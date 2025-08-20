-- metamethods.lua
-- Hydroxide-level Metamethod Hooking

local MetamethodHooks = {}
MetamethodHooks.__index = MetamethodHooks

-- Dependencies
local Logger = require(script.Parent.utils.logger)
local Serializer = require(script.Parent.utils.serializer)

-- Track original metamethods
local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
local oldIndex = mt.__index
local oldNewindex = mt.__newindex
setreadonly(mt, false) -- unlock metamethods for hooking

-- Utility: check if caller is executor script
local function isCallerScript()
    return checkcaller()
end

-- Hook __namecall
mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}

    -- Intercept RemoteEvents and RemoteFunctions
    if not isCallerScript() and (self:IsA("RemoteEvent") or self:IsA("RemoteFunction")) then
        Logger:Log(self, args, method)
    end

    return oldNamecall(self, ...)
end)

-- Hook __index
mt.__index = newcclosure(function(self, key)
    local result = oldIndex(self, key)

    -- Optional: log sensitive property accesses
    if not isCallerScript() and (typeof(self) == "Instance") then
        local protectedProperties = {"Parent","Player","Humanoid"}
        for _, prop in pairs(protectedProperties) do
            if key == prop then
                Logger:Log(self, {key, result}, "__index")
            end
        end
    end

    return result
end)

-- Hook __newindex (optional)
mt.__newindex = newcclosure(function(self, key, value)
    -- Monitor assignments to critical objects
    if not isCallerScript() and (typeof(self) == "Instance") then
        local sensitiveObjects = {"RemoteEvent","RemoteFunction","BoolValue"}
        for _, t in pairs(sensitiveObjects) do
            if self:IsA(t) then
                Logger:Log(self, {key, value}, "__newindex")
            end
        end
    end
    return oldNewindex(self, key, value)
end)

-- Restore read-only state
setreadonly(mt, true)

function MetamethodHooks:Init()
    Logger:Log({Name="RemoteSpy"}, {"Metamethod Hooks Active"})
end

return MetamethodHooks
