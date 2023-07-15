# ifmedunif.jl
# 20230715

using BiomeAge
using DelimitedFiles
using Entropics
using PyPlot

cd(joinpath(pkgdir(BiomeAge), "test"))

lineages = read_lineages_from_tsv("ChEBLeaF_db.tsv")
crowns = add_up_age_distributions(lineages, :crown, 1.0)
stems = add_up_age_distributions(lineages, :stem, 1.0)

function read_lineages_from_tsv_uniform(filename; 
		name_col=1, stem_cols=2:7, crown_cols=8:13)
	table, _ = readdlm(filename, '\t', header=true)
	for (wj, mj, uj, sj, aj, bj) = [stem_cols, crown_cols]
		for i = axes(table, 1)
			if ! isa(table[i, aj], Number) || ! isa(table[i, bj], Number)
				@assert isa(table[i, uj], Number) && isa(table[i, sj], Number)
				table[i, aj] = max(table[i, uj] - table[i, sj] * 2, NOW)
				table[i, bj] = min(table[i, uj] + table[i, sj] * 2, OLD)
			end
			table[i, [wj, mj, uj, sj]] .= ""
		end
	end
	return BiomeAge.read_lineages_from_table(table, 
		axes(table, 1), name_col, stem_cols, crown_cols)
end
lineages_uniform = read_lineages_from_tsv_uniform("ChEBLeaF_db.tsv")
crowns_uniform = add_up_age_distributions(lineages_uniform, :crown, 1.0)
stems_uniform = add_up_age_distributions(lineages_uniform, :stem, 1.0)

figure(figsize=(6.4, 4.8))
plot(TIMES, crowns, "#469825"; label="Crown-based LAR (maximum entropy)", zorder=2)
plot(TIMES, crowns_uniform, "#66CCFF"; lw=2.5, label="Crown-based LAR (uniform)", zorder=1)
plot(TIMES, stems, "--"; c="#a1752c", label="Stem-based LAR (maximum entropy)", zorder=2)
plot(TIMES, stems_uniform, "--"; c="#FFCC66", lw=2.5, label="Stem-based LAR (uniform)", zorder=1)
xlim(OLD, NOW)
ylim(0, 3)
xlabel("Time (Ma)")
ylabel("Lineage accumulation rate (Ma\$^{-1}\$)")
legend()
savefig("ifmedunif.pdf")
