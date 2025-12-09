-- made with claude.ai 😇

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local RepStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local infiniteStaminaEnabled = false
local killAuraEnabled = false
local hitboxExtenderEnabled = false
local hitboxSize = 15
local visualHitboxEnabled = false
local visualHitboxSize = 15
local oneHitEnabled = false

-- ========== LOAD OBSIDIAN LIBRARY ==========
local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local Options = Library.Options
local Toggles = Library.Toggles

local Window = Library:CreateWindow({
	Title = "KALI HUB",
	Footer = "version: 1.0",
	NotifySide = "Right",
	ShowCustomCursor = false,
})

local Tabs = {
	Main = Window:AddTab("Main", "house"),
	["UI Settings"] = Window:AddTab("UI Settings", "settings"),
}

-- ========== VISUAL HITBOX EXTENDER ==========
local visualHitboxParts = {}

local function clearVisualHitboxes()
	for _, part in pairs(visualHitboxParts) do
		if part and part.Parent then
			part:Destroy()
		end
	end
	visualHitboxParts = {}
end

local function createVisualHitbox(originalPart)
	if not originalPart:IsA("BasePart") then return end
	
	local hitbox = Instance.new("Part")
	hitbox.Name = "VisualHitbox"
	hitbox.Size = originalPart.Size * visualHitboxSize
	hitbox.CFrame = originalPart.CFrame
	hitbox.Transparency = 1
	hitbox.CanCollide = false
	hitbox.CanTouch = true
	hitbox.CanQuery = true
	hitbox.Massless = true
	hitbox.Anchored = false
	
	local weld = Instance.new("WeldConstraint")
	weld.Part0 = originalPart
	weld.Part1 = hitbox
	weld.Parent = hitbox
	
	hitbox.Parent = originalPart.Parent
	
	return hitbox
end

local function updateVisualHitboxes()
	clearVisualHitboxes()
	
	if not visualHitboxEnabled then return end
	
	for _, obj in pairs(workspace:GetChildren()) do
		if obj:IsA("Model") and obj.Name:find("_") then
			local bot = obj:FindFirstChild("Bot")
			if bot and bot:IsA("Model") then
				for _, part in pairs(bot:GetDescendants()) do
					if part:IsA("BasePart") and (part.Name:find("Arm") or part.Name:find("Hand") or part.Name:find("Leg") or part.Name:find("Foot") or part.Name:find("Torso") or part.Name == "Head") then
						local hitbox = createVisualHitbox(part)
						if hitbox then
							table.insert(visualHitboxParts, hitbox)
						end
					end
				end
			end
		end
	end
end

task.spawn(function()
	while true do
		task.wait(2)
		if visualHitboxEnabled then
			updateVisualHitboxes()
		end
	end
end)

if string.split(identifyexecutor() or "None", " ")[1] ~= "Xeno" then
local HitboxModule = require(RepStorage:WaitForChild("HitboxModule"))

local oldSetHitboxSize = HitboxModule.SetHitboxSize
HitboxModule.SetHitboxSize = function(self, size)
	if hitboxExtenderEnabled then
		local newSize = (tonumber(size) or 0.6) * hitboxSize
		return oldSetHitboxSize(self, newSize)
	end
	return oldSetHitboxSize(self, size)
end

local oldStart = HitboxModule.Start
HitboxModule.Start = function(self, character, side)
	if hitboxExtenderEnabled then
		local currentThickness = HitboxModule.Settings.thickness
		HitboxModule.Settings.thickness = currentThickness * hitboxSize
	end
	
	return oldStart(self, character, side)
end
end

-- ========== ONE HIT ==========
local input = require(RepStorage:WaitForChild("RobotInput"))
local origGetConfig = input.GetConfigForBot

local function modifyDamage(cfg)
	local dmg = 9e9
	
	for key in pairs(cfg.attackDMG) do
		cfg.attackDMG[key] = dmg
	end
	
	for key in pairs(cfg.attackForwardDMG) do
		cfg.attackForwardDMG[key] = dmg
	end
	
	for key in pairs(cfg.attackRECDMG) do
		cfg.attackRECDMG[key] = dmg
	end
	
	for key in pairs(cfg.attackForwardRECDMG) do
		cfg.attackForwardRECDMG[key] = dmg
	end
end

input.GetConfigForBot = function(bot)
	local cfg = origGetConfig(bot)
	if oneHitEnabled then
		modifyDamage(cfg)
	end
	return cfg
end

-- ========== INFINITE STAMINA ==========
local function setupInfinitePower(char)
	if not char then return end
	
	print("Setting up infinite power for:", char.Name)
	
	char:WaitForChild("Humanoid", 10)
	task.wait(1)
	
	local connection
	connection = RunService.Heartbeat:Connect(function()
		if not infiniteStaminaEnabled then return end
		
		if not char or not char.Parent then
			connection:Disconnect()
			return
		end
		
		pcall(function()
			char:SetAttribute("PowerCharge", 100)
			char:SetAttribute("Power", 100)
			char:SetAttribute("Charge", 100)
			char:SetAttribute("RobotPower", 100)
			char:SetAttribute("RobotCharge", 100)
			char:SetAttribute("Energy", 100)
			char:SetAttribute("RobotEnergy", 100)
		end)
		
		local powerValue = char:FindFirstChild("PowerCharge") or char:FindFirstChild("Power") or char:FindFirstChild("Charge")
		if powerValue and (powerValue:IsA("NumberValue") or powerValue:IsA("IntValue")) then
			pcall(function()
				powerValue.Value = 100
			end)
		end
		
		local hum = char:FindFirstChild("Humanoid")
		if hum then
			pcall(function()
				hum:SetAttribute("PowerCharge", 100)
				hum:SetAttribute("Power", 100)
				hum:SetAttribute("Charge", 100)
			end)
		end
	end)
end

if LocalPlayer.Character then
	setupInfinitePower(LocalPlayer.Character)
end

LocalPlayer.CharacterAdded:Connect(function(char)
	setupInfinitePower(char)
end)

if string.split(identifyexecutor() or "None", " ")[1] ~= "Xeno" then
-- ========== KILL AURA (CONSTANT SPAM) ==========
local killAuraActive = false

local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
	local method = getnamecallmethod()
	local args = {...}
	
	if method == "FireServer" and self.Name == "HitReport" and killAuraEnabled and not killAuraActive then
		killAuraActive = true
		
		task.spawn(function()
			while killAuraEnabled do
				pcall(function()
					RepStorage.Remotes.HitReport:FireServer(unpack(args))
				end)
				task.wait(0.05)
			end
			killAuraActive = false
		end)
	end
	
	if method == "FireServer" and infiniteStaminaEnabled then
		local remoteName = self.Name:lower()
		if remoteName:find("power") or remoteName:find("charge") or remoteName:find("drain") or remoteName:find("stamina") then
			for _, arg in pairs(args) do
				if type(arg) == "number" and arg < 100 then
					return
				end
			end
		end
	end
	
	return oldNamecall(self, ...)
end)
end

-- ========== UI ==========
local PlayerGroup = Tabs.Main:AddLeftGroupbox("Player", "user")

PlayerGroup:AddToggle("InfiniteStamina", {
	Text = "Infinite Stamina",
	Tooltip = "Keeps robot power charge at 100",
	Default = false,
	Callback = function(Value)
		infiniteStaminaEnabled = Value
	end,
})

local CombatGroup = Tabs.Main:AddLeftGroupbox("Combat", "sword")

CombatGroup:AddToggle("OneHit", {
	Text = "One Hit",
	Tooltip = "Makes all attacks deal 9 billion damage",
	Default = false,
	Callback = function(Value)
		oneHitEnabled = Value
	end,
})

CombatGroup:AddToggle("HitboxExtender", {
	Text = "Hitbox Extender",
	Tooltip = "Extends your attack hitbox",
	Default = false,
	Callback = function(Value)
		hitboxExtenderEnabled = Value
		if not Value then
			HitboxModule.Settings.thickness = 0.6
		end
	end,
})

if string.split(identifyexecutor() or "None", " ")[1] ~= "Xeno" then
CombatGroup:AddToggle("KillAura", {
	Text = "Kill Aura (Hit First)",
	Tooltip = "Spams attack after first hit",
	Default = false,
	Callback = function(Value)
		killAuraEnabled = Value
		if not Value and killAuraCoroutine then
			task.cancel(killAuraCoroutine)
			killAuraCoroutine = nil
		end
	end,
})
end

local MenuGroup = Tabs["UI Settings"]:AddLeftGroupbox("Menu", "wrench")

MenuGroup:AddToggle("KeybindMenuOpen", {
	Default = Library.KeybindFrame.Visible,
	Text = "Open Keybind Menu",
	Callback = function(value)
		Library.KeybindFrame.Visible = value
	end,
})

MenuGroup:AddToggle("ShowCustomCursor", {
	Text = "Custom Cursor",
	Default = false,
	Callback = function(Value)
		Library.ShowCustomCursor = Value
	end,
})

MenuGroup:AddDivider()
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "LeftControl", NoUI = true, Text = "Menu keybind" })

MenuGroup:AddButton("Unload", function()
	clearVisualHitboxes()
	killAuraEnabled = false
	if killAuraCoroutine then
		task.cancel(killAuraCoroutine)
	end
	Library:Unload()
end)

Library.ToggleKeybind = Options.MenuKeybind

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })

ThemeManager:SetFolder("KaliHub")
SaveManager:SetFolder("KaliHub/RobotGame")

SaveManager:BuildConfigSection(Tabs["UI Settings"])
ThemeManager:ApplyToTab(Tabs["UI Settings"])

SaveManager:LoadAutoloadConfig()

print("KALI HUB loaded!")
