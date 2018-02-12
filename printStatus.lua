local col = require 'trepl.colorize'

-- DEFAULTS --
local DEFAULT_CONFIG = {
   { label = 'success', color = 'green' },
   { label = 'fail', color = 'red' }
}
local DEFAULT_LJUST = 5

-- MODULE TABLE --
local __ = {}

__.init = function(config)
   config = config or DEFAULT_CONFIG

   local function tolabel(l)
      return ' -- '..l..': '
   end
   local status = {
      total = {
         label = tolabel('total'),
         count = 0
      }
   }

   -- format each label
   for _, x in ipairs(config) do
      status[x.label] = {
         label = tolabel(x.label),
         color = col[x.color] and x.color or nil,
         count = 0
      }
   end

   -- justify and colorize
  for k,v in pairs(status) do
     local l = stringx.rjust(v.label, rjust)
     if v.color then l = col[v.color](l) end
     status[k].label = l
  end

  __.status = status
end

__.reset = function()
   for k,_ in pairs(__.status) do
      __.status[k].count = 0
   end
end

__.update = function(update)
   if type(update) == 'string' and __.status[update] then
      update = { [update] = 1 }
   end
   if type(update) ~= 'table' then
      print(col._red('[ERR:printStatus] Invalid arg to update()'))
      return
   end
   for label, _ in pairs(__.status) do
      if label ~= 'total' and type(update[label]) == 'number' then
         __.status[label].count = __.status[label].count + update[label]
         __.status.total.count = __.status.total.count + update[label]
      end
   end
   __.write()
end

__.write = function()
   -- ljust based on current counts
   local ljust = DEFAULT_LJUST
   for _,x in pairs(__.status) do
      local digits = math.floor(math.log(x.count) / math.log(10)) + 2
      ljust = math.max(ljust, digits)
   end

   -- put label/count pairs in an array
   local out = {
      __.status.total.label,
      stringx.ljust(tostring(__.status.total.count), ljust)
   }
   for l,x in pairs(__.status) do
      if l ~= 'total' then
         table.insert(out, x.label)
         local count = stringx.ljust(tostring(x.count), ljust)
         if x.color then count = col[x.color](count) end
         table.insert(out, count)
      end
   end

   -- write array as a single line
   io.write(unpack(out))
   io.write('\r')
   io.flush()
end

return __
