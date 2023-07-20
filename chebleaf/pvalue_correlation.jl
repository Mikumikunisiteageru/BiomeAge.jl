# chebleaf/pvalue_correlation.jl

using BiomeAge
using HypothesisTests
using PyPlot

cd(joinpath(pkgdir(BiomeAge), "chebleaf"))

y1(t) = sqrt(pi) \ sin(t)
y2(t) = sqrt(pi) \ sin(t + pi/4)
gtt(n) = LinRange(0, 2*pi, n+1)[1:n] .+ pi/n
function rp(n)
	tt = gtt(n)
	test = CorrelationTest(y1.(tt), y2.(tt))
	return test.r, pvalue(test)
end
r(n) = first(rp(n))
p(n) = last(rp(n))

red = "#cc5438"
blue = "#1374d7"
purple = "#9e5fa2"

xx = LinRange(0, 2*pi, 101)
tt = gtt(10)
nn = 4:26
xlim_ = (4.3, 25.7)

close()
figure(figsize=(6.4, 4.8))

try ax11.remove() catch ; end
ax11 = PyPlot.axes([0.11, 0.58, 0.47, 0.38])
ax11.plot(xx, y1.(xx), "-"; c=red, label="\$f_1\$")
ax11.plot(xx, y2.(xx), "-"; c=blue, label="\$f_2\$")
ax11.plot(tt, y1.(tt), "o"; c=red)
ax11.plot(tt, y2.(tt), "o"; c=blue)
ax11.set_xlim(0, 2*pi)
ax11.set_xticks((0:4) .* pi/2, ["\$0\$", "\$\\pi/2\$", "\$\\pi\$", "\$3\\pi/2\$", "\$2\\pi\$"])
ax11.set_ylim(-0.64, 0.64)
ax11.set_xlabel("\$t\$", labelpad=3)
ax11.set_ylabel("\$f_\\cdot(t)\$", labelpad=-4)
ax11.text(4.3, 0.25, "\$n = 10\$"; ha="center", va="center")
ax11.legend(handletextpad=0.4)

try ax12.remove() catch ; end
ax12 = PyPlot.axes([0.7, 0.58, 0.27, 0.38])
ax12.plot(y1.(xx), y2.(xx), "-"; c=purple)
ax12.plot(y1.(tt), y2.(tt), "o"; c=purple)
ax12.set_xlim(-0.64, 0.64)
ax12.set_ylim(-0.64, 0.64)
ax12.spines["top"].set_color(red)
ax12.spines["bottom"].set_color(red)
ax12.tick_params(axis="x", colors=red)
ax12.spines["left"].set_color(blue)
ax12.spines["right"].set_color(blue)
ax12.tick_params(axis="y", colors=blue)
ax12.set_xlabel("\$f_1(t)\$", color=red, labelpad=3)
ax12.set_ylabel("\$f_2(t)\$", color=blue, labelpad=-4)
ax12.text(0, 0, "\$n = 10\$"; ha="center", va="center")

try ax21.remove() catch ; end
ax21 = PyPlot.axes([0.11, 0.09, 0.37, 0.38])
rr = r.(nn)
ax21.plot(nn, rr, "-"; c="k")
ax21.plot(10, r(10), "s"; c="k")
ax21.set_yticks([0.68, 0.70, 1/sqrt(2), 0.72, 0.74], 
	["0.68", "0.70", "\$2^{-1/2}\$", "0.72", "0.74"])
ax21.set_xlim(xlim_)
ax21.set_xlabel("\$n\$", labelpad=2)
ax21.set_ylabel("\$r\$", labelpad=2)
ax21.text(15, 0.7336303796891992, "Correlation coefficient"; ha="center", va="center")

try ax22.remove() catch ; end
ax22 = PyPlot.axes([0.6, 0.09, 0.37, 0.38])
pp = p.(nn)
ax22.plot(nn, log10.(pp), "-"; c="k")
ax22.plot(10, log10(p(10)), "s"; c="k")
ax22.plot(xlim_, fill(log10(0.05), 2), "--k"; zorder=-1, lw=0.8)
ax22.plot(xlim_, fill(log10(0.01), 2), "--k"; zorder=-1, lw=0.8)
ax22.plot(xlim_, fill(log10(0.001), 2), "--k"; zorder=-1, lw=0.8)
ax22.set_yticks(log10.([0.05, 0.01, 0.001]), ["0.050", "0.010", "0.001"])
ax22.set_xlim(xlim_)
ax22.set_xlabel("\$n\$", labelpad=2)
ax22.set_ylabel("\$p\$", labelpad=2)
ax22.text(16.3, -1, "Correlation test's \$p\$-value"; ha="center", va="center")

savefig("pvalue_correlation.pdf")
