local col = require 'trepl.colorize'
local image = require 'image'
local hashids = require 'hashids'

local opt = lapp[[
Recursively move through a directory tree, stripping the EXIF metadata from images along
the way. Each image is renamed with a short hash as an ID. Non-image files are removed
from the original directory into an error directory, but the filetree of the original
is preserved in the error dir.

   <root>       (string)             The root directory to start looking for image files
   <root_error> (default root_error) The root directory to use for problem files
]]

local ROOT = path.abspath(opt.root):gsub('%/$', '')
local ROOT_ERROR = (opt.root_error == 'root_error' and
   ROOT .. '_error' or path.abspath(opt.root_error))

----------------------------------------------
-- HELPER FUNCTIONS:
----------------------------------------------

-- Initialize Unique ID creation:
local h = hashids.new(tostring(os.time()), 4) -- use current time as the salt
local hashcntr = 0 -- use this counter to create file IDs

-- Creates a short hash for use as a unique ID
local function generateId()
   hashcntr = hashcntr + 1
   return h:encode(hashcntr)
end

-- Generates a new unique ID and returns the
-- absolute path of the new file to save
local function getSavePath(fpath)
   local dirPath = path.dirname(fpath)
   local ext = path.extension(fpath)
   local id = generateId()
   return path.join(dirPath, id .. ext)
end

-- Prints the job stats as it runs
local nSaved = 0
local nFailed = 0
local savedLabel = col.green(stringx.rjust('✓ ', 5))
local failedLabel = col.red(stringx.rjust('✗ ', 5))
local function printCounts(success)
   if (success) then
      nSaved = nSaved + 1
   else
      nFailed = nFailed + 1
   end
   local displaySaved = col.green(stringx.ljust(tostring(nSaved), 9))
   local displayFailed = col.red(stringx.ljust(tostring(nFailed), 9))
   io.write(savedLabel, displaySaved,
      failedLabel, displayFailed, '\r')
   io.flush()
end

-- escapes a string into a lua pattern
local function escapeString(s)
   return s:gsub('([^%w])', '%%%1')
end

-- Given a filepath, move that file into the "error" directory,
-- but maintain the filetree structure
local rootPathPattern = escapeString(ROOT)
local function handleError(fpath)
   local opath = fpath:gsub(rootPathPattern, ROOT_ERROR)
   local odir = path.dirname(opath)
   os.execute('mkdir -p "' .. odir .. '"')
   os.execute('mv "'.. fpath .. '" "' .. opath .. '"')
end

-- Strip the exif data via loading the file as a tensor of pixels
-- rename the file according to `getSavePath` function above
-- WILL ERROR FOR UNEXPECTED FILES OR FILES THAT CANNOT BE SAVED
-- WRAP IN PCALL AND HANDLE ACCORDINGLY
local function stripAndRename(imageFile)
   local res = image.load(imageFile)
   local savePath = getSavePath(imageFile)
   image.save(savePath, res)
   os.execute('rm -f "' .. imageFile .. '"')
end

----------------------------------------------
-- MAIN FUNCTION:
----------------------------------------------

-- Call this function with the start of the directory tree to traverse.
-- Recursively loop through all files, Strip EXIF data,
-- Save with a hashed unique ID, and delete the original image.
local function stripAndRenameRecursive(currPath)
   for fname in path.dir(currPath) do
      if (fname ~= '.' and fname ~= '..' and fname ~= '.DS_Store') then
         local fpath = path.join(currPath, fname)
         if (path.isdir(fpath)) then
            -- fpath is a directory;
            -- recursively process all files inside the directory:
            stripAndRenameRecursive(fpath)
         else
            -- Load, strip, and save the image
            local ok = pcall(stripAndRename, fpath)
            if ok then
               printCounts(true)
            else
               handleError(fpath)
               printCounts(false)
            end
         end
      end
   end
end

----------------------------------------------
-- RUN THE JOB:
----------------------------------------------
stripAndRenameRecursive(ROOT)
print(col.green('\nJOB COMPLETE'))
