# test/ChEBLeaF.jl

using BiomeAge
using Test

lineages = read_lineages_from_tsv("ChEBLeaF_db.tsv")

crowns = add_up_age_distributions(lineages, :crown, 1.0)
stems = add_up_age_distributions(lineages, :stem, 1.0)
