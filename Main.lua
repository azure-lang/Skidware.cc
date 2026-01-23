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
    fovcolor = Color3.new(1, 1, 1), 
    thickness = 1,
    fovfilled = false,
    aimpart = {"Head"},
    fov = false,
    fovsize = 100,
    downed = false,
    ff = false,
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
local meele = Tabs.main:AddRightGroupbox("Meele Aura")

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
    },
    MeeleAura = {
        Enabled = false,
        ShowAnim = false,
        Distance = 15,
        checkteam = false,
        checkdowned = false,
        targetparts = {"Head"},
        randomtime = 1
    }
}

local Settings = {
    checkDowned = false,
    wallCheck = false,
    hitlogEnabled = false,
    checkWhitelist = false,
    checkTarget = false,
    useFOV = false,
    teamCheck = false,
    fovRadius = 75,
    shootSpeed = 15,
    fireInterval = 0.17,
    maxDistance = 2000,
    bulletTracerEnabled = false,
    tracerColor = Color3.fromRGB(255, 0, 0),
    showFOV = false
}

local Events = ReplicatedStorage:WaitForChild("Events")
local GNX_S = Events:WaitForChild("GNX_S")
local ZFKLF__H = Events:WaitForChild("ZFKLF__H")

local WallbangSamples = 72
local WallbangRadius = 10
local WallbangHeight = 6
local NOTIFY_COOLDOWN = 0.35
local lastHitNotify = {}
local lastShotTime = 0

local function RandomString(len)
    local s = ""
    for i = 1, len do s = s .. string.char(math.random(97, 122)) end
    return s
end

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
        local center = UserInputService:GetMouseLocation()

        for _, a in pairs(Players:GetPlayers()) do
            if a ~= LocalPlayer and a.Character and a.Character:FindFirstChild("HumanoidRootPart") then
                if SectionSettings.SilentAim.CheckDowned and IsPlayerDowned(a) then continue end
                if SectionSettings.SilentAim.CheckTeam and a.Team == LocalPlayer.Team then continue end
                if SectionSettings.SilentAim.CheckFF and a.Character:FindFirstChildOfClass("ForceField") then continue end

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
    fovCircle.Thickness = functions.thickness
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
                    if functions.ff and p.Character:FindFirstChild("ForceField") then continue end
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

local function createTracer(startPos, endPos)
    if not Settings.bulletTracerEnabled then return end
    local tracer = Instance.new("Part")
    tracer.Anchored = true
    tracer.CanCollide = false
    tracer.Material = Enum.Material.Neon
    tracer.Color = Settings.tracerColor
    tracer.Shape = Enum.PartType.Cylinder
    local distance = (startPos - endPos).Magnitude
    tracer.Size = Vector3.new(distance, 0.12, 0.12)
    tracer.CFrame = CFrame.new((startPos + endPos) / 2, endPos) * CFrame.Angles(0, math.pi / 2, 0)
    tracer.Parent = Workspace
    task.spawn(function()
        for t = 0, 1, 0.02 do
            if tracer and tracer.Parent then
                tracer.Transparency = t
                task.wait(1/50)
            end
        end
        if tracer and tracer.Parent then tracer:Destroy() end
    end)
end

local function MakeRaycastParams()
    local rp = RaycastParams.new()
    rp.FilterType = Enum.RaycastFilterType.Exclude
    rp.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
    rp.IgnoreWater = true
    return rp
end

local function FindWallbangPoint(origin, targetPart)
    if not origin or not targetPart then return nil end
    local base = targetPart.Position
    local rp = MakeRaycastParams()
    for i = 1, WallbangSamples do
        local angle = (i / WallbangSamples) * math.pi * 2
        local r = WallbangRadius * (0.6 + math.random() * 0.8)
        local yOff = (math.random() * 2 - 1) * WallbangHeight
        local offset = Vector3.new(math.cos(angle) * r, yOff, math.sin(angle) * r)
        local testPoint = base + offset
        local dir = (testPoint - origin)
        if dir.Magnitude > 0 then
            local result = Workspace:Raycast(origin, dir, rp)
            if result then
                if result.Instance and result.Instance:IsDescendantOf(targetPart.Parent) then
                    return testPoint
                else
                    local distHitToTarget = (result.Position - base).Magnitude
                    if distHitToTarget <= 2.0 then
                        return testPoint
                    end
                end
            else
                return testPoint
            end
        end
    end
    return nil
end

local function GetClosestEnemy()
    local me = LocalPlayer.Character
    if not me or not me:FindFirstChild("HumanoidRootPart") then return nil end
    local closest, shortest = nil, math.huge
    local originPos = me.HumanoidRootPart.Position

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            if Settings.teamCheck and p.Team == LocalPlayer.Team then continue end
            if Settings.checkDowned and IsPlayerDowned(p) then continue end
            
            local head = p.Character:FindFirstChild("Head")
            if head then
                local dist3D = (originPos - head.Position).Magnitude
                if dist3D <= Settings.maxDistance then
                    local center = functions.SilentMiddle and Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2) or UserInputService:GetMouseLocation()
                    local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                    if onScreen then
                        local d2 = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                        if d2 <= (Settings.useFOV and Settings.fovRadius or math.huge) and d2 < shortest then
                            shortest = d2
                            closest = p
                        end
                    end
                end
            end
        end
    end
    return closest
end

local function Shoot(target)
    if not target or not target.Character then return end
    local head = target.Character:FindFirstChild("Head")
    local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
    if not head or not tool then return end
    
    local handle = tool:FindFirstChild("WeaponHandle")
    local origin = (handle and handle.Position) or Camera.CFrame.Position
    local aimPos = head.Position
    local dir = (aimPos - origin)
    local rp = MakeRaycastParams()

    local ray = Workspace:Raycast(origin, dir, rp)
    local lineOfSight = (not ray) or (ray.Instance and ray.Instance:IsDescendantOf(target.Character))

    local chosenAimPoint = aimPos
    local wallbangFound = false
    if not lineOfSight then
        local found = FindWallbangPoint(origin, head)
        if found then
            chosenAimPoint = found
            wallbangFound = true
        end
    end

    if not lineOfSight and Settings.wallCheck and not wallbangFound then
        return
    end

    local finalDir = (chosenAimPoint - origin).Unit
    local key = RandomString(30) .. "0"

    pcall(function() GNX_S:FireServer(tick(), key, tool, "FDS9I83", origin, {finalDir}, false) end)
    pcall(function() ZFKLF__H:FireServer("🧈", tool, key, 1, head, chosenAimPoint, finalDir) end)

    createTracer(origin, chosenAimPoint)

    if Settings.hitlogEnabled then
        local now = tick()
        if not lastHitNotify[target.UserId] or now - lastHitNotify[target.UserId] >= NOTIFY_COOLDOWN then
            lastHitNotify[target.UserId] = now
            StarterGui:SetCore("SendNotification", {Title = "RageBot Hit", Text = "Hit " .. target.Name, Duration = 2})
        end
    end
end

RunService.Heartbeat:Connect(function()
    if not functions.RageBot then return end
    local now = tick()
    if now - lastShotTime < Settings.fireInterval then return end
    
    local target = GetClosestEnemy()
    if target then
        Shoot(target)
        lastShotTime = now
    end
end)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local plrs = Players
local me = plrs.LocalPlayer
local run = RunService
local eventsFolder = ReplicatedStorage:WaitForChild("Events")

local AttachCD = {
    ["Fists"] = .05,
    ["Knuckledusters"] = .05,
    ["Nunchucks"] = 0.05,
    ["Shiv"] = .05,
    ["Bat"] = 1,
    ["Metal-Bat"] = 1,
    ["Chainsaw"] = 2.5,
    ["Balisong"] = .05,
    ["Rambo"] = .3,
    ["Shovel"] = 3,
    ["Sledgehammer"] = 2,
    ["Katana"] = .1,
    ["Wrench"] = .1,
    ["FireAxe"] = 2.6
}

local remoteFunctionPath = "XMHH.2"
local remoteEventPath = "XMHH2.2"   

local remote1 = eventsFolder:WaitForChild(remoteFunctionPath) 
local remote2 = eventsFolder:WaitForChild(remoteEventPath)   

local AttachTick = 0
local attachcd = 0.5

local MeleeAura_Connection

local function MeleeAura_Disable()
    SectionSettings.MeleeAura.Enabled = false
    if MeleeAura_Connection and MeleeAura_Connection.Connected then
        MeleeAura_Connection:Disconnect()
    end
    MeleeAura_Connection = nil
end

local function Attack(target)
    if not (target and target:FindFirstChild("Head")) then return end

    local mychar = me.Character
    if not mychar then return end
    local TOOL = mychar:FindFirstChildOfClass("Tool")
    if not TOOL then return end
    local targetpart = target:FindFirstChild(SectionSettings.MeeleAura.targetparts[1]) or target:FindFirstChild("Head")
    
    local hrp = mychar:FindFirstChild("HumanoidRootPart")
    local humanoid = mychar:FindFirstChildOfClass("Humanoid")
    if not hrp or not humanoid then return end

    local AnimFolder = TOOL:FindFirstChild("AnimsFolder")
    if not AnimFolder then return end
    local anim = AnimFolder:FindFirstChild("Slash1")
    if not anim then return end

    if tick() - AttachTick >= attachcd then
        AttachTick = tick()

        local success1, result = pcall(function()
            return remote1:InvokeServer("🍞", tick(), TOOL, "43TRFWX", "Normal", tick(), true)
        end)

        if not success1 then return end

        attachcd = AttachCD[TOOL.Name] or 1/2

        if SectionSettings.MeleeAura.ShowAnim then
            local animator = humanoid:FindFirstChild("Animator")
            if animator then
                local load = animator:LoadAnimation(anim)
                load:Play()
                load:AdjustSpeed(1.3)
            end
        end

        local Handle = TOOL:FindFirstChild("WeaponHandle") or TOOL:FindFirstChild("Handle") or mychar:FindFirstChild("Right Arm")

        if Handle and head and hrp then
            local arg2 = {
                [1] = "🍞",
                [2] = tick(),
                [3] = TOOL,
                [4] = "2389ZFX34",
                [5] = result,
                [6] = false,
                [7] = Handle,
                [8] = targetpart,
                [9] = target,
                [10] = hrp.Position,
                [11] = head.Position
            }

            pcall(function()
                remote2:FireServer(unpack(arg2))
            end)
        end

        task.wait(0.3 + math.random() * 0.2)
    end
end

local function runAttackLoop()
    return run.RenderStepped:Connect(function()
        if not SectionSettings.MeleeAura.Enabled then return end
        local char = me.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            for _, plr in ipairs(plrs:GetPlayers()) do
                if SectionSettings.MeeleAura.checkteam and plr.Team == me.Team then continue end
                if SectionSettings.MeeleAura.checkdowned and IsPlayerDowned(plr) then continue end
                if plr ~= me then
                    local c = plr.Character
                    local hrp2 = c and c:FindFirstChild("HumanoidRootPart")
                    local hum = c and c:FindFirstChildOfClass("Humanoid")
                    if hrp2 and hum then
                        local dist = (hrp.Position - hrp2.Position).Magnitude
                        if dist <= SectionSettings.MeleeAura.Distance then
                            Attack(c)
                        end
                    end
                end
            end
        end
    end)
end

local function MeleeAura_Enable()
    if SectionSettings.MeleeAura.Enabled then return end
    SectionSettings.MeleeAura.Enabled = true
    if MeleeAura_Connection and MeleeAura_Connection.Connected then
        MeleeAura_Connection:Disconnect()
    end
    MeleeAura_Connection = runAttackLoop()
end

local parts_list = {
    "Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg"
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

local random2Active = false
local function runRandomLoop2()
    if random2Active then return end
    random2Active = true
    while random2Active do
        local random2time = SectionSettings.MeeleAura.randomtime or 1
        local v3 = parts_list[math.random(1, #parts_list)]
        SectionSettings.MeeleAura.targetparts = {v3}
        task.wait(random2time)
    end
end

silent:AddToggle('v1', {
    Text = 'Toggle',
    Default = false,
    Callback = function(Value)
        functions.SilentAim = Value
        SectionSettings.SilentAim.Toggle = Value
        if Value then task.spawn(SetupSilentAim) end
    end
}):AddKeyPicker("silentkey", {
    Default = "None", SyncToggleState = true, Mode = "Toggle", Text = "Silent Aim Key", NoUI = false,
})

silent:AddToggle('v2', { Text = 'Check Team', Default = false, Callback = function(Value) SectionSettings.SilentAim.CheckTeam = Value end })
silent:AddToggle('v3_wall', { Text = 'Check Wall', Default = false, Callback = function(Value) SectionSettings.SilentAim.CheckWall = Value end })
silent:AddToggle('v4', { Text = 'Check Downed', Default = false, Callback = function(Value) SectionSettings.SilentAim.CheckDowned = Value end })
silent:AddToggle('v3_ff', { Text = 'Check Force Field', Default = false, Callback = function(Value) SectionSettings.SilentAim.CheckFF = Value end })

silent:AddDropdown('AimPartDropdown', {
    Values = { "Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg", "Random" },
    Default = 1, Multi = false, Text = 'Aim Parts',
    Callback = function(Value)
        if Value == "Random" then task.spawn(runRandomLoop) else randomActive = false SectionSettings.SilentAim.TargetParts = {Value} end
    end
})

silent:AddSlider('random_speed', {
    Text = 'Random Time', Default = 1, Min = 0.1, Max = 10, Rounding = 1, Compact = false,
    Callback = function(Value) SectionSettings.SilentAim.RandomTime = Value end
})

silent:AddToggle('v3_hit', { Text = 'Hit Chance', Default = false, Callback = function(Value) SectionSettings.SilentAim.HitChanceToggle = Value end })
silent:AddSlider('htchance amount', { Text = 'Hit Chance Amount', Default = 100, Min = 0, Max = 100, Rounding = 1, Compact = false, Callback = function(Value) SectionSettings.SilentAim.HitChance = Value end })

silent:AddToggle('v4_fov', {
    Text = 'Show FOV', Default = false,
    Callback = function(Value) SectionSettings.SilentAim.ShowFOV = Value end
}):AddColorPicker('fov color', {
    Default = Color3.new(1, 1, 1), Title = 'FOV Color', Transparency = 0,
    Callback = function(Value) SectionSettings.SilentAim.DrawColor = Value end
})

silent:AddToggle('v5', { Text = 'Filled', Default = false, Callback = function(Value) SectionSettings.SilentAim.Filled = Value end })
silent:AddSlider('fov size', { Text = 'FOV Size', Default = 100, Min = 0, Max = 500, Rounding = 1, Compact = false, Callback = function(Value) SectionSettings.SilentAim.DrawSize = Value end })
silent:AddSlider('thickness', { Text = 'Thickness', Default = 1, Min = 0, Max = 10, Rounding = 1, Compact = false, Callback = function(Value) SectionSettings.SilentAim.Thickness = Value end })

aimbot:AddToggle('aimbot', {
    Text = 'Toggle', Default = false,
    Callback = function(Value) functions.aimbot = Value end
}):AddKeyPicker("aimbotkey", {
    Default = "None", SyncToggleState = true, Mode = "Toggle", Text = "Aimbot Key", NoUI = false,
})

aimbot:AddToggle('aimbotteam', { Text = 'Check Team', Default = false, Callback = function(Value) functions.team = Value end })
aimbot:AddToggle('aimbotwall', { Text = 'Check Wall', Default = false, Callback = function(Value) functions.wall = Value end })
aimbot:AddToggle('aimbotdowned', { Text = 'Check Downed', Default = false, Callback = function(Value) functions.downed = Value end })
aimbot:AddToggle('aimbotff', { Text = 'Check Force Field', Default = false, Callback = function(Value) functions.ff = Value end })

aimbot:AddDropdown('AimPartDropdown1', {
    Values = { "Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg", "Random" },
    Default = 1, Multi = false, Text = 'Aim Parts',
    Callback = function(Value)
        if Value == "Random" then task.spawn(runRandomLoop1) else random1Active = false functions.aimpart = {Value} end
    end
})

aimbot:AddSlider('aimbotrand', {
    Text = 'Random Time', Default = 1, Min = 0, Max = 10, Rounding = 2, Compact = false,
    Callback = function(Value) functions.randomtime = Value end
})

aimbot:AddToggle('aimbotsmooth_t', { Text = 'Smooth', Default = false, Callback = function(Value) functions.smooth = Value end })
aimbot:AddSlider('aimbotsmooth_s', { Text = 'Smooth Amount', Default = 0.1, Min = 0, Max = 10, Rounding = 2, Compact = false, Callback = function(Value) functions.smoothsize = Value end })

aimbot:AddToggle('aimbotfov_t', {
    Text = 'FOV Circle', Default = false,
    Callback = function(Value) functions.fov = Value end
}):AddColorPicker('fov color aim', {
    Default = Color3.new(1, 1, 1), Title = 'FOV Color', Transparency = 0,
    Callback = function(Value) functions.fovcolor = Value end
})

aimbot:AddToggle('aimbotfov_f', { Text = 'Filled', Default = false, Callback = function(Value) functions.fovfilled = Value end })
aimbot:AddSlider('aimbotfov_s', { Text = 'FOV Size', Default = 100, Min = 0, Max = 500, Rounding = 2, Compact = false, Callback = function(Value) functions.fovsize = Value end })
aimbot:AddSlider('aimbotfov_y', { Text = 'Thickness', Default = 1, Min = 0, Max = 100, Rounding = 2, Compact = false, Callback = function(Value) functions.thickness = Value end })

rage:AddToggle('rage', { Text = 'Toggle', Default = false, Callback = function(Value) functions.RageBot = Value end })
rage:AddToggle('rageteamcheck', { Text = 'Check Team', Default = false, Callback = function(Value) Settings.checkTeam = Value end })
rage:AddToggle('ragewallcheck', { Text = 'Check Wall', Default = false, Callback = function(Value) Settings.checkWall = Value end })
rage:AddToggle('ragedownedcheck', { Text = 'Check Downed', Default = false, Callback = function(Value) Settings.checkDowned = Value end })
rage:AddToggle('rageteamcheck', { Text = 'Check Team', Default = false, Callback = function(Value) Settings.checkTeam = Value end })
rage:AddToggle('ragehitlog', { Text = 'Hit Log', Default = false, Callback = function(Value) Settings.hitlogEnabled = Value end })
rage:AddToggle('ragebulletracer', { Text = 'Bullet Tracer', Default = false, Callback = function(Value) Settings.bulletTracerEnabled = Value end })
rage:AddSlider('distance', { Text = 'Max Distance', Default = 500, Min = 0, Max = 2000, Rounding = 1, Compact = false, Callback = function(Value) Settings.maxDistance = Value end })
rage:AddSlider('shootspeed', { Text = 'Shoot Speed', Default = 15, Min = 0, Max = 100, Rounding = 2, Compact = false, Callback = function(Value) Settings.shootSpeed = Value end })
rage:AddSlider('fireinterval', { Text = 'Fire Interval', Default = 0.17, Min = 0, Max = 1, Rounding = 2, Compact = false, Callback = function(Value) Settings.fireInterval = Value end })

meele:AddToggle('meele', { Text = 'Toggle', Default = false, Callback = function(Value) SectionSettings.MeeleAura.Enabled = Value end })
meele:AddToggle('meeleshowanim', { Text = 'Show Animation', Default = false, Callback = function(Value) SectionSettings.MeeleAura.ShowAnim = Value end })
meele:AddToggle('meeleteam', { Text = 'Check Team', Default = false, Callback = function(Value) SectionSettings.MeeleAura.checkteam = Value end })
meele:AddToggle('meeledowned', { Text = 'Check Downed', Default = false, Callback = function(Value) SectionSettings.MeeleAura.checkdowned = Value end })

meele:AddDropdown('AimPartDropdown', {
    Values = { "Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg", "Random" },
    Default = 1, Multi = false, 
    Text = 'Aim Parts',
    Callback = function(Value)
        if Value == "Random" then task.spawn(runRandomLoop2) else random2Active = false SectionSettings.MeeleAura.targetparts = {Value} end
    end
})

meele:AddSlider('meelerandomtime', { Text = 'Random Time', Default = 1, Min = 0, Max = 10, Rounding = 2, Compact = false, Callback = function(Value) SectionSettings.MeeleAura.randomtime = Value end })
meele:AddSlider('meeledistance', { Text = 'Distance', Default = 15, Min = 0, Max = 100, Rounding = 2, Compact = false, Callback = function(Value) SectionSettings.MeeleAura.Distance = Value end })


local FPS = 60;

local WatermarkConnection = game:GetService('RunService').RenderStepped:Connect(function()
    FrameCounter += 1;

    if (tick() - FrameTimer) >= 1 then
        FPS = FrameCounter;
        FrameTimer = tick();
        FrameCounter = 0;
    end;

    Library:SetWatermark(('Skidware.cc | Crminality | %s fps | %s ms'):format(
        math.floor(FPS),
        math.floor(game:GetService('Stats').Network.ServerStatsItem['Data Ping']:GetValue())
    ));
end);

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ 'MenuKeybind' })
ThemeManager:SetFolder('MyScriptHub')
SaveManager:SetFolder('MyScriptHub/specific-game')
SaveManager:BuildConfigSection(Tabs['UI Settings'])
ThemeManager:ApplyToTab(Tabs['UI Settings'])
SaveManager:LoadAutoloadConfig()
