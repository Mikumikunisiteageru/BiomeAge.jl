# chebleaf/workflow.jl

using BiomeAge
using Entropics
using JLD2
using PyPlot

cd(joinpath(pkgdir(BiomeAge), "chebleaf"))

ep = 1e-3
ms, msi = 14, 6
x0 = -7
k = (0.8, 0.8, 0.8)
c0, c1, c2, c3, c4 = "C0", "C1", "C2", "C3", "C4"

xg = 83.0

prev(x) = x - ep
next(x) = x + ep

function cdr((x1, y1), x, (x2, y2), c="k"; ax=gca(), lw=2, kwargs...)
	if c isa AbstractVector
		@assert length(c) == 3
		if c[1] == c[2]
			ax.plot([x1, x, x, next(x)], [y1, y1, y2, y2], "-"; c=c[1], lw=lw, zorder=x, kwargs...)
			ax.plot([x, x, x2], [next(y2), y2, y2], "-"; c=c[3], lw=lw, zorder=x-1, kwargs...)
		elseif c[2] == c[3]
			ax.plot([x1, x, x], [y1, y1, prev(y1)], "-"; c=c[1], lw=lw, zorder=x-1, kwargs...)
			ax.plot([next(x), x, x, x2], [y1, y1, y2, y2], "-"; c=c[3], lw=lw, zorder=x, kwargs...)
		else
			ax.plot([x1, x, x], [y1, y1, prev(y1)], "-"; c=c[1], lw=lw, zorder=x-1, kwargs...)
			ax.plot([next(x), x, x, next(x)], [y1, y1, y2, y2], "-"; c=c[2], lw=lw, zorder=x, kwargs...)
			ax.plot([x, x, x2], [next(y2), y2, y2], "-"; c=c[3], lw=lw, zorder=x-1, kwargs...)
		end
	else
		ax.plot([x1, x, x, x2], [y1, y1, y2, y2], "-"; c=c, lw=lw, zorder=x, kwargs...)
	end
	return x, (y1+y2)/2
end

solidpt(x, y, c; ax=gca()) = ax.plot(x, y, "."; c=c, ms=ms, zorder=1)

function emptypt(x, y, c; ax=gca())
	solidpt(x, y, c; ax=ax)
	ax.plot(x, y, "."; c="w", ms=msi, zorder=2)
end

pts(x0, x1, y, c) = (emptypt(x0, y, c); solidpt(x1, y, c))
function pts(xs, xc, ys, yc, c; ax=gca(), lw=1.2)
	emptypt(xs, ys, c; ax=ax) 
	solidpt(xc, yc, c; ax=ax)
	ax.plot([xc, xs, xs], [yc, yc, ys], ":"; lw=lw, c=c, zorder=1.5)
end

function pa(yy, ss, c; ax=gca(), x=-3, dx=2, dy=0.35, ms=8)
	for (y, s) = zip(yy, ss)
		fx = x .+ [+ep, -dx, -dx, dx, dx, -ep]
		fy = y .+ [dy, dy, -dy, -dy, dy, dy]
		ax.fill(fx, fy; ec="none", fc = s == 1 ? c : "none")
		ax.fill(fx, fy; ec=c, fc = s == 1 ? c : "none")
	end
end

function pag(yy, s, c; ax=gca(), x=3, dx=2, dy=0.35, ms=8)
	y1, y2 = extrema(yy)
	fx = x .+ [+ep, -dx, -dx, dx, dx, -ep]
	fy = [y2+dy, y2+dy, y1-dy, y1-dy, y2+dy, y2+dy]
	ax.fill(fx, fy; ec=c, fc = s == 1 ? c : "none")
	ax.fill(fx, fy; ec=c, fc = s == 1 ? c : "none")
end

function pab(yy, ss, s, c; ax=gca(), xs=-3, xg=3, dx=2, dy=0.35)
	pa(yy, ss, c; ax=ax, x=xs, dx=dx, dy=dy)
	pag(yy, s, c; ax=ax, x=xg, dx=dx, dy=dy)
end

d10, d8, d27 = smooth.(collect.(eachcol(Float64.(load_object("samples.jld2")))))

function getinterval(d)
	q = Entropics.quantile
	f(a) = Entropics.pdf(d)(q(d, a + 0.95)) - Entropics.pdf(d)(q(d, a))
	a = Entropics.binaryroot(f, 0.001, 0.049)
	q(d, a), q(d, a + 0.95)
end

function draw(d, y, c="C0"; ax=gca(), l=0.045)
	pdf = Entropics.pdf
	xx = 0:0.1:43
	yy = pdf(d).(xx)
	ax.fill_between(-xx, y .- yy, y .+ yy; color=c, lw=0, alpha=0.5)
	ax.plot(-xx, y .- yy; c=c)
	ax.plot(-xx, y .+ yy; c=c)
	a, b = getinterval(d)
	ax.plot(-[a, a], y .+ [-l, l], "-"; c=c)
	ax.plot(-[b, b], y .+ [-l, l], "-"; c=c)
	mu = Entropics.mean(d)
	ax.plot(-mu, y, "."; c=c, ms=ms, zorder=1)
	a, b, Entropics.median(d), mu, Entropics.var(d), pdf(d)(a)
end

function drawmed(pp, y, c="C0"; ax=gca(), smoother=1.3, l=0.045)
	smed = smooth(maxendist(pp[1], pp[2]; 
		median=pp[3], mean=pp[4], var=pp[5]), smoother)
	xx = 0:0.1:43
	yy = Entropics.pdf(smed).(xx)
	ax.fill_between(-xx, y .- yy, y .+ yy; color=c, lw=0, alpha=0.5)
	ax.plot(-xx, y .- yy; c=c)
	ax.plot(-xx, y .+ yy; c=c)
	ax.plot(-[pp[1], pp[1]], y .+ [-l, l], "-"; c=c)
	ax.plot(-[pp[2], pp[2]], y .+ [-l, l], "-"; c=c)
	ax.plot(-pp[4], y, "."; c=c, ms=ms, zorder=1)
	smed
end

function show101(j, c, r; ax=gca(), dx=0.026, ox=-0.001, oy=0.0025)
	x = 0.72 - r * (0.72-0.577)
	y = (1 - j / 4) * 0.38 + j / 4 * 0.13 - 0.01
	ax.plot(-0.015 .+ [0.577, x-dx, NaN, x+dx, 0.72], fill(y, 5), "-"; c=c)
	ax.text(-0.015 .+ x+ox, y, "101"; c=c, ha="center", va="center", size="small")
	ax.text(-0.015 .+ 0.587, y+oy, string(j), ha="center", va="bottom", size="small")
end

close()
figure(figsize=(6.4, 3.74))

try ax1.remove() catch ; end
ax1 = PyPlot.axes([0.003, 0, 0.36, 1])
cdr(cdr(cdr(cdr((x0, -1), -12, (x0, -2), c0), -17, (x0, -3), c0), -35, 
		cdr(cdr(cdr((x0, -4), -11, (x0, -5), c1), -23, 
				cdr((x0, -6), -15, (x0, -7), c2), [c1, k, c2]), -30, 
			(x0, -8), [k, k, c3]), [c0, k, k]), -46, 
	cdr(cdr(cdr((x0, -9), -25, (x0, -10), c4), -33, (x0, -11), c4), -40, 
		cdr(cdr((x0, -12), -15, (x0, -13), c4), -28, (x0, -14), c4), c4), [k, k, c4])
ax1.plot([-50, -46], [-8.125, -8.125], "-"; c=k)
pts(-35, -17, -4.5, -2.25, c0; ax=ax1)
pts(-23, -15, -5.5, -6.5, c2; ax=ax1)
pts(-40, -33, -11.75, -10.25, c4; ax=ax1)
pab(-1:-1:-3, [1, 0, 1], 1, c0; ax=ax1)
pab(-4:-1:-5, [0, 0], 0, c1; ax=ax1)
pab(-6:-1:-7, [1, 1], 1, c2; ax=ax1)
pab(-8:-1:-8, [0], 0, c3; ax=ax1)
pab(-9:-1:-14, [1, 1, 1, 0, 0, 0], 1, c4; ax=ax1)
ax1.plot([-3, -3, -10], [-14.65, -15.5, -15.5], "-k", lw=1)
ax1.plot([3, 3, -10], [-14.65, -16.5, -16.5], "-k", lw=1)
ax1.text(-11, -15.5, "Local species", va="center", ha="right", fontsize=9)
ax1.text(-11, -16.5, "Characteristic genera", va="center", ha="right", fontsize=9)
ax1.text(-26, -2.2, "1", ha="center", va="bottom", size="small")
ax1.text(-19, -6.45, "2", ha="center", va="bottom", size="small")
ax1.text(-36.5, -10.2, "3", ha="center", va="bottom", size="small")
ax1.set_xlim(-24 .+ 0.36 .* (-xg, xg))
ax1.set_ylim((-17.2925, 0.1425))
ax1.axis("off")

try ax2.remove() catch ; end
ax2 = PyPlot.axes([0.363, 0.5, 0.317, 0.5])
p10 = draw(d10, 0, c0; ax=ax2)
p8 = draw(d8, -0.3, c2; ax=ax2)
p27 = draw(d27, -0.6, c4; ax=ax2)
ax2.set_xlim(-21.5-0.317*xg, -21.5+0.317*xg)
ax2.set_ylim(-0.9, 0.44)
ax2.text(-21.5, 0.27, "Unreported distributions", ha="center", va="center", fontsize=9)
ax2.text(-41, 0.015, "1", ha="center", va="bottom", size="small")
ax2.text(-41, 0.015-0.3, "2", ha="center", va="bottom", size="small")
ax2.text(-41, 0.015-0.6, "3", ha="center", va="bottom", size="small")
ax2.axis("off")

try ax3.remove() catch ; end
ax3 = PyPlot.axes([0.68, 0.5, 0.317, 0.5])
s10 = drawmed(p10, 0, c0; ax=ax3)
s8 = drawmed(p8, -0.3, c2; ax=ax3)
s27 = drawmed(p27, -0.6, c4; ax=ax3)
ax3.set_xlim(-21.5-0.317*xg, -21.5+0.317*xg)
ax3.set_ylim(-0.9, 0.44)
ax3.text(-21.5, 0.27, "Recovered distributions", ha="center", va="center", fontsize=9)
ax3.text(-41, 0.015, "1", ha="center", va="bottom", size="small")
ax3.text(-41, 0.015-0.3, "2", ha="center", va="bottom", size="small")
ax3.text(-41, 0.015-0.6, "3", ha="center", va="bottom", size="small")
ax3.axis("off")

try ax4.remove() catch ; end
ax4 = PyPlot.axes([0.68, 0.0, 0.317, 0.5])
p(x) = pdf(d10)(x) + pdf(d8)(x) + pdf(d27)(x)
x = 0:0.1:43
ax4.fill_between(-x, pdf(d27).(x) + pdf(d8).(x), p.(x); color=c0, lw=0, alpha=0.5)
ax4.fill_between(-x, pdf(d27).(x), pdf(d27).(x) + pdf(d8).(x); color=c2, lw=0, alpha=0.5)
ax4.fill_between(-x, zero(x), pdf(d27).(x); color=c4, lw=0, alpha=0.5)
ax4.plot(-x, p.(x), "-k")
ax4.plot(-x, pdf(d27).(x), "--k", lw=0.5)
ax4.plot(-x, pdf(d27).(x) + pdf(d8).(x), "--k", lw=0.5)
ax4.plot(-x, zero(x), "-k")
ax4.text(-8.1, 0.161, "1", ha="center", va="center", size="small")
ax4.text(-7.8, 0.032, "2", ha="center", va="center", size="small")
ax4.text(-27, 0.030, "3", ha="center", va="center", size="small")
ax4.set_xlim(-21.5-0.317*xg, -21.5+0.317*xg)
ax4.set_ylim(-0.06, 0.25)
ax4.axis("off")

try ax0.remove() catch ; end
ax0 = PyPlot.axes([0, 0, 1, 1])
ax0.set_facecolor("none")
ax0.set_xlim([0, 1])
ax0.set_ylim([0, 1])
emptypt(0.02+0.39, 0.508, (0.4,0.4,0.4); ax=ax0)
ax0.text(0.02+0.415, 0.504, "Stem node", ha="left", va="center", fontsize=9)
solidpt(0.02+0.39, 0.448, (0.4,0.4,0.4); ax=ax0)
ax0.text(0.02+0.415, 0.444, "Crown node", ha="left", va="center", fontsize=9)
ax0.text(0.873, 0.49, "Crown-based", ha="right", va="center", fontsize=9)
ax0.text(0.873, 0.49-1*0.04, "LAR (lineage", ha="right", va="center", fontsize=9)
ax0.text(0.873, 0.49-2*0.04, "accumulation", ha="right", va="center", fontsize=9)
ax0.text(0.873, 0.49-3*0.04, "rate) curve", ha="right", va="center", fontsize=9)
epp = 0.005
eppx = 0.003
ax0.plot([0.5+eppx, 0+eppx, 0+eppx, 1-eppx, 1-eppx, 0.5-epp], [1-epp, 1-epp, 0+epp, 0+epp, 1-epp, 1-epp], "-k", lw=1.2)
ax0.plot([0.68, 0.68, NaN, 0.68, 0.68], [0+epp, 0.13, NaN, 0.38, 1-epp], "--k", lw=1.2)
ax0.text(0.52, 0.049, "FROM THE LITERATURE", ha="center", va="center")
ax0.text(0.84-eppx/2, 0.049, "TO THIS META-ANALYSIS", ha="center", va="center")
ax0.plot(-0.015 .+ [0.681, 0.407, 0.407, 0.735, 0.78, 0.735, 0.679], [0.38, 0.38, 0.13, 0.13, 0.255, 0.38, 0.38], "-k", lw=0.8)
ax0.text(-0.015 .+ 0.49, 0.264, "Reported", ha="center", va="bottom", fontsize=9)
ax0.text(-0.015 .+ 0.49, 0.246, "statistics", ha="center", va="top", fontsize=9)
show101(1, c0, 14/43; ax=ax0)
show101(2, c2, 10/43; ax=ax0)
show101(3, c4, 27/43; ax=ax0)
ax0.axis("off")
ax0.text(0.07, 0.886, "(a)", ha="center", va="center")
ax0.text(0.49, 0.886, "(b)", ha="center", va="center")
ax0.text(0.49 + 0.317, 0.886, "(c)", ha="center", va="center")
ax0.text(0.836, 0.278, "(d)", ha="center", va="center")

savefig("workflow.pdf")
