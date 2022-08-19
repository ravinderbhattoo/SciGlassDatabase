"""
A Julia package for extracting data from SciGlass database.

Verbatim from https://github.com/epam/SciGlass

__SciGlass__

The largest glass property database contains data for more than 420 thousand glass compositions including more than 18 thousand halide and about 38 thousand chalcogenide glasses. It provides also property predictions and calculations, help you solve R&D problems.

__Features__

- Glass Properties. Practically all broadly used physical and chemical properties of glasses and glass-forming melts with concise but informative description of syntheses and measurement procedures.
- Glasses. 422,000 glasses and melts, including more than 268,000 oxide glasses and melts, 18,500 halide and 38,500 chalcogenide glasses. The data were taken from more than 40,000 literature sources including more than 19,700 patents.
- Property Calculations. Over 100 computational methods to compute the properties in 15 groups (e.g., viscosity, density, mechanical, optical), many of them in broad temperature ranges. Prediction of properties of oxide, halide, and chalcogenide glasses is possible in wide concentration ranges.
- Ternary Diagrams of Glass Formation. More than 3,800 ternary diagrams of glass formation.
- Optical Spectra. More than 15,000 optical spectra (from UV to near IR) for glasses and melts with 96 different ways to represent spectra.
- Ternary Property Diagram.Automatically generate isoproperty lines versus composition and compare calculated and experimental property values for ternary compositions.
- Statistical Analysis. Find best computational method from least squares fit of calculated and experimental values to insure best method can be applied to your glass composition.
- Patent and Trademark Index. Over 19,000 international patents and 1,000 trademarks; complete information on usage, country, company, composition, property table, author, and TM symbol.
- Subject Index. Explore hundreds of specialized subjects (e.g., diffusion of specific gases & ions), which are difficult to find by other ways.
- Chemical Durability of Glasses. Pertinent data on about 35,000 glasses as well as access to a large compendium on standard durability testing methods.
- Optimization of Glass Compositions. Find the most perspective glass compositions meeting a complex of requirements on specific values of their properties

"""
module SciGlassDatabase

using DataFrames, Query, CSV, Plots, TernaryPlots
using Pkg.Artifacts

export PROPERTY, SELECT, load_essentials

"""
    Property holds all the table in Property.mdb database file.

# List of tables:

    ATOMS
    CalcListProp
    IDF
    Legends
    SYMBOL
    tblpar
    CalcAtoms
    DT
    Journal
    PConvert
    Sort_Comp
    CalcComp
    DT2
    LISTPROP
    PropList
    UNITS

"""
mutable struct Property
    ATOMS
    CalcListProp
    IDF
    Legends
    SYMBOL
    tblpar
    CalcAtoms
    DT
    Journal
    PConvert
    Sort_Comp
    CalcComp
    DT2
    LISTPROP
    PropList
    UNITS
end

function Property()
    items = [string(fn)*".TXT" for fn in fieldnames(Property)]
    Property(items...)
end

"""
    Select holds all the table in Select.mdb database file.

# List of tables:

    Authors
    GF_add
    MaxGno
    Reference
    SpectralParam
    WtPc
    AtMol
    Contries
    Gcomp
    MolPc
    SciGK
    SubjectIndex
    AtWt
    GF
    Kod2Ref
    Patents
    Spectr
    Trademark

"""
mutable struct Select
    Authors
    GF_add
    MaxGno
    Reference
    SpectralParam
    WtPc
    AtMol
    Contries
    Gcomp
    MolPc
    SciGK
    SubjectIndex
    AtWt
    GF
    Kod2Ref
    Patents
    Spectr
    Trademark
end

function Select()
    items = [string(fn)*".TXT" for fn in fieldnames(Select)]
    Select(items...)
end


function Base.show(io::IO, table::Union{Select, Property}) 
    printstyled("$(typeof(table))\n", color=:blue, bold=true)
    fnames = fieldnames(typeof(table))
    for item in fnames[1:end-1]
        printstyled("    \u22A2\u2192 ", color=:blue)
        if typeof(getfield(table, item)) == String
            printstyled("$item  \u2715\n", color=:red, bold=true)
        else
            printstyled("$item  \u2713\n", color=:green, bold=true)
        end
    end
    item = fnames[end]
    printstyled("    \u25F3\u2192 ", color=:blue)
    if typeof(getfield(table, item)) == String
        printstyled("$item  \u2715\n", color=:red, bold=true)
    else
        printstyled("$item  \u2713\n", color=:green, bold=true)
    end
end

PROPERTY = Property()
SELECT = Select()

include("./functions.jl")
include("./extract.jl")
include("./plots.jl")

function load_essentials()
    load_table!(PROPERTY, "LISTPROP")
    load_table!(PROPERTY, "CalcComp")
    load_table!(SELECT, "SciGK")
    load_table!(SELECT, "Gcomp")
    load_table!(SELECT, "Kod2Ref")
    load_table!(SELECT, "Reference")
    return true
end

end
