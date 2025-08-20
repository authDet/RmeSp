-- ui.lua
-- Hydroxide-level RemoteSpy UI module

local UI = {}

-- Create main ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RemoteSpyUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = game:GetService("CoreGui") -- stealthy placement

-- Create floating frame
local frame = Instance.new("Frame")
frame.Name = "LogFrame"
frame.Size = UDim2.new(0.35, 0, 0.4, 0)
frame.Position = UDim2.new(0.32, 0, 0.28, 0)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0
frame.BackgroundTransparency = 0.15
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.Parent = screenGui

-- Create title label
local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, 0, 0.08, 0)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundTransparency = 1
title.Text = "RemoteSpy Log"
title.Font = Enum.Font.Code
title.TextSize = 18
title.TextColor3 = Color3.fromRGB(0, 255, 0)
title.TextXAlignment = Enum.TextXAlignment.Center
title.Parent = frame

-- Create scrollable log container
local scrollingFrame = Instance.new("ScrollingFrame")
scrollingFrame.Name = "LogScroll"
scrollingFrame.Size = UDim2.new(1, -10, 0.92, -5)
scrollingFrame.Position = UDim2.new(0, 5, 0.08, 0)
scrollingFrame.BackgroundTransparency = 1
scrollingFrame.BorderSizePixel = 0
scrollingFrame.CanvasSize = UDim2.new(0, 0, 5, 0) -- dynamic later
scrollingFrame.ScrollBarThickness = 6
scrollingFrame.Parent = frame

-- Create UIListLayout for log stacking
local listLayout = Instance.new("UIListLayout")
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 2)
listLayout.Parent = scrollingFrame

-- Function to add a log entry
function UI:AddLog(remoteName, args)
    local entry = Instance.new("TextLabel")
    entry.Size = UDim2.new(1, -10, 0, 18)
    entry.BackgroundTransparency = 1
    entry.TextColor3 = Color3.fromRGB(0, 255, 0)
    entry.TextXAlignment = Enum.TextXAlignment.Left
    entry.Font = Enum.Font.Code
    entry.TextSize = 14
    entry.Text = string.format("[%s] %s", remoteName, args)
    entry.Parent = scrollingFrame

    -- Auto-scroll to bottom
    scrollingFrame.CanvasPosition = Vector2.new(0, scrollingFrame.AbsoluteCanvasSize.Y)
end

-- Optional toggle visibility with a key (Insert by default)
local userInput = game:GetService("UserInputService")
local visible = true
userInput.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.Insert then
        visible = not visible
        frame.Visible = visible
    end
end)

-- Return reference to scrollingFrame for logger attachment
UI.TextBox = {
    Text = "",
    Parent = scrollingFrame,
    AddLog = function(_, remoteName, serializedArgs)
        UI:AddLog(remoteName, serializedArgs)
    end
}

return UI
