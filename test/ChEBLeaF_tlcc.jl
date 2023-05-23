# test/ChEBLeaF_tlcc.jl

using BiomeAge
using DelimitedFiles
using PyPlot

cd(joinpath(pkgdir(BiomeAge), "test"))

paleoenv = readdlm("paleoenv.tsv", '\t')
times, temps, precs, elevs, elevs2 = collect.(eachcol(paleoenv))
n = only(findall(isapprox.(maximum(times), TIMES)))

lineages = read_lineages_from_tsv("ChEBLeaF_db.tsv")
crowns = add_up_age_distributions(lineages, :crown, 1.0)[1:n]
stems = add_up_age_distributions(lineages, :stem, 1.0)[1:n]

k = 0
for ts1 = [temps, precs, elevs, elevs2]
	for ts2 = [crowns, stems]
		global k += 1
		x, y = tlcc(ts1, ts2, -200:200)
		subplot(4, 2, k)
		plot(x, y)
	end
end

# using Distributions
# using HypothesisTests
# function test(ts1, ts2)
# 	corrtest = CorrelationTest(ts1, ts2)
# 	p1 = pvalue(corrtest)
# 	r = cor(ts1, ts2)
# 	t = r * sqrt((599) / (1-r^2))
# 	T = TDist(599)
# 	p2 = min(cdf(T, t), ccdf(T, t)) * 2
# 	return isapprox(p1, p2), p1, p2
# end
# test(temps, crowns)
# test(temps, stems)
