using RansomwareSimulator, Test

@testset "Nₜ" begin
    @test RansomwareSimulator.Nₜ(0, 1, 0, 100) == 0.001
    @test RansomwareSimulator.Nₜ(0, 1, 1, 100) == 1.001
    @test RansomwareSimulator.Nₜ(1, 1, 0, 100) ≈ 0.00299 atol=0.00001
    @test RansomwareSimulator.Nₜ(1, 5, 0, 100) ≈ 0.09276 atol=0.00001
    @test RansomwareSimulator.Nₜ(1, 0, 0, 60) == 0.001
end
