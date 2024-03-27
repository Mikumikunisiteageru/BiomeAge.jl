# test/runtests.jl

using Aqua
using BiomeAge
using Test

Aqua.test_ambiguities(BiomeAge)
Aqua.test_unbound_args(BiomeAge)
Aqua.test_undefined_exports(BiomeAge)
Aqua.test_piracy(BiomeAge)
Aqua.test_project_extras(BiomeAge)
Aqua.test_stale_deps(BiomeAge)
Aqua.test_deps_compat(BiomeAge)
Aqua.test_project_toml_formatting(BiomeAge)

@testset "now" begin
	@test BiomeAge.NOW === 0.0
	@test get_now() === 0.0
	@test BiomeAge.set_now(1) == 1
	@test get_now() === 1.0
	@test BiomeAge.set_now(0) == 0
	@test get_now() === 0.0
end

@testset "old" begin
	@test BiomeAge.OLD === 120.0
	@test get_old() === 120.0
	@test BiomeAge.set_old(130) == 130
	@test get_old() === 130.0
	@test BiomeAge.set_old(120) == 120
	@test get_old() === 120.0
end

@testset "sep" begin
	@test BiomeAge.SEP === 0.1
	@test get_sep() === 0.1
	@test BiomeAge.set_sep(0.2) == 0.2
	@test get_sep() === 0.2
	@test BiomeAge.set_sep(0.1) == 0.1
	@test get_sep() === 0.1
end

@testset "times" begin
	@test get_times() == 0.0:0.1:120
	@test get_times(3:9) == 0.2:0.1:0.8
	@test get_times(39) === 3.8
end

@testset "num_or_nothing" begin
	@test BiomeAge.num_or_nothing(2) === 2
	@test BiomeAge.num_or_nothing(0.3) === 0.3
	@test BiomeAge.num_or_nothing(nothing) === nothing
	@test BiomeAge.num_or_nothing("nothing") === nothing
end
