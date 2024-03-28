# src/BiomeAge.jl

module BiomeAge

using Changepoints
using DelimitedFiles
using Entropics
using Statistics
using XLSX

export get_now, get_old, get_sep, get_times
# export set_now, set_old, set_sep

export read_lineages_from_tsv, read_lineages_from_xlsx
export get_age_distribution, add_up_age_distributions
export get_change_points
export tlcc
export get_extremum_points

NOW::Float64 = 0
get_now() = NOW
set_now(now) = (global NOW = now)

OLD::Float64 = 120
get_old() = OLD
set_old(old) = (global OLD = old)

SEP::Float64 = 0.1
get_sep() = SEP
set_sep(sep) = (global SEP = sep)

get_times() = get_now() : get_sep() : get_old()
get_times(id) = get_times()[id]

struct Lineage
	row::Int
	name::String
	stem::Entropics.MaxEnDist
	crown::Entropics.MaxEnDist
end

num_or_nothing(x) = isa(x, Number) ? x : nothing

function med_wmuab(wmuab; w_as=:median)
	any(isa.(wmuab, Number)) || error("No information!")
	w, m, u, a, b = num_or_nothing.(wmuab)
	w_as == :median ? isnothing(m) && (m = w) : 
	w_as == :mean   ? isnothing(u) && (u = w) : error("Illegal `w_as` value!")
	isa(a, Number) || (a = get_now())
	isa(b, Number) || (b = get_old())
	a == b && (a -= get_sep(); b += get_sep())
	return maxendist(a, b; median=m, mean=u)
end

function read_lineages_from_table(table, rows, name_col, stem_cols, crown_cols)
	lineages = Lineage[]
	for row = rows
		name = table[row, name_col]
		stem = med_wmuab(table[row, stem_cols])
		crown = med_wmuab(table[row, crown_cols])
		push!(lineages, Lineage(row, name, stem, crown))
	end
	return lineages
end

function read_lineages_from_tsv(filename; 
		name_col=1, stem_cols=2:6, crown_cols=7:11)
	table, _ = readdlm(filename, '\t', header=true)
	return read_lineages_from_table(table, 
		1 : size(table, 1), name_col, stem_cols, crown_cols)
end

read_lineages_from_xlsx(filename; sheet="Sheet1", 
	rows=2:73, name_col=1, stem_cols=3:7, crown_cols=8:12) = 
		read_lineages_from_table(XLSX.readxlsx(filename)[sheet][:], 
			rows, name_col, stem_cols, crown_cols)

function get_age_distribution(lineage, group=:crown, h=1.0)
	@assert group in [:crown, :stem]
	return pdf(smooth(getproperty(lineage, group), h)).(get_times())
end

add_up_age_distributions(lineages, group=:crown, h=1.0) = 
	sum(get_age_distribution.(lineages, group, h))

function get_change_points(ages; method=:PELT, sigma=1.5)
	@assert method in [:PELT, :BS]
	cost_function = NormalMeanSegment(ages, sigma)
	if method == :PELT
		xps, _ = PELT(cost_function, length(ages))
	elseif method == :BS
		xps, _ = BS(cost_function, length(ages))
	end
	return get_times(xps[2:end]) .+ get_sep()/2
end

function tlcc(ts1, ts2, shifts=-100:100)
	p(s) = max(s, 0) # positive part
	n(s) = min(s, 0) # negative part
	@assert (l = length(ts1)) == length(ts2)
	timelags = shifts .* get_sep()
	pearsons = [cor(ts1[1+p(s):l+n(s)], ts2[1-n(s):l-p(s)]) for s = shifts]
	return timelags, pearsons
end

function get_extremum_points(ts; rtol=0.0)
	extremum_points = Tuple{Float64, Float64, Char}[]
	for i = reverse(eachindex(get_times()))[begin+1:end-1]
		ts[i-1] < ts[i] * (1-rtol) && ts[i] * (1+rtol) > ts[i+1] && 
			push!(extremum_points, (get_times(i), ts[i], '^'))
		ts[i-1] > ts[i] * (1+rtol) && ts[i] * (1-rtol) < ts[i+1] && 
			push!(extremum_points, (get_times(i), ts[i], 'v'))
	end
	return extremum_points
end

end # module BiomeAge
