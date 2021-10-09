using SafeTestsets

@time @safetestset "available_targets Tests" begin include("test_simulation/test_available_targets.jl") end
@time @safetestset "add_targets! Tests" begin include("test_simulation/test_add_targets.jl") end
@time @safetestset "complete_attack! Tests" begin include("test_simulation/test_complete_attack.jl") end

@time @safetestset "color Tests" begin include("test_plot/test_color.jl") end
@time @safetestset "bestX Tests" begin include("test_plot/test_bestX.jl") end
@time @safetestset "Nₜ Tests" begin include("test_plot/test_nt.jl") end
