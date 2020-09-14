--[[
Netatmo authentication class
@author ikubicki
]]
class 'Auth'

function Auth:new(config)
    self.config = config
    self:init()
    return self
end

function Auth:getHeaders(headers)
    local token = self:getToken()
    if string.len(token) > 0 then
        headers['Authorization'] = 'Bearer ' .. token
    end
    return headers
end

function Auth:getToken()
    local cache = Globals:get('netatmo_token')
    if cache then
        return cache.token
    end
    return ""
end

function Auth:init()
    local timestamp = os.time(os.date("!*t"))
    local cache = Globals:get('netatmo_token')
    if cache and cache.token and cache.expire > timestamp and cache.clientID == self.config:getClientID() then
        return true
    end

    local http = HTTPClient:new()
    local data = {
        ["grant_type"] = 'password',
        ["scope"] = 'read_station',
        ["client_id"] = self.config:getClientID(),
        ["client_secret"] = self.config:getClientSecret(),
        ["username"] = self.config:getUsername(),
        ["password"] = self.config:getPassword(),
    }
    QuickApp:debug(json.encode(data))
    local callback = function(response)
        local data = json.decode(response.data)
        Globals:set('netatmo_token', {
            clientID = self.config:getClientID(),
            expire = timestamp + data.expires_in - 1000,
            token = data.access_token,
        })
    end
    http:postForm('https://api.netatmo.net/oauth2/token', data, callback)
    fibaro.setTimeout(300000, function() self:init() end)
end