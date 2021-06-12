local library = loadstring(game:HttpGet('https://raw.githubusercontent.com/obeseinsect/roblox/main/Ui%20Libraries/Elerium.lua'))()
local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/obeseinsect/roblox/main/Other%20Libraries/KiriotESP.lua"))()
ESP:Toggle(true); ESP.Players = false; ESP.Color = Color3.fromRGB(128,234,255)

local player = game.Players.LocalPlayer
local cam = workspace.CurrentCamera
local keys = debug.getupvalue(require(player.PlayerScripts.Client.Bullets).lm, 1)
local nevermore = require(game:GetService("ReplicatedStorage").Nevermore)

ESP:AddObjectListener(workspace.Ignore.Items, {
    Color = Color3.fromRGB(102,255,102),
    Type = 'Model',
    PrimaryPart = function(obj) while not obj:FindFirstChildWhichIsA('Part') do wait() end return obj:FindFirstChildWhichIsA('Part') end,
    IsEnabled = function(obj) return ESP[obj.Name] and player:DistanceFromCharacter(obj.PrimaryPart.Position) < itemRange end
})
ESP:AddObjectListener(workspace.Entities.Infected, {
    Color = Color3.fromRGB(255,102,102),
    Type = 'Model',
    PrimaryPart = function(obj) while not obj:FindFirstChildWhichIsA('Part') do wait() end return obj:FindFirstChildWhichIsA('Part') end,
    IsEnabled = function(obj) return ESP.Zombies and player:DistanceFromCharacter(obj.PrimaryPart.Position) < zombieRange end
})

-- game.Players.LocalPlayer.PlayerScripts.Client.Bullets
-- Generates the key needed to fire the GiveDamage remote
local getKey = function()
    local v41 = string.reverse(tostring(nevermore:GetTime() * 1 + 1337))
    local v42 = string.sub(v41, string.len(v41) - 5, string.len(v41) - 3) .. string.sub(v41, 1, string.len(v41) - 10) .. string.sub(v41, string.len(v41) - 2, string.len(v41)) .. string.sub(v41, string.len(v41) - 9, string.len(v41) - 6)
    local v40 = ""
    for v43 = 1, string.len(v42) do 
        local v44 = string.sub(v42, v43, v43)
        local v45 = v44
        if keys[v44] then
            v45 = keys[v44]
        end
        v40 = v40 .. v45
    end
    return v40
end

local pickupItems = function()
    local itemsFolder = workspace.Ignore.Items:GetChildren()
    for i = 1, #itemsFolder do local item = itemsFolder[i]
        local part = item:FindFirstChildWhichIsA('Part') 
        if part and player:DistanceFromCharacter(part.Position) < 7.5 then
            game:GetService("ReplicatedStorage").RF:InvokeServer('CheckInteract', {["Target"] = {["Mag"] = player:DistanceFromCharacter(part.Position), ["Type"] = "Item", ["CanInteract"] = true, ["Obj"] = item}})
        end
    end
end

local damageClosest = function()
    local dist, target, zombFolder = math.huge, nil, workspace.Entities.Infected:GetChildren()
    for i = 1, #zombFolder do local zomb = zombFolder[i]
        if zomb:FindFirstChild('HumanoidRootPart') then
            local _, visible = cam:WorldToViewportPoint(zomb.HumanoidRootPart.Position)            
            local newDist = player:DistanceFromCharacter(zomb.HumanoidRootPart.Position)
            if visible and newDist < dist then
                dist = newDist; target = zomb
            end
        end
    end
    if target then
	game:GetService("ReplicatedStorage").RE:FireServer('bb', 
        {["AIs"] = {[1] = {["AI"] = target, ["Velocity"] = Vector3.new(), ["Special"] = "Headshot", ["Damage"] = 100}}})
    end
end

do 
	local Window = library:AddWindow("Those Who Remain - Cameron was here", {
		main_color = Color3.fromRGB(41, 74, 122),
		min_size = Vector2.new(400, 500),
		toggle_key = Enum.KeyCode.RightShift,
		can_resize = true,
	})
    local gTab = Window:AddTab("Game")
	do
		local kAll = gTab:AddSwitch("Kill All Zombies", function(v) killAll = v end)
        gTab:AddKeybind("Kill All", function(v) killAll = not killAll kAll:Set(killAll) end, {["standard"] = Enum.KeyCode.T})
		gTab:AddSwitch("Silent Aim", function(v) silentAim = v end)
		gTab:AddSwitch("Item Aura (7m)", function(v) itemAura = v end)
	end
	local visuals = Window:AddTab("Visuals")
	do
        visuals:AddSwitch("Player ESP", function(v) ESP.Players = v end)
		visuals:AddSwitch("Zombie ESP", function(v) ESP.Zombies = v end)
        local zombRangeSlider = visuals:AddSlider("Zombie Range", function(v) zombieRange = v end, {["min"] = 0, ["max"] = 2500, ["readonly"] = false})

        local itemEsp = visuals:AddFolder("Item ESP")
        local itemRangeSlider = itemEsp:AddSlider("Range", function(v) itemRange = v end, {["min"] = 0, ["max"] = 1000, ["readonly"] = false})
        for i, v in pairs(game:GetService("ReplicatedStorage").Models["Item Pickups"]:GetChildren()) do
            itemEsp:AddSwitch(v.Name, function(e) ESP[v.Name] = e end)
        end
	end
	gTab:Show()
	library:FormatWindows()
end

local mt = getrawmetatable(game)
local old = mt.__namecall
setreadonly(mt, false)
mt.__namecall = newcclosure(function(self, ...)
    local args = {...}
    if silentAim and args[1] == 'GlobalReplicate' and args[2].RecoilScale then 
        damageClosest()
        return old(self, ...)
    end
    return old(self, ...)
end)

while wait() do
    if killAll then damageClosest() end
    if itemAura then pickupItems() end
end
