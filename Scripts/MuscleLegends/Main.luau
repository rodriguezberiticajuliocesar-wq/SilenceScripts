--[[
    HonenxWhite - Ml Main
    by Honen @𝔥𝔬𝔫𝔢𝔶
]]

local services = {
	Players = game:GetService("Players"),
	ReplicatedStorage = game:GetService("ReplicatedStorage"),
	VirtualUser = game:GetService("VirtualUser"),
	Workspace = workspace,
	Lighting = game:GetService("Lighting"),
	UserInputService = game:GetService("UserInputService"),
	VirtualInputManager = game:GetService("VirtualInputManager"),
	RunService = game:GetService("RunService"),
	CollectionService = game:GetService("CollectionService"),
	HttpService = game:GetService("HttpService")
}

local utils = {}
utils.runtime = {}

for _, connection in ipairs(_G.HonenxWhiteMainConnections or {}) do
	pcall(function() connection:Disconnect() end)
end
_G.HonenxWhiteMainConnections = {}
_G.HonenxWhiteMainGeneration = (_G.HonenxWhiteMainGeneration or 0) + 1
utils.Generation = _G.HonenxWhiteMainGeneration

function utils.isCurrent()
	return utils.Generation == _G.HonenxWhiteMainGeneration
end

function utils.connect(signal, callback, connection)
	connection = signal:Connect(callback)
	table.insert(_G.HonenxWhiteMainConnections, connection)
	return connection
end

utils.playerData = {
	Player = services.Players.LocalPlayer,
	DisplayName = services.Players.LocalPlayer.DisplayName,
	Character = services.Players.LocalPlayer.Character,
	Humanoid = nil,
	Camera = services.Workspace.CurrentCamera,
	Backpack = services.Players.LocalPlayer:WaitForChild("Backpack")
}

utils.playerData.Humanoid = utils.playerData.Character and utils.playerData.Character:FindFirstChildOfClass("Humanoid")

utils.remotes = {
	ChangeSpeedSize = services.ReplicatedStorage.rEvents.changeSpeedSizeRemote,
	MuscleEvent = utils.playerData.Player.muscleEvent
}

function utils.formatNumber(n)
	if n >= 1e18 then return string.format("%.1fqi", n / 1e18)
	elseif n >= 1e15 then return string.format("%.1fqa", n / 1e15)
	elseif n >= 1e12 then return string.format("%.1ft", n / 1e12)
	elseif n >= 1e9 then return string.format("%.1fb", n / 1e9)
	elseif n >= 1e6 then return string.format("%.1fm", n / 1e6)
	elseif n >= 1e3 then return string.format("%.1fk", n / 1e3)
	else return tostring(n) end
end

function utils.formatWithCommas(n, formatted, separatorCount)
	formatted = tostring(math.floor(n))
	while true do
		formatted, separatorCount = formatted:gsub("^(-?%d+)(%d%d%d)", "%1.%2")
		if separatorCount == 0 then break end
	end
	return formatted
end

function utils.greeting(hour)
	hour = hour or os.date("*t").hour
	if hour >= 6 and hour < 12 then return "Good Morning!"
	elseif hour >= 12 and hour < 13 then return "Good Noon!"
	elseif hour >= 13 and hour < 19 then return "Good Afternoon!"
	elseif hour >= 19 and hour < 22 then return "Good Evening!"
	else return "Good Night!" end
end

function utils.createPrivacyRedactor(player, key)
	local redactor = {
		NameEnabled = false,
		StatsEnabled = false,
		OriginalNames = setmetatable({}, {__mode = "k"}),
		OriginalStats = setmetatable({}, {__mode = "k"}),
		NameGuis = setmetatable({}, {__mode = "k"}),
	}
	_G.HonenxWhitePrivacyGenerations = _G.HonenxWhitePrivacyGenerations or {}
	_G.HonenxWhitePrivacyGenerations[key] = (_G.HonenxWhitePrivacyGenerations[key] or 0) + 1
	local generation = _G.HonenxWhitePrivacyGenerations[key]

	local function containsName(text)
		return string.find(text, player.Name, 1, true)
			or string.find(text, player.DisplayName, 1, true)
	end

	local function redact(storage, object, replacement)
		local saved = storage[object]
		if not saved or object.Text ~= saved.Redacted then
			saved = {Original = object.Text}
			storage[object] = saved
		end
		saved.Redacted = replacement
		object.Text = replacement
	end

	local function restore(storage, stillDisabled)
		local savedObjects = {}
		for object, saved in pairs(storage) do
			table.insert(savedObjects, {Object = object, Text = saved.Original})
		end
		table.clear(storage)
		task.spawn(function()
			for _ = 1, 5 do
				if not stillDisabled() then return end
				for _, saved in ipairs(savedObjects) do
					if saved.Object.Parent then saved.Object.Text = saved.Text end
				end
				task.wait(0.1)
			end
		end)
	end

	local function setNameGuiHidden(nameGui)
		if nameGui and nameGui:IsA("BillboardGui") then
			if redactor.NameGuis[nameGui] == nil then redactor.NameGuis[nameGui] = nameGui.Enabled end
			nameGui.Enabled = false
		end
	end

	local function showNameGui(nameGui)
		if not nameGui or not nameGui:IsA("BillboardGui") then return end
		nameGui.Enabled = true
	end

	local function isTopStat(object)
		if not string.find(object.Text, "%d") or object.AbsolutePosition.Y > 150 then return false end
		local current = object
		for _ = 1, 6 do
			if not current then break end
			local name = string.lower(current.Name)
			if string.find(name, "strength", 1, true) or string.find(name, "gem", 1, true) then return true end
			current = current.Parent
		end
		return false
	end

	local function redactLeaderboardStats(nameObject, coreGui)
		local nameCenterY = nameObject.AbsolutePosition.Y + nameObject.AbsoluteSize.Y / 2
		local minimumX = nameObject.AbsolutePosition.X + nameObject.AbsoluteSize.X * 0.5
		local tolerance = math.max(6, nameObject.AbsoluteSize.Y * 0.5)
		for _, valueObject in ipairs(coreGui:GetDescendants()) do
			if (valueObject:IsA("TextLabel") or valueObject:IsA("TextButton"))
				and valueObject ~= nameObject and string.find(valueObject.Text, "%d") then
				local valueCenterY = valueObject.AbsolutePosition.Y + valueObject.AbsoluteSize.Y / 2
				if valueObject.AbsolutePosition.X >= minimumX
					and math.abs(valueCenterY - nameCenterY) <= tolerance then
					redact(redactor.OriginalStats, valueObject, "####")
				end
			end
		end
	end

	local function update()
		local character = player.Character
		if redactor.NameEnabled and character then
			setNameGuiHidden(character:FindFirstChild("nameGui", true))
		end
		if redactor.NameEnabled then
			local namedCharacter = workspace:FindFirstChild("HenneZocktTV")
			local head = namedCharacter and namedCharacter:FindFirstChild("Head")
			setNameGuiHidden(head and head:FindFirstChild("nameGui"))
		end
		if redactor.StatsEnabled then
			for _, object in ipairs(player:WaitForChild("PlayerGui"):GetDescendants()) do
				if (object:IsA("TextLabel") or object:IsA("TextButton")) and isTopStat(object) then
					redact(redactor.OriginalStats, object, "####")
				end
			end
		end

		local coreGui = game:GetService("CoreGui")
		for _, object in ipairs(coreGui:GetDescendants()) do
			if object:IsA("TextLabel") or object:IsA("TextButton") then
				local saved = redactor.OriginalNames[object]
				if containsName(object.Text) or (saved and containsName(saved.Original)) then
					if redactor.StatsEnabled then redactLeaderboardStats(object, coreGui) end
					if redactor.NameEnabled then redact(redactor.OriginalNames, object, "########") end
				end
			end
		end
	end

	function redactor:SetNameEnabled(enabled)
		self.NameEnabled = enabled
		if not enabled then
			restore(self.OriginalNames, function() return not self.NameEnabled end)
			local savedNameGuis = {}
			for nameGui in pairs(self.NameGuis) do table.insert(savedNameGuis, nameGui) end
			table.clear(self.NameGuis)
			task.spawn(function()
				for _ = 1, 10 do
					if self.NameEnabled then return end
					local currentCharacter = player.Character
					local currentNameGui = currentCharacter and currentCharacter:FindFirstChild("nameGui", true)
					showNameGui(currentNameGui)
					local namedCharacter = workspace:FindFirstChild("HenneZocktTV")
					local head = namedCharacter and namedCharacter:FindFirstChild("Head")
					local explicitNameGui = head and head:FindFirstChild("nameGui")
					showNameGui(explicitNameGui)
					for _, nameGui in ipairs(savedNameGuis) do
						if nameGui.Parent then showNameGui(nameGui) end
					end
					task.wait(0.1)
				end
			end)
		end
		pcall(update)
	end

	function redactor:SetStatsEnabled(enabled)
		self.StatsEnabled = enabled
		if not enabled then restore(self.OriginalStats, function() return not self.StatsEnabled end) end
		pcall(update)
	end

	task.spawn(function()
		while _G.HonenxWhitePrivacyGenerations[key] == generation do
			if redactor.NameEnabled or redactor.StatsEnabled then pcall(update) end
			task.wait(1)
		end
	end)
	return redactor
end

function utils.toggleSelection(selected, selectedList, value, label, prefix)
	if selected[value] then
		selected[value] = nil
		for index = #selectedList, 1, -1 do
			if selectedList[index] == value then table.remove(selectedList, index) end
		end
	else
		selected[value] = true
		table.insert(selectedList, value)
	end
	label.Text = prefix .. (#selectedList > 0 and table.concat(selectedList, ", ") or "None")
end

function utils.deleteAds()
	for _, portal in pairs(game:GetDescendants()) do
		if portal.Name == "RobloxForwardPortals" then
			portal:Destroy()
		end
	end
	if _G.ads then
		_G.ads:Disconnect()
	end

	_G.ads = game.DescendantAdded:Connect(function(descendant)
		if descendant.Name == "RobloxForwardPortals" then
			descendant:Destroy()
		end
	end)
end
utils.deleteAds()

utils.library = loadstring(game:HttpGet("https://raw.githubusercontent.com/rodriguezberiticajuliocesar-wq/SilenceScripts/refs/heads/main/libraries/eleriumv2.luau?cache=" .. tostring(os.time()), true))()

utils.HonenxWhite = utils.library:AddWindow("HonenxWhite | Main - " .. utils.greeting(), {
	main_color = Color3.fromRGB(0, 120, 255),
	min_size = Vector2.new(720, 900),
	can_resize = true,
})

task.spawn(function()
	while utils.isCurrent() do
		task.wait(60)
		if utils.isCurrent() then
			utils.HonenxWhite:SetTitle("HonenxWhite | Main - " .. utils.greeting())
		end
	end
end)

utils.connect(utils.playerData.Player.Idled, function()
	services.VirtualUser:CaptureController()
	services.VirtualUser:ClickButton2(Vector2.new())
end)

utils.connect(utils.playerData.Player.CharacterAdded, function(character)
	utils.playerData.Character = character
	utils.playerData.Humanoid = character:WaitForChild("Humanoid", 10)
	utils.playerData.Backpack = utils.playerData.Player:WaitForChild("Backpack")
end)

local tabs = {
	main = utils.HonenxWhite:AddTab("Main"),
	killing = utils.HonenxWhite:AddTab("Killing"),
	specs = utils.HonenxWhite:AddTab("Specs"),
	farming = utils.HonenxWhite:AddTab("Farming"),
	fast = utils.HonenxWhite:AddTab("⚡ Fast"),
	boss = utils.HonenxWhite:AddTab("Boss"),
	inventory = utils.HonenxWhite:AddTab("Pets"),
	boosts = utils.HonenxWhite:AddTab("Boosts"),
	teleport = utils.HonenxWhite:AddTab("Teleports"),
	stats = utils.HonenxWhite:AddTab("Stats"),
	info = utils.HonenxWhite:AddTab("Info")
}

for _, tab in pairs(tabs) do
	tab.runtime = {}
end

tabs.main:AddLabel("User Settings:")

tabs.main.Settings = {
	Size = {Value = 2, Enabled = false},
	Speed = {Value = 120, Enabled = false},
	FOV = {Value = 70, Enabled = false}
}

tabs.main:AddTextBox("Size:", function(text)
	text = string.gsub(text, "%s+", "")
	if tonumber(text) and tonumber(text) > 0 then
		tabs.main.Settings.Size.Value = tonumber(text)
	end
end, {clear = false})

tabs.main:AddSwitch("Set Size", function(bool)
	tabs.main.Settings.Size.Enabled = bool
end)

task.spawn(function()
	while utils.isCurrent() and true do
		if tabs.main.Settings.Size.Enabled and utils.playerData.Character and utils.playerData.Humanoid then
			utils.remotes.ChangeSpeedSize:InvokeServer("changeSize", tabs.main.Settings.Size.Value)
		end
		task.wait(0.01)
	end
end)

tabs.main:AddTextBox("Speed:", function(text)
	text = string.gsub(text, "%s+", "")
	if tonumber(text) and tonumber(text) > 0 then
		tabs.main.Settings.Speed.Value = tonumber(text)
	end
end, {clear = false})

tabs.main:AddSwitch("Set Speed", function(bool)
	tabs.main.Settings.Speed.Enabled = bool
end)

task.spawn(function()
	while utils.isCurrent() and true do
		if tabs.main.Settings.Speed.Enabled and utils.playerData.Character and utils.playerData.Humanoid then
			utils.remotes.ChangeSpeedSize:InvokeServer("changeSpeed", tabs.main.Settings.Speed.Value)
		end
		task.wait(0.01)
	end
end)

if utils.playerData.Camera then
	tabs.main:AddTextBox("FOV:", function(text)
		text = string.gsub(text, "%s+", "")
		if tonumber(text) and tonumber(text) >= 1 and tonumber(text) <= 120 then
			tabs.main.Settings.FOV.Value = tonumber(text)
		end
	end, {clear = false})

	tabs.main:AddSwitch("Set FOV", function(bool)
		tabs.main.Settings.FOV.Enabled = bool
		utils.playerData.Camera.FieldOfView = bool and tabs.main.Settings.FOV.Value or 70
	end)

	task.spawn(function()
		while utils.isCurrent() and true do
			if tabs.main.Settings.FOV.Enabled and utils.playerData.Camera then
				utils.playerData.Camera.FieldOfView = tabs.main.Settings.FOV.Value
			end
			task.wait(0.01)
		end
	end)
end

tabs.main:AddLabel("Protection and Visuals:")

tabs.main.Protection = {
	AntiFling = {Enabled = false},
	PositionLock = {Enabled = false, Position = nil}
}

tabs.main.enableAntiFling = function()
	if not tabs.main.Protection.AntiFling.Enabled or not utils.playerData.Player.Character then return end
	if not utils.playerData.Player.Character:FindFirstChild("HumanoidRootPart") then return end
	if utils.playerData.Player.Character.HumanoidRootPart:FindFirstChild("BodyVelocity") and
	   utils.playerData.Player.Character.HumanoidRootPart.BodyVelocity.MaxForce == Vector3.new(100000, 0, 100000) then
		utils.playerData.Player.Character.HumanoidRootPart.BodyVelocity:Destroy()
	end
	tabs.main.runtime.bv = Instance.new("BodyVelocity")
	tabs.main.runtime.bv.MaxForce = Vector3.new(100000, 0, 100000)
	tabs.main.runtime.bv.Velocity = Vector3.new(0, 0, 0)
	tabs.main.runtime.bv.P = 1250
	tabs.main.runtime.bv.Parent = utils.playerData.Player.Character.HumanoidRootPart
end

tabs.main.disableAntiFling = function()
	if not utils.playerData.Player.Character or not utils.playerData.Player.Character:FindFirstChild("HumanoidRootPart") then return end
	if utils.playerData.Player.Character.HumanoidRootPart:FindFirstChild("BodyVelocity") and
	   utils.playerData.Player.Character.HumanoidRootPart.BodyVelocity.MaxForce == Vector3.new(100000, 0, 100000) then
		utils.playerData.Player.Character.HumanoidRootPart.BodyVelocity:Destroy()
	end
end

tabs.main:AddSwitch("Anti Fling", function(bool)
	tabs.main.Protection.AntiFling.Enabled = bool
	if bool then tabs.main.enableAntiFling() else tabs.main.disableAntiFling() end
end):Set(false)


utils.connect(utils.playerData.Player.CharacterAdded, function(newChar)
	newChar:WaitForChild("HumanoidRootPart", 5)
	if tabs.main.Protection.AntiFling.Enabled then tabs.main.enableAntiFling() end
end)

tabs.main.lockPosition = function()
	tabs.main.enableAntiFling()
	if not tabs.main.Protection.PositionLock.Enabled or not tabs.main.Protection.PositionLock.Position or not utils.playerData.Player.Character then return end
	if not utils.playerData.Player.Character:FindFirstChild("HumanoidRootPart") then return end
	if utils.playerData.Player.Character.HumanoidRootPart:FindFirstChild("PositionLocker") then
		utils.playerData.Player.Character.HumanoidRootPart.PositionLocker.Position = tabs.main.Protection.PositionLock.Position
	else
		tabs.main.disableAntiFling()
		tabs.main.runtime.bp = Instance.new("BodyPosition")
		tabs.main.runtime.bp.Name = "PositionLocker"
		tabs.main.runtime.bp.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
		tabs.main.runtime.bp.Position = tabs.main.Protection.PositionLock.Position
		tabs.main.runtime.bp.P = 100000
		tabs.main.runtime.bp.Parent = utils.playerData.Player.Character.HumanoidRootPart
	end
end

tabs.main.unlockPosition = function()
	if utils.playerData.Player.Character and utils.playerData.Player.Character:FindFirstChild("HumanoidRootPart") then
		if utils.playerData.Player.Character.HumanoidRootPart:FindFirstChild("PositionLocker") then
			utils.playerData.Player.Character.HumanoidRootPart.PositionLocker:Destroy()
		end
	end
	tabs.main.Protection.PositionLock.Position = nil
end

tabs.main:AddSwitch("Lock Position", function(bool)
	tabs.main.Protection.PositionLock.Enabled = bool
	if bool then
		if utils.playerData.Player.Character and utils.playerData.Player.Character:FindFirstChild("HumanoidRootPart") then
			tabs.main.Protection.PositionLock.Position = utils.playerData.Player.Character.HumanoidRootPart.Position
		end
		tabs.main.lockPosition()
	else
		tabs.main.unlockPosition()
	end
end)

tabs.main.VisibilitySettings = {
	HidePets = false,
	HidePopups = true,
	ShowPetsEvent = services.ReplicatedStorage.rEvents:WaitForChild("showPetsEvent"),
	SavePlayerSizeEvent = services.ReplicatedStorage.rEvents:WaitForChild("savePlayerSizeEvent")
}





tabs.main:AddSwitch("Hide Pets", function(state)
	tabs.main.VisibilitySettings.HidePets = state
	tabs.main.VisibilitySettings.ShowPetsEvent:FireServer(state and "hidePets" or "showPets")
end):Set(false)


tabs.main.VisibilitySettings.HidePopupsSwitch = tabs.main:AddSwitch("Hide Popups", function(state)
	tabs.main.VisibilitySettings.HidePopups = state
	tabs.main.VisibilitySettings.SavePlayerSizeEvent:FireServer("showPopupsOption")
end)
tabs.main.VisibilitySettings.HidePopupsSwitch:Set(false)


tabs.main.RedactConfigPath = "HonenxWhite/MuscleLegendsMainConfig.json"
tabs.main.RedactConfig = {
	RedactName = false,
	RedactStats = false,
}

tabs.main.loadRedactConfig = function()
	if type(isfile) ~= "function" or type(readfile) ~= "function" then return end
	pcall(function()
		if not isfile(tabs.main.RedactConfigPath) then return end
		local savedConfig = services.HttpService:JSONDecode(readfile(tabs.main.RedactConfigPath))
		if typeof(savedConfig) == "table" then
			tabs.main.RedactConfig.RedactName = savedConfig.RedactName == true
			tabs.main.RedactConfig.RedactStats = savedConfig.RedactStats == true
		end
	end)
end

tabs.main.saveRedactConfig = function()
	if type(writefile) ~= "function" then return end
	pcall(function()
		if type(makefolder) == "function"
			and (type(isfolder) ~= "function" or not isfolder("HonenxWhite")) then
			pcall(makefolder, "HonenxWhite")
		end
		writefile(tabs.main.RedactConfigPath, services.HttpService:JSONEncode(tabs.main.RedactConfig))
	end)
end

tabs.main.loadRedactConfig()
tabs.main.PrivacyRedactor = utils.createPrivacyRedactor(utils.playerData.Player, "Main")
tabs.main.RedactNameSwitch = tabs.main:AddSwitch("Redact Name", function(state)
	tabs.main.PrivacyRedactor:SetNameEnabled(state)
	tabs.main.RedactConfig.RedactName = state
	tabs.main.saveRedactConfig()
end)
tabs.main.RedactNameSwitch:Set(tabs.main.RedactConfig.RedactName)
tabs.main.RedactStatsSwitch = tabs.main:AddSwitch("Redact Stats", function(state)
	tabs.main.PrivacyRedactor:SetStatsEnabled(state)
	tabs.main.RedactConfig.RedactStats = state
	tabs.main.saveRedactConfig()
end)
tabs.main.RedactStatsSwitch:Set(tabs.main.RedactConfig.RedactStats)

utils.connect(utils.playerData.Player.CharacterAdded, function(newChar)
	if tabs.main.Protection.PositionLock.Enabled and newChar:WaitForChild("HumanoidRootPart", 5) then
		tabs.main.Protection.PositionLock.Position = newChar.HumanoidRootPart.Position
		tabs.main.lockPosition()
	end
end)

task.spawn(function()
	while utils.isCurrent() and true do
		if tabs.main.Protection.PositionLock.Enabled then tabs.main.lockPosition() end
		task.wait(0.1)
	end
end)



tabs.main.WaterParts = {
	Parts = {},
	PartSize = 2048,
	TotalDistance = 50000,
	StartPosition = Vector3.new(-2, -9.5, -2)
}

task.spawn(function()
	for x = 0, math.ceil(tabs.main.WaterParts.TotalDistance / tabs.main.WaterParts.PartSize) - 1 do
		for z = 0, math.ceil(tabs.main.WaterParts.TotalDistance / tabs.main.WaterParts.PartSize) - 1 do
			for i, offset in ipairs({
				{x * tabs.main.WaterParts.PartSize, z * tabs.main.WaterParts.PartSize, "Side_" .. x .. "_" .. z},
				{-x * tabs.main.WaterParts.PartSize, z * tabs.main.WaterParts.PartSize, "LeftRight_" .. x .. "_" .. z},
				{-x * tabs.main.WaterParts.PartSize, -z * tabs.main.WaterParts.PartSize, "UpLeft_" .. x .. "_" .. z},
				{x * tabs.main.WaterParts.PartSize, -z * tabs.main.WaterParts.PartSize, "UpRight_" .. x .. "_" .. z}
			}) do
				tabs.main.runtime.part = Instance.new("Part")
				tabs.main.runtime.part.Size = Vector3.new(tabs.main.WaterParts.PartSize, 1, tabs.main.WaterParts.PartSize)
				tabs.main.runtime.part.Position = tabs.main.WaterParts.StartPosition + Vector3.new(offset[1], 0, offset[2])
				tabs.main.runtime.part.Anchored = true
				tabs.main.runtime.part.Transparency = 1
				tabs.main.runtime.part.CanCollide = true
				tabs.main.runtime.part.Name = "Part_" .. offset[3]
				tabs.main.runtime.part.Parent = services.Workspace
				table.insert(tabs.main.WaterParts.Parts, tabs.main.runtime.part)
			end
		end
	end
end)

tabs.main.WalkOnWaterSwitch = tabs.main:AddSwitch("Walk on Water", function(bool)
	for _, part in ipairs(tabs.main.WaterParts.Parts) do
		if part and part.Parent then part.CanCollide = bool end
	end
end)
tabs.main.WalkOnWaterSwitch:Set(false)


tabs.main:AddLabel("Other:")

tabs.main:AddSwitch("Infinite Jump", function(bool)
	_G.InfiniteJump = bool
	if bool then
		utils.connect(services.UserInputService.JumpRequest, function()
			if _G.InfiniteJump then
				services.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
			end
		end)
	end
end)

tabs.main.FortuneWheelData = {
	Running = false,
	Generation = 0,
	Remote = services.ReplicatedStorage.rEvents:WaitForChild("openFortuneWheelRemote"),
	Chances = services.ReplicatedStorage
		:WaitForChild("shared")
		:WaitForChild("catalogs")
		:WaitForChild("fortuneWheelChances")
		:WaitForChild("Fortune Wheel")
}

tabs.main.spinFortuneWheel = function()
	pcall(function()
		tabs.main.FortuneWheelData.Remote:InvokeServer(
			"openFortuneWheel",
			tabs.main.FortuneWheelData.Chances
		)
	end)
end

tabs.main:AddSwitch("Spin Fortune Wheel", function(state)
	tabs.main.FortuneWheelData.Running = state
	tabs.main.FortuneWheelData.Generation += 1
	tabs.main.runtime.generation = tabs.main.FortuneWheelData.Generation

	if not state then return end

	task.spawn(function()
		while utils.isCurrent() and tabs.main.FortuneWheelData.Running and tabs.main.FortuneWheelData.Generation == tabs.main.runtime.generation do
			tabs.main.spinFortuneWheel()
			task.wait(1)
		end
	end)
end)

tabs.main.TimeDropdown = tabs.main:AddDropdown("Change Time", function(selection)
	services.Lighting.ClockTime = selection == "Night" and 0 or 9
end)
tabs.main.TimeDropdown:Add("Night")
tabs.main.TimeDropdown:Add("Day")

-- Kill Tab (i never know where it stars)


tabs.killing.getTool = function()
	for _, v in pairs(services.Players.LocalPlayer.Backpack:GetChildren()) do
		if v.Name == "Punch" and services.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
			services.Players.LocalPlayer.Character.Humanoid:EquipTool(v)
		end
	end
	services.Players.LocalPlayer.muscleEvent:FireServer("punch", "leftHand")
	services.Players.LocalPlayer.muscleEvent:FireServer("punch", "rightHand")
end

tabs.killing.isPlayerAlive = function(player)
	return player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and
		player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0
end

tabs.killing.isSpawnProtected = function(player)
	if not player or not player.Character then return false end
	if player.Character:FindFirstChildOfClass("ForceField")
		or player.Character:FindFirstChild("spawnProtectionHighlight") then
		return true
	end
	tabs.killing.runtime.protectedUntil = player.Character:GetAttribute("SpawnProtectedUntil")
	return typeof(tabs.killing.runtime.protectedUntil) == "number" and services.Workspace:GetServerTimeNow() < tabs.killing.runtime.protectedUntil
end

tabs.killing.getLocalCombatCharacter = function()
	tabs.killing.runtime.character_416 = services.Players.LocalPlayer.Character
	tabs.killing.runtime.humanoid_417 = tabs.killing.runtime.character_416 and tabs.killing.runtime.character_416:FindFirstChildOfClass("Humanoid")
	tabs.killing.runtime.humanoidRootPart = tabs.killing.runtime.character_416 and tabs.killing.runtime.character_416:FindFirstChild("HumanoidRootPart")
	if not tabs.killing.runtime.character_416 or not tabs.killing.runtime.humanoid_417 or tabs.killing.runtime.humanoid_417.Health <= 0 or not tabs.killing.runtime.humanoidRootPart then return end
	return tabs.killing.runtime.character_416, tabs.killing.runtime.humanoid_417, tabs.killing.runtime.humanoidRootPart
end

tabs.killing.positionNearTarget = function(target, heightOffset)
	if not tabs.killing.isPlayerAlive(target)
		or tabs.killing.isSpawnProtected(target)
		or tabs.killing.isSpawnProtected(services.Players.LocalPlayer) then
		return false
	end
	tabs.killing.runtime.discardCharacter_localRoot_429, tabs.killing.runtime.discardHumanoid_localRoot_429, tabs.killing.runtime.localRoot_429 = tabs.killing.getLocalCombatCharacter()
	tabs.killing.runtime.targetRoot_430 = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
	if not tabs.killing.runtime.localRoot_429 or not tabs.killing.runtime.targetRoot_430 then return false end

	tabs.killing.runtime.localRoot_429.CFrame = tabs.killing.runtime.targetRoot_430.CFrame * CFrame.new(0, heightOffset, 0)
	tabs.killing.runtime.localRoot_429.AssemblyLinearVelocity = Vector3.zero
	tabs.killing.runtime.localRoot_429.AssemblyAngularVelocity = Vector3.zero
	return true
end

tabs.killing.touchAndPunchTarget = function(target, heightOffset)
	if not tabs.killing.positionNearTarget(target, heightOffset) then return false, false end
	services.RunService.Heartbeat:Wait()
	if not tabs.killing.positionNearTarget(target, heightOffset) then return false, false end

	tabs.killing.runtime.character_444 = tabs.killing.getLocalCombatCharacter()
	tabs.killing.runtime.targetRoot_445 = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
	tabs.killing.runtime.targetHumanoid_446 = target.Character and target.Character:FindFirstChildOfClass("Humanoid")
	if not tabs.killing.runtime.character_444 or not tabs.killing.runtime.targetRoot_445 or not tabs.killing.runtime.targetHumanoid_446 or tabs.killing.isSpawnProtected(target) then return false, false end

	tabs.killing.runtime.hand = tabs.killing.runtime.character_444:FindFirstChild("LeftHand") or tabs.killing.runtime.character_444:FindFirstChild("RightHand")
	if not tabs.killing.runtime.hand then return false, false end

	tabs.killing.runtime.punchTool = tabs.killing.runtime.character_444:FindFirstChild("Punch") or services.Players.LocalPlayer.Backpack:FindFirstChild("Punch")
	tabs.killing.runtime.humanoid_453 = tabs.killing.runtime.character_444:FindFirstChildOfClass("Humanoid")
	if tabs.killing.runtime.punchTool and tabs.killing.runtime.punchTool.Parent ~= tabs.killing.runtime.character_444 and tabs.killing.runtime.humanoid_453 then
		tabs.killing.runtime.humanoid_453:EquipTool(tabs.killing.runtime.punchTool)
	end

	tabs.killing.runtime.healthBefore = tabs.killing.runtime.targetHumanoid_446.Health
	tabs.killing.runtime.attempted_459 = pcall(function()
		firetouchinterest(tabs.killing.runtime.targetRoot_445, tabs.killing.runtime.hand, 0)
		firetouchinterest(tabs.killing.runtime.targetRoot_445, tabs.killing.runtime.hand, 1)
		services.Players.LocalPlayer.muscleEvent:FireServer("punch", tabs.killing.runtime.hand.Name == "LeftHand" and "leftHand" or "rightHand")
	end)
	if not tabs.killing.runtime.attempted_459 then return false, false end

	for _ = 1, 4 do
		services.RunService.Heartbeat:Wait()
		if not tabs.killing.isPlayerAlive(target) or tabs.killing.runtime.targetHumanoid_446.Health < tabs.killing.runtime.healthBefore then
			return true, true
		end
		if tabs.killing.isSpawnProtected(target) then
			return false, false
		end
	end

	return false, true
end

tabs.killing.attackPlayerWithLimit = function(target, hitLimit, shouldContinue, heightOffset, countAttempts, hits, hitRegistered, attempted)
	hits = 0
	while utils.isCurrent() and hits < hitLimit and shouldContinue() and tabs.killing.isPlayerAlive(target) and not tabs.killing.isSpawnProtected(target) do
		hitRegistered, attempted = tabs.killing.touchAndPunchTarget(target, heightOffset)
		if countAttempts or hitRegistered then hits = hits + 1 end
		if not attempted and not countAttempts then break end
		if not hitRegistered then task.wait(0.05) end
	end
	return hits
end

tabs.killing.attackPlayerForDuration = function(target, duration, shouldContinue, heightOffset, startedAt, character, targetRoot, leftHand, rightHand, punchTool, humanoid)
	startedAt = os.clock()
	while utils.isCurrent() and os.clock() - startedAt < duration
		and shouldContinue()
		and tabs.killing.isPlayerAlive(target)
		and not tabs.killing.isSpawnProtected(target) do
		if tabs.killing.positionNearTarget(target, heightOffset) then
			character = services.Players.LocalPlayer.Character
			targetRoot = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
			leftHand = character and character:FindFirstChild("LeftHand")
			rightHand = character and character:FindFirstChild("RightHand")
			punchTool = character and character:FindFirstChild("Punch") or services.Players.LocalPlayer.Backpack:FindFirstChild("Punch")
			humanoid = character and character:FindFirstChildOfClass("Humanoid")
			if punchTool and humanoid and punchTool.Parent ~= character then humanoid:EquipTool(punchTool) end

			if targetRoot and leftHand and rightHand then
				pcall(function()
					firetouchinterest(targetRoot, leftHand, 0)
					firetouchinterest(targetRoot, leftHand, 1)
					firetouchinterest(targetRoot, rightHand, 0)
					firetouchinterest(targetRoot, rightHand, 1)
					services.Players.LocalPlayer.muscleEvent:FireServer("punch", "leftHand")
					services.Players.LocalPlayer.muscleEvent:FireServer("punch", "rightHand")
				end)
			end
		end
		services.RunService.Heartbeat:Wait()
	end
end

tabs.killing:AddLabel("Misc:")

tabs.killing.equipBestStatPets = function(priority)
	for _, folder in pairs(services.Players.LocalPlayer.petsFolder:GetChildren()) do
		if folder:IsA("Folder") then
			for _, pet in pairs(folder:GetChildren()) do
				services.ReplicatedStorage.rEvents.equipPetEvent:FireServer("unequipPet", pet)
			end
		end
	end

	task.wait(0.2)
	tabs.killing.runtime.petsByName = {}
	for _, petName in ipairs(priority) do tabs.killing.runtime.petsByName[petName] = {} end

	for _, pet in pairs(services.Players.LocalPlayer.petsFolder.Unique:GetChildren()) do
		if tabs.killing.runtime.petsByName[pet.Name] then table.insert(tabs.killing.runtime.petsByName[pet.Name], pet) end
	end

	tabs.killing.runtime.equippedCount = 0
	for _, petName in ipairs(priority) do
		for _, pet in ipairs(tabs.killing.runtime.petsByName[petName]) do
			if tabs.killing.runtime.equippedCount >= 9 then return end
			services.ReplicatedStorage.rEvents.equipPetEvent:FireServer("equipPet", pet)
			tabs.killing.runtime.equippedCount += 1
			task.wait(0.1)
		end
	end
end

tabs.killing:AddButton("Equip Best Damage", function()
	tabs.killing.equipBestStatPets({"Wild Wizard", "Chaos Sorcerer", "Mighty Monster", "Small Fry"})
end)

tabs.killing:AddButton("Equip Best Health", function()
	tabs.killing.equipBestStatPets({"Mighty Monster", "Small Fry", "Wild Wizard", "Chaos Sorcerer"})
end)

tabs.killing:AddSwitch("Remove Attack Animations", function(bool)
	if bool then
		tabs.killing.runtime.blockedAnimations = {
			["3638729053"] = true,
			["3638767427"] = true,
			["507768375"] = true,
			["522635514"] = true,
			["522638767"] = true,
			["182393478"] = true,
			["129967390"] = true,
			["129967478"] = true
		}

		tabs.killing.runtime.shouldBlockAnimation = function(track)
			if not track or not track.Animation then return false end
			tabs.killing.runtime.animationId = tostring(track.Animation.AnimationId):match("%d+")
			tabs.killing.runtime.animationName = string.lower((track.Name or "") .. " " .. (track.Animation.Name or ""))
			return tabs.killing.runtime.blockedAnimations[tabs.killing.runtime.animationId] == true
				or string.find(tabs.killing.runtime.animationName, "punch", 1, true) ~= nil
				or string.find(tabs.killing.runtime.animationName, "attack", 1, true) ~= nil
				or string.find(tabs.killing.runtime.animationName, "right", 1, true) ~= nil
				or string.find(tabs.killing.runtime.animationName, "equip", 1, true) ~= nil
				or string.find(tabs.killing.runtime.animationName, "tool", 1, true) ~= nil
				or string.find(tabs.killing.runtime.animationName, "hold", 1, true) ~= nil
		end

		tabs.killing.runtime.isAttackTool = function(tool)
			if not tool or not tool:IsA("Tool") then return false end
			tabs.killing.runtime.name = string.lower(tool.Name)
			return string.find(tabs.killing.runtime.name, "punch", 1, true) ~= nil
				or string.find(tabs.killing.runtime.name, "attack", 1, true) ~= nil
				or string.find(tabs.killing.runtime.name, "right", 1, true) ~= nil
		end

		tabs.killing.runtime.hasAttackToolEquipped = function(character)
			if not character then return false end
			for _, child in ipairs(character:GetChildren()) do
				if tabs.killing.runtime.isAttackTool(child) then return true end
			end
			return false
		end

		tabs.killing.runtime.isMovementAnimation = function(track, character)
			tabs.killing.runtime.animation = track and track.Animation
			tabs.killing.runtime.animate = character and character:FindFirstChild("Animate")
			if not tabs.killing.runtime.animation or not tabs.killing.runtime.animate or not tabs.killing.runtime.animation:IsDescendantOf(tabs.killing.runtime.animate) then
				return false
			end

			tabs.killing.runtime.path = ""
			tabs.killing.runtime.current = tabs.killing.runtime.animation
			while utils.isCurrent() and tabs.killing.runtime.current and tabs.killing.runtime.current ~= tabs.killing.runtime.animate.Parent do
				tabs.killing.runtime.path = tabs.killing.runtime.path .. " " .. string.lower(tabs.killing.runtime.current.Name)
				if tabs.killing.runtime.current == tabs.killing.runtime.animate then break end
				tabs.killing.runtime.current = tabs.killing.runtime.current.Parent
			end

			if string.find(tabs.killing.runtime.path, "tool", 1, true)
				or string.find(tabs.killing.runtime.path, "punch", 1, true)
				or string.find(tabs.killing.runtime.path, "attack", 1, true)
				or string.find(tabs.killing.runtime.path, "equip", 1, true)
				or string.find(tabs.killing.runtime.path, "hold", 1, true) then
				return false
			end

			for _, movementName in ipairs({"idle", "walk", "run", "jump", "fall", "climb", "swim", "sit"}) do
				if string.find(tabs.killing.runtime.path, movementName, 1, true) then return true end
			end
			return false
		end

		tabs.killing.runtime.stopBlockedAnimations = function(character)
			tabs.killing.runtime.humanoid_603 = character and character:FindFirstChildOfClass("Humanoid")
			if not tabs.killing.runtime.humanoid_603 then return end
			for _, track in ipairs(tabs.killing.runtime.humanoid_603:GetPlayingAnimationTracks()) do
				if tabs.killing.runtime.shouldBlockAnimation(track) then track:Stop(0) end
			end
		end

		tabs.killing.runtime.stopEquipAnimations = function(character)
			tabs.killing.runtime.humanoid_611 = character and character:FindFirstChildOfClass("Humanoid")
			if not tabs.killing.runtime.humanoid_611 then return end
			for _, track in ipairs(tabs.killing.runtime.humanoid_611:GetPlayingAnimationTracks()) do
				tabs.killing.runtime.priority = track.Priority
				if tabs.killing.runtime.shouldBlockAnimation(track)
					or not tabs.killing.runtime.isMovementAnimation(track, character)
					or tabs.killing.runtime.priority == Enum.AnimationPriority.Action
					or tabs.killing.runtime.priority == Enum.AnimationPriority.Action2
					or tabs.killing.runtime.priority == Enum.AnimationPriority.Action3
					or tabs.killing.runtime.priority == Enum.AnimationPriority.Action4 then
					track:Stop(0)
				end
			end
		end

		tabs.killing.runtime.setupAnimationBlocking = function()
			tabs.killing.runtime.char_627 = services.Players.LocalPlayer.Character
			tabs.killing.runtime.humanoid_628 = tabs.killing.runtime.char_627 and tabs.killing.runtime.char_627:FindFirstChildOfClass("Humanoid")
			if not tabs.killing.runtime.humanoid_628 then return end

			tabs.killing.runtime.stopBlockedAnimations(tabs.killing.runtime.char_627)
			if _G.AnimBlockConnection then _G.AnimBlockConnection:Disconnect() end
			_G.AnimBlockConnection = utils.connect(tabs.killing.runtime.humanoid_628.AnimationPlayed, function(track)
				if tabs.killing.runtime.shouldBlockAnimation(track)
					or (tabs.killing.runtime.hasAttackToolEquipped(tabs.killing.runtime.char_627) and not tabs.killing.runtime.isMovementAnimation(track, tabs.killing.runtime.char_627)) then
					track:Stop(0)
				end
			end)
		end

		tabs.killing.runtime.processTool = function(tool)
			if tabs.killing.runtime.isAttackTool(tool) then
				if not tool:GetAttribute("ActivatedOverride") then
					tool:SetAttribute("ActivatedOverride", true)

					_G.ToolConnections = _G.ToolConnections or {}
					_G.ToolConnections[tool] = utils.connect(tool.Activated, function()
						task.wait(0.05)
						tabs.killing.runtime.stopBlockedAnimations(services.Players.LocalPlayer.Character)
					end)

					_G.ToolEquipConnections = _G.ToolEquipConnections or {}
					_G.ToolEquipConnections[tool] = utils.connect(tool.Equipped, function()
						for _, delayTime in ipairs({0, 0.03, 0.08, 0.15, 0.25}) do
							task.delay(delayTime, function()
								tabs.killing.runtime.stopEquipAnimations(services.Players.LocalPlayer.Character)
							end)
						end
					end)
				end

				if tool.Parent == services.Players.LocalPlayer.Character then
					tabs.killing.runtime.stopEquipAnimations(services.Players.LocalPlayer.Character)
				end
			end
		end

		tabs.killing.runtime.overrideToolActivation = function()
			for _, tool in pairs(services.Players.LocalPlayer.Backpack:GetChildren()) do
				tabs.killing.runtime.processTool(tool)
			end

			tabs.killing.runtime.char_673 = services.Players.LocalPlayer.Character
			if tabs.killing.runtime.char_673 then
				for _, tool in pairs(tabs.killing.runtime.char_673:GetChildren()) do
					if tool:IsA("Tool") then
						tabs.killing.runtime.processTool(tool)
					end
				end
			end

			_G.BackpackAddedConnection = utils.connect(services.Players.LocalPlayer.Backpack.ChildAdded, function(child)
				if child:IsA("Tool") then
					task.wait(0.1)
					tabs.killing.runtime.processTool(child)
				end
			end)

			if tabs.killing.runtime.char_673 then
				_G.CharacterToolAddedConnection = utils.connect(tabs.killing.runtime.char_673.ChildAdded, function(child)
					if child:IsA("Tool") then
						task.wait(0.1)
						tabs.killing.runtime.processTool(child)
					end
				end)
			end
		end

		_G.AnimMonitorConnection = utils.connect(services.RunService.RenderStepped, function()
			tabs.killing.runtime.character_700 = services.Players.LocalPlayer.Character
			if tabs.killing.runtime.hasAttackToolEquipped(tabs.killing.runtime.character_700) then
				tabs.killing.runtime.stopEquipAnimations(tabs.killing.runtime.character_700)
			else
				tabs.killing.runtime.stopBlockedAnimations(tabs.killing.runtime.character_700)
			end
		end)

		_G.CharacterAddedConnection = utils.connect(services.Players.LocalPlayer.CharacterAdded, function(newChar)
			task.wait(1)
			tabs.killing.runtime.setupAnimationBlocking()
			tabs.killing.runtime.overrideToolActivation()

			if _G.CharacterToolAddedConnection then
				_G.CharacterToolAddedConnection:Disconnect()
			end

			_G.CharacterToolAddedConnection = utils.connect(newChar.ChildAdded, function(child)
				if child:IsA("Tool") then
					task.wait(0.1)
					tabs.killing.runtime.processTool(child)
				end
			end)
		end)

		tabs.killing.runtime.setupAnimationBlocking()
		tabs.killing.runtime.overrideToolActivation()
	else
		if _G.AnimBlockConnection then
			_G.AnimBlockConnection:Disconnect()
			_G.AnimBlockConnection = nil
		end

		if _G.AnimMonitorConnection then
			_G.AnimMonitorConnection:Disconnect()
			_G.AnimMonitorConnection = nil
		end

		if _G.CharacterAddedConnection then
			_G.CharacterAddedConnection:Disconnect()
			_G.CharacterAddedConnection = nil
		end

		if _G.BackpackAddedConnection then
			_G.BackpackAddedConnection:Disconnect()
			_G.BackpackAddedConnection = nil
		end

		if _G.CharacterToolAddedConnection then
			_G.CharacterToolAddedConnection:Disconnect()
			_G.CharacterToolAddedConnection = nil
		end

		if _G.ToolConnections then
			for tool, connection in pairs(_G.ToolConnections) do
				if connection then
					connection:Disconnect()
				end
				if tool and tool:GetAttribute("ActivatedOverride") then
					tool:SetAttribute("ActivatedOverride", nil)
				end
			end
			_G.ToolConnections = nil
		end

		if _G.ToolEquipConnections then
			for _, connection in pairs(_G.ToolEquipConnections) do
				if connection then connection:Disconnect() end
			end
			_G.ToolEquipConnections = nil
		end
	end
end)

tabs.killing:AddLabel("Auto Kill:")

_G.whitelistedPlayers = _G.whitelistedPlayers or {}
_G.blacklistedPlayers = _G.blacklistedPlayers or {}

for _, connectionName in ipairs({
	"killAllConnection",
	"farmBadKarmaConnection",
	"farmGoodKarmaConnection",
	"blacklistKillConnection",
	"deathRingConnection"
}) do
	tabs.killing.runtime.connection = _G[connectionName]
	if tabs.killing.runtime.connection then
		pcall(function() tabs.killing.runtime.connection:Disconnect() end)
		_G[connectionName] = nil
	end
end

_G.killAll = false
_G.killBlacklistedOnly = false
_G.farmBadKarma = false
_G.farmGoodKarma = false
_G.deathRingEnabled = false
_G.killAllGeneration = (_G.killAllGeneration or 0) + 1
_G.killListGeneration = (_G.killListGeneration or 0) + 1

tabs.killing.isWhitelisted = function(player)
	for _, name in ipairs(_G.whitelistedPlayers) do
		if name:lower() == player.Name:lower() then return true end
	end
	return false
end

tabs.killing.isBlacklisted = function(player)
	for _, name in ipairs(_G.blacklistedPlayers) do
		if name:lower() == player.Name:lower() then return true end
	end
	return false
end

tabs.killing.RemoveWhitelistDropdown = nil
tabs.killing.WhitelistDisplayNames = {}

tabs.killing.getWhitelistDisplayName = function(username)
	local cached = tabs.killing.WhitelistDisplayNames[username]
	if cached then return cached end
	local player = services.Players:FindFirstChild(username)
	if player then
		tabs.killing.WhitelistDisplayNames[username] = player.DisplayName
		return player.DisplayName
	end
	return username
end

tabs.killing.WhitelistDropdown = tabs.killing:AddDropdown("Add to Whitelist", function(selectedText)
	tabs.killing.runtime.playerName_817 = selectedText:match("| (.+)$")
	if tabs.killing.runtime.playerName_817 then
		tabs.killing.runtime.playerName_817 = tabs.killing.runtime.playerName_817:gsub("^%s*(.-)%s*$", "%1")
		local selectedPlayer = services.Players:FindFirstChild(tabs.killing.runtime.playerName_817)
		if selectedPlayer then tabs.killing.WhitelistDisplayNames[selectedPlayer.Name] = selectedPlayer.DisplayName end
		for _, name in ipairs(_G.whitelistedPlayers) do
			if name:lower() == tabs.killing.runtime.playerName_817:lower() then return end
		end
		table.insert(_G.whitelistedPlayers, tabs.killing.runtime.playerName_817)
		if tabs.killing.RemoveWhitelistDropdown then
			tabs.killing.RemoveWhitelistDropdown:Add(tabs.killing.getWhitelistDisplayName(tabs.killing.runtime.playerName_817))
		end
	end
end)

tabs.killing:AddSwitch("Kill Everyone", function(bool)
	_G.killAll = bool
	_G.killAllGeneration = (_G.killAllGeneration or 0) + 1
	tabs.killing.runtime.generation_831 = _G.killAllGeneration
	if not bool then return end

	task.spawn(function(generation, foundTarget)
		while utils.isCurrent() and _G.killAll and _G.killAllGeneration == generation do
			foundTarget = false
			for _, player in ipairs(services.Players:GetPlayers()) do
				if not _G.killAll or _G.killAllGeneration ~= generation then break end
				if player ~= services.Players.LocalPlayer
					and not tabs.killing.isWhitelisted(player)
					and tabs.killing.isPlayerAlive(player)
					and not tabs.killing.isSpawnProtected(player) then
					foundTarget = true
					tabs.killing.attackPlayerForDuration(player, 4, function()
						return _G.killAll and _G.killAllGeneration == generation and not tabs.killing.isWhitelisted(player)
					end, 3.5)
				end
			end
			if foundTarget then
				services.RunService.Heartbeat:Wait()
			else
				task.wait(0.1)
			end
		end
	end, tabs.killing.runtime.generation_831)
end)

tabs.killing:AddSwitch("Whitelist Friends", function(bool)
	_G.whitelistFriends = bool

	if bool then
		for _, player in pairs(services.Players:GetPlayers()) do
			if player ~= services.Players.LocalPlayer and player:IsFriendsWith(services.Players.LocalPlayer.UserId) then
				if not tabs.killing.isWhitelisted(player) then
					table.insert(_G.whitelistedPlayers, player.Name)
				end
			end
		end

		_G.friendWhitelistConnection = utils.connect(services.Players.PlayerAdded, function(player)
			if _G.whitelistFriends and player:IsFriendsWith(services.Players.LocalPlayer.UserId) then
				if not tabs.killing.isWhitelisted(player) then
					table.insert(_G.whitelistedPlayers, player.Name)
				end
			end
		end)

		_G.friendCheckLoop = task.spawn(function()
			while utils.isCurrent() and _G.whitelistFriends do
				task.wait(3)
				for _, player in pairs(services.Players:GetPlayers()) do
					if player ~= services.Players.LocalPlayer and player:IsFriendsWith(services.Players.LocalPlayer.UserId) then
						if not tabs.killing.isWhitelisted(player) then
							table.insert(_G.whitelistedPlayers, player.Name)
							print("Neuer Freund zur Whitelist hinzugefügt:", player.Name)
						end
					end
				end
			end
		end)
	else
		if _G.friendWhitelistConnection then
			_G.friendWhitelistConnection:Disconnect()
			_G.friendWhitelistConnection = nil
		end
		if _G.friendCheckLoop then
			task.cancel(_G.friendCheckLoop)
			_G.friendCheckLoop = nil
		end
	end
end)

tabs.killing:AddLabel("Karma Killing:")

tabs.killing.KarmaData = {FarmEvil = false, FarmGood = false, Generation = 0}

tabs.killing.matchesKarmaMode = function(player)
	tabs.killing.runtime.goodKarma = player:FindFirstChild("goodKarma")
	tabs.killing.runtime.evilKarma = player:FindFirstChild("evilKarma")
	if not tabs.killing.runtime.goodKarma or not tabs.killing.runtime.evilKarma then return false end

	tabs.killing.runtime.goodValue = tabs.killing.runtime.goodKarma.Value or 0
	tabs.killing.runtime.evilValue = tabs.killing.runtime.evilKarma.Value or 0
	if tabs.killing.runtime.goodValue + tabs.killing.runtime.evilValue < 5 then return false end
	return (tabs.killing.KarmaData.FarmEvil and tabs.killing.runtime.goodValue > tabs.killing.runtime.evilValue)
		or (tabs.killing.KarmaData.FarmGood and tabs.killing.runtime.evilValue > tabs.killing.runtime.goodValue)
end

tabs.killing.restartKarmaWorker = function()
	tabs.killing.KarmaData.Generation += 1
	tabs.killing.runtime.generation_921 = tabs.killing.KarmaData.Generation
	if not tabs.killing.KarmaData.FarmEvil and not tabs.killing.KarmaData.FarmGood then return end

	task.spawn(function()
		while utils.isCurrent() and (tabs.killing.KarmaData.FarmEvil or tabs.killing.KarmaData.FarmGood) and tabs.killing.KarmaData.Generation == tabs.killing.runtime.generation_921 do
			tabs.killing.runtime.foundTarget_926 = false
			for _, player in ipairs(services.Players:GetPlayers()) do
				if tabs.killing.KarmaData.Generation ~= tabs.killing.runtime.generation_921 then break end
				if player ~= services.Players.LocalPlayer
					and not tabs.killing.isWhitelisted(player)
					and tabs.killing.isPlayerAlive(player)
					and not tabs.killing.isSpawnProtected(player)
					and tabs.killing.matchesKarmaMode(player) then
					tabs.killing.runtime.foundTarget_926 = true
					tabs.killing.attackPlayerWithLimit(player, 4, function()
						return tabs.killing.KarmaData.Generation == tabs.killing.runtime.generation_921
							and not tabs.killing.isWhitelisted(player)
							and tabs.killing.matchesKarmaMode(player)
					end, 3.5)
				end
			end
			if tabs.killing.runtime.foundTarget_926 then
				services.RunService.Heartbeat:Wait()
			else
				task.wait(0.1)
			end
		end
	end)
end

tabs.killing:AddSwitch("Farm Evil Karma", function(state)
	tabs.killing.KarmaData.FarmEvil = state
	tabs.killing.restartKarmaWorker()
end)

tabs.killing:AddSwitch("Farm Good Karma", function(state)
	tabs.killing.KarmaData.FarmGood = state
	tabs.killing.restartKarmaWorker()
end)



tabs.killing:AddLabel("Target Killing:")

tabs.killing.RemoveKilllistDropdown = nil
tabs.killing.KilllistDisplayNames = {}

tabs.killing.getKilllistDisplayName = function(username)
	local cached = tabs.killing.KilllistDisplayNames[username]
	if cached then return cached end
	local player = services.Players:FindFirstChild(username)
	if player then
		tabs.killing.KilllistDisplayNames[username] = player.DisplayName
		return player.DisplayName
	end
	return username
end

tabs.killing.BlacklistDropdown = tabs.killing:AddDropdown("Add to Killlist", function(selectedText)
	local selectedUsername = selectedText:match("| (.+)$")
	local selectedPlayer = selectedUsername and services.Players:FindFirstChild(selectedUsername:gsub("^%s*(.-)%s*$", "%1"))
	if selectedPlayer then
		tabs.killing.runtime.playerName_967 = selectedPlayer.Name
		tabs.killing.KilllistDisplayNames[selectedPlayer.Name] = selectedPlayer.DisplayName
		if not tabs.killing.isBlacklisted({Name = tabs.killing.runtime.playerName_967}) then
			table.insert(_G.blacklistedPlayers, tabs.killing.runtime.playerName_967)
			if tabs.killing.RemoveKilllistDropdown then
				tabs.killing.RemoveKilllistDropdown:Add(selectedPlayer.DisplayName)
			end
		end
	end
end)

for _, player in ipairs(services.Players:GetPlayers()) do
	if player ~= services.Players.LocalPlayer then
		tabs.killing.WhitelistDisplayNames[player.Name] = player.DisplayName
		tabs.killing.WhitelistDropdown:Add(player.DisplayName .. " | " .. player.Name)
		tabs.killing.KilllistDisplayNames[player.Name] = player.DisplayName
		tabs.killing.BlacklistDropdown:Add(player.DisplayName .. " | " .. player.Name)
	end
end

utils.connect(services.Players.PlayerAdded, function(player)
	if player ~= services.Players.LocalPlayer then
		tabs.killing.WhitelistDisplayNames[player.Name] = player.DisplayName
		tabs.killing.WhitelistDropdown:Add(player.DisplayName .. " | " .. player.Name)
		tabs.killing.KilllistDisplayNames[player.Name] = player.DisplayName
		tabs.killing.BlacklistDropdown:Add(player.DisplayName .. " | " .. player.Name)
	end
end)

utils.connect(services.Players.PlayerRemoving, function(player)
	tabs.killing.WhitelistDropdown:Remove(player.DisplayName .. " | " .. player.Name)
	tabs.killing.BlacklistDropdown:Remove(player.DisplayName .. " | " .. player.Name)
end)

tabs.killing.TargetKillAntiGravityName = "HonenxWhiteTargetKillAntiGravity"
tabs.killing.TargetKillHeightOffset = 10
tabs.killing.TargetKillGravityState = {
	Active = false,
	OriginalGravity = nil,
	Connection = nil
}

tabs.killing.setTargetKillAntiGravity = function(enabled)
	tabs.killing.runtime.character_1000 = services.Players.LocalPlayer.Character
	tabs.killing.runtime.root = tabs.killing.runtime.character_1000 and tabs.killing.runtime.character_1000:FindFirstChild("HumanoidRootPart")
	if enabled then
		if not tabs.killing.TargetKillGravityState.Active then
			tabs.killing.TargetKillGravityState.Active = true
			tabs.killing.TargetKillGravityState.OriginalGravity = services.Workspace.Gravity
			services.Workspace.Gravity = 0

			tabs.killing.TargetKillGravityState.Connection = utils.connect(services.RunService.Heartbeat, function()
				services.Workspace.Gravity = 0
				tabs.killing.runtime.currentCharacter = services.Players.LocalPlayer.Character
				tabs.killing.runtime.currentRoot = tabs.killing.runtime.currentCharacter and tabs.killing.runtime.currentCharacter:FindFirstChild("HumanoidRootPart")
				if tabs.killing.runtime.currentRoot then
					tabs.killing.runtime.velocity_1013 = tabs.killing.runtime.currentRoot.AssemblyLinearVelocity
					tabs.killing.runtime.currentRoot.AssemblyLinearVelocity = Vector3.new(tabs.killing.runtime.velocity_1013.X, 0, tabs.killing.runtime.velocity_1013.Z)
				end
			end)
		end

		if tabs.killing.runtime.root then
			tabs.killing.runtime.oldAntiGravity = tabs.killing.runtime.root:FindFirstChild(tabs.killing.TargetKillAntiGravityName)
			if tabs.killing.runtime.oldAntiGravity then tabs.killing.runtime.oldAntiGravity:Destroy() end
			tabs.killing.runtime.velocity_1022 = tabs.killing.runtime.root.AssemblyLinearVelocity
			tabs.killing.runtime.root.AssemblyLinearVelocity = Vector3.new(tabs.killing.runtime.velocity_1022.X, 0, tabs.killing.runtime.velocity_1022.Z)
			tabs.killing.runtime.root.AssemblyAngularVelocity = Vector3.zero
		end
	else
		if tabs.killing.TargetKillGravityState.Connection then
			tabs.killing.TargetKillGravityState.Connection:Disconnect()
			tabs.killing.TargetKillGravityState.Connection = nil
		end
		if tabs.killing.TargetKillGravityState.Active then
			services.Workspace.Gravity = tabs.killing.TargetKillGravityState.OriginalGravity or 196.2
		end
		tabs.killing.TargetKillGravityState.Active = false
		tabs.killing.TargetKillGravityState.OriginalGravity = nil
	end
end

tabs.killing:AddSwitch("Kill List", function(bool)
	_G.killBlacklistedOnly = bool
	_G.killListGeneration = (_G.killListGeneration or 0) + 1
	tabs.killing.runtime.generation_1042 = _G.killListGeneration
	if not bool then
		tabs.killing.setTargetKillAntiGravity(false)
		return
	end
	tabs.killing.setTargetKillAntiGravity(true)

	task.spawn(function(generation, target)
		while utils.isCurrent() and _G.killBlacklistedOnly and _G.killListGeneration == generation do
			target = nil
			for _, player in ipairs(services.Players:GetPlayers()) do
				if not _G.killBlacklistedOnly or _G.killListGeneration ~= generation then break end
				if player ~= services.Players.LocalPlayer
					and tabs.killing.isBlacklisted(player)
					and tabs.killing.isPlayerAlive(player)
					and not tabs.killing.isSpawnProtected(player) then
					target = player
					break
				end
			end

			if target then
				pcall(function()
					while utils.isCurrent() and _G.killBlacklistedOnly
						and _G.killListGeneration == generation
						and target.Parent == services.Players
						and tabs.killing.isBlacklisted(target)
						and tabs.killing.isPlayerAlive(target)
						and not tabs.killing.isSpawnProtected(target) do
						tabs.killing.runtime.discardHit_attempted, tabs.killing.runtime.attempted_1071 = tabs.killing.touchAndPunchTarget(target, tabs.killing.TargetKillHeightOffset)
						if not tabs.killing.runtime.attempted_1071 then task.wait(0.1) end
					end
				end)
				services.RunService.Heartbeat:Wait()
			else
				task.wait(0.1)
			end
		end
	end, tabs.killing.runtime.generation_1042)
end)

tabs.killing.SpectateData = {
	SelectedPlayer = nil,
	SelectedPlayerUserId = nil,
	Spectating = false,
	CurrentTargetConnection = nil,
	LocalPlayerRespawnConnection = nil,
	CameraMonitorLoop = nil
}

getgenv().SpectateState = getgenv().SpectateState or {
	SavedUserId = nil,
	IsSpectating = false
}

tabs.killing.stopSpectating = function()
	if tabs.killing.SpectateData.CurrentTargetConnection then
		tabs.killing.SpectateData.CurrentTargetConnection:Disconnect()
		tabs.killing.SpectateData.CurrentTargetConnection = nil
	end

	if tabs.killing.SpectateData.CameraMonitorLoop then
		tabs.killing.SpectateData.CameraMonitorLoop = false
	end

	tabs.killing.runtime.localPlayer_1110 = services.Players.LocalPlayer
	if tabs.killing.runtime.localPlayer_1110.Character then
		tabs.killing.runtime.humanoid_1112 = tabs.killing.runtime.localPlayer_1110.Character:FindFirstChildOfClass("Humanoid")
		if tabs.killing.runtime.humanoid_1112 then
			utils.playerData.Camera.CameraSubject = tabs.killing.runtime.humanoid_1112
			utils.playerData.Camera.CameraType = Enum.CameraType.Custom
		end
	end

	if utils.playerData.Humanoid then
		utils.playerData.Camera.CameraSubject = utils.playerData.Humanoid
	end
end

tabs.killing.startCameraMonitor = function()
	if tabs.killing.SpectateData.CameraMonitorLoop then
		tabs.killing.SpectateData.CameraMonitorLoop = false
		task.wait(0.3)
	end

	tabs.killing.SpectateData.CameraMonitorLoop = true

	task.spawn(function()
		while utils.isCurrent() and tabs.killing.SpectateData.CameraMonitorLoop do
			task.wait(0.2)
			if tabs.killing.SpectateData.Spectating and tabs.killing.SpectateData.SelectedPlayer then
				tabs.killing.runtime.targetChar = tabs.killing.SpectateData.SelectedPlayer.Character
				if tabs.killing.runtime.targetChar then
					tabs.killing.runtime.targetHumanoid_1138 = tabs.killing.runtime.targetChar:FindFirstChildOfClass("Humanoid")
					if tabs.killing.runtime.targetHumanoid_1138 then
						if utils.playerData.Camera.CameraSubject ~= tabs.killing.runtime.targetHumanoid_1138 then
							utils.playerData.Camera.CameraSubject = tabs.killing.runtime.targetHumanoid_1138
						end
					end
				end
			else
				break
			end
		end
	end)
end

tabs.killing.updateSpectateTarget = function(player)
	if not player then
		if tabs.killing.SpectateData.SelectedPlayerUserId then
			for _, p in ipairs(services.Players:GetPlayers()) do
				if p.UserId == tabs.killing.SpectateData.SelectedPlayerUserId then
					player = p
					tabs.killing.SpectateData.SelectedPlayer = player
					break
				end
			end
		end

		if not player and getgenv().SpectateState.SavedUserId then
			for _, p in ipairs(services.Players:GetPlayers()) do
				if p.UserId == getgenv().SpectateState.SavedUserId then
					player = p
					tabs.killing.SpectateData.SelectedPlayer = player
					tabs.killing.SpectateData.SelectedPlayerUserId = p.UserId
					break
				end
			end
		end

		if not player then
			tabs.killing.stopSpectating()
			return
		end
	end

	tabs.killing.SpectateData.SelectedPlayerUserId = player.UserId
	tabs.killing.SpectateData.SelectedPlayer = player

	if tabs.killing.SpectateData.CurrentTargetConnection then
		tabs.killing.SpectateData.CurrentTargetConnection:Disconnect()
		tabs.killing.SpectateData.CurrentTargetConnection = nil
	end

	tabs.killing.runtime.setCamera = function(char)
		if not tabs.killing.SpectateData.Spectating or tabs.killing.SpectateData.SelectedPlayerUserId ~= player.UserId then
			return
		end
		tabs.killing.runtime.humanoid_1193 = char:WaitForChild("Humanoid", 3)
		if tabs.killing.runtime.humanoid_1193 and tabs.killing.SpectateData.Spectating and tabs.killing.SpectateData.SelectedPlayerUserId == player.UserId then
			utils.playerData.Camera.CameraSubject = tabs.killing.runtime.humanoid_1193
		end
	end

	if player.Character then
		tabs.killing.runtime.setCamera(player.Character)
	end

	tabs.killing.SpectateData.CurrentTargetConnection = utils.connect(player.CharacterAdded, function(newChar)
		if tabs.killing.SpectateData.Spectating and tabs.killing.SpectateData.SelectedPlayerUserId == player.UserId then
			tabs.killing.runtime.setCamera(newChar)
		end
	end)
end

tabs.killing.getPlayers = function()
	return services.Players:GetPlayers()
end

tabs.killing.SpectateDropdown = tabs.killing:AddDropdown("Choose Player", function(text)
	for _, player in ipairs(tabs.killing.getPlayers()) do
		tabs.killing.runtime.optionText = player.DisplayName .. " | " .. player.Name
		if text == tabs.killing.runtime.optionText then
			tabs.killing.SpectateData.SelectedPlayer = player
			tabs.killing.SpectateData.SelectedPlayerUserId = player.UserId
			getgenv().SpectateState.SavedUserId = player.UserId
			if tabs.killing.SpectateData.Spectating then
				tabs.killing.updateSpectateTarget(player)
			end
			break
		end
	end
end)

tabs.killing:AddSwitch("Spectate", function(bool)
	tabs.killing.SpectateData.Spectating = bool
	getgenv().SpectateState.IsSpectating = bool

	if tabs.killing.SpectateData.Spectating then
		if tabs.killing.SpectateData.SelectedPlayerUserId then
			getgenv().SpectateState.SavedUserId = tabs.killing.SpectateData.SelectedPlayerUserId
		end
		tabs.killing.updateSpectateTarget()
		tabs.killing.startCameraMonitor()
	else
		tabs.killing.stopSpectating()
		task.wait(0.1)
		tabs.killing.runtime.localPlayer_1242 = services.Players.LocalPlayer
		if tabs.killing.runtime.localPlayer_1242.Character then
			tabs.killing.runtime.humanoid_1244 = tabs.killing.runtime.localPlayer_1242.Character:FindFirstChildOfClass("Humanoid")
			if tabs.killing.runtime.humanoid_1244 then
				utils.playerData.Camera.CameraSubject = tabs.killing.runtime.humanoid_1244
			end
		end
		getgenv().SpectateState.IsSpectating = false
	end
end)

for _, player in ipairs(tabs.killing.getPlayers()) do
	tabs.killing.SpectateDropdown:Add(player.DisplayName .. " | " .. player.Name)
end

utils.connect(services.Players.PlayerAdded, function(player)
	tabs.killing.SpectateDropdown:Add(player.DisplayName .. " | " .. player.Name)
	if getgenv().SpectateState.IsSpectating and getgenv().SpectateState.SavedUserId == player.UserId then
		tabs.killing.SpectateData.Spectating = true
		tabs.killing.SpectateData.SelectedPlayer = player
		tabs.killing.SpectateData.SelectedPlayerUserId = player.UserId
		tabs.killing.updateSpectateTarget(player)
	end
end)

utils.connect(services.Players.PlayerRemoving, function(player)
	tabs.killing.SpectateDropdown:Remove(player.DisplayName .. " | " .. player.Name)
	if player.UserId == tabs.killing.SpectateData.SelectedPlayerUserId then
		if tabs.killing.SpectateData.Spectating then
			tabs.killing.stopSpectating()

			tabs.killing.SpectateData.SelectedPlayer = nil
			tabs.killing.SpectateData.CurrentTargetConnection = nil

			tabs.killing.runtime.localPlayer_1275 = services.Players.LocalPlayer
			if tabs.killing.runtime.localPlayer_1275.Character and utils.playerData.Humanoid then
				utils.playerData.Camera.CameraSubject = utils.playerData.Humanoid
			end
		end
	end
end)

if tabs.killing.SpectateData.LocalPlayerRespawnConnection then
	tabs.killing.SpectateData.LocalPlayerRespawnConnection:Disconnect()
end

tabs.killing.SpectateData.LocalPlayerRespawnConnection = utils.connect(services.Players.LocalPlayer.CharacterAdded, function(char)
	tabs.killing.runtime.humanoid_1288 = char:WaitForChild("Humanoid", 3)
	if tabs.killing.runtime.humanoid_1288 then
		utils.playerData.Humanoid = tabs.killing.runtime.humanoid_1288
	end

	task.wait(0.5)

	if getgenv().SpectateState.IsSpectating then
		tabs.killing.SpectateData.Spectating = true
		tabs.killing.updateSpectateTarget()
		tabs.killing.startCameraMonitor()
	else
		if utils.playerData.Humanoid then
			utils.playerData.Camera.CameraSubject = utils.playerData.Humanoid
		end
	end
end)

tabs.killing:AddLabel("Kill Aura:")

tabs.killing.KillAura = {
	RingPart = nil,
	RingColor = Color3.fromRGB(0, 120, 255),
	RingTransparency = 0.6,
	CenterCFrame = nil,
	Frozen = false,
	Generation = 0
}
_G.showDeathRing = false
_G.deathRingRange = 20

tabs.killing.StaleRing = services.Workspace:FindFirstChild("HonenxWhiteKillAuraRing")
if tabs.killing.StaleRing then tabs.killing.StaleRing:Destroy() end

tabs.killing:AddTextBox("Range (1-140):", function(text)
	if tonumber(text) then
		_G.deathRingRange = math.clamp(tonumber(text), 1, 140)
		if tabs.killing.KillAura.RingPart then
			tabs.killing.KillAura.RingPart.Size = Vector3.new(0.2, _G.deathRingRange * 2, _G.deathRingRange * 2)
		end
	end
end, {clear = false})

tabs.killing.RingColors = {
	{Name = "HonenxWhite", Color = Color3.fromRGB(0, 120, 255)},
	{Name = "Red", Color = Color3.fromRGB(30, 150, 255)},
	{Name = "Orange", Color = Color3.fromRGB(255, 128, 0)},
	{Name = "Yellow", Color = Color3.fromRGB(255, 230, 0)},
	{Name = "Lime", Color = Color3.fromRGB(128, 255, 0)},
	{Name = "Green", Color = Color3.fromRGB(0, 200, 70)},
	{Name = "Cyan", Color = Color3.fromRGB(0, 220, 255)},
	{Name = "Blue", Color = Color3.fromRGB(0, 100, 255)},
	{Name = "Purple", Color = Color3.fromRGB(145, 70, 255)},
	{Name = "Pink", Color = Color3.fromRGB(255, 80, 180)},
	{Name = "White", Color = Color3.fromRGB(255, 255, 255)},
	{Name = "Black", Color = Color3.fromRGB(0, 0, 0)}
}

tabs.killing.RingColorDropdown = tabs.killing:AddDropdown("Ring Color", function(selection)
	for _, colorData in ipairs(tabs.killing.RingColors) do
		if colorData.Name == selection then
			tabs.killing.KillAura.RingColor = colorData.Color
			if tabs.killing.KillAura.RingPart then tabs.killing.KillAura.RingPart.Color = colorData.Color end
			break
		end
	end
end)
for _, colorData in ipairs(tabs.killing.RingColors) do
	tabs.killing.RingColorDropdown:Add(colorData.Name)
end

tabs.killing.destroyKillAuraRing = function()
	if tabs.killing.KillAura.RingPart then
		tabs.killing.KillAura.RingPart:Destroy()
		tabs.killing.KillAura.RingPart = nil
	end
end

tabs.killing.createKillAuraRing = function()
	tabs.killing.destroyKillAuraRing()
	tabs.killing.runtime.oldRing = services.Workspace:FindFirstChild("HonenxWhiteKillAuraRing")
	if tabs.killing.runtime.oldRing then tabs.killing.runtime.oldRing:Destroy() end

	tabs.killing.KillAura.RingPart = Instance.new("Part")
	tabs.killing.KillAura.RingPart.Name = "HonenxWhiteKillAuraRing"
	tabs.killing.KillAura.RingPart.Shape = Enum.PartType.Cylinder
	tabs.killing.KillAura.RingPart.Material = Enum.Material.Neon
	tabs.killing.KillAura.RingPart.Color = tabs.killing.KillAura.RingColor
	tabs.killing.KillAura.RingPart.Transparency = tabs.killing.KillAura.RingTransparency
	tabs.killing.KillAura.RingPart.Anchored = true
	tabs.killing.KillAura.RingPart.CanCollide = false
	tabs.killing.KillAura.RingPart.CanTouch = false
	tabs.killing.KillAura.RingPart.CanQuery = false
	tabs.killing.KillAura.RingPart.CastShadow = false
	tabs.killing.KillAura.RingPart.Size = Vector3.new(0.2, _G.deathRingRange * 2, _G.deathRingRange * 2)
	if tabs.killing.KillAura.CenterCFrame then
		tabs.killing.KillAura.RingPart.CFrame = tabs.killing.KillAura.CenterCFrame * CFrame.Angles(0, 0, math.rad(90))
	end
	tabs.killing.KillAura.RingPart.Parent = services.Workspace
end

tabs.killing.ShowRingSwitch = nil
tabs.killing.ShowRingSwitch = tabs.killing:AddSwitch("Show Ring", function(bool)
	if bool and not _G.deathRingEnabled then
		_G.showDeathRing = false
		tabs.killing.ShowRingSwitch:Set(false)
		return
	end

	_G.showDeathRing = bool
	if bool then
		tabs.killing.createKillAuraRing()
	else
		tabs.killing.destroyKillAuraRing()
	end
end)

if _G.deathRingConnection then
	_G.deathRingConnection:Disconnect()
	_G.deathRingConnection = nil
end

tabs.killing.updateKillAuraRing = function()
	if tabs.killing.KillAura.RingPart and tabs.killing.KillAura.CenterCFrame then
		tabs.killing.KillAura.RingPart.CFrame = tabs.killing.KillAura.CenterCFrame * CFrame.Angles(0, 0, math.rad(90))
	end
end

tabs.killing:AddSwitch("Toggle Ring", function(bool)
	_G.deathRingEnabled = bool
	tabs.killing.KillAura.Generation += 1
	tabs.killing.runtime.generation_1419 = tabs.killing.KillAura.Generation
	if not bool then
		if tabs.killing.ShowRingSwitch and _G.showDeathRing then tabs.killing.ShowRingSwitch:Set(false) end
		return
	end

	tabs.killing.runtime.discardCharacter_initialRoot, tabs.killing.runtime.discardHumanoid_initialRoot, tabs.killing.runtime.initialRoot = tabs.killing.getLocalCombatCharacter()
	if tabs.killing.runtime.initialRoot then tabs.killing.KillAura.CenterCFrame = tabs.killing.runtime.initialRoot.CFrame end

	task.spawn(function()
		while utils.isCurrent() and _G.deathRingEnabled and tabs.killing.KillAura.Generation == tabs.killing.runtime.generation_1419 do
			tabs.killing.runtime.discardCharacter_localRoot_1430, tabs.killing.runtime.discardHumanoid_localRoot_1430, tabs.killing.runtime.localRoot_1430 = tabs.killing.getLocalCombatCharacter()
			if tabs.killing.runtime.localRoot_1430 and not tabs.killing.KillAura.Frozen then
				tabs.killing.KillAura.CenterCFrame = tabs.killing.runtime.localRoot_1430.CFrame
			end
			tabs.killing.updateKillAuraRing()
			services.RunService.RenderStepped:Wait()
		end
	end)

	task.spawn(function()
		while utils.isCurrent() and _G.deathRingEnabled and tabs.killing.KillAura.Generation == tabs.killing.runtime.generation_1419 do
			if tabs.killing.KillAura.Frozen or not tabs.killing.KillAura.CenterCFrame then
				task.wait(0.05)
				continue
			end

			tabs.killing.runtime.centerCFrame = tabs.killing.KillAura.CenterCFrame
			tabs.killing.runtime.attackedPlayer = false
			for _, player in ipairs(services.Players:GetPlayers()) do
				if not _G.deathRingEnabled or tabs.killing.KillAura.Generation ~= tabs.killing.runtime.generation_1419 then break end
				tabs.killing.runtime.targetRoot_1450 = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
				if player ~= services.Players.LocalPlayer
					and not tabs.killing.isWhitelisted(player)
					and tabs.killing.isPlayerAlive(player)
					and not tabs.killing.isSpawnProtected(player)
					and tabs.killing.runtime.targetRoot_1450
					and (tabs.killing.runtime.centerCFrame.Position - tabs.killing.runtime.targetRoot_1450.Position).Magnitude <= _G.deathRingRange then
					tabs.killing.runtime.attackedPlayer = true
					tabs.killing.KillAura.Frozen = true
					tabs.killing.KillAura.CenterCFrame = tabs.killing.runtime.centerCFrame
					tabs.killing.updateKillAuraRing()

					tabs.killing.attackPlayerWithLimit(player, 4, function()
						tabs.killing.runtime.currentTargetRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
						return _G.deathRingEnabled
							and tabs.killing.KillAura.Generation == tabs.killing.runtime.generation_1419
							and not tabs.killing.isWhitelisted(player)
							and tabs.killing.runtime.currentTargetRoot
							and (tabs.killing.runtime.centerCFrame.Position - tabs.killing.runtime.currentTargetRoot.Position).Magnitude <= _G.deathRingRange
					end, 3.5)

					for _ = 1, 4 do
						tabs.killing.runtime.discardCharacter_currentLocalRoot, tabs.killing.runtime.discardHumanoid_currentLocalRoot, tabs.killing.runtime.currentLocalRoot = tabs.killing.getLocalCombatCharacter()
						if tabs.killing.runtime.currentLocalRoot then
							tabs.killing.runtime.currentLocalRoot.CFrame = tabs.killing.runtime.centerCFrame
							tabs.killing.runtime.currentLocalRoot.AssemblyLinearVelocity = Vector3.zero
							tabs.killing.runtime.currentLocalRoot.AssemblyAngularVelocity = Vector3.zero
						end
						tabs.killing.KillAura.CenterCFrame = tabs.killing.runtime.centerCFrame
						tabs.killing.updateKillAuraRing()
						services.RunService.Heartbeat:Wait()
					end
					tabs.killing.KillAura.Frozen = false
				end
			end

			if not tabs.killing.runtime.attackedPlayer then task.wait(0.05) end
		end
		tabs.killing.KillAura.Frozen = false
	end)
end)

tabs.killing.WhitelistLabel = tabs.killing:AddLabel("Whitelist: None")
tabs.killing.RemoveWhitelistDropdown = tabs.killing:AddDropdown("Remove from Whitelist", function(selectedDisplayName)
	for index = #_G.whitelistedPlayers, 1, -1 do
		if tabs.killing.getWhitelistDisplayName(_G.whitelistedPlayers[index]) == selectedDisplayName then
			table.remove(_G.whitelistedPlayers, index)
			break
		end
	end
	tabs.killing.RemoveWhitelistDropdown:Remove(selectedDisplayName)
end)

for _, playerName in ipairs(_G.whitelistedPlayers) do
	tabs.killing.RemoveWhitelistDropdown:Add(tabs.killing.getWhitelistDisplayName(playerName))
end

tabs.killing:AddButton("Clear Whitelist", function()
	_G.whitelistedPlayers = {}
	tabs.killing.RemoveWhitelistDropdown:Clear()
end)

tabs.killing.BlacklistLabel = tabs.killing:AddLabel("Killlist: None")
tabs.killing.RemoveKilllistDropdown = tabs.killing:AddDropdown("Remove from Killlist", function(selectedDisplayName)
	for index = #_G.blacklistedPlayers, 1, -1 do
		if tabs.killing.getKilllistDisplayName(_G.blacklistedPlayers[index]) == selectedDisplayName then
			table.remove(_G.blacklistedPlayers, index)
			break
		end
	end
	tabs.killing.RemoveKilllistDropdown:Remove(selectedDisplayName)
end)

for _, playerName in ipairs(_G.blacklistedPlayers) do
	tabs.killing.RemoveKilllistDropdown:Add(tabs.killing.getKilllistDisplayName(playerName))
end

tabs.killing:AddButton("Clear Killlist", function()
	_G.blacklistedPlayers = {}
	tabs.killing.RemoveKilllistDropdown:Clear()
end)

task.spawn(function()
	while utils.isCurrent() and true do
		local displayedWhitelist = {}
		for _, username in ipairs(_G.whitelistedPlayers) do
			table.insert(displayedWhitelist, tabs.killing.getWhitelistDisplayName(username))
		end
		tabs.killing.WhitelistLabel.Text = #displayedWhitelist == 0 and "Whitelist: None" or "Whitelist: " .. table.concat(displayedWhitelist, ", ")
		local displayedKilllist = {}
		for _, username in ipairs(_G.blacklistedPlayers) do
			table.insert(displayedKilllist, tabs.killing.getKilllistDisplayName(username))
		end
		tabs.killing.BlacklistLabel.Text = #displayedKilllist == 0 and "Killlist: None" or "Killlist: " .. table.concat(displayedKilllist, ", ")
		task.wait(0.01)
	end
end)

tabs.specs:AddLabel("Player Stats:")

tabs.specs.Data = {
	PlayerToInspect = nil,
	EmojiMap = {
		["Time"] = utf8.char(0x1F55B), ["Stats"] = utf8.char(0x1F4CA), ["Strength"] = utf8.char(0x1F4AA),
		["Rebirths"] = utf8.char(0x1F504), ["Durability"] = utf8.char(0x1F6E1), ["Kills"] = utf8.char(0x1F480),
		["Agility"] = "⚡", ["Evil Karma"] = utf8.char(0x1F608), ["Good Karma"] = utf8.char(0x1F607),
		["Brawls"] = utf8.char(0x1F94A)
	},
	StatDefinitions = {
		{name = "Strength", statName = "Strength"}, {name = "Rebirths", statName = "Rebirths"},
		{name = "Durability", statName = "Durability"}, {name = "Agility", statName = "Agility"},
		{name = "Kills", statName = "Kills"}, {name = "Evil Karma", statName = "evilKarma"},
		{name = "Good Karma", statName = "goodKarma"}, {name = "Brawls", statName = "Brawls"}
	},
	StatLabels = {}
}

tabs.specs.PlayerDropdown = tabs.specs:AddDropdown("Choose Player", function(text)
	for _, player in ipairs(services.Players:GetPlayers()) do
		if text == player.DisplayName .. " | " .. player.Name then
			tabs.specs.Data.PlayerToInspect = player
			break
		end
	end
end)

for _, player in ipairs(services.Players:GetPlayers()) do
	tabs.specs.PlayerDropdown:Add(player.DisplayName .. " | " .. player.Name)
end

utils.connect(services.Players.PlayerAdded, function(player)
	tabs.specs.PlayerDropdown:Add(player.DisplayName .. " | " .. player.Name)
end)

utils.connect(services.Players.PlayerRemoving, function(player)
	tabs.specs.PlayerDropdown:Remove(player.DisplayName .. " | " .. player.Name)
	if tabs.specs.Data.PlayerToInspect == player then tabs.specs.Data.PlayerToInspect = nil end
end)

tabs.specs.PlayerNameLabel = tabs.specs:AddLabel("👤 Name: N/A")
tabs.specs.PlayerUsernameLabel = tabs.specs:AddLabel("🎫 Username: N/A")

for _, info in ipairs(tabs.specs.Data.StatDefinitions) do
	tabs.specs.Data.StatLabels[info.name] = tabs.specs:AddLabel(tabs.specs.Data.EmojiMap[info.name] .. " " .. info.name .. ": N/A")
end

tabs.specs.updateStatLabels = function(targetPlayer)
	if not targetPlayer then return end
	tabs.specs.PlayerNameLabel.Text = "👤 Name: " .. targetPlayer.DisplayName
	tabs.specs.PlayerUsernameLabel.Text = "🎫 Username: " .. targetPlayer.Name
	if not targetPlayer:FindFirstChild("leaderstats") then return end
	for _, info in ipairs(tabs.specs.Data.StatDefinitions) do
		tabs.specs.runtime.statObject = targetPlayer.leaderstats:FindFirstChild(info.statName) or targetPlayer:FindFirstChild(info.statName)
		if tabs.specs.runtime.statObject then
			tabs.specs.Data.StatLabels[info.name].Text = string.format("%s %s: %s (%s)", tabs.specs.Data.EmojiMap[info.name] or "", info.name,
				utils.formatNumber(tabs.specs.runtime.statObject.Value), utils.formatWithCommas(tabs.specs.runtime.statObject.Value))
		else
			tabs.specs.Data.StatLabels[info.name].Text = tabs.specs.Data.EmojiMap[info.name] .. " " .. info.name .. ": 0 (0)"
		end
	end
end

task.spawn(function()
	while utils.isCurrent() and true do
		if tabs.specs.Data.PlayerToInspect then tabs.specs.updateStatLabels(tabs.specs.Data.PlayerToInspect) end
		task.wait(0.1)
	end
end)

tabs.specs:AddLabel("———————————————————————————————————")
tabs.specs:AddLabel("Advanced Stats:")

tabs.specs.AdvancedStats = {
	HealthLabel = tabs.specs:AddLabel("🛡️ Enemy Health: N/A"),
	EnemyDamageLabel = tabs.specs:AddLabel("💥 Enemy Damage: N/A"),
	PlayerHealthLabel = tabs.specs:AddLabel("🛡️ Your Health: N/A"),
	PlayerDamageLabel = tabs.specs:AddLabel("💥 Your Damage: N/A"),
	HitsToKillLabel = tabs.specs:AddLabel("👊 Hits to Kill: N/A")
}

tabs.specs.StatsCache = {
	health = 0,
	enemyDamage = 0,
	playerHealth = 0,
	playerDamage = 0,
	hitsToKill = "N/A"
}

tabs.specs.calculatePlayerHealth = function(targetPlayer)
	if not targetPlayer then return 0 end
	tabs.specs.runtime.durabilityStat = targetPlayer:FindFirstChild("Durability") or
		(targetPlayer:FindFirstChild("leaderstats") and targetPlayer.leaderstats:FindFirstChild("Durability"))
	if not tabs.specs.runtime.durabilityStat then return 0 end
	tabs.specs.runtime.totalMultiplier_1635 = 1
	if targetPlayer:FindFirstChild("ultimatesFolder") and targetPlayer.ultimatesFolder:FindFirstChild("Infernal Health") then
		tabs.specs.runtime.totalMultiplier_1635 = tabs.specs.runtime.totalMultiplier_1635 + 0.15 * (targetPlayer.ultimatesFolder["Infernal Health"].Value or 0)
	end
	if targetPlayer:FindFirstChild("equippedPets") then
		for _, petValue in ipairs(targetPlayer.equippedPets:GetChildren()) do
			if petValue:IsA("ObjectValue") and petValue.Value then
				if string.lower(petValue.Value.Name):match("mighty") and string.lower(petValue.Value.Name):match("monster") then
					tabs.specs.runtime.totalMultiplier_1635 = tabs.specs.runtime.totalMultiplier_1635 + 0.5
				end
				if string.lower(petValue.Value.Name):match("small") and string.lower(petValue.Value.Name):match("fry") then
					tabs.specs.runtime.totalMultiplier_1635 = tabs.specs.runtime.totalMultiplier_1635 + 0.25
				end
			end
		end
	end
	return tabs.specs.runtime.durabilityStat.Value * tabs.specs.runtime.totalMultiplier_1635
end

tabs.specs.calculatePlayerDamage = function(targetPlayer)
	if not targetPlayer then return 0 end
	if not targetPlayer:FindFirstChild("leaderstats") or not targetPlayer.leaderstats:FindFirstChild("Strength") then return 0 end
	tabs.specs.runtime.baseDamage = targetPlayer.leaderstats.Strength.Value * 0.066666666666666666666666666666666666666666666667
	tabs.specs.runtime.totalMultiplier_1658 = 1
	if targetPlayer:FindFirstChild("ultimatesFolder") and targetPlayer.ultimatesFolder:FindFirstChild("Demon Damage") then
		tabs.specs.runtime.totalMultiplier_1658 = tabs.specs.runtime.totalMultiplier_1658 + 0.1 * (targetPlayer.ultimatesFolder["Demon Damage"].Value or 0)
	end
	if targetPlayer:FindFirstChild("equippedPets") then
		for _, petValue in ipairs(targetPlayer.equippedPets:GetChildren()) do
			if petValue:IsA("ObjectValue") and petValue.Value then
				if string.lower(petValue.Value.Name):match("wild") and string.lower(petValue.Value.Name):match("wizard") then
					tabs.specs.runtime.totalMultiplier_1658 = tabs.specs.runtime.totalMultiplier_1658 + 0.5
				end
				if string.lower(petValue.Value.Name):match("chaos") and string.lower(petValue.Value.Name):match("sorcerer") then
					tabs.specs.runtime.totalMultiplier_1658 = tabs.specs.runtime.totalMultiplier_1658 + 0.25
				end
			end
		end
	end
	return tabs.specs.runtime.baseDamage * tabs.specs.runtime.totalMultiplier_1658
end

tabs.specs.updateAdvancedStats = function(targetPlayer)
	if not targetPlayer then
		tabs.specs.AdvancedStats.HealthLabel.Text = "🛡️ Enemy Health: N/A"
		tabs.specs.AdvancedStats.EnemyDamageLabel.Text = "💥 Enemy Damage: N/A"
		tabs.specs.AdvancedStats.PlayerHealthLabel.Text = "🛡️ Your Health: N/A"
		tabs.specs.AdvancedStats.PlayerDamageLabel.Text = "💥 Your Damage: N/A"
		tabs.specs.AdvancedStats.HitsToKillLabel.Text = "👊 Hits to Kill: N/A"
		return
	end

	tabs.specs.StatsCache.health = tabs.specs.calculatePlayerHealth(targetPlayer)
	tabs.specs.StatsCache.enemyDamage = tabs.specs.calculatePlayerDamage(targetPlayer)
	tabs.specs.StatsCache.playerHealth = tabs.specs.calculatePlayerHealth(utils.playerData.Player)
	tabs.specs.StatsCache.playerDamage = tabs.specs.calculatePlayerDamage(utils.playerData.Player)
	tabs.specs.StatsCache.hitsToKill = tabs.specs.StatsCache.playerDamage <= 0 and "∞" or (math.ceil(tabs.specs.StatsCache.health / tabs.specs.StatsCache.playerDamage) > 200 and "∞" or
		(math.ceil(tabs.specs.StatsCache.health / tabs.specs.StatsCache.playerDamage) < 1 and "instant" or math.ceil(tabs.specs.StatsCache.health / tabs.specs.StatsCache.playerDamage)))

	tabs.specs.AdvancedStats.HealthLabel.Text = string.format("🛡️ Enemy Health: %s (%s)", utils.formatNumber(tabs.specs.StatsCache.health), utils.formatWithCommas(tabs.specs.StatsCache.health))
	tabs.specs.AdvancedStats.EnemyDamageLabel.Text = string.format("💥 Enemy Damage: %s (%s)", utils.formatNumber(tabs.specs.StatsCache.enemyDamage), utils.formatWithCommas(tabs.specs.StatsCache.enemyDamage))
	tabs.specs.AdvancedStats.PlayerHealthLabel.Text = string.format("🛡️ Your Health: %s (%s)", utils.formatNumber(tabs.specs.StatsCache.playerHealth), utils.formatWithCommas(tabs.specs.StatsCache.playerHealth))
	tabs.specs.AdvancedStats.PlayerDamageLabel.Text = string.format("💥 Your Damage: %s (%s)", utils.formatNumber(tabs.specs.StatsCache.playerDamage), utils.formatWithCommas(tabs.specs.StatsCache.playerDamage))
	tabs.specs.AdvancedStats.HitsToKillLabel.Text = string.format("👊 Hits to Kill: %s", tostring(tabs.specs.StatsCache.hitsToKill))
end

task.spawn(function()
	while utils.isCurrent() and true do
		tabs.specs.updateAdvancedStats(tabs.specs.Data.PlayerToInspect)
		task.wait(0.1)
	end
end)


tabs.farming:AddLabel("Rebirths:")

tabs.farming.RebirthData = {
	Label = tabs.farming:AddLabel("Rebirths: 0"),
	TargetLabel = tabs.farming:AddLabel("Target: None"),
	Rebirths = utils.playerData.Player.leaderstats:WaitForChild("Rebirths"),
	TargetRebirths = 0,
	IsAutoRebirthing = false
}


tabs.farming:AddTextBox("Set Rebirth Target (Required):", function(text)
	if tonumber(text) and tonumber(text) >= 0 then tabs.farming.RebirthData.TargetRebirths = tonumber(text) end
end)

tabs.farming.RebirthData.Switch = tabs.farming:AddSwitch("Auto Rebirth", function(enabled)
	if enabled and tabs.farming.RebirthData.TargetRebirths > 0 and tabs.farming.RebirthData.Rebirths.Value < tabs.farming.RebirthData.TargetRebirths then
		tabs.farming.RebirthData.IsAutoRebirthing = true
		task.spawn(function()
			while utils.isCurrent() and tabs.farming.RebirthData.IsAutoRebirthing and tabs.farming.RebirthData.Rebirths.Value < tabs.farming.RebirthData.TargetRebirths do
				services.ReplicatedStorage.rEvents.rebirthRemote:InvokeServer("rebirthRequest")
				task.wait(0.05)
			end
			tabs.farming.RebirthData.IsAutoRebirthing = false
			tabs.farming.RebirthData.Switch:Set(false)
		end)
	else
		tabs.farming.RebirthData.IsAutoRebirthing = false
	end
end)

task.spawn(function()
	while utils.isCurrent() and true do
		tabs.farming.RebirthData.Label.Text = "Rebirths: " .. utils.formatWithCommas(tabs.farming.RebirthData.Rebirths.Value)
		tabs.farming.RebirthData.TargetLabel.Text = "Target Rebirths: " .. utils.formatWithCommas(tabs.farming.RebirthData.TargetRebirths)
		task.wait(0.01)
	end
end)

tabs.farming.SizeData = {Active = false}

tabs.farming.SizeSwitch = tabs.farming:AddSwitch("Auto Size 1", function(bool) tabs.farming.SizeData.Active = bool end)
tabs.farming.SizeSwitch:Set(false)

task.spawn(function()
	while utils.isCurrent() and true do
		if tabs.farming.SizeData.Active and utils.playerData.Character and utils.playerData.Humanoid then
			utils.remotes.ChangeSpeedSize:InvokeServer("changeSize", 1)
		end
		task.wait(0.01)
	end
end)

tabs.farming.KingData = {TargetPosition = CFrame.new(-8665.4, 17.21, -5792.9), TeleportActive = false}

tabs.farming.KingSwitch = tabs.farming:AddSwitch("Auto King", function(enabled)
	tabs.farming.KingData.TeleportActive = enabled
end)

task.spawn(function()
	while utils.isCurrent() and true do
		if tabs.farming.KingData.TeleportActive then
			if not utils.playerData.Character or not utils.playerData.Character:FindFirstChildOfClass("Humanoid") then
				utils.playerData.Player.CharacterAdded:Wait()
				utils.playerData.Character = utils.playerData.Player.Character
				task.wait(2)
			end

			if not utils.playerData.Humanoid or utils.playerData.Humanoid.Health <= 0 then
				repeat
					task.wait(0.5)
					utils.playerData.Character = utils.playerData.Player.Character
					utils.playerData.Humanoid = utils.playerData.Character and utils.playerData.Character:FindFirstChildOfClass("Humanoid")
				until utils.playerData.Character and utils.playerData.Humanoid and utils.playerData.Humanoid.Health > 0
				task.wait(1)
			end

			if utils.playerData.Character and utils.playerData.Character:FindFirstChild("HumanoidRootPart") then
				if (utils.playerData.Character.HumanoidRootPart.Position - tabs.farming.KingData.TargetPosition.Position).magnitude > 5 then
					pcall(function()
						utils.playerData.Character.HumanoidRootPart.CFrame = tabs.farming.KingData.TargetPosition
					end)
				end
			end
		end
		task.wait(0.05)
	end
end)

tabs.farming:AddLabel("Auto Exercises (recommended for rebirthing):")

tabs.farming.ExerciseData = {
	SelectedTool = nil,
	AutoFarm = false
}

tabs.farming.ToolDropdown = tabs.farming:AddDropdown("Select Exercise", function(selection)
	tabs.farming.ExerciseData.SelectedTool = selection
end)
for _, tool in ipairs({"Weight", "Pushups", "Situps", "Handstands"}) do
	tabs.farming.ToolDropdown:Add(tool)
end

tabs.farming.MachinesFolder = services.Workspace:WaitForChild("machinesFolder")
tabs.farming.SquatsByName = {}
tabs.farming.SquatMachineNames = {}
tabs.farming.LiftMachineNames = {}
tabs.farming.MachineExerciseData = {
	Squat = {SelectedMachine = nil, ActiveMachine = nil, Running = false, Generation = 0, ReenterAt = 0, SeatPart = nil, Choices = {}},
	Lift = {SelectedMachine = nil, ActiveMachine = nil, Running = false, Generation = 0, ReenterAt = 0, SeatPart = nil, Choices = {}}
}

for _, machine in ipairs(tabs.farming.MachinesFolder:GetChildren()) do
	tabs.farming.runtime.lowerName = string.lower(machine.Name)
	if string.find(tabs.farming.runtime.lowerName, "squat", 1, true) and tabs.farming.runtime.lowerName ~= "squat rack" then
		tabs.farming.SquatsByName[machine.Name] = tabs.farming.SquatsByName[machine.Name] or {}
		table.insert(tabs.farming.SquatsByName[machine.Name], machine)
	elseif string.find(tabs.farming.runtime.lowerName, "lift", 1, true) and tabs.farming.runtime.lowerName ~= "deadlift" then
		tabs.farming.MachineExerciseData.Lift.Choices[machine.Name] = machine
		table.insert(tabs.farming.LiftMachineNames, machine.Name)
	end
end

for machineName, matchingSquats in pairs(tabs.farming.SquatsByName) do
	tabs.farming.MachineExerciseData.Squat.Choices[machineName] = matchingSquats[1]
	table.insert(tabs.farming.SquatMachineNames, machineName)
end

table.sort(tabs.farming.SquatMachineNames)
table.sort(tabs.farming.LiftMachineNames)

tabs.farming.getMachineInteractPart = function(machine)
	for _, descendant in ipairs(machine:GetDescendants()) do
		if descendant:IsA("BasePart") and string.lower(descendant.Name) == "interactseat" then
			return descendant
		end
	end
end

tabs.farming.enterExerciseMachine = function(machine)
	if not machine or not machine.Parent then return false end

	tabs.farming.runtime.character_1850 = utils.playerData.Player.Character or utils.playerData.Player.CharacterAdded:Wait()
	tabs.farming.runtime.humanoidRootPart = tabs.farming.runtime.character_1850:WaitForChild("HumanoidRootPart", 5)
	tabs.farming.runtime.interactPart = tabs.farming.getMachineInteractPart(machine)
	if not tabs.farming.runtime.humanoidRootPart or not tabs.farming.runtime.interactPart then return false end

	tabs.farming.runtime.humanoidRootPart.CFrame = tabs.farming.runtime.interactPart.CFrame * CFrame.new(0, 3, 0)
	tabs.farming.runtime.humanoidRootPart.AssemblyLinearVelocity = Vector3.zero
	tabs.farming.runtime.humanoidRootPart.AssemblyAngularVelocity = Vector3.zero
	task.wait(0.4)
	services.VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
	task.wait(0.1)
	services.VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
	task.wait(0.4)
	return true
end

tabs.farming.ToolExerciseSwitch = nil
tabs.farming.SquatExerciseSwitch = nil
tabs.farming.LiftExerciseSwitch = nil

tabs.farming.ToolExerciseSwitch = tabs.farming:AddSwitch("Start exercising", function(enabled)
	tabs.farming.ExerciseData.AutoFarm = enabled

	if enabled then
		if tabs.farming.SquatExerciseSwitch and tabs.farming.MachineExerciseData.Squat.Running then tabs.farming.SquatExerciseSwitch:Set(false) end
		if tabs.farming.LiftExerciseSwitch and tabs.farming.MachineExerciseData.Lift.Running then tabs.farming.LiftExerciseSwitch:Set(false) end

		task.spawn(function()
			while utils.isCurrent() and tabs.farming.ExerciseData.AutoFarm do
				if utils.playerData.Character ~= utils.playerData.Player.Character then
					utils.playerData.Character = utils.playerData.Player.Character
					utils.playerData.Humanoid = utils.playerData.Character and utils.playerData.Character:FindFirstChildOfClass("Humanoid")
				end

				if not utils.playerData.Character or not utils.playerData.Character:FindFirstChildOfClass("Humanoid") then
					utils.playerData.Player.CharacterAdded:Wait()
					utils.playerData.Character = utils.playerData.Player.Character
					utils.playerData.Humanoid = utils.playerData.Character and utils.playerData.Character:FindFirstChildOfClass("Humanoid")
					task.wait(2)
				end

				if not utils.playerData.Humanoid or utils.playerData.Humanoid.Health <= 0 then
					repeat
						task.wait(0.5)
						utils.playerData.Character = utils.playerData.Player.Character
						utils.playerData.Humanoid = utils.playerData.Character and utils.playerData.Character:FindFirstChildOfClass("Humanoid")
					until utils.playerData.Character and utils.playerData.Humanoid and utils.playerData.Humanoid.Health > 0
					task.wait(1)
				end

				if utils.playerData.Character and tabs.farming.ExerciseData.SelectedTool then
					tabs.farming.runtime.toolName = tabs.farming.ExerciseData.SelectedTool

					if not utils.playerData.Character:FindFirstChild(tabs.farming.runtime.toolName) then
						tabs.farming.runtime.toolInBackpack = utils.playerData.Player.Backpack:FindFirstChild(tabs.farming.runtime.toolName)
						if tabs.farming.runtime.toolInBackpack then
							utils.playerData.Humanoid:EquipTool(tabs.farming.runtime.toolInBackpack)
							task.wait(0.2)
						end
					end

					if utils.playerData.Character:FindFirstChild(tabs.farming.runtime.toolName) then
						pcall(function()
							utils.playerData.Player.muscleEvent:FireServer("rep")
						end)
					end

					if tabs.farming.runtime.toolName == "Handstands" and tick() % 6 < 0.1 then
						pcall(function()
							services.VirtualUser:CaptureController()
							services.VirtualUser:ClickButton1(Vector2.new(500, 500))
						end)
					end
				end

				task.wait()
			end
		end)
	else
		if tabs.farming.ExerciseData.SelectedTool and utils.playerData.Player.Character then
			tabs.farming.runtime.equippedTool = utils.playerData.Player.Character:FindFirstChild(tabs.farming.ExerciseData.SelectedTool)
			if tabs.farming.runtime.equippedTool then
				tabs.farming.runtime.equippedTool.Parent = utils.playerData.Player.Backpack
			end
		end
	end
end)

tabs.farming.addMachineDropdown = function(label, machineData, machineNames)
	tabs.farming.runtime.dropdown = tabs.farming:AddDropdown(label, function(selection)
		machineData.SelectedMachine = machineData.Choices[selection]
		machineData.ActiveMachine = nil
		machineData.SeatPart = nil
		machineData.ReenterAt = 0
	end)

	for _, machineName in ipairs(machineNames) do
		tabs.farming.runtime.dropdown:Add(machineName)
	end
end

tabs.farming.startMachineExercise = function(machineData)
	machineData.Generation += 1
	tabs.farming.runtime.generation = machineData.Generation
	tabs.farming.runtime.lastCharacter = utils.playerData.Player.Character

	task.spawn(function()
		while utils.isCurrent() and machineData.Running and machineData.Generation == tabs.farming.runtime.generation do
			tabs.farming.runtime.character_1958 = utils.playerData.Player.Character
			tabs.farming.runtime.humanoid = tabs.farming.runtime.character_1958 and tabs.farming.runtime.character_1958:FindFirstChildOfClass("Humanoid")

			if tabs.farming.runtime.character_1958 ~= tabs.farming.runtime.lastCharacter then
				tabs.farming.runtime.lastCharacter = tabs.farming.runtime.character_1958
				machineData.ActiveMachine = nil
				machineData.SeatPart = nil
				machineData.ReenterAt = os.clock() + 3.5
			end

			if not tabs.farming.runtime.character_1958 or not tabs.farming.runtime.humanoid or tabs.farming.runtime.humanoid.Health <= 0 then
				machineData.ActiveMachine = nil
				machineData.SeatPart = nil
				machineData.ReenterAt = math.max(machineData.ReenterAt, os.clock() + 3.5)
				task.wait(0.1)
				continue
			end

			tabs.farming.runtime.humanoidState = tabs.farming.runtime.humanoid:GetState()
			tabs.farming.runtime.jumpedOff = machineData.ActiveMachine and (
				tabs.farming.runtime.humanoidState == Enum.HumanoidStateType.Jumping
				or tabs.farming.runtime.humanoidState == Enum.HumanoidStateType.Freefall
				or (machineData.SeatPart and tabs.farming.runtime.humanoid.SeatPart ~= machineData.SeatPart)
			)

			if tabs.farming.runtime.jumpedOff then
				machineData.ActiveMachine = nil
				machineData.SeatPart = nil
				machineData.ReenterAt = os.clock() + 3.5
			end

			if machineData.SelectedMachine and not machineData.ActiveMachine and os.clock() >= machineData.ReenterAt then
				if tabs.farming.enterExerciseMachine(machineData.SelectedMachine) then
					machineData.ActiveMachine = machineData.SelectedMachine
					machineData.SeatPart = tabs.farming.runtime.humanoid.SeatPart
				end
			end

			task.wait(0.1)
		end
	end)
end

tabs.farming.setMachineExerciseState = function(machineData, otherMachineData, state)
	machineData.Running = state
	machineData.Generation += 1
	machineData.ActiveMachine = nil
	machineData.SeatPart = nil
	machineData.ReenterAt = 0

	if not state then return end
	if tabs.farming.ToolExerciseSwitch and tabs.farming.ExerciseData.AutoFarm then tabs.farming.ToolExerciseSwitch:Set(false) end
	if otherMachineData.Running then
		if machineData == tabs.farming.MachineExerciseData.Squat and tabs.farming.LiftExerciseSwitch then
			tabs.farming.LiftExerciseSwitch:Set(false)
		elseif machineData == tabs.farming.MachineExerciseData.Lift and tabs.farming.SquatExerciseSwitch then
			tabs.farming.SquatExerciseSwitch:Set(false)
		end
	end
	tabs.farming.startMachineExercise(machineData)
	task.spawn(function(generation)
		while utils.isCurrent() and machineData.Running and machineData.Generation == generation do
			if machineData.ActiveMachine then utils.playerData.Player.muscleEvent:FireServer("rep") end
			task.wait(0.1)
		end
	end, machineData.Generation)
end

tabs.farming.addMachineDropdown("Select Squat", tabs.farming.MachineExerciseData.Squat, tabs.farming.SquatMachineNames)
tabs.farming.SquatExerciseSwitch = tabs.farming:AddSwitch("Auto Squat", function(state)
	tabs.farming.setMachineExerciseState(tabs.farming.MachineExerciseData.Squat, tabs.farming.MachineExerciseData.Lift, state)
end)

tabs.farming.addMachineDropdown("Select Lift", tabs.farming.MachineExerciseData.Lift, tabs.farming.LiftMachineNames)
tabs.farming.LiftExerciseSwitch = tabs.farming:AddSwitch("Auto Lift", function(state)
	tabs.farming.setMachineExerciseState(tabs.farming.MachineExerciseData.Lift, tabs.farming.MachineExerciseData.Squat, state)
end)

tabs.farming.AutoRepRunning = false
tabs.farming.AutoRepSwitch = tabs.farming:AddSwitch("Auto Rep", function(state)
	tabs.farming.AutoRepRunning = state
	if not state then return end
	task.spawn(function()
		while utils.isCurrent() and tabs.farming.AutoRepRunning do
			utils.playerData.Player.muscleEvent:FireServer("rep")
			task.wait(0.1)
		end
	end)
end)

tabs.farming:AddLabel("Auto Rock:")

tabs.farming.RockData = {
	Data = {["Tiny Rock - 0 Dura"] = 0, ["Large Rock - 100 Dura"] = 100, ["Punching Rock - 10 Dura"] = 10,
		["Golden Rock - 5k Dura"] = 5000, ["Frost Rock - 150k Dura"] = 150000, ["Mythical Rock - 400k Dura"] = 400000,
		["Eternal Rock - 750k Dura"] = 750000, ["Legend Rock - 1m Dura"] = 1000000, ["Muscle King Rock - 5m Dura"] = 5000000,
		["Jungle Rock - 10m Dura"] = 10000000, ["Industrial Rock - 25m Dura"] = 25000000,},
	SelectedRock = nil
}

tabs.farming.RockDropdown = tabs.farming:AddDropdown("Select Rock", function(selection) tabs.farming.RockData.SelectedRock = selection end)
for rockName in pairs(tabs.farming.RockData.Data) do tabs.farming.RockDropdown:Add(rockName) end

tabs.farming.RockSwitch = tabs.farming:AddSwitch("Auto Rock", function(enabled)
	getgenv().RockFarmRunning = enabled
	if enabled and tabs.farming.RockData.SelectedRock then
		task.spawn(function()
			while utils.isCurrent() and getgenv().RockFarmRunning do
				task.wait(0.12)
				if utils.playerData.Player.Durability.Value >= tabs.farming.RockData.Data[tabs.farming.RockData.SelectedRock] then
					for _, v in pairs(tabs.farming.MachinesFolder:GetDescendants()) do
						if v.Name == "neededDurability" and v.Value == tabs.farming.RockData.Data[tabs.farming.RockData.SelectedRock] and
						   utils.playerData.Player.Character:FindFirstChild("LeftHand") and v.Parent:FindFirstChild("Rock") then
							firetouchinterest(v.Parent.Rock, utils.playerData.Player.Character.RightHand, 0)
							firetouchinterest(v.Parent.Rock, utils.playerData.Player.Character.RightHand, 1)
							firetouchinterest(v.Parent.Rock, utils.playerData.Player.Character.LeftHand, 0)
							firetouchinterest(v.Parent.Rock, utils.playerData.Player.Character.LeftHand, 1)
							tabs.killing.getTool()
						end
					end
				end
			end
		end)
	end
end)

tabs.farming:AddLabel("Better Strength Farming:")

tabs.farming.Configs = {
	{name = "Pushup + Industrial Rock", tool = "Pushups", rock = "Industrial Rock"},
	{name = "Pushup + Jungle Rock", tool = "Pushups", rock = "Ancient Jungle Rock"},
	{name = "Pushup + Muscle King Rock", tool = "Pushups", rock = "Muscle King Mountain"},
	{name = "Pushup + Legends Rock", tool = "Pushups", rock = "Rock Of Legends"}
}
tabs.farming.ActiveConfigs = {}

for _, config in ipairs(tabs.farming.Configs) do
	tabs.farming.ActiveConfigs[config.name] = false
	config.Switch = tabs.farming:AddSwitch(config.name, function(state)
		tabs.farming.ActiveConfigs[config.name] = state
		if tabs.farming.ActiveConfigs[config.name] then
			if utils.playerData.Player.Backpack:FindFirstChild(config.tool) and not utils.playerData.Player.Character:FindFirstChild(config.tool) then
				utils.playerData.Player.Character.Humanoid:EquipTool(utils.playerData.Player.Backpack[config.tool])
			end
			task.spawn(function()
				while utils.isCurrent() and tabs.farming.ActiveConfigs[config.name] do
					utils.playerData.Player.muscleEvent:FireServer("rep")
					if tabs.farming.MachinesFolder:FindFirstChild(config.rock) and utils.playerData.Player.Character:FindFirstChild("LeftHand") then
						firetouchinterest(tabs.farming.MachinesFolder[config.rock].Rock, utils.playerData.Player.Character.LeftHand, 0)
						firetouchinterest(tabs.farming.MachinesFolder[config.rock].Rock, utils.playerData.Player.Character.LeftHand, 1)
					end
					if utils.playerData.Player.Backpack:FindFirstChild("Punch") then
						utils.playerData.Humanoid:EquipTool(utils.playerData.Player.Backpack.Punch)
						utils.playerData.Player.muscleEvent:FireServer("punch", "rightHand")
						utils.playerData.Player.muscleEvent:FireServer("punch", "leftHand")
					end
					services.RunService.RenderStepped:Wait()
					if utils.playerData.Player.Backpack:FindFirstChild(config.tool) then
						utils.playerData.Player.Character.Humanoid:EquipTool(utils.playerData.Player.Backpack[config.tool])
					end
				end
			end)
		else
			if utils.playerData.Player.Character:FindFirstChild(config.tool) then
				utils.playerData.Player.Character[config.tool].Parent = utils.playerData.Player.Backpack
			end
		end
	end)
end

tabs.boss:AddLabel("Boss Farming:")
tabs.boss.StatusLabel = tabs.boss:AddLabel("Status: Waiting for Boss")
tabs.boss.BossLabel = tabs.boss:AddLabel("Boss: None")
tabs.boss.HealthLabel = tabs.boss:AddLabel("Health: 0 / 0")
tabs.boss.NextBossLabel = tabs.boss:AddLabel("Next Boss: N/A")

tabs.boss.Data = {
	Running = false,
	Generation = 0,
	ContinueTraining = true,
	Phase = "Waiting",
	TrainingSnapshot = nil,
	PunchInterval = 0.3,
	LastPunch = 0,
	AttackSequence = nil,
	EvadeUntil = 0,
	EvadeDistance = 230,
	PunchBehindDistance = 45,
	StompHealthThreshold = 0.35,
	DodgeStomps = false,
	BossConfig = nil,
	Bosses = {},
	BossOrder = {},
	BossByDisplayName = {},
	SelectedBosses = {}
}

tabs.boss.SelectedBossesLabel = tabs.boss:AddLabel("Targeted Bosses: Detecting...")
tabs.boss.BossDropdown = tabs.boss:AddDropdown("Target specific Bosses", function(displayName)
	tabs.boss.runtime.bossModelName = tabs.boss.Data.BossByDisplayName[displayName]
	if tabs.boss.runtime.bossModelName then
		tabs.boss.Data.SelectedBosses[tabs.boss.runtime.bossModelName] = not tabs.boss.Data.SelectedBosses[tabs.boss.runtime.bossModelName]
		tabs.boss.updateSelectedBossesLabel()
	end
end)

tabs.boss.updateSelectedBossesLabel = function(selectedNames)
	selectedNames = {}
	for _, modelName in ipairs(tabs.boss.Data.BossOrder) do
		if tabs.boss.Data.SelectedBosses[modelName] then
			table.insert(selectedNames, (string.gsub(tabs.boss.Data.Bosses[modelName], "%s+[Bb][Oo][Ss][Ss]$", "")))
		end
	end
	tabs.boss.SelectedBossesLabel.Text = "Targeted Bosses: " .. (#selectedNames > 0 and table.concat(selectedNames, ", ") or "None")
end

tabs.boss.addBossChoice = function(modelName, displayName)
	modelName = tostring(modelName or "")
	displayName = tostring(displayName or modelName)
	if modelName == "" or tabs.boss.Data.Bosses[modelName] then return end
	tabs.boss.Data.Bosses[modelName] = displayName
	tabs.boss.Data.BossByDisplayName[displayName] = modelName
	tabs.boss.Data.SelectedBosses[modelName] = true
	table.insert(tabs.boss.Data.BossOrder, modelName)
	tabs.boss.BossDropdown:Add(displayName)
	tabs.boss.updateSelectedBossesLabel()
end

tabs.boss.runtime.configSuccess, tabs.boss.Data.BossConfig = pcall(function()
	return require(services.ReplicatedStorage:WaitForChild("shared"):WaitForChild("config"):WaitForChild("BossEventConfig"))
end)
if tabs.boss.runtime.configSuccess and tabs.boss.Data.BossConfig and tabs.boss.Data.BossConfig.RARITIES then
	for _, rarity in ipairs(tabs.boss.Data.BossConfig.RARITIES) do
		tabs.boss.addBossChoice(rarity.BossModel, rarity.DisplayName or rarity.Name or rarity.BossModel)
	end
else
	tabs.boss.SelectedBossesLabel.Text = "Farmed Bosses: Waiting for detection"
end

tabs.boss.shouldFarmBoss = function(model)
	if not tabs.boss.Data.Bosses[model.Name] then
		tabs.boss.addBossChoice(model.Name, services.Workspace:GetAttribute("BossDisplayName") or model.Name)
	end
	return tabs.boss.Data.SelectedBosses[model.Name] == true
end

tabs.boss.findActiveBoss = function(model, stats, health, maxHealth, hitbox)
	for _, candidate in ipairs(services.CollectionService:GetTagged("BossEventBoss")) do
		if candidate:IsA("Model") and candidate:IsDescendantOf(services.Workspace) then
			model = candidate
			break
		end
	end

	if not model then
		tabs.boss.runtime.events = services.Workspace:FindFirstChild("Events")
		tabs.boss.runtime.bossFolder = tabs.boss.runtime.events and (tabs.boss.runtime.events:FindFirstChild("BossEvent") or tabs.boss.runtime.events:FindFirstChild("BossArena"))
		if tabs.boss.runtime.bossFolder then
			for _, candidate in ipairs(tabs.boss.runtime.bossFolder:GetDescendants()) do
				if candidate:IsA("Model") and (candidate:FindFirstChild("BossDamageHitbox") or candidate:HasTag("BossEventBoss")) then
					model = candidate
					break
				end
			end
		end
	end

	if not model then return end
	stats = model:FindFirstChild("stats")
	health = stats and stats:FindFirstChild("Health")
	maxHealth = stats and stats:FindFirstChild("MaxHealth")
	hitbox = model:FindFirstChild("BossDamageHitbox", true)
	if not hitbox or not hitbox:IsA("BasePart") then return end
	tabs.boss.runtime.currentHealth = health and health.Value or services.Workspace:GetAttribute("BossHealth")
	if typeof(tabs.boss.runtime.currentHealth) == "number" and tabs.boss.runtime.currentHealth <= 0 then return end
	return model, health, maxHealth, hitbox
end

tabs.boss.getBossHealth = function(health)
	return health and health.Value or services.Workspace:GetAttribute("BossHealth") or 0
end

tabs.boss.getBossMaxHealth = function(maxHealth)
	return maxHealth and maxHealth.Value or services.Workspace:GetAttribute("BossMaxHealth") or 0
end

tabs.boss.formatCountdown = function(seconds, hours, minutes)
	seconds = math.max(0, math.floor(seconds or 0))
	hours = math.floor(seconds / 3600)
	minutes = math.floor(seconds % 3600 / 60)
	seconds = seconds % 60
	return string.format("%dh %dmin %ds", hours, minutes, seconds)
end

tabs.boss.leaveExerciseMachine = function(character, humanoid, root)
	character = utils.playerData.Player.Character
	humanoid = character and character:FindFirstChildOfClass("Humanoid")
	root = character and character:FindFirstChild("HumanoidRootPart")
	if not humanoid or humanoid.Health <= 0 then return end

	pcall(function()
		services.VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
		humanoid.Sit = false
		humanoid.Jump = true
		humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
		if root then root.AssemblyLinearVelocity = Vector3.new(0, math.max(root.AssemblyLinearVelocity.Y, 50), 0) end
	end)
	pcall(function() services.VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game) end)
	task.wait(0.2)
end

tabs.boss.pauseTraining = function()
	if tabs.boss.Data.TrainingSnapshot then return end
	tabs.boss.Data.TrainingSnapshot = {
		Rebirth = tabs.farming.RebirthData.IsAutoRebirthing,
		Size = tabs.farming.SizeData.Active,
		King = tabs.farming.KingData.TeleportActive,
		Tool = tabs.farming.ExerciseData.AutoFarm,
		Squat = tabs.farming.MachineExerciseData.Squat.Running,
		Lift = tabs.farming.MachineExerciseData.Lift.Running,
		AutoRep = tabs.farming.AutoRepRunning,
		Rock = getgenv().RockFarmRunning == true,
		Configs = {}
	}
	for _, config in ipairs(tabs.farming.Configs) do
		tabs.boss.Data.TrainingSnapshot.Configs[config.name] = tabs.farming.ActiveConfigs[config.name] == true
		if tabs.farming.ActiveConfigs[config.name] and config.Switch then config.Switch:Set(false) end
	end
	if tabs.boss.Data.TrainingSnapshot.Rebirth then tabs.farming.RebirthData.Switch:Set(false) end
	if tabs.boss.Data.TrainingSnapshot.Size then tabs.farming.SizeSwitch:Set(false) end
	if tabs.boss.Data.TrainingSnapshot.King then tabs.farming.KingSwitch:Set(false) end
	if tabs.boss.Data.TrainingSnapshot.Tool then tabs.farming.ToolExerciseSwitch:Set(false) end
	if tabs.boss.Data.TrainingSnapshot.Squat then tabs.farming.SquatExerciseSwitch:Set(false) end
	if tabs.boss.Data.TrainingSnapshot.Lift then tabs.farming.LiftExerciseSwitch:Set(false) end
	if tabs.boss.Data.TrainingSnapshot.Squat or tabs.boss.Data.TrainingSnapshot.Lift then tabs.boss.leaveExerciseMachine() end
	if tabs.boss.Data.TrainingSnapshot.AutoRep then tabs.farming.AutoRepSwitch:Set(false) end
	if tabs.boss.Data.TrainingSnapshot.Rock then tabs.farming.RockSwitch:Set(false) end
end

tabs.boss.resumeTraining = function(snapshot)
	snapshot = tabs.boss.Data.TrainingSnapshot
	if not snapshot then return end
	tabs.boss.Data.TrainingSnapshot = nil
	if snapshot.Rebirth then tabs.farming.RebirthData.Switch:Set(false)
 end
	if snapshot.Size then tabs.farming.SizeSwitch:Set(false)
 end
	if snapshot.King then tabs.farming.KingSwitch:Set(false)
 end
	if snapshot.Tool then tabs.farming.ToolExerciseSwitch:Set(false)
 end
	if snapshot.Squat then tabs.farming.SquatExerciseSwitch:Set(false)
 end
	if snapshot.Lift then tabs.farming.LiftExerciseSwitch:Set(false)
 end
	if snapshot.AutoRep then tabs.farming.AutoRepSwitch:Set(false)
 end
	if snapshot.Rock then tabs.farming.RockSwitch:Set(false)
 end
	for _, config in ipairs(tabs.farming.Configs) do
		if snapshot.Configs[config.name] and config.Switch then config.Switch:Set(false)
 end
	end
end

tabs.boss.getBossHeadPosition = function(model, hitbox, head)
	head = model:FindFirstChild("Head", true) or model:FindFirstChild("head", true)
	if head and head:IsA("BasePart") then return head.Position end
	if head and head:IsA("Bone") then return head.WorldPosition end
	return hitbox.Position + Vector3.new(0, hitbox.Size.Y * 0.35, 0)
end

tabs.boss.getAliveCharacter = function(generation, timeout, startedAt, character, root, humanoid)
	startedAt = os.clock()
	repeat
		character = utils.playerData.Player.Character
		root = character and character:FindFirstChild("HumanoidRootPart")
		humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if root and humanoid and humanoid.Health > 0 then
			utils.playerData.Character = character
			utils.playerData.Humanoid = humanoid
			return character, root, humanoid
		end
		tabs.boss.StatusLabel.Text = "Status: Waiting for Respawn"
		task.wait(0.1)
	until not tabs.boss.Data.Running
		or tabs.boss.Data.Generation ~= generation
		or (timeout and os.clock() - startedAt >= timeout)
end

tabs.boss.evadeAttack = function(model, hitbox, root, humanoid, sequence, attackKind, attackCFrame, impactTime, direction, safePosition, center)
	sequence = model:GetAttribute("BossAttackSequence")
	attackKind = model:GetAttribute("BossAttackKind")
	attackCFrame = model:GetAttribute("BossAttackCFrame")
	impactTime = model:GetAttribute("BossAttackImpactTime")

	if typeof(sequence) == "number" and sequence ~= tabs.boss.Data.AttackSequence then
		tabs.boss.Data.AttackSequence = sequence
		if typeof(attackKind) == "string" and typeof(attackCFrame) == "CFrame" and typeof(impactTime) == "number" then
			tabs.boss.Data.EvadeUntil = impactTime + 0.6
		end
	end

	if typeof(attackCFrame) ~= "CFrame" or services.Workspace:GetServerTimeNow() > tabs.boss.Data.EvadeUntil then
		return
	end

	attackKind = string.lower(tostring(attackKind or ""))
	if string.find(attackKind, "punch", 1, true) then
		center = tabs.boss.getBossHeadPosition(model, hitbox)
		direction = Vector3.new(attackCFrame.LookVector.X, 0, attackCFrame.LookVector.Z)
		if direction.Magnitude < 1 then direction = Vector3.new(hitbox.CFrame.LookVector.X, 0, hitbox.CFrame.LookVector.Z) end
		if direction.Magnitude < 1 then direction = Vector3.new(0, 0, 1) end
		safePosition = center - direction.Unit * tabs.boss.Data.PunchBehindDistance
		root.CFrame = CFrame.lookAt(safePosition, center)
		root.AssemblyLinearVelocity = Vector3.zero
		root.AssemblyAngularVelocity = Vector3.zero
		tabs.boss.StatusLabel.Text = "Status: Dodging Punch"
		return "Punch"
	end

	if not string.find(attackKind, "stomp", 1, true) then return end
	if humanoid.Health / math.max(humanoid.MaxHealth, 1) <= tabs.boss.Data.StompHealthThreshold then
		tabs.boss.Data.DodgeStomps = true
	end
	if not tabs.boss.Data.DodgeStomps then return end

	direction = Vector3.new(root.Position.X - attackCFrame.Position.X, 0, root.Position.Z - attackCFrame.Position.Z)
	if direction.Magnitude < 1 then
		direction = Vector3.new(-attackCFrame.LookVector.X, 0, -attackCFrame.LookVector.Z)
	end
	if direction.Magnitude < 1 then direction = Vector3.new(1, 0, 0) end
	direction = direction.Unit
	safePosition = attackCFrame.Position + direction * tabs.boss.Data.EvadeDistance + Vector3.new(0, 18, 0)
	root.CFrame = CFrame.lookAt(safePosition, attackCFrame.Position)
	root.AssemblyLinearVelocity = Vector3.zero
	root.AssemblyAngularVelocity = Vector3.zero
	tabs.boss.StatusLabel.Text = "Status: Dodging Stomp"
	return "Stomp"
end

tabs.boss.attack = function(model, health, maxHealth, hitbox, character, root, humanoid, punch, leftHand, rightHand, center, position, evadeMode)
	character = utils.playerData.Player.Character
	root = character and character:FindFirstChild("HumanoidRootPart")
	humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not root or not humanoid or humanoid.Health <= 0 then return end
	evadeMode = tabs.boss.evadeAttack(model, hitbox, root, humanoid)
	if evadeMode == "Stomp" then return end
	punch = character:FindFirstChild("Punch") or utils.playerData.Backpack:FindFirstChild("Punch")
	if punch and punch.Parent ~= character then humanoid:EquipTool(punch) end
	leftHand = character:FindFirstChild("LeftHand")
	rightHand = character:FindFirstChild("RightHand")
	center = tabs.boss.getBossHeadPosition(model, hitbox)
	if evadeMode ~= "Punch" then
		position = center
		root.CFrame = CFrame.lookAt(position, position + hitbox.CFrame.LookVector)
	end
	root.AssemblyLinearVelocity = Vector3.zero
	root.AssemblyAngularVelocity = Vector3.zero
	pcall(function()
		if leftHand then
			firetouchinterest(hitbox, leftHand, 0)
			firetouchinterest(hitbox, leftHand, 1)
		end
		if rightHand then
			firetouchinterest(hitbox, rightHand, 0)
			firetouchinterest(hitbox, rightHand, 1)
		end
	end)

	if os.clock() - tabs.boss.Data.LastPunch >= tabs.boss.Data.PunchInterval then
		tabs.boss.Data.LastPunch = os.clock()
		pcall(function()
			utils.remotes.MuscleEvent:FireServer("punch", "leftHand")
			utils.remotes.MuscleEvent:FireServer("punch", "rightHand")
			if punch then punch:Activate() end
		end)
	end

	tabs.boss.BossLabel.Text = "Boss: " .. (services.Workspace:GetAttribute("BossDisplayName") or model.Name)
	tabs.boss.runtime.health = tabs.boss.getBossHealth(health)
	tabs.boss.runtime.maxHealth = tabs.boss.getBossMaxHealth(maxHealth)
	tabs.boss.HealthLabel.Text = "Health: " .. utils.formatNumber(tabs.boss.runtime.health) .. " / " .. utils.formatNumber(tabs.boss.runtime.maxHealth)
end

tabs.boss.findChest = function(chest, prompt, part)
	for _, candidate in ipairs(services.CollectionService:GetTagged("BossEventChest")) do
		if candidate:IsDescendantOf(services.Workspace) then chest = candidate break end
	end
	if not chest then chest = services.Workspace:FindFirstChild("BossChest", true) end
	if not chest then
		for _, candidate in ipairs(services.Workspace:GetDescendants()) do
			if candidate:IsA("ProximityPrompt") and candidate.Name == "bossChestPrompt" then
				chest = candidate.Parent
				break
			end
		end
	end
	if not chest then return end
	prompt = chest:FindFirstChild("bossChestPrompt", true)
	part = prompt and prompt.Parent or (chest:IsA("Model") and (chest.PrimaryPart or chest:FindFirstChildWhichIsA("BasePart", true))) or chest
	if part and part:IsA("BasePart") then return chest, prompt, part end
end

tabs.boss.collectChest = function(generation, startedAt, chest, prompt, part, character, root)
	tabs.boss.StatusLabel.Text = "Status: Waiting for Chest"
	startedAt = os.clock()
	repeat
		chest, prompt, part = tabs.boss.findChest()
		if chest and chest:GetAttribute("BossChestEmerging") ~= true then break end
		task.wait(0.1)
	until not tabs.boss.Data.Running or tabs.boss.Data.Generation ~= generation or os.clock() - startedAt >= 12
	if not chest or not part then return end

	tabs.boss.StatusLabel.Text = "Status: Collecting Chest"
	startedAt = os.clock()
	repeat
		character, root = tabs.boss.getAliveCharacter(generation, 2)
		if character and root and chest.Parent and part.Parent then
			tabs.boss.StatusLabel.Text = "Status: Collecting Chest"
			pcall(function()
				root.CFrame = CFrame.lookAt(part.Position + Vector3.new(0, 3, 4), part.Position)
				root.AssemblyLinearVelocity = Vector3.zero
			end)
			task.wait(0.15)
			if prompt and prompt.Parent and fireproximityprompt then
				pcall(function() fireproximityprompt(prompt) end)
			else
				pcall(function()
					services.VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
					task.wait(0.1)
					services.VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
				end)
			end
		end
		task.wait(0.25)
	until not tabs.boss.Data.Running
		or tabs.boss.Data.Generation ~= generation
		or utils.playerData.Player:GetAttribute("BossChestPending") == false
		or not chest.Parent
		or os.clock() - startedAt >= 12
end

tabs.boss.ContinueSwitch = tabs.boss:AddSwitch("Continue Farming after Boss Kill", function(state)
	tabs.boss.Data.ContinueTraining = state
	if state and tabs.boss.Data.Phase == "Waiting" then tabs.boss.resumeTraining() end
end)
tabs.boss.ContinueSwitch:Set(false)


task.spawn(function(model, health, maxHealth, hitbox, currentHealth, currentMaxHealth, nextTime)
	while utils.isCurrent() and true do
		model, health, maxHealth, hitbox = tabs.boss.findActiveBoss()
		if model then
			currentHealth = tabs.boss.getBossHealth(health)
			currentMaxHealth = tabs.boss.getBossMaxHealth(maxHealth)
			tabs.boss.BossLabel.Text = "Boss: " .. (services.Workspace:GetAttribute("BossDisplayName") or model.Name)
			tabs.boss.HealthLabel.Text = "Health: " .. utils.formatNumber(currentHealth) .. " / " .. utils.formatNumber(currentMaxHealth)
			tabs.boss.NextBossLabel.Text = "Next Boss: Current boss active"
		else
			tabs.boss.BossLabel.Text = "Boss: None"
			tabs.boss.HealthLabel.Text = "Health: 0 / 0"
			nextTime = services.Workspace:GetAttribute("BossSpawnNextTime")
			tabs.boss.NextBossLabel.Text = typeof(nextTime) == "number"
				and "Next Boss: " .. tabs.boss.formatCountdown(nextTime - services.Workspace:GetServerTimeNow())
				or "Next Boss: N/A"
		end
		task.wait(0.25)
	end
end)

tabs.boss.AutoFarmSwitch = tabs.boss:AddSwitch("Auto Farm Boss", function(state)
	tabs.boss.Data.Running = state
	tabs.boss.Data.Generation += 1
	tabs.boss.runtime.generation = tabs.boss.Data.Generation
	if not state then
		tabs.boss.Data.Phase = "Waiting"
		tabs.boss.StatusLabel.Text = "Status: Disabled"
		tabs.boss.resumeTraining()
		return
	end

	task.spawn(function(generation, wasFighting, model, health, maxHealth, hitbox, selected)
		while utils.isCurrent() and tabs.boss.Data.Running and tabs.boss.Data.Generation == generation do
			pcall(function()
				model, health, maxHealth, hitbox = tabs.boss.findActiveBoss()
				selected = model and tabs.boss.shouldFarmBoss(model)
				if model and not selected then
					if wasFighting then
						wasFighting = false
						tabs.boss.resumeTraining()
					end
					tabs.boss.Data.Phase = "Waiting"
					tabs.boss.StatusLabel.Text = "Status: Skipping " .. (services.Workspace:GetAttribute("BossDisplayName") or model.Name)
				elseif model then
					if not wasFighting then
						wasFighting = true
						tabs.boss.Data.Phase = "Fighting"
						tabs.boss.Data.AttackSequence = nil
						tabs.boss.Data.EvadeUntil = 0
						tabs.boss.Data.DodgeStomps = false
						tabs.boss.pauseTraining()
					end
					if utils.playerData.Player.Character
						and utils.playerData.Player.Character:FindFirstChildOfClass("Humanoid")
						and utils.playerData.Player.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
						tabs.boss.StatusLabel.Text = "Status: Fighting"
						tabs.boss.attack(model, health, maxHealth, hitbox)
					else
						tabs.boss.StatusLabel.Text = "Status: Waiting for Respawn"
					end
				elseif wasFighting then
					wasFighting = false
					tabs.boss.Data.Phase = "Collecting"
					pcall(tabs.boss.collectChest, generation)
					tabs.boss.BossLabel.Text = "Boss: None"
					tabs.boss.HealthLabel.Text = "Health: 0 / 0"
					if tabs.boss.Data.ContinueTraining then tabs.boss.resumeTraining() end
					tabs.boss.Data.Phase = "Waiting"
					tabs.boss.StatusLabel.Text = "Status: Waiting for Boss"
				else
					tabs.boss.StatusLabel.Text = "Status: Waiting for Boss"
				end
			end)
			task.wait(model and selected and 0.03 or 0.25)
		end
	end, tabs.boss.runtime.generation)
end)

tabs.inventory:AddLabel("Pet Shop:")

tabs.inventory.PetShopRuntime = services.ReplicatedStorage:WaitForChild("shared"):WaitForChild("runtime")
tabs.inventory.PetShopFolder = tabs.inventory.PetShopRuntime:WaitForChild("cPetShopFolder")
tabs.inventory.PetShopRemote = services.ReplicatedStorage.rEvents:WaitForChild("cPetShopRemote")

tabs.inventory.PetShopData = {
	PetList = {},
	Selected = {},
	SelectedList = {},
	BuyAmount = 1
}

tabs.inventory.AuraData = {
	AuraList = {},
	Selected = {},
	SelectedList = {},
	BuyAmount = 1
}

tabs.inventory.EvolveData = {Selected = {}, SelectedList = {}, Amount = 1}

for _, item in ipairs(tabs.inventory.PetShopFolder:GetChildren()) do
	if item:GetAttribute("IsPowerUp") == true then
		table.insert(tabs.inventory.AuraData.AuraList, item.Name)
	else
		table.insert(tabs.inventory.PetShopData.PetList, item.Name)
	end
end
table.sort(tabs.inventory.PetShopData.PetList)
table.sort(tabs.inventory.AuraData.AuraList)

tabs.inventory.BuyPetLabel = tabs.inventory:AddLabel("Selected Pets: None")
tabs.inventory.BuyPetDropdown = tabs.inventory:AddDropdown("Choose Pets", function(text)
	utils.toggleSelection(tabs.inventory.PetShopData.Selected, tabs.inventory.PetShopData.SelectedList, text, tabs.inventory.BuyPetLabel, "Selected Pets: ")
end)
for _, petName in ipairs(tabs.inventory.PetShopData.PetList) do tabs.inventory.BuyPetDropdown:Add(petName) end

tabs.inventory:AddTextBox("Buy Amount:", function(text)
	tabs.inventory.PetShopData.BuyAmount = math.max(1, math.floor(tonumber(text) or 1))
end, {clear = false})

tabs.inventory:AddSwitch("Buy Pet", function(bool)
	_G.AutoHatchPet = bool
	if bool then
		task.spawn(function()
			while utils.isCurrent() and _G.AutoHatchPet do
				for _, petName in ipairs(tabs.inventory.PetShopData.SelectedList) do
					tabs.inventory.runtime.selectedPet = tabs.inventory.PetShopFolder:FindFirstChild(petName)
					if tabs.inventory.runtime.selectedPet then
						for _ = 1, tabs.inventory.PetShopData.BuyAmount do
							task.spawn(function(selectedPet)
								pcall(function() tabs.inventory.PetShopRemote:InvokeServer(selectedPet) end)
							end, tabs.inventory.runtime.selectedPet)
						end
					end
				end
				task.wait(0.1)
			end
		end)
	end
end)

tabs.inventory:AddLabel("Auras:")

tabs.inventory.AuraLabel = tabs.inventory:AddLabel("Selected Auras: None")
tabs.inventory.AuraDropdown = tabs.inventory:AddDropdown("Select Auras", function(text)
	utils.toggleSelection(tabs.inventory.AuraData.Selected, tabs.inventory.AuraData.SelectedList, text, tabs.inventory.AuraLabel, "Selected Auras: ")
end)
for _, auraName in ipairs(tabs.inventory.AuraData.AuraList) do tabs.inventory.AuraDropdown:Add(auraName) end

tabs.inventory:AddTextBox("Buy Amount:", function(text)
	tabs.inventory.AuraData.BuyAmount = math.max(1, math.floor(tonumber(text) or 1))
end, {clear = false})

tabs.inventory:AddSwitch("Buy Aura", function(bool)
	_G.AutoHatchAura = bool
	if bool then
		task.spawn(function()
			while utils.isCurrent() and _G.AutoHatchAura do
				for _, auraName in ipairs(tabs.inventory.AuraData.SelectedList) do
					tabs.inventory.runtime.selectedAura = tabs.inventory.PetShopFolder:FindFirstChild(auraName)
					if tabs.inventory.runtime.selectedAura then
						for _ = 1, tabs.inventory.AuraData.BuyAmount do
							task.spawn(function(selectedAura)
								pcall(function() tabs.inventory.PetShopRemote:InvokeServer(selectedAura) end)
							end, tabs.inventory.runtime.selectedAura)
						end
					end
				end
				task.wait(0.1)
			end
		end)
	end
end)

tabs.inventory:AddLabel("You need Gems and Inventory Space!")

tabs.inventory:AddLabel("Auto Evolving:")

tabs.inventory.EvolveLabel = tabs.inventory:AddLabel("Selected Pets: None")
tabs.inventory.EvolvePetDropdown = tabs.inventory:AddDropdown("Choose Pets", function(text)
	utils.toggleSelection(tabs.inventory.EvolveData.Selected, tabs.inventory.EvolveData.SelectedList, text, tabs.inventory.EvolveLabel, "Selected Pets: ")
end)
for _, petName in ipairs(tabs.inventory.PetShopData.PetList) do tabs.inventory.EvolvePetDropdown:Add(petName) end

tabs.inventory:AddTextBox("Evolve Amount:", function(text)
	tabs.inventory.EvolveData.Amount = math.max(1, math.floor(tonumber(text) or 1))
end, {clear = false})

tabs.inventory.AutoEvolveRunning = false

tabs.inventory:AddSwitch("Auto Evolve", function(state)
    tabs.inventory.AutoEvolveRunning = state
    if not state then return end

    task.spawn(function()
        while utils.isCurrent() and tabs.inventory.AutoEvolveRunning do
			for _, petName in ipairs(tabs.inventory.EvolveData.SelectedList) do
				for _ = 1, tabs.inventory.EvolveData.Amount do
					services.ReplicatedStorage.rEvents.petEvolveEvent:FireServer("evolvePet", petName)
				end
			end
            task.wait(0.5)
        end
    end)
end)



tabs.inventory:AddLabel("Auto Trading:")

tabs.inventory.TradeData = {SelectedPlayers = {}, SelectedPlayerList = {}, SelectedPets = {}, SelectedPetList = {}, Generation = 0}

tabs.inventory.TradePlayerLabel = tabs.inventory:AddLabel("Selected Players: None")
tabs.inventory.TradePlayerDropdown = tabs.inventory:AddDropdown("Choose Player", function(name)
    tabs.inventory.runtime.username_2258 = name:match(" | (.+)") or name
    utils.toggleSelection(tabs.inventory.TradeData.SelectedPlayers, tabs.inventory.TradeData.SelectedPlayerList, tabs.inventory.runtime.username_2258, tabs.inventory.TradePlayerLabel, "Selected Players: ")
end)

tabs.inventory:AddButton("Add All Players", function()
	for _, player in ipairs(services.Players:GetPlayers()) do
		if player ~= services.Players.LocalPlayer and not tabs.inventory.TradeData.SelectedPlayers[player.Name] then
			tabs.inventory.TradeData.SelectedPlayers[player.Name] = true
			table.insert(tabs.inventory.TradeData.SelectedPlayerList, player.Name)
		end
	end
	tabs.inventory.TradePlayerLabel.Text = "Selected Players: " .. (#tabs.inventory.TradeData.SelectedPlayerList > 0 and table.concat(tabs.inventory.TradeData.SelectedPlayerList, ", ") or "None")
end)

for _, player in ipairs(services.Players:GetPlayers()) do
    if player ~= services.Players.LocalPlayer then
        tabs.inventory.TradePlayerDropdown:Add(player.DisplayName .. " | " .. player.Name)
    end
end

utils.connect(services.Players.PlayerAdded, function(player)
    if player ~= services.Players.LocalPlayer then
        tabs.inventory.TradePlayerDropdown:Add(player.DisplayName .. " | " .. player.Name)
    end
end)

utils.connect(services.Players.PlayerRemoving, function(player)
    tabs.inventory.TradePlayerDropdown:Remove(player.DisplayName .. " | " .. player.Name)
    if tabs.inventory.TradeData.SelectedPlayers[player.Name] then
		utils.toggleSelection(tabs.inventory.TradeData.SelectedPlayers, tabs.inventory.TradeData.SelectedPlayerList, player.Name, tabs.inventory.TradePlayerLabel, "Selected Players: ")
	end
end)

tabs.inventory.TradePetLabel = tabs.inventory:AddLabel("Selected Pets: None")
tabs.inventory.TradePetDropdown = tabs.inventory:AddDropdown("Choose Pets", function(text)
	utils.toggleSelection(tabs.inventory.TradeData.SelectedPets, tabs.inventory.TradeData.SelectedPetList, text, tabs.inventory.TradePetLabel, "Selected Pets: ")
end)
for _, petName in ipairs(tabs.inventory.PetShopData.PetList) do tabs.inventory.TradePetDropdown:Add(petName) end



tabs.inventory.AutoTradeRunning = false

tabs.inventory:AddSwitch("Auto Trade", function(state)
    tabs.inventory.AutoTradeRunning = state
	tabs.inventory.TradeData.Generation += 1
    if not state then return end

    task.spawn(function(generation)
        while utils.isCurrent() and tabs.inventory.AutoTradeRunning and tabs.inventory.TradeData.Generation == generation do
            if #tabs.inventory.TradeData.SelectedPlayerList > 0 and #tabs.inventory.TradeData.SelectedPetList > 0 then
				for _, username in ipairs(tabs.inventory.TradeData.SelectedPlayerList) do
					tabs.inventory.runtime.tradePlayer = services.Players:FindFirstChild(username)
					if not tabs.inventory.AutoTradeRunning or tabs.inventory.TradeData.Generation ~= generation then break end
					if tabs.inventory.runtime.tradePlayer then
						tabs.inventory.runtime.tradingEvent = services.ReplicatedStorage.rEvents.tradingEvent
						tabs.inventory.runtime.unique = game.Players.LocalPlayer.petsFolder.Unique

						tabs.inventory.runtime.tradingEvent:FireServer(
							"sendTradeRequest",
							tabs.inventory.runtime.tradePlayer
						)

						task.wait(0.5)

						tabs.inventory.runtime.offered = 0
						tabs.inventory.runtime.offeredPets = {}
						repeat
							tabs.inventory.runtime.addedPet = false
							for _, selectedName in ipairs(tabs.inventory.TradeData.SelectedPetList) do
								for _, pet in ipairs(tabs.inventory.runtime.unique:GetChildren()) do
									if pet.Name == selectedName and not tabs.inventory.runtime.offeredPets[pet] then
										tabs.inventory.runtime.tradingEvent:FireServer("offerItem", pet)
										tabs.inventory.runtime.offeredPets[pet] = true
										tabs.inventory.runtime.offered += 1
										tabs.inventory.runtime.addedPet = true
										task.wait(0.01)
										break
									end
								end
								if not tabs.inventory.AutoTradeRunning or tabs.inventory.TradeData.Generation ~= generation or tabs.inventory.runtime.offered >= 6 then break end
							end
						until not tabs.inventory.AutoTradeRunning or tabs.inventory.TradeData.Generation ~= generation or tabs.inventory.runtime.offered >= 6 or not tabs.inventory.runtime.addedPet

						task.wait(0.05)

						if tabs.inventory.AutoTradeRunning and tabs.inventory.TradeData.Generation == generation then
							tabs.inventory.runtime.tradingEvent:FireServer("acceptTrade")
							task.wait(2)
						end
					end
				end
            end

            task.wait(2)
        end
    end, tabs.inventory.TradeData.Generation)
end)





tabs.boosts:AddLabel("Boost Eater:")

tabs.boosts.EggEaterData = {Running = false}

task.spawn(function()
	while utils.isCurrent() and true do
		if tabs.boosts.EggEaterData.Running then
			tabs.boosts.runtime.tool_2122 = utils.playerData.Player.Character:FindFirstChild("Protein Egg") or utils.playerData.Player.Backpack:FindFirstChild("Protein Egg")
			if tabs.boosts.runtime.tool_2122 then utils.playerData.Player.muscleEvent:FireServer("proteinEgg", tabs.boosts.runtime.tool_2122) end
			task.wait(0.25)
		else
			task.wait(1)
		end
	end
end)

tabs.boosts:AddSwitch("Eat All Eggs", function(state) tabs.boosts.EggEaterData.Running = state end):Set(false)

tabs.boosts.BoostData = {
	ItemList = {"Tropical Shake", "Energy Shake", "Protein Bar", "TOUGH Bar", "Protein Shake", "ULTRA Shake", "Energy Bar"},
	Running = false
}

task.spawn(function()
	while utils.isCurrent() and true do
		if tabs.boosts.BoostData.Running then
			for _, itemName in ipairs(tabs.boosts.BoostData.ItemList) do
				tabs.boosts.runtime.tool_2142 = utils.playerData.Player.Character:FindFirstChild(itemName) or utils.playerData.Player.Backpack:FindFirstChild(itemName)
				if tabs.boosts.runtime.tool_2142 then
					tabs.boosts.runtime.parts = {}
					for word in itemName:gmatch("%S+") do table.insert(tabs.boosts.runtime.parts, word:lower()) end
					for i = 2, #tabs.boosts.runtime.parts do tabs.boosts.runtime.parts[i] = tabs.boosts.runtime.parts[i]:sub(1, 1):upper() .. tabs.boosts.runtime.parts[i]:sub(2) end
					for i = 1, 10 do utils.playerData.Player.muscleEvent:FireServer(table.concat(tabs.boosts.runtime.parts), tabs.boosts.runtime.tool_2142) end
				end
			end
		end
		task.wait(0.1)
	end
end)

tabs.boosts:AddSwitch("Eat all Boosts (expect lag)", function(state) tabs.boosts.BoostData.Running = state end)

tabs.boosts:AddLabel("Egg Gifter:")

tabs.boosts.EggGifterData = {ProteinEggLabel = tabs.boosts:AddLabel("Protein Eggs: 0"), SelectedPlayer = nil, EggCount = 0}

tabs.boosts.EggPlayerDropdown = tabs.boosts:AddDropdown("Choose Player", function(name)
    tabs.boosts.runtime.username_2340 = name:match(" | (.+)") or name
    tabs.boosts.EggGifterData.SelectedPlayer = services.Players:FindFirstChild(tabs.boosts.runtime.username_2340)
end)

for _, player in ipairs(services.Players:GetPlayers()) do
    if player ~= services.Players.LocalPlayer then
        tabs.boosts.EggPlayerDropdown:Add(player.DisplayName .. " | " .. player.Name)
    end
end

utils.connect(services.Players.PlayerAdded, function(player)
    if player ~= services.Players.LocalPlayer then
        tabs.boosts.EggPlayerDropdown:Add(player.DisplayName .. " | " .. player.Name)
    end
end)

utils.connect(services.Players.PlayerRemoving, function(player)
    tabs.boosts.EggPlayerDropdown:Remove(player.DisplayName .. " | " .. player.Name)
    if tabs.boosts.EggGifterData.SelectedPlayer == player then tabs.boosts.EggGifterData.SelectedPlayer = nil end
end)

tabs.boosts.EggAmountTextBox = tabs.boosts:AddTextBox("Amount:", function(text)
	tabs.boosts.runtime.amount_2362 = tonumber(text)
	if tabs.boosts.runtime.amount_2362 then
		tabs.boosts.EggGifterData.EggCount = math.max(0, math.floor(tabs.boosts.runtime.amount_2362))
	end
end, {clear = false})

tabs.boosts:AddButton("Start Gifting", function()
	tabs.boosts.runtime.amount_2369 = tonumber(tabs.boosts.EggAmountTextBox.Text) or tabs.boosts.EggGifterData.EggCount
	tabs.boosts.runtime.amount_2369 = tabs.boosts.runtime.amount_2369 and math.max(0, math.floor(tabs.boosts.runtime.amount_2369)) or 0
	tabs.boosts.EggGifterData.EggCount = tabs.boosts.runtime.amount_2369

	if not tabs.boosts.EggGifterData.SelectedPlayer or tabs.boosts.runtime.amount_2369 == 0 then return end

	task.spawn(function()
		for _ = 1, tabs.boosts.runtime.amount_2369 do
			tabs.boosts.runtime.egg = services.Players.LocalPlayer.consumablesFolder:FindFirstChild("Protein Egg")
			if not tabs.boosts.runtime.egg then break end

			pcall(function()
				services.ReplicatedStorage.rEvents.giftRemote:InvokeServer("giftRequest", tabs.boosts.EggGifterData.SelectedPlayer, tabs.boosts.runtime.egg)
			end)
			task.wait(0.1)
		end
	end)
end)

tabs.boosts:AddLabel("Shake Gifter:")

tabs.boosts.ShakeGifterData = {TropicalShakeLabel = tabs.boosts:AddLabel("Tropical Shakes: 0"), SelectedPlayer = nil, ShakeCount = 0}

tabs.boosts.ShakePlayerDropdown = tabs.boosts:AddDropdown("Choose Player", function(name)
	tabs.boosts.runtime.usernameone = name:match(" | (.+)") or name
	tabs.boosts.ShakeGifterData.SelectedPlayer = services.Players:FindFirstChild(tabs.boosts.runtime.usernameone)
end)

for _, player in ipairs(services.Players:GetPlayers()) do
	if player ~= services.Players.LocalPlayer then
		tabs.boosts.ShakePlayerDropdown:Add(player.DisplayName .. " | " .. player.Name)
	end
end

utils.connect(services.Players.PlayerAdded, function(player)
	if player ~= services.Players.LocalPlayer then
		tabs.boosts.ShakePlayerDropdown:Add(player.DisplayName .. " | " .. player.Name)
	end
end)

utils.connect(services.Players.PlayerRemoving, function(player)
	tabs.boosts.ShakePlayerDropdown:Remove(player.DisplayName .. " | " .. player.Name)
	if tabs.boosts.ShakeGifterData.SelectedPlayer == player then tabs.boosts.ShakeGifterData.SelectedPlayer = nil end
end)

tabs.boosts.ShakeAmountTextBox = tabs.boosts:AddTextBox("Amount:", function(text)
	tabs.boosts.runtime.amount_2415 = tonumber(text)
	if tabs.boosts.runtime.amount_2415 then
		tabs.boosts.ShakeGifterData.ShakeCount = math.max(0, math.floor(tabs.boosts.runtime.amount_2415))
	end
end, {clear = false})

tabs.boosts:AddButton("Start Gifting", function()
	tabs.boosts.runtime.amount_2422 = tonumber(tabs.boosts.ShakeAmountTextBox.Text) or tabs.boosts.ShakeGifterData.ShakeCount
	tabs.boosts.runtime.amount_2422 = tabs.boosts.runtime.amount_2422 and math.max(0, math.floor(tabs.boosts.runtime.amount_2422)) or 0
	tabs.boosts.ShakeGifterData.ShakeCount = tabs.boosts.runtime.amount_2422

	if not tabs.boosts.ShakeGifterData.SelectedPlayer or tabs.boosts.runtime.amount_2422 == 0 then return end

	task.spawn(function()
		for _ = 1, tabs.boosts.runtime.amount_2422 do
			tabs.boosts.runtime.shake = services.Players.LocalPlayer.consumablesFolder:FindFirstChild("Tropical Shake")
			if not tabs.boosts.runtime.shake then break end

			pcall(function()
				services.ReplicatedStorage.rEvents.giftRemote:InvokeServer("giftRequest", tabs.boosts.ShakeGifterData.SelectedPlayer, tabs.boosts.runtime.shake)
			end)
			task.wait(0.1)
		end
	end)
end)

task.spawn(function()
	while utils.isCurrent() and true do
		tabs.boosts.runtime.proteinEggCount = 0
		tabs.boosts.runtime.tropicalShakeCount = 0
		if utils.playerData.Backpack then
			for _, item in ipairs(utils.playerData.Backpack:GetChildren()) do
				if item.Name == "Protein Egg" then tabs.boosts.runtime.proteinEggCount = tabs.boosts.runtime.proteinEggCount + 1
				elseif item.Name == "Tropical Shake" then tabs.boosts.runtime.tropicalShakeCount = tabs.boosts.runtime.tropicalShakeCount + 1 end
			end
		end
		tabs.boosts.EggGifterData.ProteinEggLabel.Text = "Protein Eggs: " .. tabs.boosts.runtime.proteinEggCount
		tabs.boosts.ShakeGifterData.TropicalShakeLabel.Text = "Tropical Shakes: " .. tabs.boosts.runtime.tropicalShakeCount
		task.wait(7.5)
	end
end)

tabs.boosts:AddLabel("Interferes with Boosts you got gifted. Get on a machine for less Lag!")

tabs.teleport:AddLabel("Main:")

tabs.teleport.Locations = {
	{name = "Tiny Island", pos = CFrame.new(-37.1, 9.2, 1919)},
	{name = "Main Island", pos = CFrame.new(16.07, 9.08, 133.8)},
	{name = "Beach", pos = CFrame.new(-8, 9, -169.2)}
}

for _, loc in ipairs(tabs.teleport.Locations) do
	tabs.teleport:AddButton(loc.name, function()
		if utils.playerData.Player.Character and utils.playerData.Player.Character:FindFirstChild("HumanoidRootPart") then
			utils.playerData.Player.Character.HumanoidRootPart.CFrame = loc.pos
		end
	end)
end

tabs.teleport:AddLabel("Gyms:")

tabs.teleport.GymLocations = {
	{name = "Overcharged Gym", pos = CFrame.new(-2941.766, 151.797, 4994.552)},
	{name = "Industrial gym", pos = CFrame.new(-5254.681641, 58.342850, 4931.850586)},
	{name = "Jungle Gym", pos = CFrame.new(-8543, 6.8, 2400)},
	{name = "Muscle King Gym", pos = CFrame.new(-8665.4, 17.21, -5792.9)},
	{name = "Legends Gym", pos = CFrame.new(4516, 991.5, -3856)},
	{name = "Infernal Gym", pos = CFrame.new(-6759, 7.36, -1284)},
	{name = "Mythical Gym", pos = CFrame.new(2250, 7.37, 1073.2)},
	{name = "Frost Gym", pos = CFrame.new(-2623, 7.36, -409)}
}

for _, gym in ipairs(tabs.teleport.GymLocations) do
	tabs.teleport:AddButton(gym.name, function()
		if utils.playerData.Player.Character and utils.playerData.Player.Character:FindFirstChild("HumanoidRootPart") then
			utils.playerData.Player.Character.HumanoidRootPart.CFrame = gym.pos
		end
	end)
end

tabs.stats:AddLabel("Elapsed Time:")

tabs.stats.Data = {
	StopwatchLabel = tabs.stats:AddLabel("0d 0h 0m 0s"),
	StartTime = tick(),
	Leaderstats = utils.playerData.Player:WaitForChild("leaderstats"),
	Stats = {},
	InitialValues = {},
	StatLabels = {}
}

tabs.stats:AddLabel("Stats:")

task.spawn(function()
	while utils.isCurrent() and true do
		tabs.stats.runtime.elapsedTime = tick() - tabs.stats.Data.StartTime
		tabs.stats.runtime.days = math.floor(tabs.stats.runtime.elapsedTime / (24 * 3600))
		tabs.stats.runtime.hours = math.floor((tabs.stats.runtime.elapsedTime % (24 * 3600)) / 3600)
		tabs.stats.runtime.minutes = math.floor((tabs.stats.runtime.elapsedTime % 3600) / 60)
		tabs.stats.runtime.seconds = math.floor(tabs.stats.runtime.elapsedTime % 60)
		tabs.stats.Data.StopwatchLabel.Text = string.format("%dd %dh %dm %ds", tabs.stats.runtime.days, tabs.stats.runtime.hours, tabs.stats.runtime.minutes, tabs.stats.runtime.seconds)
		task.wait(0.1)
	end
end)

tabs.stats.Data.Stats = {
	{name = tabs.specs.Data.EmojiMap["Strength"] .. " Strength", stat = tabs.stats.Data.Leaderstats:WaitForChild("Strength")},
	{name = tabs.specs.Data.EmojiMap["Rebirths"] .. " Rebirths", stat = tabs.stats.Data.Leaderstats:WaitForChild("Rebirths")},
	{name = tabs.specs.Data.EmojiMap["Durability"] .. " Durability", stat = utils.playerData.Player:WaitForChild("Durability")},
	{name = tabs.specs.Data.EmojiMap["Kills"] .. " Kills", stat = tabs.stats.Data.Leaderstats:WaitForChild("Kills")},
	{name = tabs.specs.Data.EmojiMap["Agility"] .. " Agility", stat = utils.playerData.Player:WaitForChild("Agility")},
	{name = tabs.specs.Data.EmojiMap["Evil Karma"] .. " Evil Karma", stat = utils.playerData.Player:WaitForChild("evilKarma")},
	{name = tabs.specs.Data.EmojiMap["Good Karma"] .. " Good Karma", stat = utils.playerData.Player:WaitForChild("goodKarma")},
	{name = tabs.specs.Data.EmojiMap["Brawls"] .. " Brawls", stat = tabs.stats.Data.Leaderstats:WaitForChild("Brawls")}
}

for _, info in ipairs(tabs.stats.Data.Stats) do
	tabs.stats.Data.InitialValues[info.name] = info.stat.Value
	tabs.stats.Data.StatLabels[info.name] = tabs.stats:AddLabel("")
end

task.spawn(function()
	while utils.isCurrent() and true do
		for _, info in ipairs(tabs.stats.Data.Stats) do
			tabs.stats.runtime.currentValue = info.stat.Value
			tabs.stats.runtime.gained = tabs.stats.runtime.currentValue - tabs.stats.Data.InitialValues[info.name]
			tabs.stats.Data.StatLabels[info.name].Text = string.format("%s: %s (%s) | Gained: %s (%s)", info.name,
				utils.formatNumber(tabs.stats.runtime.currentValue), utils.formatWithCommas(tabs.stats.runtime.currentValue),
				utils.formatNumber(tabs.stats.runtime.gained), utils.formatWithCommas(tabs.stats.runtime.gained))
		end
		task.wait(0.1)
	end
end)
tabs.info:Show()
tabs.info:AddLabel("Made by Honen")
tabs.info:AddLabel("Any issues? Join our Discord")
tabs.info:AddLabel("Official Discord: discord.gg/bVDtwKF92")
tabs.info:AddButton("Copy Invite", function()
	if setclipboard then
		setclipboard("https://discord.gg/bVDtwKF92")
		game.StarterGui:SetCore("SendNotification", {Title = "Link Copied!", Text = "You can continue to Discord now.", Duration = 3})
	else
		game.StarterGui:SetCore("SendNotification", {Title = "Error!", Text = "Clipboard not Supported.", Duration = 3})
	end
end)
tabs.info:AddLabel("")
tabs.info:AddLabel("Contributors:").TextSize = 17
tabs.info:AddLabel("- cyanam1 (@𝔥𝔬𝔫𝔢𝔶)")
tabs.info:AddLabel("- White @chilin6369")
tabs.info:AddLabel("- Honen @Owner")
tabs.info:AddLabel("")
tabs.info:AddLabel("HonenxWhite is Open-Source!")
tabs.info:AddLabel("")
tabs.info.VersionLabel = tabs.info:AddLabel("Muscle Legends [V4.1.3]")
tabs.info.VersionLabel.TextSize = 20
tabs.info.VersionLabel.Font = Enum.Font.Arcade




-- ⚡ FAST REP ADAPTATIVO (Súper rápido sin lag) - by cyanam1
tabs.fast:AddLabel("⚡ Fast Rep:")
tabs.fast.FastRepData = {
    Running = false,
    WorkerActive = false,
    StartStrength = 0,
    StartDurability = 0,
    SendRate = 400,
    MaxSendRate = 800,
    MinSendRate = 100,
    MaxBurst = 32,
    SendTokens = 0,
    LastLoopAt = os.clock(),
    CurrentPing = 0,
    LastPingCheck = 0,
    PingControl = true
}

local strengthStat = utils.playerData.Player:WaitForChild("leaderstats"):WaitForChild("Strength")
local durabilityStat = utils.playerData.Player:WaitForChild("Durability")
local networkStats = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]

tabs.fast.FastRepStatus = tabs.fast:AddLabel("Status: Inactive")
tabs.fast.FastRepStatus.TextColor3 = Color3.fromRGB(255, 80, 80)

tabs.fast.FastRepWorkerLoop = function()
    tabs.fast.FastRepData.LastLoopAt = os.clock()
    while utils.isCurrent() and tabs.fast.FastRepData.Running do
        local now = os.clock()
        local elapsed = math.min(0.1, now - tabs.fast.FastRepData.LastLoopAt)
        tabs.fast.FastRepData.LastLoopAt = now
        
        if tick() - tabs.fast.FastRepData.LastPingCheck > 0.5 then
            tabs.fast.FastRepData.CurrentPing = networkStats:GetValue()
            tabs.fast.FastRepData.LastPingCheck = tick()
            
            if tabs.fast.FastRepData.PingControl then
                local ping = tabs.fast.FastRepData.CurrentPing
                local targetSpeed
                if ping < 80 then
                    targetSpeed = 800
                elseif ping < 150 then
                    targetSpeed = 600
                elseif ping < 250 then
                    targetSpeed = 400
                elseif ping < 400 then
                    targetSpeed = 200
                else
                    targetSpeed = 100
                end
                tabs.fast.FastRepData.SendRate = targetSpeed
            end
        end
        
        tabs.fast.FastRepData.SendTokens = math.min(
            tabs.fast.FastRepData.MaxBurst,
            tabs.fast.FastRepData.SendTokens + tabs.fast.FastRepData.SendRate * elapsed
        )
        
        local burstLimit = math.max(1, math.min(
            tabs.fast.FastRepData.MaxBurst,
            math.ceil(tabs.fast.FastRepData.SendRate * 0.05)
        ))
        
        local sendCount = math.min(math.floor(tabs.fast.FastRepData.SendTokens), burstLimit)
        
        for i = 1, sendCount do
            utils.remotes.MuscleEvent:FireServer("rep")
        end
        
        tabs.fast.FastRepData.SendTokens = tabs.fast.FastRepData.SendTokens - sendCount
        
        tabs.fast.FastRepStatus.Text = "Status: ⚡ " .. math.floor(tabs.fast.FastRepData.SendRate) 
            .. " reps/s | " .. math.floor(tabs.fast.FastRepData.CurrentPing) .. " ms"
        tabs.fast.FastRepStatus.TextColor3 = Color3.fromRGB(80, 255, 120)
        
        services.RunService.Heartbeat:Wait()
    end
    tabs.fast.FastRepData.WorkerActive = false
end

tabs.fast:AddTextBox("Max reps/s: 800", function(text)
    local num = tonumber(text)
    if num and num > 0 then
        tabs.fast.FastRepData.MaxSendRate = math.clamp(num, 100, 2000)
        tabs.fast.FastRepData.SendRate = math.min(tabs.fast.FastRepData.SendRate, tabs.fast.FastRepData.MaxSendRate)
    end
end, {clear = false})

tabs.fast:AddSwitch("Ping Control (Auto Speed)", function(state)
    tabs.fast.FastRepData.PingControl = state
end):Set(false)


tabs.fast.FastRepToggle = tabs.fast:AddSwitch("Fast Rep ⚡ (No Lag)", function(state)
    tabs.fast.FastRepData.Running = state
    if state then
        tabs.fast.FastRepData.StartStrength = strengthStat.Value
        tabs.fast.FastRepData.StartDurability = durabilityStat.Value
        tabs.fast.FastRepData.SendRate = 400
        tabs.fast.FastRepData.SendTokens = 0
        tabs.fast.FastRepData.LastLoopAt = os.clock()
        tabs.fast.FastRepData.LastPingCheck = tick()
        
        if not tabs.fast.FastRepData.WorkerActive then
            tabs.fast.FastRepData.WorkerActive = true
            task.spawn(tabs.fast.FastRepWorkerLoop)
        end
    else
        tabs.fast.FastRepStatus.Text = "Status: Inactive"
        tabs.fast.FastRepStatus.TextColor3 = Color3.fromRGB(255, 80, 80)
    end
end)

tabs.fast:AddLabel("⚡ 400-800 reps/s | Ping auto-ajustado")










-- 🔄 FAST REBIRTH - by cyanam1
tabs.fast:AddLabel("🔄 Fast Rebirth:")

tabs.fast.FastRebirthData = {
    Running = false,
    WorkerActive = false,
    Rebirths = utils.playerData.Player.leaderstats:WaitForChild("Rebirths"),
    Strength = utils.playerData.Player.leaderstats:WaitForChild("Strength"),
    TargetRebirths = 0,
    RebirthsGained = 0,
    LastRebirthTime = 0,
    TotalRebirths = 0
}

tabs.fast.FastRebirthStatus = tabs.fast:AddLabel("Status: Inactive")
tabs.fast.FastRebirthStatus.TextColor3 = Color3.fromRGB(255, 80, 80)

tabs.fast.FastRebirthStats = tabs.fast:AddLabel("Rebirths: 0 | Gained: 0")
tabs.fast.FastRebirthSpeed = tabs.fast:AddLabel("Speed: --/min")

tabs.fast.FastRebirthWorker = function()
    local startRebirths = tabs.fast.FastRebirthData.Rebirths.Value
    tabs.fast.FastRebirthData.TotalRebirths = 0
    local lastCheck = tick()
    local lastRebirthCount = startRebirths
    
    while utils.isCurrent() and tabs.fast.FastRebirthData.Running do
        -- Verificar si llegamos al target
        if tabs.fast.FastRebirthData.TargetRebirths > 0 
            and tabs.fast.FastRebirthData.Rebirths.Value >= tabs.fast.FastRebirthData.TargetRebirths then
            tabs.fast.FastRebirthStatus.Text = "Status: ✅ Target alcanzado!"
            tabs.fast.FastRebirthStatus.TextColor3 = Color3.fromRGB(80, 255, 120)
            tabs.fast.FastRebirthData.Running = false
            break
        end
        
        -- 1. Equipar mascotas de repetición para farmear rápido
        pcall(function()
            local uniquePets = utils.playerData.Player.petsFolder.Unique
            -- Desequipar todas primero
            for _, folder in pairs(utils.playerData.Player.petsFolder:GetChildren()) do
                if folder:IsA("Folder") and folder.Name ~= "Unique" then
                    for _, pet in pairs(folder:GetChildren()) do
                        services.ReplicatedStorage.rEvents.equipPetEvent:FireServer("unequipPet", pet)
                    end
                end
            end
            task.wait(0.1)
            
            -- Equipar mascotas de repetición (prioridad a las de más reps)
            local repPets = {
                "Omega Overlord", "Swift Samurai", "Inferno Drake",
                "Common Boss Pet", "Rare Boss Pet", "Epic Boss Pet",
                "Rainbow Boss Pet", "Legendary Boss Pet", "Mythic Boss Pet"
            }
            
            local equippedCount = 0
            for _, petName in ipairs(repPets) do
                if equippedCount >= 12 then break end
                for _, pet in pairs(uniquePets:GetChildren()) do
                    if pet.Name == petName then
                        services.ReplicatedStorage.rEvents.equipPetEvent:FireServer("equipPet", pet)
                        equippedCount = equippedCount + 1
                        task.wait(0.05)
                    end
                end
            end
        end)
        
        -- 2. Farmear strength hasta el target para el próximo rebirth
        local currentRebirths = tabs.fast.FastRebirthData.Rebirths.Value
        local targetStrength = 5000 + currentRebirths * 2550
        local repsPerBurst = utils.playerData.Player.MembershipType == Enum.MembershipType.Premium and 6 or 12
        
        tabs.fast.FastRebirthStatus.Text = "Status: 💪 Farmeando... " 
            .. utils.formatNumber(tabs.fast.FastRebirthData.Strength.Value) 
            .. " / " .. utils.formatNumber(targetStrength)
        tabs.fast.FastRebirthStatus.TextColor3 = Color3.fromRGB(80, 255, 120)
        
        -- Farmear hasta llegar al target
        while utils.isCurrent() and tabs.fast.FastRebirthData.Running 
            and tabs.fast.FastRebirthData.Strength.Value < targetStrength do
            
            for i = 1, repsPerBurst do
                pcall(function()
                    utils.remotes.MuscleEvent:FireServer("rep")
                end)
            end
            task.wait(0.02)
            
            -- Actualizar stats
            tabs.fast.FastRebirthStats.Text = "Rebirths: " 
                .. utils.formatWithCommas(tabs.fast.FastRebirthData.Rebirths.Value) 
                .. " | Gained: " 
                .. utils.formatWithCommas(tabs.fast.FastRebirthData.Rebirths.Value - startRebirths)
        end
        
        -- 3. Hacer el rebirth
        if utils.isCurrent() and tabs.fast.FastRebirthData.Running 
            and tabs.fast.FastRebirthData.Strength.Value >= targetStrength then
            
            tabs.fast.FastRebirthStatus.Text = "Status: 🔄 Haciendo rebirth..."
            tabs.fast.FastRebirthStatus.TextColor3 = Color3.fromRGB(255, 200, 80)
            
            local rebirthValueBefore = tabs.fast.FastRebirthData.Rebirths.Value
            local attempts = 0
            
            repeat
                pcall(function()
                    services.ReplicatedStorage.rEvents.rebirthRemote:InvokeServer("rebirthRequest")
                end)
                task.wait(0.05)
                attempts = attempts + 1
            until not tabs.fast.FastRebirthData.Running 
                or tabs.fast.FastRebirthData.Rebirths.Value > rebirthValueBefore 
                or attempts >= 50
            
            if tabs.fast.FastRebirthData.Rebirths.Value > rebirthValueBefore then
                tabs.fast.FastRebirthData.TotalRebirths = tabs.fast.FastRebirthData.TotalRebirths + 
                    (tabs.fast.FastRebirthData.Rebirths.Value - rebirthValueBefore)
                tabs.fast.FastRebirthData.LastRebirthTime = tick()
            end
        end
        
        -- Calcular velocidad cada segundo
        if tick() - lastCheck >= 1 then
            local currentCount = tabs.fast.FastRebirthData.Rebirths.Value
            local gained = currentCount - lastRebirthCount
            tabs.fast.FastRebirthSpeed.Text = "Speed: " .. gained .. " rebirths/s"
            lastRebirthCount = currentCount
            lastCheck = tick()
        end
        
        task.wait(0.3)
    end
    
    tabs.fast.FastRebirthData.WorkerActive = false
end

tabs.fast:AddTextBox("Target rebirths (0 = infinito):", function(text)
    local num = tonumber(text)
    if num and num >= 0 then
        tabs.fast.FastRebirthData.TargetRebirths = math.floor(num)
    end
end, {clear = false})

tabs.fast.FastRebirthToggle = tabs.fast:AddSwitch("Fast Rebirth 🔄", function(state)
    tabs.fast.FastRebirthData.Running = state
    if state then
        tabs.fast.FastRebirthStatus.Text = "Status: 🔄 Iniciando..."
        tabs.fast.FastRebirthStatus.TextColor3 = Color3.fromRGB(80, 255, 120)
        
        if not tabs.fast.FastRebirthData.WorkerActive then
            tabs.fast.FastRebirthData.WorkerActive = true
            task.spawn(tabs.fast.FastRebirthWorker)
        end
    else
        tabs.fast.FastRebirthStatus.Text = "Status: Inactive"
        tabs.fast.FastRebirthStatus.TextColor3 = Color3.fromRGB(255, 80, 80)
    end
end)

tabs.fast:AddLabel("🔄 Auto farmea + rebirth automático")


-- 🔄 FAST REBIRTH V2 (Auto: Velocidad → Farm → Packs → Rebirth → Golems)
tabs.fast:AddLabel("")
tabs.fast:AddLabel("🔄 Fast Rebirth V2 (Automático):")

tabs.fast.FastRebirthV2Data = {
    Running = false,
    WorkerActive = false,
    Rebirths = utils.playerData.Player.leaderstats:WaitForChild("Rebirths"),
    Strength = utils.playerData.Player.leaderstats:WaitForChild("Strength"),
    TargetRebirths = 0,
    RebirthsGained = 0,
    LastRebirthTime = 0,
    TotalRebirths = 0,
    UseGolems = true,
    UsePackPets = true,
    -- PACKS de x2 Rebirths (SOLO estos)
    PackPets = {
        "Titanium Hydra",
        "Tribal Overlord"
    },
    -- Mascotas de VELOCIDAD de rep
    RepPets = {
        "Omega Overlord",
        "Swift Samurai"
    },
    -- Golems con +10% Rep Speed (de jefes)
    GolemPets = {
        "Mythic Boss Pet",
        "Legendary Boss Pet",
        "Epic Boss Pet",
        "Rainbow Boss Pet"
    }
}

tabs.fast.FastRebirthV2Status = tabs.fast:AddLabel("Status: Inactive")
tabs.fast.FastRebirthV2Status.TextColor3 = Color3.fromRGB(255, 80, 80)

tabs.fast.FastRebirthV2Stats = tabs.fast:AddLabel("Rebirths: 0 | Gained: 0")
tabs.fast.FastRebirthV2Speed = tabs.fast:AddLabel("Speed: --/min")

tabs.fast.equipPetsByNameV2 = function(petNames, maxPets)
    maxPets = maxPets or 12
    local uniquePets = utils.playerData.Player.petsFolder.Unique
    local equipped = 0
    local equippedSet = {}

    -- 1. Desequipar TODO primero
    for _, folder in pairs(utils.playerData.Player.petsFolder:GetChildren()) do
        if folder:IsA("Folder") and folder.Name ~= "Unique" then
            for _, pet in pairs(folder:GetChildren()) do
                pcall(function()
                    services.ReplicatedStorage.rEvents.equipPetEvent:FireServer("unequipPet", pet)
                end)
            end
        end
    end
    task.wait(0.2)

    -- 2. Función interna para equipar UN pet
    local function tryEquip(pet)
        if equipped >= maxPets then return false end
        if equippedSet[pet] then return false end
        pcall(function()
            services.ReplicatedStorage.rEvents.equipPetEvent:FireServer("equipPet", pet)
        end)
        equippedSet[pet] = true
        equipped = equipped + 1
        task.wait(0.05)
        return true
    end

    -- 3. Equipar SOLO por nombre exacto (todas las copias que haya)
    for _, petName in ipairs(petNames) do
        if equipped >= maxPets then break end
        for _, pet in pairs(uniquePets:GetChildren()) do
            if equipped >= maxPets then break end
            if pet.Name == petName then
                tryEquip(pet)
            end
        end
    end

    return equipped
end

tabs.fast.FastRebirthV2Worker = function()
    local startRebirths = tabs.fast.FastRebirthV2Data.Rebirths.Value
    tabs.fast.FastRebirthV2Data.TotalRebirths = 0
    local lastCheck = tick()
    local lastRebirthCount = startRebirths
    
    while utils.isCurrent() and tabs.fast.FastRebirthV2Data.Running do
        if tabs.fast.FastRebirthV2Data.TargetRebirths > 0 
            and tabs.fast.FastRebirthV2Data.Rebirths.Value >= tabs.fast.FastRebirthV2Data.TargetRebirths then
            tabs.fast.FastRebirthV2Status.Text = "Status: ✅ Target alcanzado!"
            tabs.fast.FastRebirthV2Status.TextColor3 = Color3.fromRGB(80, 255, 120)
            tabs.fast.FastRebirthV2Data.Running = false
            break
        end
        
        tabs.fast.FastRebirthV2Status.Text = "Status: ⚡ Equipando velocidad..."
        tabs.fast.FastRebirthV2Status.TextColor3 = Color3.fromRGB(255, 200, 80)
        
        pcall(function()
            tabs.fast.equipPetsByNameV2(tabs.fast.FastRebirthV2Data.RepPets, 12)
        end)
        
        task.wait(0.3)
        
        local currentRebirths = tabs.fast.FastRebirthV2Data.Rebirths.Value
        local targetStrength = 5000 + currentRebirths * 2550
        local repsPerBurst = utils.playerData.Player.MembershipType == Enum.MembershipType.Premium and 6 or 12
        
        tabs.fast.FastRebirthV2Status.Text = "Status: 💪 Farmeando... " 
            .. utils.formatNumber(tabs.fast.FastRebirthV2Data.Strength.Value) 
            .. " / " .. utils.formatNumber(targetStrength)
        tabs.fast.FastRebirthV2Status.TextColor3 = Color3.fromRGB(80, 255, 120)
        
        while utils.isCurrent() and tabs.fast.FastRebirthV2Data.Running 
            and tabs.fast.FastRebirthV2Data.Strength.Value < targetStrength do
            
            for i = 1, repsPerBurst do
                pcall(function()
                    utils.remotes.MuscleEvent:FireServer("rep")
                end)
            end
            task.wait(0.02)
            
            tabs.fast.FastRebirthV2Stats.Text = "Rebirths: " 
                .. utils.formatWithCommas(tabs.fast.FastRebirthV2Data.Rebirths.Value) 
                .. " | Gained: " 
                .. utils.formatWithCommas(tabs.fast.FastRebirthV2Data.Rebirths.Value - startRebirths)
        end
        
        if utils.isCurrent() and tabs.fast.FastRebirthV2Data.Running 
            and tabs.fast.FastRebirthV2Data.Strength.Value >= targetStrength then
            
            if tabs.fast.FastRebirthV2Data.UsePackPets then
                tabs.fast.FastRebirthV2Status.Text = "Status: 🎁 Equipando packs..."
                tabs.fast.FastRebirthV2Status.TextColor3 = Color3.fromRGB(255, 150, 255)
                
                pcall(function()
                    tabs.fast.equipPetsByNameV2(tabs.fast.FastRebirthV2Data.PackPets, 12)
                end)
                
                task.wait(0.5)
            end
            
            tabs.fast.FastRebirthV2Status.Text = "Status: 🔄 Haciendo rebirth..."
            tabs.fast.FastRebirthV2Status.TextColor3 = Color3.fromRGB(255, 200, 80)
            
            local rebirthValueBefore = tabs.fast.FastRebirthV2Data.Rebirths.Value
            local attempts = 0
            
            repeat
                pcall(function()
                    services.ReplicatedStorage.rEvents.rebirthRemote:InvokeServer("rebirthRequest")
                end)
                task.wait(0.05)
                attempts = attempts + 1
            until not tabs.fast.FastRebirthV2Data.Running 
                or tabs.fast.FastRebirthV2Data.Rebirths.Value > rebirthValueBefore 
                or attempts >= 50
            
            if tabs.fast.FastRebirthV2Data.Rebirths.Value > rebirthValueBefore then
                tabs.fast.FastRebirthV2Data.TotalRebirths = tabs.fast.FastRebirthV2Data.TotalRebirths + 
                    (tabs.fast.FastRebirthV2Data.Rebirths.Value - rebirthValueBefore)
                tabs.fast.FastRebirthV2Data.LastRebirthTime = tick()
            end
            
            if tabs.fast.FastRebirthV2Data.UseGolems then
                tabs.fast.FastRebirthV2Status.Text = "Status: 🐾 Re-equipando golems..."
                tabs.fast.FastRebirthV2Status.TextColor3 = Color3.fromRGB(150, 200, 255)
                
                task.wait(0.5)
                
                pcall(function()
                    tabs.fast.equipPetsByNameV2(tabs.fast.FastRebirthV2Data.GolemPets, 12)
                end)
            end
        end
        
        if tick() - lastCheck >= 1 then
            local currentCount = tabs.fast.FastRebirthV2Data.Rebirths.Value
            local gained = currentCount - lastRebirthCount
            tabs.fast.FastRebirthV2Speed.Text = "Speed: " .. gained .. " rebirths/s"
            lastRebirthCount = currentCount
            lastCheck = tick()
        end
        
        task.wait(0.3)
    end
    
    tabs.fast.FastRebirthV2Data.WorkerActive = false
end

tabs.fast:AddTextBox("V2 - Target rebirths (0 = infinito):", function(text)
    local num = tonumber(text)
    if num and num >= 0 then
        tabs.fast.FastRebirthV2Data.TargetRebirths = math.floor(num)
    end
end, {clear = false})

tabs.fast:AddSwitch("V2 - Usar Golems después del rebirth", function(state)
    tabs.fast.FastRebirthV2Data.UseGolems = state
end):Set(false)


tabs.fast:AddSwitch("V2 - Usar Packs (x2 Rebirths)", function(state)
    tabs.fast.FastRebirthV2Data.UsePackPets = state
end):Set(false)


tabs.fast.FastRebirthV2Toggle = tabs.fast:AddSwitch("Fast Rebirth V2 🔄 (Auto)", function(state)
    tabs.fast.FastRebirthV2Data.Running = state
    if state then
        tabs.fast.FastRebirthV2Status.Text = "Status: 🔄 Iniciando V2..."
        tabs.fast.FastRebirthV2Status.TextColor3 = Color3.fromRGB(80, 255, 120)
        
        if not tabs.fast.FastRebirthV2Data.WorkerActive then
            tabs.fast.FastRebirthV2Data.WorkerActive = true
            task.spawn(tabs.fast.FastRebirthV2Worker)
        end
    else
        tabs.fast.FastRebirthV2Status.Text = "Status: Inactive"
        tabs.fast.FastRebirthV2Status.TextColor3 = Color3.fromRGB(255, 80, 80)
    end
end)

tabs.fast:AddLabel("🔄 V2: Velocidad → Farm → Packs → Rebirth → Golems")
