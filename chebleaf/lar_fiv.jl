# chebleaf/lar_fiv.jl

using BiomeAge
using DelimitedFiles
using Entropics
using GeologicTime
using PyPlot

cd(joinpath(pkgdir(BiomeAge), "chebleaf"))

table, _ = readdlm("lineages_more.tsv", '\t', header=true)
fiv = data[:, 14]
lineages = BiomeAge.read_lineages_from_table(table, axes(table, 1), 1, 2:7, 8:13)

count_by_fiv(fiv_thres=0.2) = count(fiv .>= fiv_thres)
get_scaled_lar_by_fiv(fiv_thres=0.2, group=:crown, h=1.0) = 
	add_up_age_distributions(lineages[fiv .>= fiv_thres], group, h) / count_by_fiv(fiv_thres)

close()
figure(figsize=(6.4, 4.8))

try ax1.remove() catch ; end
ax1 = PyPlot.axes([0.13, 0.865, 0.83, 0.1])
drawtimescale(ax1, 100, 0, [3, 4]; fontsize=9, texts = Dict(
	"Cretaceous" => "Cretaceous", "Paleogene" => "Paleogene", 
	"Neogene" => "Neogene", "Quaternary" => "Q", 
	"Late Cretaceous" => "Late Cretaceous", "Paleocene" => "Paleoc.", 
	"Eocene" => "Eocene", "Oligocene" => "Oligoc.", "Miocene" => "Miocene", 
	"Pliocene" => "P", "Pleistocene" => "P"))

try ax2.remove() catch ; end
ax2 = PyPlot.axes([0.13, 0.11, 0.83, 0.74])
ax2.plot(TIMES, get_scaled_lar_by_fiv(0.15, :stem) , ":"; c="#a1752c", lw=2, 
	alpha=0.4, label="Stem-based LAR (FIV ≥ 15%; 75 lineages)")
ax2.plot(TIMES, get_scaled_lar_by_fiv(0.20, :stem), "-"; c="#a1752c", lw=2, 
	alpha=1.0, label="Stem-based LAR (FIV ≥ 20%; 72 lineages)")
ax2.plot(TIMES, get_scaled_lar_by_fiv(0.30, :stem), "--"; c="#a1752c", lw=2, 
	alpha=0.6, label="Stem-based LAR (FIV ≥ 30%; 57 lineages)")
ax2.plot(TIMES, get_scaled_lar_by_fiv(0.15, :crown) , ":"; c="#469825", lw=2, 
	alpha=0.4, label="Crown-based LAR (FIV ≥ 15%; 75 lineages)")
ax2.plot(TIMES, get_scaled_lar_by_fiv(0.20, :crown), "-"; c="#469825", lw=2, 
	alpha=1.0, label="Crown-based LAR (FIV ≥ 20%; 72 lineages)")
ax2.plot(TIMES, get_scaled_lar_by_fiv(0.30, :crown), "--"; c="#469825", lw=2, 
	alpha=0.6, label="Crown-based LAR (FIV ≥ 30%; 57 lineages)")
ax2.set_xlim(OLD, NOW)
ax2.set_ylim(0, 0.04)
ax2.set_xlabel("Time (Ma)")
ax2.set_ylabel("LAR per lineage (Ma\$^{-1}\$)")
ax2.legend(handlelength=2.83)

savefig("lar_fiv.pdf")
