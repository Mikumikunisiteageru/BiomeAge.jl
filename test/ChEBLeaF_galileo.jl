# test/ChEBLeaF_galileo.jl

using BiomeAge
using Entropics
using GeologicTime
using PyPlot

cd(joinpath(pkgdir(BiomeAge), "test"))

lineages = read_lineages_from_tsv("ChEBLeaF_db.tsv")
sort!(lineages, by = lineage -> mean(lineage.crown))
crown_ages = get_age_distribution.(lineages, :crown, 1.0)
stem_ages = get_age_distribution.(lineages, :stem, 1.0)

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
crown_color = "#469825"
ax2 = PyPlot.axes([103/4100, 0.69, 0.83 - 103/4100, 0.24])
crowns = sum(crown_ages)
xps = get_change_points(crowns)
ax2.plot(TIMES, crowns; c=crown_color)
d, u = 0, 3
ax2.set_ylim([d, u])
hd1 = hd2 = nothing
for (l, r) = [(25, 20), (15, 4)]
	hd1, = ax2.fill([l, l, r, r], [d, u, u, d]; c="#dadcea", lw=0, zorder=-20)
end
for xp = xps
	hd2, = ax2.plot([xp, xp], [d, u], "-.k"; lw=0.8, zorder=-10)
end
x = xps[2]
i = searchsorted(TIMES, x)
y = 2 \ (crowns[i.start] + crowns[i.stop])
hd3, = ax2.plot(x, y, "*"; 
	c=crown_color, ms=12, markerfacecolor="w", linewidth=1.0)
ax2.tick_params(left=false, labelleft=false, right=true, labelright=true, 
	bottom=false, labelbottom=false)
ax2.set_xlim([100, 0])
ax2.set_ylabel("Crown LAR / Ma\$^{-1}\$", labelpad=7)
ax2.text(-15, 1.8, "(Lineage Accumulation Rate)";
	rotation="vertical", ha="center", va="center")
ax2.yaxis.set_label_position("right")
ax2.legend([hd1, hd2, hd3], 
	["Intenser monsoon", "Change point", "Time of origin"]; 
	loc="lower right", fontsize=8.5, framealpha=0.9, 
	labelspacing=0.4, handlelength=1.5, handletextpad=0.5, borderaxespad=0.7)

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

try ax4.remove() catch ; end
stem_color = "#a1752c"
ax4 = PyPlot.axes([0.05, 0.76, 0.42, 0.155])
stems = sum(stem_ages)
xps = get_change_points(stems)
ax4.plot(TIMES, stems; c=stem_color)
d, u = 0, 2.2
for xp = xps
	ax4.plot([xp, xp], [d, u], "-.k"; lw=0.8, zorder=-10)
end
x = xps[1]
i = searchsorted(TIMES, x)
y = 2 \ (stems[i.start] + stems[i.stop])
ax4.plot(x, y, "*"; 
	c=stem_color, ms=8, markerfacecolor="w", linewidth=1.0)
ax4.set_xlim([120, 0])
ax4.tick_params(axis="x", pad=2, labelsize=8, length=2)
ax4.set_xlabel("Time / Ma", fontsize=9, labelpad=3, loc="left")
ax4.set_ylim([d, u])
ax4.set_yticks(0:0.5:2.0)
ax4.tick_params(left=false, labelleft=false, right=true, labelright=true)
ax4.tick_params(axis="y", pad=2, labelsize=8, length=2)
ax4.set_ylabel("Stem LAR / Ma\$^{-1}\$", fontsize=9, labelpad=3, loc="top")
ax4.yaxis.set_label_position("right")

try ax0.remove() catch ; end
ax0 = PyPlot.axes([0, 0, 1, 1])
ax0.set_facecolor("none")
ax0.text(0.083, 0.896, "(a)"; ha="center", va="center", fontsize=10)
ax0.text(0.605, 0.896, "(b)"; ha="center", va="center", fontsize=10)
ax0.text(0.539, 0.111, "(c)"; ha="center", va="center", fontsize=10)
ax0.axis("off")

savefig("ChEBLeaF_galileo_w6in4.pdf")
