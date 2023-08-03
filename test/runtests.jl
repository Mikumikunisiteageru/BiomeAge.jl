# test/runtests.jl

using Aqua
using BiomeAge

Aqua.test_ambiguities(BiomeAge)
Aqua.test_unbound_args(BiomeAge)
Aqua.test_undefined_exports(BiomeAge)
Aqua.test_piracy(BiomeAge)
Aqua.test_project_extras(BiomeAge)
Aqua.test_stale_deps(BiomeAge)
Aqua.test_deps_compat(BiomeAge)
Aqua.test_project_toml_formatting(BiomeAge)
