push!(LOAD_PATH,"../src/")

using Documenter, DocThemeIndigo, SciGlassDatabase

indigo = DocThemeIndigo.install(SciGlassDatabase)

function prepare_documentation()
    makedocs(sitename="SciGlassDatabase.jl";
        build = "../documentation",
        format = Documenter.HTML(
        prettyurls = get(ENV, "CI", nothing) == "true",
        assets=String[indigo]
        ),
        modules=[SciGlassDatabase],
        pages = [
            "Home" => "sciglassdatabase.md",
            "Table of contents" => "toc.md",
            "Examples" => "examples.md",
            "Index" => "index.md",
            "Autodocs" => "autodocs.md"
        ]
    )
end

prepare_documentation()
