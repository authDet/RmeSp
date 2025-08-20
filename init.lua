
-- init.lua
-- Hydroxide-level Remote Spy by Rebel Genius Framework
-- Executor ready: loadstring(game:HttpGet("url"))()

-- Module loader simulation (for inline embedding)
local function requireModule(modName)
    local modules = {
        ["hooks.remotes"] = [[
            local RemoteSpy = {}
            function RemoteSpy:HookRemotes(logger)
                for _, obj in pairs(game:GetDescendants()) do
                    if obj:IsA("RemoteEvent") then
                        local oldFireServer = obj.FireServer
                        obj.FireServer = newcclosure(function(self, ...)
                            logger:Log(self, {...})
                            return oldFireServer(self, ...)
                        end)
                    elseif obj:IsA("RemoteFunction") then
                        local oldInvokeServer = obj.InvokeServer
                        obj.InvokeServer = newcclosure(function(self, ...)
                            logger:Log(self, {...})
                            return oldInvokeServer(self, ...)
                        end)
                    end
                end
            end
            return RemoteSpy
        ]],
        ["hooks.metamethods"] = [[
            local mt = getrawmetatable(game)
            setreadonly(mt,false)
            local oldNamecall = mt.__namecall
            local function HookNamecall(logger)
                mt.__namecall = newcclosure(function(self,...)
                    local method = getnamecallmethod()
                    if method=="FireServer" or method=="InvokeServer" then
                        logger:Log(self,{...})
                    end
                    return oldNamecall(self,...)
                end)
            end
            HookNamecall = HookNamecall
            setreadonly(mt,true)
            return {HookNamecall=HookNamecall}
        ]],
        ["utils.serializer"] = [[
            local Serializer = {}
            function Serializer:Serialize(tbl)
                local str = "{"
                for k,v in pairs(tbl) do
                    local key = tostring(k)
                    local val = type(v)=="table" and self:Serialize(v) or tostring(v)
                    str = str..key.."="..val..","
                end
                return str.."}"
            end
            return Serializer
        ]],
        ["utils.logger"] = [[
            local Serializer = requireModule("utils.serializer")
            local logger = {}
            function logger:Log(remote,args)
                print("[RemoteSpy] "..remote.Name.." | "..Serializer:Serialize(args))
                if self.TextBox then
                    self.TextBox.Text = self.TextBox.Text..remote.Name.." | "..Serializer:Serialize(args).."\n"
                end
            end
            function logger:AttachUI(textbox)
                self.TextBox = textbox
            end
            return logger
        ]],
        ["ui"] = [[
            local ScreenGui = Instance.new("ScreenGui")
            ScreenGui.Name = "RemoteSpyUI"
            ScreenGui.Parent = game.CoreGui
            local Frame = Instance.new("Frame",ScreenGui)
            Frame.Size = UDim2.new(0.3,0,0.4,0)
            Frame.Position = UDim2.new(0.35,0,0.3,0)
            Frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
            Frame.BorderSizePixel = 0
            local TextBox = Instance.new("TextBox",Frame)
            TextBox.Size = UDim2.new(1,0,1,0)
            TextBox.ClearTextOnFocus = false
            TextBox.MultiLine = true
            TextBox.Text = "[RemoteSpy Initialized]\\n"
            TextBox.TextColor3 = Color3.fromRGB(0,255,0)
            TextBox.BackgroundTransparency = 1
            return TextBox
        ]]
    }

    return loadstring(modules[modName])()
end

-- Initialize Logger & UI
local Logger = requireModule("utils.logger")
local TextBox = requireModule("ui")
Logger:AttachUI(TextBox)

-- Hook Remotes
local RemoteHooks = requireModule("hooks.remotes")
RemoteHooks:HookRemotes(Logger)

-- Hook Metamethods
local MetaHooks = requireModule("hooks.metamethods")
MetaHooks.HookNamecall(Logger)

-- Confirmation Message
Logger:Log({Name="RemoteSpy"}, {"All hooks successfully initialized. Hydroxide-level ready."})
