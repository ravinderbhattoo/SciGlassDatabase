# This file contains function to plot data.

export scatterTernary, scatterplot_table

"""
    scatterTernary(composition; property="DENSITY", kwargs...)

Generates a scatter plot on a ternary diagram based on the given composition and property.

# Arguments
- `composition`: The composition data to be plotted. This should be a data structure compatible with the `get_compositions` function.
- `property`: A string specifying the property to be visualized. Defaults to `"DENSITY"`. The property name is automatically converted to uppercase.
- `kwargs...`: Additional keyword arguments passed to the `get_compositions` function.

# Returns
- A scatter plot object if the composition data contains entries; otherwise, no plot is generated.

# Details
- The function retrieves the composition data and the specified property using the `get_compositions` function.
- The ternary composition data is converted to Cartesian coordinates using the `tern2cart` function.
- A ternary plot is created with axes labeled according to the composition names.
- The scatter plot is colored based on the values of the specified property, with a colorbar included for reference.

# Notes
- The function assumes that the input composition data contains at least three components for ternary plotting.
- If the composition data is empty, no scatter plot is generated.
"""
function scatterTernary(composition; property="DENSITY", kwargs...)
    property = uppercase(property)
    df = get_compositions(;property=[property], composition=composition, kwargs...)

    NAMES = names(df)[3:5]
    compos = df[!, NAMES]

    a = [zeros(Float64, size(compos, 1)) zeros(Float64, size(compos, 1))]

    for i in 1:size(compos,1)
        a[i,:] = collect(tern2cart(compos[i,:]))'
    end

    ternary_axes(
        title=property,
        xguide=NAMES[1],
        yguide=NAMES[2],
        zguide=NAMES[3],
    )
    if size(compos, 1) > 0
        return scatter!(a[:,1], a[:,2], marker_z=df[!, property], legend=false,
        colorbar=true, colorbar_title=" \n ", right_margin = 2*Plots.mm,
        )
    end
end



"""
    scatterplot_table(df, x, y)

Generates a scatter plot from the given DataFrame `df` using the specified columns `x` and `y`.

# Arguments
- `df::DataFrame`: The input DataFrame containing the data to be plotted.
- `x::Symbol`: The column name in the DataFrame to be used for the x-axis.
- `y::Symbol`: The column name in the DataFrame to be used for the y-axis.

# Behavior
- Converts the column names `x` and `y` to uppercase before plotting.
- Creates a scatter plot with no legend label.
- Sets the x-axis and y-axis labels to the uppercase string representation of the column names.

"""
function scatterplot_table(df, x, y)
    x, y = Symbol.(uppercase.(String.([x, y])))
    Plots.scatter(df[!, x], df[!, y], label=nothing)
    xlabel!(String(x))
    ylabel!(String(y))
end



