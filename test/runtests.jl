# test/runtests.jl

using Aqua
using BiomeAge
using Entropics
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

@testset "med_wmuab" begin
	@test_throws ErrorException BiomeAge.med_wmuab((+, +, +, +, +))
	med = BiomeAge.med_wmuab(("", 0.4, "", 0, 1))
	@test isapprox(median(med), 0.4)
	med = BiomeAge.med_wmuab(("", "", 0.4, 0, 1))
	@test isapprox(mean(med), 0.4)
	med = BiomeAge.med_wmuab((0.4, "", "", 0, 1); w_as=:median)
	@test isapprox(median(med), 0.4)
	med = BiomeAge.med_wmuab((0.4, 0.3, "", 0, 1); w_as=:median)
	@test isapprox(median(med), 0.3)
	med = BiomeAge.med_wmuab((0.4, "", "", 0, 1); w_as=:mean)
	@test isapprox(mean(med), 0.4)
	med = BiomeAge.med_wmuab((0.4, "", 0.3, 0, 1); w_as=:mean)
	@test isapprox(mean(med), 0.3)
	@test_throws ErrorException BiomeAge.med_wmuab((0.4, "", "", 0, 1); w_as=:w)
	med = BiomeAge.med_wmuab((50, "", "", 0, ""); w_as=:mean)
	@test all(isapprox.(support(med), (0, get_old())))
	med = BiomeAge.med_wmuab((50, "", "", "", 90); w_as=:mean)
	@test all(isapprox.(support(med), (get_now(), 90)))
	med = BiomeAge.med_wmuab((50, "", "", 50, 50); w_as=:mean)
	@test all(isapprox.(support(med), (50 - get_sep(), 50 + get_sep())))
	@test isa(med, Entropics.MED000)
end

@testset "read_lineages_from_table" begin
	table = Any[
		"Acer"        ""     ""   64.20   63.10   67.16   ""     ""   63.10   60.47   66.33
		"Ainsliaea"	  ""   3.04    4.38    0.29   12.46   ""   1.84    2.68    0.12    7.76
	]
	lineages = BiomeAge.read_lineages_from_table(table, 1:2, 1, 2:6, 7:11)
	@test isa(lineages, Vector{BiomeAge.Lineage})
	@test length(lineages) == 2
	acer, ainsliaea = lineages
	@test acer.row == 1
	@test acer.name == "Acer"
	@test isapprox(mean(acer.stem), 64.20)
	@test isapprox(minimum(support(acer.stem)), 63.10)
	@test isapprox(maximum(support(acer.stem)), 67.16)
	@test isapprox(mean(acer.crown), 63.10)
	@test isapprox(minimum(support(acer.crown)), 60.47)
	@test isapprox(maximum(support(acer.crown)), 66.33)
	@test isapprox(mean(ainsliaea.stem), 4.38)
	@test isapprox(median(ainsliaea.stem), 3.04)
end

@testset "read_lineages_from_tsv" begin
	filename = joinpath("..", "chebleaf", "lineages.tsv")
	lineages = read_lineages_from_tsv(filename)
	@test isa(lineages, Vector{BiomeAge.Lineage})
	@test length(lineages) == 72
	@test lineages[end-1].name == "Yua"
end

@testset "read_lineages_from_xlsx" begin
	filename = "lineages.xlsx"
	global lineages = read_lineages_from_xlsx(filename; stem_cols=2:6, crown_cols=7:11)
	@test isa(lineages, Vector{BiomeAge.Lineage})
	@test length(lineages) == 72
	global yulania = lineages[end]
	@test yulania.name == "Yulania"
end

@testset "get_age_distribution" begin
	f = get_age_distribution(yulania, :crown)
	@test isa(f, Vector{Float64})
	@test length(f) == length(get_times())
	@test isapprox(maximum(f), 0.11682169961340769)
	f = get_age_distribution(yulania, :stem)
	@test isa(f, Vector{Float64})
	@test length(f) == length(get_times())
	@test isapprox(maximum(f), 0.24565665028062605)
end

@testset "add_up_age_distributions" begin
	f = add_up_age_distributions(lineages, :crown)
	@test isa(f, Vector{Float64})
	@test length(f) == length(get_times())
	@test isapprox(maximum(f), 2.3463025813743954)
	f = add_up_age_distributions(lineages, :stem)
	@test isa(f, Vector{Float64})
	@test length(f) == length(get_times())
	@test isapprox(maximum(f), 1.9916892900480965)
end

@testset "get_change_points" begin
	ages = Float64[0, 0, 0, 0, 0, 1, 1, 1, 1, 1, -1, -1, -1, -1, -1]
	@test_throws AssertionError get_change_points(ages; method=:NULL)
	@test isapprox(get_change_points(ages; method=:PELT, sigma=0.5), [0.45, 0.95])
	@test isapprox(get_change_points(ages; method=:BS, sigma=0.5), [0.45, 0.95])
	@test isapprox(get_change_points(ages; method=:PELT, sigma=1.5), [0.95])
	@test isapprox(get_change_points(ages; method=:BS, sigma=1.5), [0.95])
end

@testset "tlcc" begin
	ts1 = sin.(get_times())
	ts2 = sin.(get_times() .- 5)
	timelags, pearsons = tlcc(ts1, ts2)
	@test timelags == -10.0:0.1:10.0
	x, index = findmax(pearsons)
	@test isapprox(x, 1.0)
	@test index == 51
	@test isapprox(sum(pearsons), -3.3704949274837204)
end

@testset "get_extremum_points" begin
	ts = sin.(get_times() ./ (35/pi))
	extremum_points = get_extremum_points(ts)
	@test extremum_points == [(87.5, 1.0, '^'), (52.5, -1.0, 'v'), (17.5, 1.0, '^')]
end
