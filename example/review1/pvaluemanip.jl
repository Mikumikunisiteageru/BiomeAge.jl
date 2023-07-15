# pvaluemanip.jl
# 20230715

using HypothesisTests

y1(t) = sin(t)
y2(t) = sin(t + pi/4)
function rp(n)
	tt = LinRange(0, 2*pi, n)
	test = CorrelationTest(y1.(tt), y2.(tt))
	return test.r, pvalue(test)
end
r(n) = first(rp(n))
p(n) = last(rp(n))

using PyPlot

nn = 4:26
xlim_ = (4.3, 25.7)

figure(figsize=(6.4, 4.8))

subplot(211)
rr = r.(nn)
plot(nn, rr, ".-C0"; ms=10)
plot(xlim_, fill(1/sqrt(2), 2), "--k"; zorder=-1, lw=0.8)
yticks([0.63, 0.64, 0.65, 0.66, 0.67, 0.68, 0.69, 0.70, 1/sqrt(2)], 
	["0.63", "0.64", "0.65", "0.66", "0.67", "0.68", "0.69", "0.70", "\$2^{-1/2}\$"])
xticks(nn)
xlim(xlim_)
ylabel("\$r\$")

subplot(212)
pp = p.(nn)
plot(nn, log10.(pp), ".-C0"; ms=10)
plot(xlim_, fill(log10(0.05), 2), "--k"; zorder=-1, lw=0.8)
plot(xlim_, fill(log10(0.01), 2), "--k"; zorder=-1, lw=0.8)
plot(xlim_, fill(log10(0.001), 2), "--k"; zorder=-1, lw=0.8)
xticks(nn)
yticks(log10.([0.05, 0.01, 0.001]), ["0.050", "0.010", "0.001"])
xlim(xlim_)
xlabel("\$n\$, number of sampling points on \$[0, 2\\pi]\$")
ylabel("\$p\$")

savefig("pvaluemanip.pdf")
