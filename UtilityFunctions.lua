local utils = {}

function utils.ensureCharacterLoaded(player)
    if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Head") then
        return true
    else
        return false
    end
end

function utils.getHumanoidRootPart(player)
    if utils.ensureCharacterLoaded(player) then
        return player.Character.HumanoidRootPart
    else
        return
    end
end

function utils.addConnection(signal, func)
    if not signal or not func then return end
    if typeof(signal) ~= "RBXScriptSignal" or typeof(func) ~= "function" then return end

    return signal:Connect(func)
end

return utils
