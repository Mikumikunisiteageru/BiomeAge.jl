# chebleaf/datatext.jl

using BiomeAge

cd(joinpath(pkgdir(BiomeAge), "chebleaf"))

lineages = read_lineages_from_tsv("lineages.tsv")
sort!(lineages, by = lineage -> mean(lineage.crown))
crowns = add_up_age_distributions(lineages, :crown, 1.0)
stems = add_up_age_distributions(lineages, :stem, 1.0)

get_change_points(crowns)
get_change_points(stems)
get_extremum_points(crowns)
get_extremum_points(stems)
