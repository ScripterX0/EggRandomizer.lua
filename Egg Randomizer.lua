-- Egg Randomizer – by ScripterX
-- Compact GUI: Choose Egg | Randomize Hatch | Age Picker (1–100)

local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Cleanup existing GUI
if playerGui:FindFirstChild("PetRandomizerGui") then
    playerGui.PetRandomizerGui:Destroy()
end

-- GUI setup
local ScreenGui = Instance.new("ScreenGui", playerGui)
ScreenGui.Name = "PetRandomizerGui"

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 220, 0, 180)
Frame.Position = UDim2.new(0.5, -110, 0.4, -90)
Frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
Frame.Active = true
Frame.Draggable = true

local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1,0,0,25)
Title.Text = "Egg Randomizer – by ScripterX"
Title.TextColor3 = Color3.fromRGB(255,255,255)
Title.BackgroundColor3 = Color3.fromRGB(40,40,40)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14

-- Buttons and input
local EggBtn = Instance.new("TextButton", Frame)
EggBtn.Size = UDim2.new(0.9,0,0,25)
EggBtn.Position = UDim2.new(0.05,0,0.25,0)
EggBtn.Text = "Choose Egg: Common Egg"
EggBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
EggBtn.TextColor3 = Color3.fromRGB(255,255,255)
EggBtn.Font = Enum.Font.Gotham
EggBtn.TextSize = 14

local HatchBtn = Instance.new("TextButton", Frame)
HatchBtn.Size = UDim2.new(0.9,0,0,25)
HatchBtn.Position = UDim2.new(0.05,0,0.45,0)
HatchBtn.Text = "Randomize Hatch"
HatchBtn.BackgroundColor3 = Color3.fromRGB(0,170,255)
HatchBtn.TextColor3 = Color3.fromRGB(255,255,255)
HatchBtn.Font = Enum.Font.GothamBold
HatchBtn.TextSize = 14

local AgeBox = Instance.new("TextBox", Frame)
AgeBox.Size = UDim2.new(0.9,0,0,25)
AgeBox.Position = UDim2.new(0.05,0,0.65,0)
AgeBox.PlaceholderText = "Enter Age (1–100)"
AgeBox.BackgroundColor3 = Color3.fromRGB(60,60,60)
AgeBox.TextColor3 = Color3.fromRGB(255,255,255)
AgeBox.Font = Enum.Font.Gotham
AgeBox.TextSize = 14

-- Egg → Pets mapping
local Pets = {
    ["Common Egg"] = {"Dog","Golden Lab","Bunny"},
    ["Bug Egg"] = {"Caterpillar","Snail","Giant Ant","Praying Mantis","Dragonfly"},
    ["Common Summer Egg"] = {"Starfish","Seagull","Crab"},
    ["Rare Summer Egg"] = {"Flamingo","Toucan","Sea Turtle","Orangutan","Seal"},
    ["Paradise Egg"] = {"Ostrich","Peacock","Capybara","Mimic Octopus"},
    ["Mythical Egg"] = {"Grey Mouse","Brown Mouse","Squirrel","Red Giant Ant","Red Fox"},
    ["Gourmet Egg"] = {"Bagel Bunny","Pancake Mole","Sushi Bear","Spaghetti Sloth","French Fry Ferret"},
    ["Sprout Egg"] = {"Dairy Cow","Jackalope","Sapling","Golem","Golden Goose"},
    ["Anti Bee Egg"] = {"Wasp","Tarantula Hawk","Moth","Butterfly","Disco Bee"},
    ["Bee Egg"] = {"Bee","Honey Bee","Bear Bee","Petal Bee","Queen Bee"},
    ["Night Egg"] = {"Hedgehog","Mole","Frog","Echo Frog","Night Owl","Raccoon"},
    ["Primal Egg"] = {"Parasaurolophus","Iguanodon","Pachycephalosaurus","Dilophosaurus","Ankylosaurus","Spinosaurus"},
    ["Dinosaur Egg"] = {"T-Rex","Brontosaurus","Pterodactyl","Raptor","Stegosaurus"},
    ["Zen Egg"] = {"Kitsune","Kodama","Nihonzaru","Shiba Inu","Tanchozuru","Raiju","Kappa","Red Fox"}
}

-- Egg selection cycle
local eggNames = {}
for name in pairs(Pets) do table.insert(eggNames, name) end
table.sort(eggNames)
local currentIndex = 1

EggBtn.MouseButton1Click:Connect(function()
    currentIndex = (currentIndex % #eggNames) + 1
    EggBtn.Text = "Choose Egg: " .. eggNames[currentIndex]
end)

-- Show result above the nearest egg in 3D world
local function showAboveEgg(petName, age)
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local nearest, dist = nil, math.huge
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name:lower():find("egg") then
            local d = (obj.Position - hrp.Position).magnitude
            if d < dist and d < 30 then
                nearest, dist = obj, d
            end
        end
    end

    if nearest then
        local billboard = Instance.new("BillboardGui", nearest)
        billboard.Size = UDim2.new(0,200,0,50)
        billboard.Adornee = nearest
        billboard.AlwaysOnTop = true
        billboard.StudsOffset = Vector3.new(0,3,0)

        local label = Instance.new("TextLabel", billboard)
        label.Size = UDim2.new(1,0,1,0)
        label.BackgroundTransparency = 1
        label.Text = ("You got: %s (Age: %d)"):format(petName, age)
        label.TextScaled = true
        label.TextColor3 = Color3.fromRGB(0,255,0)
        label.Font = Enum.Font.GothamBold

        game.Debris:AddItem(billboard, 5)
    end
end

-- Randomize logic
HatchBtn.MouseButton1Click:Connect(function()
    local pool = Pets[eggNames[currentIndex]]
    if not pool then return end
    local pet = pool[math.random(1, #pool)]
    local age = tonumber(AgeBox.Text)
    if not age or age < 1 or age > 100 then
        age = math.random(1, 100)
    end
    showAboveEgg(pet, age)
end)
