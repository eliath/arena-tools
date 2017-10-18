return function()
   local col = require 'trepl.colorize'

   local status = {
      total = {
         label = stringx.rjust(' -- total: ', 13),
         count = 0
      },
      success = {
         label = col.green(stringx.rjust(' -- success: ', 13)),
         count = 0
      },
      fail = {
         label = col.red(stringx.rjust(' -- fail: ', 13)),
         count = 0
      }
   }

   local printError = function(str)
      print('[ERR:printStatus] '..str)
   end

   local applyUpdate = function(update)
      if update == true then
         update = { total = 1, success = 1, fail = 0 }
      elseif update == false then
         update = { total = 1, success = 0, fail = 1 }
      end

      if type(update) ~= 'table' or
         type(update.total) ~= 'number' or
         not (update.success or update.fail) then
         return printError('Invalid <update> arg')
      end

      status.total.count = status.total.count + update.total
      status.success.count = status.success.count + update.success
      status.fail.count = status.fail.count + update.fail
   end

   return function(update)
      applyUpdate(update)

      totalCount = stringx.ljust(tostring(status.total.count), 5)
      failCount = stringx.ljust(tostring(status.fail.count), 5)
      successCount = stringx.ljust(tostring(status.success.count), 5)

      io.write(
         status.total.label,   totalCount,
         status.success.label, successCount,
         status.fail.label,    failCount,
         '\r')
      io.flush()
   end
end
