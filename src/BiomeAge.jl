# src/BiomeAge.jl

module BiomeAge

using Changepoints
using DelimitedFiles
using Entropics
using XLSX

export NOW, OLD, SEP, TIMES

export read_lineages_from_tsv, read_lineages_from_xlsx
export get_age_distribution, add_up_age_distributions
export get_change_points

const NOW = 0
const OLD = 120
const SEP = 0.1
const TIMES = NOW : SEP : OLD

struct Lineage
	row::Int
	name::String
	stem::Entropics.MaxEnDist
	crown::Entropics.MaxEnDist
end

num_or_nothing(x) = isa(x, Number) ? x : nothing

function med_wmusab(wmusab; w_as=:median)
	any(isa.(wmusab, Number)) || error("No information!")
	w, m, u, s, a, b = num_or_nothing.(wmusab)
	w_as == :median ? isnothing(m) && (m = w) : 
	w_as == :mean   ? isnothing(u) && (u = w) : error("Illegal `w_as` value!")
	isa(a, Number) || (a = NOW)
	isa(b, Number) || (b = OLD)
	a == b && (a -= SEP; b += SEP)
	return maxendist(a, b; median=m, mean=u, std=s)
end

function read_lineages_from_table(table, rows, name_col, stem_cols, crown_cols)
	lineages = Lineage[]
	for row = rows
		name = table[row, name_col]
		stem = med_wmusab(table[row, stem_cols])
		crown = med_wmusab(table[row, crown_cols])
		push!(lineages, Lineage(row, name, stem, crown))
	end
	return lineages
end

function read_lineages_from_tsv(filename; 
		name_col=1, stem_cols=2:7, crown_cols=8:13)
	table, _ = readdlm(filename, '\t', header=true)
	return read_lineages_from_table(table, 
		1 : size(table, 1), name_col, stem_cols, crown_cols)
end

read_lineages_from_xlsx(filename, sheet="Sheet1", 
	rows=2:68, name_col=1, stem_cols=3:8, crown_cols=9:14) = 
		read_lineages_from_table(XLSX.readxlsx(filename)[sheet][:], 
			rows, name_col, stem_cols, crown_cols)

function get_age_distribution(lineage, group=:crown, h=1.0)
	@assert group in [:crown, :stem]
	return pdf(smooth(getproperty(lineage, group), h)).(TIMES)
end

add_up_age_distributions(lineages, group=:crown, h=1.0) = 
	sum(get_age_distribution.(lineages, group, h))

function get_change_points(ages; method=:PELT, sigma=1.5)
	@assert method in [:PELT, :BS]
	if method == :PELT
		cost_function = NormalMeanSegment(ages, sigma)
		xps, _ = PELT(cost_function, length(ages))
	elseif method == :BS
		xps, _ = BS(cost_function, length(ages))
	end
	return TIMES[xps[2:end]] .+ SEP/2
end

end # module BiomeAge
