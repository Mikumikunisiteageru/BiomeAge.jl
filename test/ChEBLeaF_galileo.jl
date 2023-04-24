# test/ChEBLeaF_galileo.jl

using BiomeAge
using Entropics
using GeologicTime
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
figure(figsize=(6.4, 7.2))

try ax1.remove() catch ; end
# ax1 = PyPlot.axes([0.17, 0.94, 0.66, 0.05])
ax1 = PyPlot.axes([103/4100, 0.94, 0.83 - 103/4100, 0.05])
drawtimescale(ax1, 100, 0, [3, 4]; fontsize=8, texts = Dict(
	"Cretaceous" => "Cretaceous", "Paleogene" => "Paleogene", 
	"Neogene" => "Neogene", "Quaternary" => "Q", 
	"Late Cretaceous" => "Late Cretaceous", "Paleocene" => "Paleoc.", 
	"Eocene" => "Eocene", "Oligocene" => "Oligoc.", "Miocene" => "Miocene", 
	"Pliocene" => "P", "Pleistocene" => "P"))

try ax2.remove() catch ; end
ax2 = PyPlot.axes([103/4100, 0.69, 0.83 - 103/4100, 0.24])
crowns = sum(crown_ages)
ax2.plot(TIMES, crowns)
ax2.set_ylim([0, 3])
ax2.tick_params(left=false, labelleft=false, right=true, labelright=true, 
	bottom=false, labelbottom=false)
ax2.set_xlim([100, 0])
ax2.set_ylabel("Crown LAR / Ma\$^{-1}\$", labelpad=7)
ax2.yaxis.set_label_position("right")

try ax3.remove() catch ; end
ax3 = PyPlot.axes([0.17, 0.06, 0.66, 0.62])
STRETCH = -0.5 * maximum(maximum.(crown_ages[1:n-2] .+ crown_ages[3:n]))
EPSILON = 0.1 * minimum(maximum.(crown_ages))
LOWER = ((n+1) >> 1 + 0.9) * STRETCH
UPPER = -0.5 * STRETCH
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
		ax3.fill_between(TIMES[s:t], y .+ crown_age[s:t], y .- crown_age[s:t], 
			lw=0, fc=COLOR_RIN, alpha=0.75, zorder=-10)
		ax3.plot([NOW, TIMES[s]], [y, y], "--", c="k", lw=0.4, zorder=-10)
		ax3.text(SUBNOW - TEXTSEP, y, print_name(lineages[i].name, :left), 
			ha="left", va="center", fontsize=8)
	else
		y = (i - n/2) * STRETCH
		ax3.fill_between(TIMES[s:t], y .+ crown_age[s:t], y .- crown_age[s:t], 
			lw=0, fc=COLOR_LEN, alpha=0.75, zorder=-10)
		ax3.plot([TIMES[t], OLD], [y, y], "--", c="k", lw=0.4, zorder=-10)
		ax3.text(SUBOLD + TEXTSEP, y, print_name(lineages[i].name, :right), 
			ha="right", va="center", fontsize=8)
	end
	ax3.fill_between(TIMES[s:t], y .+ crown_age[s:t], y .- crown_age[s:t], 
		lw=0.4, ec="k", fc="none", alpha=1, zorder=-1)
	ax3.plot(mean(lineages[i].crown), y, ".", c="k", ms=3)
end
ax3.set_xlim([SUBOLD, SUBNOW])
ax3.set_ylim([LOWER, UPPER])
ax3.set_yticks([])
ax3.set_xlabel("Time / Ma", labelpad=2)
