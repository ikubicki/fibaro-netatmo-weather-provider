--[[
Configuration handler
@author ikubicki
]]
class 'Config'

function Config:new(app)
    self.app = app
    self:init()
    return self
end

function Config:getClientID()
    return self.clientID
end

function Config:getClientSecret()
    return self.clientSecret
end

function Config:getUsername()
    return self.username
end

function Config:getPassword()
    return self.password
end

function Config:getDeviceID()
    return self.deviceID
end

function Config:getAccessToken()
    return self.token
end

function Config:setAccessToken(token)
    self.app:setVariable("AccessToken", token)
    self.token = token
end

function Config:getRefreshToken()
    return self.rtoken
end

function Config:setRefreshToken(token)
    self.app:setVariable("RefreshToken", token)
    self.rtoken = rtoken
end

function Config:getTimeoutInterval()
    return tonumber(self.interval) * 60000
end

--[[
This function takes variables and sets as global variables if those are not set already.
This way, adding other devices might be optional and leaves option for users, 
what they want to add into HC3 virtual devices.
]]
function Config:init()
    self.clientID = self.app:getVariable('ClientID')
    self.clientSecret = self.app:getVariable('ClientSecret')
    self.username = self.app:getVariable('Username')
    self.password = self.app:getVariable('Password')
    self.deviceID = tostring(self.app:getVariable('DeviceID'))
    self.interval = self.app:getVariable('Interval')
    self.token = self.app:getVariable('AccessToken')
    self.rtoken = self.app:getVariable('RefreshToken')

    local storedClientID = Globals:get('netatmo_client_id')
    local storedClientSecret = Globals:get('netatmo_client_secret')
    local storedRToken = Globals:get('netatmo_rtoken', '')
    local storedInterval = Globals:get('netatmo_interval')

    -- handling clientID
    if string.len(self.clientID) < 4 and string.len(storedClientID) > 3 then
        self.app:setVariable("ClientID", storedClientID)
        self.clientID = storedClientID
    elseif (storedClientID == nil and self.clientID) then -- or storedClientID ~= self.clientID then
        Globals:set('netatmo_client_id', self.clientID)
    end
    -- handling client secret
    if string.len(self.clientSecret) < 4 and string.len(storedClientSecret) > 3 then
        self.app:setVariable("ClientSecret", storedClientSecret)
        self.clientSecret = storedClientSecret
    elseif (storedClientSecret == nil and self.clientSecret) then -- or storedClientSecret ~= self.clientSecret then
        Globals:set('netatmo_client_secret', self.clientSecret)
    end
    -- handling rtoken
    if string.len(self.rtoken) < 4 and string.len(storedRToken) > 3 then
        self.app:setVariable("RefreshToken", storedRToken)
        self.rtoken = storedRToken
    elseif (storedRToken == nil and self.rtoken) then
        Globals:set('netatmo_rtoken', self.token)
    end
    -- handling interval
    if not self.interval or self.interval == "" then
        if storedInterval and storedInterval ~= "" then
            self.app:setVariable("Interval", storedInterval)
            self.interval = storedInterval
        else
            self.interval = "5"
        end
    end
    if (storedInterval == "" and self.interval ~= "") then -- or storedInterval ~= self.interval then
        Globals:set('netatmo_interval', self.interval)
    end
end