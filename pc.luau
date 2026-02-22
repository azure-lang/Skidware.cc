local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local me = Players.LocalPlayer
local plrs = game:GetService("Players")
local Camera = Workspace.CurrentCamera
local camera = Workspace.CurrentCamera
local run = game:GetService("RunService")

local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'

local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

local window = Library:CreateWindow({
    Title = "Skidware.cc"
})

local tabs = {
    main = window:AddTab("Combat"),
    visuals = window:AddTab("Visuals"),
	player = window:AddTab("Player"),
    settings = window:AddTab("Settings")
}

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
	meleeauraF = false,
	invisible = false,
    RageBot = false
}

local Meele = {
    Toggle = false,
    Team = false,
    Downed = false,
    FF = false,
    Anim = false,
    Target = {"Head"},
    Distance = 15,
	Randomtime = 1
}

local cockie = {
    SilentAimCircle = nil
}

local ZFKLF__H = game:GetService('ReplicatedStorage').Events:FindFirstChild('ZFKLF__H')

local vis = tabs.visuals:AddLeftGroupbox("Player Visuals")
local silent = tabs.main:AddLeftGroupbox("Silent Aim")
local aimbot = tabs.main:AddRightGroupbox("Aimbot")
local rage = tabs.main:AddLeftGroupbox("Rage Bot")
local meele = tabs.main:AddRightGroupbox("Meele Aura")
local plrc = tabs.player:AddLeftGroupbox("Player Modifications")
local viss = tabs.visuals:AddRightGroupbox("Player Visuals Settings")
local visw = tabs.visuals:AddRightGroupbox("World Visuals")
local visp = tabs.visuals:AddLeftGroupbox('View Model Visuals')


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

local rep = game:GetService("ReplicatedStorage")
local events = rep:WaitForChild("Events")
local mouse = me:GetMouse()

local settings = {
    ragebot = false,
    checkdowned = false,
    checkteam = false,
    checkwall = false,
    distance = 1000,
    fireinterval = 0.1,
    shootspeed = 1,
    hitlog = false,
    sound = false,
    selected_sound = '92570611018210',
    CheckWhiteList = false,
    bulletTracerEnabled = false,
    tracerColor = Color3.new(1, 1, 1)
}

local sounds = {
    ['Rust'] = 92570611018210,
    ['Skeet'] = 83717596220569,
    ['Neverlose'] = 6607204501,
    ['Minecraft'] = 136876055001267,
    ['Headshot'] = 140572774008234
}

local lastshottime = 0
local whitelist = {}
local WallbangSamples = 72
local WallbangRadius = 10
local WallbangHeight = 6

local function RandomString(length)
    local res = ""
    for i = 1, length do
        res = res .. string.char(math.random(97, 122))
    end
    return res
end

local function SendHitLog(targetName, bodyPart, distance)
    if not settings.hitlog then return end
    local message = string.format("Hit %s on %s, %.1f studs", targetName, bodyPart, distance)
    Library:Notify(message, 4)
end

local function createSound()
    if not settings.sound then return end
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://" .. settings.selected_sound
    sound.Volume = 1
    sound.Parent = camera
    sound:Play()
    sound.Ended:Connect(function()
        sound:Destroy()
    end)
end

local function createTracer(startPos, endPos)
    if not settings.bulletTracerEnabled then return end
    local att0 = Instance.new("Attachment")
    att0.WorldPosition = startPos
    att0.Parent = workspace.Terrain
    local att1 = Instance.new("Attachment")
    att1.WorldPosition = endPos
    att1.Parent = workspace.Terrain
    local beam = Instance.new("Beam")
    beam.Texture = "rbxassetid://7136858729"
    beam.TextureMode = Enum.TextureMode.Stretch
    beam.FaceCamera = true
    beam.LightInfluence = 0
    beam.Width0 = 0.8
    beam.Width1 = 0.8
    beam.Attachment0 = att0
    beam.Attachment1 = att1
    beam.Color = ColorSequence.new(settings.tracerColor)
    beam.Parent = workspace.Terrain
    task.spawn(function()
        for t = 0, 1, 0.05 do
            if beam and beam.Parent then beam.Transparency = NumberSequence.new(t) end
            task.wait(0.03)
        end
        if beam then beam:Destroy() end
        if att0 then att0:Destroy() end
        if att1 then att1:Destroy() end
    end)
end

local function MakeRaycastParams()
    local rp = RaycastParams.new()
    rp.FilterType = Enum.RaycastFilterType.Exclude
    rp.FilterDescendantsInstances = {me.Character, camera}
    rp.IgnoreWater = true
    return rp
end

local function FindWallbangPoint(origin, targetPart)
    if not origin or not targetPart then return nil end
    local base = targetPart.Position
    local rp = MakeRaycastParams()
    local MaxDistance = 10000

    for i = 1, WallbangSamples do
        local angle = (i / WallbangSamples) * math.pi * 2
        local r = WallbangRadius * (0.6 + math.random())
        local yOff = (math.random() * 2 - 1) * WallbangHeight
        local offset = Vector3.new(math.cos(angle) * r, yOff, math.sin(angle) * r)
        local testPoint = base + offset
        local dir = (testPoint - origin)
        
        if dir.Magnitude > 0 then
            local extendedDir = dir.Unit * MaxDistance
            local result = workspace:Raycast(origin, extendedDir, rp)
            
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
    if not me.Character or not me.Character:FindFirstChild("HumanoidRootPart") then return nil end
    local closestEnemy, shortestDistance = nil, math.huge
    local myRootPos = me.Character.HumanoidRootPart.Position
    
    for _, player in pairs(plrs:GetPlayers()) do
        if player == me or (settings.checkteam and player.Team == me.Team) then continue end
        local character = player.Character
        if not character or not character:FindFirstChild("Humanoid") then continue end
        if settings.checkdowned and character.Humanoid.Health <= 15 then continue end
        
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if rootPart and character:FindFirstChildOfClass("Humanoid").Health > 15 then
            if settings.CheckWhiteList and table.find(whitelist, player) then continue end
            
            local screenPos, onScreen = camera:WorldToViewportPoint(rootPart.Position)
            if onScreen then
                local mouseDistance = (Vector2.new(mouse.X, mouse.Y) - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
                if mouseDistance < shortestDistance then
                    local worldDist = (rootPart.Position - myRootPos).Magnitude
                    if worldDist < settings.distance then
                        shortestDistance = mouseDistance
                        closestEnemy = player
                    end
                end
            end
        end
    end
    return closestEnemy
end

local function Shoot(target)
    if not target or not target.Character then return end
    local head = target.Character:FindFirstChild("Head")
    local myRoot = me.Character:FindFirstChild("HumanoidRootPart")
    if not head or not myRoot then return end
    local tool = me.Character:FindFirstChildOfClass("Tool")
    if not tool then return end
    local values = tool:FindFirstChild("Values")
    local ammo = values and values:FindFirstChild("SERVER_Ammo")
    if not ammo or ammo.Value <= 0 then return end

    local originPos = camera.CFrame.Position
    local aimPos = head.Position
    local rp = MakeRaycastParams()
    local ray = workspace:Raycast(originPos, (aimPos - originPos), rp)
    local los = (not ray) or (ray.Instance and ray.Instance:IsDescendantOf(target.Character))

    local chosenPoint = aimPos
    local wallbangFound = false

    if not los then
        local found = FindWallbangPoint(originPos, head)
        if found then
            chosenPoint = found
            wallbangFound = true
        end
    end

    if not los and settings.checkwall and not wallbangFound then return end

    local hitDirection = (chosenPoint - originPos).Unit
    local randomKey = RandomString(30) .. "0"
    local distToPlayer = (myRoot.Position - head.Position).Magnitude

    createSound()
    createTracer(originPos, chosenPoint)
    SendHitLog(target.Name, head.Name, distToPlayer)

    events.GNX_S:FireServer(tick(), randomKey, tool, "FDS9I83", originPos, {hitDirection}, false)

    task.delay(0.00001, function()
        events["ZFKLF__H"]:FireServer("🧈", tool, randomKey, 1, head, chosenPoint, hitDirection)
        ammo.Value = math.max(ammo.Value - 1, 0)
        local hitMarker = tool:FindFirstChild("Hitmarker") or tool:FindFirstChild("HitMarker")
        if hitMarker then hitMarker:Fire(head) end
        events.GNX_R:FireServer(tick(), "KLWE89U0", tool)
    end)
end

local soundList = {}
for name, _ in pairs(sounds) do table.insert(soundList, name) end

run.Heartbeat:Connect(function()
    if not settings.ragebot then return end
    if me.Character and me.Character:FindFirstChildOfClass("Tool") then
        local now = tick()
        if now - lastshottime < settings.fireinterval then return end
        local target = GetClosestEnemy()
        if target then
            for i = 1, settings.shootspeed do
                Shoot(target)
            end
            lastshottime = now
        end
    end
end)

local plrs = game:GetService("Players")
local me = plrs.LocalPlayer
local run = game:GetService("RunService")
local rp = game:GetService("ReplicatedStorage")
local events = rp:FindFirstChild("Events")

local remoteFunctionPath = "XMHH.2" 
local remoteEventPath = "XMHH2.2"

local remote1 = events and events:WaitForChild(remoteFunctionPath, 5)
local remote2 = events and events:WaitForChild(remoteEventPath, 5)

local AttachCD = {["Fists"] = .35, ["BBaton"] = .5, ["__ZombieFists1"] = .35, ["__ZombieFists2"] = .37, ["__ZombieFists3"] = .22, ["__ZombieFists4"] = .4, ["__XFists"] = .35, ["Balisong"] = .3, ["Bat"] = 1.2, ["Bayonet"] = .6, ["BlackBayonet"] = .6, ["CandyCrowbar"] = 2.5, ["Chainsaw"] = 3, ["Crowbar"] = 1.2, ["Clippers"] = .6, ["CursedDagger"] = .8, ["DELTA-X04"] = .6, ["ERADICATOR"] = 2, ["ERADICATOR-II"] = 2, ["Fire-Axe"] = 1.6, ["GoldenAxe"] = .75, ["Golfclub"] = 1.2, ["Hatchet"] = .7, ["Katana"] = .6, ["Knuckledusters"] = .5, ["Machete"] = .7, ["Metal-Bat"] = 1.3, ["Nunchucks"] = .3, ["PhotonBlades"] = .8, ["Rambo"] = .8, ["ReforgedKatana"] = .85, ["Rendbreaker"] = 1.5, ["RoyalBroadsword"] = 1, ["Sabre"] = .7, ["Scythe"] = 1.2, ["Shiv"] = .5, ["Shovel"] = 2.5, ["SlayerSword"] = 1.5, ["Sledgehammer"] = 2.2, ["Taiga"] = .7, ["Tomahawk"] = .85, ["Wrench"] = .6, ["_BFists"] = .35, ["_FallenBlade"] = 1.3, ["_Sledge"] = 2.2, ["new_oldSlayerSword"] = 1.5}

local currentSlash = 1
local lastAttack = 0
local meeleconn

local function attack(target)
    local char = me.Character
    local tool = char and char:FindFirstChildOfClass("Tool")
    if not tool then return end

    local cd = AttachCD[tool.Name] or 0.5
    if tick() - lastAttack < cd then return end
    lastAttack = tick()

    local aimtarget = Meele.Target[1] or "Head"
    local aimpart = target:FindFirstChild(aimtarget)
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not (aimpart and hrp and remote1 and remote2) then return end

    local arg1 = {
        [1] = "🍞",
        [2] = tick(),
        [3] = tool,
        [4] = "43TRFWX",
        [5] = "Normal",
        [6] = tick(),
        [7] = true
    }

    local success1, result = pcall(function()
        return remote1:InvokeServer(unpack(arg1))
    end)

    if not success1 then return end

    task.wait(0.05)

    local handle = tool:FindFirstChild('WeaponHandle') or tool:FindFirstChild("Handle") or char:FindFirstChild("Right Arm")
    
    if handle then
        local arg2 = {
            [1] = "🍞",
            [2] = tick(),
            [3] = tool,
            [4] = "2389ZFX34",
            [5] = result,
            [6] = false,
            [7] = handle,
            [8] = aimpart,
            [9] = target,
            [10] = hrp.Position,
            [11] = aimpart.Position
        }
        pcall(function()
            remote2:FireServer(unpack(arg2))
        end)
    end

    if Meele.Anim then
        local animFolder = tool:FindFirstChild("AnimsFolder")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if animFolder and hum then
            local animator = hum:FindFirstChildOfClass("Animator") or hum
            local anim = animFolder:FindFirstChild("Slash" .. currentSlash)
            if anim and animator then
                animator:LoadAnimation(anim):Play(0.1, 1, 1.3)
                currentSlash = animFolder:FindFirstChild("Slash" .. (currentSlash + 1)) and (currentSlash + 1) or 1
            end
        end
    end
end

local function loop()
    return run.RenderStepped:Connect(function()
        if not Meele.Toggle then return end
        local char = me.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        for _, p in pairs(plrs:GetPlayers()) do
            if p == me then continue end
            local c = p.Character
            local targetHrp = c and c:FindFirstChild("HumanoidRootPart")
            local hum = c and c:FindFirstChildOfClass("Humanoid")
            
            if targetHrp and hum and hum.Health > 0 then
                if Meele.Team and p.Team == me.Team then continue end
                if Meele.Downed and hum.Health < 15 then continue end
                if Meele.FF and c:FindFirstChildOfClass('ForceField') then continue end
                
                if (targetHrp.Position - hrp.Position).Magnitude <= Meele.Distance then
                    attack(c)
                    break
                end
            end
        end
    end)
end

meeleconn = loop()

local cloneref = cloneref or function(...) return ... end
local Service = setmetatable({}, {
    __index = function(_, k) return cloneref(game:GetService(k)) end
})

repeat task.wait() until game:IsLoaded()
local Players = Service.Players
local Player = Players and Players.LocalPlayer
repeat task.wait() Player = Players and Players.LocalPlayer until Player

local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid, HumanoidRootPart
local function UpdateCharacterReferences()
    Character = Player.Character
    if Character then
        HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
        Humanoid = Character:FindFirstChildOfClass("Humanoid")
    else
        HumanoidRootPart = nil
        Humanoid = nil
    end
end
UpdateCharacterReferences()

local Invis_Fixed = true
local InvisEnabled = false
local Track = nil
local Animation = Instance.new("Animation")
Animation.AnimationId = "rbxassetid://215384594"

local RunService = Service.RunService
local Heartbeat = RunService and RunService.Heartbeat
local RenderStepped = RunService and RunService.RenderStepped
local StarterGui = Service.StarterGui
local CoreGui = Service.CoreGui

local GUI = Instance.new("ScreenGui")
GUI.Name = "InvisWarningGUI"
GUI.ResetOnSpawn = false
GUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
GUI.Parent = CoreGui

local WarnLabel = Instance.new("TextLabel", GUI)
WarnLabel.Text = "⚠️You are visible⚠️"
WarnLabel.Visible = false
WarnLabel.Size = UDim2.new(0, 200, 0, 30)
WarnLabel.Position = UDim2.new(0.5, -100, 0.85, 0)
WarnLabel.BackgroundTransparency = 1
WarnLabel.Font = Enum.Font.GothamSemibold
WarnLabel.TextSize = 24
WarnLabel.TextColor3 = Color3.fromRGB(255,255,0)
WarnLabel.TextStrokeTransparency = 0.5
WarnLabel.ZIndex = 10

local function Grounded()
    return Humanoid and Humanoid:IsDescendantOf(workspace) and Humanoid.FloorMaterial ~= Enum.Material.Air
end

local function LoadAndPrepareTrack()
    if Track then
        pcall(function() Track:Stop() end)
        Track = nil
    end
    if Humanoid then
        local ok, res = pcall(function() return Humanoid:LoadAnimation(Animation) end)
        if ok and res then
            Track = res
            Track.Priority = Enum.AnimationPriority.Action4
        else
            Track = nil
        end
    else
        Track = nil
    end
end

local function Invis_Disable()
    if not InvisEnabled then return end
    InvisEnabled = false
    if Track then pcall(function() Track:Stop() end) end
    if Humanoid then pcall(function() workspace.CurrentCamera.CameraSubject = Humanoid end) end
    if Character then
        for _, v in pairs(Character:GetDescendants()) do
            if v:IsA("BasePart") and v.Transparency == 0.5 then
                v.Transparency = 0
            end
        end
    end
    WarnLabel.Visible = false
end

local function Invis_Enable()
    if InvisEnabled or not Invis_Fixed then return end
    UpdateCharacterReferences()
    if not Character or not Humanoid or not HumanoidRootPart then return end
    if not Character:FindFirstChild("Torso") then
        pcall(function()
            StarterGui:SetCore("SendNotification", {Title="Invisibility FAILED", Text="Feature requires R6 Avatar.", Duration=5})
        end)
        return
    end
    InvisEnabled = true
    pcall(function() workspace.CurrentCamera.CameraSubject = HumanoidRootPart end)
    LoadAndPrepareTrack()
end

Player.CharacterAdded:Connect(function(newChar)
    if Track then pcall(function() Track:Stop() end) Track = nil end
    task.wait()
    UpdateCharacterReferences()
    if not Humanoid then
        task.wait(0.5)
        UpdateCharacterReferences()
        if not Humanoid then
            Invis_Fixed = false
            if InvisEnabled then Invis_Disable() end
            pcall(function()
                StarterGui:SetCore("SendNotification", {Title="Invisibility Error", Text="Could not verify character type.", Duration=5})
            end)
            return
        end
    end
    if Humanoid.RigType ~= Enum.HumanoidRigType.R6 then
        Invis_Fixed = false
        if InvisEnabled then Invis_Disable() end
        pcall(function()
            StarterGui:SetCore("SendNotification", {Title="Invisibility Warning", Text="Non-R6 Avatar detected. Invisibility disabled.", Duration=5})
        end)
        return
    else
        Invis_Fixed = true
    end
    if InvisEnabled then
        if HumanoidRootPart then pcall(function() workspace.CurrentCamera.CameraSubject = HumanoidRootPart end) end
        LoadAndPrepareTrack()
    end
end)

Player.CharacterRemoving:Connect(function()
    if Track then pcall(function() Track:Stop() end) Track = nil end
    WarnLabel.Visible = false
end)

if Heartbeat then
    Heartbeat:Connect(function(deltaTime)
        if not InvisEnabled or not Invis_Fixed then
            if not InvisEnabled and Character then
                for _, v in pairs(Character:GetDescendants()) do
                    if v:IsA("BasePart") and v.Transparency == 0.5 then v.Transparency = 0 end
                end
            end
            WarnLabel.Visible = false
            return
        end

        if not Character or not Humanoid or not HumanoidRootPart or not Humanoid:IsDescendantOf(workspace) or Humanoid.Health <= 0 then
            WarnLabel.Visible = false
            return
        end

        WarnLabel.Visible = not Grounded()

        local speed = 12
        if Humanoid.MoveDirection.Magnitude > 0 then
            local offset = Humanoid.MoveDirection * speed * deltaTime
            if HumanoidRootPart and HumanoidRootPart:IsDescendantOf(workspace) then
                HumanoidRootPart.CFrame = HumanoidRootPart.CFrame + offset
            end
        end

        local OldCFrame = HumanoidRootPart.CFrame
        local OldCameraOffset = Humanoid.CameraOffset

        local _, y = workspace.CurrentCamera.CFrame:ToOrientation()
        if HumanoidRootPart and HumanoidRootPart:IsDescendantOf(workspace) then
            HumanoidRootPart.CFrame = CFrame.new(HumanoidRootPart.CFrame.Position) * CFrame.fromOrientation(0, y, 0)
            HumanoidRootPart.CFrame = HumanoidRootPart.CFrame * CFrame.Angles(math.rad(90), 0, 0)
        end
        Humanoid.CameraOffset = Vector3.new(0, 1.44, 0)

        if Track then
            local ok = pcall(function()
                if not Track.IsPlaying then Track:Play() end
                Track:AdjustSpeed(0)
                Track.TimePosition = 0.3
            end)
            if not ok then LoadAndPrepareTrack() end
        elseif Humanoid and Humanoid.Health > 0 then
            LoadAndPrepareTrack()
        end

        if RenderStepped then RenderStepped:Wait() end

        if Humanoid and Humanoid:IsDescendantOf(workspace) then
            Humanoid.CameraOffset = OldCameraOffset
        end
        if HumanoidRootPart and HumanoidRootPart:IsDescendantOf(workspace) then
            HumanoidRootPart.CFrame = OldCFrame
        end

        if Track then pcall(function() Track:Stop() end) end

        if HumanoidRootPart and HumanoidRootPart:IsDescendantOf(workspace) then
            local LookVector = workspace.CurrentCamera.CFrame.LookVector
            local Horizontal = Vector3.new(LookVector.X, 0, LookVector.Z)
            if Horizontal.Magnitude > 0.1 then
                local TargetCFrame = CFrame.new(HumanoidRootPart.Position, HumanoidRootPart.Position + Horizontal.Unit)
                HumanoidRootPart.CFrame = TargetCFrame
            end
        end

        if Character then
            for _, v in pairs(Character:GetDescendants()) do
                if v:IsA("BasePart") and v.Transparency ~= 1 then
                    v.Transparency = 0.5
                end
            end
        end
    end)
end

_G.Invis_Enable = Invis_Enable
_G.Invis_Disable = Invis_Disable
_G.IsInvisEnabled = function() return InvisEnabled end

local Workspace, RunService, Players, CoreGui, Lighting = cloneref(game:GetService("Workspace")), cloneref(game:GetService("RunService")), cloneref(game:GetService("Players")), game:GetService("CoreGui"), cloneref(game:GetService("Lighting"))

local ESP = {
    Enabled = false,
    TeamCheck = false,
    MaxDistance = 200,
    FontSize = 11,
    FadeOut = {
        OnDistance = false,
        OnDeath = false,
        OnLeave = false,
    },
    Options = { 
        Teamcheck = false, TeamcheckRGB = Color3.fromRGB(0, 255, 0),
        Friendcheck = false, FriendcheckRGB = Color3.fromRGB(0, 255, 0),
        Highlight = false, HighlightRGB = Color3.fromRGB(255, 0, 0),
    },
    Drawing = {
        Chams = {
            ChamsEnabled = false,
			GlowEnabled = false,
        },
        Names = {
            Enabled = false,
            RGB = Color3.fromRGB(255, 255, 255),
        },
        Flags = {
            Enabled = false,
        },
        Distances = {
            Enabled = false, 
            Position = "Text",
            RGB = Color3.fromRGB(255, 255, 255),
        },
        Weapons = {
            Enabled = false, WeaponTextRGB = Color3.fromRGB(119, 120, 255),
            Outlined = false,
            Gradient = false,
            GradientRGB1 = Color3.fromRGB(255, 255, 255), GradientRGB2 = Color3.fromRGB(119, 120, 255),
        },
        Healthbar = {
            Enabled = false,  
            HealthText = false, Lerp = false, HealthTextRGB = Color3.fromRGB(119, 120, 255),
            Width = 2.5,
            Gradient = false, GradientRGB1 = Color3.fromRGB(255, 0, 0), GradientRGB2 = Color3.fromRGB(255, 255, 0), GradientRGB3 = Color3.fromRGB(0, 255, 0), 
        },
        Boxes = {
            Animate = false,
            RotationSpeed = 300,
            Gradient = false, GradientRGB1 = Color3.fromRGB(0, 255, 0), GradientRGB2 = Color3.fromRGB(0, 0, 0), 
            GradientFill = false, GradientFillRGB1 = Color3.fromRGB(0, 255, 0), GradientFillRGB2 = Color3.fromRGB(0, 0, 0), 
            Filled = {
                Enabled = false,
                Transparency = 0.75,
                RGB = Color3.fromRGB(0, 0, 0),
            },
            Full = {
                Enabled = false,
                RGB = Color3.fromRGB(255, 255, 255),
            },
            Corner = {
                Enabled = false,
                RGB = Color3.fromRGB(255, 255, 255),
            },
        };
    };
    Connections = {
        RunService = RunService;
    };
    Fonts = {};
}

-- Def & Vars
local Euphoria = ESP.Connections;
local lplayer = Players.LocalPlayer;
local camera = game.Workspace.CurrentCamera;
local Cam = Workspace.CurrentCamera;
local RotationAngle, Tick = -45, tick();

-- Functions
local Functions = {}
do
    function Functions:Create(Class, Properties)
        local _Instance = typeof(Class) == 'string' and Instance.new(Class) or Class
        for Property, Value in pairs(Properties) do
            _Instance[Property] = Value
        end
        return _Instance;
    end
end;

do -- Initalize
    local ScreenGui = Functions:Create("ScreenGui", {
        Parent = CoreGui,
        Name = "ESPHolder",
    });

    local DupeCheck = function(plr)
        if ScreenGui:FindFirstChild(plr.Name) then
            ScreenGui[plr.Name]:Destroy()
        end
    end

    local ESP = function(plr)
        coroutine.wrap(DupeCheck)(plr) -- Dupecheck
        local Name = Functions:Create("TextLabel", {Parent = ScreenGui, Position = UDim2.new(0.5, 0, 0, -11), Size = UDim2.new(0, 100, 0, 20), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(255, 255, 255), Font = Enum.Font.Code, TextSize = ESP.FontSize, TextStrokeTransparency = 0, TextStrokeColor3 = Color3.fromRGB(0, 0, 0), RichText = true})
        local Distance = Functions:Create("TextLabel", {Parent = ScreenGui, Position = UDim2.new(0.5, 0, 0, 11), Size = UDim2.new(0, 100, 0, 20), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(255, 255, 255), Font = Enum.Font.Code, TextSize = ESP.FontSize, TextStrokeTransparency = 0, TextStrokeColor3 = Color3.fromRGB(0, 0, 0), RichText = true})
        local Weapon = Functions:Create("TextLabel", {Parent = ScreenGui, Position = UDim2.new(0.5, 0, 0, 31), Size = UDim2.new(0, 100, 0, 20), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(255, 255, 255), Font = Enum.Font.Code, TextSize = ESP.FontSize, TextStrokeTransparency = 0, TextStrokeColor3 = Color3.fromRGB(0, 0, 0), RichText = true})
        local Box = Functions:Create("Frame", {Parent = ScreenGui, BackgroundColor3 = Color3.fromRGB(0, 0, 0), BackgroundTransparency = 0.75, BorderSizePixel = 0})
        local Gradient1 = Functions:Create("UIGradient", {Parent = Box, Enabled = ESP.Drawing.Boxes.GradientFill, Color = ColorSequence.new{ColorSequenceKeypoint.new(0, ESP.Drawing.Boxes.GradientFillRGB1), ColorSequenceKeypoint.new(1, ESP.Drawing.Boxes.GradientFillRGB2)}})
        local Outline = Functions:Create("UIStroke", {Parent = Box, Enabled = ESP.Drawing.Boxes.Gradient, Transparency = 0, Color = Color3.fromRGB(255, 255, 255), LineJoinMode = Enum.LineJoinMode.Miter})
        local Gradient2 = Functions:Create("UIGradient", {Parent = Outline, Enabled = ESP.Drawing.Boxes.Gradient, Color = ColorSequence.new{ColorSequenceKeypoint.new(0, ESP.Drawing.Boxes.GradientRGB1), ColorSequenceKeypoint.new(1, ESP.Drawing.Boxes.GradientRGB2)}})
        local Healthbar = Functions:Create("Frame", {Parent = ScreenGui, BackgroundColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 0})
        local BehindHealthbar = Functions:Create("Frame", {Parent = ScreenGui, ZIndex = -1, BackgroundColor3 = Color3.fromRGB(0, 0, 0), BackgroundTransparency = 0})
        local HealthbarGradient = Functions:Create("UIGradient", {Parent = Healthbar, Enabled = ESP.Drawing.Healthbar.Gradient, Rotation = -90, Color = ColorSequence.new{ColorSequenceKeypoint.new(0, ESP.Drawing.Healthbar.GradientRGB1), ColorSequenceKeypoint.new(0.5, ESP.Drawing.Healthbar.GradientRGB2), ColorSequenceKeypoint.new(1, ESP.Drawing.Healthbar.GradientRGB3)}})
        local HealthText = Functions:Create("TextLabel", {Parent = ScreenGui, Position = UDim2.new(0.5, 0, 0, 31), Size = UDim2.new(0, 100, 0, 20), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(255, 255, 255), Font = Enum.Font.Code, TextSize = ESP.FontSize, TextStrokeTransparency = 0, TextStrokeColor3 = Color3.fromRGB(0, 0, 0)})
        local WeaponIcon = Functions:Create("ImageLabel", {Parent = ScreenGui, BackgroundTransparency = 1, BorderColor3 = Color3.fromRGB(0, 0, 0), BorderSizePixel = 0, Size = UDim2.new(0, 40, 0, 40)})
        local Gradient3 = Functions:Create("UIGradient", {Parent = WeaponIcon, Rotation = -90, Enabled = ESP.Drawing.Weapons.Gradient, Color = ColorSequence.new{ColorSequenceKeypoint.new(0, ESP.Drawing.Weapons.GradientRGB1), ColorSequenceKeypoint.new(1, ESP.Drawing.Weapons.GradientRGB2)}})
        local LeftTop = Functions:Create("Frame", {Parent = ScreenGui, BackgroundColor3 = ESP.Drawing.Boxes.Corner.RGB, Position = UDim2.new(0, 0, 0, 0)})
        local LeftSide = Functions:Create("Frame", {Parent = ScreenGui, BackgroundColor3 = ESP.Drawing.Boxes.Corner.RGB, Position = UDim2.new(0, 0, 0, 0)})
        local RightTop = Functions:Create("Frame", {Parent = ScreenGui, BackgroundColor3 = ESP.Drawing.Boxes.Corner.RGB, Position = UDim2.new(0, 0, 0, 0)})
        local RightSide = Functions:Create("Frame", {Parent = ScreenGui, BackgroundColor3 = ESP.Drawing.Boxes.Corner.RGB, Position = UDim2.new(0, 0, 0, 0)})
        local BottomSide = Functions:Create("Frame", {Parent = ScreenGui, BackgroundColor3 = ESP.Drawing.Boxes.Corner.RGB, Position = UDim2.new(0, 0, 0, 0)})
        local BottomDown = Functions:Create("Frame", {Parent = ScreenGui, BackgroundColor3 = ESP.Drawing.Boxes.Corner.RGB, Position = UDim2.new(0, 0, 0, 0)})
        local BottomRightSide = Functions:Create("Frame", {Parent = ScreenGui, BackgroundColor3 = ESP.Drawing.Boxes.Corner.RGB, Position = UDim2.new(0, 0, 0, 0)})
        local BottomRightDown = Functions:Create("Frame", {Parent = ScreenGui, BackgroundColor3 = ESP.Drawing.Boxes.Corner.RGB, Position = UDim2.new(0, 0, 0, 0)})
        local Flag1 = Functions:Create("TextLabel", {Parent = ScreenGui, Position = UDim2.new(1, 0, 0, 0), Size = UDim2.new(0, 100, 0, 20), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(255, 255, 255), Font = Enum.Font.Code, TextSize = ESP.FontSize, TextStrokeTransparency = 0, TextStrokeColor3 = Color3.fromRGB(0, 0, 0)})
        local Flag2 = Functions:Create("TextLabel", {Parent = ScreenGui, Position = UDim2.new(1, 0, 0, 0), Size = UDim2.new(0, 100, 0, 20), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(255, 255, 255), Font = Enum.Font.Code, TextSize = ESP.FontSize, TextStrokeTransparency = 0, TextStrokeColor3 = Color3.fromRGB(0, 0, 0)})
        --local DroppedItems = Functions:Create("TextLabel", {Parent = ScreenGui, AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(255, 255, 255), Font = Enum.Font.Code, TextSize = ESP.FontSize, TextStrokeTransparency = 0, TextStrokeColor3 = Color3.fromRGB(0, 0, 0)})
        --
        local Updater = function()
            local Connection;
            local function HideESP()
                Box.Visible = false;
                Name.Visible = false;
                Distance.Visible = false;
                Weapon.Visible = false;
                Healthbar.Visible = false;
                BehindHealthbar.Visible = false;
                HealthText.Visible = false;
                WeaponIcon.Visible = false;
                LeftTop.Visible = false;
                LeftSide.Visible = false;
                BottomSide.Visible = false;
                BottomDown.Visible = false;
                RightTop.Visible = false;
                RightSide.Visible = false;
                BottomRightSide.Visible = false;
                BottomRightDown.Visible = false;
                Flag1.Visible = false;
                Flag2.Visible = false;
                if not plr then
                    ScreenGui:Destroy();
                    Connection:Disconnect();
                end
            end
            --
            Connection = Euphoria.RunService.RenderStepped:Connect(function()
                if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    local HRP = plr.Character.HumanoidRootPart
                    local Humanoid = plr.Character:WaitForChild("Humanoid");
                    local Pos, OnScreen = Cam:WorldToScreenPoint(HRP.Position)
                    local Dist = (Cam.CFrame.Position - HRP.Position).Magnitude / 3.5714285714
                    
                    if OnScreen and Dist <= ESP.MaxDistance then
                        local Size = HRP.Size.Y
                        local scaleFactor = (Size * Cam.ViewportSize.Y) / (Pos.Z * 2)
                        local w, h = 3 * scaleFactor, 4.5 * scaleFactor

                        -- Teamcheck
                        if ESP.TeamCheck and plr ~= lplayer and ((lplayer.Team ~= plr.Team and plr.Team) or (not lplayer.Team and not plr.Team)) and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character:FindFirstChild("Humanoid") then

                            do -- Corner Boxes
                                LeftTop.Visible = ESP.Drawing.Boxes.Corner.Enabled
                                LeftTop.Position = UDim2.new(0, Pos.X - w / 2, 0, Pos.Y - h / 2)
                                LeftTop.Size = UDim2.new(0, w / 5, 0, 1)
                                
                                LeftSide.Visible = ESP.Drawing.Boxes.Corner.Enabled
                                LeftSide.Position = UDim2.new(0, Pos.X - w / 2, 0, Pos.Y - h / 2)
                                LeftSide.Size = UDim2.new(0, 1, 0, h / 5)
                                
                                BottomSide.Visible = ESP.Drawing.Boxes.Corner.Enabled
                                BottomSide.Position = UDim2.new(0, Pos.X - w / 2, 0, Pos.Y + h / 2)
                                BottomSide.Size = UDim2.new(0, 1, 0, h / 5)
                                BottomSide.AnchorPoint = Vector2.new(0, 5)
                                
                                BottomDown.Visible = ESP.Drawing.Boxes.Corner.Enabled
                                BottomDown.Position = UDim2.new(0, Pos.X - w / 2, 0, Pos.Y + h / 2)
                                BottomDown.Size = UDim2.new(0, w / 5, 0, 1)
                                BottomDown.AnchorPoint = Vector2.new(0, 1)
                                
                                RightTop.Visible = ESP.Drawing.Boxes.Corner.Enabled
                                RightTop.Position = UDim2.new(0, Pos.X + w / 2, 0, Pos.Y - h / 2)
                                RightTop.Size = UDim2.new(0, w / 5, 0, 1)
                                RightTop.AnchorPoint = Vector2.new(1, 0)
                                
                                RightSide.Visible = ESP.Drawing.Boxes.Corner.Enabled
                                RightSide.Position = UDim2.new(0, Pos.X + w / 2 - 1, 0, Pos.Y - h / 2)
                                RightSide.Size = UDim2.new(0, 1, 0, h / 5)
                                RightSide.AnchorPoint = Vector2.new(0, 0)
                                
                                BottomRightSide.Visible = ESP.Drawing.Boxes.Corner.Enabled
                                BottomRightSide.Position = UDim2.new(0, Pos.X + w / 2, 0, Pos.Y + h / 2)
                                BottomRightSide.Size = UDim2.new(0, 1, 0, h / 5)
                                BottomRightSide.AnchorPoint = Vector2.new(1, 1)
                                
                                BottomRightDown.Visible = ESP.Drawing.Boxes.Corner.Enabled
                                BottomRightDown.Position = UDim2.new(0, Pos.X + w / 2, 0, Pos.Y + h / 2)
                                BottomRightDown.Size = UDim2.new(0, w / 5, 0, 1)
                                BottomRightDown.AnchorPoint = Vector2.new(1, 1)                                                            
                            end

                            do -- Boxes
                                Box.Position = UDim2.new(0, Pos.X - w / 2, 0, Pos.Y - h / 2)
                                Box.Size = UDim2.new(0, w, 0, h)
                                Box.Visible = ESP.Drawing.Boxes.Full.Enabled;

                                -- Gradient
                                if ESP.Drawing.Boxes.Filled.Enabled then
                                    Box.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                                    if ESP.Drawing.Boxes.GradientFill then
                                        Box.BackgroundTransparency = ESP.Drawing.Boxes.Filled.Transparency;
                                    else
                                        Box.BackgroundTransparency = 1
                                    end
                                    Box.BorderSizePixel = 1
                                else
                                    Box.BackgroundTransparency = 1
                                end
                                -- Animation
                                RotationAngle = RotationAngle + (tick() - Tick) * ESP.Drawing.Boxes.RotationSpeed * math.cos(math.pi / 4 * tick() - math.pi / 2)
                                if ESP.Drawing.Boxes.Animate then
                                    Gradient1.Rotation = RotationAngle
                                    Gradient2.Rotation = RotationAngle
                                else
                                    Gradient1.Rotation = -90
                                    Gradient2.Rotation = -90
                                end
                                Tick = tick()
                            end

                            -- Healthbar
                            do  
                                local health = Humanoid.Health / Humanoid.MaxHealth;
                                Healthbar.Visible = ESP.Drawing.Healthbar.Enabled;
                                Healthbar.Position = UDim2.new(0, Pos.X - w / 2 - 6, 0, Pos.Y - h / 2 + h * (1 - health))  
                                Healthbar.Size = UDim2.new(0, ESP.Drawing.Healthbar.Width, 0, h * health)  
                                --
                                BehindHealthbar.Visible = ESP.Drawing.Healthbar.Enabled;
                                BehindHealthbar.Position = UDim2.new(0, Pos.X - w / 2 - 6, 0, Pos.Y - h / 2)  
                                BehindHealthbar.Size = UDim2.new(0, ESP.Drawing.Healthbar.Width, 0, h)
                                -- Health Text
                                do
                                    if ESP.Drawing.Healthbar.HealthText then
                                        local healthPercentage = math.floor(Humanoid.Health / Humanoid.MaxHealth * 100)
                                        HealthText.Position = UDim2.new(0, Pos.X - w / 2 - 6, 0, Pos.Y - h / 2 + h * (1 - healthPercentage / 100) + 3)
                                        HealthText.Text = tostring(healthPercentage)
                                        HealthText.Visible = Humanoid.Health < Humanoid.MaxHealth
                                        if ESP.Drawing.Healthbar.Lerp then
                                            local color = health >= 0.75 and Color3.fromRGB(0, 255, 0) or health >= 0.5 and Color3.fromRGB(255, 255, 0) or health >= 0.25 and Color3.fromRGB(255, 170, 0) or Color3.fromRGB(255, 0, 0)
                                            HealthText.TextColor3 = color
                                        else
                                            HealthText.TextColor3 = ESP.Drawing.Healthbar.HealthTextRGB
                                        end
                                    end                        
                                end
                            end

                            do -- Names
                                Name.Visible = ESP.Drawing.Names.Enabled
                                if ESP.Options.Friendcheck and lplayer:IsFriendsWith(plr.UserId) then
                                    Name.Text = string.format('(<font color="rgb(%d, %d, %d)">F</font>) %s', ESP.Options.FriendcheckRGB.R * 255, ESP.Options.FriendcheckRGB.G * 255, ESP.Options.FriendcheckRGB.B * 255, plr.Name)
                                else
                                    Name.Text = string.format('(<font color="rgb(%d, %d, %d)">E</font>) %s', 255, 0, 0, plr.Name)
                                end
                                Name.Position = UDim2.new(0, Pos.X, 0, Pos.Y - h / 2 - 9)
                            end
                            
                            do -- Distance
                                if ESP.Drawing.Distances.Enabled then
                                    if ESP.Drawing.Distances.Position == "Bottom" then
                                        Weapon.Position = UDim2.new(0, Pos.X, 0, Pos.Y + h / 2 + 18)
                                        WeaponIcon.Position = UDim2.new(0, Pos.X - 21, 0, Pos.Y + h / 2 + 15);
                                        Distance.Position = UDim2.new(0, Pos.X, 0, Pos.Y + h / 2 + 7)
                                        Distance.Text = string.format("%d meters", math.floor(Dist))
                                        Distance.Visible = true
                                    elseif ESP.Drawing.Distances.Position == "Text" then
                                        Weapon.Position = UDim2.new(0, Pos.X, 0, Pos.Y + h / 2 + 8)
                                        WeaponIcon.Position = UDim2.new(0, Pos.X - 21, 0, Pos.Y + h / 2 + 5);
                                        Distance.Visible = false
                                        if ESP.Options.Friendcheck and lplayer:IsFriendsWith(plr.UserId) then
                                            Name.Text = string.format('(<font color="rgb(%d, %d, %d)">F</font>) %s [%d]', ESP.Options.FriendcheckRGB.R * 255, ESP.Options.FriendcheckRGB.G * 255, ESP.Options.FriendcheckRGB.B * 255, plr.Name, math.floor(Dist))
                                        else
                                            Name.Text = string.format('(<font color="rgb(%d, %d, %d)">E</font>) %s [%d]', 255, 0, 0, plr.Name, math.floor(Dist))
                                        end
                                        Name.Visible = ESP.Drawing.Names.Enabled
                                    end
                                end
                            end

                            do -- Weapons
                                Weapon.Text = "none"
                                Weapon.Visible = ESP.Drawing.Weapons.Enabled
                            end                            
                        else
                            HideESP();
                        end
                    else
                        HideESP();
                    end
                else
                    HideESP();
                end
            end)
        end
        coroutine.wrap(Updater)();
    end
    do -- Update ESP
        for _, v in pairs(game:GetService("Players"):GetPlayers()) do
            if v.Name ~= lplayer.Name then
                coroutine.wrap(ESP)(v)
            end      
        end
        --
        game:GetService("Players").PlayerAdded:Connect(function(v)
            coroutine.wrap(ESP)(v)
        end);
    end;
end;

local InstanceNew, CFrameNew, Vec3 = Instance.new, CFrame.new, Vector3.new
local Players = cloneref(game:GetService("Players"))

pcall(function() setfflag("AdornShadingAPI", "true") end) --// required


--// Chams
do
    local function RemoveAdorns(Part): ()
        if not Part then return end;
        local Children = Part:GetChildren();

        for i = 1, #Children do
            local Obj = Children[i]
            if Obj.Name == "Chams" or Obj.Name == "Glow" then
                Obj:Destroy();
            end
        end
    end

    function CreateAdornment(Part, Type, Color, Trans, ZIndex, SizeOffset, Extra)
        Extra = Extra or {}

        local Ad
        if Type == "Cylinder" then
            Ad = InstanceNew("CylinderHandleAdornment")
            Ad.Height = Part.Size.Y + (Extra.HeightOffset or 0);
            Ad.Radius = (Part.Size.X * 0.5) + (Extra.RadiusOffset or 0);
            Ad.CFrame = CFrameNew(Vec3(), Vec3(0, 1, 0));

        elseif Type == "Box" then
            Ad = InstanceNew("BoxHandleAdornment")
            Ad.Size = Part.Size + (SizeOffset or Vec3(0,0,0));
        end

        Ad.Name = "Chams"
        Ad.AlwaysOnTop = true
        Ad.ZIndex = ZIndex
        Ad.Adornee = Part
        Ad.Color3 = Color
        Ad.Transparency = Trans or 0
        if Extra.Shading then
            Ad.Shading = Extra.Shading
        end

        Ad.Parent = Part
        return Ad
    end

    task.spawn(function()
        while task.wait(2) do
            local MainColor = Color3.new(); --// you can change these two
            local GlowColor = Color3.new(1, 1, 1);
            local Trans = 0.5

            for _, Player in Players:GetPlayers() do
                local Char = Player.Character
                if not Char then continue end

                for _, Part in Char:GetChildren() do
                    if not Part:IsA("BasePart") or Part.Transparency >= 1 then continue end;

                    RemoveAdorns(Part)

                    local IsHead = Part.Name == "Head" or Part.Name == "FakeHead"

                    if ESP.Drawing.Chams.GlowEnabled then
                        CreateAdornment(
                            Part,
                            IsHead and "Cylinder" or "Box",
                            Color3.new(GlowColor.R*5, GlowColor.G*5, GlowColor.B*5),
                            -1,
                            IsHead and 10 or 9,
                            Vec3(0.03, 0.03, 0.03),
                            { Shading = Enum.AdornShading.XRayShaded }
                        )
                    end

                    if ESP.Drawing.Chams.ChamsEnabled then
                        CreateAdornment(
                            Part,
                            IsHead and "Cylinder" or "Box",
                            MainColor,
                            Trans,
                            10,
                            Vec3(0.02, 0.02, 0.02)
                        )
                    end
                end
            end
        end
    end)
end;

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
        local random2time = Meele.Randomtime or 1
        local v3 = parts_list[math.random(1, #parts_list)]
        Meele.Target = {v3}
        task.wait(random2time)
    end
end

vis:AddToggle('vis1', { Text = 'Enabled', Default = false, Callback = function(Value) ESP.Enabled = Value end })
vis:AddToggle('vis1', { Text = 'Show Box', Default = false, Callback = function(Value) ESP.Drawing.Boxes.Full.Enabled = Value end })
vis:AddToggle('vis1', { Text = 'Show Health Bar', Default = false, Callback = function(Value) ESP.Drawing.Healthbar.Enabled = Value end })
vis:AddToggle('vis1', { Text = 'Show Name', Default = false, Callback = function(Value) ESP.Drawing.Names.Enabled = Value end })
vis:AddToggle('vis1', { Text = 'Show Distance', Default = false, Callback = function(Value) ESP.Drawing.Distances.Enabled = Value end })
vis:AddToggle('vis1', { Text = 'Show Tool', Default = false, Callback = function(Value) ESP.Drawing.Weapons.Enabled = Value end })
vis:AddToggle('vis1', { Text = 'Show Chams', Default = false, Callback = function(Value) ESP.Drawing.Chams.ChamsEnabled = Value end })

viss:AddToggle('vis1', { Text = 'Box Gradient', Default = false, Callback = function(Value) ESP.Drawing.Boxes.Gradient = Value end })
viss:AddToggle('vis1', { Text = 'Box Fill', Default = false, Callback = function(Value) ESP.Drawing.Boxes.Filled.Enabled = Value end })
viss:AddSlider('vis1', {
    Text = 'Box Fill Transparency', Default = 0.75, Min = 0, Max = 1, Rounding = 2, Compact = false,
    Callback = function(Value) ESP.Drawing.Boxes.Filled.Transparency = Value end
})
viss:AddToggle('vis1', { Text = 'Box Gradient Fill', Default = false, Callback = function(Value) ESP.Drawing.Boxes.GradientFill = Value end })
viss:AddToggle('vis1', { Text = 'Health Bar Gradient', Default = false, Callback = function(Value) ESP.Drawing.Healthbar.Gradient = Value end })
viss:AddToggle('vis1', { Text = 'Box Gradient Fill', Default = false, Callback = function(Value) ESP.Drawing.Boxes.GradientFill = Value end })


visw:AddToggle('dealeresp', { Text = 'Dealer ESP', Default = false, Callback = function(val)
        DealerESP_Enabled = val
        if val then
            task.spawn(function()
                while DealerESP_Enabled do
                    task.wait(1)
                    if Workspace:FindFirstChild("Map") and Workspace.Map:FindFirstChild("Shopz") then
                        for _, v in pairs(Workspace.Map.Shopz:GetChildren()) do
                            if (v.Name == "Dealer" or v.Name == "ArmoryDealer") and not v:FindFirstChild("DealerESP") then
                                local hl = Instance.new("Highlight", v)
                                hl.Name = "DealerESP"
                                if v.Name == "Dealer" then hl.FillColor = Color3.fromRGB(153, 255, 153)
                                else hl.FillColor = Color3.fromRGB(153, 204, 255) end
                            end
                        end
                    end
                end
            end)
        else
             if Workspace:FindFirstChild("Map") and Workspace.Map:FindFirstChild("Shopz") then
                for _, v in pairs(Workspace.Map.Shopz:GetChildren()) do
                    if v:FindFirstChild("DealerESP") then v.DealerESP:Destroy() end
                end
            end
        end
    end
})
local SafeESP_Enabled = false
visw:AddToggle('safeesp', { Text = 'Safe ESP', Default = false, Callback = function(val)
        SafeESP_Enabled = val
        if val then
            task.spawn(function()
                while SafeESP_Enabled do
                    task.wait(1)
                    if Workspace:FindFirstChild("Map") and Workspace.Map:FindFirstChild("BredMakurz") then
                        for _, obj in pairs(Workspace.Map.BredMakurz:GetChildren()) do
                            if not obj:FindFirstChild("SafeESP") then
                                local isSafe = obj.Name:lower():find("safe") or obj.Name:lower():find("register") or obj.Name:lower():find("cash")
                                if isSafe then
                                    local bg = Instance.new("BillboardGui", obj)
                                    bg.Name = "SafeESP"
                                    bg.AlwaysOnTop = true
                                    bg.Size = UDim2.new(1.2, 0, 1.2, 0)
                                    local txt = Instance.new("TextLabel", bg)
                                    txt.Name = "name"
                                    txt.Size = UDim2.new(1,0,0.3,0)
                                    txt.BackgroundTransparency = 1
                                    txt.TextColor3 = Color3.fromRGB(0, 255, 0)
                                    txt.Text = obj.Name
									txt.TextStrokeTransparency = 0
                                    local hp = Instance.new("TextLabel", bg)
                                    hp.Name = "health"
                                    hp.Size = UDim2.new(1,0,0.3,0)
                                    hp.Position = UDim2.new(0,0,0,17)
									hp.BackgroundTransparency = 1
                    				hp.TextColor3 = Color3.fromRGB(0, 255, 0)
									hp.TextStrokeTransparency = 0

                                    if obj:FindFirstChild("Values") and obj.Values:FindFirstChild("Broken") then
                                        if obj.Values.Broken.Value then
                                            txt.TextColor3 = Color3.fromRGB(255, 0, 0)
                                            hp.Visible = false
                                        else
                                            if obj.Values:FindFirstChild("Health") then
                                                hp.Text = "Health: " .. obj.Values.Health.Value
                                            end
                                        end
                                    end
                                end
                            else
                                if obj:FindFirstChild("Values") and obj.Values:FindFirstChild("Broken") and obj.SafeESP:FindFirstChild("name") then
                                     if obj.Values.Broken.Value then
                                        obj.SafeESP.name.TextColor3 = Color3.fromRGB(255, 0, 0)
                                        if obj.SafeESP:FindFirstChild("health") then obj.SafeESP.health.Visible = false end
                                     else
                                        if obj.Values:FindFirstChild("Health") and obj.SafeESP:FindFirstChild("health") then
                                            obj.SafeESP.health.Text = "Health: " .. obj.Values.Health.Value
                                        end
                                     end
                                end
                            end
                        end
                    end
                end
            end)
        else
            if Workspace:FindFirstChild("Map") and Workspace.Map:FindFirstChild("BredMakurz") then
                for _, obj in pairs(Workspace.Map.BredMakurz:GetChildren()) do
                    if obj:FindFirstChild("SafeESP") then obj.SafeESP:Destroy() end
                end
            end
			SafeESP_Enabled = false
        end
    end
})
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

rage:AddToggle('rage', { Text = 'Toggle', Default = false, Callback = function(Value) settings.ragebot = Value end }):AddKeyPicker("ragekey", {
    Default = "None", SyncToggleState = true, Mode = "Toggle", Text = "Rage Bot Key", NoUI = false,
})
rage:AddToggle('rageteamcheck', { Text = 'Check Team', Default = false, Callback = function(Value) settings.checkteam = Value end })
rage:AddToggle('ragewallcheck', { Text = 'Check Wall', Default = false, Callback = function(Value) settings.checkwall = Value end })
rage:AddToggle('ragedownedcheck', { Text = 'Check Downed', Default = false, Callback = function(Value) settings.checkdowned = Value end })
rage:AddToggle('ragesound', { Text = 'Hit Sound', Default = false, Callback = function(Value) settings.sound = Value end })
rage:AddToggle('ragehit', { Text = 'Hit Log', Default = false, Callback = function(Value) settings.hitlog = Value end })
rage:AddToggle('ragebulletracer', { Text = 'Bullet Tracer', Default = false, Callback = function(Value) settings.bulletTracerEnabled = Value end })
rage:AddDropdown("hitsound_dropdown", { Text = "Hit Sound List", Values = soundList, Default = "Default", Multi = false, Callback = function(v) settings.selected_sound = sounds[v] end })
rage:AddSlider('distance', { Text = 'Max Distance', Default = 500, Min = 0, Max = 10000, Rounding = 1, Compact = false, Callback = function(Value) settings.distance = Value end })
rage:AddSlider('fovradius', { Text = 'FOV Radius', Default = 150, Min = 0, Max = 500, Rounding = 1, Compact = false, Callback = function(Value) settings.fov_radius = Value end })
rage:AddSlider('shootspeed', { Text = 'Shoot Speed', Default = 15, Min = 0, Max = 100, Rounding = 2, Compact = false, Callback = function(Value) settings.shootspeed = Value end })
rage:AddSlider('fireinterval', { Text = 'Fire Interval', Default = 0.17, Min = 0, Max = 1, Rounding = 2, Compact = false, Callback = function(Value) settings.fireinterval = Value end })

meele:AddToggle('meele', { Text = 'Toggle', Default = false, Callback = function(Value) 
		Meele.Toggle = Value
	end
}):AddKeyPicker("meelkey", {
    Default = "None", SyncToggleState = true, Mode = "Toggle", Text = "Meele Aura Key", NoUI = false,
})

meele:AddToggle('meeleshowanim', { Text = 'Show Animation', Default = false, Callback = function(Value) Meele.Anim = Value end })
meele:AddToggle('meeleteam', { Text = 'Check Team', Default = false, Callback = function(Value) Meele.Team = Value end })
meele:AddToggle('meeledowned', { Text = 'Check Downed', Default = false, Callback = function(Value) Meele.Downed = Value end })

meele:AddDropdown('AimPartDropdown', {
    Values = { "Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg", "Random" },
    Default = 1, Multi = false, 
    Text = 'Aim Parts',
    Callback = function(Value)
        if Value == "Random" then task.spawn(runRandomLoop2) else random2Active = false Meele.Target = {Value} end
    end
})

meele:AddSlider('meeletime', { Text = 'Random Time', Default = 1, Min = 0, Max = 10, Rounding = 2, Compact = false, Callback = function(Value) Meele.Randomtime = Value end })
meele:AddSlider('meeledistance', { Text = 'Distance', Default = 15, Min = 0, Max = 100, Rounding = 2, Compact = false, Callback = function(Value) Meele.Distance = Value end })

local fovcamera = false
local fovcameraamount = 70
local cframespeed = false
local cframespeedamount = 1
local spin = false
local spinspeed = 10
local jumpheight = false
local jumpamount = 7.2

plrc:AddToggle("fovcamera", {
    Text = "Field Of View",
    Default = false,
    Callback = function(Value)
        fovcamera = Value
        if not Value then
            camera.FieldOfView = 70
        end
    end
})

plrc:AddSlider('fovcameraamount', { 
    Text = 'Field Of View Amount', 
    Default = 70, Min = 0, Max = 120, Rounding = 2, 
    Callback = function(Value) fovcameraamount = Value end 
})

plrc:AddToggle("cframespeed", {
    Text = "CFrame Speed",
    Default = false,
    Callback = function(Value) cframespeed = Value end
})

plrc:AddSlider('cframespeedamount', { 
    Text = 'CFrame Speed Amount', 
    Default = 1, Min = 0, Max = 5, Rounding = 2, 
    Callback = function(Value) cframespeedamount = Value end
})

plrc:AddToggle("jumpheight", {
    Text = "Jump Height",
    Default = false,
    Callback = function(Value)
        jumpheight = Value
        if not Value and me.Character and me.Character:FindFirstChild("Humanoid") then
            me.Character.Humanoid.JumpHeight = 7.2
        end
    end
})

plrc:AddSlider('jumpamount', { 
    Text = 'Jump Height Amount', 
    Default = 7.2, Min = 0, Max = 50, Rounding = 2, 
    Callback = function(Value) jumpamount = Value end
})

plrc:AddToggle("spin", {
    Text = "Spin",
    Default = false,
    Callback = function(Value) spin = Value end
})

plrc:AddSlider('spinspeed', { 
    Text = 'Spin Speed', 
    Default = 10, Min = 0, Max = 100, Rounding = 2, 
    Callback = function(Value) spinspeed = Value end
})

run.RenderStepped:Connect(function()
    if fovcamera then
        camera.FieldOfView = fovcameraamount
    end
    
    if jumpheight and me.Character and me.Character:FindFirstChild("Humanoid") then
        local hum = me.Character.Humanoid
        hum.UseJumpPower = false
        hum.JumpHeight = jumpamount
    end
end)

run.Heartbeat:Connect(function()
    if cframespeed and me.Character and me.Character:FindFirstChild('Humanoid') and me.Character:FindFirstChild('HumanoidRootPart') then
        local hum = me.Character.Humanoid
        local hrp = me.Character.HumanoidRootPart
        if hum.MoveDirection.Magnitude > 0 then
            hrp.CFrame = hrp.CFrame + (hum.MoveDirection * cframespeedamount)
        end
    end

    if spin and me.Character and me.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = me.Character.HumanoidRootPart
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(spinspeed), 0)
    end
end)

plrc:AddToggle("inv", {
    Text = "Invisible",
    Default = false,
    Disabled = false,
    Visible = true,
    Risky = false,

    Callback = function(Value)
        functions.invisible = Value
        if Value then
            pcall(function() if _G and _G.Invis_Enable then _G.Invis_Enable() end end)
        else
            pcall(function() if _G and _G.Invis_Disable then _G.Invis_Disable() end end)
        end
    end
})

local autopickup = false
local connection

plrc:AddToggle("autopickup_toggle", {
    Text = "Auto Pickup Money",
    Default = false,
    Callback = function(Value)
        autopickup = Value
        
        if connection then
            connection:Disconnect()
            connection = nil
        end

        if autopickup then
            local remote = ReplicatedStorage.Events:FindFirstChild('CZDPZUS')
            local moneyfolder = workspace.Filter.SpawnedBread
            local canpickup = true
            local starttick = tick()

            connection = run.RenderStepped:Connect(function()
                local function getmony()
                    local dist = 15
                    local closest = nil
                    if me.Character and me.Character:FindFirstChild('HumanoidRootPart') then
                        for _, m in pairs(moneyfolder:GetChildren()) do
                            if m and me.Character and me.Character:FindFirstChild('HumanoidRootPart') then
                                local distance = (me.Character.HumanoidRootPart.Position - m.Position).Magnitude
                                if distance < dist then
                                    dist = distance
                                    closest = m
                                end
                            end
                        end
                    end
                    return closest
                end
                
                local foundmoney = getmony()
                if foundmoney and canpickup then
                    remote:FireServer(foundmoney)
                    canpickup = false
                    starttick = tick()
                end
                
                if not canpickup and tick() - starttick >= 1 then
                    canpickup = true
                end
            end)
        end
    end
})

Library:SetWatermarkVisibility(true)
local FrameTimer = tick()
local FrameCounter = 0;
local FPS = 60;

local WatermarkConnection = RunService.RenderStepped:Connect(function()
    FrameCounter += 1;

    if (tick() - FrameTimer) >= 1 then
        FPS = FrameCounter;
        FrameTimer = tick();
        FrameCounter = 0;
    end;

    local TimeString = os.date("%I:%M%p")

    Library:SetWatermark(('Skidware.cc | Criminality | %s | %s fps | %s ms'):format(
        TimeString,
        math.floor(FPS),
        math.floor(game:GetService('Stats').Network.ServerStatsItem['Data Ping']:GetValue())
    ));
end);

local MenuGroup = tabs.settings:AddLeftGroupbox('Menu')
MenuGroup:AddButton('Unload', function() Library:Unload() end)
MenuGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', { Default = 'Q', NoUI = true, Text = 'Menu Keybind' })

Library.ToggleKeybind = Options.MenuKeybind
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ 'MenuKeybind' })
ThemeManager:SetFolder('skidware.cc')
SaveManager:SetFolder('skidware.cc/criminality')
SaveManager:BuildConfigSection(tabs.settings)
ThemeManager:ApplyToTab(tabs.settings)
SaveManager:LoadAutoloadConfig()

MenuGroup:AddToggle("Keybind", {
    Text = "Key Bind",
    Tooltip = "This is a tooltip",
    DisabledTooltip = "I am disabled!",

    Default = false,
    Disabled = false,
    Visible = true,
    Risky = false,

    Callback = function(Value)
        Library.KeybindFrame.Visible = Value
    end,
})
