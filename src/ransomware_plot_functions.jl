"""
    color(color)
Returns standard plot fill as (fillrange, alpha, `color`) for `color`:
  - red
  - green
  - light green
  - yellow
any other color is returned as false.
"""
function color(color)
    if color == "red"
        return (0, 0.2, :red)
    elseif color == "green"
        return (0, 0.2, :green)
    elseif color == "light green"
        return (0, 0.1, :green)
    elseif color == "yellow"
        return (0, 0.2, :yellow)
    else
        return false
    end
end

"""
    getActions(type, state)
Returns sum of `state.[actions]` of type `type` over time,
as two vectors `volume`, `time`
"""
function getActions(type, state)
    volume = []
    time = []
    counter = 0
    for action in state.actions
        if action.action == type
            push!(time, action.step)
            push!(volume, counter + 1)
            counter += 1
        end
    end
    return volume, time
end

"""
    bestX(times)
Returns vector `times` in an opinionated best unit, based on largest time value:
  - milliseconds for values up to 5 seconds
  - seconds for values up to 16 minutes
  - minutes for values up to 16 hours
  - hours for values up to 3 days
  - days for any value over 3 days
and string `xlabel` = time in milliseconds / seconds / minutes / hours / days
"""
function bestX(times)
    ms_longest = last(times)
    s_longest = ms_longest / 1000
    m_longest = s_longest / 60
    h_longest = m_longest / 60
    d_longest = h_longest / 24

    if d_longest > 3
        updated_times = times ./ (1000 * 60 * 60 * 24)
        xlabel = "Time in days"
    elseif h_longest > 16
        updated_times = times ./ (1000 * 60 * 60)
        xlabel = "Time in hours"
    elseif m_longest > 16
        updated_times = times ./ (1000 * 60)
        xlabel = "Time in minutes"
    elseif s_longest > 5
        updated_times = times ./ 1000
        xlabel = "Time in seconds"
    else
        updated_times = times
        xlabel = "Time in milliseconds"
    end
    return updated_times, xlabel
end

"""
    infection_plot(state)
Returns plot of infected servers over time, based on data in `state.actions`
"""
function infection_plot(state)
    ylabel = "Infected Servers"
    infection_volume, infection_time = getActions(INFECT, state)
    infection_time, xlabel = bestX(infection_time)
    return Plots.plot(infection_time,
                        infection_volume,
                        xlabel=xlabel,
                        ylabel=ylabel,
                        seriestype=:scatter,
                        color=:red,
                        legend=false,
                        title="Infected Servers")
end

"""
    encrypted_plot(state)
Returns a plot of fully encrypted servers over time, based on data in `state.actions`
"""
function encrypted_plot(state)
    ylabel = "Encrypted Servers"
    v_encrypted, t_encrypted = getActions(ENCRYPTED, state)
    t_encrypted, xlabel = bestX(t_encrypted)

    return Plots.plot(t_encrypted,
                        v_encrypted,
                        xlabel=xlabel,
                        ylabel=ylabel,
                        seriestype=:scatter,
                        color=:red,
                        legend=false,
                        title="Encrypted Servers")
end

"""
    encrypted_plot(state)
Returns a plot of encrypted GB over time, based on data in `state.encrpyted_gb`
and point of complete encryption of servers based on data in `state.actions`
"""
function encrypted_gb_plot(state)
    ylabel = "GB encrypted"
    v_encrypted, t_encrypted = getActions(ENCRYPTED, state)
    v_encrypted = v_encrypted .* 0
    t_encrypted, xlabel = bestX(t_encrypted)

    encrypted_gb_time = [i.step / (1000 * 60) for i in state.encrpyted_gb]
    encrypted_gb = [i.encrypted for i in state.encrpyted_gb]

    total_gb = sum([i.disk_size for i in state.state])
    total_gb_plot = [total_gb,total_gb]
    total_gb_plot_time = [0,last(t_encrypted)]
    encrypted_gb_plot = Plots.plot(total_gb_plot_time,
                                    total_gb_plot,
                                    color=false,
                                    fill=(0,0,:white),
                                    grid = false)
    Plots.plot!(total_gb_plot_time,total_gb_plot,color=false,fill=color("green"))
    Plots.plot!(encrypted_gb_time, encrypted_gb,color=false, fill=(0,1,:white))
    Plots.plot!(encrypted_gb_time,
                    encrypted_gb,
                    xlabel=xlabel,
                    ylabel=ylabel,
                    title="Encrypted GB",
                    color=:red,
                    fill=color("red"),
                    legend=false)
    Plots.plot!(t_encrypted,
                    v_encrypted,
                    seriestype=:scatter,
                    color=:red)
    restore_time = last(encrypted_gb) * parameters.restore_time / (1000*60*60)
    Time_to_restore = string("Estimated Time to\nRestore from backup:\n",
                                Int(round(restore_time)), " hours")
    xpos = Plots.xlims(encrypted_gb_plot)[2] / 1.5
    ypos = Plots.ylims(encrypted_gb_plot)[2] / 2
    Plots.annotate!(xpos,ypos, (Time_to_restore, :black, :center))
    return encrypted_gb_plot
end

"""
    Nₜ(t, multiplier, recovery_start, r_point)
Returns
"""
function Nₜ(t, multiplier, recovery_start, r_point)
    N₀ = 0.001
    plateau = log((100-recovery_start)/N₀)
    growth = (1 - ℯ^(-(((1/r_point * 10)* multiplier) * 1)*t))
    curve = N₀*ℯ^(plateau * growth)
    return curve + recovery_start
end

"""
    function_loss_plot(state, parameters, post_ante=nothing)

Returns plot
"""
function function_loss_plot(state, parameters, post_ante=nothing)
    ms_day = 1000*60*60*24
    ms_hour = 1000*60*60
    n_servers = length(state.state)
    forensics_multiplier = 1
    restore_multiplier = 1
    plot_name = "Recovery Curve"
    v_encrypted, t_encrypted = getActions(ENCRYPTED,state)
    pushfirst!(v_encrypted, 0)
    pushfirst!(t_encrypted, 0)
    lost_functionality = [100 - (i / n_servers) * 100 for i in v_encrypted]
    t_forensics = ((parameters.forensics*ms_hour) / forensics_multiplier)
    r_forensics = round(t_forensics, digits=0)
    forensics_time = [convert(Int64, r_forensics)]
    forensics_downtime_functionality = last(lost_functionality)
    e_gb = sum([x.disk_size for x in state.state if x.status.encrypted])
    r_point = e_gb * parameters.restore_time
    time = range(1, stop=r_point, step = 1*ms_hour)
    recovered_functionality = [Nₜ(t,
                                    restore_multiplier,
                                    last(lost_functionality),
                                    r_point) for t in time]
    recovery_time = time .+ last(forensics_time)
    complete_time = [t_encrypted;
                        forensics_time; recovery_time] ./ ms_day
    complete_functionality = [lost_functionality;
                                forensics_downtime_functionality;
                                recovered_functionality]
    fully_functional = fill(100, length(complete_time))
    recovery_plots = []

    recovery_curve = Plots.plot(complete_time,
                                    fully_functional,
                                    fill =(-10,0,:white),
                                    color=false,
                                    grid = false)
    Plots.plot!(complete_time,
                    fully_functional,
                    title=plot_name,
                    fill = color("red"),
                    color=false)
    Plots.plot!(complete_time,
                    complete_functionality,
                    fill =(-10,0,:white),
                    color=false)
    Plots.plot!(complete_time,
                    complete_functionality,
                    fill = color("green"),
                    color=:black,
                    legend = false,
                    xlabel = "Time in Days",
                    ylabel = "% Functionality")

    I = Trapz.trapz(complete_time, complete_functionality ./ 100)
    RI = I / last(complete_time)
    RI_label = string("Resilience Index:\n", round(RI; digits=3))
    xpos = Plots.xlims(recovery_curve)[2] / 1.5
    Plots.annotate!(xpos,50, (RI_label, :black, :center))
    push!(recovery_plots, recovery_curve)

    function post_ante_plots(x_forensics_multiplier, x_restore_multiplier, parameters)
        x_t_forensics = (parameters.forensics*ms_hour) / x_forensics_multiplier
        x_r_forensics = [convert(Int64, round(x_t_forensics, digits=0))]
        x_forensics_downtime_functionality = last(lost_functionality)
        step_diff = last(forensics_time) - last(x_r_forensics)
        x_time = range(1, stop=r_point + step_diff, step = 1*ms_hour)
        x_recovered_functionality = [Nₜ(t,
                                        x_restore_multiplier,
                                        last(lost_functionality),
                                        r_point) for t in x_time]
        x_recovery_time = x_time .+ last(x_r_forensics)
        x_complete_time = [t_encrypted;
                            x_r_forensics;
                            x_recovery_time] ./ ms_day
        x_complete_functionality = [lost_functionality;
                                    x_forensics_downtime_functionality;
                                    x_recovered_functionality]
        x_recovery_curve = Plots.plot(complete_time,
                                        fully_functional,
                                        fill = (0,0,:white),
                                        color=false,
                                        grid = false)
        Plots.plot!(complete_time,
                        fully_functional,
                        title=x_plot_name,
                        fill = color("red"),
                        color=false)
        Plots.plot!(x_complete_time,
                        x_complete_functionality,
                        fill =(0,0,:white),
                        color=:black)
        Plots.plot!(x_complete_time,
                        x_complete_functionality,
                        fill = color("yellow"),
                        color=:black)
        Plots.plot!(complete_time,
                        complete_functionality,
                        fill = (0,0,:white),
                        color=:black)
        Plots.plot!(complete_time,
                        complete_functionality,
                        fill = color("green"),
                        color=:black,
                        legend = false,
                        xlabel = "Time in Days",
                        ylabel = "% Functionality")
                        x_I = Trapz.trapz(x_complete_time,
                                            x_complete_functionality ./ 100)
                        x_RI = x_I / last(x_complete_time)
                            x_RI_label = string("Resilience Index:\n",
                                                round(x_RI; digits=3),
                                                "\nPercentage Improvement:\n",
                                                round((x_RI / RI * 100) - 100,
                                                digits=3), "%")
                            x_xpos = Plots.xlims(x_recovery_curve)[2] / 1.5
                            Plots.annotate!(x_xpos,50,
                                                (x_RI_label, :black, :center))
        return x_recovery_curve
    end
    if !isnothing(post_ante)
        for x in parameters.post_ante
            x_plot_name = string(get(x, "name", "Post Ante"),
                                    " Potential Improvement")
            x_forensics_multiplier = 1
            x_restore_multiplier = 1
            if "forensics" in get(x, "stages", [])
                x_forensics_multiplier += get(x, "estimated_improvement", 0)
            end
            if "restore" in get(x, "stages", [])
                x_restore_multiplier += get(x, "estimated_improvement", 0)
            end
            x_recovery_curve = post_ante_plots(x_forensics_multiplier,
                                                x_restore_multiplier,
                                                parameters)
            push!(recovery_plots, x_recovery_curve)
        end
        if length(parameters.post_ante) > 1
            x_plot_name = "Combined Potential Improvement"
            x_forensics_multiplier = 1
            x_restore_multiplier = 1
            for x in parameters.post_ante
                if "forensics" in get(x, "stages", [])
                    x_forensics_multiplier += get(x, "estimated_improvement", 0)
                end
                if "restore" in get(x, "stages", [])
                    x_restore_multiplier += get(x, "estimated_improvement", 0)
                end
            end
            x_recovery_curve = post_ante_plots(x_forensics_multiplier,
                                                x_restore_multiplier,
                                                parameters)
            push!(recovery_plots, x_recovery_curve)
        end
    end
    return recovery_plots
end
