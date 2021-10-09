using RansomwareSimulator, Test

@testset "bestX" begin
    @test_throws BoundsError RansomwareSimulator.bestX([])
    let times = [0]
        updated_times, xlabel = RansomwareSimulator.bestX(times)
        @test updated_times == [0.0]
        @test xlabel == "Time in milliseconds"
    end
    let times = [0,1,285,1000,5000]
        updated_times, xlabel = RansomwareSimulator.bestX(times)
        @test updated_times == [0.0,1.0,285.0,1000.0,5000.0]
        @test xlabel == "Time in milliseconds"
    end
    let times = [0,1,285,5001]
        updated_times, xlabel = RansomwareSimulator.bestX(times)
        @test updated_times == [0.0,0.001,0.285,5.001]
        @test xlabel == "Time in seconds"
    end
    let times = [0,1,285,5001, 960000]
        updated_times, xlabel = RansomwareSimulator.bestX(times)
        @test updated_times == [0.0,0.001,0.285,5.001,960.0]
        @test xlabel == "Time in seconds"
    end
    let times = [960000, 960001]
        updated_times, xlabel = RansomwareSimulator.bestX(times)
        @test updated_times == (times ./ (1000*60))
        @test xlabel == "Time in minutes"
    end
    let times = [960001, 57600000]
        updated_times, xlabel = RansomwareSimulator.bestX(times)
        @test updated_times == (times ./ (1000*60))
        @test xlabel == "Time in minutes"
    end
    let times = [960001, 57600001]
        updated_times, xlabel = RansomwareSimulator.bestX(times)
        @test updated_times == (times ./ (1000*60*60))
        @test xlabel == "Time in hours"
    end
    let times = [960001, 259200000]
        updated_times, xlabel = RansomwareSimulator.bestX(times)
        @test updated_times == (times ./ (1000*60*60))
        @test xlabel == "Time in hours"
    end
    let times = [3,57600001, 259200001]
        updated_times, xlabel = RansomwareSimulator.bestX(times)
        @test updated_times == (times ./ (1000*60*60*24))
        @test xlabel == "Time in days"
    end
end
