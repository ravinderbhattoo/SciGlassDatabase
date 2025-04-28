
export print_properties, list_properties, print_property_data, get_compositions, get_molar_wt, list_metadata

"""
    print_property_data()

Print property names and their corresponding field names from the `PROPERTY.LISTPROP` table.

"""
function print_property_data()
    for item in  eachrow(PROPERTY.LISTPROP[!, :])
        printstyled("$(item[:NAME]) ", color=:green, bold=false)
        printstyled("\u27F7 ", color=:red, bold=true)
        printstyled("$(item[:FLDNAM])", color=:green, bold=false)
        printstyled(" [ $(item[:Unit]), $(item[:IDF])]\n", color=:green, bold=false)
    end
end

"""
    print_properties()

Print property names from the [`list_properties`](@ref).
"""
function print_properties()
    for i in list_properties()
        printstyled("$i\n"; bold=true)
    end
end

"""
    list_properties()

Return property names as vector that can be extracted using [`get_compositions`](@ref).

# Returns

- `list`: List of property names.

List of properties:

T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, V500, V600, V700, V800, V900, V1000,
V1100, V1200, V1300, V1400, V1500, V1600, V1800, V2000, V2200, TG, LPT, ANPT, SPT, Tsoft, RO150,
RO300, RO20, RO100, TK100C, TEC55, TEC100, TEC160, TEC210, TEC350, ANY_TEC, DENSITY, spvm, ND300,
nd300low, nd300hi, DNFC300, NUD300, RTSH180, MOD_UNG, MOD_SDV, MIKROTV, EPS730, TGD730, ro800,
ro1000, ro1200, ro1400, Tm, TLiq, SUT900, SUT1200, SUT1300, SUT1400, any_sut, cond220, pois,
cp20, cp200, cp400, cp800, cp1000, cp1200, cp1400, dens800, dens1000, dens1200, dens1400, Tmax,
Vmax, Tn, Io, tcr, tx

"""
function list_properties()
    list = ["T1", "T2", "T3", "T4", "T5", "T6", "T7", "T8", "T9", "T10", "T11", "T12", "T13",
            "V500", "V600", "V700", "V800", "V900", "V1000", "V1100", "V1200", "V1300", "V1400",
            "V1500", "V1600", "V1800", "V2000", "V2200", "TG", "LPT", "ANPT", "SPT", "Tsoft",
            "RO150", "RO300", "RO20", "RO100", "TK100C", "TEC55", "TEC100", "TEC160", "TEC210",
            "TEC350", "ANY_TEC", "DENSITY", "spvm", "ND300", "nd300low", "nd300hi", "DNFC300",
            "NUD300", "RTSH180", "MOD_UNG", "MOD_SDV", "MIKROTV", "EPS730", "TGD730", "ro800",
            "ro1000", "ro1200", "ro1400", "Tm", "TLiq", "SUT900", "SUT1200", "SUT1300", "SUT1400",
            "any_sut", "cond220", "pois", "cp20", "cp200", "cp400", "cp800", "cp1000", "cp1200",
            "cp1400", "dens800", "dens1000", "dens1200", "dens1400",  "Tmax", "Vmax", "Tn", "Io", "tcr", "tx"]
    return list
end

"""
    list_metadata()

Return vector of subset of metadata headers for a glass compositions.

# Returns

- `list`: List of metadata headers.

List of metadata:

Author, Year, Glass_Class, Analysis, Prop_Code, GForm, any_n, Trademark, QComp,
QComp2, Flag

"""
function list_metadata()
    list = ["Author", "Year", "Glass_Class", "Analysis", "Prop_Code",
    "GForm", "any_n", "Trademark", "QComp", "QComp2", "Flag"]
    return list
end

"""
    get_compositions(;property=["DENSITY", "TLiq"], composition="SiO2-K2O", prop_inner=true, comp_inner=true,
        clean=true, molp=true, with_metadata=false)

Return a DataFrame with glass compositions and their properties.

# Arguments

- `property=["DENSITY"]`: List of properties to be extracted.
- `composition="SiO2-K2O"`: Glass compositions.
- `prop_inner=true`: If true takes intersection of data for multiple properties, otherwise union.
- `comp_inner=true`: If true takes intersection of data for multiple components, otherwise union.
- `clean=true`": If true, clean the DataFrame before returning (extra columns removed).
- `molp=true`: If true, compositions are in mol%, otherwise weight%.
- `with_metadata=false`: If true, give metadata for each composition (Authors, Year, Journal etc.).

# Returns

- `DataFrame`: DataFrame with glass compositions and their properties.

`DataFrame` contains the following columns:
- `GLASNO`: Glass number.
- `property`: Property values.
- `composition`: Composition values.

    # Example
```julia
get_compositions(;property=["DENSITY", "TLiq"], composition="SiO2-Na2O")
```

"""
function get_compositions(;property=["DENSITY", "TLiq"], composition="SiO2-K2O", prop_inner=true, comp_inner=true, clean=true, molp=true, with_metadata=false)
    cols = split(composition, "-")
    COLS = uppercase.(cols)
    property = uppercase.(property)

    mask = @. typeof(SELECT.SciGK[!, property]) != Missing
    if prop_inner
        mask = [Bool(prod(i)) for i in eachrow(mask)]
    else
        mask = [Bool(sum(i)>0) for i in eachrow(mask)]
    end

    function Float64(x)
        if typeof(x) == Missing
            return Float64(0.0)
        else
            x
        end
    end

    function check(i)
        i = Float64.(collect(i))
        return Bool( all((x) -> (x > 0.0) || ~comp_inner, i) && (sum(i) > 99.0) && (sum(i) < 101.0) )
    end

    mask2 = [check(i) for i in eachrow(SELECT.SciGK[!, COLS])]

    mask = @. mask * mask2

    props = SELECT.SciGK[mask, ["GLASNO", "KOD", property...]]
    metadata = SELECT.SciGK[mask, uppercase.(list_metadata())]
    comps = SELECT.SciGK[mask, COLS]

    if ~molp
        mmass = get_molar_wt(cols)
        for (item, m) in zip(COLS, mmass)
            comps[!, item] .*= m
        end
        total = [sum(i) for i in eachrow(comps)]
        for item in COLS
            comps[!, item] ./= total/100
        end
    end

    mainout = hcat(props, comps)
    out = mainout

    if clean
        out = out[:, ["GLASNO", property..., COLS...]]
    end

    if with_metadata
        refid = SELECT.Kod2Ref.RefID[indexin(mainout.KOD, SELECT.Kod2Ref.Kod)]
        index = indexin(refid, SELECT.Reference.Refer_ID)
        REF = SELECT.Reference[index, :]
        all_names = union(Set(names(REF)), Set(names(metadata)))
        new_names = setdiff(all_names, Set(names(REF)))
        out = hcat(out, metadata[!, collect(new_names)], REF)
    end

    return out
end


"""
    get_molar_wt(comps_list)

Return molar weight from component list.

# Arguments

- `comps_list`: List of glass components

# Returns

- 'list': List of molar weight for each component

"""
function get_molar_wt(comps_list)
    index = indexin(comps_list, PROPERTY.CalcComp.FORMULA)
    return collect(PROPERTY.CalcComp.M_WT[index])
end

"""
    separate_columns(comps, compositions)

Convert composition from string representation to DataFrame.
"""
function separate_columns(comps, compositions)
    cols = split(comps, "-")
    dict1 = Dict()
    for item in cols
        dict1 = merge(dict1, Dict(item=>Float64[]))
    end

    function apply!(composition)
        for item in cols
            push!(dict1[item], 0.0)
        end
        for item in split(composition, "-")
            a, b = split(item, "_")
            dict1[a][end] = parse(Float64, b)
        end
    end

    apply!.(compositions)

    return DataFrame(dict1)
end

"""
    get_components_from_composition(x; molp=true)

Return list of components with data.
"""
function get_components_from_composition(x; molp=true)
    x_ = split(x, "-")
    if length(x_) >=4
        if molp
            return [foldl((a, b)->a*"_"*b, (x_[i], x_[i+3])) for i in 1:4:length(x_)]
        else
            return [foldl((a, b)->a*"_"*b, (x_[i], x_[i+2])) for i in 1:4:length(x_)]
        end
    else
        return [""]
    end
end


"""
    get_composition_from_glass_number(glassno; composition="SiO2", molp=true, inner=true)

Return mask if components present in glass numbers and glass compositions from glass numbers.

"""
function get_composition_from_glass_number(glassno; composition="SiO2", molp=true, inner=true)
    mask = indexin(glassno, SELECT.Gcomp.GlasNo)
    table = SELECT.Gcomp[mask, :]

    clean_comps = x -> replace(x, "\x7f"=>"-")[2:end-1]
    nComposition = clean_comps.(table.Composition)

    table.Composition .= nComposition

    items = split(composition, "-")
    function findin(inp)
        if (length(inp)==length(items)) || ~inner
            return all((a) -> any(x->occursin(x, a), items), inp)
        else
            return false
        end
    end

    components = get_components_from_composition.(table.Composition; molp=molp)

    ifin = findin.(components)
    comps = table[ifin, :]
    comps.Composition .= map((x)->foldl((a, b)-> a*"-"*b, x), components[ifin])

    ifin, comps
end
