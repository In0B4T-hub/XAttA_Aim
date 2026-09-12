--==============================================================
--  XAttA Aim Assist  |  v3.3 (Style+Accessibility) - Base v3.2
--  Hecho con AntiGravity IA e In0B4T_SD (Ksjzns84)
--==============================================================

-- [[ EDITAR AQUÍ - Personaliza tus mensajes y frases ]]
local Mensajes = {
    Pregunta = "¿Deseas activar XAttA Aim Assist?",
    AlSi     = "¡XAttA ULTRA ha sido activado!",
    AlNo     = "XAttA desactivado. Suerte apuntando solo.",
    Guardar  = "¿Guardar Estado de botones?",
}

local FrasesReflexion = {
    "La práctica hace al maestro.", "Cada derrota enseña más que una victoria.",
    "La constancia vence al talento.", "No cuentes los días, haz que los días cuenten.",
    "El único modo de hacer un gran trabajo es amar lo que haces.",
    "Cree en ti y ya estarás a mitad del camino.", "La disciplina es el puente entre metas y logros.",
    "El éxito no es definitivo, el fracaso no es fatal.", "Lo que no te mata te hace más fuerte.",
    "Sueña en grande, empieza pequeño, actúa ahora.",
}
-- ==============================================================

local Players      = game:GetService("Players")
local UIS          = game:GetService("UserInputService")
local RunService   = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Stats        = game:GetService("Stats")
local HttpService  = game:GetService("HttpService")
local LP           = Players.LocalPlayer
local Cam          = workspace.CurrentCamera
local PlayerGui    = LP:WaitForChild("PlayerGui")
local IS_MOBILE    = UIS.TouchEnabled and not UIS.MouseEnabled

local SAVE_FILE = "XAttA_save.json"

local FONTS = {
    {n="Gotham",f=Enum.Font.Gotham},{n="GothamBold",f=Enum.Font.GothamBold},
    {n="GothamBlack",f=Enum.Font.GothamBlack},{n="SourceSans",f=Enum.Font.SourceSans},
    {n="SourceSansBold",f=Enum.Font.SourceSansBold},{n="Code",f=Enum.Font.Code},
    {n="SciFi",f=Enum.Font.SciFi},{n="Arcade",f=Enum.Font.Arcade},
    {n="Fantasy",f=Enum.Font.Fantasy},{n="Antique",f=Enum.Font.Antique},
    {n="Bodoni",f=Enum.Font.Bodoni},{n="Cartoon",f=Enum.Font.Cartoon},
    {n="Highway",f=Enum.Font.Highway},{n="Jura",f=Enum.Font.Jura},
    {n="Legacy",f=Enum.Font.Legacy},{n="Nunito",f=Enum.Font.Nunito},
    {n="Oswald",f=Enum.Font.Oswald},{n="Roboto",f=Enum.Font.Roboto},
    {n="RobotoMono",f=Enum.Font.RobotoMono},{n="Ubuntu",f=Enum.Font.Ubuntu},
    {n="TitilliumWeb",f=Enum.Font.TitilliumWeb},
}

local UI = {}
local uiOpen = false
local compactMode = false

local S = {
    Smoothness=45, FovRadius=200, Prediction=0.08,
    ActivationMode = IS_MOBILE and "Toggle" or "RightClick",
    IgnoreWalls=false, DebugWall=false, ShowCircle=true, ShowName=true,
    ToggleActive=false, Priority="Crosshair", TeamCheck=true,
    AimBone="Head", StickyAim=true, SmoothType="Smoothstep",
    ShowCrosshair=true, CrosshairStyle="CrossGap", CrosshairColor=Color3.fromRGB(0,255,140),
    CrosshairSize=10, CrosshairThick=2, CrosshairGap=4, CrosshairGlow=true,
    CircleColor=Color3.fromRGB(0,200,255), CircleThickness=1.5, CirclePulse=true,
    CameraFov=80, ForceCamera="Default", CameraMode="Default",
    ShowFPS=true, ShowPing=true,
    PanelBg=Color3.fromRGB(13,16,24), AccentColor=Color3.fromRGB(0,200,255),
    GlassEffect=true, Ripples=true, Animations=true,
    CircleOffset     = {x=0, y=0},
    CrosshairOffset  = {x=0, y=0},
    ReopenPos        = {xs=0.5, xo=0, ys=0.5, yo=0},
    TogglePos        = {xs=0.15, xo=0, ys=0.5, yo=0},
    FPS  = {fontIndex=2,fontSize=13,bgColor=Color3.fromRGB(10,15,25),textColor=Color3.fromRGB(0,220,255),bgTransp=0.35,anchored=false,pos=UDim2.new(0,10,0,10)},
    PING = {fontIndex=2,fontSize=13,bgColor=Color3.fromRGB(10,15,25),textColor=Color3.fromRGB(0,220,255),bgTransp=0.35,anchored=false,pos=UDim2.new(0,10,0,44)},
    NAME = {fontSize=15,bgColor=Color3.fromRGB(10,15,25)},

    -- ====== NUEVO: ESTILO AVANZADO ======
    UIScale          = 1.0,       -- DPI global
    PanelTransparency= 0,         -- transparencia del panel principal
    BorderThickness  = 1.5,       -- grosor de bordes
    CornerRadius     = 26,        -- redondez
    GlowIntensity    = 1.0,       -- intensidad de brillo de acento
    ShowTabIcons     = true,      -- iconos en pestañas
    GradientAngle    = 135,       -- ángulo del gradiente
    AccentPulse      = false,     -- pulsación de acento global

    -- ====== NUEVO: ACCESIBILIDAD ======
    HighContrast     = false,     -- alto contraste
    EasyMode         = false,     -- oculta opciones avanzadas
    FontScale        = 1.0,       -- escala global de fuente
    ReduceMotion     = false,     -- desactiva animaciones
    ColorBlindMode   = "None",    -- None | Protanopia | Deuteranopia | Tritanopia
    ShowTooltips     = true,      -- mostrar ayuda al pasar mouse

    -- Guardado para restaurar cuando se desactiva HighContrast
    _savedAccent     = Color3.fromRGB(0,200,255),
    _savedPanelBg    = Color3.fromRGB(13,16,24),
}

-- ============ Lista de items avanzados (se ocultan en EasyMode) ============
local ADVANCED_ITEMS = {
    ["Wallcheck (Bloquear A Través de Paredes)"] = true,
    ["Debug Wallcheck"] = true,
    ["Sticky Aim (no cambiar objetivo)"] = true,
    ["Ignorar Compañeros (Team Check)"] = true,
    ["Bone a Apuntar"] = true,
    ["Prioridad de Objetivo"] = true,
    ["Tipo de Suavizado"] = true,
    ["Forzar Cámara"] = true,
    ["Modo de Cámara"] = true,
    ["Glow"] = true,
    ["Offset X"] = true,
    ["Offset Y"] = true,
    ["Grosor"] = true,
}

--==================== Helpers ====================
local function create(class, props, parent)
    local o = Instance.new(class)
    for k,v in pairs(props or {}) do o[k]=v end
    if parent then o.Parent=parent end
    return o
end
local function tw(o,t,props,style,dir)
    if S.ReduceMotion then
        for k,v in pairs(props) do
            if k ~= "Position" and k ~= "Size" then
                pcall(function() o[k] = v end)
            end
        end
        return nil
    end
    local ti=TweenInfo.new(t or .3,style or Enum.EasingStyle.Quint,dir or Enum.EasingDirection.Out)
    local a=TweenService:Create(o,ti,props); a:Play(); return a
end
local function corner(r,p) return create("UICorner",{CornerRadius=r or UDim.new(0,8)},p) end
local function stroke(c,t,p) return create("UIStroke",{Color=c or S.AccentColor,Thickness=t or 1.5,ApplyStrokeMode=Enum.ApplyStrokeMode.Border},p) end
local function gradient(parent,c1,c2,rot) return create("UIGradient",{Color=ColorSequence.new(c1,c2),Rotation=rot or S.GradientAngle},parent) end

local function responsiveScale()
    local vp = Cam.ViewportSize
    if IS_MOBILE then
        local s = math.min(vp.X / 1700, vp.Y / 950)
        return math.clamp(s, 0.42, 0.68)
    end
    local s = math.min(vp.X / 1280, vp.Y / 720)
    return math.clamp(s, 0.62, 1.15)
end

-- ============ NUEVO: aplicar UIScale global a un contenedor ============
local function ensureUIScale(container)
    if not container then return nil end
    local existing = container:FindFirstChild("XAttA_UIScale")
    if existing then return existing end
    local us = Instance.new("UIScale")
    us.Name = "XAttA_UIScale"
    us.Scale = S.UIScale
    us.Parent = container
    return us
end

local function applyUIScale()
    if UI.main then
        local us = UI.main:FindFirstChild("XAttA_UIScale")
        if us then us.Scale = S.UIScale end
    end
    if fovGui then
        local us = fovGui:FindFirstChild("XAttA_UIScale")
        if us then us.Scale = S.UIScale end
    end
    if statsGui then
        local us = statsGui:FindFirstChild("XAttA_UIScale")
        if us then us.Scale = S.UIScale end
    end
    if crosshairGui then
        local us = crosshairGui:FindFirstChild("XAttA_UIScale")
        if us then us.Scale = S.UIScale end
    end
    if gui then
        local us = gui:FindFirstChild("XAttA_UIScale")
        if us then us.Scale = S.UIScale end
    end
end

-- ============ NUEVO: alto contraste ============
local function applyHighContrast()
    if not UI.main then return end
    if S.HighContrast then
        S._savedAccent = S.AccentColor
        S._savedPanelBg = S.PanelBg
        S.AccentColor = Color3.fromRGB(255,255,0)
        S.PanelBg = Color3.fromRGB(0,0,0)
        S.BorderThickness = math.max(S.BorderThickness, 2.5)
    else
        S.AccentColor = S._savedAccent or Color3.fromRGB(0,200,255)
        S.PanelBg = S._savedPanelBg or Color3.fromRGB(13,16,24)
    end
    UI.main.BackgroundColor3 = S.PanelBg
    for _, d in ipairs(UI.main:GetDescendants()) do
        if d:IsA("UIStroke") then
            d.Color = S.AccentColor
            d.Thickness = S.BorderThickness
        end
        if d:IsA("TextLabel") or d:IsA("TextButton") or d:IsA("TextBox") then
            if S.HighContrast then
                d.TextColor3 = Color3.fromRGB(255,255,255)
            end
        end
        if d:IsA("Frame") and d.BackgroundTransparency < 0.5 then
            if S.HighContrast then
                d.BackgroundColor3 = Color3.fromRGB(0,0,0)
            end
        end
    end
end

-- ============ NUEVO: filtro colorblind ============
local function applyColorBlind()
    if not UI.main then return end
    local tint = nil
    if S.ColorBlindMode == "Protanopia" then tint = Color3.fromRGB(0.56, 0.44, 0.0)
    elseif S.ColorBlindMode == "Deuteranopia" then tint = Color3.fromRGB(0.5, 0.5, 0.0)
    elseif S.ColorBlindMode == "Tritanopia" then tint = Color3.fromRGB(0.0, 0.5, 0.56)
    end
    local overlay = UI.main:FindFirstChild("_colorblindOverlay")
    if tint then
        if not overlay then
            overlay = create("Frame",{
                Name="_colorblindOverlay",
                Size=UDim2.fromScale(1,1),
                BackgroundColor3=tint,
                BackgroundTransparency=0.85,
                BorderSizePixel=0,
                ZIndex=999,
                Active=false,
            }, UI.main)
            corner(UDim.new(0, S.CornerRadius), overlay)
        end
        overlay.BackgroundColor3 = tint
    elseif overlay then
        overlay:Destroy()
    end
end

local function addRipple(btn)
    if not S.Ripples then return end
    btn.ClipsDescendants = true
    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if not S.Ripples then return end
            local r = create("Frame",{
                Size=UDim2.fromOffset(0,0),
                Position=UDim2.new(0, input.Position.X - btn.AbsolutePosition.X, 0, input.Position.Y - btn.AbsolutePosition.Y),
                AnchorPoint=Vector2.new(0.5,0.5), BackgroundColor3=Color3.new(1,1,1),
                BackgroundTransparency=0.7, BorderSizePixel=0, ZIndex=(btn.ZIndex or 1)+10,
            }, btn)
            corner(UDim.new(1,0), r)
            local maxSize = math.max(btn.AbsoluteSize.X, btn.AbsoluteSize.Y) * 2
            tw(r, 0.5, {Size=UDim2.fromOffset(maxSize,maxSize), BackgroundTransparency=1}, Enum.EasingStyle.Quad)
            task.delay(0.5, function() r:Destroy() end)
        end
    end)
end

--==================== Notificaciones ====================
local notifGui, notifHolder
local function ensureNotif()
    if notifGui then return end
    notifGui = create("ScreenGui",{Name="XAttA_Notif",ResetOnSpawn=false,IgnoreGuiInset=true,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,DisplayOrder=99999},PlayerGui)
    notifHolder = create("Frame",{Size=UDim2.new(0,300,1,0),Position=UDim2.new(1,-10,0,0),AnchorPoint=Vector2.new(1,0),BackgroundTransparency=1},notifGui)
    create("UIListLayout",{Padding=UDim.new(0,8),VerticalAlignment=Enum.VerticalAlignment.Top,HorizontalAlignment=Enum.HorizontalAlignment.Right,SortOrder=Enum.SortOrder.LayoutOrder},notifHolder)
end

local function notify(text, kind)
    ensureNotif()
    kind = kind or "info"
    local colors = {info=S.AccentColor, success=Color3.fromRGB(60,220,120), warn=Color3.fromRGB(255,180,40), error=Color3.fromRGB(240,70,80)}
    local col = colors[kind] or S.AccentColor
    local n = create("Frame",{Size=UDim2.new(1,0,0,50),Position=UDim2.new(1,30,0,0),BackgroundColor3=Color3.fromRGB(15,20,30),BackgroundTransparency=0.1,BorderSizePixel=0,LayoutOrder=math.floor(os.clock()*1000)},notifHolder)
    corner(UDim.new(0,10),n); stroke(col,1.5,n)
    create("Frame",{Size=UDim2.new(0,4,1,0),BackgroundColor3=col,BorderSizePixel=0},n)
    create("TextLabel",{Size=UDim2.new(1,-16,1,0),Position=UDim2.new(0,12,0,0),BackgroundTransparency=1,Text=text,TextColor3=Color3.fromRGB(230,240,255),Font=Enum.Font.Gotham,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true},n)
    tw(n,0.4,{Position=UDim2.new(0,0,0,0)},Enum.EasingStyle.Back)
    task.delay(3,function() tw(n,0.3,{Position=UDim2.new(1,30,0,0)},Enum.EasingStyle.Quad,Enum.EasingDirection.In); task.wait(0.35); n:Destroy() end)
end

--==================== Prompt (Sí/No) ====================
local promptGui, promptBox, promptText, promptOverlay
local function buildPrompt()
    promptGui = create("ScreenGui",{Name="XAttA_Prompt",ResetOnSpawn=false,IgnoreGuiInset=true,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,DisplayOrder=99998,Enabled=false},PlayerGui)
    local overlay = create("Frame",{Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.new(0,0,0),BackgroundTransparency=0.5,BorderSizePixel=0},promptGui)
    promptBox = create("Frame",{Size=UDim2.fromOffset(340,180),Position=UDim2.fromScale(.5,.5),AnchorPoint=Vector2.new(.5,.5),BackgroundColor3=Color3.fromRGB(13,17,26),BorderSizePixel=0,ZIndex=2},overlay)
    corner(UDim.new(0,18),promptBox); stroke(S.AccentColor,2,promptBox)
    gradient(promptBox, Color3.fromRGB(18,24,38), Color3.fromRGB(10,14,22), 135)
    promptText = create("TextLabel",{Size=UDim2.new(.88,.45),Position=UDim2.fromScale(.5,.3),AnchorPoint=Vector2.new(.5,.5),BackgroundTransparency=1,Text="",TextColor3=Color3.fromRGB(225,235,250),Font=Enum.Font.GothamBold,TextSize=17,TextWrapped=true,ZIndex=3},promptBox)
    return overlay
end

local function showPrompt(text, onYes, onNo)
    if not promptOverlay then promptOverlay = buildPrompt() end
    promptGui.Enabled = true
    promptText.Text = text
    for _,c in ipairs(promptBox:GetChildren()) do
        if c:IsA("TextButton") then c:Destroy() end
    end
    local function mkBtn(txt,col,pos,cb)
        local b=create("TextButton",{Size=UDim2.fromScale(.34,.2),Position=UDim2.fromScale(pos,.78),AnchorPoint=Vector2.new(.5,.5),BackgroundColor3=col,BorderSizePixel=0,Text=txt,TextColor3=Color3.new(1,1,1),Font=Enum.Font.GothamBold,TextSize=16,AutoButtonColor=false,ZIndex=3},promptBox)
        corner(UDim.new(0,12),b); addRipple(b)
        b.MouseEnter:Connect(function() tw(b,0.15,{BackgroundColor3=col:Lerp(Color3.new(1,1,1),0.2)}) end)
        b.MouseLeave:Connect(function() tw(b,0.15,{BackgroundColor3=col}) end)
        b.MouseButton1Click:Connect(function() promptGui.Enabled = false; if cb then cb() end end)
    end
    mkBtn("Sí", Color3.fromRGB(0,170,100), 0.28, onYes)
    mkBtn("No", Color3.fromRGB(180,45,65), 0.72, onNo)
end

--==================== Snapshots ====================
local positionSnapshot = {}
local function snapshotPositions()
    positionSnapshot = {
        CircleOffset    = {S.CircleOffset.x, S.CircleOffset.y},
        CrosshairOffset = {S.CrosshairOffset.x, S.CrosshairOffset.y},
        ReopenPos       = {S.ReopenPos.xs, S.ReopenPos.xo, S.ReopenPos.ys, S.ReopenPos.yo},
        TogglePos       = {S.TogglePos.xs, S.TogglePos.xo, S.TogglePos.ys, S.TogglePos.yo},
        FPS_pos         = {S.FPS.pos.X.Scale, S.FPS.pos.X.Offset, S.FPS.pos.Y.Scale, S.FPS.pos.Y.Offset},
        PING_pos        = {S.PING.pos.X.Scale, S.PING.pos.X.Offset, S.PING.pos.Y.Scale, S.PING.pos.Y.Offset},
    }
end

local function restoreSnapshot()
    if not positionSnapshot.FPS_pos then return end
    S.CircleOffset    = {x=positionSnapshot.CircleOffset[1], y=positionSnapshot.CircleOffset[2]}
    S.CrosshairOffset = {x=positionSnapshot.CrosshairOffset[1], y=positionSnapshot.CrosshairOffset[2]}
    S.ReopenPos       = {xs=positionSnapshot.ReopenPos[1], xo=positionSnapshot.ReopenPos[2], ys=positionSnapshot.ReopenPos[3], yo=positionSnapshot.ReopenPos[4]}
    S.TogglePos       = {xs=positionSnapshot.TogglePos[1], xo=positionSnapshot.TogglePos[2], ys=positionSnapshot.TogglePos[3], yo=positionSnapshot.TogglePos[4]}
    S.FPS.pos  = UDim2.new(positionSnapshot.FPS_pos[1], positionSnapshot.FPS_pos[2], positionSnapshot.FPS_pos[3], positionSnapshot.FPS_pos[4])
    S.PING.pos = UDim2.new(positionSnapshot.PING_pos[1], positionSnapshot.PING_pos[2], positionSnapshot.PING_pos[3], positionSnapshot.PING_pos[4])
    if UI.applyPositions then UI.applyPositions() end
end

local function hasChanges()
    if not positionSnapshot.FPS_pos then return false end
    local function diff(a,b) return math.abs((a or 0)-(b or 0)) > 0.5 end
    if diff(S.CircleOffset.x, positionSnapshot.CircleOffset[1]) then return true end
    if diff(S.CircleOffset.y, positionSnapshot.CircleOffset[2]) then return true end
    if diff(S.CrosshairOffset.x, positionSnapshot.CrosshairOffset[1]) then return true end
    if diff(S.CrosshairOffset.y, positionSnapshot.CrosshairOffset[2]) then return true end
    if diff(S.ReopenPos.xs*1000, positionSnapshot.ReopenPos[1]*1000) then return true end
    if diff(S.ReopenPos.xo, positionSnapshot.ReopenPos[2]) then return true end
    if diff(S.ReopenPos.ys*1000, positionSnapshot.ReopenPos[3]*1000) then return true end
    if diff(S.ReopenPos.yo, positionSnapshot.ReopenPos[4]) then return true end
    if diff(S.TogglePos.xs*1000, positionSnapshot.TogglePos[1]*1000) then return true end
    if diff(S.TogglePos.xo, positionSnapshot.TogglePos[2]) then return true end
    if diff(S.TogglePos.ys*1000, positionSnapshot.TogglePos[3]*1000) then return true end
    if diff(S.TogglePos.yo, positionSnapshot.TogglePos[4]) then return true end
    if diff(S.FPS.pos.X.Scale*1000, positionSnapshot.FPS_pos[1]*1000) then return true end
    if diff(S.FPS.pos.X.Offset, positionSnapshot.FPS_pos[2]) then return true end
    if diff(S.FPS.pos.Y.Scale*1000, positionSnapshot.FPS_pos[3]*1000) then return true end
    if diff(S.FPS.pos.Y.Offset, positionSnapshot.FPS_pos[4]) then return true end
    if diff(S.PING.pos.X.Scale*1000, positionSnapshot.PING_pos[1]*1000) then return true end
    if diff(S.PING.pos.X.Offset, positionSnapshot.PING_pos[2]) then return true end
    if diff(S.PING.pos.Y.Scale*1000, positionSnapshot.PING_pos[3]*1000) then return true end
    if diff(S.PING.pos.Y.Offset, positionSnapshot.PING_pos[4]) then return true end
    return false
end

--==================== Persistencia ====================
local function udimToTable(u) return {xs=u.X.Scale, xo=u.X.Offset, ys=u.Y.Scale, yo=u.Y.Offset} end
local function tableToUdim(t)
    if not t then return nil end
    return UDim2.new(t.xs or 0, t.xo or 0, t.ys or 0, t.yo or 0)
end
local function c3ToTable(c) return {c.R, c.G, c.B} end
local function tableToC3(t) if not t then return nil end return Color3.new(t[1],t[2],t[3]) end

local function saveToDisk()
    local data = {
        CircleOffset    = S.CircleOffset,
        CrosshairOffset = S.CrosshairOffset,
        ReopenPos       = S.ReopenPos,
        TogglePos       = S.TogglePos,
        FPS_pos         = udimToTable(S.FPS.pos),
        PING_pos        = udimToTable(S.PING.pos),
        -- Nuevos
        UIScale         = S.UIScale,
        PanelTransparency = S.PanelTransparency,
        BorderThickness = S.BorderThickness,
        CornerRadius    = S.CornerRadius,
        GlowIntensity   = S.GlowIntensity,
        ShowTabIcons    = S.ShowTabIcons,
        GradientAngle   = S.GradientAngle,
        AccentPulse     = S.AccentPulse,
        HighContrast    = S.HighContrast,
        EasyMode        = S.EasyMode,
        FontScale       = S.FontScale,
        ReduceMotion    = S.ReduceMotion,
        ColorBlindMode  = S.ColorBlindMode,
        ShowTooltips    = S.ShowTooltips,
        AccentColor     = c3ToTable(S.AccentColor),
        PanelBg         = c3ToTable(S.PanelBg),
    }
    local ok, json = pcall(function() return HttpService:JSONEncode(data) end)
    if not ok then return false end
    local success = pcall(function() if writefile then writefile(SAVE_FILE, json) end end)
    return success
end

local function loadFromDisk()
    local ok, content = pcall(function()
        if readfile and isfile and isfile(SAVE_FILE) then return readfile(SAVE_FILE) end
        return nil
    end)
    if not ok or not content then return false end
    local ok2, data = pcall(function() return HttpService:JSONDecode(content) end)
    if not ok2 or type(data) ~= "table" then return false end
    if data.CircleOffset then S.CircleOffset = data.CircleOffset end
    if data.CrosshairOffset then S.CrosshairOffset = data.CrosshairOffset end
    if data.ReopenPos then S.ReopenPos = data.ReopenPos end
    if data.TogglePos then S.TogglePos = data.TogglePos end
    if data.FPS_pos then S.FPS.pos = tableToUdim(data.FPS_pos) end
    if data.PING_pos then S.PING.pos = tableToUdim(data.PING_pos) end
    -- Nuevos
    if data.UIScale then S.UIScale = data.UIScale end
    if data.PanelTransparency then S.PanelTransparency = data.PanelTransparency end
    if data.BorderThickness then S.BorderThickness = data.BorderThickness end
    if data.CornerRadius then S.CornerRadius = data.CornerRadius end
    if data.GlowIntensity then S.GlowIntensity = data.GlowIntensity end
    if data.ShowTabIcons ~= nil then S.ShowTabIcons = data.ShowTabIcons end
    if data.GradientAngle then S.GradientAngle = data.GradientAngle end
    if data.AccentPulse ~= nil then S.AccentPulse = data.AccentPulse end
    if data.HighContrast ~= nil then S.HighContrast = data.HighContrast end
    if data.EasyMode ~= nil then S.EasyMode = data.EasyMode end
    if data.FontScale then S.FontScale = data.FontScale end
    if data.ReduceMotion ~= nil then S.ReduceMotion = data.ReduceMotion end
    if data.ColorBlindMode then S.ColorBlindMode = data.ColorBlindMode end
    if data.ShowTooltips ~= nil then S.ShowTooltips = data.ShowTooltips end
    if data.AccentColor then S.AccentColor = tableToC3(data.AccentColor) end
    if data.PanelBg then S.PanelBg = tableToC3(data.PanelBg) end
    return true
end

--==================== GUI Raíz ====================
local gui = create("ScreenGui",{Name="XAttA_GUI",ResetOnSpawn=false,IgnoreGuiInset=true,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,DisplayOrder=99990},PlayerGui)
ensureUIScale(gui)

--==================== Pantalla de carga ====================
local loading = create("Frame",{Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.fromRGB(6,8,14),BorderSizePixel=0,ZIndex=100},gui)
gradient(loading, Color3.fromRGB(12,16,26), Color3.fromRGB(3,4,8), 135)
for i=0,20 do
    create("Frame",{Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,i/20,0),BackgroundColor3=Color3.fromRGB(0,100,180),BackgroundTransparency=0.94,BorderSizePixel=0,ZIndex=100},loading)
    create("Frame",{Size=UDim2.new(0,1,1,0),Position=UDim2.new(i/20,0,0,0),BackgroundColor3=Color3.fromRGB(0,100,180),BackgroundTransparency=0.94,BorderSizePixel=0,ZIndex=100},loading)
end

local title = create("TextLabel",{Size=UDim2.fromScale(.6,.2),Position=UDim2.fromScale(.5,.42),AnchorPoint=Vector2.new(.5,.5),BackgroundTransparency=1,Text="XAttA",TextColor3=Color3.fromRGB(0,220,255),Font=Enum.Font.GothamBlack,TextScaled=true,TextTransparency=1,ZIndex=101},loading)
local titleStroke = create("UIStroke",{Color=Color3.fromRGB(0,120,200),Thickness=2.5,Transparency=1},title)
create("TextLabel",{Size=UDim2.fromScale(.6,.025),Position=UDim2.fromScale(.5,.58),AnchorPoint=Vector2.new(.5,.5),BackgroundTransparency=1,Text="U L T R A   v3.3",TextColor3=Color3.fromRGB(120,180,240),Font=Enum.Font.GothamBold,TextSize=12,TextTransparency=1,ZIndex=101},loading)
local subtitle = create("TextLabel",{Size=UDim2.fromScale(.5,.035),Position=UDim2.fromScale(.5,.63),AnchorPoint=Vector2.new(.5,.5),BackgroundTransparency=1,Text="Iniciando sistema...",TextColor3=Color3.fromRGB(150,180,220),Font=Enum.Font.Gotham,TextSize=14,TextTransparency=1,ZIndex=101},loading)
local barBg = create("Frame",{Size=UDim2.fromScale(.35,.006),Position=UDim2.fromScale(.5,.7),AnchorPoint=Vector2.new(.5,.5),BackgroundColor3=Color3.fromRGB(20,26,40),BorderSizePixel=0,ZIndex=101},loading)
corner(UDim.new(1,0),barBg)
local barFill = create("Frame",{Size=UDim2.fromScale(0,1),BackgroundColor3=Color3.fromRGB(0,200,255),BorderSizePixel=0,ZIndex=102},barBg)
corner(UDim.new(1,0),barFill); gradient(barFill, Color3.fromRGB(0,120,255), Color3.fromRGB(120,240,255), 0)
create("TextLabel",{Size=UDim2.fromScale(1,.03),Position=UDim2.fromScale(.5,.95),AnchorPoint=Vector2.new(.5,.5),BackgroundTransparency=1,Text="Hecho con AntiGravity IA e In0B4T_SD (Ksjzns84)",TextColor3=Color3.fromRGB(80,90,110),Font=Enum.Font.Gotham,TextSize=12,ZIndex=101},loading)

for i=1,35 do
    local p = create("Frame",{Size=UDim2.fromOffset(math.random(2,5),math.random(2,5)),Position=UDim2.new(math.random(),0,1.15,0),BackgroundColor3=Color3.fromRGB(math.random(0,100),math.random(180,255),255),BackgroundTransparency=0.3,BorderSizePixel=0,ZIndex=100},loading)
    corner(UDim.new(1,0),p)
    local dur=math.random(4,10); local tx=p.Position.X.Scale+(math.random()-0.5)*0.08
    local t=TweenService:Create(p,TweenInfo.new(dur,Enum.EasingStyle.Linear),{Position=UDim2.new(tx,0,-0.15,0),BackgroundTransparency=1})
    t:Play(); t.Completed:Connect(function() p:Destroy() end)
end

tw(title,0.7,{TextTransparency=0}); tw(titleStroke,1.2,{Transparency=0})
tw(subtitle,0.9,{TextTransparency=0}); tw(barFill,4,{Size=UDim2.fromScale(1,1)},Enum.EasingStyle.Quad,Enum.EasingDirection.InOut)

task.spawn(function()
    task.wait(0.8)
    while title.Parent do
        tw(title,0.7,{TextTransparency=0.35},Enum.EasingStyle.Sine); task.wait(0.7)
        if not title.Parent then break end
        tw(title,0.7,{TextTransparency=0},Enum.EasingStyle.Sine); task.wait(0.7)
    end
end)
task.spawn(function()
    local txts={"Iniciando sistema...","Cargando módulos...","Optimizando motor...","Cargando preferencias...","Casi listo..."}
    local i=1
    while loading.Parent do
        task.wait(0.85)
        if not loading.Parent then break end
        i=i%#txts+1
        tw(subtitle,0.2,{TextTransparency=1}); task.wait(0.25)
        if not subtitle.Parent then break end
        subtitle.Text=txts[i]; tw(subtitle,0.2,{TextTransparency=0})
    end
end)

--==================== Pantalla pregunta ====================
local question = create("Frame",{Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.new(0,0,0),BackgroundTransparency=1,BorderSizePixel=0,Visible=false,ZIndex=90},gui)
local qBox = create("Frame",{Size=UDim2.fromScale(0,0),Position=UDim2.fromScale(.5,.5),AnchorPoint=Vector2.new(.5,.5),BackgroundColor3=Color3.fromRGB(13,17,26),BorderSizePixel=0,ZIndex=91},question)
corner(UDim.new(0,26),qBox); stroke(S.AccentColor,2,qBox)
create("TextLabel",{Size=UDim2.fromScale(.88,.45),Position=UDim2.fromScale(.5,.32),AnchorPoint=Vector2.new(.5,.5),BackgroundTransparency=1,Text=Mensajes.Pregunta,TextColor3=Color3.fromRGB(225,235,250),Font=Enum.Font.GothamMedium,TextSize=20,TextWrapped=true,ZIndex=92},qBox)

local function mkAnsBtn(txt,color,pos)
    local b=create("TextButton",{Size=UDim2.fromScale(.34,.2),Position=UDim2.fromScale(pos,.78),AnchorPoint=Vector2.new(.5,.5),BackgroundColor3=color,BorderSizePixel=0,Text=txt,TextColor3=Color3.new(1,1,1),Font=Enum.Font.GothamBold,TextSize=18,AutoButtonColor=false,ZIndex=92},qBox)
    corner(UDim.new(0,14),b); addRipple(b)
    b.MouseEnter:Connect(function() tw(b,0.15,{Size=UDim2.fromScale(.36,.22)}); tw(b,0.15,{BackgroundColor3=color:Lerp(Color3.new(1,1,1),0.2)}) end)
    b.MouseLeave:Connect(function() tw(b,0.15,{Size=UDim2.fromScale(.34,.2)}); tw(b,0.15,{BackgroundColor3=color}) end)
    return b
end
local yesBtn = mkAnsBtn("Sí", Color3.fromRGB(0,170,100), .28)
local noBtn  = mkAnsBtn("No", Color3.fromRGB(180,45,65), .72)

local function showSplash(text)
    local splash=create("Frame",{Size=UDim2.new(.42,0,0,72),Position=UDim2.new(.5,0,1,40),AnchorPoint=Vector2.new(.5,1),BackgroundColor3=Color3.fromRGB(18,22,34),BorderSizePixel=0,ZIndex=200},gui)
    corner(UDim.new(0,22),splash); stroke(S.AccentColor,1.5,splash)
    gradient(splash, Color3.fromRGB(22,28,42), Color3.fromRGB(12,16,24), 90)
    create("TextLabel",{Size=UDim2.fromScale(.92,1),Position=UDim2.fromScale(.5,.5),AnchorPoint=Vector2.new(.5,.5),BackgroundTransparency=1,Text=text,TextColor3=Color3.fromRGB(230,240,255),Font=Enum.Font.GothamMedium,TextSize=16,TextWrapped=true,ZIndex=201},splash)
    tw(splash,0.65,{Position=UDim2.new(.5,0,1,-130)},Enum.EasingStyle.Back)
    task.wait(3.2)
    tw(splash,0.5,{Position=UDim2.new(.5,0,1,40)},Enum.EasingStyle.Quad,Enum.EasingDirection.In)
    task.wait(0.55); splash:Destroy()
end

--==================== Variables UI ====================
local fovGui,fovCircle,targetNameLbl,reopenBtn,toggleBtn
local crosshairGui,statsGui,fpsLbl,pingLbl
local editorOverlay,editorScroll,editorTitle
local tabContent, tabUnderline, searchBox
local activeTab = "AIM"
local searchQuery = ""

local BASE_W, BASE_H = 620, 540

UI.setMovable = function(enabled)
    UI.uiOpen = enabled
    uiOpen = enabled
end

local function refreshCircleVisibility()
    if fovGui then fovGui.Enabled = S.ShowCircle; if fovCircle then fovCircle.Visible = S.ShowCircle end end
end

local function applyCameraForce()
    if S.ForceCamera=="FirstPerson" then LP.CameraMode=Enum.CameraMode.LockFirstPerson
    elseif S.ForceCamera=="ThirdPerson" then LP.CameraMode=Enum.CameraMode.Classic; LP.CameraMaxZoomDistance=12.5; LP.CameraMinZoomDistance=12.5
    else LP.CameraMode=Enum.CameraMode.Classic; LP.CameraMinZoomDistance=0.5; LP.CameraMaxZoomDistance=400 end
end
local function applyCameraMode()
    if S.CameraMode=="Follow" then Cam.CameraType=Enum.CameraType.Follow
    elseif S.CameraMode=="Orbital" then Cam.CameraType=Enum.CameraType.Orbital
    else Cam.CameraType=Enum.CameraType.Custom end
end

local function refreshCrosshair()
    if not crosshairGui then return end
    crosshairGui:ClearAllChildren()
    ensureUIScale(crosshairGui)
    if not S.ShowCrosshair then return end
    local col = S.CrosshairColor
    local size, thick, gap = S.CrosshairSize, S.CrosshairThick, S.CrosshairGap
    local baseX = S.CrosshairOffset.x
    local baseY = S.CrosshairOffset.y
    local parent = crosshairGui
    local function pxFrame(w,h,xo,yo,rot)
        local f = create("Frame",{Size=UDim2.fromOffset(w,h),Position=UDim2.new(.5,baseX+(xo or 0),.5,baseY+(yo or 0)),AnchorPoint=Vector2.new(.5,.5),BackgroundColor3=col,BorderSizePixel=0,Rotation=rot or 0,ZIndex=5},parent)
        if S.CrosshairGlow then create("UIStroke",{Color=col,Thickness=3,Transparency=0.75,ApplyStrokeMode=Enum.ApplyStrokeMode.Border},f) end
        return f
    end
    if S.CrosshairStyle=="Dot" then
        local d=pxFrame(size,size,0,0); corner(UDim.new(1,0),d)
    elseif S.CrosshairStyle=="Cross" then
        pxFrame(size*2,thick,0,0); pxFrame(thick,size*2,0,0)
    elseif S.CrosshairStyle=="CrossGap" then
        local half=size/2
        pxFrame(size,thick,(gap+half),0); pxFrame(size,thick,-(gap+half),0)
        pxFrame(thick,size,0,(gap+half)); pxFrame(thick,size,0,-(gap+half))
    elseif S.CrosshairStyle=="Circle" then
        local c=create("Frame",{Size=UDim2.fromOffset(size*2,size*2),Position=UDim2.new(.5,baseX,.5,baseY),AnchorPoint=Vector2.new(.5,.5),BackgroundTransparency=1,BorderSizePixel=0,ZIndex=5},parent)
        corner(UDim.new(1,0),c); stroke(col,thick,c)
    elseif S.CrosshairStyle=="X" then
        pxFrame(size*2,thick,0,0,45); pxFrame(size*2,thick,0,0,-45)
    elseif S.CrosshairStyle=="CrossCircle" then
        local half=size/2
        pxFrame(size,thick,(gap+half),0); pxFrame(size,thick,-(gap+half),0)
        pxFrame(thick,size,0,(gap+half)); pxFrame(thick,size,0,-(gap+half))
        local c=create("Frame",{Size=UDim2.fromOffset(size*2.5,size*2.5),Position=UDim2.new(.5,baseX,.5,baseY),AnchorPoint=Vector2.new(.5,.5),BackgroundTransparency=1,BorderSizePixel=0,ZIndex=5},parent)
        corner(UDim.new(1,0),c); stroke(col,thick*0.6,c)
    elseif S.CrosshairStyle=="TShape" then
        pxFrame(size*2,thick,0,0); pxFrame(thick,size,0,size/2+thick/2)
    end
end

local function refreshStats()
    if fpsLbl then
        fpsLbl.Visible=S.ShowFPS
        fpsLbl.Font=FONTS[S.FPS.fontIndex].f
        fpsLbl.TextSize=S.FPS.fontSize * S.FontScale
        fpsLbl.BackgroundColor3=S.FPS.bgColor
        fpsLbl.BackgroundTransparency=S.FPS.bgTransp
        fpsLbl.TextColor3=S.FPS.textColor
        fpsLbl.Position=S.FPS.pos
        local st=fpsLbl:FindFirstChildOfClass("UIStroke"); if st then st.Color=S.FPS.textColor end
    end
    if pingLbl then
        pingLbl.Visible=S.ShowPing
        pingLbl.Font=FONTS[S.PING.fontIndex].f
        pingLbl.TextSize=S.PING.fontSize * S.FontScale
        pingLbl.BackgroundColor3=S.PING.bgColor
        pingLbl.BackgroundTransparency=S.PING.bgTransp
        pingLbl.TextColor3=S.PING.textColor
        pingLbl.Position=S.PING.pos
        local st=pingLbl:FindFirstChildOfClass("UIStroke"); if st then st.Color=S.PING.textColor end
    end
end

-- Reusables
local function addSlider(parent,name,minV,maxV,defaultV,format,onChanged,order)
    if S.EasyMode and ADVANCED_ITEMS[name] then return nil end
    local c = create("Frame",{Size=UDim2.new(1,-8,0,52),BackgroundTransparency=1,LayoutOrder=order,ZIndex=62},parent)
    create("TextLabel",{Size=UDim2.new(.7,0,0,18),BackgroundTransparency=1,Text=name,TextColor3=Color3.fromRGB(200,215,235),Font=Enum.Font.Gotham,TextSize=13 * S.FontScale,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=62},c)
    local valLbl=create("TextLabel",{Size=UDim2.new(.3,0,0,18),Position=UDim2.new(.7,0,0,0),BackgroundTransparency=1,Text=format(defaultV),TextColor3=S.AccentColor,Font=Enum.Font.GothamBold,TextSize=13 * S.FontScale,TextXAlignment=Enum.TextXAlignment.Right,ZIndex=62},c)
    local track=create("Frame",{Size=UDim2.new(1,0,0,10),Position=UDim2.new(0,0,0,30),BackgroundColor3=Color3.fromRGB(22,28,42),BorderSizePixel=0,ZIndex=62},c)
    corner(UDim.new(1,0),track)
    local fill=create("Frame",{Size=UDim2.fromScale((defaultV-minV)/(maxV-minV),1),BackgroundColor3=S.AccentColor,BorderSizePixel=0,ZIndex=63},track)
    corner(UDim.new(1,0),fill); gradient(fill,S.AccentColor,S.AccentColor:Lerp(Color3.new(1,1,1),0.3),0)
    local knobSize=IS_MOBILE and 22 or (S.BigTouchTargets and 22 or 18)
    local knob=create("Frame",{Size=UDim2.fromOffset(knobSize,knobSize),Position=UDim2.new((defaultV-minV)/(maxV-minV),0,.5,0),AnchorPoint=Vector2.new(.5,.5),BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0,ZIndex=64},track)
    corner(UDim.new(1,0),knob); stroke(S.AccentColor,2,knob)
    local dragging=false; local active,isMouse=nil,false
    local function setFromX(x)
        local rel=math.clamp((x-track.AbsolutePosition.X)/math.max(track.AbsoluteSize.X,1),0,1)
        fill.Size=UDim2.fromScale(rel,1); knob.Position=UDim2.new(rel,0,.5,0)
        valLbl.Text=format(minV+rel*(maxV-minV))
        if onChanged then onChanged(minV+rel*(maxV-minV)) end
    end
    track.InputBegan:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true; isMouse=true; active=input; setFromX(input.Position.X)
        elseif input.UserInputType==Enum.UserInputType.Touch then dragging=true; isMouse=false; active=input; setFromX(input.Position.X) end
    end)
    UIS.InputChanged:Connect(function(input)
        if not dragging then return end
        if isMouse and input.UserInputType==Enum.UserInputType.MouseMovement then setFromX(input.Position.X)
        elseif not isMouse and input==active then setFromX(input.Position.X) end
    end)
    UIS.InputEnded:Connect(function(input)
        if not dragging then return end
        if isMouse and input.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false
        elseif not isMouse and input==active then dragging=false; active=nil end
    end)
    return c
end

local function addColorRow(parent,name,colors,currentColor,onPick,order)
    if S.EasyMode and ADVANCED_ITEMS[name] then return nil end
    local row=create("Frame",{Size=UDim2.new(1,-8,0,32),BackgroundTransparency=1,LayoutOrder=order,ZIndex=62},parent)
    create("TextLabel",{Size=UDim2.new(.4,0,1,0),BackgroundTransparency=1,Text=name,TextColor3=Color3.fromRGB(200,215,235),Font=Enum.Font.Gotham,TextSize=13 * S.FontScale,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=62},row)
    for i,col in ipairs(colors) do
        local cb=create("TextButton",{Size=UDim2.fromOffset(22,22),Position=UDim2.new(1,-(#colors-i+1)*28+14,.5,0),AnchorPoint=Vector2.new(1,.5),BackgroundColor3=col,BorderSizePixel=0,Text="",AutoButtonColor=false,ZIndex=63},row)
        corner(UDim.new(1,0),cb); stroke(Color3.fromRGB(60,70,90),1,cb); addRipple(cb)
        cb.MouseButton1Click:Connect(function() if onPick then onPick(col) end end)
    end
    return row
end

local function addToggle(parent,name,defaultVal,onChanged,order)
    if S.EasyMode and ADVANCED_ITEMS[name] then return nil end
    local c=create("Frame",{Size=UDim2.new(1,-8,0,34),BackgroundTransparency=1,LayoutOrder=order,ZIndex=62},parent)
    create("TextLabel",{Size=UDim2.new(.65,0,1,0),BackgroundTransparency=1,Text=name,TextColor3=Color3.fromRGB(200,215,235),Font=Enum.Font.Gotham,TextSize=13 * S.FontScale,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=62},c)
    local btn=create("TextButton",{Size=UDim2.fromOffset(58,26),Position=UDim2.new(1,0,.5,0),AnchorPoint=Vector2.new(1,.5),BackgroundColor3=defaultVal and Color3.fromRGB(0,170,100) or Color3.fromRGB(60,40,50),BorderSizePixel=0,Text=defaultVal and "ON" or "OFF",TextColor3=Color3.new(1,1,1),Font=Enum.Font.GothamBold,TextSize=12,AutoButtonColor=false,ZIndex=63},c)
    corner(UDim.new(1,0),btn); addRipple(btn)
    local state=defaultVal
    btn.MouseButton1Click:Connect(function()
        state=not state; btn.Text=state and "ON" or "OFF"
        tw(btn,0.2,{BackgroundColor3=state and Color3.fromRGB(0,170,100) or Color3.fromRGB(60,40,50)})
        if onChanged then onChanged(state) end
    end)
    return c
end

local function addFontCycler(parent,name,stateKey,onUpdate,order)
    if S.EasyMode and ADVANCED_ITEMS[name] then return nil end
    local c=create("Frame",{Size=UDim2.new(1,-8,0,50),BackgroundTransparency=1,LayoutOrder=order,ZIndex=62},parent)
    create("TextLabel",{Size=UDim2.new(.55,0,0,18),BackgroundTransparency=1,Text=name,TextColor3=Color3.fromRGB(200,215,235),Font=Enum.Font.Gotham,TextSize=13 * S.FontScale,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=62},c)
    local btn=create("TextButton",{Size=UDim2.new(1,0,0,26),Position=UDim2.new(0,0,0,22),BackgroundColor3=Color3.fromRGB(22,28,42),BorderSizePixel=0,Text=FONTS[S[stateKey].fontIndex].n,TextColor3=Color3.fromRGB(200,215,235),Font=FONTS[S[stateKey].fontIndex].f,TextSize=13 * S.FontScale,AutoButtonColor=false,ZIndex=63},c)
    corner(UDim.new(0,8),btn); stroke(Color3.fromRGB(40,50,70),1,btn); addRipple(btn)
    btn.MouseButton1Click:Connect(function()
        local idx=S[stateKey].fontIndex%#FONTS+1; S[stateKey].fontIndex=idx
        btn.Text=FONTS[idx].n; btn.Font=FONTS[idx].f
        if onUpdate then onUpdate() end
    end)
    return c
end

local function addInfoLabel(parent,text,order)
    return create("TextLabel",{Size=UDim2.new(1,-8,0,20),BackgroundTransparency=1,Text=text,TextColor3=Color3.fromRGB(130,145,170),Font=Enum.Font.Gotham,TextSize=12 * S.FontScale,TextXAlignment=Enum.TextXAlignment.Left,LayoutOrder=order,ZIndex=62},parent)
end

local function addSeparator(parent,order)
    return create("Frame",{Size=UDim2.new(1,-8,0,1),BackgroundColor3=S.AccentColor,BackgroundTransparency=0.5,BorderSizePixel=0,LayoutOrder=order,ZIndex=62},parent)
end

local function addSectionTitle(parent,text,order)
    return create("TextLabel",{Size=UDim2.new(1,-8,0,26),BackgroundTransparency=1,Text=text,TextColor3=S.AccentColor,Font=Enum.Font.GothamBold,TextSize=14 * S.FontScale,TextXAlignment=Enum.TextXAlignment.Left,LayoutOrder=order,ZIndex=62},parent)
end

local function addSelector(parent,name,options,currentValue,onSelect,order)
    if S.EasyMode and ADVANCED_ITEMS[name] then return nil end
    local container=create("Frame",{Size=UDim2.new(1,-8,0,26+#options*30),BackgroundTransparency=1,LayoutOrder=order,ZIndex=62},parent)
    create("TextLabel",{Size=UDim2.new(1,0,0,20),BackgroundTransparency=1,Text=name,TextColor3=Color3.fromRGB(200,215,235),Font=Enum.Font.Gotham,TextSize=13 * S.FontScale,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=62},container)
    local list=create("Frame",{Size=UDim2.new(1,0,0,#options*30),Position=UDim2.new(0,0,0,24),BackgroundTransparency=1,ZIndex=62},container)
    create("UIListLayout",{Padding=UDim.new(0,4)},list)
    local buttons={}
    local function refresh(cur)
        for val,b in pairs(buttons) do
            local bst=b:FindFirstChildOfClass("UIStroke")
            if val==cur then
                tw(b,0.2,{BackgroundColor3=S.AccentColor,TextColor3=Color3.new(1,1,1)})
                if bst then tw(bst,0.2,{Color=S.AccentColor}) end
            else
                tw(b,0.2,{BackgroundColor3=Color3.fromRGB(22,28,42),TextColor3=Color3.fromRGB(190,205,225)})
                if bst then tw(bst,0.2,{Color=Color3.fromRGB(40,50,70)}) end
            end
        end
    end
    for _,opt in ipairs(options) do
        local b=create("TextButton",{Size=UDim2.new(1,0,0,26),BackgroundColor3=Color3.fromRGB(22,28,42),BorderSizePixel=0,Text=opt.label,TextColor3=Color3.fromRGB(190,205,225),Font=Enum.Font.Gotham,TextSize=13 * S.FontScale,AutoButtonColor=false,ZIndex=63},list)
        corner(UDim.new(0,8),b); stroke(Color3.fromRGB(40,50,70),1,b); addRipple(b)
        b.MouseEnter:Connect(function() if currentValue~=opt.value then tw(b,0.15,{BackgroundColor3=Color3.fromRGB(30,38,56)}) end end)
        b.MouseLeave:Connect(function() if currentValue~=opt.value then tw(b,0.15,{BackgroundColor3=Color3.fromRGB(22,28,42)}) end end)
        b.MouseButton1Click:Connect(function() currentValue=opt.value; if onSelect then onSelect(opt.value) end; refresh(currentValue) end)
        buttons[opt.value]=b
    end
    refresh(currentValue)
    return container
end

local function openEditor(titleText, buildFn)
    if not editorOverlay then return end
    editorTitle.Text = "◀  "..titleText
    for _,c in ipairs(editorScroll:GetChildren()) do if not c:IsA("UIListLayout") then c:Destroy() end end
    buildFn(editorScroll)
    editorOverlay.Visible = true
    if tabContent then tabContent.Visible = false end
end
local function closeEditor()
    if editorOverlay then editorOverlay.Visible = false end
    if tabContent then tabContent.Visible = true end
end

--==================== Interfaz Principal ====================
local function buildMainUI()
    local s = responsiveScale()
    local W, H = math.floor(BASE_W*s), math.floor(BASE_H*s)
    local vp = Cam.ViewportSize

    local main = create("Frame",{Name="MainUI",Size=UDim2.fromOffset(W,H),Position=UDim2.fromOffset((vp.X-W)/2,(vp.Y-H)/2),AnchorPoint=Vector2.new(0,0),BackgroundColor3=S.PanelBg,BackgroundTransparency=S.PanelTransparency,BorderSizePixel=0,Visible=false,ClipsDescendants=true,ZIndex=50},gui)
    main:SetAttribute("BaseX",W); main:SetAttribute("BaseY",H)
    corner(UDim.new(0,S.CornerRadius),main); stroke(S.AccentColor,S.BorderThickness,main)
    gradient(main,S.PanelBg,S.PanelBg:Lerp(Color3.new(0,0,0),0.3),S.GradientAngle)
    UI.main = main; UI.mainFrame = main
    ensureUIScale(main)

    local header = create("Frame",{Size=UDim2.new(1,0,0,50),BackgroundColor3=Color3.fromRGB(16,20,32),BorderSizePixel=0,ZIndex=51},main)
    gradient(header,Color3.fromRGB(16,20,32),Color3.fromRGB(22,30,48),90)
    create("Frame",{Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,0),BackgroundColor3=S.AccentColor,BackgroundTransparency=0.5,BorderSizePixel=0,ZIndex=52},header)
    create("Frame",{Size=UDim2.fromOffset(10,10),Position=UDim2.new(0,18,.5,0),AnchorPoint=Vector2.new(0,.5),BackgroundColor3=S.AccentColor,BorderSizePixel=0,ZIndex=53},header)
    create("TextLabel",{Size=UDim2.new(0,110,1,0),Position=UDim2.new(0,34,0,0),BackgroundTransparency=1,Text="XAttA",TextColor3=S.AccentColor,Font=Enum.Font.GothamBlack,TextSize=22,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=53},header)
    create("TextLabel",{Size=UDim2.new(0,140,1,0),Position=UDim2.new(0,106,0,0),BackgroundTransparency=1,Text="U L T R A  v3.3",TextColor3=Color3.fromRGB(90,110,140),Font=Enum.Font.GothamBold,TextSize=9,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=53},header)

    local function winBtn(order,symbol,hover,cb)
        local b=create("TextButton",{Size=UDim2.fromOffset(38,38),Position=UDim2.new(1,-16-order*44,.5,0),AnchorPoint=Vector2.new(1,.5),BackgroundColor3=Color3.fromRGB(24,30,44),BorderSizePixel=0,Text=symbol,TextColor3=Color3.fromRGB(190,200,220),Font=Enum.Font.GothamBold,TextSize=15,AutoButtonColor=false,ZIndex=53},header)
        corner(UDim.new(1,0),b); addRipple(b)
        b.MouseEnter:Connect(function() tw(b,0.15,{BackgroundColor3=hover,TextColor3=Color3.new(1,1,1)}) end)
        b.MouseLeave:Connect(function() tw(b,0.15,{BackgroundColor3=Color3.fromRGB(24,30,44),TextColor3=Color3.fromRGB(190,200,220)}) end)
        b.MouseButton1Click:Connect(cb)
        return b
    end

    local tabsBar = create("Frame",{Size=UDim2.new(1,0,0,40),Position=UDim2.new(0,0,0,50),BackgroundColor3=Color3.fromRGB(12,16,24),BorderSizePixel=0,ZIndex=51},main)
    local tabsList = create("Frame",{Size=UDim2.new(1,-100,1,0),BackgroundTransparency=1,ZIndex=52},tabsBar)
    create("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,Padding=UDim.new(0,4),VerticalAlignment=Enum.VerticalAlignment.Center},tabsList)
    create("UIPadding",{PaddingLeft=UDim.new(0,16)},tabsList)

    local searchFrame = create("Frame",{Size=UDim2.fromOffset(180,26),Position=UDim2.new(1,-190,.5,0),AnchorPoint=Vector2.new(0,.5),BackgroundColor3=Color3.fromRGB(20,26,40),BorderSizePixel=0,ZIndex=52},tabsBar)
    corner(UDim.new(0,8),searchFrame)
    create("TextLabel",{Size=UDim2.fromOffset(24,26),BackgroundTransparency=1,Text="🔍",TextColor3=Color3.fromRGB(120,140,170),Font=Enum.Font.Gotham,TextSize=12,ZIndex=53},searchFrame)
    searchBox = create("TextBox",{Size=UDim2.new(1,-28,1,0),Position=UDim2.new(0,26,0,0),BackgroundTransparency=1,Text="",PlaceholderText="Buscar...",PlaceholderColor3=Color3.fromRGB(100,115,140),TextColor3=Color3.fromRGB(220,235,250),Font=Enum.Font.Gotham,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=53},searchFrame)
    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        searchQuery = string.lower(searchBox.Text)
        if UI.rebuildTab then UI.rebuildTab() end
    end)

    tabContent = create("ScrollingFrame",{Size=UDim2.new(1,-26,1,-196),Position=UDim2.new(0,13,0,98),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=5,ScrollBarImageColor3=S.AccentColor,CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollingDirection=Enum.ScrollingDirection.Y,ZIndex=51},main)
    create("UIListLayout",{Padding=UDim.new(0,10),SortOrder=Enum.SortOrder.LayoutOrder},tabContent)

    local footer = create("Frame",{Size=UDim2.new(1,0,0,56),Position=UDim2.new(0,0,1,-56),BackgroundColor3=Color3.fromRGB(16,20,32),BorderSizePixel=0,ZIndex=51},main)
    create("Frame",{Size=UDim2.new(1,0,0,1),BackgroundColor3=S.AccentColor,BackgroundTransparency=0.5,BorderSizePixel=0,ZIndex=52},footer)
    create("TextLabel",{Size=UDim2.new(.5,0,0,16),Position=UDim2.new(0,14,0,6),BackgroundTransparency=1,Text="Hecho con AntiGravity IA e In0B4T_SD (Ksjzns84)",TextColor3=Color3.fromRGB(85,105,135),Font=Enum.Font.Gotham,TextSize=10,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=52},footer)
    local phraseLbl = create("TextLabel",{Size=UDim2.new(.5,0,0,16),Position=UDim2.new(0,14,0,28),BackgroundTransparency=1,Text=FrasesReflexion[math.random(1,#FrasesReflexion)],TextColor3=S.AccentColor,Font=Enum.Font.Gotham,TextSize=10,TextXAlignment=Enum.TextXAlignment.Left,TextTransparency=0.15,ZIndex=52},footer)
    task.spawn(function()
        while phraseLbl.Parent do
            task.wait(6)
            if not phraseLbl.Parent then break end
            tw(phraseLbl,0.4,{TextTransparency=1}); task.wait(0.5)
            if not phraseLbl.Parent then break end
            phraseLbl.Text=FrasesReflexion[math.random(1,#FrasesReflexion)]
            tw(phraseLbl,0.4,{TextTransparency=0.15})
        end
    end)

    local tabsDef = {
        {id="AIM",label="🎯 Aim"},{id="CAM",label="🎥 Cámara"},
        {id="VIS",label="🎨 Visual"},{id="STATS",label="📊 Stats"},
        {id="CONFIG",label="⚙ Config"},{id="INFO",label="ℹ Info"},
    }
    local tabButtons = {}
    local function switchTab(id)
        activeTab = id
        for tid,tb in pairs(tabButtons) do
            if tid==id then tw(tb,0.2,{TextColor3=S.AccentColor})
            else tw(tb,0.2,{TextColor3=Color3.fromRGB(140,160,190)}) end
        end
        if UI.rebuildTab then UI.rebuildTab() end
    end

    for _,tab in ipairs(tabsDef) do
        local label = S.ShowTabIcons and tab.label or tab.label:gsub("[^%w ]", "")
        local b=create("TextButton",{Size=UDim2.fromOffset(0,40),AutomaticSize=Enum.AutomaticSize.X,BackgroundTransparency=1,Text=label,TextColor3=Color3.fromRGB(140,160,190),Font=Enum.Font.GothamMedium,TextSize=12,AutoButtonColor=false,ZIndex=53},tabsList)
        create("UIPadding",{PaddingLeft=UDim.new(0,8),PaddingRight=UDim.new(0,8)},b)
        addRipple(b)
        b.MouseButton1Click:Connect(function() switchTab(tab.id) end)
        b.MouseEnter:Connect(function() if activeTab~=tab.id then tw(b,0.15,{TextColor3=Color3.fromRGB(200,220,240)}) end end)
        b.MouseLeave:Connect(function() if activeTab~=tab.id then tw(b,0.15,{TextColor3=Color3.fromRGB(140,160,190)}) end end)
        tabButtons[tab.id]=b
    end

    editorOverlay = create("Frame",{Size=tabContent.Size,Position=tabContent.Position,BackgroundColor3=Color3.fromRGB(11,14,22),BorderSizePixel=0,Visible=false,ZIndex=60},main)
    corner(UDim.new(0,12),editorOverlay); stroke(S.AccentColor,1.2,editorOverlay)
    local editorTop = create("Frame",{Size=UDim2.new(1,0,0,34),BackgroundColor3=Color3.fromRGB(18,22,34),BorderSizePixel=0,ZIndex=61},editorOverlay)
    corner(UDim.new(0,12),editorTop)
    editorTitle = create("TextButton",{Size=UDim2.new(1,-20,1,0),Position=UDim2.new(0,10,0,0),BackgroundTransparency=1,Text="Editor",TextColor3=S.AccentColor,Font=Enum.Font.GothamBold,TextSize=14,TextXAlignment=Enum.TextXAlignment.Left,AutoButtonColor=false,ZIndex=62},editorTop)
    editorTitle.MouseButton1Click:Connect(closeEditor)
    editorScroll = create("ScrollingFrame",{Size=UDim2.new(1,-8,1,-44),Position=UDim2.new(0,4,0,40),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=4,ScrollBarImageColor3=S.AccentColor,CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollingDirection=Enum.ScrollingDirection.Y,ZIndex=62},editorOverlay)
    create("UIListLayout",{Padding=UDim.new(0,8),SortOrder=Enum.SortOrder.LayoutOrder},editorScroll)

    UI.rebuildTab = function()
        for _,c in ipairs(tabContent:GetChildren()) do if not c:IsA("UIListLayout") then c:Destroy() end end
        local order=0
        local function nextOrder() order=order+1; return order end
        local function match(text) return searchQuery=="" or string.find(string.lower(text), searchQuery, 1, true) end

        if activeTab=="AIM" then
            if match("suavidad") then addSlider(tabContent,"Suavidad (0 = Instantáneo)",0,100,S.Smoothness,function(v) return string.format("%d",math.floor(v)) end,function(v) S.Smoothness=v end,nextOrder()) end
            if match("predicción") then addSlider(tabContent,"Predicción de Movimiento",0,500,S.Prediction*1000,function(v) return string.format("%d ms",math.floor(v)) end,function(v) S.Prediction=v/1000 end,nextOrder()) end
            if match("radio") then addSlider(tabContent,"Radio de Detección",50,900,S.FovRadius,function(v) return string.format("%d px",math.floor(v)) end,function(v) S.FovRadius=v; if fovCircle then fovCircle.Size=UDim2.fromOffset(v*2,v*2) end end,nextOrder()) end
            if match("sticky") then addToggle(tabContent,"Sticky Aim (no cambiar objetivo)",S.StickyAim,function(v) S.StickyAim=v end,nextOrder()) end
            if match("team") then addToggle(tabContent,"Ignorar Compañeros (Team Check)",S.TeamCheck,function(v) S.TeamCheck=v end,nextOrder()) end
            if match("bone") then addSelector(tabContent,"Bone a Apuntar",{{label="Cabeza",value="Head"},{label="Torso Superior",value="UpperTorso"},{label="Torso",value="Torso"},{label="Más Cercano",value="Nearest"},{label="Aleatorio",value="Random"}},S.AimBone,function(v) S.AimBone=v end,nextOrder()) end
            if match("priority") then addSelector(tabContent,"Prioridad de Objetivo",{{label="Más cercano al Crosshair",value="Crosshair"},{label="Más cercano a ti",value="Distance"},{label="Menos vida",value="Health"},{label="Más amenaza",value="Threat"}},S.Priority,function(v) S.Priority=v end,nextOrder()) end
            if match("smooth") then addSelector(tabContent,"Tipo de Suavizado",{{label="Linear",value="Linear"},{label="Smoothstep (Recomendado)",value="Smoothstep"},{label="Bezier (Curva suave)",value="Bezier"}},S.SmoothType,function(v) S.SmoothType=v end,nextOrder()) end
            if match("wallcheck") or match("pared") then addToggle(tabContent,"Wallcheck (Bloquear A Través de Paredes)",not S.IgnoreWalls,function(v) S.IgnoreWalls=not v end,nextOrder()) end
            if match("debug") then addToggle(tabContent,"Debug Wallcheck",S.DebugWall,function(v) S.DebugWall=v end,nextOrder()) end
            if match("círculo") or match("circulo") then addToggle(tabContent,"Mostrar Círculo FOV",S.ShowCircle,function(v) S.ShowCircle=v; refreshCircleVisibility() end,nextOrder()) end
            if match("nombre") then addToggle(tabContent,"Mostrar Nombre del Objetivo",S.ShowName,function(v) S.ShowName=v; if targetNameLbl and not v then targetNameLbl.Visible=false end end,nextOrder()) end

            local editBtn1 = create("TextButton",{Size=UDim2.new(1,-8,0,28),BackgroundColor3=Color3.fromRGB(22,28,42),BorderSizePixel=0,Text="✎ Editar Círculo FOV",TextColor3=S.AccentColor,Font=Enum.Font.GothamBold,TextSize=12,AutoButtonColor=false,LayoutOrder=nextOrder(),ZIndex=63},tabContent)
            corner(UDim.new(0,8),editBtn1); addRipple(editBtn1)
            editBtn1.MouseButton1Click:Connect(function()
                openEditor("Editar Círculo FOV",function(scroll)
                    addInfoLabel(scroll,"Personaliza el círculo del Aim Assist",1); addSeparator(scroll,2)
                    addColorRow(scroll,"Color",{Color3.fromRGB(0,200,255),Color3.fromRGB(0,255,130),Color3.fromRGB(255,80,80),Color3.fromRGB(255,200,0),Color3.fromRGB(200,80,255),Color3.fromRGB(255,255,255)},S.CircleColor,function(col) S.CircleColor=col; if fovCircle then local st=fovCircle:FindFirstChildOfClass("UIStroke"); if st then st.Color=col end end end,3)
                    addSlider(scroll,"Grosor",0.5,6,S.CircleThickness,function(v) return string.format("%.1f",v) end,function(v) S.CircleThickness=v; if fovCircle then local st=fovCircle:FindFirstChildOfClass("UIStroke"); if st then st.Thickness=v end end end,4)
                    addToggle(scroll,"Pulso Animado",S.CirclePulse,function(v) S.CirclePulse=v end,5)
                    addSlider(scroll,"Offset X",-500,500,S.CircleOffset.x,function(v) return string.format("%d",math.floor(v)) end,function(v) S.CircleOffset.x=v; if fovCircle then fovCircle.Position=UDim2.new(.5,v,.5,S.CircleOffset.y) end end,6)
                    addSlider(scroll,"Offset Y",-500,500,S.CircleOffset.y,function(v) return string.format("%d",math.floor(v)) end,function(v) S.CircleOffset.y=v; if fovCircle then fovCircle.Position=UDim2.new(.5,S.CircleOffset.x,.5,v) end end,7)
                end)
            end)
            local editBtn2 = create("TextButton",{Size=UDim2.new(1,-8,0,28),BackgroundColor3=Color3.fromRGB(22,28,42),BorderSizePixel=0,Text="✎ Editar Nombre del Objetivo",TextColor3=S.AccentColor,Font=Enum.Font.GothamBold,TextSize=12,AutoButtonColor=false,LayoutOrder=nextOrder(),ZIndex=63},tabContent)
            corner(UDim.new(0,8),editBtn2); addRipple(editBtn2)
            editBtn2.MouseButton1Click:Connect(function()
                openEditor("Editar Nombre del Objetivo",function(scroll)
                    addInfoLabel(scroll,"Estilo de la etiqueta del nombre",1); addSeparator(scroll,2)
                    addColorRow(scroll,"Color de Fondo",{Color3.fromRGB(10,15,25),Color3.fromRGB(25,10,10),Color3.fromRGB(10,25,15),Color3.fromRGB(25,25,10),Color3.fromRGB(255,255,255)},S.NAME.bgColor,function(col) S.NAME.bgColor=col; if targetNameLbl then targetNameLbl.BackgroundColor3=col end end,3)
                    addColorRow(scroll,"Color de Letra",{Color3.fromRGB(0,200,255),Color3.fromRGB(0,255,130),Color3.fromRGB(255,80,80),Color3.fromRGB(255,255,255)},S.CircleColor,function(col) S.CircleColor=col end,4)
                    addSlider(scroll,"Tamaño",10,30,S.NAME.fontSize,function(v) return string.format("%d",math.floor(v)) end,function(v) S.NAME.fontSize=v; if targetNameLbl then targetNameLbl.TextSize=v end end,5)
                end)
            end)

        elseif activeTab=="CAM" then
            if match("fov") then addSlider(tabContent,"FOV de Cámara",50,120,S.CameraFov,function(v) return string.format("%d°",math.floor(v)) end,function(v) S.CameraFov=v; Cam.FieldOfView=v end,nextOrder()) end
            if match("forzar") then addSelector(tabContent,"Forzar Cámara",{{label="Default",value="Default"},{label="1ra Persona",value="FirstPerson"},{label="3ra Persona",value="ThirdPerson"}},S.ForceCamera,function(v) S.ForceCamera=v; applyCameraForce() end,nextOrder()) end
            if match("modo") then addSelector(tabContent,"Modo de Cámara",{{label="Default (Custom)",value="Default"},{label="Seguir (Follow)",value="Follow"},{label="Orbitando (Orbital)",value="Orbital"}},S.CameraMode,function(v) S.CameraMode=v; applyCameraMode() end,nextOrder()) end

        elseif activeTab=="VIS" then
            -- ============ CROSSHAIR ============
            addSectionTitle(tabContent,"🎯 Crosshair",nextOrder())
            if match("crosshair") then addToggle(tabContent,"Mostrar Crosshair",S.ShowCrosshair,function(v) S.ShowCrosshair=v; refreshCrosshair() end,nextOrder()) end
            if match("crosshair") or match("mira") then
                local editBtn3 = create("TextButton",{Size=UDim2.new(1,-8,0,28),BackgroundColor3=Color3.fromRGB(22,28,42),BorderSizePixel=0,Text="✎ Editar Crosshair",TextColor3=S.AccentColor,Font=Enum.Font.GothamBold,TextSize=12,AutoButtonColor=false,LayoutOrder=nextOrder(),ZIndex=63},tabContent)
                corner(UDim.new(0,8),editBtn3); addRipple(editBtn3)
                editBtn3.MouseButton1Click:Connect(function()
                    openEditor("Editar Crosshair",function(scroll)
                        addInfoLabel(scroll,"Personaliza tu mira central",1); addSeparator(scroll,2)
                        addSelector(scroll,"Estilo",{{label="Cruz (+)",value="Cross"},{label="Cruz con Gap",value="CrossGap"},{label="Punto (•)",value="Dot"},{label="Círculo (○)",value="Circle"},{label="X",value="X"},{label="Cruz + Círculo",value="CrossCircle"},{label="T",value="TShape"}},S.CrosshairStyle,function(v) S.CrosshairStyle=v; refreshCrosshair() end,3)
                        addColorRow(scroll,"Color",{Color3.fromRGB(0,255,100),Color3.fromRGB(0,200,255),Color3.fromRGB(255,80,80),Color3.fromRGB(255,255,255),Color3.fromRGB(255,200,0),Color3.fromRGB(200,80,255)},S.CrosshairColor,function(col) S.CrosshairColor=col; refreshCrosshair() end,4)
                        addSlider(scroll,"Tamaño",4,30,S.CrosshairSize,function(v) return string.format("%d",math.floor(v)) end,function(v) S.CrosshairSize=v; refreshCrosshair() end,5)
                        addSlider(scroll,"Grosor",1,6,S.CrosshairThick,function(v) return string.format("%.1f",v) end,function(v) S.CrosshairThick=v; refreshCrosshair() end,6)
                        addSlider(scroll,"Gap",0,15,S.CrosshairGap,function(v) return string.format("%d",math.floor(v)) end,function(v) S.CrosshairGap=v; refreshCrosshair() end,7)
                        addToggle(scroll,"Glow",S.CrosshairGlow,function(v) S.CrosshairGlow=v; refreshCrosshair() end,8)
                        addSlider(scroll,"Offset X",-500,500,S.CrosshairOffset.x,function(v) return string.format("%d",math.floor(v)) end,function(v) S.CrosshairOffset.x=v; refreshCrosshair() end,9)
                        addSlider(scroll,"Offset Y",-500,500,S.CrosshairOffset.y,function(v) return string.format("%d",math.floor(v)) end,function(v) S.CrosshairOffset.y=v; refreshCrosshair() end,10)
                    end)
                end)
            end

            -- ============ COLORES ============
            addSectionTitle(tabContent,"🎨 Colores",nextOrder())
            addColorRow(tabContent,"Fondo del Panel",{Color3.fromRGB(13,16,24),Color3.fromRGB(20,10,25),Color3.fromRGB(25,15,10),Color3.fromRGB(10,20,15),Color3.fromRGB(8,8,8),Color3.fromRGB(30,30,40)},S.PanelBg,function(col) S.PanelBg=col; if UI.mainFrame then UI.mainFrame.BackgroundColor3=col end end,nextOrder())
            addColorRow(tabContent,"Color de Acento",{Color3.fromRGB(0,200,255),Color3.fromRGB(0,255,130),Color3.fromRGB(255,80,80),Color3.fromRGB(255,200,0),Color3.fromRGB(200,80,255),Color3.fromRGB(255,255,255)},S.AccentColor,function(col)
                S.AccentColor=col
                if UI.mainFrame then
                    local st = UI.mainFrame:FindFirstChildOfClass("UIStroke")
                    if st then st.Color = col end
                    for _, d in ipairs(UI.mainFrame:GetDescendants()) do
                        if d:IsA("UIStroke") then d.Color = col end
                    end
                end
            end,nextOrder())

            -- ============ ESTILO AVANZADO (NUEVO) ============
            addSectionTitle(tabContent,"✨ Estilo Avanzado",nextOrder())
            addSlider(tabContent,"Transparencia del Panel",0,0.8,0.8-S.PanelTransparency,function(v) return string.format("%d%%",math.floor(v*100)) end,function(v)
                S.PanelTransparency = 0.8 - v
                if UI.mainFrame then UI.mainFrame.BackgroundTransparency = S.PanelTransparency end
            end,nextOrder())
            addSlider(tabContent,"Grosor de Bordes",0.5,4,S.BorderThickness,function(v) return string.format("%.1f",v) end,function(v)
                S.BorderThickness = v
                if UI.mainFrame then
                    for _, d in ipairs(UI.mainFrame:GetDescendants()) do
                        if d:IsA("UIStroke") then d.Thickness = v end
                    end
                end
            end,nextOrder())
            addSlider(tabContent,"Redondez de Esquinas",0,40,S.CornerRadius,function(v) return string.format("%d",math.floor(v)) end,function(v)
                S.CornerRadius = v
                if UI.mainFrame then
                    local c = UI.mainFrame:FindFirstChildOfClass("UICorner")
                    if c then c.CornerRadius = UDim.new(0, v) end
                end
            end,nextOrder())
            addSlider(tabContent,"Ángulo del Gradiente",0,360,S.GradientAngle,function(v) return string.format("%d°",math.floor(v)) end,function(v)
                S.GradientAngle = v
                if UI.mainFrame then
                    local g = UI.mainFrame:FindFirstChildOfClass("UIGradient")
                    if g then g.Rotation = v end
                end
            end,nextOrder())
            addToggle(tabContent,"Mostrar Iconos en Pestañas",S.ShowTabIcons,function(v)
                S.ShowTabIcons = v
                notify("Recarga la UI para aplicar iconos","info")
            end,nextOrder())

            -- ============ ACCESIBILIDAD (NUEVO) ============
            addSectionTitle(tabContent,"♿ Accesibilidad",nextOrder())
            addSlider(tabContent,"Escala de Interfaz (DPI)",0.7,1.5,S.UIScale,function(v) return string.format("%d%%",math.floor(v*100)) end,function(v)
                S.UIScale = v
                applyUIScale()
            end,nextOrder())
            addSlider(tabContent,"Escala de Fuente",0.8,1.5,S.FontScale,function(v) return string.format("%d%%",math.floor(v*100)) end,function(v)
                S.FontScale = v
                if UI.rebuildTab then UI.rebuildTab() end
                refreshStats()
            end,nextOrder())
            addToggle(tabContent,"Alto Contraste",S.HighContrast,function(v)
                S.HighContrast = v
                applyHighContrast()
                if UI.rebuildTab then UI.rebuildTab() end
                notify(v and "Alto contraste ON" or "Alto contraste OFF", v and "success" or "info")
            end,nextOrder())
            addToggle(tabContent,"Modo Fácil (oculta avanzado)",S.EasyMode,function(v)
                S.EasyMode = v
                if UI.rebuildTab then UI.rebuildTab() end
                notify(v and "Modo Fácil activado" or "Modo Fácil desactivado", v and "success" or "info")
            end,nextOrder())
            addToggle(tabContent,"Reducir Movimiento",S.ReduceMotion,function(v)
                S.ReduceMotion = v
                notify(v and "Animaciones reducidas" or "Animaciones normales", "info")
            end,nextOrder())
            addSelector(tabContent,"Modo Daltonismo",{
                {label="Ninguno",value="None"},
                {label="Protanopia (rojo)",value="Protanopia"},
                {label="Deuteranopia (verde)",value="Deuteranopia"},
                {label="Tritanopia (azul)",value="Tritanopia"},
            },S.ColorBlindMode,function(v)
                S.ColorBlindMode = v
                applyColorBlind()
            end,nextOrder())
            addToggle(tabContent,"Botones Grandes (táctil)",S.BigTouchTargets,function(v)
                S.BigTouchTargets = v
                if UI.rebuildTab then UI.rebuildTab() end
            end,nextOrder())

            -- ============ EFECTOS ============
            addSectionTitle(tabContent,"🌀 Efectos",nextOrder())
            addToggle(tabContent,"Ripples en Botones",S.Ripples,function(v) S.Ripples = v end,nextOrder())
            addToggle(tabContent,"Animaciones Globales",S.Animations,function(v) S.Animations = v end,nextOrder())
            addToggle(tabContent,"Glass Effect",S.GlassEffect,function(v) S.GlassEffect = v end,nextOrder())

        elseif activeTab=="STATS" then
            if match("fps") then addToggle(tabContent,"Mostrar FPS",S.ShowFPS,function(v) S.ShowFPS=v; refreshStats() end,nextOrder()) end
            if match("ping") then addToggle(tabContent,"Mostrar Ping",S.ShowPing,function(v) S.ShowPing=v; refreshStats() end,nextOrder()) end
            if match("fps") then
                local eb = create("TextButton",{Size=UDim2.new(1,-8,0,28),BackgroundColor3=Color3.fromRGB(22,28,42),BorderSizePixel=0,Text="✎ Editar FPS",TextColor3=S.AccentColor,Font=Enum.Font.GothamBold,TextSize=12,AutoButtonColor=false,LayoutOrder=nextOrder(),ZIndex=63},tabContent)
                corner(UDim.new(0,8),eb); addRipple(eb)
                eb.MouseButton1Click:Connect(function()
                    openEditor("Editar FPS Counter",function(scroll)
                        addInfoLabel(scroll,"Personaliza el contador de FPS",1); addSeparator(scroll,2)
                        addFontCycler(scroll,"Fuente","FPS",function() refreshStats() end,3)
                        addSlider(scroll,"Tamaño",8,40,S.FPS.fontSize,function(v) return string.format("%d",math.floor(v)) end,function(v) S.FPS.fontSize=v; refreshStats() end,4)
                        addColorRow(scroll,"Fondo",{Color3.fromRGB(10,15,25),Color3.fromRGB(25,10,10),Color3.fromRGB(10,25,15),Color3.fromRGB(25,25,10),Color3.fromRGB(255,255,255),Color3.fromRGB(0,0,0)},S.FPS.bgColor,function(col) S.FPS.bgColor=col; refreshStats() end,5)
                        addColorRow(scroll,"Letra",{Color3.fromRGB(0,220,255),Color3.fromRGB(0,255,100),Color3.fromRGB(255,80,80),Color3.fromRGB(255,255,255),Color3.fromRGB(255,200,0),Color3.fromRGB(200,80,255)},S.FPS.textColor,function(col) S.FPS.textColor=col; refreshStats() end,6)
                    end)
                end)
            end
            if match("ping") then
                local eb = create("TextButton",{Size=UDim2.new(1,-8,0,28),BackgroundColor3=Color3.fromRGB(22,28,42),BorderSizePixel=0,Text="✎ Editar Ping",TextColor3=S.AccentColor,Font=Enum.Font.GothamBold,TextSize=12,AutoButtonColor=false,LayoutOrder=nextOrder(),ZIndex=63},tabContent)
                corner(UDim.new(0,8),eb); addRipple(eb)
                eb.MouseButton1Click:Connect(function()
                    openEditor("Editar Ping Counter",function(scroll)
                        addInfoLabel(scroll,"Personaliza el contador de Ping",1); addSeparator(scroll,2)
                        addFontCycler(scroll,"Fuente","PING",function() refreshStats() end,3)
                        addSlider(scroll,"Tamaño",8,40,S.PING.fontSize,function(v) return string.format("%d",math.floor(v)) end,function(v) S.PING.fontSize=v; refreshStats() end,4)
                        addColorRow(scroll,"Fondo",{Color3.fromRGB(10,15,25),Color3.fromRGB(25,10,10),Color3.fromRGB(10,25,15),Color3.fromRGB(25,25,10),Color3.fromRGB(255,255,255),Color3.fromRGB(0,0,0)},S.PING.bgColor,function(col) S.PING.bgColor=col; refreshStats() end,5)
                        addColorRow(scroll,"Letra",{Color3.fromRGB(0,220,255),Color3.fromRGB(0,255,100),Color3.fromRGB(255,80,80),Color3.fromRGB(255,255,255),Color3.fromRGB(255,200,0),Color3.fromRGB(200,80,255)},S.PING.textColor,function(col) S.PING.textColor=col; refreshStats() end,6)
                    end)
                end)
            end

        elseif activeTab=="CONFIG" then
            addInfoLabel(tabContent,"Presets y gestión de configuración",nextOrder())
            addSeparator(tabContent,nextOrder())
            local presetRow = create("Frame",{Size=UDim2.new(1,-8,0,32),BackgroundTransparency=1,LayoutOrder=nextOrder(),ZIndex=62},tabContent)
            local function presetBtn(text,pos,apply)
                local b=create("TextButton",{Size=UDim2.new(.32,0,1,0),Position=UDim2.new(pos,0,0,0),BackgroundColor3=Color3.fromRGB(22,28,42),BorderSizePixel=0,Text=text,TextColor3=Color3.fromRGB(200,215,235),Font=Enum.Font.Gotham,TextSize=11,AutoButtonColor=false,ZIndex=63},presetRow)
                corner(UDim.new(0,6),b); addRipple(b)
                b.MouseButton1Click:Connect(apply)
            end
            presetBtn("🎯 Legit",0,function() S.Smoothness=75; S.Prediction=0.05; S.FovRadius=120; notify("Preset Legit aplicado","success") end)
            presetBtn("⚖ Balance",0.34,function() S.Smoothness=45; S.Prediction=0.1; S.FovRadius=200; notify("Preset Balance aplicado","success") end)
            presetBtn("🔥 Rage",0.68,function() S.Smoothness=0; S.Prediction=0.15; S.FovRadius=600; notify("Preset Rage aplicado","success") end)
            addSeparator(tabContent,nextOrder())
            local saveNowBtn = create("TextButton",{Size=UDim2.new(1,-8,0,34),BackgroundColor3=Color3.fromRGB(0,150,90),BorderSizePixel=0,Text="💾 Guardar Posiciones Ahora",TextColor3=Color3.new(1,1,1),Font=Enum.Font.GothamBold,TextSize=13,AutoButtonColor=false,LayoutOrder=nextOrder(),ZIndex=63},tabContent)
            corner(UDim.new(0,8),saveNowBtn); addRipple(saveNowBtn)
            saveNowBtn.MouseButton1Click:Connect(function()
                if saveToDisk() then notify("Posiciones guardadas en disco","success"); snapshotPositions()
                else notify("No se pudo guardar (executor necesario)","warn") end
            end)
            local resetBtn = create("TextButton",{Size=UDim2.new(1,-8,0,34),BackgroundColor3=Color3.fromRGB(150,50,60),BorderSizePixel=0,Text="↺ Restaurar Posiciones",TextColor3=Color3.new(1,1,1),Font=Enum.Font.GothamBold,TextSize=13,AutoButtonColor=false,LayoutOrder=nextOrder(),ZIndex=63},tabContent)
            corner(UDim.new(0,8),resetBtn); addRipple(resetBtn)
            resetBtn.MouseButton1Click:Connect(function()
                S.CircleOffset={x=0,y=0}; S.CrosshairOffset={x=0,y=0}
                S.ReopenPos={xs=.5,xo=0,ys=.5,yo=0}; S.TogglePos={xs=.15,xo=0,ys=.5,yo=0}
                S.FPS.pos=UDim2.new(0,10,0,10); S.PING.pos=UDim2.new(0,10,0,44)
                if UI.applyPositions then UI.applyPositions() end
                notify("Posiciones restauradas","info")
            end)

        elseif activeTab=="INFO" then
            addInfoLabel(tabContent,"XAttA ULTRA v3.3",nextOrder())
            addInfoLabel(tabContent,"Hecho con AntiGravity IA e In0B4T_SD (Ksjzns84)",nextOrder())
            addSeparator(tabContent,nextOrder())
            addInfoLabel(tabContent,"• 6 pestañas + buscador",nextOrder())
            addInfoLabel(tabContent,"• Estilo Avanzado (transparencia, bordes, esquinas)",nextOrder())
            addInfoLabel(tabContent,"• Accesibilidad (DPI, contraste, fuente, daltonismo)",nextOrder())
            addInfoLabel(tabContent,"• Modo Fácil para ocultar opciones avanzadas",nextOrder())
            addInfoLabel(tabContent,"• Elementos movibles mientras UI abierta",nextOrder())
            addInfoLabel(tabContent,"• Guardado automático de posiciones",nextOrder())
            addInfoLabel(tabContent,"• Persistencia entre sesiones (executor)",nextOrder())
            addInfoLabel(tabContent,"• FPS/Ping/Círculo/Crosshair arrastrables",nextOrder())
            addInfoLabel(tabContent,"• SHIFT = abrir/cerrar ventana",nextOrder())
        end
    end

    local resizeHandle=create("TextButton",{Size=UDim2.fromOffset(20,20),Position=UDim2.new(1,-6,1,-6),AnchorPoint=Vector2.new(1,1),BackgroundColor3=S.AccentColor,BackgroundTransparency=0.15,BorderSizePixel=0,Text="",AutoButtonColor=false,ZIndex=55},main)
    corner(UDim.new(0,6),resizeHandle); stroke(S.AccentColor,1,resizeHandle)
    for i=1,3 do create("Frame",{Size=UDim2.fromOffset(2,9),Position=UDim2.new(0,4+(i-1)*5,1,-6),AnchorPoint=Vector2.new(0,1),BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=0.2,BorderSizePixel=0,ZIndex=56},resizeHandle) end
    do
        local dragging=false; local pressPos,startSize,startAbs = nil,nil,nil
        local isMouse,activeTouch = false,nil
        resizeHandle.InputBegan:Connect(function(input)
            if input.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true; isMouse=true; pressPos=input.Position; startSize=main.AbsoluteSize; startAbs=main.AbsolutePosition; main.AnchorPoint=Vector2.new(0,0); main.Position=UDim2.fromOffset(startAbs.X,startAbs.Y)
            elseif input.UserInputType==Enum.UserInputType.Touch then dragging=true; isMouse=false; activeTouch=input; pressPos=input.Position; startSize=main.AbsoluteSize; startAbs=main.AbsolutePosition; main.AnchorPoint=Vector2.new(0,0); main.Position=UDim2.fromOffset(startAbs.X,startAbs.Y) end
        end)
        UIS.InputChanged:Connect(function(input)
            if not dragging then return end
            local ok=false
            if isMouse and input.UserInputType==Enum.UserInputType.MouseMovement then ok=true
            elseif not isMouse and input==activeTouch then ok=true end
            if ok then
                local d=input.Position-pressPos
                local nw=math.max(400,startSize.X+d.X); local nh=math.max(300,startSize.Y+d.Y)
                main.Size=UDim2.fromOffset(nw,nh); main:SetAttribute("BaseX",nw); main:SetAttribute("BaseY",nh)
            end
        end)
        UIS.InputEnded:Connect(function(input)
            if not dragging then return end
            if isMouse and input.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false
            elseif not isMouse and input==activeTouch then dragging=false; activeTouch=nil end
        end)
    end

    local function doHideUI(skipPrompt)
        local function finish()
            UI.setMovable(false)
            tw(main,0.28,{Size=UDim2.fromOffset(0,0)},Enum.EasingStyle.Back,Enum.EasingDirection.In)
            task.delay(0.3,function() main.Visible=false end)
            if reopenBtn then reopenBtn.Visible=true; reopenBtn.Size=UDim2.fromOffset(0,0); tw(reopenBtn,0.5,{Size=UDim2.fromOffset(130,48)},Enum.EasingStyle.Back) end
        end
        if skipPrompt or not hasChanges() then finish(); return end
        showPrompt(Mensajes.Guardar, function()
            if saveToDisk() then notify("Estado de botones guardado","success") end
            snapshotPositions(); finish()
        end, function()
            restoreSnapshot(); notify("Posiciones restauradas","info"); finish()
        end)
    end
    UI.hide = doHideUI

    local function showUI()
        main.Visible=true; compactMode=false
        if tabContent then tabContent.Visible=true end
        if editorOverlay then editorOverlay.Visible=false end
        UI.setMovable(true)
        snapshotPositions()
        local sz=Vector2.new(main:GetAttribute("BaseX") or W, main:GetAttribute("BaseY") or H)
        main.Size=UDim2.fromOffset(0,0)
        tw(main,0.5,{Size=UDim2.fromOffset(sz.X,sz.Y)},Enum.EasingStyle.Back)
        if reopenBtn then tw(reopenBtn,0.25,{Size=UDim2.fromOffset(0,0)}); task.delay(0.3,function() if reopenBtn then reopenBtn.Visible=false end end) end
    end
    UI.show = showUI

    local function toggleCompact()
        local function apply()
            compactMode=not compactMode
            local sz=Vector2.new(main:GetAttribute("BaseX") or W, main:GetAttribute("BaseY") or H)
            if compactMode then
                tabContent.Visible=false
                if editorOverlay then editorOverlay.Visible=false end
                tabsBar.Visible=false
                tw(main,0.4,{Size=UDim2.fromOffset(sz.X,100)},Enum.EasingStyle.Quint)
            else
                tabContent.Visible=true
                tabsBar.Visible=true
                tw(main,0.4,{Size=UDim2.fromOffset(sz.X,sz.Y)},Enum.EasingStyle.Quint)
            end
        end
        if not hasChanges() then apply(); return end
        showPrompt(Mensajes.Guardar, function()
            if saveToDisk() then notify("Estado de botones guardado","success") end
            snapshotPositions(); apply()
        end, function()
            restoreSnapshot(); notify("Posiciones restauradas","info"); apply()
        end)
    end

    winBtn(0,"✕",Color3.fromRGB(200,50,70),function() doHideUI(false) end)
    winBtn(1,"▢",Color3.fromRGB(60,70,90),toggleCompact)
    winBtn(2,"—",Color3.fromRGB(60,70,90),function() doHideUI(false) end)

    do
        local dragging=false; local dragStart,startPos = nil,nil
        local isMouse,activeTouch = false,nil
        local function beginJelly()
            if S.Animations and not S.ReduceMotion then
                local sz=main.AbsoluteSize
                tw(main,0.18,{Size=UDim2.fromOffset(sz.X*1.025,sz.Y*1.025)},Enum.EasingStyle.Back)
            end
        end
        local function endJelly()
            if S.Animations and not S.ReduceMotion then
                local b=Vector2.new(main:GetAttribute("BaseX") or main.AbsoluteSize.X, main:GetAttribute("BaseY") or main.AbsoluteSize.Y)
                tw(main,0.55,{Size=UDim2.fromOffset(b.X,b.Y)},Enum.EasingStyle.Elastic)
            end
        end
        header.InputBegan:Connect(function(input)
            if input.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true; isMouse=true; dragStart=input.Position; startPos=main.Position; beginJelly()
            elseif input.UserInputType==Enum.UserInputType.Touch then dragging=true; isMouse=false; activeTouch=input; dragStart=input.Position; startPos=main.Position; beginJelly() end
        end)
        UIS.InputChanged:Connect(function(input)
            if not dragging then return end
            local ok=false
            if isMouse and input.UserInputType==Enum.UserInputType.MouseMovement then ok=true
            elseif not isMouse and input==activeTouch then ok=true end
            if ok then
                local d=input.Position-dragStart
                main.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)
            end
        end)
        UIS.InputEnded:Connect(function(input)
            if not dragging then return end
            if isMouse and input.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false; endJelly()
            elseif not isMouse and input==activeTouch then dragging=false; activeTouch=nil; endJelly() end
        end)
    end

    task.defer(function() switchTab("AIM") end)
end

--==================== FOV Círculo ====================
local function buildFovCircle()
    fovGui = create("ScreenGui",{Name="XAttA_FOV",ResetOnSpawn=false,IgnoreGuiInset=true,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,Enabled=S.ShowCircle,DisplayOrder=99988},PlayerGui)
    ensureUIScale(fovGui)
    fovCircle = create("Frame",{Size=UDim2.fromOffset(S.FovRadius*2,S.FovRadius*2),Position=UDim2.new(.5,S.CircleOffset.x,.5,S.CircleOffset.y),AnchorPoint=Vector2.new(.5,.5),BackgroundTransparency=1,BorderSizePixel=0,ZIndex=5},fovGui)
    corner(UDim.new(1,0),fovCircle); stroke(S.CircleColor,S.CircleThickness,fovCircle)

    local dragging,dragStart,startOff = false,nil,nil
    local isMouse,activeTouch = false,nil
    fovCircle.InputBegan:Connect(function(input)
        if not UI.uiOpen then return end
        if input.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true; isMouse=true; dragStart=input.Position; startOff={x=S.CircleOffset.x,y=S.CircleOffset.y}
        elseif input.UserInputType==Enum.UserInputType.Touch then dragging=true; isMouse=false; activeTouch=input; dragStart=input.Position; startOff={x=S.CircleOffset.x,y=S.CircleOffset.y} end
    end)
    UIS.InputChanged:Connect(function(input)
        if not dragging then return end
        local ok=false
        if isMouse and input.UserInputType==Enum.UserInputType.MouseMovement then ok=true
        elseif not isMouse and input==activeTouch then ok=true end
        if ok then
            local d=input.Position-dragStart
            S.CircleOffset.x=startOff.x+d.X; S.CircleOffset.y=startOff.y+d.Y
            fovCircle.Position=UDim2.new(.5,S.CircleOffset.x,.5,S.CircleOffset.y)
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if not dragging then return end
        if isMouse and input.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false
        elseif not isMouse and input==activeTouch then dragging=false; activeTouch=nil end
    end)

    targetNameLbl = create("TextLabel",{Size=UDim2.fromOffset(220,26),Position=UDim2.new(0,0,0,0),AnchorPoint=Vector2.new(.5,1),BackgroundColor3=S.NAME.bgColor,BackgroundTransparency=0.25,BorderSizePixel=0,Text="",TextColor3=S.CircleColor,Font=Enum.Font.GothamBold,TextSize=S.NAME.fontSize,Visible=false,ZIndex=7},fovGui)
    corner(UDim.new(0,8),targetNameLbl); stroke(S.CircleColor,1.2,targetNameLbl)

    task.spawn(function()
        while fovCircle and fovCircle.Parent do
            if S.CirclePulse and S.ShowCircle and not S.ReduceMotion then
                local st=fovCircle:FindFirstChildOfClass("UIStroke")
                if st then
                    tw(st,1.2,{Transparency=0.5},Enum.EasingStyle.Sine); task.wait(1.2)
                    if not st.Parent then break end
                    tw(st,1.2,{Transparency=0},Enum.EasingStyle.Sine); task.wait(1.2)
                else task.wait(1) end
            else task.wait(0.5) end
        end
    end)
end

--==================== Stats UI ====================
local function buildStats()
    statsGui = create("ScreenGui",{Name="XAttA_Stats",ResetOnSpawn=false,IgnoreGuiInset=true,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,DisplayOrder=99989},PlayerGui)
    ensureUIScale(statsGui)
    fpsLbl = create("TextLabel",{Size=UDim2.fromOffset(140,26),Position=S.FPS.pos,BackgroundColor3=S.FPS.bgColor,BackgroundTransparency=S.FPS.bgTransp,BorderSizePixel=0,Text="FPS: 0",TextColor3=S.FPS.textColor,Font=FONTS[S.FPS.fontIndex].f,TextSize=S.FPS.fontSize*S.FontScale,TextXAlignment=Enum.TextXAlignment.Left,Visible=S.ShowFPS,ZIndex=3},statsGui)
    corner(UDim.new(0,6),fpsLbl); stroke(S.FPS.textColor,1,fpsLbl)
    pingLbl = create("TextLabel",{Size=UDim2.fromOffset(140,26),Position=S.PING.pos,BackgroundColor3=S.PING.bgColor,BackgroundTransparency=S.PING.bgTransp,BorderSizePixel=0,Text="Ping: 0 ms",TextColor3=S.PING.textColor,Font=FONTS[S.PING.fontIndex].f,TextSize=S.PING.fontSize*S.FontScale,TextXAlignment=Enum.TextXAlignment.Left,Visible=S.ShowPing,ZIndex=3},statsGui)
    corner(UDim.new(0,6),pingLbl); stroke(S.PING.textColor,1,pingLbl)

    local function makeLabelDraggable(label, settings)
        local dragging,dragStart,startPos = false,nil,nil
        local isMouse,activeTouch = false,nil
        label.InputBegan:Connect(function(input)
            if not UI.uiOpen then return end
            if settings.anchored then return end
            if input.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true; isMouse=true; dragStart=input.Position; startPos=label.Position
            elseif input.UserInputType==Enum.UserInputType.Touch then dragging=true; isMouse=false; activeTouch=input; dragStart=input.Position; startPos=label.Position end
        end)
        UIS.InputChanged:Connect(function(input)
            if not dragging then return end
            local ok=false
            if isMouse and input.UserInputType==Enum.UserInputType.MouseMovement then ok=true
            elseif not isMouse and input==activeTouch then ok=true end
            if ok then
                local d=input.Position-dragStart
                label.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)
                settings.pos=label.Position
            end
        end)
        UIS.InputEnded:Connect(function(input)
            if not dragging then return end
            if isMouse and input.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false
            elseif not isMouse and input==activeTouch then dragging=false; activeTouch=nil end
        end)
    end
    makeLabelDraggable(fpsLbl, S.FPS)
    makeLabelDraggable(pingLbl, S.PING)
    refreshStats()
end

--==================== Botones flotantes ====================
local function buildReopenBtn()
    local sz = IS_MOBILE and 110 or 120
    local h = IS_MOBILE and 42 or 44
    reopenBtn = create("TextButton",{Size=UDim2.fromOffset(0,0),Position=UDim2.new(S.ReopenPos.xs,S.ReopenPos.xo,S.ReopenPos.ys,S.ReopenPos.yo),AnchorPoint=Vector2.new(.5,.5),BackgroundColor3=S.AccentColor,BorderSizePixel=0,Text="XAttA",TextColor3=Color3.new(1,1,1),Font=Enum.Font.GothamBold,TextSize=IS_MOBILE and 13 or 16,AutoButtonColor=false,Visible=false,ZIndex=40},gui)
    reopenBtn:SetAttribute("BaseX",sz); reopenBtn:SetAttribute("BaseY",h)
    corner(UDim.new(1,0),reopenBtn); stroke(S.AccentColor,2,reopenBtn)
    task.spawn(function()
        while reopenBtn.Parent do
            if reopenBtn.Visible and not S.ReduceMotion then
                tw(reopenBtn,1.4,{BackgroundColor3=S.AccentColor:Lerp(Color3.new(1,1,1),0.3)},Enum.EasingStyle.Sine,Enum.EasingDirection.InOut); task.wait(1.4)
                if not reopenBtn.Parent then break end
                tw(reopenBtn,1.4,{BackgroundColor3=S.AccentColor},Enum.EasingStyle.Sine,Enum.EasingDirection.InOut); task.wait(1.4)
            else task.wait(0.4) end
        end
    end)
    local dragging,dragStart,startPos = false,nil,nil
    local isMouse,activeTouch = false,nil
    local dragged = false
    reopenBtn.InputBegan:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true; isMouse=true; dragged=false; dragStart=input.Position; startPos=reopenBtn.Position
        elseif input.UserInputType==Enum.UserInputType.Touch then dragging=true; isMouse=false; activeTouch=input; dragged=false; dragStart=input.Position; startPos=reopenBtn.Position end
    end)
    UIS.InputChanged:Connect(function(input)
        if not dragging then return end
        local ok=false
        if isMouse and input.UserInputType==Enum.UserInputType.MouseMovement then ok=true
        elseif not isMouse and input==activeTouch then ok=true end
        if ok then
            local d=input.Position-dragStart
            if d.Magnitude>3 then dragged=true end
            reopenBtn.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)
            S.ReopenPos={xs=reopenBtn.Position.X.Scale,xo=reopenBtn.Position.X.Offset,ys=reopenBtn.Position.Y.Scale,yo=reopenBtn.Position.Y.Offset}
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if not dragging then return end
        if isMouse and input.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false
        elseif not isMouse and input==activeTouch then dragging=false; activeTouch=nil end
    end)
    reopenBtn.MouseButton1Click:Connect(function()
        if dragged then return end
        if UI.show then UI.show() end
    end)
end

local function buildToggleBtn()
    local sz = IS_MOBILE and 82 or 82
    toggleBtn = create("TextButton",{Size=UDim2.fromOffset(sz,sz),Position=UDim2.new(S.TogglePos.xs,S.TogglePos.xo,S.TogglePos.ys,S.TogglePos.yo),AnchorPoint=Vector2.new(.5,.5),BackgroundColor3=Color3.fromRGB(70,22,22),BackgroundTransparency=0.25,BorderSizePixel=0,Text="OFF",TextColor3=Color3.new(1,1,1),Font=Enum.Font.GothamBlack,TextSize=IS_MOBILE and 18 or 18,AutoButtonColor=false,Visible=false,ZIndex=35},gui)
    toggleBtn:SetAttribute("BaseX",sz); toggleBtn:SetAttribute("BaseY",sz)
    corner(UDim.new(1,0),toggleBtn)
    local tst = stroke(Color3.fromRGB(255,60,60),2,toggleBtn)
    local dragging,dragStart,startPos = false,nil,nil
    local isMouse,activeTouch = false,nil
    local dragged = false
    toggleBtn.InputBegan:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true; isMouse=true; dragged=false; dragStart=input.Position; startPos=toggleBtn.Position
        elseif input.UserInputType==Enum.UserInputType.Touch then dragging=true; isMouse=false; activeTouch=input; dragged=false; dragStart=input.Position; startPos=toggleBtn.Position end
    end)
    UIS.InputChanged:Connect(function(input)
        if not dragging then return end
        local ok=false
        if isMouse and input.UserInputType==Enum.UserInputType.MouseMovement then ok=true
        elseif not isMouse and input==activeTouch then ok=true end
        if ok then
            local d=input.Position-dragStart
            if d.Magnitude>3 then dragged=true end
            toggleBtn.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)
            S.TogglePos={xs=toggleBtn.Position.X.Scale,xo=toggleBtn.Position.X.Offset,ys=toggleBtn.Position.Y.Scale,yo=toggleBtn.Position.Y.Offset}
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if not dragging then return end
        if isMouse and input.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false
        elseif not isMouse and input==activeTouch then dragging=false; activeTouch=nil end
    end)
    toggleBtn.MouseButton1Click:Connect(function()
        if dragged then return end
        S.ToggleActive=not S.ToggleActive
        if S.ToggleActive then toggleBtn.Text="ON"; tw(toggleBtn,0.2,{BackgroundColor3=Color3.fromRGB(20,70,35)}); tst.Color=Color3.fromRGB(60,255,100)
        else toggleBtn.Text="OFF"; tw(toggleBtn,0.2,{BackgroundColor3=Color3.fromRGB(70,22,22)}); tst.Color=Color3.fromRGB(255,60,60) end
    end)
end

--==================== Lógica Aim ====================
local function hasLOS(head)
    if S.IgnoreWalls then return true end
    if not head or not head.Parent then return false end
    local char = head:FindFirstAncestorOfClass("Model")
    if not char then return false end
    local ignoreList={}
    if LP.Character then table.insert(ignoreList, LP.Character) end
    table.insert(ignoreList, char)
    local ok, obscuring = pcall(function() return Cam:GetPartsObscuringTarget({head.Position}, ignoreList) end)
    if ok and obscuring then
        for _,part in ipairs(obscuring) do
            if part and part:IsDescendantOf(game) and not part:IsDescendantOf(char) then
                if LP.Character and not part:IsDescendantOf(LP.Character) then return false end
            end
        end
        return true
    end
    local origin = Cam.CFrame.Position
    local dir = head.Position - origin
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = ignoreList
    params.IgnoreWater = false
    params.RespectCanCollide = false
    return workspace:Raycast(origin, dir, params) == nil
end

local function sameTeam(plr)
    if not S.TeamCheck then return false end
    if not LP.Team or not plr.Team then return false end
    return LP.Team == plr.Team
end

local function getAimPart(char)
    if S.AimBone=="Nearest" then
        local center = Vector2.new(Cam.ViewportSize.X/2 + S.CircleOffset.x, Cam.ViewportSize.Y/2 + S.CircleOffset.y)
        local best, bestD = nil, math.huge
        for _,name in ipairs({"Head","UpperTorso","Torso","LowerTorso","HumanoidRootPart"}) do
            local p = char:FindFirstChild(name)
            if p then
                local v = Cam:WorldToViewportPoint(p.Position)
                if v.Z > 0 then
                    local d = (Vector2.new(v.X,v.Y) - center).Magnitude
                    if d < bestD then best, bestD = p, d end
                end
            end
        end
        return best
    elseif S.AimBone=="Random" then
        local names = {"Head","UpperTorso","Torso"}
        local c = char:FindFirstChild(names[math.random(1,#names)])
        return c or char:FindFirstChild("Head")
    else
        return char:FindFirstChild(S.AimBone) or char:FindFirstChild("Head")
    end
end

local currentTarget = nil

local function getTarget()
    local center = Vector2.new(Cam.ViewportSize.X/2 + S.CircleOffset.x, Cam.ViewportSize.Y/2 + S.CircleOffset.y)
    local candidates = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LP then continue end
        if sameTeam(plr) then continue end
        local char = plr.Character
        if not char then continue end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then continue end
        local part = getAimPart(char)
        if not part then continue end
        local pos = Cam:WorldToViewportPoint(part.Position)
        if pos.Z <= 0 then continue end
        local d = (Vector2.new(pos.X,pos.Y) - center).Magnitude
        if d < S.FovRadius and hasLOS(part) then
            local score = 0
            if S.Priority=="Crosshair" then score = d
            elseif S.Priority=="Distance" then
                if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then score = (LP.Character.HumanoidRootPart.Position - part.Position).Magnitude
                else score = d end
            elseif S.Priority=="Health" then score = hum.Health
            elseif S.Priority=="Threat" then
                local dir = (part.Position - Cam.CFrame.Position).Unit
                score = -Cam.CFrame.LookVector:Dot(dir)
            end
            table.insert(candidates, {part=part, score=score})
        end
    end
    if #candidates==0 then currentTarget=nil; return nil end
    table.sort(candidates,function(a,b) return a.score<b.score end)
    if S.StickyAim and currentTarget and currentTarget.Parent then
        for _,c in ipairs(candidates) do
            if c.part==currentTarget then return currentTarget end
        end
    end
    currentTarget = candidates[1].part
    return currentTarget
end

local function isAimActive()
    if S.ActivationMode=="Always" then return true end
    if S.ActivationMode=="RightClick" then return UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) end
    if S.ActivationMode=="Toggle" then return S.ToggleActive end
    return false
end

local fpsFrames, fpsTime = 0, 0
RunService.RenderStepped:Connect(function(dt)
    fpsFrames=fpsFrames+1; fpsTime=fpsTime+dt
    if fpsTime>=0.5 then
        if fpsLbl then fpsLbl.Text="FPS: "..math.floor(fpsFrames/fpsTime) end
        fpsFrames, fpsTime = 0, 0
    end
end)

task.spawn(function()
    while true do
        task.wait(1)
        local ok, val = pcall(function() return Stats.Network.ServerStatsItem["Data Ping"]:GetValue() end)
        if pingLbl then pingLbl.Text="Ping: "..(ok and math.floor(val) or 0).." ms" end
    end
end)

RunService.RenderStepped:Connect(function(dt)
    if Cam.FieldOfView ~= S.CameraFov then Cam.FieldOfView = S.CameraFov end
    if not UI.main then return end

    if targetNameLbl then
        if S.ShowName and S.ShowCircle then
            local t = currentTarget
            if t and t.Parent then
                local pos, onScreen = Cam:WorldToViewportPoint(t.Position)
                if onScreen then
                    targetNameLbl.Visible = true
                    targetNameLbl.Position = UDim2.fromOffset(pos.X, pos.Y - 60)
                    targetNameLbl.Text = t.Parent.Name
                    targetNameLbl.TextColor3 = S.CircleColor
                    targetNameLbl.TextSize = S.NAME.fontSize * S.FontScale
                    targetNameLbl.BackgroundColor3 = S.NAME.bgColor
                    local st = targetNameLbl:FindFirstChildOfClass("UIStroke"); if st then st.Color = S.CircleColor end
                else targetNameLbl.Visible = false end
            else targetNameLbl.Visible = false end
        else targetNameLbl.Visible = false end
    end

    if not isAimActive() then return end
    local target = getTarget()
    if not target then return end

    local aimPos = target.Position
    if S.Prediction > 0 then
        local char = target:FindFirstAncestorOfClass("Model")
        if char then
            local root = char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart
            if root then aimPos = target.Position + root.AssemblyLinearVelocity * S.Prediction end
        end
    end

    local currentCF = Cam.CFrame
    local desiredCF = CFrame.lookAt(currentCF.Position, aimPos)

    if S.Smoothness <= 0.5 then
        Cam.CFrame = desiredCF
    else
        local sf = (100 - S.Smoothness) / 100
        local alpha = math.clamp(dt * (1 + sf * 25), 0, 1)
        if S.SmoothType == "Smoothstep" then alpha = alpha * alpha * (3 - 2 * alpha)
        elseif S.SmoothType == "Bezier" then local t=alpha; alpha = t*t*(3-2*t)*0.7 + t*0.3 end
        Cam.CFrame = currentCF:Lerp(desiredCF, alpha)
    end
end)

UI.applyPositions = function()
    if fovCircle then fovCircle.Position=UDim2.new(.5,S.CircleOffset.x,.5,S.CircleOffset.y) end
    if reopenBtn then reopenBtn.Position=UDim2.new(S.ReopenPos.xs,S.ReopenPos.xo,S.ReopenPos.ys,S.ReopenPos.yo) end
    if toggleBtn then toggleBtn.Position=UDim2.new(S.TogglePos.xs,S.TogglePos.xo,S.TogglePos.ys,S.TogglePos.yo) end
    if fpsLbl then fpsLbl.Position=S.FPS.pos end
    if pingLbl then pingLbl.Position=S.PING.pos end
    refreshCrosshair()
end

--==================== Flujo ====================
loadFromDisk()

task.wait(4)
tw(loading,0.6,{BackgroundTransparency=1})
tw(title,0.5,{TextTransparency=1}); tw(titleStroke,0.5,{Transparency=1})
tw(subtitle,0.5,{TextTransparency=1})
tw(barBg,0.5,{BackgroundTransparency=1}); tw(barFill,0.5,{BackgroundTransparency=1})
task.wait(0.7); loading:Destroy()

question.Visible=true
tw(question,0.6,{BackgroundTransparency=0.5})
local qW = IS_MOBILE and 0.78 or 0.42; local qH = IS_MOBILE and 0.34 or 0.32
tw(qBox,0.6,{Size=UDim2.fromScale(qW,qH)},Enum.EasingStyle.Back)

local answered=false
yesBtn.MouseButton1Click:Connect(function()
    if answered then return end; answered=true
    tw(qBox,0.35,{Size=UDim2.fromScale(0,0)},Enum.EasingStyle.Back,Enum.EasingDirection.In)
    tw(question,0.4,{BackgroundTransparency=1}); task.wait(0.45); question:Destroy()
    task.spawn(showSplash, Mensajes.AlSi); task.wait(0.3)

    buildMainUI(); buildFovCircle(); buildReopenBtn(); buildToggleBtn(); buildStats()
    crosshairGui = create("ScreenGui",{Name="XAttA_Crosshair",ResetOnSpawn=false,IgnoreGuiInset=true,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,DisplayOrder=99987},PlayerGui)
    ensureUIScale(crosshairGui)
    refreshCrosshair()
    applyCameraForce(); applyCameraMode()
    if S.HighContrast then applyHighContrast() end
    if S.ColorBlindMode ~= "None" then applyColorBlind() end
    applyUIScale()
    if UI.applyPositions then UI.applyPositions() end
    if UI.show then UI.show() end
    if toggleBtn then toggleBtn.Visible=(S.ActivationMode=="Toggle") end
    refreshCircleVisibility()
    task.wait(0.4)
    notify("Bienvenido a XAttA ULTRA v3.3","success")
    notify("Nuevo: Estilo Avanzado + Accesibilidad en Visual","info")
end)

noBtn.MouseButton1Click:Connect(function()
    if answered then return end; answered=true
    tw(qBox,0.35,{Size=UDim2.fromScale(0,0)},Enum.EasingStyle.Back,Enum.EasingDirection.In)
    tw(question,0.4,{BackgroundTransparency=1}); task.wait(0.45); question:Destroy()
    showSplash(Mensajes.AlNo)
end)

UIS.InputBegan:Connect(function(input,gp)
    if gp then return end
    if IS_MOBILE then return end
    if input.KeyCode==Enum.KeyCode.LeftShift or input.KeyCode==Enum.KeyCode.RightShift then
        if not UI.main then return end
        if UI.uiOpen then if UI.hide then UI.hide(false) end
        else if UI.show then UI.show() end end
    end
end)
