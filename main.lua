--[[
Netatmo Weather Provider
@author ikubicki
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
    self.auth = Auth:new(self.config)
    self.http = HTTPClient:new({
        baseUrl = 'https://api.netatmo.com/api'
    })
    self.i18n = i18n:new(api.get("/settings/info").defaultLanguage)
    self:trace('')
    self:trace('Netatmo weather provider')
    self:trace('User:', self.config:getUsername())
    self:updateProperty('manufacturer', 'Netatmo')
    self:updateProperty('manufacturer', 'Weather Station')
    self:run()
    self:updateView("button3_1", "text", self.i18n:get('Temperature'))
    self:updateView("button3_2", "text", self.i18n:get('Humidity')) 
    self:updateView("button3_3", "text", self.i18n:get('Wind')) 
end

function QuickApp:run()
    self:pullNetatmoData()
    local interval = self.config:getTimeoutInterval()
    if (interval > 0) then
        fibaro.setTimeout(interval, function() self:run() end)
    end
end

function QuickApp:pullNetatmoData()
    local url = '/getstationsdata'
    self:updateView("button1", "text", self.i18n:get('please-wait'))
    if string.len(self.config:getDeviceID()) > 3 then
        -- QuickApp:debug('Pulling data for device ' .. self.config:getDeviceID())
        url = url .. '?device_id=' .. self.config:getDeviceID()
    else
        -- QuickApp:debug('Pulling data')
    end
    local callback = function(response)
        local data = json.decode(response.data)
        if data.error and data.error.message then
            QuickApp:error(data.error.message)
            return false
        end

        local device = data.body.devices[1]
        local status = data.status == "ok"
        local temp = tonumber(device.dashboard_data["Temperature"])
        local humi = tonumber(device.dashboard_data["Humidity"])
        local rain = 0
        local wind = 0

        for _, module in pairs(device.modules) do
            if module.type == "NAModule2" then
                wind = tonumber(module.dashboard_data.WindStrength)
                self:updateProperty("Wind", wind)
            end
            if module.type == "NAModule3" then
                rain = tonumber(module.dashboard_data.Rain)
            end
        end

        self:updateProperty("Temperature", temp)
        self:updateProperty("Humidity", humi)
        self:updateProperty("Wind", wind)

        if wind > 30 then
            self:setCondition('windy')
        elseif rain > 0 then
            self:setCondition('rain')
        elseif humi > 70 then
            self:setCondition('cloudy')
        elseif temp < 0 then
            self:setCondition('freeze')
        elseif temp > 30 then
            self:setCondition('heat')
        else 
            self:setCondition('clear')
        end
        self:trace('Device ' .. device["_id"] .. ' updated')
        self:updateView("label1", "text", string.format(self.i18n:get('last-update'), os.date('%Y-%m-%d %H:%M:%S')))
        self:updateView("button1", "text", self.i18n:get('refresh'))

        if string.len(self.config:getDeviceID()) < 4 then
            self.config:setDeviceID(device["_id"])
        end
    end
    
    self.http:get(url, callback, nil, self.auth:getHeaders({}))
    
    return {}
end

function QuickApp:button1Event()
    self:pullNetatmoData()
end

function QuickApp:showTemperature()
    self:updateView("button3_1", "text", self:getProperty("Temperature") .. " °C")
    fibaro.setTimeout(5000, function() 
        self:updateView("button3_1", "text", self.i18n:get('Temperature')) 
    end)
end

function QuickApp:showHumidity()
    self:updateView("button3_2", "text", self:getProperty("Humidity") .. " %")
    fibaro.setTimeout(5000, function() 
        self:updateView("button3_2", "text", self.i18n:get('Humidity')) 
    end)
end

function QuickApp:showWind()
    self:updateView("button3_3", "text", self:getProperty("Wind") .. " km/h")
    fibaro.setTimeout(5000, function() 
        self:updateView("button3_3", "text", self.i18n:get('Wind')) 
    end)
end

function QuickApp:getProperty(name)
    return fibaro.getValue(plugin.mainDeviceId, name)
end




