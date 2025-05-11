local funcs = {}
local UserInputService = game:GetService("UserInputService")

local services = {
    VirtualInputManager = Instance.new("VirtualInputManager")
}

setmetatable(services, {
    __index = function(self, idx)
        self[idx] = cloneref(game:GetService(idx))
        return self[idx]
    end,
})

function funcs.ensureCharacterLoaded(player)
    if player and player.Character and player.Character:FindFirstChild("Head") and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid")  then
        return true
    else
        return false
    end
end

function funcs.getHumanoidRootPart(player)
    if funcs.ensureCharacterLoaded(player) then
        return player.Character.HumanoidRootPart
    else
        warn("getHumanoidRootPart expected player, you gave:", tostring(player))
        return
    end
end

function funcs.doMouseClick(x, y)
    if typeof(x) ~= "number" or typeof(y) ~= "number" then
        warn("doMouseClick expects two numbers")
        return
    end
    services.VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 1)
    task.wait()
    services.VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 1)
end

function funcs.calculateDistance(x, y)
    local typeX = typeof(x)
    local typeY = typeof(y)

    local isVector3Pair = typeX == "Vector3" and typeY == "Vector3"
    local isVector2Pair = typeX == "Vector2" and typeY == "Vector2"

    if not (isVector3Pair or isVector2Pair) then
        warn("calculateDistance expects two Vector3s or two Vector2s, got:", typeX, "and", typeY)
        return
    end

    return (x - y).Magnitude
end


function funcs.addInputListener(keycode, func)
    if not keycode or not func then return end
    if typeof(keycode) ~= "EnumItem" or keycode.EnumType ~= Enum.KeyCode then return end
    if typeof(func) ~= "function" then return end
    
    return UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
        if gameProcessedEvent then return end

        if input.KeyCode == keycode then
            func()
        end
    end)
end

function funcs.addConnection(signal, func)
    if typeof(signal) ~= "RBXScriptSignal" then
        warn("addConnection expects signal, you gave:", tostring(typeof(signal)))
        return
    end
    if typeof(func) ~= "function" then
        warn("addConnection expects function, you gave:", tostring(typeof(func)))
        return
    end
    return signal:Connect(func)
end

function funcs.getClosestPlayer(position, teamName, child)
    if typeof(position) ~= "Vector3" then
        warn("getClosestPlayer expects Vector3, you gave:", tostring(typeof(position)))
        return
    end
    local plr = game:GetService("Players").LocalPlayer
    local closestPlayer
    local shortestDistance = math.huge

    for _, player in pairs(game:GetService("Players"):GetPlayers()) do
        if player and player ~= plr and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            if teamName == nil or (player.Team and player.Team.Name == teamName) then
                if child == nil or (player:FindFirstChild(child)) then
                    local distance = funcs.calculateDistance(position, player.Character.HumanoidRootPart.Position)
                    if distance < shortestDistance then
                        shortestDistance = distance
                        closestPlayer = player
                    end
                end
            end
        end
    end
    return closestPlayer
end

return funcs
