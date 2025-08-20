-- core.lua
-- Core Hydroxide-level RemoteSpy engine
-- This is the executor-loaded brain

local Core = {}

-- Require utility modules
local Serializer = require(script.Parent.utils.serializer)
local Logger = require(script.Parent.utils.logger)
local RemoteHooks = require(script.Parent.hooks.remotes)
local MetaHooks = require(script.Parent.hooks.metamethods)
local UI = require(script.Parent.ui) -- optional, can be nil

-- Attach UI to logger if available
if UI then
    Logger:AttachUI(UI)
end

-- Initialize a table to keep track of hooked remotes
Core.HookedRemotes = {}

-- Internal function: hook a single remote
function Core:HookRemote(remote)
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

-- Discover and hook all remotes dynamically
function Core:HookAllRemotes()
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            self:HookRemote(obj)
        end
    end
end

-- Metamethod hooking: intercept all dynamic remote calls
function Core:HookMetamethods()
    local mt = getrawmetatable(game)
    setreadonly(mt, false)

    local oldNamecall = mt.__namecall

    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if method == "FireServer" or method == "InvokeServer" then
            Logger:Log(self, {...})
        end
        return oldNamecall(self, ...)
    end)

    setreadonly(mt, true)
end

-- Dynamic hooking for newly added remotes (listens for runtime instances)
function Core:ListenForNewRemotes()
    game.DescendantAdded:Connect(function(obj)
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            self:HookRemote(obj)
        end
    end)
end

-- Initialize Core
function Core:Init()
    Logger:Log({Name="RemoteSpy"}, {"Core initialization started."})
    self:HookAllRemotes()
    self:HookMetamethods()
    self:ListenForNewRemotes()
    Logger:Log({Name="RemoteSpy"}, {"All core hooks are active. Hydroxide-level ready."})
end

return Core
