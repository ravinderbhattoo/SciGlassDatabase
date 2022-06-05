export load_table!, load_all_tables!, reload_table!, print_all_headers!, eachtable

"""
    eachtable(tables::Union{Property, Select})
    
Generate iterator over tables in Union{Property, Select}.

# Example
```julia
for (name, table) in eachtable(SELECT)
    # some code
end
```
"""
function eachtable(tables::Union{Property, Select})
    ((item, getproperty(tables, item)) for item in fieldnames(typeof(tables)))
end



"""
    reload_table!(a, item)

Force reload table field with DataFrame from filepath.

See also [`load_table!`](@ref), [`load_all_tables!`](@ref).

# Example
```julia
reload_table!(SELECT, "AtMol")
```
"""
function reload_table!(tables, item)
    filepath = String(item) * ".TXT"
    filepath = joinpath(@artifact_str(filepath), filepath)
    set_table_field!(tables, Symbol(item), filepath)
end

"""
    set_table_field!(a, item::Symbol, filepath::Union{DataFrame, String})

Set table field with DataFrame from filepath. Skip loading if DataFrame already exists, use reload_table! for force reloading of table.

See also [`reload_table!`](@ref), [`load_table!`](@ref), [`load_all_tables!`](@ref).

"""
function set_table_field!(a, item::Symbol, filepath::DataFrame)
    print("already loaded $item")
    printstyled(" \u2713\n", color=:green, bold=true)
end

function set_table_field!(a, item::Symbol, filepath::String)
    print("loading $item \u23F3 ")
    try
        df = DataFrame(CSV.File(filepath))
        setfield!(a, item, df)
        printstyled(" \u2713\n", color=:green, bold=true)
    catch
        print("skipped $item")
        printstyled(" \u2715\n", color=:red, bold=true)
    end
    nothing
end


"""
    load_table!(table, field)

Set table field with DataFrame. Skip loading if DataFrame already exists, use reload_table! for force reloading of table.

See also [`reload_table!`](@ref), [`load_table!`](@ref), [`load_all_tables!`](@ref).

# Example
```julia
load_table!(SELECT, "AtMol")
```

"""
function load_table!(tables, item::Union{Symbol, String})
    filepath = getfield(tables, Symbol(item))
    if typeof(filepath) == String
        filepath = joinpath(@artifact_str(filepath), filepath)
    end
    set_table_field!(tables, Symbol(item), filepath)
end

"""
    load_all_tables!(tables)

Load all table fields with DataFrame. Skip loading if DataFrame already exists, use reload_table! for force reloading of table.

See also [`reload_table!`](@ref), [`load_table!`](@ref), [`load_all_tables!`](@ref).

# Example
```julia
load_all_tables!(SELECT)
```

"""
function load_all_tables!(tables; force=false)
    for (item, filepath) in eachtable(tables)
        if force
            reload_table!(tables, item)
        else
            load_table!(tables, item)
        end
    end
end

"""
    print_all_headers!(tables)

Print headers of all the tables.

# Example
```julia
print_all_headers!(SELECT)
```
"""
function print_all_headers!(tables)
    for (item, x) in eachtable(tables)
        try
            println()
            printstyled("$item\n"; color = :red, bold=true) 
            println(names(x))
        catch
            println("skipped $item")
        end
    end
end

