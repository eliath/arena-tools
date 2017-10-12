CSV 2 JSON
==========

A script to efficiently convert large CSV files to JSON.

Run `csv2json/init.lua` without arguments for detailed usage.

Usage
-----

quite simply: `csv2json/init.lua <inputCSV> <output>`

Recommended to run the script with torch7. Dependencies should be autmatically
injected into the global namespace.

Pure lua users should ensure they have the cjson package.

### Example - using Map option

    $ th csv2json/init.lua input.csv output/ --map ./mapping.lua

...will take the rows of `input.csv` and save each as its own JSON file in `output/`,
using the function returned from `mapping.lua` to map the row to the desired
output format.

By default, there is no mapping function; the CSV column headers will be used
as the JSON keys in the output.

### Mapping

The script offers a `--map` option that allows the user to apply a custom mapping
function to the CSV rows. The `--map` option expects a path to a lua file that reutrns
a single function. The function has two parameters: the CSV row, as a lua table, and
the row index. The function should return a lua table representing the output for
that CSV row

#### Example Mapper

For example, if the script si called with a mapping function:

    $ th csv2json input.csv output/ --map mapping.lua

`mapping.lua`:

    return function(data, index)
      local out = tablex.union(data, {
        fullname = data.firstname .. ' ' .. data.lastname,
        id = index
      })
      return out
    end

The above would take a CSV row, retain all its data as-is, and insert (or overwrite)
the `fullname` and `id` fields.

- `data` is the CSV row as a lua table
- By default, script expects column headers in the first row
- Row `0` for CSVs with column headers will be the first row of actual data, not the header row

If the file has a header row, `data` will have the headers as string keys and the
values as the CSV column values as strings.

If the file does not have a header row, `data` will be a "list" of string values.

#### `__filename` feild

The mapping function can also determine the filename in which  to save the mapped data
(dir mode only). Set the `__filename` feild on the table returned from the mapping
function, and the script will save the data in a file in your specified output directory
under that name, e.g. `<output_dir>/<__filename>.json`.
The `__filename` feild is deleted before writing the data so it won't muddle
the results.
