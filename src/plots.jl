export scatterTernary

"""
    scatterTernary(comps; property="DENSITY", kwargs...)

Plot a ternary plot given a composition and property.
"""
function scatterTernary(comps; property="DENSITY", kwargs...)
    df = get_compositions(;property=[property], composition=comps, kwargs...)

    NAMES = names(df)[end-2:end]
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