-- serializer.lua
-- Hydroxide-grade serialization for RemoteSpy

local Serializer = {}
Serializer.__index = Serializer

-- Track circular references
local seen = {}

-- Recursive serialization function
function Serializer:Serialize(value, indent)
    indent = indent or 0
    local t = typeof(value)
    local spacing = string.rep("  ", indent)
    
    if t == "Instance" then
        return string.format("Instance(%s:%s)", value.ClassName, value.Name)
    elseif t == "table" then
        if seen[value] then
            return "<Circular Reference>"
        end
        seen[value] = true
        local str = "{\n"
        for k, v in pairs(value) do
            str = str .. spacing .. "  [" .. Serializer:Serialize(k) .. "] = " .. Serializer:Serialize(v, indent + 1) .. ",\n"
        end
        str = str .. spacing .. "}"
        seen[value] = nil
        return str
    elseif t == "CFrame" then
        local pos = value.Position
        local rot = value - pos
        return string.format("CFrame(Position=%.2f,%.2f,%.2f, Rotation=%s)", pos.X,pos.Y,pos.Z,tostring(rot))
    elseif t == "Vector3" then
        return string.format("Vector3(%.2f, %.2f, %.2f)", value.X, value.Y, value.Z)
    elseif t == "Vector2" then
        return string.format("Vector2(%.2f, %.2f)", value.X, value.Y)
    elseif t == "EnumItem" then
        return "Enum." .. tostring(value.EnumType) .. "." .. tostring(value.Name)
    elseif t == "function" then
        return "<Function>"
    elseif t == "userdata" then
        return "<Userdata>"
    else
        return tostring(value)
    end
end

-- Convenience wrapper for logging
function Serializer:Dump(...)
    local args = {...}
    local output = {}
    for i, v in ipairs(args) do
        output[i] = self:Serialize(v)
    end
    return table.concat(output, ", ")
end

return Serializer
