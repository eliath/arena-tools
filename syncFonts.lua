#!/usr/bin/env th
local printStatus = require('./printStatus')()

local opt = lapp[[
Sync font files from given directory with ~/Library/Fonts

   <inputDir> (string)  A directory containing font files to install
   --ignore-duplicates  Don't re-add duplicate files
]]

local fontsDir = path.expanduser('~/Library/Fonts')
local idir = path.abspath(path.expanduser(opt.inputDir))
assert(path.exists(idir), 'Input path does not exist')
assert(path.isdir(idir), 'Input path is not a directory')

local fontsToInstall = dir.getallfiles(idir, '*ttf')
for _,x in ipairs(dir.getallfiles(idir, '*otf')) do
   table.insert(fontsToInstall, x)
end

for _,fontFile in ipairs(fontsToInstall) do
   local fontName = path.basename(fontFile)
   local fontTarget = path.join(fontsDir, fontName)
   if path.exists(fontTarget) and opt['ignote-duplicates'] then
      printStatus(false)
   else
      os.execute('cp "' .. fontFile .. '" "' .. fontTarget .. '"')
      printStatus(true)
   end
end

print('done')
