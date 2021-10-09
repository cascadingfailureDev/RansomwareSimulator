# find available targets to attack
function available_targets(initiator, servers)
    ignored_servers = []
    for x in initiator.targets
        push!(ignored_servers, x.target)
    end
    push!(ignored_servers, initiator)
    potential_servers = setdiff(servers, ignored_servers)
    return [i for i in potential_servers if i.susceptible]
end

# add targets to target array until array has length == attack_parallelism
function add_targets!(servers, rng, attack_parallelism, initiator)
    while length(initiator.targets) < attack_parallelism
        targets = available_targets(initiator, servers)
        if length(targets) == 0 break end
        server = Random.rand(rng, targets)
        time_remaining = Random.rand(rng, 1:500)
        target = Target(
            target = server,
            tᵣ = time_remaining)
        push!(initiator.targets, target)
    end
    return nothing
end

# Initialization loads external configuration, assigns simulation wide varaibles
# to parameters, and loads any defined servers in the configuration file to
# state.state, finally if no infected server has been specified in the
# configuration file, one is selected at random, and any infected servers have
# targets assigned according to the attack_parallelism parameter
function initialize_parameters(config)
    setup = config["setup"]
    random_seed = setup["random_seed"]
    rng = Random.MersenneTwister(random_seed)
    encrypt_gbs⁻¹ = setup["average_time_to_encypt_gb"]
    attack_parallelism = setup["attack_parallelism"]
    forensics = config["setup"]["forensics"]
    forensics = config["setup"]["forensics"]
    restore_time = config["setup"]["restore_time"]
    post_ante = config["post_ante"]
        parameters = Parameters(
            random_seed = random_seed,
            rng = rng,
            encrypt_gbs⁻¹ = encrypt_gbs⁻¹,
            attack_parallelism = attack_parallelism,
            forensics = forensics,
            restore_time = restore_time,
            post_ante = post_ante)
        return(parameters)
end

function initialize_state(config, parameters)
    state = State()
    specified_starting_server = false

    for server in config["servers"]
        time_to_encrypt = server["disk_size_gb"] * parameters.encrypt_gbs⁻¹
        x = Server(
            system_id = server["system_id"],
            disk_size = server["disk_size_gb"],
            susceptible = server["susceptible"],
            t_to_encrypt = time_to_encrypt,
            status = InfectionStatus(
                infected = server["infected"],
                encrypted = false,
                encrypting = false,
                encryption_start = nothing),
                targets = [])
        push!(state.state, x)

        state.susceptible = length([i for i in state.state if i.susceptible])

        if server["infected"] == true && specified_starting_server == false
            specified_starting_server = true
            infected_action = Action(
                action = INFECT,
                initiator = nothing,
                subject = x,
                step = 0)
            push!(state.actions, infected_action)
        end
    end

    if !specified_starting_server
        println("no infected server created, randoming infecting server")
        range_of_servers = range(1, stop= length(state.state), step = 1)
        initial_infection = Random.rand(parameters.rng, range_of_servers)
        state.state[initial_infection].status.infected = true
        state.infected_servers += 1
        infected_action = Action(
            action = INFECT,
            initiator = nothing,
            subject = state.state[initial_infection],
            step = 0)
        push!(state.actions, infected_action)
    end
    return(state)
end


function complete_attack!(initiator, target, state)
    if !target.target.status.infected
        target.target.status.infected = true
        state.infected_servers += 1
        infected_action = Action(
            action = INFECT,
            initiator = initiator,
            subject = target.target,
            step = state.step)
        push!(state.actions, infected_action)
    end
    filter!(e->e≠target,initiator.targets)

    return nothing
end


# runs each time the step increases and updates the current state
function update!(parameters, state)
    current_encrypted_gb = 0.0
    for server in state.state
        if server.status.infected
            # attacking phase
            for target in server.targets
                target.tᵣ -= 1
                if target.tᵣ == 0
                    complete_attack!(server, target, state)
                end
            end
            add_targets!(state.state, parameters.rng, parameters.attack_parallelism, server)

            if !server.status.encrypting && !server.status.encrypted
                    server.status.encrypting = true
                    state.encrypting_servers += 1
                    server.status.encryption_start = state.step
                    encrypting_action = Action(
                        action = ENCRYPTING,
                        initiator = nothing,
                        subject = server,
                        step = state.step)
                    push!(state.actions, encrypting_action)
            end
        end
        # encrpyting phase
        if server.status.encrypting
            t_encrypting = state.step - server.status.encryption_start
            if t_encrypting == server.t_to_encrypt
                server.status.encrypting = false
                server.status.encrypted = true
                state.encrypting_servers -= 1
                state.encrypted_servers += 1
                encrypted_action = Action(
                    action = ENCRYPTED,
                    initiator = nothing,
                    subject = server,
                    step = state.step)
                push!(state.actions, encrypted_action)
            end
            eₜ = state.step - server.status.encryption_start
            eᵥ = (server.disk_size * eₜ / server.t_to_encrypt)
            current_encrypted_gb += eᵥ
        elseif server.status.encrypted
            current_encrypted_gb += server.disk_size
        end

    end
    push!(state.encrpyted_gb,EncryptedGB(step=state.step,
                                            encrypted=current_encrypted_gb))
    state.step += 1
    return nothing
end

function run_simulation!(parameters::Parameters, state::State)
    print("simulation running...")
    while state.encrypted_servers < state.susceptible
        update!(parameters, state)
    end
    println("\nsimulation over, all servers infected")
    return nothing
end

function run_simulation(config::Dict)
    println("Initializing simulation")
    parameters = initialize_parameters(config)
    state = initialize_state(config, parameters)
    run_simulation!(parameters, state)
    return parameters, state
end
