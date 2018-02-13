# Strip Exif Data

Removes all exif data and saves the image under a new unique ID
name.

Prints the job status as it executes and prints a job summary
after execution finishes.

**USAGE**

`image` and `hashids` packages, available from luarocks.

    $ luarocks install image
    $ luarocks install hashids

Change the variable named `START_PATH` to change the start
of the directory tree to operate on.

**IMPORTANT**

You should not alter the `test_images_orig/` directory in any way.

Instead, copy that folder and rename it, updating the `START_PATH`
variable in the script to the new folder name.

This will ensure you always have a clean set of images to
test with, as the script alters the files directly.
