using RansomwareSimulator, Test

@testset "available_targets" begin
    # test availble susceptible servers are returned
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
    server_initiator = [servers; initiator]
    returned_servers = RansomwareSimulator.available_targets(initiator, server_initiator)
    @test returned_servers  == servers

    # test that single server is handled correctly
    initator_only = RansomwareSimulator.available_targets(initiator, RansomwareSimulator.Server[initiator])
    @test initator_only == RansomwareSimulator.Server[]

    initiator = nothing
    servers = nothing
    server_initiator = nothing
    returned_servers = nothing

    # test that already targeted servers are not returned
    initiator_full = RansomwareSimulator.Server(
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

    servers_full = RansomwareSimulator.Server[]
    for i in range(1, stop= 5, step = 1)
        push!(servers_full, RansomwareSimulator.Server(
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
    for i in servers_full
        push!(initiator_full.targets, RansomwareSimulator.Target(target=i, tᵣ=500))
    end

    full = RansomwareSimulator.available_targets(initiator_full, RansomwareSimulator.Server[servers_full; initiator_full])
    @test full == RansomwareSimulator.Server[]

    initiator_full = nothing
    servers_full = nothing
    full = nothing

    # test available non-susceptible servers are not returned
    initiator_nonsus = RansomwareSimulator.Server(
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

    servers_non_sus = RansomwareSimulator.Server[]
    for i in range(1, stop= 5, step = 1)
        push!(servers_non_sus, RansomwareSimulator.Server(
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
    nonsus = RansomwareSimulator.available_targets(initiator_nonsus, RansomwareSimulator.Server[servers_non_sus; initiator_nonsus])
    @test nonsus == RansomwareSimulator.Server[]

    initiator_nonsus = nothing
    servers_non_sus = nothing
    nonsus = nothing

    # test emypty server list
    initiator_empty = RansomwareSimulator.Server(
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

    empty = RansomwareSimulator.available_targets(initiator_empty, RansomwareSimulator.Server[])
    @test empty == RansomwareSimulator.Server[]

    initiator_empty = nothing
    empty = nothing
end
