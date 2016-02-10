local weather = require "weather"
local menubar = {}

local weatherBar = hs.menubar.new()

local apiKey = nil

function menubar.init()
   if file_exists("forecast_io_api_key.lua") then
      apiKey = require "forecast_io_api_key"
      updateWeatherBar()
      hs.timer.doEvery(15*60, updateWeatherBar)
   else
      hs.alert.show('Weatherbar in use, but no forecast.io api key found!')
   end
end

function updateWeatherBar()
   local w = weather.weather(apiKey, function(status, w)
                                if status == 200 then
                                   weatherBar:setTitle(weather.getIcon(w.currently.icon) ..
                                                          math.floor(w.currently.temperature + 0.5) ..
                                                          '/' ..
                                                          math.floor(w.daily.data[1].temperatureMin + 0.5) ..
                                                          '/' ..
                                                          math.floor(w.daily.data[1].temperatureMax + 0.5))
                                   weatherBar:setMenu(genWeatherBarMenu(w))
                                else
                                   hs.alert.show("forecast.io call failed. Check console for details.")
                                end
   end)
end

function genWeatherBarMenu(w)
   local menu = {}

   if w.minutely ~= nil then
      table.insert(menu, {title = weather.getIcon(w.minutely.icon) .. ' ' .. w.minutely.summary})
   end

   if w.hourly ~= nil then
      local hourlyMenu = {}

      for index, hour in ipairs(w.hourly.data) do
         table.insert(hourlyMenu, {title = os.date('%H', hour.time) .. ':\t' .. math.floor(hour.temperature + 0.5) .. '°\t' .. weather.getIcon(hour.icon) .. ' ' .. hour.summary})
      end

      table.insert(menu, {title = weather.getIcon(w.hourly.icon) .. ' ' .. w.hourly.summary,
                          menu = hourlyMenu})
   end

   if w.daily ~= nil then
      local dailyMenu = {}

      for index, day in ipairs(w.daily.data) do
         if index > 1 then
            table.insert(dailyMenu, {title = os.date('%a', day.time) .. ':  \t' .. weather.getIcon(day.icon) .. ' ' .. day.summary})
         end
      end

      table.insert(menu, {title = weather.getIcon(w.daily.icon) .. ' ' .. w.daily.summary,
                       menu = dailyMenu})
   end

   return menu
end

function file_exists(name)
   local f=io.open(name,"r")
   if f~=nil then
      io.close(f)
      return true
   else
      return false
   end
end

return menubar
