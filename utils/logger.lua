-- remotes.lua
-- Hydroxide-level Remote hooking module

local RemoteHooks = {}
RemoteHooks.__index = RemoteHooks

-- Dependencies
local Logger = require(script.Parent.utils.logger)
local Serializer = require(script.Parent.utils.serializer)

-- Table to track hooked remotes to avoid duplicate hooks
RemoteHooks.HookedRemotes = {}

-- Internal function: hook a single remote
function RemoteHooks:Hook(remote)
    if self.HookedRemotes[remote] then
        return -- already hooked
    end
    self.HookedRemotes[remote] = true

    if remote:IsA("RemoteEvent") then
        local oldFireServer = remote.FireServer
        remote.FireServer = newcclosure(function(self, ...)
            Logger:Log(remote, {...})
            return oldFireServer(self, ...)
        end)
    elseif remote:IsA("RemoteFunction") then
        local oldInvokeServer = remote.InvokeServer
        remote.InvokeServer = newcclosure(function(self, ...)
            Logger:Log(remote, {...})
            return oldInvokeServer(self, ...)
        end)
    end
end

-- Discover and hook all current remotes in the game
function RemoteHooks:HookAll()
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            self:Hook(obj)
        end
    end
end

-- Dynamic runtime hooking: automatically hook new remotes
function RemoteHooks:Listen()
    game.DescendantAdded:Connect(function(obj)
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            self:Hook(obj)
        end
    end)
end

-- Hook remotes with optional filter function
-- filterFunc(remote) -> boolean
function RemoteHooks:HookFiltered(filterFunc)
    for _, obj in pairs(game:GetDescendants()) do
        if (obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction")) and filterFunc(obj) then
            self:Hook(obj)
        end
    end
end

-- Initialize the module with auto-hook + listener
function RemoteHooks:Init()
    Logger:Log({Name="RemoteSpy"}, {"Initializing Remote Hooks..."})
    self:HookAll()
    self:Listen()
    Logger:Log({Name="RemoteSpy"}, {"Remote Hooks active. All RemoteEvents/Functions monitored."})
end

return RemoteHooks
