local json = require 'cjson'

local opt = lapp[[
Convert a CSV file to JSON.
Each CSV row becomes a JSON object in the output.
Output paths ending in / means each row will be output as a separate file.
Otherwise output as an array of objects.
The script buffers input/output and thus should be safe on large files.

   <input>  (string)           The input CSV file
   <output> (optional string)  Path to JSON output, stdout by default.
                               Trailing slash means directory
   --map    (optional string)  Path to lua file with mapping function (see README)
   --no-header                 No CSV column headers; treat rows as unlabeled array
]]

local CHUNKSIZE = 2^13 -- 8kb
local dirOut = opt.output and
   (stringx.endswith(opt.output, '/') or path.isdir(opt.output))
local fileOut = not dirOut
local mapFunc = opt.map and require(opt.map) or (function(d) return d end)
local headers -- used to hold the column headers
local firstLine = true
local lineIdx = 0


if fileOut then
   opt.output = io.output(opt.output)
   opt.output:write('[\n')
end

if dirOut then
   opt.output = path.abspath(path.expanduser(opt.output))
   os.execute('mkdir -p "' .. opt.output .. '"')
end

opt.input = io.open(opt.input, 'r')

local readChunk = function()
   local lines, rest = opt.input:read(CHUNKSIZE, '*line')
   if not lines then return nil end
   if rest then lines = lines .. rest end
   lines = stringx.strip(lines, '\n')
   return stringx.split(lines)
end

local splitLine = function(line)
   return stringx.split(stringx.strip(line), ',')
end

local decodeLine = function(line, idx)
   local cols = splitLine(line)
   local res = cols
   if headers then
      res = {}
      for i,val in ipairs(cols) do
         local k = headers[i] or '__UNKNOWN_HEADER__'..i
         res[k] = val
      end
   end
   return mapFunc(res, idx)
end

local writeData = function(data, lineIdx)
   if dirOut then
      local opath = path.join(opt.output,
         (data.__filename or tostring(lineIdx)) .. '.json')
      data.__filename = nil
      local ofile = io.open(opath, 'w')
      ofile:write(json.encode(data))
      ofile:close()
   else
      if lineIdx > 0 then opt.output:write(',\n') end
      opt.output:write(json.encode(data))
   end
end

while true do
   local lines = readChunk()
   if not lines then break end

   for i,line in ipairs(lines) do
      if lineIdx == 0 and not opt['no-header'] and not headers then
         -- Grab the headers from the first line instead of writing
         headers = splitLine(line)
      else
         local data = decodeLine(line, lineIdx)
         writeData(data, lineIdx)
         lineIdx = lineIdx + 1
      end
   end
end


if fileOut then
   opt.output:write('\n]')
   opt.output:close()
end
