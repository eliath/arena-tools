#!/usr/bin/env th
local async = require 'async'
local json = require 'cjson'
local opt = lapp[[
Get the image pyramid JSON for all image blocks in a channel

   <channel>      (string)       The channel ID to look at
   <output>       (string)       path to output the JSON
   -a,--auth      (default auth.json)         Path to the authentication file
]]

local f = io.open(opt.auth, 'r')
local authData = f:read('*all')
f:close()
local ok, auth = pcall(json.decode, authData)
if not ok then error('[AUTH] Bad file:', opt.auth) end
local AUTH_TOKEN = auth.token
if (type(AUTH_TOKEN) ~= 'string' and AUTH_TOKEN:len() > 5) then
   error('[AUTH] Invalid token')
end

print('[AUTH] Token found:', AUTH_TOKEN)

local opath = path.abspath(path.expanduser(opt.output))
local odir = path.splitpath(opath)


local API_BASE = "http://api.are.na/v2"

local config = {
   url = API_BASE .. '/channels/' .. opt.channel .. '/contents',
   headers = { Authorization = 'Bearer ' .. AUTH_TOKEN },
   format = 'json'
}

print('[GET] '..config.url)

async.fiber(function()
   local resp = async.fiber.sync.get(config)
   local images = {}
   for _, o in ipairs(resp.contents) do
      if (o.image and type(o.image) == 'table') then
         table.insert(images, o.image)
      end
   end
   if #images == 0 then
      print('[RESULT] No Images found.')
      return
   end
   os.execute('mkdir -p "' .. odir .. '"')
   local f = io.open(opath, 'w')
   f:write(json.encode({ images = images }))
   f:close()
   print('[RESULT] in '..opath)
end)
async.go()
