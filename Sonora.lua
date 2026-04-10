local cloneref = cloneref or function(o) return o end
local CoreGui = cloneref(game:GetService("CoreGui"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local TweenService = cloneref(game:GetService("TweenService"))
local Players = cloneref(game:GetService("Players"))
local LocalPlayer = Players.LocalPlayer

local UI_NAME = "RobloxUIPref" -- Nombre ofuscado para evitar escaneos de CoreGui

-- Tabla de Configuración Global (Hacks)
getgenv().GMods = {
    InfAmmo = false,
    NoRecoil = false,
    SilentAim = false,
    KillAll = false,
    ESP_Boxes = false,
    ESP_Info = false,
    ESP_Tracers = false,
    TeamCheck = false,
    ESP_Skeleton = false,
    ESP_Distance = false,
    ESP_Chams = false,
    ESP_Radar = false,
    Noclip = false,
    VehicleESP = false,
    V_Nuke = false,
    V_Fling = false,
    V_NukeLoop = false
}

-- ====== BUCLE DE NOCLIP ======
game:GetService("RunService").Stepped:Connect(function()
    if getgenv().GMods.Noclip then
        local char = LocalPlayer.Character
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end
end)

-- ====== BYPASS ADONIS (Replica Exacta 1:1 de anti.txt) ======
local function BypassAdonis()
    local success, err = pcall(function()
        -- 1. Cerrar hilos de ejecución de Adonis (Módulo 19 de anti.txt)
        local AdonisAnticheatThreads = {}
        if getreg then
            for _, v in pairs(getreg()) do
                if typeof(v) == "thread" then
                    local s = debug.info(v, 1, "s")
                    if s and (s:match(".Core.Anti") or s:match(".Plugins.Anti_Cheat")) then
                        table.insert(AdonisAnticheatThreads, v)
                    end
                end
            end
        end
        for _, thread in pairs(AdonisAnticheatThreads) do
            pcall(coroutine.close, thread)
        end

        -- 2. Neutralizar tablas de detección en el Garbage Collector
        local AdonisTables = {}
        if getgc then
            for _, v in pairs(getgc(true)) do
                if typeof(v) == "table" and rawget(v, "Detected") and rawget(v, "RLocked") then
                    if typeof(rawget(v, "Detected")) == "function" then
                        table.insert(AdonisTables, v)
                    end
                end
            end
        end

        for _, AdonisTable in pairs(AdonisTables) do
            for i, v in pairs(AdonisTable) do
                if typeof(v) == "function" then
                    -- anti.txt usa Hooking.HookFunction, replicamos con hookfunction si existe
                    if hookfunction then
                        pcall(hookfunction, v, function(...)
                            coroutine.yield()
                            return task.wait(9e9)
                        end)
                    else
                        -- Fallback si el ejecutor no tiene hookfunction
                        AdonisTable[i] = function(...)
                            coroutine.yield()
                            return task.wait(9e9)
                        end
                    end
                end
            end
        end
    end)
    return success
end

if BypassAdonis() then
    task.spawn(function()
        repeat task.wait() until _G.Notify or Notify
        local n = _G.Notify or Notify
        n("Bypass Adonis: Activo", 4)
    end)
end

-- Eliminar instancia vieja si existe para recargar limpio
if CoreGui:FindFirstChild(UI_NAME) then
    CoreGui[UI_NAME]:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = UI_NAME
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

-- ====== SISTEMA DE NOTIFICACIONES ======
local NotifContainer = Instance.new("Frame")
NotifContainer.Name = "NotifContainer"
NotifContainer.Size = UDim2.new(0, 220, 1, -20)
NotifContainer.Position = UDim2.new(1, -240, 0, 10)
NotifContainer.BackgroundTransparency = 1
NotifContainer.Parent = ScreenGui

local NotifList = Instance.new("UIListLayout")
NotifList.SortOrder = Enum.SortOrder.LayoutOrder
NotifList.Padding = UDim.new(0, 10)
NotifList.VerticalAlignment = Enum.VerticalAlignment.Bottom
NotifList.Parent = NotifContainer

local function Notify(text, duration)
    duration = duration or 3
    local notif = Instance.new("Frame")
    notif.Size = UDim2.new(1, 40, 0, 40)
    notif.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    notif.BackgroundTransparency = 0.2
    notif.BorderSizePixel = 0
    notif.Parent = NotifContainer

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = notif

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(130, 130, 140) -- Plata resaltado
    stroke.Thickness = 1
    stroke.Parent = notif

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.FredokaOne
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = notif

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, 0, 0, 2)
    bar.Position = UDim2.new(0, 0, 1, -2)
    bar.BackgroundColor3 = Color3.fromRGB(130, 130, 140)
    bar.BorderSizePixel = 0
    bar.Parent = notif

    TweenService:Create(notif, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        { Size = UDim2.new(1, 0, 0, 40) }):Play()
    TweenService:Create(bar, TweenInfo.new(duration, Enum.EasingStyle.Linear), { Size = UDim2.new(0, 0, 0, 2) }):Play()

    task.delay(duration, function()
        if not notif or not notif.Parent then return end
        local outTween = TweenService:Create(notif, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
            { Size = UDim2.new(1, 40, 0, 40), BackgroundTransparency = 1 })
        TweenService:Create(label, TweenInfo.new(0.3), { TextTransparency = 1 }):Play()
        TweenService:Create(stroke, TweenInfo.new(0.3), { Transparency = 1 }):Play()
        outTween:Play()
        outTween.Completed:Wait()
        notif:Destroy()
    end)
end

-- ====== COLORES Y ESTILO DARK GLASS ======
local GLASS_COLOR = Color3.fromRGB(12, 12, 14)        -- Fondo Gris Oscuro / Negro
local GLASS_HIGHLIGHT = Color3.fromRGB(130, 130, 140) -- Brillo Plata / Metalico
local TEXT_MAIN = Color3.fromRGB(255, 255, 255)       -- Texto Primario
local TEXT_SUB = Color3.fromRGB(150, 150, 160)        -- Texto Secundario Gris

local FONT_MAIN = Enum.Font.FredokaOne
local FONT_BOLD = Enum.Font.FredokaOne

-- ====== CONTENEDOR PRINCIPAL ======
local MainFrame = Instance.new("ImageLabel")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 520, 0, 340) -- UI Mediana (Medium UI)
MainFrame.Position = UDim2.new(0.5, -260, 0.5, -170)
MainFrame.BackgroundColor3 = GLASS_COLOR
MainFrame.BackgroundTransparency = 0.35 -- Transparente pero solido (Efecto Glassmorphism)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = false
MainFrame.Image = "rbxassetid://111254867464843"
MainFrame.ImageTransparency = 0.55 -- Imagen mas transparente
MainFrame.ScaleType = Enum.ScaleType.Crop
MainFrame.Parent = ScreenGui

-- Bordes redondeados
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

-- Borde brillante tipo cristal
local UIStroke = Instance.new("UIStroke")
UIStroke.Color = GLASS_HIGHLIGHT
UIStroke.Thickness = 1.5
UIStroke.Transparency = 0.4
UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
UIStroke.Parent = MainFrame

-- ====== TOPBAR (Para mover la UI) ======
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundTransparency = 1
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0, 200, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "WHO1AM BETA"
Title.TextColor3 = TEXT_MAIN
Title.TextSize = 16
Title.Font = FONT_BOLD
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = TEXT_SUB
CloseBtn.TextSize = 14
CloseBtn.Parent = TopBar
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
CloseBtn.MouseEnter:Connect(function()
    TweenService:Create(CloseBtn, TweenInfo.new(0.2),
        { TextColor3 = Color3.fromRGB(255, 60, 60) }):Play()
end)
CloseBtn.MouseLeave:Connect(function() TweenService:Create(CloseBtn, TweenInfo.new(0.2), { TextColor3 = TEXT_SUB }):Play() end)

-- ====== TABS NAVIGATION (Lado izquierdo) ======
local TabBar = Instance.new("Frame")
TabBar.Name = "TabBar"
TabBar.Size = UDim2.new(0, 130, 1, -40)
TabBar.Position = UDim2.new(0, 0, 0, 40)
TabBar.BackgroundTransparency = 1
TabBar.BorderSizePixel = 0
TabBar.Parent = MainFrame

local TabList = Instance.new("UIListLayout")
TabList.SortOrder = Enum.SortOrder.LayoutOrder
TabList.Padding = UDim.new(0, 8)
TabList.HorizontalAlignment = Enum.HorizontalAlignment.Center
TabList.Parent = TabBar

-- Indicador visual animado (Fuera del TabBar para animar libre)
local Indicator = Instance.new("Frame")
Indicator.Name = "Indicator"
Indicator.Size = UDim2.new(0, 4, 0, 0)
Indicator.Position = UDim2.new(0, 0, 0, 0)
Indicator.BackgroundColor3 = GLASS_HIGHLIGHT
Indicator.BorderSizePixel = 0
Indicator.Parent = MainFrame

local IndicatorCorner = Instance.new("UICorner")
IndicatorCorner.CornerRadius = UDim.new(1, 0)
IndicatorCorner.Parent = Indicator

-- PERFIL DEL USUARIO
local ProfileFrame = Instance.new("Frame")
ProfileFrame.Name = "ProfileFrame"
ProfileFrame.Size = UDim2.new(1, -10, 0, 36)
ProfileFrame.BackgroundTransparency = 1
ProfileFrame.LayoutOrder = -1
ProfileFrame.Parent = TabBar

local AvatarIcon = Instance.new("ImageLabel")
AvatarIcon.Size = UDim2.new(0, 26, 0, 26)
AvatarIcon.Position = UDim2.new(0, 5, 0.5, -13)
AvatarIcon.BackgroundTransparency = 1
AvatarIcon.Image = "rbxthumb://type=AvatarHeadShot&id=" ..
    (Players.LocalPlayer and Players.LocalPlayer.UserId or 1) .. "&w=150&h=150"
AvatarIcon.Parent = ProfileFrame
local AvatarCorner = Instance.new("UICorner")
AvatarCorner.CornerRadius = UDim.new(1, 0)
AvatarCorner.Parent = AvatarIcon

local NameLabel = Instance.new("TextLabel")
NameLabel.Size = UDim2.new(1, -35, 1, 0)
NameLabel.Position = UDim2.new(0, 35, 0, 0)
NameLabel.BackgroundTransparency = 1
NameLabel.Text = Players.LocalPlayer and Players.LocalPlayer.Name or "Unknown"
NameLabel.TextColor3 = TEXT_MAIN
NameLabel.TextSize = 13
NameLabel.Font = FONT_MAIN
NameLabel.TextXAlignment = Enum.TextXAlignment.Left
NameLabel.Parent = ProfileFrame
NameLabel.TextTruncate = Enum.TextTruncate.AtEnd

-- Linea Separadora
local SepLine = Instance.new("Frame")
SepLine.Name = "SepLine"
SepLine.Size = UDim2.new(0.8, 0, 0, 1)
SepLine.BackgroundColor3 = GLASS_HIGHLIGHT
SepLine.BackgroundTransparency = 0.5
SepLine.BorderSizePixel = 0
SepLine.LayoutOrder = 0
SepLine.Parent = TabBar

-- ====== CONTENEDOR DE PAGINAS ======
local ContentContainer = Instance.new("Frame")
ContentContainer.Name = "ContentContainer"
ContentContainer.Size = UDim2.new(1, -140, 1, -55)
ContentContainer.Position = UDim2.new(0, 130, 0, 40)
ContentContainer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ContentContainer.BackgroundTransparency = 0.93 -- Contenedor solido interno
ContentContainer.BorderSizePixel = 0
ContentContainer.Parent = MainFrame

local ContentCorner = Instance.new("UICorner")
ContentCorner.CornerRadius = UDim.new(0, 8)
ContentCorner.Parent = ContentContainer

local pages = {}
local tabs = {}

local function CreatePage(name)
    local page = Instance.new("ScrollingFrame")
    page.Name = name
    page.Size = UDim2.new(1, -20, 1, -20)
    page.Position = UDim2.new(0, 10, 0, 10)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = GLASS_HIGHLIGHT
    page.Visible = false
    page.Parent = ContentContainer

    local List = Instance.new("UIListLayout")
    List.Padding = UDim.new(0, 10)
    List.Parent = page

    pages[name] = page
    return page
end

local function SwitchTab(tabName)
    for name, page in pairs(pages) do
        page.Visible = (name == tabName)
    end

    for name, tab in pairs(tabs) do
        local icon = tab:FindFirstChild("Icon")
        if name == tabName then
            -- Animacion de seleccion
            TweenService:Create(tab, TweenInfo.new(0.3), { TextColor3 = TEXT_MAIN, BackgroundTransparency = 0.75 }):Play()
            if icon then
                TweenService:Create(icon, TweenInfo.new(0.3), { ImageColor3 = TEXT_MAIN }):Play()
            end
            TweenService:Create(Indicator, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Position = UDim2.new(0, 5, 0, tab.AbsolutePosition.Y - MainFrame.AbsolutePosition.Y),
                Size = UDim2.new(0, 3, 0, 32)
            }):Play()
        else
            -- Animacion des-seleccion
            TweenService:Create(tab, TweenInfo.new(0.3), { TextColor3 = TEXT_SUB, BackgroundTransparency = 1 }):Play()
            if icon then
                TweenService:Create(icon, TweenInfo.new(0.3), { ImageColor3 = TEXT_SUB }):Play()
            end
        end
    end
end

local tabOrderCounter = 1

local function CreateTab(name, iconId)
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.LayoutOrder = tabOrderCounter
    tabOrderCounter = tabOrderCounter + 1
    btn.Size = UDim2.new(0, 110, 0, 32)
    btn.BackgroundColor3 = GLASS_HIGHLIGHT
    btn.BackgroundTransparency = 1
    btn.Text = "         " .. name
    btn.TextColor3 = TEXT_SUB
    btn.TextSize = 14
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Font = FONT_MAIN
    btn.Parent = TabBar

    local icon = Instance.new("ImageLabel")
    icon.Name = "Icon"
    icon.Size = UDim2.new(0, 16, 0, 16)
    icon.Position = UDim2.new(0, 8, 0.5, -8)
    icon.BackgroundTransparency = 1
    icon.Image = iconId
    icon.ImageColor3 = TEXT_SUB
    icon.Parent = btn

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn

    btn.MouseButton1Click:Connect(function()
        SwitchTab(name)
    end)

    tabs[name] = btn
    CreatePage(name)
end

-- Crear las Tabs especificas (Main, Gun, Troll)
CreateTab("Main", "rbxassetid://115293043996075")
CreateTab("Gun", "rbxassetid://127910889366859")
CreateTab("Troll", "rbxassetid://126543797759227")

-- Helper para botones estilo Checkbox con Callbacks de Estado
local function AddCheckbox(parentPage, text, callback)
    local btnContainer = Instance.new("TextButton")
    btnContainer.Size = UDim2.new(1, 0, 0, 26) -- Altura del checkbox
    btnContainer.BackgroundTransparency = 1
    btnContainer.Text = ""
    btnContainer.Parent = parentPage

    -- Caja del Checkbox
    local checkBox = Instance.new("Frame")
    checkBox.Size = UDim2.new(0, 18, 0, 18)
    checkBox.Position = UDim2.new(0, 4, 0.5, -9)
    checkBox.BackgroundColor3 = Color3.fromRGB(25, 25, 30) -- Fondo oscuro
    checkBox.BorderSizePixel = 0
    checkBox.Parent = btnContainer

    local boxCorner = Instance.new("UICorner")
    boxCorner.CornerRadius = UDim.new(0, 4)
    boxCorner.Parent = checkBox

    local boxStroke = Instance.new("UIStroke")
    boxStroke.Color = Color3.fromRGB(60, 60, 70) -- Borde
    boxStroke.Thickness = 1
    boxStroke.Parent = checkBox

    -- Palomita (Checkmark)
    local checkIcon = Instance.new("TextLabel")
    checkIcon.Size = UDim2.new(1, 0, 1, 0)
    checkIcon.BackgroundTransparency = 1
    checkIcon.Text = "✓"
    checkIcon.TextColor3 = TEXT_MAIN
    checkIcon.TextSize = 14
    checkIcon.Font = Enum.Font.GothamBold
    checkIcon.TextTransparency = 1 -- Oculto al inicio
    checkIcon.Parent = checkBox

    -- Etiqueta de Texto
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -35, 1, 0)
    label.Position = UDim2.new(0, 32, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = TEXT_MAIN
    label.TextSize = 14
    label.Font = FONT_MAIN
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = btnContainer

    -- Logica de Toggle
    local toggled = false

    btnContainer.MouseEnter:Connect(function()
        TweenService:Create(boxStroke, TweenInfo.new(0.2), { Color = GLASS_HIGHLIGHT }):Play()
    end)
    btnContainer.MouseLeave:Connect(function()
        if not toggled then
            TweenService:Create(boxStroke, TweenInfo.new(0.2), { Color = Color3.fromRGB(60, 60, 70) }):Play()
        end
    end)

    btnContainer.MouseButton1Click:Connect(function()
        toggled = not toggled
        if toggled then
            TweenService:Create(checkIcon, TweenInfo.new(0.2), { TextTransparency = 0 }):Play()
            TweenService:Create(boxStroke, TweenInfo.new(0.2), { Color = GLASS_HIGHLIGHT }):Play()
            Notify("Actived: " .. text, 3)
        else
            TweenService:Create(checkIcon, TweenInfo.new(0.2), { TextTransparency = 1 }):Play()
            TweenService:Create(boxStroke, TweenInfo.new(0.2), { Color = Color3.fromRGB(60, 60, 70) }):Play()
            Notify("Disabled: " .. text, 3)
        end

        if callback then
            task.spawn(function()
                callback(toggled)
            end)
        end
    end)
end

-- Rellenar Main Tab
AddCheckbox(pages["Main"], "Snaplines (Full ESP)", function(state)
    getgenv().GMods.ESP_Boxes = state
    getgenv().GMods.ESP_Info = state
    getgenv().GMods.ESP_Tracers = state
end)
AddCheckbox(pages["Main"], "Ignore Team", function(state)
    getgenv().GMods.TeamCheck = state
end)
AddCheckbox(pages["Main"], "Distance ESP", function(state)
    getgenv().GMods.ESP_Distance = state
end)
AddCheckbox(pages["Main"], "Skeleton ESP", function(state)
    getgenv().GMods.ESP_Skeleton = state
end)
AddCheckbox(pages["Main"], "RGB Chams (X-Ray)", function(state)
    getgenv().GMods.ESP_Chams = state
end)
AddCheckbox(pages["Main"], "2D Radar", function(state)
    getgenv().GMods.ESP_Radar = state
end)

-- Rellenar Gun Tab
AddCheckbox(pages["Gun"], "Silent Aim", function(state)
    getgenv().GMods.SilentAim = state
end)
AddCheckbox(pages["Gun"], "Infinite Ammo", function(state)
    getgenv().GMods.InfAmmo = state
end)
AddCheckbox(pages["Gun"], "No Recoil / Spread", function(state)
    getgenv().GMods.NoRecoil = state
end)


-- Rellenar Troll Tab
-- Kill All Toggle: Ahora es un interruptor que mata continuamente
AddCheckbox(pages["Troll"], "Loop Kill All", function(state)
    getgenv().GMods.KillAll = state

    if state then
        task.spawn(function()
            while getgenv().GMods.KillAll do
                local RS = game:GetService("ReplicatedStorage")
                local ACS = RS:FindFirstChild("ACS_Engine")
                local DamageEvent = ACS and ACS.Events:FindFirstChild("Damage")
                local AccessIdEvent = ACS and ACS.Events:FindFirstChild("AcessId")

                local myChar = LocalPlayer.Character
                local myTool = myChar and myChar:FindFirstChildOfClass("Tool")

                if myTool and DamageEvent and AccessIdEvent then
                    local accessId = nil
                    pcall(function() accessId = AccessIdEvent:InvokeServer(LocalPlayer.UserId) end)

                    if accessId then
                        local sessionToken = tostring(accessId) .. "-" .. tostring(LocalPlayer.UserId)

                        -- RESTAURACION DE DATA COMPLETA PARA BYPASS DE PROTOCOLO
                        local gunSettings = nil
                        pcall(function()
                            local settingsMod = myTool:FindFirstChild("Settings") or
                                myTool:FindFirstChild("ACS_Settings")
                            if settingsMod then gunSettings = require(settingsMod) end
                        end)

                        local dataTable = gunSettings or {
                            Ammo = 30,
                            DamageFallOf = 1,
                            ShootRate = 750,
                            IgnoreProtection = false,
                            EnableZeroing = true,
                            IncludeChamberedBullet = true,
                            Zoom = 60,
                            MaxRecoilPower = 1.5,
                            BulletPenetration = 50,
                            CanCheckMag = true,
                            BulletLight = false,
                            MuzzleVelocity = 885,
                            gunName = myTool.Name,
                            HeadDamage = { 90, 90 },
                            TorsoDamage = { 60, 60 },
                            LimbDamage = { 30, 30 },
                            MinDamage = 5,
                            StoredAmmo = 30,
                            AmmoInGun = 30,
                            MaxStoredAmmo = 30,
                            Type = "Gun",
                            ShootType = 3,
                            Bullets = 1,
                            Jammed = false,
                            CanBreak = false,
                            SlideLock = false,
                            SightAtt = "",
                            FireModes = { Auto = true, Semi = true },
                            MagCount = true,
                            BurstShot = 3,
                            camRecoil = { camRecoilUp = { 5, 10 }, camRecoilRight = { 5, 10 }, camRecoilLeft = { 5, 10 }, camRecoilTilt = { 20, 20 } },
                            gunRecoil = { gunRecoilUp = { 5, 10 }, gunRecoilRight = { 5, 10 }, gunRecoilLeft = { 5, 10 }, gunRecoilTilt = { 20, 25 } },
                            AimInaccuracyStepAmount = 0.25,
                            AimRecoilReduction = 2.5,
                            MaxSpread = 0,
                            MinSpread = 0,
                            BulletDrop = 0,
                            WalkMult = 0,
                            MaxZero = 500,
                            ZeroIncrement = 50,
                            CurrentZero = 0,
                            adsTime = 1,
                            BulletType = "5.56x45mm",
                            ADSEnabled = { false, false },
                        }

                        local modTable = {
                            SpreadRM = 1,
                            MuzzleVelocity = 1,
                            Zoom2Value = 30,
                            MaxSpread = 1,
                            Zoom3Value = 55,
                            DamageMod = 1,
                            AimRM = 1,
                            MaxRecoilPower = 1,
                            MinRecoilPower = 1,
                            RecoilPowerStepAmount = 1,
                            MinSpread = 1,
                            AimInaccuracyStepAmount = 1,
                            AimInaccuracyDecrease = 1,
                            WalkMult = 1,
                            adsTime = 1,
                            ZoomValue = 60,
                            GLVelocity = 1,
                            minDamageMod = 1,
                            gunRecoilMod = { RecoilRight = 1, RecoilUp = 1, RecoilTilt = 1, RecoilLeft = 1 },
                            camRecoilMod = { RecoilRight = 1, RecoilUp = 1, RecoilTilt = 1, RecoilLeft = 1 },
                        }

                        local killedThisSweep = 0
                        for _, player in ipairs(Players:GetPlayers()) do
                            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") then
                                local hum = player.Character.Humanoid
                                local onSameTeam = player.Team ~= nil and LocalPlayer.Team ~= nil and
                                    player.Team == LocalPlayer.Team

                                if (not getgenv().GMods.TeamCheck or not onSameTeam) and hum.Health > 0 then
                                    killedThisSweep = killedThisSweep + 1
                                    task.spawn(function()
                                        pcall(function()
                                            DamageEvent:InvokeServer(
                                                myTool,
                                                hum,
                                                2, -- Distancia fake
                                                1, -- Headshot
                                                dataTable,
                                                modTable,
                                                nil,
                                                nil,
                                                sessionToken
                                            )
                                        end)
                                    end)
                                end
                            end
                        end
                    end
                end
                task.wait(0.8) -- Tiempo entre barridos automáticos
            end
        end)
    end
end)

-- Boton ACTION: ...

-- Toggle: Anti-AFK
AddCheckbox(pages["Troll"], "Anti-AFK", function(state)
    getgenv().GMods.AntiAFK = state
    if state then
        task.spawn(function()
            while getgenv().GMods.AntiAFK do
                local VirtualUser = game:GetService("VirtualUser")
                pcall(function()
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton2(Vector2.new())
                end)
                task.wait(60)
            end
        end)
    end
end)

-- ====== PESTAÑA DE INFO (Info Session) ======
CreateTab("Info", "rbxassetid://80492492668606") -- Icono de info
local infoPage = pages["Info"]

local GroupBox = Instance.new("Frame")
GroupBox.Name = "ServerBox"
GroupBox.Size = UDim2.new(1, 0, 0, 160)
GroupBox.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
GroupBox.BackgroundTransparency = 0.5
GroupBox.BorderSizePixel = 0
GroupBox.Parent = infoPage

local GBCorner = Instance.new("UICorner")
GBCorner.CornerRadius = UDim.new(0, 8)
GBCorner.Parent = GroupBox

local GBStroke = Instance.new("UIStroke")
GBStroke.Color = Color3.fromRGB(60, 60, 70)
GBStroke.Parent = GroupBox

local GBTitle = Instance.new("TextLabel")
GBTitle.Size = UDim2.new(1, -20, 0, 30)
GBTitle.Position = UDim2.new(0, 10, 0, 5)
GBTitle.BackgroundTransparency = 1
GBTitle.Text = "Server"
GBTitle.TextColor3 = TEXT_MAIN
GBTitle.Font = Enum.Font.GothamBold
GBTitle.TextSize = 16
GBTitle.TextXAlignment = Enum.TextXAlignment.Left
GBTitle.Parent = GroupBox

local GBSub = Instance.new("TextLabel")
GBSub.Size = UDim2.new(1, -20, 0, 15)
GBSub.Position = UDim2.new(0, 10, 0, 25)
GBSub.BackgroundTransparency = 1
GBSub.Text = "Information on the session you're currently in"
GBSub.TextColor3 = TEXT_SUB
GBSub.Font = Enum.Font.Gotham
GBSub.TextSize = 11
GBSub.TextXAlignment = Enum.TextXAlignment.Left
GBSub.Parent = GroupBox

local StatsContainer = Instance.new("Frame")
StatsContainer.Size = UDim2.new(1, -20, 1, -50)
StatsContainer.Position = UDim2.new(0, 10, 0, 45)
StatsContainer.BackgroundTransparency = 1
StatsContainer.Parent = GroupBox

local StatsLayout = Instance.new("UIGridLayout")
StatsLayout.CellSize = UDim2.new(0.48, 0, 0, 48)
StatsLayout.CellPadding = UDim2.new(0.04, 0, 0, 8)
StatsLayout.FillDirection = Enum.FillDirection.Horizontal
StatsLayout.SortOrder = Enum.SortOrder.LayoutOrder
StatsLayout.Parent = StatsContainer

local function CreateStatCard(title, initialValue, updateFunc)
    local card = Instance.new("Frame")
    card.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    card.BorderSizePixel = 0
    card.Parent = StatsContainer

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = card

    local tLabel = Instance.new("TextLabel")
    tLabel.Size = UDim2.new(1, -10, 0, 15)
    tLabel.Position = UDim2.new(0, 10, 0, 8)
    tLabel.BackgroundTransparency = 1
    tLabel.Text = title
    tLabel.TextColor3 = TEXT_MAIN
    tLabel.Font = Enum.Font.GothamBold
    tLabel.TextSize = 13
    tLabel.TextXAlignment = Enum.TextXAlignment.Left
    tLabel.Parent = card

    local vLabel = Instance.new("TextLabel")
    vLabel.Size = UDim2.new(1, -10, 0, 15)
    vLabel.Position = UDim2.new(0, 10, 0, 25)
    vLabel.BackgroundTransparency = 1
    vLabel.Text = initialValue
    vLabel.TextColor3 = TEXT_SUB
    vLabel.Font = Enum.Font.Gotham
    vLabel.TextSize = 11
    vLabel.TextXAlignment = Enum.TextXAlignment.Left
    vLabel.Parent = card

    if updateFunc then
        task.spawn(function()
            while task.wait(1) do
                if vLabel and vLabel.Parent then
                    vLabel.Text = updateFunc()
                else
                    break
                end
            end
        end)
    end
end

local joinTime = tick()
CreateStatCard("Players", #Players:GetPlayers() .. " playing", function()
    return #Players:GetPlayers() .. " playing"
end)
CreateStatCard("Max Players", Players.MaxPlayers .. " players max", nil)
CreateStatCard("Latency", "Calculating...", function()
    local success, ping = pcall(function() return LocalPlayer:GetNetworkPing() * 1000 end)
    if success and ping then return math.floor(ping) .. " ms" end
    return "0 ms"
end)
CreateStatCard("In server for", "00:00:00", function()
    local t = tick() - joinTime
    local h = math.floor(t / 3600)
    local m = math.floor((t % 3600) / 60)
    local s = math.floor(t % 60)
    return string.format("%02d:%02d:%02d", h, m, s)
end)

-- ====== GAME INFO BOX ======
local GameBox = Instance.new("Frame")
GameBox.Name = "GameBox"
GameBox.Size = UDim2.new(1, 0, 0, 80)
GameBox.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
GameBox.BackgroundTransparency = 0.5
GameBox.BorderSizePixel = 0
GameBox.Parent = infoPage

local GBCorner2 = Instance.new("UICorner")
GBCorner2.CornerRadius = UDim.new(0, 8)
GBCorner2.Parent = GameBox

local GBStroke2 = Instance.new("UIStroke")
GBStroke2.Color = Color3.fromRGB(60, 60, 70)
GBStroke2.Parent = GameBox

local GameIcon = Instance.new("ImageLabel")
GameIcon.Size = UDim2.new(0, 50, 0, 50)
GameIcon.Position = UDim2.new(0, 15, 0.5, -25)
GameIcon.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
GameIcon.BorderSizePixel = 0
GameIcon.Image = "rbxthumb://type=Asset&id=" .. game.PlaceId .. "&w=150&h=150"
GameIcon.Parent = GameBox

local IconCorner = Instance.new("UICorner")
IconCorner.CornerRadius = UDim.new(0, 8)
IconCorner.Parent = GameIcon

local GameNameLabel = Instance.new("TextLabel")
GameNameLabel.Size = UDim2.new(1, -160, 0, 20)
GameNameLabel.Position = UDim2.new(0, 80, 0, 20)
GameNameLabel.BackgroundTransparency = 1
GameNameLabel.Text = "Cargando Juego..."
GameNameLabel.TextColor3 = TEXT_MAIN
GameNameLabel.Font = Enum.Font.GothamBold
GameNameLabel.TextSize = 14
GameNameLabel.TextXAlignment = Enum.TextXAlignment.Left
GameNameLabel.TextTruncate = Enum.TextTruncate.AtEnd
GameNameLabel.Parent = GameBox

task.spawn(function()
    pcall(function()
        local MarketPlace = game:GetService("MarketplaceService")
        local info = MarketPlace:GetProductInfo(game.PlaceId)
        GameNameLabel.Text = info.Name
    end)
end)

local JobIdLabel = Instance.new("TextLabel")
JobIdLabel.Size = UDim2.new(1, -160, 0, 15)
JobIdLabel.Position = UDim2.new(0, 80, 0, 42)
JobIdLabel.BackgroundTransparency = 1
JobIdLabel.Text = "JobId: " .. (game.JobId ~= "" and string.sub(game.JobId, 1, 10) .. "..." or "Servidor Privado/Local")
JobIdLabel.TextColor3 = TEXT_SUB
JobIdLabel.Font = Enum.Font.Gotham
JobIdLabel.TextSize = 11
JobIdLabel.TextXAlignment = Enum.TextXAlignment.Left
JobIdLabel.Parent = GameBox

local CopyJobBtn = Instance.new("TextButton")
CopyJobBtn.Size = UDim2.new(0, 60, 0, 26)
CopyJobBtn.Position = UDim2.new(1, -75, 0.5, -13)
CopyJobBtn.BackgroundColor3 = GLASS_HIGHLIGHT
CopyJobBtn.BackgroundTransparency = 0.8
CopyJobBtn.Text = "Copy"
CopyJobBtn.TextColor3 = TEXT_MAIN
CopyJobBtn.Font = Enum.Font.GothamBold
CopyJobBtn.TextSize = 12
CopyJobBtn.Parent = GameBox

local CopyBtnCorner = Instance.new("UICorner")
CopyBtnCorner.CornerRadius = UDim.new(0, 6)
CopyBtnCorner.Parent = CopyJobBtn

local CopyStroke = Instance.new("UIStroke")
CopyStroke.Color = GLASS_HIGHLIGHT
CopyStroke.Transparency = 0.4
CopyStroke.Parent = CopyJobBtn

CopyJobBtn.MouseEnter:Connect(function()
    TweenService:Create(CopyJobBtn, TweenInfo.new(0.2), { BackgroundTransparency = 0.6 }):Play()
end)
CopyJobBtn.MouseLeave:Connect(function()
    TweenService:Create(CopyJobBtn, TweenInfo.new(0.2), { BackgroundTransparency = 0.8 }):Play()
end)

CopyJobBtn.MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard(game.JobId)
        Notify("JobId Copiado ✔️", 2.5)
    else
        Notify("Tu ejecutor no soporta copiar a portapapeles", 3)
    end
end)

-- Init
task.delay(0.1, function()
    SwitchTab("Main")
end)

-- LOGICA PARA ARRASTRAR LA UI
local dragging = false
local dragInput, dragStart, startPos

TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

TopBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

-- ====== LOGICA ACS GUN MODS ======
local function ApplyACSMods(tool)
    if not tool:IsA("Tool") then return end

    local acsSettings = tool:FindFirstChild("ACS_Settings")
    if not acsSettings or not acsSettings:IsA("ModuleScript") then return end

    pcall(function()
        local settingsTable = require(acsSettings)

        -- Inf Ammo
        if getgenv().GMods.InfAmmo then
            settingsTable.Ammo = 999
            settingsTable.StoredAmmo = 9999
            settingsTable.AmmoInGun = 999
            settingsTable.MaxStoredAmmo = 9999
        end

        -- No Recoil / No Spread
        if getgenv().GMods.NoRecoil then
            settingsTable.camRecoil = { camRecoilUp = { 0, 0 }, camRecoilTilt = { 0, 0 }, camRecoilLeft = { 0, 0 }, camRecoilRight = { 0, 0 } }
            settingsTable.gunRecoil = { gunRecoilUp = { 0, 0 }, gunRecoilTilt = { 0, 0 }, gunRecoilLeft = { 0, 0 }, gunRecoilRight = { 0, 0 } }
            settingsTable.MinSpread = 0
            settingsTable.MaxSpread = 0
            settingsTable.AimSpreadReduction = 5
            settingsTable.AimRecoilReduction = 5
        end

        -- Wallbang (Penetracion masiva)
        if getgenv().GMods.Wallbang then
            settingsTable.BulletPenetration = 9999
            settingsTable.MuzzleVelocity = 99999 -- Ignora desaceleracion de CanPierceFunction
        end
    end)
end

local function ProcessCharacter(char)
    if not char then return end
    -- Hookear herramientas existentes
    for _, tool in ipairs(char:GetDescendants()) do
        ApplyACSMods(tool)
    end
    -- Hookear herramientas equipadas en el futuro
    char.ChildAdded:Connect(function(child)
        task.wait(0.1)
        ApplyACSMods(child)
    end)
end

-- Observar Backpack (Inventario base)
LocalPlayer.Backpack.ChildAdded:Connect(function(child)
    task.wait(0.1)
    ApplyACSMods(child)
end)

-- Loop para forzar aplicacion constante (1.5 seg) a todas las armas cargadas
task.spawn(function()
    while task.wait(1.5) do
        if LocalPlayer.Character then
            for _, tool in ipairs(LocalPlayer.Character:GetDescendants()) do
                ApplyACSMods(tool)
            end
        end
        for _, tool in ipairs(LocalPlayer.Backpack:GetChildren()) do
            ApplyACSMods(tool)
        end
    end
end)

-- Re-escanear personaje al respawnear
LocalPlayer.CharacterAdded:Connect(ProcessCharacter)
if LocalPlayer.Character then
    ProcessCharacter(LocalPlayer.Character)
end

-- ====== SILENT AIM (Namecall Hook) ======
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera

local function GetClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = math.huge
    local mousePos = UserInputService:GetMouseLocation()
    local gmods = getgenv().GMods

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            -- Verificar equipo si aplica
            local onSameTeam = player.Team ~= nil and LocalPlayer.Team ~= nil and player.Team == LocalPlayer.Team
            if not gmods.TeamCheck or not onSameTeam then
                local head = player.Character.Head
                local pos, onScreen = Camera:WorldToViewportPoint(head.Position)

                if onScreen then
                    -- Distancia al cursor (Aimbot FOV)
                    local dist = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                    if dist < shortestDistance and dist <= 350 then -- Radio aumentado a 350px
                        shortestDistance = dist
                        closestPlayer = player
                    end
                end
            end
        end
    end
    return closestPlayer
end

local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = { ... }

    -- ====== ANTI-KICK ======
    if tostring(method) == "Kick" and self == LocalPlayer and not checkcaller() then
        task.spawn(function()
            if Notify then Notify("Intento de Kick bloqueado", 3) end
        end)
        return nil
    end

    -- ====== HOOKS (SILENT AIM & OTHERS) ======
    return oldNamecall(self, ...)
end))

-- ====== SILENT AIM & WALLBANG (OPTIMIZED HITBOX) ======
-- Combinamos el hook de Raycast con un hitbox más discreto pero efectivo.
task.spawn(function()
    local function getExploitBox(char)
        for _, v in ipairs(char:GetChildren()) do
            if v.Name == "Head" and v:FindFirstChild("ACS_Aimbot_Tag") then
                return v
            end
        end
        return nil
    end

    while task.wait(0.1) do
        local gmods = getgenv().GMods
        if gmods and (gmods.SilentAim or gmods.Wallbang) then
            local target = GetClosestPlayer()
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    if target and player == target then
                        local fakeHead = getExploitBox(player.Character)
                        if not fakeHead then
                            fakeHead = Instance.new("Part")
                            fakeHead.Name = "Head"
                            fakeHead.Transparency = 0.8
                            fakeHead.BrickColor = BrickColor.new("Cyan") -- Color más discreto "tecnológico"
                            fakeHead.Material = Enum.Material.ForceField
                            fakeHead.CanCollide = false
                            fakeHead.Massless = true

                            local tag = Instance.new("StringValue")
                            tag.Name = "ACS_Aimbot_Tag"
                            tag.Parent = fakeHead

                            local weld = Instance.new("WeldConstraint")
                            weld.Part0 = player.Character.HumanoidRootPart
                            weld.Part1 = fakeHead
                            weld.Parent = fakeHead

                            fakeHead.CFrame = player.Character.HumanoidRootPart.CFrame
                            fakeHead.Parent = player.Character
                        end
                        -- Con el hook de Raycast, ya no necesitamos 40 studs de hitbox.
                        -- 8-12 studs es suficiente para registrar daño a través de paredes sin ser obvio.
                        local size = gmods.Wallbang and 10 or 6
                        fakeHead.Size = Vector3.new(size, size, size)
                    else
                        local oldBox = getExploitBox(player.Character)
                        if oldBox then oldBox:Destroy() end
                    end
                end
            end
        else
            for _, player in ipairs(Players:GetPlayers()) do
                if player and player.Character then
                    local oldBox = getExploitBox(player.Character)
                    if oldBox then oldBox:Destroy() end
                end
            end
        end
    end
end)

-- ====== ANTI-KICK YA INTEGRADO EN NAMECALL ======

-- ====== SISTEMA ESP (Drawing API) ======
-- Inspirado en Fight.lua, dibuja geometría rápida directo en la capa de GPU del executor
local espCache = {}
local camera = workspace.CurrentCamera

local function CreateESP(player)
    local esp = {}

    -- Tracers (Líneas desde arriba)
    esp.Tracer = Drawing.new("Line")
    esp.Tracer.Visible = false
    esp.Tracer.Color = Color3.fromRGB(200, 30, 30)
    esp.Tracer.Thickness = 1.2
    esp.Tracer.Transparency = 0.8

    -- Box
    esp.Box = Drawing.new("Square")
    esp.Box.Visible = false
    esp.Box.Color = Color3.fromRGB(240, 60, 60)
    esp.Box.Thickness = 1.2
    esp.Box.Transparency = 1
    esp.Box.Filled = false

    -- Name & Distance (Arriba de la cabeza)
    esp.Name = Drawing.new("Text")
    esp.Name.Visible = false
    esp.Name.Color = Color3.fromRGB(255, 255, 255)
    esp.Name.Size = 13
    esp.Name.Center = true
    esp.Name.Outline = true

    -- Tool (Bajo los pies)
    esp.Tool = Drawing.new("Text")
    esp.Tool.Visible = false
    esp.Tool.Color = Color3.fromRGB(150, 200, 255)
    esp.Tool.Size = 12
    esp.Tool.Center = true
    esp.Tool.Outline = true

    -- Skeleton Lines (12 bones minimum for R15)
    esp.Skeleton = {}
    for i = 1, 14 do
        local line = Drawing.new("Line")
        line.Visible = false
        line.Color = Color3.fromRGB(255, 255, 255)
        line.Thickness = 1.5
        line.Transparency = 1
        table.insert(esp.Skeleton, line)
    end

    espCache[player] = esp
end

local function RemoveESP(player)
    if espCache[player] then
        for _, draw in pairs(espCache[player]) do
            if type(draw) == "table" then
                for _, line in ipairs(draw) do line:Remove() end
            else
                draw:Remove()
            end
        end
        espCache[player] = nil
    end
end

for _, p in ipairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then CreateESP(p) end
end
Players.PlayerAdded:Connect(function(p)
    if p ~= LocalPlayer then CreateESP(p) end
end)
Players.PlayerRemoving:Connect(RemoveESP)

-- Define skeleton connections for R15
local skeletonConnections = {
    { "Head",          "UpperTorso" },
    { "UpperTorso",    "LowerTorso" },
    { "UpperTorso",    "LeftUpperArm" },
    { "LeftUpperArm",  "LeftLowerArm" },
    { "LeftLowerArm",  "LeftHand" },
    { "UpperTorso",    "RightUpperArm" },
    { "RightUpperArm", "RightLowerArm" },
    { "RightLowerArm", "RightHand" },
    { "LowerTorso",    "LeftUpperLeg" },
    { "LeftUpperLeg",  "LeftLowerLeg" },
    { "LeftLowerLeg",  "LeftFoot" },
    { "LowerTorso",    "RightUpperLeg" },
    { "RightUpperLeg", "RightLowerLeg" },
    { "RightLowerLeg", "RightFoot" }
}

game:GetService("RunService").RenderStepped:Connect(function()
    local gmods = getgenv().GMods
    if not gmods then return end

    -- Animated blue pulse for Chams (breathing glow effect)
    local pulse = math.abs(math.sin(tick() * 2)) -- 0 to 1 smooth oscillation
    local chamsFill = Color3.fromRGB(
        math.floor(30 + pulse * 20),             -- subtle red shift
        math.floor(80 + pulse * 60),             -- green shimmer
        math.floor(200 + pulse * 55)             -- dominant electric blue
    )
    local chamsOutline = Color3.fromRGB(
        math.floor(100 + pulse * 80),
        math.floor(160 + pulse * 80),
        255
    )

    for player, esp in pairs(espCache) do
        local isAlive = player.Character and player.Character:FindFirstChild("HumanoidRootPart") and
            player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0
        local isActive = gmods.ESP_Boxes or gmods.ESP_Info or gmods.ESP_Tracers or gmods.ESP_Skeleton or
            gmods.ESP_Distance or gmods.ESP_Chams
        local onSameTeam = player.Team ~= nil and LocalPlayer.Team ~= nil and player.Team == LocalPlayer.Team
        local allowRender = isAlive and isActive and (not gmods.TeamCheck or not onSameTeam)

        if allowRender then
            local hrp = player.Character.HumanoidRootPart
            local head = player.Character:FindFirstChild("Head")

            -- Chams Rendering
            if gmods.ESP_Chams then
                local highlight = player.Character:FindFirstChild("ESP_Chams_HL")
                if not highlight then
                    highlight = Instance.new("Highlight")
                    highlight.Name = "ESP_Chams_HL"
                    highlight.FillTransparency = 0.5
                    highlight.OutlineTransparency = 0
                    highlight.Parent = player.Character
                end
                highlight.FillColor = chamsFill
                highlight.FillTransparency = 0.3 + (pulse * 0.3) -- opacity also pulses
                highlight.OutlineColor = chamsOutline
            else
                local highlight = player.Character:FindFirstChild("ESP_Chams_HL")
                if highlight then highlight:Destroy() end
            end

            -- Screen calculations
            local pos, onScreen = camera:WorldToViewportPoint(hrp.Position)

            if onScreen then
                local headPos = camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                local legPos = camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
                local boxHeight = math.abs(headPos.Y - legPos.Y)
                local boxWidth = boxHeight * 0.65

                local myPos = (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")) and
                    LocalPlayer.Character.HumanoidRootPart.Position or Vector3.zero
                local dist = math.floor((hrp.Position - myPos).Magnitude)

                -- Render Tracers
                if gmods.ESP_Tracers then
                    esp.Tracer.From = Vector2.new(camera.ViewportSize.X / 2, 0)
                    esp.Tracer.To = Vector2.new(pos.X, headPos.Y)
                    esp.Tracer.Visible = true
                else
                    esp.Tracer.Visible = false
                end

                -- Render Box
                if gmods.ESP_Boxes then
                    esp.Box.Size = Vector2.new(boxWidth, boxHeight)
                    esp.Box.Position = Vector2.new(pos.X - boxWidth / 2, headPos.Y)
                    esp.Box.Visible = true
                else
                    esp.Box.Visible = false
                end

                -- Render Info & Distance
                if gmods.ESP_Info or gmods.ESP_Distance then
                    local nameStr = ""
                    if gmods.ESP_Info then nameStr = player.DisplayName end
                    if gmods.ESP_Distance then nameStr = nameStr .. " [" .. tostring(dist) .. "m]" end

                    esp.Name.Text = nameStr
                    esp.Name.Position = Vector2.new(pos.X, headPos.Y - 16)
                    esp.Name.Visible = nameStr ~= ""

                    if gmods.ESP_Info then
                        local tool = player.Character:FindFirstChildOfClass("Tool")
                        if tool then
                            esp.Tool.Text = tool.Name
                            esp.Tool.Position = Vector2.new(pos.X, legPos.Y + 3)
                            esp.Tool.Visible = true
                        else
                            esp.Tool.Visible = false
                        end
                    else
                        esp.Tool.Visible = false
                    end
                else
                    esp.Name.Visible = false
                    esp.Tool.Visible = false
                end

                -- Render Skeleton
                if gmods.ESP_Skeleton then
                    for i, connections in ipairs(skeletonConnections) do
                        local part1 = player.Character:FindFirstChild(connections[1])
                        local part2 = player.Character:FindFirstChild(connections[2])
                        local lineDraw = esp.Skeleton[i]

                        if part1 and part2 and lineDraw then
                            local p1, on1 = camera:WorldToViewportPoint(part1.Position)
                            local p2, on2 = camera:WorldToViewportPoint(part2.Position)
                            if on1 and on2 then
                                lineDraw.From = Vector2.new(p1.X, p1.Y)
                                lineDraw.To = Vector2.new(p2.X, p2.Y)
                                lineDraw.Visible = true
                            else
                                lineDraw.Visible = false
                            end
                        else
                            if lineDraw then lineDraw.Visible = false end
                        end
                    end
                else
                    for _, lineDraw in ipairs(esp.Skeleton) do lineDraw.Visible = false end
                end
            else
                esp.Tracer.Visible = false
                esp.Box.Visible = false
                esp.Name.Visible = false
                esp.Tool.Visible = false
                for _, lineDraw in ipairs(esp.Skeleton) do lineDraw.Visible = false end
            end
        else
            -- Cleanup when hidden/dead
            local highlight = player.Character and player.Character:FindFirstChild("ESP_Chams_HL")
            if highlight then highlight:Destroy() end

            esp.Tracer.Visible = false
            esp.Box.Visible = false
            esp.Name.Visible = false
            esp.Tool.Visible = false
            for _, lineDraw in ipairs(esp.Skeleton) do lineDraw.Visible = false end
        end
    end
end)

-- ====== 2D RADAR (Apple Glass Floating UI) ======
local radarBase = Instance.new("Frame")
radarBase.Name = "RadarUI"
radarBase.Size = UDim2.new(0, 180, 0, 180)
radarBase.Position = UDim2.new(1, -200, 1, -200)
radarBase.BackgroundColor3 = GLASS_COLOR
radarBase.BackgroundTransparency = 0.2
radarBase.BorderSizePixel = 0
radarBase.Active = true
radarBase.Draggable = true
radarBase.Visible = false
radarBase.Parent = ScreenGui

local radarCorner = Instance.new("UICorner")
radarCorner.CornerRadius = UDim.new(1, 0) -- Circle
radarCorner.Parent = radarBase

local radarStroke = Instance.new("UIStroke")
radarStroke.Color = GLASS_HIGHLIGHT
radarStroke.Thickness = 2
radarStroke.Parent = radarBase

-- Crosshair in radar center
local xLine = Instance.new("Frame")
xLine.Size = UDim2.new(1, 0, 0, 1)
xLine.Position = UDim2.new(0, 0, 0.5, 0)
xLine.BackgroundColor3 = GLASS_HIGHLIGHT
xLine.BorderSizePixel = 0
xLine.Transparency = 0.5
xLine.Parent = radarBase

local yLine = Instance.new("Frame")
yLine.Size = UDim2.new(0, 1, 1, 0)
yLine.Position = UDim2.new(0.5, 0, 0, 0)
yLine.BackgroundColor3 = GLASS_HIGHLIGHT
yLine.BorderSizePixel = 0
yLine.Transparency = 0.5
yLine.Parent = radarBase

local centerDot = Instance.new("Frame")
centerDot.Size = UDim2.new(0, 4, 0, 4)
centerDot.Position = UDim2.new(0.5, -2, 0.5, -2)
centerDot.BackgroundColor3 = TEXT_MAIN
centerDot.BorderSizePixel = 0
centerDot.Parent = radarBase
local dotCorner = Instance.new("UICorner")
dotCorner.CornerRadius = UDim.new(1, 0)
dotCorner.Parent = centerDot

local radarBlips = {}

game:GetService("RunService").RenderStepped:Connect(function()
    local gmods = getgenv().GMods
    if not gmods then return end

    if gmods.ESP_Radar then
        radarBase.Visible = true
        local radius = radarBase.AbsoluteSize.X / 2
        local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local isAlive = player.Character and player.Character:FindFirstChild("HumanoidRootPart") and
                    player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0
                local onSameTeam = player.Team ~= nil and LocalPlayer.Team ~= nil and player.Team == LocalPlayer.Team
                local allowBlip = isAlive and (not gmods.TeamCheck or not onSameTeam)

                if allowBlip and myRoot then
                    local targetRoot = player.Character.HumanoidRootPart
                    local relPos = camera.CFrame:ToObjectSpace(targetRoot.CFrame).Position

                    if not radarBlips[player] then
                        local blip = Instance.new("Frame")
                        blip.Size = UDim2.new(0, 6, 0, 6)
                        blip.BackgroundColor3 = Color3.fromRGB(255, 30, 30)
                        blip.BorderSizePixel = 0
                        blip.Parent = radarBase
                        local blipCorner = Instance.new("UICorner")
                        blipCorner.CornerRadius = UDim.new(1, 0)
                        blipCorner.Parent = blip
                        radarBlips[player] = blip
                    end

                    local blip = radarBlips[player]
                    local distance = math.sqrt(relPos.X ^ 2 + relPos.Z ^ 2)
                    local maxRadarRange = 150 -- Studs you can see in radar

                    -- Scale distance
                    local ratio = distance / maxRadarRange
                    local angle = math.atan2(relPos.X, relPos.Z)

                    -- Clamp to circle radius
                    local clampedRatio = math.clamp(ratio, 0, 1)
                    local uiX = math.sin(angle) * (radius * clampedRatio)
                    local uiY = math.cos(angle) * (radius * clampedRatio)

                    blip.Position = UDim2.new(0.5, uiX - 3, 0.5, uiY - 3)

                    if onSameTeam then
                        blip.BackgroundColor3 = Color3.fromRGB(30, 255, 30) -- Green for friendlies if teamcheck is off
                    else
                        blip.BackgroundColor3 = Color3.fromRGB(255, 30, 30) -- Red for enemies
                    end
                    blip.Visible = true
                else
                    if radarBlips[player] then radarBlips[player].Visible = false end
                end
            end
        end
    else
        radarBase.Visible = false
    end
end)
Players.PlayerRemoving:Connect(function(player)
    if radarBlips[player] then
        radarBlips[player]:Destroy()
        radarBlips[player] = nil
    end
end)
