# chebleaf/lar_uniform.jl

using BiomeAge
using DelimitedFiles
using Entropics
using GeologicTime
using PyPlot

cd(joinpath(pkgdir(BiomeAge), "chebleaf"))

lineages = read_lineages_from_tsv("lineages.tsv")
crowns = add_up_age_distributions(lineages, :crown, 1.0)
stems = add_up_age_distributions(lineages, :stem, 1.0)

function read_lineages_from_tsv_uniform(filename; 
		name_col=1, stem_cols=2:6, crown_cols=7:11)
	table, _ = readdlm(filename, '\t', header=true)
	for (wj, mj, uj, aj, bj) = [stem_cols, crown_cols]
		for i = axes(table, 1)
			@assert isa(table[i, aj], Number) && isa(table[i, bj], Number)
			table[i, [wj, mj, uj]] .= ""
		end
	end
	return BiomeAge.read_lineages_from_table(table, 
		axes(table, 1), name_col, stem_cols, crown_cols)
end
lineages_uniform = read_lineages_from_tsv_uniform("lineages.tsv")
crowns_uniform = add_up_age_distributions(lineages_uniform, :crown, 1.0)
stems_uniform = add_up_age_distributions(lineages_uniform, :stem, 1.0)

close()
figure(figsize=(6.4, 4.8))

try ax1.remove() catch ; end
ax1 = PyPlot.axes([0.11, 0.865, 0.85, 0.1])
drawtimescale(ax1, 100, 0, [3, 4]; fontsize=9, texts = Dict(
	"Cretaceous" => "Cretaceous", "Paleogene" => "Paleogene", 
	"Neogene" => "Neogene", "Quaternary" => "Q", 
	"Late Cretaceous" => "Late Cretaceous", "Paleocene" => "Paleoc.", 
	"Eocene" => "Eocene", "Oligocene" => "Oligoc.", "Miocene" => "Miocene", 
	"Pliocene" => "P", "Pleistocene" => "P"))

try ax2.remove() catch ; end
ax2 = PyPlot.axes([0.11, 0.11, 0.85, 0.74])
ax2.plot(TIMES, stems, "--"; c="#a1752c", label="Stem-based LAR (maximum entropy)", zorder=2)
ax2.plot(TIMES, stems_uniform, "--"; c="#FFCC66", lw=2.5, label="Stem-based LAR (uniform)", zorder=1)
ax2.plot(TIMES, crowns, "#469825"; label="Crown-based LAR (maximum entropy)", zorder=2)
ax2.plot(TIMES, crowns_uniform, "#66CCFF"; lw=2.5, label="Crown-based LAR (uniform)", zorder=1)
ax2.set_xlim(OLD, NOW)
ax2.set_ylim(0, 3)
ax2.set_xlabel("Time (Ma)")
ax2.set_ylabel("Lineage accumulation rate (Ma\$^{-1}\$)")
ax2.legend()

savefig("lar_uniform.pdf")
