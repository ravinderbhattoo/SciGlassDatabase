using Pkg; Pkg.activate(".")

using SciGlassDatabase

load_essentials()

comps = "SiO2-Na2O-MgO"
df = get_compositions(;property=["Density"], composition=comps)

# show this dataframe as table for visualization.
show_table(df; with_plot=true)

# Plot property vs composition
scatterplot_table(df, :SIO2, :DENSITY)

# Ploting ternary plot for glass with three component
scatterTernary(comps; property="DENSITY")

# Get metadata
df = get_compositions(;property=["Density"], composition=comps, with_metadata=true)

