using Pkg; Pkg.activate(".")
using SciGlassDatabase

load_essentials()


f = prop -> display(scatterTernary("SiO2-Na2O-CaO"; property=prop))

f.(list_of_props())

