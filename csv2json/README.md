CSV 2 JSON
==========

A script to efficiently convert large CSV files to JSON.

Run `./csv2json --help` for detailed usage.

Usage
-----

### Examples

--> print the csv file as an array of JSON objects to STDOUT

    $ ./csv2json input.csv

--> output the array of JSON objects to a file named `output.json`

    $ ./csv2json input.csv ./path/to/output.json

--> output each CSV row as a JSON file containing a single object
in the directory `outputFiles/` (triggered by trailing slash)

    $ ./csv2json input.csv ./path/to/outputFiles/


#### using `--map` option

The `--map` option allows the user to specify a custom mapping function
for the CSV --> JSON data.

    $ ./csv2json input.csv --map ./mapFunc.lua

The function returned from `mapFunc.lua` should take two arguments

```
-- mapFunc.lua --

return function(data, idx)
  -- data is the CSV row as a lua table
  -- idx is the CSV row index

  -- function should return a lua table
  -- the returned object will be encoded
  -- and output as JSON
end
```

##### Important:

If your output parameter is a directory, you can control the filenames
of the output JSON by setting the `__filename` field on the lua table
returned from your mapping function.

If `__filename` (or the mapFunc altogether) is not given, the files
will have names like `0.json`, `1.json`, etc... according to their
row index in the CSV file.

### Gotchas

- By default, script expects column headers in the first row
- Row `0` for CSVs with column headers will be the first row of actual data, not the header row
