# src/BiomeAge.jl

module BiomeAge

using Entropics
using XLSX

export read_lineages_from_xlsx
export add_up_age_distributions
export TIMES

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

function read_lineages_from_xlsx(file, sheet, 
		rows, name_col, stem_cols, crown_cols)
	table = XLSX.readxlsx(file)[sheet][:]
	lineages = Lineage[]
	for row = rows
		name = table[row, name_col]
		stem = med_wmusab(table[row, stem_cols])
		crown = med_wmusab(table[row, crown_cols])
		push!(lineages, Lineage(row, name, stem, crown))
		println(row, ' ', name)
	end
	return lineages
end

function add_up_age_distributions(lineages, group, h)
	@assert group in [:crown, :stem]
	pdfs = Vector[]
	for lineage = lineages
		push!(pdfs, pdf(smooth(getproperty(lineage, group), h)).(TIMES))
	end
	return sum(pdfs)
end	

end # module BiomeAge
