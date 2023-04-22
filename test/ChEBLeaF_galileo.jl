# test/ChEBLeaF_galileo.jl

using BiomeAge
using Entropics
using PyPlot

cd(joinpath(pkgdir(BiomeAge), "test"))

lineages = read_lineages_from_tsv("ChEBLeaF_db.tsv")
sort!(lineages, by = lineage -> mean(lineage.crown))
crown_ages = get_age_distribution.(lineages, :crown, 1.0)

n = length(lineages)

function print_name(name, ha=:left)
	if ha == :left
		return "\$" * replace(name, r" \(.+\)" => s"*") * "\$"
	elseif ha == :right
		return "\$" * replace(name, r"(.+) \(.+\)" => s"*\\,\1") * "\$"
	else
		error("Wrong `ha` value!")
	end
end

close()
figure(figsize=(6.4, 6.4))
STRETCH = -0.5 * maximum(maximum.(crown_ages[1:n-2] .+ crown_ages[3:n]))
EPSILON = 0.1 * minimum(maximum.(crown_ages))
LOWER = ((n+1) >> 1 + 1.3) * STRETCH
UPPER = -1 * STRETCH
SUBNOW = 0
SUBOLD = 82
TEXTSEP = 2
COLOR_LEN = "#FFE211"
COLOR_RIN = "#FFA500"
for (i, crown_age) = enumerate(crown_ages)
	s = findfirst(crown_age .>= EPSILON)
	t = findlast(crown_age .>= EPSILON)
	if i <= (n+1) >> 1
		y = i * STRETCH
		fill_between(TIMES[s:t], y .+ crown_age[s:t], y .- crown_age[s:t], 
			lw=0, fc=COLOR_RIN, alpha=0.75, zorder=-10)
		plot([NOW, TIMES[s]], [y, y], "--", c="k", lw=0.4, zorder=-10)
		text(SUBNOW - TEXTSEP, y, print_name(lineages[i].name, :left), 
			ha="left", va="center", fontsize=8)
	else
		y = (i - n/2) * STRETCH
		fill_between(TIMES[s:t], y .+ crown_age[s:t], y .- crown_age[s:t], 
			lw=0, fc=COLOR_LEN, alpha=0.75, zorder=-10)
		plot([TIMES[t], OLD], [y, y], "--", c="k", lw=0.4, zorder=-10)
		text(SUBOLD + TEXTSEP, y, print_name(lineages[i].name, :right), 
			ha="right", va="center", fontsize=8)
	end
	fill_between(TIMES[s:t], y .+ crown_age[s:t], y .- crown_age[s:t], 
		lw=0.4, ec="k", fc="none", alpha=1, zorder=-1)
	plot(mean(lineages[i].crown), y, ".", c="k", ms=3)
end
xlim([0, 82])
ylim([LOWER, UPPER])
gca().invert_xaxis()
yticks([])
gca().set_position([0.17, 0.1, 0.66, 0.85])
