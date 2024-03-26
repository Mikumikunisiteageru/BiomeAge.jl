# BiomeAge.jl

BiomeAge.jl is the accessory software package of an article published on New Phytologist ([Zhang et al., 2024, 10.1111/nph.19524](https://nph.onlinelibrary.wiley.com/doi/10.1111/nph.19524)) analyzing the history of East Asian evergreen broad-leaved forests (EAEBLF). It creates the Figures [2](https://github.com/Mikumikunisiteageru/BiomeAge.jl/blob/master/chebleaf/workflow.jl), [3](https://github.com/Mikumikunisiteageru/BiomeAge.jl/blob/master/chebleaf/galileo.jl), and [4](https://github.com/Mikumikunisiteageru/BiomeAge.jl/blob/master/chebleaf/tlcc.jl) in the article from [divergence time data](https://github.com/Mikumikunisiteageru/BiomeAge.jl/blob/master/chebleaf/lineages.tsv).

## Installation and usage

This package runs on Julia. It requires an unregistered package Entropics.jl, which can be installed by
```julia
]add https://github.com/Mikumikunisiteageru/Entropics.jl
```
Then, this package BiomeAge.jl can be installed likewise by
```julia
]add https://github.com/Mikumikunisiteageru/BiomeAge.jl
```
At this point, the core functions --- those applicable in similar analysis on other biomes --- should be ready.

To redraw the figures specifically designed for the EAEBLF biome, some additional package should be also installed using
```julia
]add DelimitedFiles, GeologicTime, JLD2, Printf, PyPlot
```
Run the scripts except the `savefig` lines at the end, and the figures in the article can be exactly reproduced.

## Citation

To cite the article or this package, please use the following [BibTeX code](https://github.com/Mikumikunisiteageru/BiomeAge.jl/blob/master/CITATION.bib) for your reference management software.
```bibtex
@article{BiomeAge2024,
	author = {Zhang, Qian and Yang, Yuchang and Liu, Bing and Lu, Limin and Sauquet, Hervé and Li, Dezhu and Chen, Zhiduan},
	title = {Meta-analysis provides insights into the origin and evolution of East Asian evergreen broad-leaved forests},
	journal = {New Phytologist},
	year = {2024},
	doi = {https://doi.org/10.1111/nph.19524},
	url = {https://nph.onlinelibrary.wiley.com/doi/abs/10.1111/nph.19524},
}
```
