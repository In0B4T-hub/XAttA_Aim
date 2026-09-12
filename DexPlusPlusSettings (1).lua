-- ==========================================================
-- XAttA - Admin Panel (FIXED)
-- Hecho por DeepSeek e In0B4T_SD (Ksjzns84)
-- ==========================================================

-- ===== Limpieza de ejecución previa =====
if _G.XAttA_Cleanup then
    pcall(_G.XAttA_Cleanup)
    _G.XAttA_Cleanup = nil
end
_G.XAttA_Loaded = false

-- ========== Servicios ==========
local Players      = game:GetService("Players")
local UIS          = game:GetService("UserInputService")
local RunService   = game:GetService("RunService")
local Lighting     = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

local LP  = Players.LocalPlayer
local Cam = workspace.CurrentCamera

-- ========== Parent seguro ==========
local function getUIParent()
    if gethui then
        local ok, h = pcall(gethui)
        if ok and h then return h end
    end
    local ok, cg = pcall(function() return game:GetService("CoreGui") end)
    if ok and cg then
        local probe = Instance.new("Folder")
        local s = pcall(function() probe.Parent = cg end)
        probe:Destroy()
        if s then return cg end
    end
    return LP:WaitForChild("PlayerGui")
end

local UIParent = getUIParent()

-- ========== Helpers ==========
local function new(class, props, parent)
    local ok, o = pcall(Instance.new, class)
    if not ok or not o then return nil end
    for k, v in pairs(props or {}) do
        pcall(function() o[k] = v end)
    end
    if parent then pcall(function() o.Parent = parent end) end
    return o
end

local function corner(r, parent)
    if not parent then return end
    return new("UICorner", { CornerRadius = UDim.new(0, r) }, parent)
end

local function stroke(color, thick, trans, parent)
    if not parent then return end
    return new("UIStroke", {
        Color = color or Color3.fromRGB(255,255,255),
        Thickness = thick or 1,
        Transparency = trans or 0.6,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    }, parent)
end

local function gradient(colors, rot, parent)
    if not parent then return end
    local g = new("UIGradient", { Rotation = rot or 90 }, parent)
    if not g then return end
    local seq = {}
    local n = #colors
    for i, c in ipairs(colors) do
        local t = (n > 1) and (i-1)/(n-1) or 0
        table.insert(seq, ColorSequenceKeypoint.new(t, c))
    end
    pcall(function() g.Color = ColorSequence.new(seq) end)
    return g
end

-- ========== Estado ==========
local State = {
    Windowed = false,
    Visible = true,
    Minimized = false,
    SidebarVisible = true,
    Player = {
        WalkSpeed = 16, WalkLoop = false,
        JumpPower = 50, JumpLoop = false,
        InfiniteJump = false, NoAnim = false, Invisible = false,
    },
    Camera = {
        FOV = Cam and Cam.FieldOfView or 70,
        Fullbright = false,
        ForceCamera = "Default",
        Xray = false,
        Hitbox = false,
        HitboxStyle = "2D",
    },
}

local Original = {
    Lighting = {
        Brightness = Lighting.Brightness,
        ClockTime = Lighting.ClockTime,
        FogEnd = Lighting.FogEnd,
        GlobalShadows = Lighting.GlobalShadows,
        OutdoorAmbient = Lighting.OutdoorAmbient,
        Ambient = Lighting.Ambient,
    },
}

local Connections = {}
local function track(c) table.insert(Connections, c); return c end

_G.XAttA_Cleanup = function()
    for _, c in ipairs(Connections) do pcall(function() c:Disconnect() end) end
    Connections = {}
    pcall(function()
        local g = UIParent:FindFirstChild("XAttA_Panel")
        if g then g:Destroy() end
    end)
    pcall(function()
        local b = Lighting:FindFirstChild("XAttA_Blur")
        if b then b:Destroy() end
    end)
    _G.XAttA_Loaded = false
end

-- ========== ScreenGui ==========
local Screen = new("ScreenGui", {
    Name = "XAttA_Panel",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    DisplayOrder = 999999,
}, UIParent)
if not Screen then warn("[XAttA] No se pudo crear el ScreenGui"); return end

-- ========== Loading ==========
local Loading = new("Frame", {
    Name = "Loading",
    Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = Color3.fromRGB(10, 12, 18),
    BorderSizePixel = 0,
    ZIndex = 100,
}, Screen)

local barBg = new("Frame", {
    Name = "BarBg",
    Size = UDim2.new(0, 300, 0, 4),
    Position = UDim2.new(0.5, -150, 0.55, 0),
    BackgroundColor3 = Color3.fromRGB(35, 38, 55),
    BorderSizePixel = 0,
    ZIndex = 102,
}, Loading)
if barBg then corner(4, barBg) end

local loadBarFill = new("Frame", {
    Name = "BarFill",
    Size = UDim2.new(0, 0, 1, 0),
    BackgroundColor3 = Color3.fromRGB(120, 180, 255),
    BorderSizePixel = 0,
    ZIndex = 103,
}, barBg)
if loadBarFill then
    corner(4, loadBarFill)
    gradient({Color3.fromRGB(80,150,255), Color3.fromRGB(180,120,255)}, 0, loadBarFill)
end

local title = new("TextLabel", {
    Name = "Title",
    Size = UDim2.new(0, 220, 0, 60),
    Position = UDim2.new(0.5, -110, 0.42, 0),
    BackgroundTransparency = 1,
    Font = Enum.Font.GothamBlack,
    Text = "XAttA",
    TextColor3 = Color3.fromRGB(255,255,255),
    TextScaled = true,
    ZIndex = 102,
}, Loading)
if title then
    gradient({Color3.fromRGB(120,180,255), Color3.fromRGB(200,140,255)}, 45, title)
end

new("TextLabel", {
    Name = "Sub",
    Size = UDim2.new(1, 0, 0, 20),
    Position = UDim2.new(0, 0, 0.5, 10),
    BackgroundTransparency = 1,
    Font = Enum.Font.Gotham,
    Text = "Admin Panel",
    TextColor3 = Color3.fromRGB(180, 190, 220),
    TextSize = 14,
    ZIndex = 102,
}, Loading)

new("TextLabel", {
    Name = "Credits",
    Size = UDim2.new(1, 0, 0, 16),
    Position = UDim2.new(0, 0, 0.62, 0),
    BackgroundTransparency = 1,
    Font = Enum.Font.GothamMedium,
    Text = "Hecho por DeepSeek e In0B4T_SD (Ksjzns84)",
    TextColor3 = Color3.fromRGB(130, 140, 170),
    TextSize = 12,
    ZIndex = 102,
}, Loading)

-- Blur
local blurEffect = new("BlurEffect", {
    Name = "XAttA_Blur", Size = 0, Enabled = false,
}, Lighting)

-- Fondo oscuro
local DarkOverlay = new("Frame", {
    Name = "DarkOverlay",
    Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = Color3.fromRGB(0, 0, 0),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Visible = false,
    ZIndex = 1,
}, Screen)

-- ========== Ventana ==========
local Window = new("Frame", {
    Name = "Window",
    Size = UDim2.new(0, 760, 0, 480),
    Position = UDim2.new(0.5, -380, 0.5, -240),
    BackgroundColor3 = Color3.fromRGB(18, 20, 28),
    BorderSizePixel = 0,
    ClipsDescendants = true,
    Visible = false,
    ZIndex = 5,
}, Screen)
corner(10, Window)
stroke(Color3.fromRGB(60, 65, 90), 1, 0.3, Window)

local TopBar = new("Frame", {
    Name = "TopBar",
    Size = UDim2.new(1, 0, 0, 36),
    BackgroundColor3 = Color3.fromRGB(24, 27, 38),
    BorderSizePixel = 0,
    ZIndex = 6,
}, Window)

new("Frame", {
    Size = UDim2.new(1, 0, 0, 1),
    Position = UDim2.new(0, 0, 1, -1),
    BackgroundColor3 = Color3.fromRGB(50, 55, 75),
    BorderSizePixel = 0,
    ZIndex = 7,
}, TopBar)

local menuBtn = new("TextButton", {
    Size = UDim2.new(0, 30, 0, 30),
    Position = UDim2.new(0, 4, 0.5, -15),
    BackgroundColor3 = Color3.fromRGB(40, 44, 60),
    Text = "☰", Font = Enum.Font.GothamBold, TextSize = 16,
    TextColor3 = Color3.fromRGB(220, 225, 240),
    BorderSizePixel = 0, ZIndex = 7, AutoButtonColor = true,
}, TopBar)
corner(6, menuBtn)

new("TextLabel", {
    Size = UDim2.new(1, -320, 1, 0),
    Position = UDim2.new(0, 42, 0, 0),
    BackgroundTransparency = 1,
    Font = Enum.Font.GothamBold, Text = "XAttA",
    TextColor3 = Color3.fromRGB(230, 235, 250), TextSize = 14,
    TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 7,
}, TopBar)

new("TextLabel", {
    Size = UDim2.new(0, 200, 1, 0),
    Position = UDim2.new(1, -300, 0, 0),
    BackgroundTransparency = 1,
    Font = Enum.Font.Gotham, Text = "Admin Panel",
    TextColor3 = Color3.fromRGB(130, 140, 170), TextSize = 12,
    TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 7,
}, TopBar)

local function topButton(text, color, xOffset)
    local b = new("TextButton", {
        Size = UDim2.new(0, 26, 0, 26),
        Position = UDim2.new(1, xOffset, 0.5, -13),
        BackgroundColor3 = color, Text = text,
        Font = Enum.Font.GothamBold, TextSize = 14,
        TextColor3 = Color3.fromRGB(255,255,255),
        BorderSizePixel = 0, ZIndex = 7, AutoButtonColor = true,
    }, TopBar)
    corner(6, b)
    return b
end

local minBtn   = topButton("—", Color3.fromRGB(70, 75, 95), -96)
local maxBtn   = topButton("▢", Color3.fromRGB(70, 75, 95), -64)
local closeBtn = topButton("✕", Color3.fromRGB(200, 60, 60), -32)

local Body = new("Frame", {
    Name = "Body",
    Size = UDim2.new(1, 0, 1, -36),
    Position = UDim2.new(0, 0, 0, 36),
    BackgroundTransparency = 1, ZIndex = 6,
}, Window)

local Sidebar = new("Frame", {
    Name = "Sidebar",
    Size = UDim2.new(0, 170, 1, 0),
    BackgroundColor3 = Color3.fromRGB(22, 25, 35),
    BorderSizePixel = 0, ZIndex = 7,
}, Body)

new("Frame", {
    Size = UDim2.new(0, 1, 1, 0),
    Position = UDim2.new(1, -1, 0, 0),
    BackgroundColor3 = Color3.fromRGB(45, 50, 70),
    BorderSizePixel = 0, ZIndex = 8,
}, Sidebar)

local Content = new("Frame", {
    Name = "Content",
    Size = UDim2.new(1, -170, 1, 0),
    Position = UDim2.new(0, 170, 0, 0),
    BackgroundTransparency = 1, ClipsDescendants = true, ZIndex = 7,
}, Body)

-- ========== Páginas y Nav ==========
local Pages = {}
local NavButtons = {}
local CurrentPage = nil

local function switchPage(name)
    for n, p in pairs(Pages) do p.Visible = (n == name) end
    for n, b in pairs(NavButtons) do
        if n == name then
            b.BackgroundColor3 = Color3.fromRGB(45, 50, 70)
            b.BackgroundTransparency = 0
            b.TextColor3 = Color3.fromRGB(230, 235, 250)
        else
            b.BackgroundTransparency = 1
            b.TextColor3 = Color3.fromRGB(160, 170, 200)
        end
    end
    CurrentPage = name
end

local function addNavButton(name, label, icon)
    local idx = 0
    for _ in pairs(NavButtons) do idx = idx + 1 end
    local b = new("TextButton", {
        Size = UDim2.new(1, -12, 0, 38),
        Position = UDim2.new(0, 6, 0, 6 + idx * 42),
        BackgroundColor3 = Color3.fromRGB(0,0,0),
        BackgroundTransparency = 1,
        Text = "   " .. icon .. "  " .. label,
        Font = Enum.Font.GothamMedium, TextSize = 14,
        TextColor3 = Color3.fromRGB(160, 170, 200),
        TextXAlignment = Enum.TextXAlignment.Left,
        BorderSizePixel = 0, AutoButtonColor = false, ZIndex = 8,
    }, Sidebar)
    corner(6, b)
    track(b.MouseEnter:Connect(function()
        if CurrentPage ~= name then
            b.BackgroundTransparency = 0.6
            b.BackgroundColor3 = Color3.fromRGB(40, 44, 60)
        end
    end))
    track(b.MouseLeave:Connect(function()
        if CurrentPage ~= name then b.BackgroundTransparency = 1 end
    end))
    track(b.MouseButton1Click:Connect(function() switchPage(name) end))
    NavButtons[name] = b
    return b
end

local function addPage(name)
    local p = new("ScrollingFrame", {
        Name = name,
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1, BorderSizePixel = 0,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = Color3.fromRGB(80, 90, 120),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false, ZIndex = 8,
    }, Content)
    new("UIPadding", {
        PaddingTop = UDim.new(0, 12), PaddingLeft = UDim.new(0, 16),
        PaddingRight = UDim.new(0, 16), PaddingBottom = UDim.new(0, 12),
    }, p)
    new("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8),
    }, p)
    Pages[name] = p
    return p
end

addNavButton("Player", "Player", "👤")
addNavButton("Camera", "Camera", "🎥")
local PlayerPage = addPage("Player")
local CameraPage = addPage("Camera")

-- ========== Componentes ==========
local function sectionTitle(parent, text)
    new("TextLabel", {
        Size = UDim2.new(1, 0, 0, 26),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold, Text = text,
        TextColor3 = Color3.fromRGB(200, 210, 240), TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, parent)
end

local function makeSlider(parent, label, min, max, default, isInt, callback)
    local row = new("Frame", {
        Size = UDim2.new(1, 0, 0, 60),
        BackgroundColor3 = Color3.fromRGB(26, 29, 40),
        BorderSizePixel = 0,
    }, parent)
    corner(8, row); stroke(Color3.fromRGB(50, 55, 75), 1, 0.4, row)

    new("TextLabel", {
        Size = UDim2.new(1, -20, 0, 20),
        Position = UDim2.new(0, 10, 0, 6),
        BackgroundTransparency = 1, Font = Enum.Font.GothamMedium,
        Text = label, TextColor3 = Color3.fromRGB(220, 225, 240),
        TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left,
    }, row)

    local valueLbl = new("TextLabel", {
        Size = UDim2.new(0, 80, 0, 20),
        Position = UDim2.new(1, -90, 0, 6),
        BackgroundTransparency = 1, Font = Enum.Font.GothamBold,
        Text = tostring(default), TextColor3 = Color3.fromRGB(120, 180, 255),
        TextSize = 13, TextXAlignment = Enum.TextXAlignment.Right,
    }, row)

    local trackBg = new("Frame", {
        Size = UDim2.new(1, -20, 0, 6),
        Position = UDim2.new(0, 10, 0, 34),
        BackgroundColor3 = Color3.fromRGB(45, 50, 70),
        BorderSizePixel = 0,
    }, row)
    corner(3, trackBg)

    local fill = new("Frame", {
        Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(120, 180, 255),
        BorderSizePixel = 0,
    }, trackBg)
    corner(3, fill)
    gradient({Color3.fromRGB(80,150,255), Color3.fromRGB(180,120,255)}, 0, fill)

    local knob = new("Frame", {
        Size = UDim2.new(0, 14, 0, 14),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new((default - min) / (max - min), 0, 0.5, 0),
        BackgroundColor3 = Color3.fromRGB(255,255,255), BorderSizePixel = 0,
    }, trackBg)
    corner(14, knob)

    local sliderBtn = new("TextButton", {
        Size = UDim2.new(1, 0, 1, 20),
        Position = UDim2.new(0, 0, 0, -10),
        BackgroundTransparency = 1, Text = "",
    }, trackBg)

    local dragging = false
    local function updateFromX(x)
        local rel = math.clamp((x - trackBg.AbsolutePosition.X) / math.max(trackBg.AbsoluteSize.X, 1), 0, 1)
        local val = min + (max - min) * rel
        if isInt then val = math.floor(val + 0.5) end
        valueLbl.Text = tostring(val)
        fill.Size = UDim2.new(rel, 0, 1, 0)
        knob.Position = UDim2.new(rel, 0, 0.5, 0)
        if callback then pcall(callback, val) end
    end

    track(sliderBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            updateFromX(input.Position.X)
        end
    end))
    track(UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
            updateFromX(input.Position.X)
        end
    end))
    track(UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end))

    return row
end

local function makeToggle(parent, label, default, callback)
    local row = new("Frame", {
        Size = UDim2.new(1, 0, 0, 44),
        BackgroundColor3 = Color3.fromRGB(26, 29, 40),
        BorderSizePixel = 0,
    }, parent)
    corner(8, row); stroke(Color3.fromRGB(50, 55, 75), 1, 0.4, row)

    new("TextLabel", {
        Size = UDim2.new(1, -80, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1, Font = Enum.Font.GothamMedium,
        Text = label, TextColor3 = Color3.fromRGB(220, 225, 240),
        TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left,
    }, row)

    local switchBg = new("Frame", {
        Size = UDim2.new(0, 46, 0, 24),
        Position = UDim2.new(1, -58, 0.5, -12),
        BackgroundColor3 = default and Color3.fromRGB(80, 200, 120) or Color3.fromRGB(55, 60, 80),
        BorderSizePixel = 0,
    }, row)
    corner(24, switchBg)

    local knob = new("Frame", {
        Size = UDim2.new(0, 18, 0, 18),
        Position = default and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9),
        BackgroundColor3 = Color3.fromRGB(255,255,255), BorderSizePixel = 0,
    }, switchBg)
    corner(18, knob)

    local state = default
    local function set(on, fire)
        state = on
        TweenService:Create(switchBg, TweenInfo.new(0.15), {
            BackgroundColor3 = on and Color3.fromRGB(80, 200, 120) or Color3.fromRGB(55, 60, 80)
        }):Play()
        TweenService:Create(knob, TweenInfo.new(0.15), {
            Position = on and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
        }):Play()
        if callback and fire ~= false then pcall(callback, on) end
    end

    local btn = new("TextButton", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1, Text = "",
    }, row)
    track(btn.MouseButton1Click:Connect(function() set(not state) end))

    return set, row
end

local function makeButtonRow(parent, label, buttons, callback)
    local row = new("Frame", {
        Size = UDim2.new(1, 0, 0, 44),
        BackgroundColor3 = Color3.fromRGB(26, 29, 40),
        BorderSizePixel = 0,
    }, parent)
    corner(8, row); stroke(Color3.fromRGB(50, 55, 75), 1, 0.4, row)

    new("TextLabel", {
        Size = UDim2.new(0, 140, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1, Font = Enum.Font.GothamMedium,
        Text = label, TextColor3 = Color3.fromRGB(220, 225, 240),
        TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left,
    }, row)

    local container = new("Frame", {
        Size = UDim2.new(1, -170, 1, -12),
        Position = UDim2.new(0, 158, 0, 6),
        BackgroundTransparency = 1,
    }, row)
    new("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, container)

    local btns = {}
    for i, txt in ipairs(buttons) do
        local b = new("TextButton", {
            Size = UDim2.new(0, 60, 1, 0),
            BackgroundColor3 = Color3.fromRGB(45, 50, 70),
            Font = Enum.Font.GothamMedium, Text = txt,
            TextColor3 = Color3.fromRGB(220, 225, 240),
            TextSize = 12, BorderSizePixel = 0, LayoutOrder = i,
            AutoButtonColor = true,
        }, container)
        corner(6, b)
        track(b.MouseButton1Click:Connect(function()
            for _, o in ipairs(btns) do o.BackgroundColor3 = Color3.fromRGB(45, 50, 70) end
            b.BackgroundColor3 = Color3.fromRGB(80, 130, 220)
            if callback then pcall(callback, i, txt) end
        end))
        btns[i] = b
    end
    return row, btns
end

-- ==========================================================
-- PLAYER PAGE
-- ==========================================================
sectionTitle(PlayerPage, "Movimiento")

makeSlider(PlayerPage, "WalkSpeed", 1, 500, 16, true, function(v)
    State.Player.WalkSpeed = v
    local char = LP.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = v end
end)

makeToggle(PlayerPage, "Loop WalkSpeed (anclar)", false, function(on)
    State.Player.WalkLoop = on
    if on then
        task.spawn(function()
            while State.Player.WalkLoop do
                local char = LP.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if hum then hum.WalkSpeed = State.Player.WalkSpeed end
                task.wait(0.1)
            end
        end)
    end
end)

makeSlider(PlayerPage, "JumpPower", 1, 1000, 50, true, function(v)
    State.Player.JumpPower = v
    local char = LP.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum.UseJumpPower = true; hum.JumpPower = v end
end)

makeToggle(PlayerPage, "Loop JumpPower (anclar)", false, function(on)
    State.Player.JumpLoop = on
    if on then
        task.spawn(function()
            while State.Player.JumpLoop do
                local char = LP.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if hum then hum.UseJumpPower = true; hum.JumpPower = State.Player.JumpPower end
                task.wait(0.1)
            end
        end)
    end
end)

sectionTitle(PlayerPage, "Habilidades")

makeToggle(PlayerPage, "Infinite Jump", false, function(on)
    State.Player.InfiniteJump = on
end)

makeToggle(PlayerPage, "No Anim", false, function(on)
    State.Player.NoAnim = on
    local char = LP.Character
    if char then
        local animate = char:FindFirstChild("Animate")
        if animate then animate.Disabled = on end
        if on then
            local hum = char:FindFirstChildOfClass("Humanoid")
            local animator = hum and hum:FindFirstChildOfClass("Animator")
            if animator then
                for _, t in ipairs(animator:GetPlayingAnimationTracks()) do t:Stop(0) end
            end
        end
    end
end)

makeToggle(PlayerPage, "Invisible", false, function(on)
    State.Player.Invisible = on
    local char = LP.Character
    if char then
        for _, d in ipairs(char:GetDescendants()) do
            if d:IsA("BasePart") and d.Name ~= "HumanoidRootPart" then
                d.LocalTransparencyModifier = on and 1 or 0
                d.Transparency = on and 1 or 0
            elseif d:IsA("Decal") or d:IsA("Texture") then
                d.Transparency = on and 1 or 0
            end
        end
    end
end)

-- ==========================================================
-- CAMERA PAGE
-- ==========================================================
sectionTitle(CameraPage, "Visión")

makeSlider(CameraPage, "Field of View (FOV)", 20, 160, 70, true, function(v)
    State.Camera.FOV = v
    if Cam then Cam.FieldOfView = v end
end)

makeToggle(CameraPage, "Fullbright", false, function(on)
    State.Camera.Fullbright = on
    if on then
        Lighting.Brightness = 3
        Lighting.ClockTime = 14
        Lighting.FogEnd = 1e6
        Lighting.GlobalShadows = false
        Lighting.OutdoorAmbient = Color3.fromRGB(178,178,178)
        Lighting.Ambient = Color3.fromRGB(178,178,178)
    else
        for k, v in pairs(Original.Lighting) do Lighting[k] = v end
    end
end)

sectionTitle(CameraPage, "Modo de cámara")

makeButtonRow(CameraPage, "Force Camera",
    {"Default", "1st", "3rd", "Fixed", "ShiftLock"},
    function(i, txt)
        local cameraType = Enum.CameraType.Custom
        if txt == "Default" then
            cameraType = Enum.CameraType.Custom
            LP.CameraMode = Enum.CameraMode.Classic
        elseif txt == "1st" then
            cameraType = Enum.CameraType.Custom
            LP.CameraMode = Enum.CameraMode.LockFirstPerson
        elseif txt == "3rd" then
            cameraType = Enum.CameraType.Custom
            LP.CameraMode = Enum.CameraMode.Classic
        elseif txt == "Fixed" then
            cameraType = Enum.CameraType.Fixed
        elseif txt == "ShiftLock" then
            cameraType = Enum.CameraType.Custom
            LP.DevEnableMouseLock = true
            UIS.MouseBehavior = Enum.MouseBehavior.LockCenter
        end
        State.Camera.ForceCamera = txt
        if Cam then Cam.CameraType = cameraType end
    end
)

sectionTitle(CameraPage, "Utilidades")

makeToggle(CameraPage, "Xray (ver a través de paredes)", false, function(on)
    State.Camera.Xray = on
    if not on then
        for _, d in ipairs(workspace:GetDescendants()) do
            if d:IsA("BasePart") then
                pcall(function() d.LocalTransparencyModifier = 0 end)
            end
        end
    end
end)

makeToggle(CameraPage, "Hitbox", false, function(on)
    State.Camera.Hitbox = on
    if not on then
        for _, plr in ipairs(Players:GetPlayers()) do
            local char = plr.Character
            if char then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local b2 = hrp:FindFirstChild("XAttA_Hitbox2D")
                    local b3 = hrp:FindFirstChild("XAttA_Hitbox3D")
                    if b2 then b2:Destroy() end
                    if b3 then b3:Destroy() end
                end
            end
        end
    end
end)

makeButtonRow(CameraPage, "Estilo Hitbox", {"2D", "3D"}, function(i, txt)
    State.Camera.HitboxStyle = txt
end)

-- ==========================================================
-- Loop visual (Xray + Hitbox)
-- ==========================================================
local function updateHitboxes()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP then
            local char = plr.Character
            if char then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    if State.Camera.HitboxStyle == "2D" then
                        local sb = hrp:FindFirstChild("XAttA_Hitbox3D")
                        if sb then sb:Destroy() end
                        if not hrp:FindFirstChild("XAttA_Hitbox2D") then
                            local bg = Instance.new("BillboardGui")
                            bg.Name = "XAttA_Hitbox2D"
                            bg.Adornee = hrp
                            bg.Size = UDim2.new(0, 60, 0, 100)
                            bg.AlwaysOnTop = true
                            bg.Parent = hrp
                            local f = Instance.new("Frame", bg)
                            f.Size = UDim2.fromScale(1, 1)
                            f.BackgroundColor3 = Color3.fromRGB(255, 40, 40)
                            f.BackgroundTransparency = 0.5
                            f.BorderSizePixel = 2
                            f.BorderColor3 = Color3.fromRGB(255, 0, 0)
                        end
                    else
                        local bb = hrp:FindFirstChild("XAttA_Hitbox2D")
                        if bb then bb:Destroy() end
                        if not hrp:FindFirstChild("XAttA_Hitbox3D") then
                            local sb = Instance.new("SelectionBox")
                            sb.Name = "XAttA_Hitbox3D"
                            sb.Adornee = hrp
                            sb.Color3 = Color3.fromRGB(255, 40, 40)
                            sb.LineThickness = 0.05
                            sb.SurfaceTransparency = 0.7
                            sb.SurfaceColor3 = Color3.fromRGB(255, 0, 0)
                            sb.Parent = hrp
                        end
                    end
                end
            end
        end
    end
end

local xrayAccum = 0
track(RunService.RenderStepped:Connect(function(dt)
    xrayAccum = xrayAccum + dt
    if xrayAccum < 0.15 then return end
    xrayAccum = 0

    if State.Camera.Hitbox then
        pcall(updateHitboxes)
    end

    if State.Camera.Xray then
        local myChar = LP.Character
        for _, d in ipairs(workspace:GetDescendants()) do
            if d:IsA("BasePart") and not (myChar and d:IsDescendantOf(myChar)) then
                pcall(function() d.LocalTransparencyModifier = 0.5 end)
            end
        end
    end
end))

-- Infinite Jump
track(UIS.JumpRequest:Connect(function()
    if State.Player.InfiniteJump then
        local char = LP.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end))

-- No Anim loop
task.spawn(function()
    while _G.XAttA_Loaded do
        task.wait(0.1)
        if State.Player.NoAnim then
            local char = LP.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local animator = hum and hum:FindFirstChildOfClass("Animator")
            if animator then
                for _, t in ipairs(animator:GetPlayingAnimationTracks()) do t:Stop(0) end
            end
        end
    end
end)

-- Invisible loop
task.spawn(function()
    while _G.XAttA_Loaded do
        task.wait(0.25)
        if State.Player.Invisible then
            local char = LP.Character
            if char then
                for _, d in ipairs(char:GetDescendants()) do
                    if d:IsA("BasePart") and d.Name ~= "HumanoidRootPart" then
                        if d.LocalTransparencyModifier ~= 1 then
                            d.LocalTransparencyModifier = 1
                        end
                    end
                end
            end
        end
    end
end)

-- Respawn
track(LP.CharacterAdded:Connect(function(char)
    task.wait(0.4)
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = State.Player.WalkSpeed
        hum.UseJumpPower = true
        hum.JumpPower = State.Player.JumpPower
    end
    if State.Player.NoAnim then
        local animate = char:FindFirstChild("Animate")
        if animate then animate.Disabled = true end
    end
end))

-- ==========================================================
-- Drag & Resize
-- ==========================================================
local dragging, dragStart, startPos = false, nil, nil

track(TopBar.InputBegan:Connect(function(input)
    if State.Windowed and not State.Minimized then
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = Window.Position
        end
    end
end))

track(UIS.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
    or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        Window.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end))

track(UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end))

local ResizeHandle = new("Frame", {
    Name = "ResizeHandle",
    Size = UDim2.new(0, 18, 0, 18),
    Position = UDim2.new(1, -18, 1, -18),
    BackgroundColor3 = Color3.fromRGB(60, 65, 90),
    BorderSizePixel = 0, Visible = false, ZIndex = 20,
}, Window)
corner(4, ResizeHandle)
new("Frame", {
    Size = UDim2.new(0, 8, 0, 1),
    Position = UDim2.new(1, -10, 1, -5),
    BackgroundColor3 = Color3.fromRGB(160, 170, 200),
    BorderSizePixel = 0,
}, ResizeHandle)
new("Frame", {
    Size = UDim2.new(0, 1, 0, 8),
    Position = UDim2.new(1, -5, 1, -10),
    BackgroundColor3 = Color3.fromRGB(160, 170, 200),
    BorderSizePixel = 0,
}, ResizeHandle)

local resizing, resizeStart, resizeStartSize = false, nil, nil

track(ResizeHandle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        resizing = true
        resizeStart = input.Position
        resizeStartSize = Window.AbsoluteSize
    end
end))

track(UIS.InputChanged:Connect(function(input)
    if resizing and (input.UserInputType == Enum.UserInputType.MouseMovement
    or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - resizeStart
        local newW = math.max(400, resizeStartSize.X + delta.X)
        local newH = math.max(280, resizeStartSize.Y + delta.Y)
        Window.Size = UDim2.new(0, newW, 0, newH)
    end
end))

track(UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        resizing = false
    end
end))

-- ==========================================================
-- Fullscreen / Window
-- ==========================================================
local function applyFullscreen()
    State.Windowed = false
    Window.Size = UDim2.new(1, -40, 1, -40)
    Window.Position = UDim2.new(0, 20, 0, 20)
    ResizeHandle.Visible = false
    DarkOverlay.Visible = true
    DarkOverlay.BackgroundTransparency = 0.5
    if blurEffect then
        blurEffect.Enabled = true
        TweenService:Create(blurEffect, TweenInfo.new(0.25), { Size = 20 }):Play()
    end
end

local function applyWindowed()
    State.Windowed = true
    Window.Size = UDim2.new(0, 760, 0, 480)
    Window.Position = UDim2.new(0.5, -380, 0.5, -240)
    ResizeHandle.Visible = true
    DarkOverlay.Visible = false
    if blurEffect then
        TweenService:Create(blurEffect, TweenInfo.new(0.25), { Size = 0 }):Play()
        task.delay(0.25, function()
            if blurEffect then blurEffect.Enabled = false end
        end)
    end
end

-- Botón flotante
local MiniButton = new("TextButton", {
    Name = "MiniButton",
    Size = UDim2.new(0, 52, 0, 52),
    Position = UDim2.new(0, 20, 0, 80),
    BackgroundColor3 = Color3.fromRGB(24, 27, 38),
    Text = "X", Font = Enum.Font.GothamBlack, TextSize = 20,
    TextColor3 = Color3.fromRGB(120, 180, 255),
    BorderSizePixel = 0, Visible = false, ZIndex = 50,
}, Screen)
corner(26, MiniButton)
stroke(Color3.fromRGB(80, 130, 220), 2, 0.2, MiniButton)

new("TextLabel", {
    Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1, Text = "XAttA",
    Font = Enum.Font.GothamBold, TextSize = 11,
    TextColor3 = Color3.fromRGB(200, 215, 255), ZIndex = 51,
}, MiniButton)

track(MiniButton.MouseButton1Click:Connect(function()
    State.Minimized = false
    MiniButton.Visible = false
    Window.Visible = true
    DarkOverlay.Visible = not State.Windowed
end))

-- Sidebar toggle
local function setSidebar(visible)
    State.SidebarVisible = visible
    TweenService:Create(Sidebar, TweenInfo.new(0.2), {
        Size = visible and UDim2.new(0, 170, 1, 0) or UDim2.new(0, 0, 1, 0)
    }):Play()
    TweenService:Create(Content, TweenInfo.new(0.2), {
        Size = visible and UDim2.new(1, -170, 1, 0) or UDim2.new(1, 0, 1, 0),
        Position = visible and UDim2.new(0, 170, 0, 0) or UDim2.new(0, 0, 0, 0),
    }):Play()
end

track(menuBtn.MouseButton1Click:Connect(function()
    setSidebar(not State.SidebarVisible)
end))

track(minBtn.MouseButton1Click:Connect(function()
    State.Minimized = true
    Window.Visible = false
    DarkOverlay.Visible = false
    MiniButton.Visible = true
end))

track(maxBtn.MouseButton1Click:Connect(function()
    if State.Windowed then applyFullscreen() else applyWindowed() end
end))

track(closeBtn.MouseButton1Click:Connect(function()
    State.Visible = false
    Window.Visible = false
    MiniButton.Visible = false
    DarkOverlay.Visible = false
    if blurEffect then blurEffect.Enabled = false; blurEffect.Size = 0 end
end))

-- Reabrir con RightShift / RightAlt
track(UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if not UIS.TouchEnabled then
        if input.KeyCode == Enum.KeyCode.RightShift
        or input.KeyCode == Enum.KeyCode.RightAlt then
            if not State.Visible then
                State.Visible = true
                State.Minimized = false
                MiniButton.Visible = false
                Window.Visible = true
                DarkOverlay.Visible = not State.Windowed
                if not State.Windowed and blurEffect then
                    blurEffect.Enabled = true
                    TweenService:Create(blurEffect, TweenInfo.new(0.25), { Size = 20 }):Play()
                end
            elseif State.Minimized then
                State.Minimized = false
                MiniButton.Visible = false
                Window.Visible = true
                DarkOverlay.Visible = not State.Windowed
            else
                State.Minimized = true
                Window.Visible = false
                DarkOverlay.Visible = false
                MiniButton.Visible = true
            end
        end
    end
end))

-- ==========================================================
-- Adaptación a dispositivo
-- ==========================================================
local function adaptToDevice()
    local isMobile = UIS.TouchEnabled and not UIS.MouseEnabled
    if isMobile then
        Window.Size = UDim2.new(1, -20, 1, -20)
        Window.Position = UDim2.new(0, 10, 0, 10)
        State.Windowed = false
        ResizeHandle.Visible = false
        Sidebar.Size = UDim2.new(0, 140, 1, 0)
        Content.Size = UDim2.new(1, -140, 1, 0)
        Content.Position = UDim2.new(0, 140, 0, 0)
        MiniButton.Size = UDim2.new(0, 60, 0, 60)
        corner(30, MiniButton)
    else
        applyFullscreen()
    end
end

pcall(adaptToDevice)

-- ==========================================================
-- Animación de carga + REVEAL (robusta)
-- ==========================================================
switchPage("Player")
_G.XAttA_Loaded = true

task.spawn(function()
    local success, err = pcall(function()
        -- Animación de barra
        if loadBarFill then
            for i = 0, 100 do
                loadBarFill.Size = UDim2.new(i/100, 0, 1, 0)
                task.wait(0.012)
            end
        else
            task.wait(1.2)
        end

        task.wait(0.2)

        -- Fade out del fondo
        TweenService:Create(Loading, TweenInfo.new(0.5), {
            BackgroundTransparency = 1
        }):Play()

        -- Fade out de hijos (separado por tipo para evitar errores)
        for _, d in ipairs(Loading:GetDescendants()) do
            if d:IsA("TextLabel") then
                TweenService:Create(d, TweenInfo.new(0.4), {
                    BackgroundTransparency = 1,
                    TextTransparency = 1,
                }):Play()
            elseif d:IsA("Frame") then
                TweenService:Create(d, TweenInfo.new(0.4), {
                    BackgroundTransparency = 1,
                }):Play()
            end
        end

        task.wait(0.6)
    end)

    if not success then
        warn("[XAttA] Error en animación de carga: " .. tostring(err))
    end

    -- Pase lo que pase, destruimos el loading y mostramos la ventana
    pcall(function() Loading:Destroy() end)

    -- Mostrar ventana
    Window.Visible = true
    Window.Size = UDim2.new(0, 0, 0, 0)
    local targetSize = State.Windowed and UDim2.new(0, 760, 0, 480) or UDim2.new(1, -40, 1, -40)
    TweenService:Create(Window, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = targetSize
    }):Play()
end)

print("[XAttA] Panel cargado. Hecho por DeepSeek e In0B4T_SD (Ksjzns84)")
print("[XAttA] Si algo se queda raro, ejecuta: _G.XAttA_Cleanup()")