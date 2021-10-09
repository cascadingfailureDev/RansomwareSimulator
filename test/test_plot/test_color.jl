using RansomwareSimulator, Test

@testset "color" begin
    @test RansomwareSimulator.color("red") == (0, 0.2, :red)
    @test RansomwareSimulator.color("notdefined") == false
end
