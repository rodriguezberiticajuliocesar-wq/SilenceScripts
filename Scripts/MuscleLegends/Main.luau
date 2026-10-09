-- =====================================================
-- SLK VORTEX - MUSCLE LEGENDS (Version 6.0)
-- Interfaz: Fluent UI
-- Enfoque: Script Completo y Robusto
-- Basado en técnicas de SilenceScripts
-- =====================================================

-- =====================================================
-- 1. CARGAR LIBRERÍAS
-- =====================================================
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- =====================================================
-- 2. SERVICIOS
-- =====================================================
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local LP = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

-- =====================================================
-- 3. VARIABLES DE CONTROL GLOBALES
-- =====================================================
_G.AutoFarm = false
_G.FastRep = false
_G.AutoRebirth = false
_G.FastRebirth = false
_G.AutoEvolve = false
_G.AutoEquip = false
_G.AutoSell = false
_G.AutoUpgrade = false
_G.KillAura = false
_G.GodMode = false
_G.Fly = false
_G.Noclip = false
_G.InfiniteJump = false
_G.AntiAFK = false
_G.ESP = false
_G.SpeedEnabled = false
_G.SizeEnabled = false

-- =====================================================
-- 4. VARIABLES DE ANTILAG
-- =====================================================
local TargetReps = 698
local FrameTime = 1 / TargetReps
local LagCompensation = 0
local CurrentSpeed = 16
local CurrentSize = 1

-- =====================================================
-- 5. FUNCIONES AUXILIARES
-- =====================================================

-- 5.1. Obtener el evento muscleEvent (con espera activa)
local function GetMuscleEvent()
    local event = LP:FindFirstChild("muscleEvent") or LP:FindFirstChild("MuscleEvent")
    if not event then
        local timeout = 0
        repeat
            task.wait(0.1)
            event = LP:FindFirstChild("muscleEvent") or LP:FindFirstChild("MuscleEvent")
            timeout = timeout + 1
        until event or timeout > 50
    end
    return event
end

-- 5.2. Obtener el Rebirth Remote
local function GetRebirthRemote()
    local rEvents = RS:FindFirstChild("rEvents")
    if rEvents then
        return rEvents:FindFirstChild("rebirthRemote")
    end
    return nil
end

-- 5.3. Obtener el Evolve Remote
local function GetEvolveRemote()
    local rEvents = RS:FindFirstChild("rEvents")
    if rEvents then
        return rEvents:FindFirstChild("evolveRemote")
    end
    return nil
end

-- 5.4. Obtener el ChangeSpeedSize Remote
local function GetChangeSpeedRemote()
    local rEvents = RS:FindFirstChild("rEvents")
    if rEvents then
        return rEvents:FindFirstChild("changeSpeedSizeRemote")
    end
    return nil
end

-- 5.5. Obtener el Sell Remote
local function GetSellRemote()
    local rEvents = RS:FindFirstChild("rEvents")
    if rEvents then
        return rEvents:FindFirstChild("sellRemote")
    end
    return nil
end

-- 5.6. Función de farmeo con Anti-Lag
local function StartFarm()
    local event = GetMuscleEvent()
    if not event then return end
    
    while _G.AutoFarm or _G.FastRep do
        local CycleStart = tick()
        
        pcall(function()
            event:FireServer("punch", "leftHand")
            event:FireServer("punch", "rightHand")
        end)
        
        local CycleTime = tick() - CycleStart
        local WaitTime = FrameTime - CycleTime
        
        if CycleTime > FrameTime then
            WaitTime = 0
            LagCompensation = math.min(LagCompensation + 0.0001, 0.01)
        else
            WaitTime = WaitTime + LagCompensation
            LagCompensation = math.max(LagCompensation - 0.00001, 0)
        end
        
        if WaitTime > 0 then
            task.wait(WaitTime)
        end
    end
end

-- 5.7. Función de Kill Aura
local function StartKillAura()
    while _G.KillAura do
        local event = GetMuscleEvent()
        if event and LP.Character then
            for _, v in pairs(Players:GetPlayers()) do
                if v ~= LP and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChild("Humanoid") then
                    if v.Character.Humanoid.Health > 0 then
                        local dist = (LP.Character.HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).Magnitude
                        if dist < 25 then
                            pcall(function()
                                local hand = LP.Character:FindFirstChild("LeftHand") or LP.Character:FindFirstChild("RightHand")
                                if hand then
                                    firetouchinterest(v.Character.HumanoidRootPart, hand, 0)
                                    task.wait(0.01)
                                    firetouchinterest(v.Character.HumanoidRootPart, hand, 1)
                                    event:FireServer("punch", "leftHand")
                                    event:FireServer("punch", "rightHand")
                                end
                            end)
                        end
                    end
                end
            end
        end
        task.wait(0.1)
    end
end

-- 5.8. Función de Auto Equip (equipa la mejor herramienta)
local function AutoEquipBest()
    if not LP.Character then return end
    local backpack = LP:FindFirstChild("Backpack")
    if not backpack then return end
    
    local bestTool = nil
    local bestDamage = 0
    
    for _, tool in pairs(backpack:GetChildren()) do
        if tool:IsA("Tool") then
            local damage = tool:GetAttribute("Damage") or 0
            if damage > bestDamage then
                bestDamage = damage
                bestTool = tool
            end
        end
    end
    
    if bestTool then
        local humanoid = LP.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid:EquipTool(bestTool)
        end
    end
end

-- 5.9. Función de Auto Sell
local function StartAutoSell()
    while _G.AutoSell do
        pcall(function()
            local sellRemote = GetSellRemote()
            if sellRemote then
                if sellRemote:IsA("RemoteFunction") then
                    sellRemote:InvokeServer()
                else
                    sellRemote:FireServer()
                end
            end
        end)
        task.wait(30)
    end
end

-- 5.10. Función de Anti-AFK
local function StartAntiAFK()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton1(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end

-- =====================================================
-- 6. CREAR VENTANA PRINCIPAL
-- =====================================================
local Window = Fluent:CreateWindow({
    Title = "SLK VORTEX",
    SubTitle = "by SLK Team | Muscle Legends",
    TabWidth = 160,
    Size = UDim2.fromOffset(600, 500),
    Acrylic = false,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

-- =====================================================
-- 7. CREAR PESTAÑAS
-- =====================================================
local Tabs = {
    Farm = Window:AddTab({ Title = "Farm", Icon = "sword" }),
    Rebirth = Window:AddTab({ Title = "Rebirth", Icon = "rotate-cw" }),
    Pets = Window:AddTab({ Title = "Pets", Icon = "paw-print" }),
    Combat = Window:AddTab({ Title = "Combat", Icon = "skull" }),
    Player = Window:AddTab({ Title = "Player", Icon = "user" }),
    Visuals = Window:AddTab({ Title = "Visuals", Icon = "eye" }),
    Misc = Window:AddTab({ Title = "Misc", Icon = "settings" })
}

-- =====================================================
-- 8. PESTAÑA: FARM
-- =====================================================
local FarmTab = Tabs.Farm

FarmTab:AddParagraph({
    Title = "Farmeo Automático",
    Content = "Activa el farmeo de fuerza y durabilidad con sistema Anti-Lag."
})

FarmTab:AddToggle("AutoFarmToggle", {
    Title = "Auto Farm (Anti-Lag)",
    Default = false,
    Callback = function(Value)
        _G.AutoFarm = Value
        if Value then
            task.spawn(StartFarm)
            Fluent:Notify({ Title = "SLK VORTEX", Content = "Auto Farm activado." })
        end
    end
})

FarmTab:AddToggle("FastRepsToggle", {
    Title = "Fast Reps ⚡ (698 reps/s)",
    Default = false,
    Callback = function(Value)
        _G.FastRep = Value
        if Value then
            task.spawn(StartFarm)
            Fluent:Notify({ Title = "SLK VORTEX", Content = "Fast Reps activado." })
        end
    end
})

FarmTab:AddSlider("RepsSlider", {
    Title = "Reps por Segundo",
    Description = "Ajusta la velocidad de repeticiones.",
    Default = 698,
    Min = 100,
    Max = 999,
    Rounding = 1,
    Callback = function(Value)
        TargetReps = Value
        FrameTime = 1 / TargetReps
    end
})

FarmTab:AddToggle("AutoEquipToggle", {
    Title = "Auto Equip (Mejor Herramienta)",
    Default = false,
    Callback = function(Value)
        _G.AutoEquip = Value
        if Value then
            task.spawn(function()
                while _G.AutoEquip do
                    AutoEquipBest()
                    task.wait(5)
                end
            end)
        end
    end
})

-- =====================================================
-- 9. PESTAÑA: REBIRTH
-- =====================================================
local RebirthTab = Tabs.Rebirth

RebirthTab:AddParagraph({
    Title = "Sistema de Rebirth",
    Content = "Automatiza el proceso de renacimiento."
})

RebirthTab:AddToggle("AutoRebirthToggle", {
    Title = "Auto Rebirth",
    Default = false,
    Callback = function(Value)
        _G.AutoRebirth = Value
        if Value then
            task.spawn(function()
                while _G.AutoRebirth do
                    pcall(function()
                        local rebirthRemote = GetRebirthRemote()
                        if rebirthRemote then
                            if rebirthRemote:IsA("RemoteFunction") then
                                rebirthRemote:InvokeServer()
                            else
                                rebirthRemote:FireServer()
                            end
                        end
                    end)
                    task.wait(5)
                end
            end)
        end
    end
})

RebirthTab:AddToggle("FastRebirthToggle", {
    Title = "Fast Rebirth",
    Default = false,
    Callback = function(Value)
        _G.FastRebirth = Value
        if Value then
            task.spawn(function()
                while _G.FastRebirth do
                    pcall(function()
                        local rebirthRemote = GetRebirthRemote()
                        if rebirthRemote then
                            if rebirthRemote:IsA("RemoteFunction") then
                                rebirthRemote:InvokeServer()
                            else
                                rebirthRemote:FireServer()
                            end
                        end
                    end)
                    task.wait(1.5)
                end
            end)
        end
    end
})

-- =====================================================
-- 10. PESTAÑA: PETS
-- =====================================================
local PetsTab = Tabs.Pets

PetsTab:AddParagraph({
    Title = "Gestión de Mascotas",
    Content = "Automatiza la evolución de tus mascotas."
})

PetsTab:AddToggle("AutoEvolveToggle", {
    Title = "Auto Evolve Pets",
    Default = false,
    Callback = function(Value)
        _G.AutoEvolve = Value
        if Value then
            task.spawn(function()
                while _G.AutoEvolve do
                    pcall(function()
                        local evolveRemote = GetEvolveRemote()
                        if evolveRemote then
                            if evolveRemote:IsA("RemoteFunction") then
                                evolveRemote:InvokeServer()
                            else
                                evolveRemote:FireServer()
                            end
                        end
                    end)
                    task.wait(3)
                end
            end)
        end
    end
})

-- =====================================================
-- 11. PESTAÑA: COMBAT
-- =====================================================
local CombatTab = Tabs.Combat

CombatTab:AddParagraph({
    Title = "Modo Combate",
    Content = "Herramientas para el combate PvP."
})

CombatTab:AddToggle("KillAuraToggle", {
    Title = "Kill Aura (25 studs)",
    Default = false,
    Callback = function(Value)
        _G.KillAura = Value
        if Value then
            task.spawn(StartKillAura)
            Fluent:Notify({ Title = "SLK VORTEX", Content = "Kill Aura activado." })
        end
    end
})

CombatTab:AddSlider("KillAuraRangeSlider", {
    Title = "Rango de Kill Aura",
    Default = 25,
    Min = 5,
    Max = 50,
    Rounding = 1,
    Callback = function(Value)
        -- Variable global para el rango
        _G.KillAuraRange = Value
    end
})

-- =====================================================
-- 12. PESTAÑA: PLAYER
-- =====================================================
local PlayerTab = Tabs.Player

PlayerTab:AddParagraph({
    Title = "Estado del Jugador",
    Content = "Modifica las propiedades de tu personaje."
})

PlayerTab:AddToggle("GodModeToggle", {
    Title = "God Mode",
    Default = false,
    Callback = function(Value)
        _G.GodMode = Value
        if LP.Character and LP.Character:FindFirstChild("Humanoid") then
            if Value then
                LP.Character.Humanoid.MaxHealth = math.huge
                LP.Character.Humanoid.Health = math.huge
            else
                LP.Character.Humanoid.MaxHealth = 100
                LP.Character.Humanoid.Health = 100
            end
        end
    end
})

PlayerTab:AddSlider("WalkSpeedSlider", {
    Title = "WalkSpeed",
    Default = 16,
    Min = 16,
    Max = 200,
    Rounding = 1,
    Callback = function(Value)
        CurrentSpeed = Value
        if LP.Character and LP.Character:FindFirstChild("Humanoid") then
            LP.Character.Humanoid.WalkSpeed = Value
        end
    end
})

PlayerTab:AddSlider("JumpPowerSlider", {
    Title = "JumpPower",
    Default = 50,
    Min = 50,
    Max = 300,
    Rounding = 1,
    Callback = function(Value)
        if LP.Character and LP.Character:FindFirstChild("Humanoid") then
            LP.Character.Humanoid.JumpPower = Value
        end
    end
})

PlayerTab:AddToggle("InfiniteJumpToggle", {
    Title = "Infinite Jump",
    Default = false,
    Callback = function(Value)
        _G.InfiniteJump = Value
    end
})

-- =====================================================
-- 13. PESTAÑA: VISUALS
-- =====================================================
local VisualsTab = Tabs.Visuals

VisualsTab:AddParagraph({
    Title = "Efectos Visuales",
    Content = "Herramientas visuales para el juego."
})

VisualsTab:AddToggle("ESPToggle", {
    Title = "ESP (Jugadores)",
    Default = false,
    Callback = function(Value)
        _G.ESP = Value
        if Value then
            for _, v in pairs(Players:GetPlayers()) do
                if v ~= LP and v.Character then
                    local highlight = Instance.new("Highlight")
                    highlight.Name = "SLK_ESP"
                    highlight.Adornee = v.Character
                    highlight.FillColor = Color3.fromRGB(255, 0, 0)
                    highlight.Parent = v.Character
                end
            end
        else
            for _, v in pairs(Players:GetPlayers()) do
                if v.Character then
                    local h = v.Character:FindFirstChild("SLK_ESP")
                    if h then h:Destroy() end
                end
            end
        end
    end
})

VisualsTab:AddSlider("FOVSlider", {
    Title = "Field of View (FOV)",
    Default = 70,
    Min = 70,
    Max = 120,
    Rounding = 1,
    Callback = function(Value)
        workspace.CurrentCamera.FieldOfView = Value
    end
})

-- =====================================================
-- 14. PESTAÑA: MISC
-- =====================================================
local MiscTab = Tabs.Misc

MiscTab:AddParagraph({
    Title = "Varios",
    Content = "Herramientas adicionales del script."
})

MiscTab:AddToggle("FlyToggle", {
    Title = "Fly",
    Default = false,
    Callback = function(Value)
        _G.Fly = Value
        if Value and LP.Character then
            local BodyVelocity = Instance.new("BodyVelocity")
            BodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            BodyVelocity.Velocity = Vector3.new(0, 0, 0)
            BodyVelocity.Parent = LP.Character.HumanoidRootPart
            RunService.RenderStepped:Connect(function()
                if _G.Fly then
                    BodyVelocity.Velocity = workspace.CurrentCamera.CFrame.LookVector * 100
                else
                    BodyVelocity:Destroy()
                end
            end)
        end
    end
})

MiscTab:AddToggle("NoclipToggle", {
    Title = "Noclip",
    Default = false,
    Callback = function(Value)
        _G.Noclip = Value
        if Value then
            RunService.Stepped:Connect(function()
                if LP.Character then
                    for _, v in pairs(LP.Character:GetDescendants()) do
                        if v:IsA("BasePart") then
                            v.CanCollide = false
                        end
                    end
                end
            end)
        end
    end
})

MiscTab:AddToggle("AntiAFKToggle", {
    Title = "Anti-AFK",
    Default = false,
    Callback = function(Value)
        _G.AntiAFK = Value
        if Value then
            task.spawn(function()
                while _G.AntiAFK do
                    StartAntiAFK()
                    task.wait(60)
                end
            end)
        end
    end
})

-- =====================================================
-- 15. CONFIGURACIÓN FINAL
-- =====================================================
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("SLK_VORTEX")
SaveManager:SetFolder("SLK_VORTEX")

SaveManager:BuildConfigSection(Tabs.Misc)
InterfaceManager:ApplyToTab(Tabs.Misc)

-- =====================================================
-- 16. MANEJO DE RESPAWN (Reconectar funciones al morir)
-- =====================================================
LP.CharacterAdded:Connect(function(character)
    task.wait(2)
    
    if _G.GodMode and character:FindFirstChild("Humanoid") then
        character.Humanoid.MaxHealth = math.huge
        character.Humanoid.Health = math.huge
    end
    
    if _G.SpeedEnabled and character:FindFirstChild("Humanoid") then
        character.Humanoid.WalkSpeed = CurrentSpeed
    end
end)

-- =====================================================
-- 17. NOTIFICACIÓN FINAL
-- =====================================================
Fluent:Notify({
    Title = "SLK VORTEX",
    Content = "Script cargado correctamente (v6.0).",
    Duration = 5
})
