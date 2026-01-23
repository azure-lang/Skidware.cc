local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local camera = Workspace.CurrentCamera
local run = game:GetService("RunService")

local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'

local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

local functions = {
    SilentAim = false,
    aimbot = false,
    wall = false,
    smooth = false,
    smoothsize = 0.1,
    randomtime = 1,
    fovcolor = Color3.new(1, 1, 1)
    fovfilled = false,
    aimpart = {"Head"},
    fov = false,
    fovsize = 100,
    downed = false,
    team = false,
    RageBot = false
}

local cockie = {
    SilentAimCircle = nil
}

local window = Library:CreateWindow({
    Title = 'Skidware.cc',
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0.2
})

local Tabs = {
    main = window:AddTab("Combat"),
    visuals = window:AddTab("Visuals"),
    player = window:AddTab("Player"),
    gun = window:AddTab("Gun Mods"),
    ["UI Settings"] = window:AddTab("Settings")
}

local silent = Tabs.main:AddLeftGroupbox("Silent Aim")
local aimbot = Tabs.main:AddRightGroupbox('Aimbot')
local rage = Tabs.main:AddLeftGroupbox("Rage Bot")

local SectionSettings = {
    SilentAim = {
        Toggle = false,
        ShowFOV = false,
        DrawSize = 130,
        DrawColor = Color3.new(1, 1, 1),
        Thickness = 1,
        TargetParts = {"Head"},
        CheckDowned = false,
        CheckWall = false,
        CheckFF = false,
        CheckTeam = false,
        CheckWhiteList = false,
        HitChance = 100,
        HitChanceToggle = false,
        Filled = false,
        RandomTime = 1
    }
}

local Events = ReplicatedStorage:WaitForChild("Events")
local GNX_S = Events:WaitForChild("GNX_S")
local ZFKLF__H = Events:WaitForChild("ZFKLF__H")

local function IsPlayerDowned(p)
    if not p or not p.Character then return false end
    local hum = p.Character:FindFirstChildOfClass("Humanoid")
    if hum and hum.Health <= 15 then return true end
    
    local cs = p.Character:FindFirstChild("CharStats")
    if cs then
        local downed = cs:FindFirstChild("Downed")
        if downed and typeof(downed.Value) == "boolean" then
            return downed.Value
        end
    end
    return false
end

local function SetupSilentAim()
    if cockie.SilentAimCircle then cockie.SilentAimCircle:Remove() end
    
    cockie.SilentAimCircle = Drawing.new("Circle")
    cockie.SilentAimCircle.Color = SectionSettings.SilentAim.DrawColor
    cockie.SilentAimCircle.Thickness = SectionSettings.SilentAim.Thickness
    cockie.SilentAimCircle.NumSides = 50
    cockie.SilentAimCircle.Radius = SectionSettings.SilentAim.DrawSize
    cockie.SilentAimCircle.Filled = SectionSettings.SilentAim.Filled
    cockie.SilentAimCircle.Visible = false

    local target = nil
    local VisualizeEvent = ReplicatedStorage:WaitForChild("Events2"):WaitForChild("Visualize")

    local function GetClosest()
        target = nil
        local shortest = SectionSettings.SilentAim.ShowFOV and SectionSettings.SilentAim.DrawSize or math.huge
        local center = functions.SilentMiddle and Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2) or UserInputService:GetMouseLocation()

        for _, a in pairs(Players:GetPlayers()) do
            if a ~= LocalPlayer and a.Character and a.Character:FindFirstChild("HumanoidRootPart") then
                if SectionSettings.SilentAim.CheckDowned and IsPlayerDowned(a) then continue end
                if SectionSettings.SilentAim.CheckTeam and a.Team == LocalPlayer.Team then continue end

                local hrp = a.Character.HumanoidRootPart
                local screenpos, onScreen = Camera:WorldToViewportPoint(hrp.Position)

                if onScreen then
                    local dist = (center - Vector2.new(screenpos.X, screenpos.Y)).Magnitude
                    if dist < shortest then
                        shortest = dist
                        target = a
                    end
                end
            end
        end
    end

    RunService.RenderStepped:Connect(function()
        if cockie.SilentAimCircle then
            local pos = UserInputService:GetMouseLocation()
            cockie.SilentAimCircle.Visible = functions.SilentAim and SectionSettings.SilentAim.ShowFOV
            cockie.SilentAimCircle.Radius = SectionSettings.SilentAim.DrawSize
            cockie.SilentAimCircle.Thickness = SectionSettings.SilentAim.Thickness
            cockie.SilentAimCircle.Filled = SectionSettings.SilentAim.Filled
            cockie.SilentAimCircle.Color = SectionSettings.SilentAim.DrawColor
            cockie.SilentAimCircle.Position = pos
        end
        if functions.SilentAim then
            GetClosest()
        end
    end)

    VisualizeEvent.Event:Connect(function(_, ShotCode, _, Gun, _, StartPos, BulletsPerShot)
        if not functions.SilentAim or not target or not target.Character then return end
        if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChildOfClass("Tool") then return end

        if SectionSettings.SilentAim.HitChanceToggle then
            if math.random(1, 100) > SectionSettings.SilentAim.HitChance then return end
        end

        local possibleParts = SectionSettings.SilentAim.TargetParts
        local parts_name = possibleParts[1] or "Head"
        local targetPart = target.Character:FindFirstChild(parts_name)
        
        if targetPart then
            local partPos = targetPart.Position
            local bulletCount = type(BulletsPerShot) == "table" and #BulletsPerShot or 1
            
            task.wait(0.005)
            for i = 1, math.clamp(bulletCount, 1, 100) do
                local dir = (partPos - StartPos).Unit
                ZFKLF__H:FireServer("🧈", Gun, ShotCode, i, targetPart, partPos, dir)
            end

            if Gun:FindFirstChild("Hitmarker") then
                Gun.Hitmarker:Fire(targetPart)
            end
        end
    end)
end

local fovCircle = Drawing.new("Circle")
fovCircle.NumSides = 50
fovCircle.Filled = false
fovCircle.Visible = false

run.RenderStepped:Connect(function()
    local pos = UserInputService:GetMouseLocation()
    fovCircle.Visible = functions.fov
    fovCircle.Radius = functions.fovsize
    fovCircle.Color = functions.fovcolor
    fovCircle.Filled = functions.fovfilled
    fovCircle.Position = pos
end)


local function aimbotLoop()
    while true do 
        if functions.aimbot then
            local character = LocalPlayer.Character
            if character and character:FindFirstChild('Head') then
                local targetPart = nil
                local shortestDistance = functions.fovsize
                local center = UserInputService:GetMouseLocation()
                
                for _, p in pairs(Players:GetPlayers()) do
                    if functions.team and p.Team == LocalPlayer.Team then continue end
                    if functions.downed and IsPlayerDowned(p) then continue end
                    local bodyPartName = functions.aimpart and functions.aimpart[1] or "Head"
                    if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild(bodyPartName) then
                        local partToAim = p.Character[bodyPartName]
                        local pos, onscreen = camera:WorldToViewportPoint(partToAim.Position)
                        if onscreen then
                            local mousedistance = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                            if mousedistance <= functions.fovsize then
                                local cansee = true
                                if functions.wall then
                                    local rayParams = RaycastParams.new()
                                    rayParams.FilterDescendantsInstances = {character, camera}
                                    rayParams.FilterType = Enum.RaycastFilterType.Exclude
                                    local rayResult = Workspace:Raycast(camera.CFrame.Position, (partToAim.Position - camera.CFrame.Position), rayParams)
                                    if rayResult and not rayResult.Instance:IsDescendantOf(p.Character) then cansee = false end
                                end
                                if cansee and mousedistance < shortestDistance then
                                    shortestDistance = mousedistance
                                    targetPart = partToAim
                                end
                            end
                        end
                    end
                end
                if targetPart then
                    local goal = CFrame.new(camera.CFrame.Position, targetPart.Position)
                    camera.CFrame = functions.smooth and camera.CFrame:Lerp(goal, functions.smoothsize/100) or goal
                end
            end
        end
        task.wait()
    end
end
task.spawn(aimbotLoop)

local parts_list = {
    "Head",
    "Torso",
    "Left Arm",
    "Right Arm",
    "Left Leg",
    "Right Leg"
}

local randomActive = false
local function runRandomLoop()
    if randomActive then return end
    randomActive = true
    while randomActive do
        local randomtime = SectionSettings.SilentAim.RandomTime or 1
        local v1 = parts_list[math.random(1, #parts_list)]
        SectionSettings.SilentAim.TargetParts = {v1}
        task.wait(randomtime)
    end
end

local random1Active = false
local function runRandomLoop1()
    if random1Active then return end
    random1Active = true
    while random1Active do
        local random1time = functions.randomtime or 1
        local v2 = parts_list[math.random(1, #parts_list)]
        functions.aimpart = {v2}
        task.wait(random1time)
    end
end

silent:AddToggle('v1', {
    Text = 'Toggle',
    Default = false,
    Callback = function(Value)
        functions.SilentAim = Value
        SectionSettings.SilentAim.Toggle = Value
        if Value then
            task.spawn(SetupSilentAim)
        end
    end
}):AddKeyPicker("silentkey", {
    Default = "None",
    SyncToggleState = true,
    Mode = "Toggle",
    Text = "Silent Aim Key",
    NoUI = false,
})

silent:AddToggle('v2', {
    Text = 'Check Team',
    Default = false,
    Callback = function(Value)
        SectionSettings.SilentAim.CheckTeam = Value
    end
})

silent:AddToggle('v3_wall', {
    Text = 'Check Wall',
    Default = false,
    Callback = function(Value)
        SectionSettings.SilentAim.CheckWall = Value
    end
})

silent:AddToggle('v4', {
    Text = 'Check Downed',
    Default = false ,
    Callback = function(Value)
        SectionSettings.SilentAim.CheckDowned = Value
    end
})

silent:AddToggle('v3_ff', {
    Text = 'Check Force Field',
    Default = false,
    Callback = function(Value)
        SectionSettings.SilentAim.CheckFF = Value
    end
})

silent:AddDropdown('AimPartDropdown', {
    Values = { "Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg", "Random" },
    Default = 1,
    Multi = false,
    Text = 'Aim Parts',
    Callback = function(Value)
        if Value == "Random" then
            task.spawn(runRandomLoop)
        else
            randomActive = false
            SectionSettings.SilentAim.TargetParts = {Value}
        end
    end
})

silent:AddSlider('random_speed', {
    Text = 'Random Time',
    Default = 1,
    Min = 0.1,
    Max = 10,
    Rounding = 1,
    Compact = false,
    Callback = function(Value)
        SectionSettings.SilentAim.RandomTime = Value
    end
})

silent:AddToggle('v3_hit', {
    Text = 'Hit Chance',
    Default = false,
    Callback = function(Value)
        SectionSettings.SilentAim.HitChanceToggle = Value
    end
})

silent:AddSlider('htchance amount', {
    Text = 'Hit Chance Amount',
    Default = 100,
    Min = 0,
    Max = 100,
    Rounding = 1,
    Compact = false,
    Callback = function(Value)
        SectionSettings.SilentAim.HitChance = Value
    end
})

silent:AddToggle('v4_fov', {
    Text = 'Show FOV',
    Default = false,
    Callback = function(Value)
        SectionSettings.SilentAim.ShowFOV = Value
    end
}):AddColorPicker('fov color', {
    Default = Color3.new(1, 1, 1),
    Title = 'FOV Color',
    Transparency = 0,
    Callback = function(Value)
        SectionSettings.SilentAim.DrawColor = Value
    end
})

silent:AddToggle('v5', {
    Text = 'Filled',
    Default = false,
    Callback = function(Value)
        SectionSettings.SilentAim.Filled = Value
    end
})

silent:AddSlider('fov size', {
    Text = 'FOV Size',
    Default = 100,
    Min = 0,
    Max = 500,
    Rounding = 1,
    Compact = false,
    Callback = function(Value)
        SectionSettings.SilentAim.DrawSize = Value
    end
})

silent:AddSlider('thickness', {
    Text = 'Thickness',
    Default = 1,
    Min = 0,
    Max = 10,
    Rounding = 1,
    Compact = false,
    Callback = function(Value)
        SectionSettings.SilentAim.Thickness = Value
    end
})

aimbot:AddToggle('aimbot', {
    Text = 'Toggle',
    Default = false,
    Callback = function(Value)
        functions.aimbot = Value
    end
}):AddKeyPicker("aimbotkey", {
    Default = "None",
    SyncToggleState = true,
    Mode = "Toggle",
    Text = "Aimbot Key",
    NoUI = false,
})

aimbot:AddToggle('aimbotteam', {
    Text = 'Check Team',
    Default = false,
    Callback = function(Value)
        functions.team = Value
    end
})

aimbot:AddToggle('aimbotwall', {
    Text = 'Check Wall',
    Default = false,
    Callback = function(Value)
        functions.wall = Value
    end
})

aimbot:AddToggle('aimbotdowned', {
    Text = 'Check Downed',
    Default = false,
    Callback = function(Value)
        functions.downed = Value
    end
})

aimbot:AddToggle('aimbotdowned', {
    Text = 'Check Downed',
    Default = false,
    Callback = function(Value)
        functions.downed = Value
    end
})

aimbot:AddDropdown('AimPartDropdown1', {
    Values = { "Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg", "Random" },
    Default = 1,
    Multi = false,
    Text = 'Aim Parts',
    Callback = function(Value)
        if Value == "Random" then
            task.spawn(runRandomLoop1)
        else
            random1Active = false
            functions.aimpart = {Value}
        end
    end
})

aimbot:AddSlider('aimbotsmooth', {
    Text = 'Random Time',
    Default = 1,
    Min = 0,
    Max = 10,
    Rounding = 2,
    Compact = false,
    Callback = function(Value)
        functions.randomtime = Value
    end
})

aimbot:AddToggle('aimbotsmooth', {
    Text = 'Smooth',
    Default = false,
    Callback = function(Value)
        functions.smooth = Value
    end
})

aimbot:AddSlider('aimbotsmooth', {
    Text = 'Smooth Amount',
    Default = 0.1,
    Min = 0,
    Max = 10,
    Rounding = 2,
    Compact = false,
    Callback = function(Value)
        functions.smoothsize = Value
    end
})

aimbot:AddToggle('aimbotsmooth', {
    Text = 'FOV Circle',
    Default = false,
    Callback = function(Value)
        functions.fov = Value
    end
}):AddColorPicker('fov color', {
    Default = Color3.new(1, 1, 1),
    Title = 'FOV Color',
    Transparency = 0,
    Callback = function(Value)
        functions.fovcolor = Value
    end
})

aimbot:AddToggle('aimbotsmooth', {
    Text = 'Filled',
    Default = false,
    Callback = function(Value)
        functions.fovfilled = Value
    end
})

aimbot:AddSlider('aimbotsmooth', {
    Text = 'FOV Size',
    Default = 100,
    Min = 0,
    Max = 500,
    Rounding = 2,
    Compact = false,
    Callback = function(Value)
        functions.fovsize = Value
    end
})
