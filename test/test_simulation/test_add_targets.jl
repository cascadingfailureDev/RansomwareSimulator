using RansomwareSimulator, Test
import Random

@testset "add_targets!" begin
    #test empty servers
    empty_rng = Random.MersenneTwister(1234)
    empty_attack_parallelism = 3
    empty_initiator = RansomwareSimulator.Server(
    system_id = "initiator",
    disk_size = 500,
    susceptible = true,
    t_to_encrypt = 1000,
    status = RansomwareSimulator.InfectionStatus(
        infected = true,
        encrypted = false,
        encrypting = false,
        encryption_start = nothing),
        targets = [])

    RansomwareSimulator.add_targets!(RansomwareSimulator.Server[], empty_rng, empty_attack_parallelism, empty_initiator)
    @test isempty(empty_initiator.targets)

    #test no susceptible servers
    nosus_rng = Random.MersenneTwister(1234)
    nosus_attack_parallelism = 3
    nosus_initiator = RansomwareSimulator.Server(
    system_id = "initiator",
    disk_size = 500,
    susceptible = true,
    t_to_encrypt = 1000,
    status = RansomwareSimulator.InfectionStatus(
        infected = true,
        encrypted = false,
        encrypting = false,
        encryption_start = nothing),
        targets = [])
    servers_nosus = RansomwareSimulator.Server[]
    for i in range(1, stop= 5, step = 1)
        push!(servers_nosus, RansomwareSimulator.Server(
        system_id = string("server",i),
        disk_size = 500,
        susceptible = false,
        t_to_encrypt = 1000,
        status = RansomwareSimulator.InfectionStatus(
            infected = true,
            encrypted = false,
            encrypting = false,
            encryption_start = nothing),
            targets = [])
        )
    end
    RansomwareSimulator.add_targets!(servers_nosus, nosus_rng, nosus_attack_parallelism, nosus_initiator)
    @test isempty(empty_initiator.targets)

    # test less servers than needed
    less_rng = Random.MersenneTwister(1234)
    less_attack_parallelism = 3
    less_initiator = RansomwareSimulator.Server(
    system_id = "initiator",
    disk_size = 500,
    susceptible = true,
    t_to_encrypt = 1000,
    status = RansomwareSimulator.InfectionStatus(
        infected = true,
        encrypted = false,
        encrypting = false,
        encryption_start = nothing),
        targets = [])
    less_servers = RansomwareSimulator.Server[]
    for i in range(1, stop= 2, step = 1)
        push!(less_servers, RansomwareSimulator.Server(
        system_id = string("server",i),
        disk_size = 500,
        susceptible = true,
        t_to_encrypt = 1000,
        status = RansomwareSimulator.InfectionStatus(
            infected = true,
            encrypted = false,
            encrypting = false,
            encryption_start = nothing),
            targets = [])
        )
    end
    RansomwareSimulator.add_targets!(less_servers, less_rng, less_attack_parallelism, less_initiator)
    @test length(less_initiator.targets) == 2

    # test susceptible servers
    rng = Random.MersenneTwister(1234)
    attack_parallelism = 3
    initiator = RansomwareSimulator.Server(
    system_id = "initiator",
    disk_size = 500,
    susceptible = true,
    t_to_encrypt = 1000,
    status = RansomwareSimulator.InfectionStatus(
        infected = true,
        encrypted = false,
        encrypting = false,
        encryption_start = nothing),
        targets = [])
    servers = RansomwareSimulator.Server[]
    for i in range(1, stop= 5, step = 1)
        push!(servers, RansomwareSimulator.Server(
            system_id = string("server",i),
            disk_size = 500,
            susceptible = true,
            t_to_encrypt = 1000,
            status = RansomwareSimulator.InfectionStatus(
                infected = true,
                encrypted = false,
                encrypting = false,
                encryption_start = nothing),
                targets = [])
        )
    end
        RansomwareSimulator.add_targets!(servers, rng, attack_parallelism, initiator)
        @test length(initiator.targets) == 3

    # test no space
    space_rng = Random.MersenneTwister(1234)
    space_attack_parallelism = 3
    space_initiator = RansomwareSimulator.Server(
    system_id = "initiator",
    disk_size = 500,
    susceptible = true,
    t_to_encrypt = 1000,
    status = RansomwareSimulator.InfectionStatus(
        infected = true,
        encrypted = false,
        encrypting = false,
        encryption_start = nothing),
        targets = [])
    space_servers = RansomwareSimulator.Server[]
    for i in range(1, stop= 5, step = 1)
        push!(space_servers, RansomwareSimulator.Server(
            system_id = string("server",i),
            disk_size = 500,
            susceptible = true,
            t_to_encrypt = 1000,
            status = RansomwareSimulator.InfectionStatus(
                infected = true,
                encrypted = false,
                encrypting = false,
                encryption_start = nothing),
                targets = [])
        )
    end
    current_targets = RansomwareSimulator.Target[]
    for i in range(1, stop=3, step=1)
        tmp_target = RansomwareSimulator.Target(target=space_servers[i], tᵣ=500)
        push!(space_initiator.targets, tmp_target)
        push!(current_targets, tmp_target)
    end
    RansomwareSimulator.add_targets!(space_servers, space_rng, space_attack_parallelism, space_initiator)
    @test space_initiator.targets == current_targets


    # test servers only contains initiator
    only_rng = Random.MersenneTwister(1234)
    only_attack_parallelism = 3
    only_initiator = RansomwareSimulator.Server(
    system_id = "initiator",
    disk_size = 500,
    susceptible = true,
    t_to_encrypt = 1000,
    status = RansomwareSimulator.InfectionStatus(
        infected = true,
        encrypted = false,
        encrypting = false,
        encryption_start = nothing),
        targets = [])

    RansomwareSimulator.add_targets!(RansomwareSimulator.Server[only_initiator], only_rng, only_attack_parallelism, only_initiator)
    @test isempty(only_initiator.targets)
end
