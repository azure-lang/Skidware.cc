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
    Title = "Skidware.cc",
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0.2
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

local cockie = {
    SilentAimCircle = nil
}

local vis = tabs.visuals:AddLeftGroupbox("Player Visuals")
local silent = tabs.main:AddLeftGroupbox("Silent Aim")
local aimbot = tabs.main:AddRightGroupbox("Aimbot")
local rage = tabs.main:AddLeftGroupbox("Rage Bot")
local meele = tabs.main:AddRightGroupbox("Meele Aura")
local plrc = tabs.player:AddLeftGroupbox("Player Modifications")

local ESP = loadstring(game:HttpGet("https://pastebin.com/raw/M6NJDXGV"))()

local Events = ReplicatedStorage:FindFirstChild("Events")
local GNX_S = Events:FindFirstChild("GNX_S")
local ZFKLF__H = Events:FindFirstChild("ZFKLF__H")

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

    local now = tick()
    if not lastHitNotify[target.UserId] or now - lastHitNotify[target.UserId] >= NOTIFY_COOLDOWN then
        lastHitNotify[target.UserId] = now
        
        if Settings.hitlogEnabled then
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

vis:AddToggle('vis1', { Text = 'Enabled', Default = false, Callback = function(Value) ESP.ESP_Enabled = Value end })
vis:AddToggle('vis2', { Text = 'Show Box', Default = false, Callback = function(Value) ESP.Box = Value end })
vis:AddToggle('vis3', { Text = 'Show Name', Default = false, Callback = function(Value) ESP.Name = Value end })
vis:AddToggle('vis4', { Text = 'Show Tool', Default = false, Callback = function(Value) ESP.Tool = Value end })
vis:AddToggle('vis5', { Text = 'Show Distance', Default = false, Callback = function(Value) ESP.Distance = Value end })
vis:AddToggle('vis6', { Text = 'Show Health Text', Default = false, Callback = function(Value) ESP.HealthText = Value end })
vis:AddToggle('vis7', { Text = 'Show Health Bar', Default = false, Callback = function(Value) ESP.HealthBar = Value end })
vis:AddToggle('vis8', { Text = 'Show Chams', Default = false, Callback = function(Value) ESP.Chams = Value end })
vis:AddToggle('vis9', { Text = 'Show Head Dot', Default = false, Callback = function(Value) ESP.Headdot = Value end })
vis:AddToggle('vis10', { Text = 'Show Skeletons', Default = false, Callback = function(Value) ESP.Skeleton = Value end })

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

rage:AddToggle('rage', { Text = 'Toggle', Default = false, Callback = function(Value) functions.RageBot = Value end }):AddKeyPicker("ragekey", {
    Default = "None", SyncToggleState = true, Mode = "Toggle", Text = "Rage Bot Key", NoUI = false,
})
rage:AddToggle('rageteamcheck', { Text = 'Check Team', Default = false, Callback = function(Value) Settings.checkTeam = Value end })
rage:AddToggle('ragewallcheck', { Text = 'Check Wall', Default = false, Callback = function(Value) Settings.checkWall = Value end })
rage:AddToggle('ragedownedcheck', { Text = 'Check Downed', Default = false, Callback = function(Value) Settings.checkDowned = Value end })
rage:AddToggle('rageteamcheck', { Text = 'Check Team', Default = false, Callback = function(Value) Settings.checkTeam = Value end })
rage:AddToggle('ragehitlog', { Text = 'Hit Log', Default = false, Callback = function(Value) Settings.hitlogEnabled = Value end })
rage:AddToggle('ragebulletracer', { Text = 'Bullet Tracer', Default = false, Callback = function(Value) Settings.bulletTracerEnabled = Value end })
rage:AddSlider('distance', { Text = 'Max Distance', Default = 500, Min = 0, Max = 2000, Rounding = 1, Compact = false, Callback = function(Value) Settings.maxDistance = Value end })
rage:AddSlider('shootspeed', { Text = 'Shoot Speed', Default = 15, Min = 0, Max = 100, Rounding = 2, Compact = false, Callback = function(Value) Settings.shootSpeed = Value end })
rage:AddSlider('fireinterval', { Text = 'Fire Interval', Default = 0.17, Min = 0, Max = 1, Rounding = 2, Compact = false, Callback = function(Value) Settings.fireInterval = Value end })

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

local speedEnabled = false
local speedAmount = 1

game:GetService("RunService").RenderStepped:Connect(function()
    if speedEnabled and game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = game.Players.LocalPlayer.Character.HumanoidRootPart
        local moveDir = game.Players.LocalPlayer.Character.Humanoid.MoveDirection
        
        if moveDir.Magnitude > 0 then
            hrp.CFrame = hrp.CFrame + (moveDir * (speedAmount / 10))
        end
    end
end)

local fovenabled = false
local fovamount = 70

plrc:AddToggle('walkspeed', { Text = 'CFrame Speed', Default = false, Callback = function(Value) speedEnabled = Value end })
plrc:AddSlider('walkspeedamount', { Text = 'CFrame Speed Amount', Default = 1, Min = 0, Max = 10, Rounding = 2, Compact = false, Callback = function(Value) if speedEnabled then speedAmount = Value end end })
plrc:AddToggle('fovcamera', { Text = 'FOV Camera', Default = false, Callback = function(Value) fovenabled = Value end }
plrc:AddSlider('fovcameraamount', { Text = 'FOV Camera Amount', Default = 1, Min = 0, Max = 10, Rounding = 2, Compact = false, Callback = function(Value) fovamount = Value if fovenabled then run.RenderStepped:Connect(function() camera.FieldOfView = fovamount end) end end })
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

    Library:SetWatermark(('Skidware.cc | Criminality | %s fps | %s ms'):format(
        math.floor(FPS),
        math.floor(game:GetService('Stats').Network.ServerStatsItem['Data Ping']:GetValue())
    ));
end);

Library.KeybindFrame.Visible = false; 

Library:OnUnload(function()
    WatermarkConnection:Disconnect()
    Library.Unloaded = true
end)

local MenuGroup = tabs.settings:AddLeftGroupbox('Menu')
MenuGroup:AddButton('Unload', function() Library:Unload() end)
MenuGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', { Default = 'End', NoUI = true, Text = 'Menu Keybind' })
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
