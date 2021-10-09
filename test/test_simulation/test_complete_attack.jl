using RansomwareSimulator, Test

@testset "complete_attack!" begin
    let target = RansomwareSimulator.Target(target = RansomwareSimulator.Server(
                system_id = "target",
                disk_size = 500,
                susceptible = true,
                t_to_encrypt = 5,
                status = RansomwareSimulator.InfectionStatus(
                    infected = false,
                    encrypted = false,
                    encrypting = false,
                    encryption_start = nothing),
                targets = []),tᵣ = 0),
            initator = RansomwareSimulator.Server(
                system_id = "initiator",
                disk_size = 500,
                susceptible = true,
                t_to_encrypt = 5,
                status = RansomwareSimulator.InfectionStatus(
                    infected = true,
                    encrypted = false,
                    encrypting = false,
                    encryption_start = nothing),
                targets = []),
            state = RansomwareSimulator.State(
                state = [target.target, initator],
                step = 5,
                actions = [],
                infected_servers = 1,
                encrypting_servers = 0,
                encrypted_servers = 0,
                encrpyted_gb = [],
                susceptible = 2,
            )
        RansomwareSimulator.complete_attack!(initator, target, state)
        @test length(state.actions) == 1
        @test isempty(initator.targets)
        @test target.target.status.infected == true
        @test state.infected_servers == 2
    end

    let target = RansomwareSimulator.Target(target = RansomwareSimulator.Server(
                system_id = "target",
                disk_size = 500,
                susceptible = true,
                t_to_encrypt = 5,
                status = RansomwareSimulator.InfectionStatus(
                    infected = true,
                    encrypted = false,
                    encrypting = false,
                    encryption_start = nothing),
                targets = []),tᵣ = 0),
            initator = RansomwareSimulator.Server(
                system_id = "initiator",
                disk_size = 500,
                susceptible = true,
                t_to_encrypt = 5,
                status = RansomwareSimulator.InfectionStatus(
                    infected = true,
                    encrypted = false,
                    encrypting = false,
                    encryption_start = nothing),
                targets = []),
            state = RansomwareSimulator.State(
                state = [target.target, initator],
                step = 5,
                actions = [],
                infected_servers = 1,
                encrypting_servers = 0,
                encrypted_servers = 0,
                encrpyted_gb = [],
                susceptible = 2,
            )
        RansomwareSimulator.complete_attack!(initator, target, state)
        @test isempty(state.actions)
        @test isempty(initator.targets)
        @test state.infected_servers == 1
    end
end
