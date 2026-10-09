-- =====================================================
-- SLK VORTEX - MUSCLE LEGENDS (Version 5.0)
-- Interfaz: Fluent UI
-- Enfoque: Corrección de Farmeo y Nuevas Funciones
-- =====================================================

-- 1. CARGAR LIBRERÍA DE INTERFAZ (FLUENT UI)
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- 2. SERVICIOS Y VARIABLES GLOBALES
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local LP = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")

-- Variables de control
_G.AutoFarm = false
_G.FastRep = false
_G.AutoRebirth = false
_G.AutoEvolve = false
_G.AutoEquip = false
_G.KillAura = false
_G.GodMode = false
_G.Fly = false
_G.Noclip = false

-- Variables del Anti-Lag
local TargetReps = 698
local FrameTime = 1 / TargetReps
local LagCompensation = 0

-- =====================================================
-- 3. FUNCIONES AUXILIARES
-- =====================================================

-- Obtener el evento MuscleEvent correctamente (directamente del jugador)
local function GetMuscleEvent()
    return LP:FindFirstChild("muscleEvent") or LP.muscleEvent
end

-- Función de farmeo con Anti-Lag
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

-- =====================================================
-- 4. CREAR VENTANA PRINCIPAL (FLUENT UI)
-- =====================================================
local Window = Fluent:CreateWindow({
    Title = "SLK VORTEX",
    SubTitle = "by SLK Team | Muscle Legends",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = false, -- Desactivado para evitar detección
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

-- Crear Pestañas (Tabs)
local Tabs = {
    Farm = Window:AddTab({ Title = "Farm", Icon = "sword" }),
    Rebirth = Window:AddTab({ Title = "Rebirth", Icon = "rotate-cw" }),
    Pets = Window:AddTab({ Title = "Pets", Icon = "paw-print" }),
    Combat = Window:AddTab({ Title = "Combat", Icon = "skull" }),
    Player = Window:AddTab({ Title = "Player", Icon = "user" }),
    Misc = Window:AddTab({ Title = "Misc", Icon = "settings" })
}

-- =====================================================
-- 5. PESTAÑA: FARM (CORREGIDA)
-- =====================================================
local FarmTab = Tabs.Farm

FarmTab:AddParagraph({
    Title = "Farmeo Automático",
    Content = "Activa el farmeo de fuerza y durabilidad."
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

-- =====================================================
-- 6. PESTAÑA: REBIRTH
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
                        local rebirthRemote = RS:FindFirstChild("rEvents") and RS.rEvents:FindFirstChild("rebirthRemote")
                        if rebirthRemote then
                            if rebirthRemote:IsA("RemoteFunction") then
                                rebirthRemote:InvokeServer("rebirthRequest")
                            else
                                rebirthRemote:FireServer("rebirthRequest")
                            end
                        end
                    end)
                    task.wait(5)
                end
            end)
        end
    end
})

-- =====================================================
-- 7. PESTAÑA: PETS
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
                        local evolveRemote = RS:FindFirstChild("rEvents") and RS.rEvents:FindFirstChild("evolveRemote")
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
-- 8. PESTAÑA: COMBAT (NUEVAS FUNCIONES)
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
            task.spawn(function()
                while _G.KillAura do
                    for _, v in pairs(Players:GetPlayers()) do
                        if v ~= LP and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                            local dist = (LP.Character.HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).Magnitude
                            if dist < 25 then
                                local event = GetMuscleEvent()
                                local hand = LP.Character:FindFirstChild("LeftHand") or LP.Character:FindFirstChild("RightHand")
                                if event and hand and v.Character.HumanoidRootPart then
                                    pcall(function()
                                        -- Usar firetouchinterest como en el script de referencia
                                        firetouchinterest(v.Character.HumanoidRootPart, hand, 0)
                                        firetouchinterest(v.Character.HumanoidRootPart, hand, 1)
                                        event:FireServer("punch", "leftHand")
                                        event:FireServer("punch", "rightHand")
                                    end)
                                end
                            end
                        end
                    end
                    task.wait(0.1)
                end
            end)
        end
    end
})

-- =====================================================
-- 9. PESTAÑA: PLAYER (NUEVAS FUNCIONES)
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
            LP.Character.Humanoid.MaxHealth = Value and math.huge or 100
            LP.Character.Humanoid.Health = Value and math.huge or 100
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

-- =====================================================
-- 10. PESTAÑA: MISC (NUEVAS FUNCIONES)
-- =====================================================
local MiscTab = Tabs.Misc

MiscTab:AddParagraph({
    Title = "Varios",
    Content = "Herramientas adicionales."
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

-- =====================================================
-- 11. CONFIGURACIÓN FINAL
-- =====================================================
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("SLK_VORTEX")
SaveManager:SetFolder("SLK_VORTEX")

SaveManager:BuildConfigSection(Tabs.Misc)
InterfaceManager:ApplyToTab(Tabs.Misc)

Fluent:Notify({
    Title = "SLK VORTEX",
    Content = "Script cargado correctamente (v5.0).",
    Duration = 5
})
