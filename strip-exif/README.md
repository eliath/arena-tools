# Strip Exif Data

Removes all exif data and saves the image under a new unique ID
name.

Prints the job status as it executes and prints a job summary
after execution finishes.

**USAGE**

You need the `image` and `hashids` packages, available from luarocks.

    $ luarocks install image
    $ luarocks install hashids

Run with no arguments to see usage.

You can test on the exif-samples directory:

    $ th strip-exif.lua ./exif-samples/

Then to reset the directory back to normal:

    $ git submodule update
    $ git submodule foreach git clean -fdx

