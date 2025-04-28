# This file containes function to clean the dataframes loaded from the SciGlass database.

export clean_df!


"""
    clean_df!(df, item::Symbol)

Cleans and preprocesses a DataFrame loaded from the SciGlass database.
This function applies specific cleaning rules based on the type of table being processed.

# Arguments

- `df`: A `DataFrame` object representing the data to be cleaned.
- `item`: A `Symbol` representing the name of the table in the database (e.g., `:SciGK`).

# Description

The `clean_df!` function modifies the input DataFrame in place, applying transformations such as renaming columns or handling inconsistencies.
Each table type may have its own cleaning rules, which are determined by the `item` argument.

"""
function clean_df!(df, item)
    #################
    # For SciGK
    #################

    if Symbol(item) == :SciGK
        rename!(df, uppercase.(names(df)))
    end

end


