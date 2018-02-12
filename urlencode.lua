local urlencode = {}

urlencode.string = function(str)
   --Ensure all newlines are in CRLF form
   str = str:gsub('\r?\n', '\r\n')

   -- Percent-encode all non-unreserved characters
   -- per RFC 3986, Section 2.3
   str = str:gsub('([^%w%-%.%_%~ ])', function(c)
      return string.format('%%%02X', c:byte())
   end)

   -- Encode space as plus
   str = str:gsub(" ", "+")
   return str
end

urlencode.table = function(t)
   local params = {}
   for k, v in pairs(t) do
      local pstr = urlencode.string(k) .. '=' .. urlencode.string(v)
      table.insert(params, pstr)
   end
   -- return the param string without a leading '?'
   return table.concat(params, '&')
end

return urlencode
