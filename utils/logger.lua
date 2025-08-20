-- logger.lua
-- Hydroxide-level RemoteSpy logging engine

local Serializer = require(script.Parent.serializer)
local Logger = {}
Logger.__index = Logger

-- Internal log storage
Logger.logs = {}

-- Optional UI hook (inject via ui.lua)
Logger.UI = nil

-- Core log function
function Logger:Log(remoteName, ...)
    local serializedArgs = Serializer:Dump(...)
    local entry = {
        Remote = remoteName,
        Timestamp = os.time(),
        Args = serializedArgs
    }

    -- Store internally
    table.insert(self.logs, entry)

    -- Print to console
    print(string.format("[%s] %s -> %s", os.date("%X", entry.Timestamp), remoteName, serializedArgs))

    -- Update UI if hooked
    if self.UI and type(self.UI.UpdateLog) == "function" then
        self.UI:UpdateLog(entry)
    end
end

-- Retrieve all logs (deep copy for safety)
function Logger:GetLogs()
    local copy = {}
    for i, v in ipairs(self.logs) do
        copy[i] = {
            Remote = v.Remote,
            Timestamp = v.Timestamp,
            Args = v.Args
        }
    end
    return copy
end

-- Clear logs
function Logger:Clear()
    self.logs = {}
    print("[Logger] Cleared all logs.")
    if self.UI and type(self.UI.Clear) == "function" then
        self.UI:Clear()
    end
end

-- Filter logs by remote name pattern
function Logger:FilterByName(pattern)
    local filtered = {}
    for _, entry in ipairs(self.logs) do
        if string.find(entry.Remote, pattern) then
            table.insert(filtered, entry)
        end
    end
    return filtered
end

return Logger
