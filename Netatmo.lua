--[[
Netatmo SDK
@author ikubicki
]]
class 'Netatmo'

function Netatmo:new(config)
    self.config = config
    self.client_id = config:getClientID()
    self.client_secret = config:getClientSecret()
    self.device_id = config:getDeviceID()
    self.access_token = config:getAccessToken()
    self.refresh_token = config:getRefreshToken()
    self.http = HTTPClient:new({
        baseUrl = "https://api.netatmo.com"
    })
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
        if response.error ~= nil then
            callback(response)
            return
        end
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
        if response.error ~= nil then
            callback(response)
            return
        end
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
        -- QuickApp:debug(json.encode(response.data))
        if response.status == 400 then
            return
        end
        if response.status == 401 then
            QuickApp:debug('Unauthorized response - need to drop the access token')
            self:setAccessToken('')
            return
        end
        if attempt < 3 then
            attempt = attempt + 1
            fibaro.setTimeout(3000, function()
                QuickApp:debug('Netatmo:getStationData - Retry attempt #' .. attempt)
                local authCallback = function(response)
                    self:getStationsData(callback, attempt)
                end
                self:auth(authCallback)
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
    local url = '/api/getstationsdata'
    if string.len(self.device_id) > 1 then
        url = url .. '?device_id=' .. self.device_id
    end
    local headers = {
        Authorization = "Bearer " .. self:getAccessToken()
    }
    self.http:get(url, success, fail, headers)
end

function Netatmo:auth(callback)
    if string.len(self:getAccessToken()) > 10 then
        -- QuickApp:debug('Already authenticated')
        if callback ~= nil then
            callback({})
        end
        return
    end
    local data = {
        ["grant_type"] = 'refresh_token',
        ["refresh_token"] = self.refresh_token,
        ["client_id"] = self.client_id,
        ["client_secret"] = self.client_secret,
    }
    local fail = function(response)
        QuickApp:error('Unable to authenticate')
        QuickApp:error('Error code: ' .. response.status)
        if self.access_token ~= "" and response.status == 401 then
            self:setAccessToken('')
        end
        if callback ~= nil then
            callback(response)
        end
    end
    if string.len(self.refresh_token) < 10 then
        QuickApp:error('No refresh token available. Cannot authenticate the device.')
        fail({
            error = "No refresh token available. Cannot authenticate the device.",
            status = 400
        })
        return
    end
    local success = function(response)
        if response.status > 299 or response.status < 200 then
            fail({
                error = "Unable to authenticate",
                status = response.status
            })
            return
        end
        local data = json.decode(response.data)
        self:setAccessToken(data.access_token)
        self:setRefreshToken(data.refresh_token)
        if callback ~= nil then
            callback({})
        end
    end
    self.http:postForm('/oauth2/token', data, success, fail)
end

function Netatmo:getAccessToken()
    if self.access_token ~= "" then
        return self.access_token
    end
    return self.config:getAccessToken()
end

function Netatmo:setAccessToken(access_token)
    QuickApp:debug("Setting Access Token to " .. access_token)
    self.access_token = access_token
    self.config:setAccessToken(access_token)
end

function Netatmo:setRefreshToken(refresh_token)
    self.refresh_token = refresh_token
    self.config:setRefreshToken(refresh_token)
end
