--[[
Netatmo Weather Provider
@author ikubicki
@version 2.1.0
]]

function QuickApp:setCondition(condition)
    local conditionCodes = {
        day = { 
            unknown = 3200,
            clear = 32,
            rain = 40,
            cloudy = 28,
            heat = 36,
            freeze = 25,
            windy = 23,
        },
        night = { 
            unknown = 3200,
            clear = 31,
            rain = 40,
            cloudy = 29,
            heat = 36,
            freeze = 25,
            windy = 23,
        }
    }
    collection = 'day'
    if tonumber(os.date('%H')) > 20 or tonumber(os.date('%H')) < 6 then
        collection = 'night'
    end
    local conditionCode = conditionCodes[collection][condition]
    if conditionCode then
        self:updateProperty("ConditionCode", conditionCode)
        self:updateProperty("WeatherCondition", condition)
    end
end

function QuickApp:onInit()
    self.config = Config:new(self)
    self.i18n = i18n:new(api.get("/settings/info").defaultLanguage)
    self.netatmo = Netatmo:new(self.config)
    self:trace('')
    self:trace('Netatmo weather provider')
    self:updateProperty('manufacturer', 'Netatmo')
    self:updateProperty('manufacturer', 'Weather Station')
    self:updateView("button_temperature", "text", self.i18n:get('Temperature'))
    self:updateView("button_humidity", "text", self.i18n:get('Humidity')) 
    self:updateView("button_wind", "text", self.i18n:get('Wind')) 
    self:updateView("button_rain", "text", self.i18n:get('Rain')) 
    self:updateView("button2_1", "text", self.i18n:get('search-devices'))
    self:updateView("button2_2", "text", self.i18n:get('refresh'))
    self:run()
    self._rain = 0
end

function QuickApp:run()
    self:pullNetatmoData()
    local interval = self.config:getTimeoutInterval()
    if (interval > 0) then
        fibaro.setTimeout(interval, function() self:run() end)
    end
end

function QuickApp:pullNetatmoData()
    self:updateView("button2_2", "text", self.i18n:get('refreshing'))
    local getWeatherDataCallback = function(weatherData)
        self:updateProperty("Temperature", weatherData.temp)
        self:updateProperty("Humidity", weatherData.humi)
        self:updateProperty("Wind", weatherData.wind)
        self._rain = weatherData.rain

        if weatherData.wind > 30 then
            self:setCondition('windy')
        elseif weatherData.rain > 0 then
            self:setCondition('rain')
        elseif weatherData.humi > 70 then
            self:setCondition('cloudy')
        elseif weatherData.temp < 0 then
            self:setCondition('freeze')
        elseif weatherData.temp > 30 then
            self:setCondition('heat')
        else 
            self:setCondition('clear')
        end
        self:updateView("label1", "text", string.format(self.i18n:get('last-update'), os.date('%Y-%m-%d %H:%M:%S')))
        self:updateView("button2_2", "text", self.i18n:get('refresh'))
    end
    self.netatmo:getWeatherData(getWeatherDataCallback)    
end

function QuickApp:refreshEvent()
    self:pullNetatmoData()
end

function QuickApp:searchEvent()
    self:debug(self.i18n:get('searching-devices'))
    self:updateView("button2_1", "text", self.i18n:get('searching-devices'))
    local searchDevicesCallback = function(stations)
        QuickApp:debug(json.encode(stations))
        -- printing results
        for _, station in pairs(stations) do
            QuickApp:trace(string.format(self.i18n:get('search-row-station'), station.name, station.id))
            QuickApp:trace(string.format(self.i18n:get('search-row-station-modules'), #station.modules))
            for __, module in ipairs(station.modules) do
                QuickApp:trace(string.format(self.i18n:get('search-row-module'), module.name, module.id, module.type))
                QuickApp:trace(string.format(self.i18n:get('search-row-module_types'), table.concat(module.data_type, ', ')))
            end
        end
        self:updateView("button2_1", "text", self.i18n:get('search-devices'))
        self:updateView("label1", "text", string.format(self.i18n:get('check-logs'), 'QUICKAPP' .. self.id))
    end
    self.netatmo:searchDevices(searchDevicesCallback)
end

function QuickApp:showTemperature()
    self:updateView("button_temperature", "text", self:getProperty("Temperature") .. " °C")
    fibaro.setTimeout(5000, function() 
        self:updateView("button_temperature", "text", self.i18n:get('Temperature')) 
    end)
end

function QuickApp:showHumidity()
    self:updateView("button_humidity", "text", self:getProperty("Humidity") .. " %")
    fibaro.setTimeout(5000, function() 
        self:updateView("button_humidity", "text", self.i18n:get('Humidity')) 
    end)
end

function QuickApp:showWind()
    self:updateView("button_wind", "text", self:getProperty("Wind") .. " km/h")
    fibaro.setTimeout(5000, function() 
        self:updateView("button_wind", "text", self.i18n:get('Wind')) 
    end)
end

function QuickApp:showRain()
    self:updateView("button_rain", "text", self._rain .. " mm")
    fibaro.setTimeout(5000, function() 
        self:updateView("button_rain", "text", self.i18n:get('Rain')) 
    end)
end

function QuickApp:getProperty(name)
    return fibaro.getValue(plugin.mainDeviceId, name)
end




