# test/ChEBLeaF.jl

using BiomeAge
using Test

cd(joinpath(pkgdir(BiomeAge), "test"))

lineages = read_lineages_from_tsv("ChEBLeaF_db.tsv")

crown_ages = get_age_distributions(lineages, :crown, 1.0)
stem_ages = get_age_distributions(lineages, :stem, 1.0)
