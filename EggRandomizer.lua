--[[  
    Roblox "Grow a Garden" Egg Randomizer
    Version: 4.0
    Features:
    - Auto detects eggs in workspace
    - Randomizes pet results from defined pools
    - ESP shows possible pets
    - Auto Age (50 pets loop)
    - Draggable GUI
--]]

-- // Egg Pools
local EggPools = {
    ["Common egg"] = {"Dog", "Golden Lab", "Bunny"},
    ["Bug egg"] = {"Caterpillar", "Snail", "Giant Ant", "Praying Mantis", "Dragonfly"},
    ["Common Summer egg"] = {"Starfish", "Seagull", "Crab"},
    ["Rare Summer egg"] = {"Flamingo", "Toucan", "Sea Turtle", "Orangutan", "Seal"},
    ["Paradise egg"] = {"Ostrich", "Peacock", "Capybara", "Mimic Octopus"},
    ["Mythical egg"] = {"Grey Mouse", "Brown Mouse", "Squirrel", "Red Giant Ant", "Red Fox"},
    ["Gourmet egg"] = {"Bagel Bunny", "Pancake Mole", "Sushi Bear", "Spaghetti Sloth", "French Fry Ferret"},
    ["Sprout egg"] = {"Dairy Cow", "Jackalope", "Sapling", "Golem", "Golden Goose"},
    ["Anti Bee egg"] = {"Wasp", "Tarantula Hawk", "Moth", "Butterfly", "Disco Bee"},
    ["Bee egg"] = {"Bee", "Honey Bee", "Bear Bee", "Petal Bee", "Queen Bee"},
    ["Night egg"] = {"Hedgehog", "Mole", "Frog", "Echo Frog", "Night Owl", "Raccoon"},
    ["Primal egg"] = {"Parasaurolophus", "Iguanodon", "Pachycephalosaurus", "Dilophosaurus", "Ankylosaurus", "Spinosaurus"},
    ["Dinosaur egg"] = {"T-Rex", "Brontosaurus", "Pterodactyl", "Raptor", "Stegosaurus"},
    ["Zen egg"] = {"Kitsune", "Kodama", "Nihonzaru", "Shiba Inu", "Tanchozuru", "Kappa"},
}

-- // GUI Setup
local player = game.Players.LocalPlayer
local ScreenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 300, 0, 200)
MainFrame.Position = UDim2.new(0.3, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(130, 70, 20)
MainFrame.Active = true

-- Title
local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.Text = "🥚 EGG RANDOMIZER 🥚"
Title.Font = Enum.Font.GothamBold
Title.TextColor3 = Color3.fromRGB(0, 255, 0)
Title.TextScaled = true

-- ESP Button
local ESPButton = Instance.new("TextButton", MainFrame)
ESPButton.Size = UDim2.new(0.9, 0, 0, 30)
ESPButton.Position = UDim2.new(0.05, 0, 0.35, 0)
ESPButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
ESPButton.Text = "👁 Show Egg Contents"
ESPButton.Font = Enum.Font.GothamBold
ESPButton.TextScaled = true
ESPButton.TextColor3 = Color3.fromRGB(255, 255, 255)

-- Roll Button
local RollButton = Instance.new("TextButton", MainFrame)
RollButton.Size = UDim2.new(0.9, 0, 0, 30)
RollButton.Position = UDim2.new(0.05, 0, 0.55, 0)
RollButton.BackgroundColor3 = Color3.fromRGB(100, 60, 60)
RollButton.Text = "🎲 Roll Random Pet"
RollButton.Font = Enum.Font.GothamBold
RollButton.TextScaled = true
RollButton.TextColor3 = Color3.fromRGB(255, 255, 255)

-- Auto Age Button
local AgeButton = Instance.new("TextButton", MainFrame)
AgeButton.Size = UDim2.new(0.9, 0, 0, 30)
AgeButton.Position = UDim2.new(0.05, 0, 0.75, 0)
AgeButton.BackgroundColor3 = Color3.fromRGB(100, 60, 60)
AgeButton.Text = "🐵 Auto Age (50 pets)"
AgeButton.Font = Enum.Font.GothamBold
AgeButton.TextScaled = true
AgeButton.TextColor3 = Color3.fromRGB(255, 255, 255)

-- Version Label
local Version = Instance.new("TextLabel", MainFrame)
Version.Size = UDim2.new(1, 0, 0, 20)
Version.Position = UDim2.new(0, 0, 0.9, 0)
Version.BackgroundTransparency = 1
Version.Text = "Version: 4.0"
Version.Font = Enum.Font.Gotham
Version.TextColor3 = Color3.fromRGB(255, 255, 255)
Version.TextScaled = true

-- // Draggable
local UIS = game:GetService("UserInputService")
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
		MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
			startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

-- // Egg Functions
local function findEggs()
    local eggs = {}
    for _, obj in pairs(workspace:GetDescendants()) do
        if EggPools[obj.Name] then
            table.insert(eggs, obj)
        end
    end
    return eggs
end

local function ShowEggContents(eggModel, eggName)
    if not EggPools[eggName] then return end
    local old = eggModel:FindFirstChild("ESP_Billboard")
    if old then old:Destroy() end
    local billboard = Instance.new("BillboardGui", eggModel)
    billboard.Name = "ESP_Billboard"
    billboard.Size = UDim2.new(0, 200, 0, 100)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Adornee = eggModel
    local label = Instance.new("TextLabel", billboard)
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = table.concat(EggPools[eggName], ", ")
    label.Font = Enum.Font.Gotham
    label.TextColor3 = Color3.fromRGB(255, 255, 0)
    label.TextScaled = true
end

local function RandomizeEgg(eggModel, eggName)
    local pool = EggPools[eggName]
    if not pool then return end
    local pet = pool[math.random(1, #pool)]
    local old = eggModel:FindFirstChild("Result_Billboard")
    if old then old:Destroy() end
    local billboard = Instance.new("BillboardGui", eggModel)
    billboard.Name = "Result_Billboard"
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 2, 0)
    billboard.AlwaysOnTop = true
    billboard.Adornee = eggModel
    local label = Instance.new("TextLabel", billboard)
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = pet
    label.Font = Enum.Font.GothamBold
    label.TextColor3 = Color3.fromRGB(0, 255, 0)
    label.TextScaled = true
    return pet
end

-- // Button Actions
ESPButton.MouseButton1Click:Connect(function()
    for _, egg in pairs(findEggs()) do
        ShowEggContents(egg, egg.Name)
    end
end)

RollButton.MouseButton1Click:Connect(function()
    for _, egg in pairs(findEggs()) do
        RandomizeEgg(egg, egg.Name)
    end
end)

AgeButton.MouseButton1Click:Connect(function()
    for i = 1, 50 do
        task.wait(0.2)
        print("Auto aging pet #" .. i) -- you can replace with actual pet aging call
    end
end)
