--[[
Netatmo SDK
@author ikubicki
]]
class 'Netatmo'

function Netatmo:new(config)
    self.config = config
    self.user = config:getUsername()
    self.pass = config:getPassword()
    self.client_id = config:getClientID()
    self.client_secret = config:getClientSecret()
    self.device_id = config:getDeviceID()
    self.access_token = config:getAccessToken()
    self.token = Globals:get('netatmo_atoken', '')
    self.refresh_token = config:getRefreshToken()
    self.http = HTTPClient:new({})
    return self
end

function Netatmo:searchDevices(callback)
    local buildModule = function(module)
        return {
            id = module._id,
            name = module.module_name,
            type = module.type,
            data_type = module.data_type,
        }
    end
    local buildStation = function(data)
        local station = {
            id = data._id,
            home_id = data.home_id,
            name = data.station_name,
            modules = {},
        }
        table.insert(station.modules, buildModule(data))
        return station
    end
    local getStationsDataCallback = function(devices)
        local stations = {}
        for _, device in ipairs(devices) do
            local station = buildStation(device)
            for _, module in ipairs(device.modules) do
                table.insert(station.modules, buildModule(module))
            end
            table.insert(stations, station)
        end
        if callback ~= nil then
            callback(stations)
        end
    end
    local authCallback = function(response)
        self:getStationsData(getStationsDataCallback)
    end
    self:auth(authCallback)
end

function Netatmo:getWeatherData(callback)
    local getStationsDataCallback = function(devices)
        local device = devices[1]
        local weatherData = {
            _id = device._id,
            temp = tonumber(device.dashboard_data["Temperature"]),
            humi = tonumber(device.dashboard_data["Humidity"]),
            rain = 0,
            wind = 0,   
        }
        for _, module in pairs(device.modules) do
            if module.type == "NAModule1" then
                weatherData.temp = tonumber(module.dashboard_data.Temperature)
                weatherData.humi = tonumber(module.dashboard_data.Humidity)
            end
            if module.type == "NAModule2" then
                weatherData.wind = tonumber(module.dashboard_data.WindStrength)
            end
            if module.type == "NAModule3" then
                weatherData.rain = tonumber(module.dashboard_data.Rain)
            end
        end
        if callback ~= nil then
            callback(weatherData)
        end
    end
    local authCallback = function(response)
        self:getStationsData(getStationsDataCallback)
    end
    self:auth(authCallback)
end

function Netatmo:getStationsData(callback, attempt)
    if attempt == nil then
        attempt = 0
    end
    local fail = function(response)
        QuickApp:error('Unable to pull devices')
        QuickApp:debug(json.encode(response.data))
        Netatmo:setToken('')
        if attempt < 3 then
            attempt = attempt + 1
            fibaro.setTimeout(3000, function()
                QuickApp:debug('Netatmo:getStationData - Retry attempt #' .. attempt)
                local authCallback = function(response)
                    self:getStationsData(callback, attempt)
                end
                Netatmo:auth(authCallback)
            end)
        end
    end
    local success = function(response)
        if response.status > 299 then
            fail(response)
            return
        end
        local data = json.decode(response.data)
        if callback ~= nil then
            callback(data.body.devices)
        end
    end
    local url = 'https://api.netatmo.com/api/getstationsdata'
    if string.len(self.device_id) > 1 then
        url = url .. '?device_id=' .. self.device_id
    end
    local headers = {
        Authorization = "Bearer " .. self:getToken()
    }
    self.http:get(url, success, fail, headers)
end

function Netatmo:auth(callback)
    if string.len(self:getToken()) > 10 then
        -- QuickApp:debug('Already authenticated')
        if callback ~= nil then
            callback({})
        end
        return
    end
    if string.len(self.access_token) > 10 then
        if callback ~= nil then
            Netatmo:setToken(self.access_token)
            callback({})
        end
        return
    end
    local data = {
        ["grant_type"] = 'password',
        ["scope"] = 'read_station',
        ["client_id"] = self.client_id,
        ["client_secret"] = self.client_secret,
        ["username"] = self.user,
        ["password"] = self.pass,
    }
    if string.len(self.refresh_token) > 10 then
        data = {
            ["grant_type"] = 'refresh_token',
            ["refresh_token"] = self.refresh_token,
            ["client_id"] = self.client_id,
            ["client_secret"] = self.client_secret,
        }
    end
    local fail = function(response)
        QuickApp:error('Unable to authenticate')
        if self.access_token == self.token then
            QuickApp:error('Removing configured AccessToken')
            self.config:setAccessToken('')
        end
        Netatmo:setToken('')
    end
    local success = function(response)
        if response.status > 299 then
            fail(response)
            return
        end
        local data = json.decode(response.data)
        Netatmo:setToken(data.access_token)
        if callback ~= nil then
            callback(data)
        end
    end
    self.http:postForm('https://api.netatmo.net/oauth2/token', data, success, fail)
end

function Netatmo:setToken(token)
    self.token = token
    Globals:set('netatmo_atoken', token)
end

function Netatmo:getToken()
    if not self.token and self.access_token ~= nil then
        self.token = self.access_token
    end
    if string.len(self.token) > 10 then
        return self.token
    elseif string.len(Globals:get('netatmo_atoken', '')) > 10 then
        return Globals:get('netatmo_atoken', '')
    end
    return ""
end