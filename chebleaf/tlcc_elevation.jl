# chebleaf/tlcc_elevation.jl

using BiomeAge
using DelimitedFiles
using GeologicTime
using Printf
using PyPlot

cd(joinpath(pkgdir(BiomeAge), "chebleaf"))

environments = readdlm("environments.tsv", '\t')
times, _, _, elev1, elev2 = collect.(eachcol(environments))
n = only(findall(isapprox.(maximum(times), TIMES)))

lineages = read_lineages_from_tsv("lineages.tsv")
crowns = add_up_age_distributions(lineages, :crown, 1.0)[1:n]
stems = add_up_age_distributions(lineages, :stem, 1.0)[1:n]

function color2hex(colorstring)
	f(str) = tryparse(Int, "0x$str") / 255
	return f(colorstring[2:3]), f(colorstring[4:5]), f(colorstring[6:7])
end

function drawtlcc(ax, ts1, ts2, c2, c1; 
		xlim_=(-20,20), ylim_=(0,1), dts=-200:200, rthres=0.5)
	c1 = color2hex(c1)
	c2 = color2hex(c2)
	x_, y_ = tlcc(ts1, ts2, dts)
	ym, i = findmax(y_)
	if ym > rthres
		ax.plot(x_[i], y_[i], "^k"; ms=6)
		ax.text(0, 0.25, "Max. at \$\\Delta{t}\$ = $(x_[i]) Ma"; 
			ha="center", fontsize=8.5)
		ax.text(0, 0.1, "Corr. coeff. \$r\$ = $(@sprintf("%.3f", y_[i]))"; 
			ha="center", fontsize=8.5)
	else
		ax.text(0, 0.76, "Low correlation"; ha="center", fontsize=8.5)
	end
	ax.plot(x_, y_, "k")
	minimum(y_) < 0 && ax.plot(x_, -y_, "--k")
	ax.set_xlim(xlim_)
	ax.set_ylim(ylim_)
	xx = LinRange(-1, 1, 201)
	yy = LinRange(0, 1, 201)
	cc = Matrix(undef, 201, 201)
	white = (1.0, 1.0, 1.0)
	for (i, x) = enumerate(xx)
		if x <= 0
			cb = -x .* c1 .+ (1+x) .* white
		else
			cb = x .* c2 .+ (1-x) .* white
		end
		cb = (cb .+ white) ./ 2
		gray = sqrt(sum(cb) / 3) .* white
		for (j, y) = enumerate(yy)
			cc[j, i] = cb .* (1-y) .+ gray .* y
		end
	end
	ax.imshow(cc; extent = (xlim_..., ylim_...), zorder=-10, aspect="auto")
	ax.set_yticks(0:0.2:1)
end

function drawline(ax, ts, c, ylim_; alpha=0.05)
	ax.plot(times, ts; c=c)
	ax.set_xlim(60, 0)
	ax.set_ylim(ylim_)
	y0, y1 = ylim_
	for gt = unique(getgeotime.(59.5:-1:0.5, 4))
		start = min(60, getstart(gt))
		stop = getstop(gt)
		color = getcolor(gt)
		ax.fill([start, stop, stop, start], [y0, y0, y1, y1]; 
			c=color, zorder=-10, lw=0, alpha=alpha)
	end
end

W = 6.4
w = 0.28
d = 0.025
x = (1 - 3 * w - 2 * d) / 1.9
dw = 0.0125
H = 5.0
h = 0.255
s = d * W / H
y = (1 - 3 * h - 2 * s) / 2
dh = dw * W / H
crown_color = "#469825"
stem_color = "#a1752c"
elev1_color = "#c92f89"
elev2_color = "#5738b1"

close()
figure(figsize=(W, H))

try ax12.remove() catch ; end
ax12 = PyPlot.axes([x+w+d, y+2h+2s, w, h])
drawline(ax12, crowns, crown_color, (0, 2.7))
ax12.tick_params(left=false, labelleft=false, 
	bottom=false, labelbottom=false, top=true, labeltop=true, right=true)
ax12.tick_params("x", pad=0)
ax12.set_xlabel("Time (Ma)", labelpad=-119)
ax12.text(56, 2.19, "Crown LAR (Ma\$^{-1}\$)"; c=crown_color, ha="left")
ax12.set_yticks(0:0.5:2.5)

try ax13.remove() catch ; end
ax13 = PyPlot.axes([x+2w+2d, y+2h+2s, w, h])
drawline(ax13, stems, stem_color, (0, 2.7))
ax13.tick_params(left=false, labelleft=false, 
	bottom=false, labelbottom=false, top=true, labeltop=true, 
	right=true, labelright=true)
ax13.tick_params("x", pad=0)
ax13.set_xlabel("Time (Ma)", labelpad=-119)
ax13.set_yticks(0:0.5:2.5)
ax13.tick_params("y", pad=2)
ax13.text(56, 2.19, "Stem LAR (Ma\$^{-1}\$)"; c=stem_color, ha="left")

try ax21.remove() catch ; end
ax21 = PyPlot.axes([x+0w+0d, y+h+s, w, h])
drawline(ax21, elev1, elev1_color, (0, 4))
ax21.tick_params(labelbottom=false)
ax21.tick_params("y", pad=2)
ax21.text(18, 1.60, "Elevation"; c=elev1_color, ha="center")
ax21.text(18, 1.00, "of eastern"; c=elev1_color, ha="center")
ax21.text(18, 0.40, "Tibet (km)"; c=elev1_color, ha="center")

try ax22.remove() catch ; end
ax22 = PyPlot.axes([x+w+d+dw, y+h+s, w-dw, h-dh])
drawtlcc(ax22, crowns, elev1, crown_color, elev1_color)
ax22.tick_params(left=false, labelleft=false, labelbottom=false, right=true)

try ax23.remove() catch ; end
ax23 = PyPlot.axes([x+2w+2d+dw, y+1h+s, w-dw, h-dh])
drawtlcc(ax23, stems, elev1, stem_color, elev1_color)
ax23.tick_params(left=false, labelleft=false, 
	labelbottom=false, right=true, labelright=true)
ax23.tick_params("y", pad=2)

try ax31.remove() catch ; end
ax31 = PyPlot.axes([x+0w+0d, y+0h+0s, w, h])
drawline(ax31, elev2, elev2_color, (0, 8))
ax31.tick_params("x", pad=2)
ax31.set_xlabel("Time (Ma)", labelpad=2.5)
ax31.tick_params("y", pad=2)
ax31.text(55.8, 6.45, "Elevation of the"; c=elev2_color, ha="left")
ax31.text(55.8, 5.25, "Himalaya (km)"; c=elev2_color, ha="left")

try ax32.remove() catch ; end
ax32 = PyPlot.axes([x+w+d+dw, y+0h+0s, w-dw, h-dh])
drawtlcc(ax32, crowns, elev2, crown_color, elev2_color)
ax32.tick_params(left=false, labelleft=false, right=true)
ax32.tick_params("x", pad=2)
ax32.set_xlabel("Time lag (Ma)", labelpad=2.5)

try ax33.remove() catch ; end
ax33 = PyPlot.axes([x+2w+2d+dw, y+0h+0s, w-dw, h-dh])
drawtlcc(ax33, stems, elev2, stem_color, elev2_color; rthres=0.8)
ax33.tick_params(left=false, labelleft=false, right=true, labelright=true)
ax33.tick_params("x", pad=2)
ax33.set_xlabel("Time lag (Ma)", labelpad=2.5)
ax33.tick_params("y", pad=2)

savefig("tlcc_elevation.pdf")
