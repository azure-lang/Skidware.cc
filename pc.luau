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

local repo = 'https://raw.githubusercontent.com/deividcomsono/Obsidian/main/'

local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

local window = Library:CreateWindow({
    Title = "Skidware.cc",
    Footer = "Vesion: Paid"
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

local vis = tabs.visuals:AddLeftGroupbox("Player Visuals")
local silent = tabs.main:AddLeftGroupbox("Silent Aim")
local aimbot = tabs.main:AddRightGroupbox("Aimbot")
local rage = tabs.main:AddLeftGroupbox("Rage Bot")
local meele = tabs.main:AddRightGroupbox("Meele Aura")
local plrc = tabs.player:AddLeftGroupbox("Player Modifications")
local viss = tabs.visuals:AddRightGroupbox("Player Visuals Settings")
local visw = tabs.visuals:AddRightGroupbox("World Visuals")
local visp = tabs.visuals:AddLeftGroupbox('View Model Visuals')

local ESP = loadstring(game:HttpGet("https://pastebin.com/raw/M6NJDXGV"))()

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
    tracerColor = Color3.new(1, 1, 1),
    fov_enabled = false,
    fov_radius = 150,
    fov_color = Color3.new(1, 1, 1)
}

local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.NumSides = 100
FOVCircle.Radius = settings.fov_radius
FOVCircle.Filled = false
FOVCircle.Visible = settings.fov_enabled
FOVCircle.Color = settings.fov_color
FOVCircle.Transparency = 1

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
        local r = WallbangRadius * (0.6 + math.random() * 0.8)
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
                if mouseDistance <= settings.fov_radius then
                    local worldDist = (rootPart.Position - myRootPos).Magnitude
                    if worldDist < settings.distance and mouseDistance < shortestDistance then
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

run.RenderStepped:Connect(function()
    FOVCircle.Visible = settings.fov_enabled
    FOVCircle.Radius = settings.fov_radius
    FOVCircle.Position = UserInputService:GetMouseLocation()
    FOVCircle.Color = settings.fov_color
end)

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

local AttachCD = {["Fists"] = .35, ["BBaton"] = .5, ["__ZombieFists1"] = .35, ["__ZombieFists2"] = .37, ["__ZombieFists3"] = .22, ["__ZombieFists4"] = .4, ["__XFists"] = .35, ["Balisong"] = .3, ["Bat"] = 1.2, ["Bayonet"] = .6, ["BlackBayonet"] = .6, ["CandyCrowbar"] = 2.5, ["Chainsaw"] = 3, ["Crowbar"] = 1.2, ["Clippers"] = .6, ["CursedDagger"] = .8, ["DELTA-X04"] = .6, ["ERADICATOR"] = 2, ["ERADICATOR-II"] = 2, ["Fire-Axe"] = 1.6, ["GoldenAxe"] = .75, ["Golfclub"] = 1.2, ["Hatchet"] = .7, ["Katana"] = .6, ["Knuckledusters"] = .5, ["Machete"] = .7, ["Metal-Bat"] = 1.3, ["Nunchucks"] = .3, ["PhotonBlades"] = .8, ["Rambo"] = .8, ["ReforgedKatana"] = .85, ["Rendbreaker"] = 1.5, ["RoyalBroadsword"] = 1, ["Sabre"] = .7, ["Scythe"] = 1.2, ["Shiv"] = .5, ["Shovel"] = 2.5, ["SlayerSword"] = 1.5, ["Sledgehammer"] = 2.2, ["Taiga"] = .7, ["Tomahawk"] = .85, ["Wrench"] 
