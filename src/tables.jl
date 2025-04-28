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
        make_plot(x, y) = PlotlyJS.plot(
            df, x=Symbol(x), y=Symbol(y),
            mode="markers", marker_size=8,
            Layout(
                width=800, height=600,
                margin=attr(l=20,r=20,t=20,b=20),
                paper_bgcolor="white",
                bgcolor="white",
                )
            )

        callback!(
            app,
            Output("x-dd-output-container", "children"),
            Output("y-dd-output-container", "children"),
            Output("graph", "children"),
            Input("x-dd", "value"),
            Input("y-dd", "value"),
            ) do input_1, input_2

            fig =  dcc_graph(figure = make_plot(input_1, input_2))

            return "You have selected \"$input_1\"", "You have selected \"$input_2\"", fig
        end
    end

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
                html_div(html_h3("Select x-axis")),
                dcc_dropdown(
                    id="x-dd",
                    options = options,
                    value = options[1],
                    style=Dict("width" => "400px")
                ),
                html_div(id="x-dd-output-container"),
                html_div(html_h3("Select y-axis")),
                dcc_dropdown(
                    id="y-dd",
                    options = options,
                    value = options[2],
                    style=Dict("width" => "400px")
                ),
                html_div(id="y-dd-output-container"),
                html_div(id="graph", style=Dict("width" => "800px",
                "border" => "solid 1px gray", "margin" => "10px"))
            ])
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
            style_data_conditional=[
                Dict(
                    "if" =>  Dict("row_index" =>  "odd"),
                    "backgroundColor" =>  "rgb(248, 248, 248)"
                )
            ],
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





