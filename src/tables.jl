# Table functions for displaying

export show_table, save_table

"""
    show_table(df; title="Table", with_plot=false)

Displays a table using Dash and optionally includes an interactive plot.

# Arguments

- `df::DataFrame`: The data to be displayed in the table.
- `title::String`: The title of the table. Defaults to `"Table"`.
- `with_plot::Bool`: If `true`, includes an interactive plot feature. Defaults to `false`.

# Description

This function creates a Dash application to display a table. If `with_plot` is set to `true`,
it also provides an interactive scatter plot feature using PlotlyJS. Users can select the
columns for the x and y axes of the plot through dropdown menus.

# Interactive Plot

When `with_plot` is enabled:
- Dropdown menus allow users to select columns for the x and y axes.
- A scatter plot is generated dynamically based on the selected columns.
- The plot is displayed alongside the table.

"""
function show_table(df; title="Table", with_plot=false)
    app = dash()

    table_layout!(app, df; title=title, with_plot=with_plot)

    if with_plot

        # Callback to render scatter or ternary plot
        callback!(
            app,
            Output("graph", "children"),
            Input("plot-type", "value"),
            Input("x-dd", "value"),
            Input("y-dd", "value"),
            Input("z-dd", "value"),
            Input("color-property", "value")
        ) do plot_type, x_col, y_col, z_col, color_col
            if plot_type == "scatter"
                fig = PlotlyJS.plot(
                    df, x=Symbol(x_col), y=Symbol(y_col),
                    mode="markers", marker_size=8,
                    Layout(
                        width=1000,  # Increase width
                        height=800,  # Increase height
                        margin=attr(l=50, r=50, t=50, b=50),  # Adjust margins for better spacing
                        paper_bgcolor="white",
                        bgcolor="white"
                    )
                )
            elseif plot_type == "ternary"
                fig = PlotlyJS.plot(
                    PlotlyJS.scatterternary(
                            a=df[!, Symbol(x_col)],
                            b=df[!, Symbol(y_col)],
                            c=df[!, Symbol(z_col)],
                            mode="markers",
                            marker=attr(
                                size=8,
                                color=df[!, Symbol(color_col)],  # Use the selected property for color
                                colorscale="Viridis",  # Choose a colorscale
                                showscale=true  # Display the color scale
                            )
                            # text=((a)->("x=$(a[1]),\ny=$(a[2]),\nz=$(a[3]),\np=$(a[4])")).(eachrow(df[!, [Symbol(x_col), Symbol(y_col), Symbol(z_col), Symbol(color_col)]])) ,  # Add hover text with property values
                            # hoverinfo="text"  # Display only the hover text
            ),
                    Layout(
                        ternary=attr(
                            sum=1,
                            aaxis=attr(title=x_col),
                            baxis=attr(title=y_col),
                            caxis=attr(title=z_col)
                        ),
                        width=1000,  # Increase width
                        height=800,  # Increase height
                        margin=attr(l=50, r=50, t=50, b=50),  # Adjust margins for better spacing
                        paper_bgcolor="white",
                        bgcolor="white"
                    )
                )
            end

            return dcc_graph(figure=fig)
        end

        # Callback to enable or disable the z-axis dropdown based on plot type
        callback!(
            app,
            Output("z-dd", "disabled"),
            Output("color-property", "disabled"),
            Input("plot-type", "value")
        ) do plot_type
            a = plot_type != "ternary"
            return a, a  # Disable if plot type is not "ternary"
        end

    end

    # Callback for downloading CSV
    callback!(
        app,
        Output("download-dataframe-csv", "data"),
        Input("btn-download", "n_clicks"),
    ) do n_clicks
        if n_clicks > 0
            # Convert DataFrame to CSV string
            csv_data = IOBuffer()
            CSV.write(csv_data, df)
            seekstart(csv_data)  # Reset the buffer position
            return Dict(
                "content" => String(take!(csv_data)),
                "filename" => "table_data.csv",
                "type" => "text/csv"
            )
        end
        nothing
    end


    # Callback to highlight selected columns
    callback!(
        app,
        Output("data-table", "style_data_conditional"),
        Input("x-dd", "value"),
        Input("y-dd", "value"),
        Input("z-dd", "value"),
        Input("color-property", "value")
    ) do x_col, y_col, z_col, color_col
        return [
            Dict(
                "if" => Dict("column_id" => x_col),
                "backgroundColor" => "rgb(255, 230, 230)",  # Highlight x-axis column
                "fontWeight" => "bold"
            ),
            Dict(
                "if" => Dict("column_id" => y_col),
                "backgroundColor" => "rgb(230, 255, 230)",  # Highlight y-axis column
                "fontWeight" => "bold"
            ),
            # Highlight the z-axis column
            Dict(
                "if" => Dict("column_id" => z_col),
                "backgroundColor" => "rgb(230, 240, 255)",  # Light blue for z-axis
                "fontWeight" => "bold"
            ),
            # Highlight the selected property column
            Dict(
                "if" => Dict("column_id" => color_col),
                "backgroundColor" => "rgb(140, 130, 200)",  # Light red for the selected property
                "fontWeight" => "bold"
            )
        ]
    end


    run_server(app, "0.0.0.0", debug=true)
end

"""
    table_layout!(app, df; title="Table", with_plot=false)

Sets up the layout for the Dash application.

# Arguments

- `app`: The Dash application instance.
- `df`: A DataFrame object to be displayed in the table.
- `title`: A String specifying the title of the table. Defaults to "Table".
- `with_plot`: A Boolean indicating whether to include a plot in the layout. Defaults to `false`.

# Description

This function defines the layout of the Dash application, including the table, optional plot, and dropdowns for selecting x and y axes for the plot.
"""
function table_layout!(app, df; title="Table", with_plot=false)
    options = names(df)

    function graph_div()
        if with_plot
            html_div([
                html_div([
                    html_h3("Select x-axis", style=Dict("backgroundColor" => "rgb(255, 230, 230)")),
                    dcc_dropdown(
                        id="x-dd",
                        options = options,
                        value = options[1],
                        style=Dict("width" => "200px", "marginBottom" => "10px")
                    ),
                    html_h3("Select y-axis", style=Dict("backgroundColor" => "rgb(230, 255, 230)")),
                    dcc_dropdown(
                        id="y-dd",
                        options = options,
                        value = options[2],
                        style=Dict("width" => "200px", "marginBottom" => "10px")
                    ),
                    html_h3("Select z-axis for ternary plot", style=Dict("backgroundColor" => "rgb(230, 240, 255)")),
                    dcc_dropdown(
                        id="z-dd",
                        options = options,
                        value = options[3],
                        style=Dict("width" => "200px", "marginBottom" => "10px")
                    ),
                    html_h3("Select property for ternary plot color", style=Dict("backgroundColor" => "rgb(140, 130, 200)")),
                    dcc_dropdown(
                        id="color-property",
                        options=[Dict("label" => col, "value" => col) for col in names(df)],
                        value=names(df)[1],  # Default to the first column
                        style=Dict("width" => "200px", "marginBottom" => "10px")
                    ),
                    html_h3("Select Plot Type"),
                    dcc_dropdown(
                        id="plot-type",
                        options = [
                            Dict("label" => "Scatter Plot", "value" => "scatter"),
                            Dict("label" => "Ternary Plot", "value" => "ternary")
                        ],
                        value = "scatter",
                        style=Dict("width" => "200px", "marginBottom" => "10px")
                    )
                ], style=Dict("width" => "25%", "float" => "left", "padding" => "10px")),
                html_div([
                    html_div(id="graph", style=Dict(
                        "width" => "1000px",  # Match the plot width
                        "height" => "800px",  # Match the plot height
                        "border" => "solid 1px gray",
                        "overflow" => "auto",  # Allow scrolling if necessary
                        "margin" => "10px"
                    ))
                ], style=Dict("width" => "70%", "float" => "right", "padding" => "10px"))
            ], style=Dict("display" => "flex"))
        else
            html_div()
        end
    end

    app.layout = html_div() do
        html_h1(title),
        graph_div(),
        html_button("Download CSV", id="btn-download", n_clicks=0),
        dcc_download(id="download-dataframe-csv"),
        html_div([
            html_div("Click the button to download the table as a CSV file."),
            html_div("Note: The download will only work in a browser, not in Jupyter Notebook.")
        ]),
        dash_datatable(
            id="data-table",
            data = map(eachrow(df)) do r
            Dict(names(r) .=> values(r))
            end,
            columns=[Dict("name" =>c, "id" => c) for c in names(df)],
            style_cell_conditional=[
                Dict(
                    "if" =>  Dict("column_id" =>  c),
                    "textAlign" =>  "left"
                ) for c in ["Date", "Region"]
            ],
            style_data_conditional=[],
            style_header=Dict(
                "backgroundColor" =>  "rgb(230, 230, 230)",
                "fontWeight" =>  "bold"
            )
        )
    end

end

"""
    save_table(filepath, df)

Saves a DataFrame to a CSV file at the specified filepath.

# Arguments

- `filepath`: A String specifying the path where the CSV file will be saved.
- `df`: A DataFrame object to be saved.

# Description

This function writes the contents of the DataFrame to a CSV file using the CSV.write function.
"""
function save_table(filepath, df)
    CSV.write(filepath, df)
end





