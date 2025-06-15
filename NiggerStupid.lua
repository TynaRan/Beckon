-- ImGui Library for Roblox
-- Version 1.0
-- By [Niggers]

local ImGui = {}
ImGui.__index = ImGui

-- Constants
ImGui.WindowFlags = {
    NoTitleBar = 1,
    NoResize = 2,
    NoMove = 4,
    NoScrollbar = 8,
    NoCollapse = 16,
    AlwaysAutoResize = 32,
    NoBackground = 64
}

ImGui.ColorEditFlags = {
    NoAlpha = 1,
    NoPicker = 2,
    NoOptions = 4,
    NoSmallPreview = 8,
    NoInputs = 16,
    NoTooltip = 32,
    NoLabel = 64,
    NoSidePreview = 128
}

-- Internal state
local ctx = {
    windows = {},
    activeWindow = nil,
    hotItem = 0,
    activeItem = 0,
    lastWidget = 0,
    mousePos = Vector2.new(0, 0),
    mouseDown = false,
    mouseClicked = false,
    mouseReleased = false,
    time = 0,
    frameCount = 0,
    style = {
        windowPadding = Vector2.new(8, 8),
        windowRounding = 6,
        framePadding = Vector2.new(4, 3),
        frameRounding = 3,
        itemSpacing = Vector2.new(8, 4),
        itemInnerSpacing = Vector2.new(4, 4),
        indentSpacing = 21,
        scrollbarSize = 14,
        grabMinSize = 10,
        
        colors = {
            text = Color3.fromRGB(255, 255, 255),
            textDisabled = Color3.fromRGB(128, 128, 128),
            windowBg = Color3.fromRGB(15, 15, 15),
            childBg = Color3.fromRGB(0, 0, 0),
            popupBg = Color3.fromRGB(20, 20, 20),
            border = Color3.fromRGB(40, 40, 40),
            borderShadow = Color3.fromRGB(0, 0, 0),
            frameBg = Color3.fromRGB(30, 30, 30),
            frameBgHovered = Color3.fromRGB(40, 40, 40),
            frameBgActive = Color3.fromRGB(50, 50, 50),
            titleBg = Color3.fromRGB(10, 10, 10),
            titleBgActive = Color3.fromRGB(20, 20, 20),
            titleBgCollapsed = Color3.fromRGB(0, 0, 0),
            menuBarBg = Color3.fromRGB(36, 36, 36),
            scrollbarBg = Color3.fromRGB(5, 5, 5),
            scrollbarGrab = Color3.fromRGB(80, 80, 80),
            scrollbarGrabHovered = Color3.fromRGB(100, 100, 100),
            scrollbarGrabActive = Color3.fromRGB(120, 120, 120),
            checkMark = Color3.fromRGB(200, 200, 200),
            sliderGrab = Color3.fromRGB(120, 120, 120),
            sliderGrabActive = Color3.fromRGB(140, 140, 140),
            button = Color3.fromRGB(50, 50, 50),
            buttonHovered = Color3.fromRGB(70, 70, 70),
            buttonActive = Color3.fromRGB(90, 90, 90),
            header = Color3.fromRGB(40, 40, 40),
            headerHovered = Color3.fromRGB(60, 60, 60),
            headerActive = Color3.fromRGB(80, 80, 80),
            separator = Color3.fromRGB(60, 60, 60),
            separatorHovered = Color3.fromRGB(80, 80, 80),
            separatorActive = Color3.fromRGB(100, 100, 100),
            resizeGrip = Color3.fromRGB(80, 80, 80),
            resizeGripHovered = Color3.fromRGB(100, 100, 100),
            resizeGripActive = Color3.fromRGB(120, 120, 120),
            tab = Color3.fromRGB(40, 40, 40),
            tabHovered = Color3.fromRGB(60, 60, 60),
            tabActive = Color3.fromRGB(80, 80, 80),
            tabUnfocused = Color3.fromRGB(20, 20, 20),
            tabUnfocusedActive = Color3.fromRGB(40, 40, 40),
            plotLines = Color3.fromRGB(150, 150, 150),
            plotLinesHovered = Color3.fromRGB(200, 200, 200),
            plotHistogram = Color3.fromRGB(150, 150, 150),
            plotHistogramHovered = Color3.fromRGB(200, 200, 200),
            tableHeaderBg = Color3.fromRGB(30, 30, 30),
            tableBorderStrong = Color3.fromRGB(60, 60, 60),
            tableBorderLight = Color3.fromRGB(40, 40, 40),
            tableRowBg = Color3.fromRGB(0, 0, 0),
            tableRowBgAlt = Color3.fromRGB(20, 20, 20),
            textSelectedBg = Color3.fromRGB(50, 100, 150),
            dragDropTarget = Color3.fromRGB(255, 255, 0),
            navHighlight = Color3.fromRGB(100, 100, 100),
            navWindowingHighlight = Color3.fromRGB(255, 255, 255),
            navWindowingDimBg = Color3.fromRGB(100, 100, 100),
            modalWindowDimBg = Color3.fromRGB(100, 100, 100)
        }
    }
}

-- Utility functions
local function GetID(text)
    return text
end

local function GetCurrentWindow()
    return ctx.activeWindow
end

local function ItemAdd(rect, id)
    local window = GetCurrentWindow()
    if not window then return false end
    
    -- Check if mouse is hovering this item
    local hovered = rect:PointInside(ctx.mousePos)
    if hovered then
        ctx.hotItem = id
    end
    
    -- Check if this is the active item
    local active = (ctx.activeItem == id)
    
    -- Check if mouse clicked on this item
    local clicked = false
    if hovered and ctx.mouseClicked and ctx.hotItem == id then
        clicked = true
    end
    
    return hovered, active, clicked
end

local function PushID(id)
    local window = GetCurrentWindow()
    if window then
        table.insert(window.idStack, id)
    end
end

local function PopID()
    local window = GetCurrentWindow()
    if window and #window.idStack > 0 then
        table.remove(window.idStack)
    end
end

-- Drawing functions
local function DrawRectFilled(rect, color, rounding)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, rect.Width, 0, rect.Height)
    frame.Position = UDim2.new(0, rect.X, 0, rect.Y)
    frame.BackgroundColor3 = color
    frame.BorderSizePixel = 0
    
    if rounding and rounding > 0 then
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, rounding)
        corner.Parent = frame
    end
    
    frame.Parent = ctx.screenGui
    return frame
end

local function DrawRect(rect, color, thickness, rounding)
    thickness = thickness or 1
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, rect.Width, 0, rect.Height)
    frame.Position = UDim2.new(0, rect.X, 0, rect.Y)
    frame.BackgroundTransparency = 1
    frame.BorderSizePixel = thickness
    frame.BorderColor3 = color
    
    if rounding and rounding > 0 then
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, rounding)
        corner.Parent = frame
    end
    
    frame.Parent = ctx.screenGui
    return frame
end

local function DrawText(text, pos, color)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 200, 0, 20)
    label.Position = UDim2.new(0, pos.X, 0, pos.Y)
    label.BackgroundTransparency = 1
    label.TextColor3 = color
    label.Text = text
    label.Font = Enum.Font.SourceSans
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Top
    label.Parent = ctx.screenGui
    return label
end

-- Widget functions
function ImGui.Begin(name, open, flags)
    flags = flags or 0
    
    -- Create window if it doesn't exist
    if not ctx.windows[name] then
        ctx.windows[name] = {
            pos = Vector2.new(100, 100),
            size = Vector2.new(300, 200),
            collapsed = false,
            idStack = {}
        }
    end
    
    local window = ctx.windows[name]
    ctx.activeWindow = window
    
    -- Set open state
    if open ~= nil then
        window.open = open
    elseif window.open == nil then
        window.open = true
    end
    
    if not window.open then
        ctx.activeWindow = nil
        return false
    end
    
    -- Window rectangle
    local titleBarHeight = 24
    local windowRect = {
        X = window.pos.X,
        Y = window.pos.Y,
        Width = window.size.X,
        Height = window.size.Y
    }
    
    -- Title bar rectangle
    local titleBarRect = {
        X = window.pos.X,
        Y = window.pos.Y,
        Width = window.size.X,
        Height = titleBarHeight
    }
    
    -- Check if mouse is hovering title bar
    local titleBarHovered = titleBarRect:PointInside(ctx.mousePos)
    
    -- Check for window movement
    if titleBarHovered and ctx.mouseDown and ctx.activeItem == 0 then
        ctx.activeItem = GetID(name.."##move")
        window.moving = true
        window.moveOffset = ctx.mousePos - window.pos
    elseif window.moving and not ctx.mouseDown then
        window.moving = false
        ctx.activeItem = 0
    end
    
    if window.moving then
        window.pos = ctx.mousePos - window.moveOffset
    end
    
    -- Draw window
    if bit32.band(flags, ImGui.WindowFlags.NoBackground) == 0 then
        DrawRectFilled(windowRect, ctx.style.colors.windowBg, ctx.style.windowRounding)
    end
    
    if bit32.band(flags, ImGui.WindowFlags.NoTitleBar) == 0 then
        DrawRectFilled(titleBarRect, ctx.style.colors.titleBg, ctx.style.windowRounding)
        
        -- Title text
        DrawText(name, Vector2.new(window.pos.X + 8, window.pos.Y + 4), ctx.style.colors.text)
        
        -- Close button
        local closeButtonRect = {
            X = window.pos.X + window.size.X - 20,
            Y = window.pos.Y + 4,
            Width = 16,
            Height = 16
        }
        
        local hovered, active, clicked = ItemAdd(closeButtonRect, GetID(name.."##close"))
        local closeColor = ctx.style.colors.text
        if hovered then closeColor = ctx.style.colors.buttonHovered end
        if active then closeColor = ctx.style.colors.buttonActive end
        
        DrawRectFilled(closeButtonRect, closeColor, 3)
        DrawText("x", Vector2.new(closeButtonRect.X + 4, closeButtonRect.Y + 1), ctx.style.colors.windowBg)
        
        if clicked then
            window.open = false
        end
    end
    
    -- Set cursor for content
    window.cursorPos = Vector2.new(window.pos.X + ctx.style.windowPadding.X, 
                                  window.pos.Y + titleBarHeight + ctx.style.windowPadding.Y)
    
    return true
end

function ImGui.End()
    ctx.activeWindow = nil
end

function ImGui.Button(label, size)
    size = size or Vector2.new(80, 24)
    
    local window = GetCurrentWindow()
    if not window then return false end
    
    local id = GetID(label)
    local rect = {
        X = window.cursorPos.X,
        Y = window.cursorPos.Y,
        Width = size.X,
        Height = size.Y
    }
    
    local hovered, active, clicked = ItemAdd(rect, id)
    
    local color = ctx.style.colors.button
    if hovered then color = ctx.style.colors.buttonHovered end
    if active then color = ctx.style.colors.buttonActive end
    
    DrawRectFilled(rect, color, ctx.style.frameRounding)
    DrawText(label, Vector2.new(rect.X + (rect.Width - #label * 7) / 2, rect.Y + (rect.Height - 14) / 2), ctx.style.colors.text)
    
    window.cursorPos.Y = rect.Y + rect.Height + ctx.style.itemSpacing.Y
    
    return clicked
end

function ImGui.Checkbox(label, value)
    local window = GetCurrentWindow()
    if not window then return value, false end
    
    local id = GetID(label)
    local size = 16
    local rect = {
        X = window.cursorPos.X,
        Y = window.cursorPos.Y,
        Width = size,
        Height = size
    }
    
    local hovered, active, clicked = ItemAdd(rect, id)
    
    if clicked then
        value = not value
    end
    
    local color = ctx.style.colors.frameBg
    if hovered then color = ctx.style.colors.frameBgHovered end
    if active then color = ctx.style.colors.frameBgActive end
    
    DrawRectFilled(rect, color, ctx.style.frameRounding)
    DrawRect(rect, ctx.style.colors.border, 1, ctx.style.frameRounding)
    
    if value then
        local checkSize = 8
        local checkRect = {
            X = rect.X + (rect.Width - checkSize) / 2,
            Y = rect.Y + (rect.Height - checkSize) / 2,
            Width = checkSize,
            Height = checkSize
        }
        DrawRectFilled(checkRect, ctx.style.colors.checkMark, 2)
    end
    
    local labelPos = Vector2.new(rect.X + rect.Width + ctx.style.itemInnerSpacing.X, rect.Y + (rect.Height - 14) / 2)
    DrawText(label, labelPos, ctx.style.colors.text)
    
    window.cursorPos.Y = rect.Y + rect.Height + ctx.style.itemSpacing.Y
    
    return value, clicked
end

function ImGui.SliderFloat(label, value, min, max, format)
    format = format or "%.2f"
    
    local window = GetCurrentWindow()
    if not window then return value, false end
    
    local id = GetID(label)
    local width = 120
    local height = 16
    local rect = {
        X = window.cursorPos.X,
        Y = window.cursorPos.Y,
        Width = width,
        Height = height
    }
    
    local hovered, active, clicked = ItemAdd(rect, id)
    
    -- Calculate normalized value
    local normalized = (value - min) / (max - min)
    
    -- Handle dragging
    if active and ctx.mouseDown then
        local mouseX = ctx.mousePos.X - rect.X
        normalized = math.clamp(mouseX / rect.Width, 0, 1)
        value = min + normalized * (max - min)
    end
    
    -- Draw background
    DrawRectFilled(rect, ctx.style.colors.frameBg, ctx.style.frameRounding)
    
    -- Draw filled part
    local filledRect = {
        X = rect.X,
        Y = rect.Y,
        Width = rect.Width * normalized,
        Height = rect.Height
    }
    DrawRectFilled(filledRect, ctx.style.colors.sliderGrabActive, ctx.style.frameRounding)
    
    -- Draw grab
    local grabSize = 8
    local grabRect = {
        X = rect.X + rect.Width * normalized - grabSize / 2,
        Y = rect.Y + (rect.Height - grabSize) / 2,
        Width = grabSize,
        Height = grabSize
    }
    DrawRectFilled(grabRect, ctx.style.colors.sliderGrab, ctx.style.frameRounding)
    
    -- Draw label and value
    local labelPos = Vector2.new(rect.X, rect.Y + rect.Height + ctx.style.itemInnerSpacing.Y)
    DrawText(label, labelPos, ctx.style.colors.text)
    
    local valueText = string.format(format, value)
    local valuePos = Vector2.new(rect.X + rect.Width - #valueText * 7, rect.Y + rect.Height + ctx.style.itemInnerSpacing.Y)
    DrawText(valueText, valuePos, ctx.style.colors.text)
    
    window.cursorPos.Y = rect.Y + rect.Height + ctx.style.itemSpacing.Y + 14
    
    return value, active and ctx.mouseDown
end

function ImGui.Text(text)
    local window = GetCurrentWindow()
    if not window then return end
    
    DrawText(text, window.cursorPos, ctx.style.colors.text)
    window.cursorPos.Y = window.cursorPos.Y + 14 + ctx.style.itemSpacing.Y
end

function ImGui.SameLine(offset)
    offset = offset or 0
    local window = GetCurrentWindow()
    if window then
        window.cursorPos.X = window.cursorPos.X + offset
    end
end

function ImGui.NewLine()
    local window = GetCurrentWindow()
    if window then
        window.cursorPos.X = window.pos.X + ctx.style.windowPadding.X
        window.cursorPos.Y = window.cursorPos.Y + ctx.style.itemSpacing.Y
    end
end

function ImGui.Separator()
    local window = GetCurrentWindow()
    if not window then return end
    
    local lineY = window.cursorPos.Y + 4
    local lineRect = {
        X = window.pos.X + ctx.style.windowPadding.X,
        Y = lineY,
        Width = window.size.X - ctx.style.windowPadding.X  * 2,
        Height = 1
    }
    
    DrawRectFilled(lineRect, ctx.style.colors.separator, 0)
    
    window.cursorPos.Y = lineY + 8
end

-- Initialization
function ImGui.Init(screenGui)
    ctx.screenGui = screenGui
    ctx.time = os.clock()
    ctx.frameCount = 0
    
    -- Connect input events
    local userInputService = game:GetService("UserInputService")
    
    userInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            ctx.mouseDown = true
            ctx.mouseClicked = true
        end
    end)
    
    userInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            ctx.mouseDown = false
            ctx.mouseReleased = true
        end
    end)
    
    userInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            ctx.mousePos = Vector2.new(input.Position.X, input.Position.Y)
        end
    end)
end

function ImGui.Shutdown()
    -- Clean up
    for _, window in pairs(ctx.windows) do
        -- Clean up window resources if needed
    end
    ctx.windows = {}
    ctx.activeWindow = nil
end

function ImGui.NewFrame()
    -- Clear the screen
    if ctx.screenGui then
        ctx.screenGui:ClearAllChildren()
    end
    
    -- Update timing
    local currentTime = os.clock()
    ctx.deltaTime = currentTime - ctx.time
    ctx.time = currentTime
    ctx.frameCount = ctx.frameCount + 1
    
    -- Reset input states
    ctx.mouseClicked = false
    ctx.mouseReleased = false
    
    -- Reset hot item if mouse not down
    if not ctx.mouseDown then
        ctx.hotItem = 0
    end
end

function ImGui.Render()
    -- Rendering is handled immediately in widget functions
end

return ImGui
