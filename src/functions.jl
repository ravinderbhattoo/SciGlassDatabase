export load_table!, load_all_tables!, reload_table!, print_all_headers!, eachtable

"""
    eachtable(tables::Union{Property, Select})

Generate iterator over tables in Union{Property, Select}.

# Arguments

- `tables`: A collection of tables. Each table should be iterable and have a `names` function that returns its column names.

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
    reload_table!(tables, item::Union{Symbol, String})

Reload the table field with DataFrame from filepath. Skip loading if DataFrame already exists, use reload_table! for force reloading of table.

# Arguments

- `tables`: A collection of tables. Each table should be iterable and have a `names` function that returns its column names.
- `item`: The name of the table to load. It can be a `Symbol` or `String`.

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
    set_table_field!(a, item::Symbol, filepath::DataFrame)

Set table field with DataFrame from filepath. Skip loading if DataFrame already exists, use reload_table! for force reloading of table.

# Arguments
- `a`: A collection of tables. Each table should be iterable and have a `names` function that returns its column names.
- `item`: The name of the table to load. It can be a `Symbol` or `String`.
- `filepath`: The path to the file containing the table data. It can be a `String` or `DataFrame`.

"""
function set_table_field!(a, item::Symbol, filepath::DataFrame)
    print("already loaded $item")
    printstyled(" \u2713\n", color=:green, bold=true)
end


"""
    set_table_field!(a, item::Symbol, filepath::String)

Set table field with DataFrame from filepath. Skip loading if DataFrame already exists, use reload_table! for force reloading of table.

# Arguments

- `a`: A collection of tables. Each table should be iterable and have a `names` function that returns its column names.
- `item`: The name of the table to load. It can be a `Symbol` or `String`.
- `filepath`: The path to the file containing the table data. It can be a `String` or `DataFrame`.

"""
function set_table_field!(a, item::Symbol, filepath::String)
    print("loading $item \u23F3 ")
    try
        df = DataFrame(CSV.File(filepath))
        clean_df!(df, item)
        setfield!(a, item, df)
        printstyled(" \u2713\n", color=:green, bold=true)
    catch
        print("skipped $item")
        printstyled(" \u2715\n", color=:red, bold=true)
    end
    nothing
end


"""
    load_table!(table, item::Union{Symbol, String})

Set table field with DataFrame from filepath. Skip loading if DataFrame already exists, use reload_table! for force reloading of table.
If the filepath is a string, it will be joined with the artifact path.

# Arguments

- `table`: A collection of tables. Each table should be iterable and have a `names` function that returns its column names.
- `item`: The name of the table to load. It can be a `Symbol` or `String`.

# Example
```julia
load_table!(SELECT, "AtMol")
```

See also [`reload_table!`](@ref), [`load_table!`](@ref), [`load_all_tables!`](@ref).
"""
function load_table!(tables, item::Union{Symbol, String})
    filepath = getfield(tables, Symbol(item))
    if typeof(filepath) == String
        filepath = joinpath(@artifact_str(filepath), filepath)
    end
    set_table_field!(tables, Symbol(item), filepath)
end

"""
    load_all_tables!(tables; force=false)

Load all tables in the given collection of tables. If `force` is set to `true`, it will reload the tables even if they are already loaded.

# Arguments

- `tables`: A collection of tables. Each table should be iterable and have a `names` function that returns its column names.

# Keyword Arguments

- `force`: A boolean flag indicating whether to force reload the tables. Default is `false`.

See also [`reload_table!`](@ref), [`load_table!`](@ref), [`load_all_tables!`](@ref).

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

Prints the headers (column names) of all tables in the given collection of tables.

# Arguments
- `tables`: A collection of tables. Each table should be iterable and have a `names` function that returns its column names.

# Behavior
- Iterates through each table in the collection.
- Prints the name of the table (key) in bold red text.
- Prints the column names of the table.
- If an error occurs while processing a table, it catches the exception and prints a message indicating the table was skipped.
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

