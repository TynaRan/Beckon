local lib=loadstring(game:HttpGet("https://raw.githubusercontent.com/TynaRan/Beckon/refs/heads/main/src.lua"))()
local win=lib:Create("AimViewer V1","ProVersion")
local userTab=win:tab("User",true)
local playerTab=win:tab("Player",true)
local aimTab=win:tab("Aiming",true)
local visualTab=win:tab("Visual",true)
local configTab=win:tab("ConfigManager",true)
local function generateUID()
    return string.format("%016d",tick()%10^16)
end
userTab:label("UID_"..generateUID())
userTab:label("Name: "..game.Players.LocalPlayer.Name)
userTab:label("Creator:APizzaOne")
local configFile="aimviewer_config.json"

local function hasTeamSystem()
    return #game:GetService("Teams"):GetTeams()>0
end

local function loadConfig()
    local success,data=pcall(function()
        return game:GetService("HttpService"):JSONDecode(readfile(configFile))
    end)
    return success and data or{}
end

local function saveConfig(config)
    writefile(configFile,game:GetService("HttpService"):JSONEncode(config))
end

local config=loadConfig()
local aimbotEnabled=config.aimbotEnabled or false
local teamCheck=config.teamCheck or false
local fovSize=config.fovSize or 150
local showFOV=config.showFOV or false
local cycleColors=config.cycleColors or false
local colorSpeed=config.colorSpeed or 1
local aliveCheck=config.aliveCheck or true
local visibilityCheck=config.visibilityCheck or true
local visualEnabled=config.visualEnabled or true
local highlightColor=config.highlightColor or "255,255,255"
local effectTransparency=config.effectTransparency or 0.5
local visualTeamCheck=config.visualTeamCheck or false
local teamColorCheck=config.teamColorCheck or false
local playerSpeed=config.playerSpeed or 16
local customFOV=config.customFOV or 70
local customGravity=config.customGravity or 196.2
local loopEnabled=config.loopEnabled or false
local fullbrightEnabled=config.fullbrightEnabled or false
playerTab:input("MoveSpeed",tostring(playerSpeed),true,function(v)
    local num=tonumber(v)
    if num then
        playerSpeed=num
        config.playerSpeed=num
        saveConfig(config)
    end
end)

playerTab:input("CustomFOV",tostring(customFOV),true,function(v)
    local num=tonumber(v)
    if num then
        customFOV=num
        config.customFOV=num
        saveConfig(config)
    end
end)

playerTab:input("Gravity",tostring(customGravity),true,function(v)
    local num=tonumber(v)
    if num then
        customGravity=num
        config.customGravity=num
        saveConfig(config)
    end
end)

playerTab:toggle("LOOP_MODE",loopEnabled,function(v)
    loopEnabled=v
    config.loopEnabled=v
    saveConfig(config)
end)

playerTab:toggle("FULLBRIGHT",fullbrightEnabled,function(v)
    fullbrightEnabled=v
    config.fullbrightEnabled=v
    saveConfig(config)
end)

game:GetService("RunService").RenderStepped:Connect(function()
    if game.Players.LocalPlayer.Character then
        local humanoid=game.Players.LocalPlayer.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.WalkSpeed=loopEnabled and playerSpeed or 16
        end
    end
    
    workspace.CurrentCamera.FieldOfView=customFOV
    workspace.Gravity=loopEnabled and customGravity or 196.2
    
    if fullbrightEnabled then
        game:GetService("Lighting").Brightness=2
        game:GetService("Lighting").ClockTime=14
        game:GetService("Lighting").FogEnd=9e9
    end
end)
aimTab:toggle("EnableAimbot",aimbotEnabled,function(v)
    aimbotEnabled=v
    config.aimbotEnabled=v
    saveConfig(config)
end)
aimTab:toggle("TeamCheck",teamCheck,function(v)
    teamCheck=v
    config.teamCheck=v
    saveConfig(config)
end)
aimTab:input("FOVSize",tostring(fovSize),true,function(v)
    fovSize=tonumber(v)
    config.fovSize=fovSize
    saveConfig(config)
end)
aimTab:toggle("ShowFOV",showFOV,function(v)
    showFOV=v
    config.showFOV=v
    saveConfig(config)
end)
aimTab:toggle("ColorCycle",cycleColors,function(v)
    cycleColors=v
    config.cycleColors=v
    saveConfig(config)
end)
aimTab:input("ColorSpeed",tostring(colorSpeed),true,function(v)
    colorSpeed=tonumber(v)
    config.colorSpeed=colorSpeed
    saveConfig(config)
end)
aimTab:toggle("AliveCheck",aliveCheck,function(v)
    aliveCheck=v
    config.aliveCheck=v
    saveConfig(config)
end)
aimTab:toggle("VisibilityCheck",visibilityCheck,function(v)
    visibilityCheck=v
    config.visibilityCheck=v
    saveConfig(config)
end)

visualTab:toggle("EnableVisuals",visualEnabled,function(v)
    visualEnabled=v
    config.visualEnabled=v
    saveConfig(config)
end)
if hasTeamSystem() then
    visualTab:toggle("VisualTeamCheck",visualTeamCheck,function(v)
        visualTeamCheck=v
        config.visualTeamCheck=v
        saveConfig(config)
    end)
    visualTab:toggle("TeamColorCheck",teamColorCheck,function(v)
        teamColorCheck=v
        config.teamColorCheck=v
        saveConfig(config)
    end)
end
visualTab:input("HighlightColor",highlightColor,true,function(v)
    highlightColor=v
    config.highlightColor=v
    saveConfig(config)
end)
visualTab:input("EffectTransparency",tostring(effectTransparency),true,function(v)
    effectTransparency=tonumber(v)
    config.effectTransparency=effectTransparency
    saveConfig(config)
end)

configTab:button("SaveConfig",function()
    saveConfig(config)
end)
configTab:button("LoadConfig",function()
    config=loadConfig()
    aimbotEnabled=config.aimbotEnabled or false
    teamCheck=config.teamCheck or false
    fovSize=config.fovSize or 150
    showFOV=config.showFOV or false
    cycleColors=config.cycleColors or false
    colorSpeed=config.colorSpeed or 1
    aliveCheck=config.aliveCheck or true
    visibilityCheck=config.visibilityCheck or true
    visualEnabled=config.visualEnabled or true
    highlightColor=config.highlightColor or "255,255,255"
    effectTransparency=config.effectTransparency or 0.5
    visualTeamCheck=config.visualTeamCheck or false
    teamColorCheck=config.teamColorCheck or false
end)

local fovCircle=Drawing.new("Circle")
fovCircle.Visible=false
fovCircle.Radius=fovSize
fovCircle.Color=Color3.new(1,1,1)
fovCircle.Thickness=2
fovCircle.Filled=false
fovCircle.Position=Vector2.new(workspace.CurrentCamera.ViewportSize.X/2,workspace.CurrentCamera.ViewportSize.Y/2)

local highlight=Instance.new("Highlight")
highlight.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
highlight.FillTransparency=effectTransparency

local function getTeamColor(player)
    if not hasTeamSystem() then return Color3.new(1,1,1) end
    return player.Team and player.Team.TeamColor.Color or Color3.new(1,1,1)
end

local function isVisible(targetPart)
    if not visibilityCheck then return true end
    local camera=workspace.CurrentCamera
    local origin=camera.CFrame.Position
    local raycastParams=RaycastParams.new()
    raycastParams.FilterDescendantsInstances={game.Players.LocalPlayer.Character,targetPart.Parent}
    raycastParams.FilterType=Enum.RaycastFilterType.Blacklist
    local raycastResult=workspace:Raycast(origin,targetPart.Position-origin,raycastParams)
    return not raycastResult or raycastResult.Instance:IsDescendantOf(targetPart.Parent)
end

local function findClosestTarget()
    local players=game:GetService("Players"):GetPlayers()
    local closest,minDist=nil,fovSize
    local localPlayer=game.Players.LocalPlayer
    local localChar=localPlayer.Character
    local localRoot=localChar and localChar:FindFirstChild("HumanoidRootPart")
    if not localRoot then return nil end
    
    for _,player in pairs(players) do
        if player==localPlayer then continue end
        if teamCheck and player.Team==localPlayer.Team then continue end
        local character=player.Character
        if not character then continue end
        if aliveCheck then
            local humanoid=character:FindFirstChild("Humanoid")
            if not humanoid or humanoid.Health<=0 then continue end
        end
        local rootPart=character:FindFirstChild("HumanoidRootPart")
        if not rootPart then continue end
        if visibilityCheck and not isVisible(rootPart) then continue end
        local distance=(localRoot.Position-rootPart.Position).Magnitude
        if distance<minDist then
            minDist=distance
            closest=rootPart
        end
    end
    return closest
end

local colorHue=0
game:GetService("RunService").RenderStepped:Connect(function()
    fovCircle.Radius=fovSize
    fovCircle.Visible=showFOV
    if cycleColors then
        colorHue=(tick()*colorSpeed)%1
        fovCircle.Color=Color3.fromHSV(colorHue,1,1)
    else
        fovCircle.Color=Color3.new(1,1,1)
    end
    
    if aimbotEnabled then
        local target=findClosestTarget()
        if target then
            workspace.CurrentCamera.CFrame=CFrame.new(workspace.CurrentCamera.CFrame.Position,target.CFrame.Position)
            if visualEnabled then
                local player=game:GetService("Players"):GetPlayerFromCharacter(target.Parent)
                highlight.Parent=target.Parent
                highlight.Adornee=target.Parent
                
                if hasTeamSystem() and visualTeamCheck and teamColorCheck and player then
                    highlight.FillColor=getTeamColor(player)
                else
                    local rgb=highlightColor:split(",")
                    highlight.FillColor=Color3.new(rgb[1]/255,rgb[2]/255,rgb[3]/255)
                end
            else
                highlight.Parent=nil
            end
        else
            highlight.Parent=nil
        end
    else
        highlight.Parent=nil
    end
end)
-- ========================
--        CHAT SPY
-- ========================
local chatLogs = {}
local chatSpyEnabled = false
local chatHook

local function createChatSpyTab()
    local chatTab = win:tab("ChatSpy", false)
    local chatLogDisplay = chatTab:label("Chat Logs will here")
    local chatLogContent = ""
    
    chatTab:toggle("Enable ChatSpy", false, function(state)
        chatSpyEnabled = state
        if state then
            chatHook = game:GetService("Players").PlayerChatted:Connect(function(player, message)
                local logEntry = string.format("[%s]: %s\n", player.Name, message)
                table.insert(chatLogs, logEntry)
                chatLogContent = chatLogContent .. logEntry
                chatLogDisplay:set("Chat Logs:\n"..chatLogContent)
            end)
        else
            if chatHook then
                chatHook:Disconnect()
            end
        end
    end)
    
    chatTab:button("Clear Logs", function()
        chatLogs = {}
        chatLogContent = ""
        chatLogDisplay:set("Chat Logs cleared")
    end)
    
    chatTab:button("Copy to Clipboard", function()
        setclipboard(table.concat(chatLogs, "\n"))
    end)
end

createChatSpyTab()
