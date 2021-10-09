module RansomwareSimulator
    import Random
    import YAML
    import Plots
    import Trapz

    export AbstractActionType,
            ActionType,
            Parameters,
            AbstractServer,
            Target,
            Server,
            State,
            generate_config,
            available_targets,
            add_targets!,
            initialize_parameters,
            initialize_state,
            update!,
            run_simulation!,
            run_simulation,
            infection_plot,
            encrypted_plot,
            Nₜ,
            function_loss_plot

    include("ransomware_structs.jl")
    include("ransomware_simulation_functions.jl")
    include("ransomware_plot_functions.jl")
    include("ransomware_config_generator.jl")

end
