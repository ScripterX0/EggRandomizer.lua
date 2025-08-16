-- Egg Randomizer – Grow a Garden Theme by ScripterX (Modified with Hatch Popup)

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
Frame.Size = UDim2.new(0, 260, 0, 220)
Frame.Position = UDim2.new(0.5, -130, 0.4, -110)
Frame.BackgroundColor3 = Color3.fromRGB(102, 51, 0)
Frame.BorderSizePixel = 3
Frame.Active = true
Frame.Draggable = true
Frame.ClipsDescendants = true
Frame.BackgroundTransparency = 0.05

local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1,0,0,30)
Title.Text = "🌱 Egg Randomizer – Grow a Garden 🌱"
Title.TextColor3 = Color3.fromRGB(255,255,255)
Title.BackgroundColor3 = Color3.fromRGB(34,139,34)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16

-- Egg selector
local EggBox = Instance.new("TextButton", Frame)
EggBox.Size = UDim2.new(0.9,0,0,30)
EggBox.Position = UDim2.new(0.05,0,0.18,0)
EggBox.Text = "Select Egg"
EggBox.BackgroundColor3 = Color3.fromRGB(139, 69, 19)
EggBox.TextColor3 = Color3.fromRGB(255,255,255)
EggBox.Font = Enum.Font.Gotham
EggBox.TextSize = 14

local Scroller = Instance.new("ScrollingFrame", Frame)
Scroller.Size = UDim2.new(0.9,0,0.4,0)
Scroller.Position = UDim2.new(0.05,0,0.18,0)
Scroller.CanvasSize = UDim2.new(0,0,0,0)
Scroller.ScrollBarThickness = 6
Scroller.BackgroundColor3 = Color3.fromRGB(205, 133, 63)
Scroller.Visible = false
Scroller.ClipsDescendants = true

local UIListLayout = Instance.new("UIListLayout", Scroller)
UIListLayout.Padding = UDim.new(0,4)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- Hatch button
local HatchBtn = Instance.new("TextButton", Frame)
HatchBtn.Size = UDim2.new(0.9,0,0,30)
HatchBtn.Position = UDim2.new(0.05,0,0.65,0)
HatchBtn.Text = "🌼 Randomize Hatch 🌼"
HatchBtn.BackgroundColor3 = Color3.fromRGB(46,139,87)
HatchBtn.TextColor3 = Color3.fromRGB(255,255,255)
HatchBtn.Font = Enum.Font.GothamBold
HatchBtn.TextSize = 14

-- Age box
local AgeBox = Instance.new("TextBox", Frame)
AgeBox.Size = UDim2.new(0.9,0,0,30)
AgeBox.Position = UDim2.new(0.05,0,0.82,0)
AgeBox.PlaceholderText = "Enter Age (1–100)"
AgeBox.BackgroundColor3 = Color3.fromRGB(222,184,135)
AgeBox.TextColor3 = Color3.fromRGB(0,0,0)
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

-- Variables
local selectedEgg = nil
local activeBillboard = nil

-- Create egg buttons
for eggName in pairs(Pets) do
    local Btn = Instance.new("TextButton", Scroller)
    Btn.Size = UDim2.new(1, -10, 0, 25)
    Btn.Text = eggName
    Btn.BackgroundColor3 = Color3.fromRGB(240,240,240)
    Btn.TextColor3 = Color3.fromRGB(0,0,0)
    Btn.Font = Enum.Font.Gotham
    Btn.TextSize = 14

    Btn.MouseButton1Click:Connect(function()
        selectedEgg = eggName
        EggBox.Text = "🥚 " .. eggName
        Scroller.Visible = false
        EggBox.Visible = true
    end)
end
Scroller.CanvasSize = UDim2.new(0,0,0,#Scroller:GetChildren()*30)

EggBox.MouseButton1Click:Connect(function()
    EggBox.Visible = false
    Scroller.Visible = true
end)

-- Billboard above egg
local function showAboveEgg(petName, age)
    if activeBillboard then
        activeBillboard:Destroy()
    end

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
        label.Text = ("%s (Age: %d)"):format(petName, age)
        label.TextScaled = true
        label.TextColor3 = Color3.fromRGB(0,100,0)
        label.Font = Enum.Font.GothamBold

        activeBillboard = billboard
    end
end

-- Popup reveal
local function showPopup(petName, eggName)
    local popup = Instance.new("Frame", ScreenGui)
    popup.Size = UDim2.new(0,300,0,150)
    popup.Position = UDim2.new(0.5,-150,0.5,-75)
    popup.BackgroundColor3 = Color3.fromRGB(255, 255, 200)
    popup.BorderSizePixel = 3

    local title = Instance.new("TextLabel", popup)
    title.Size = UDim2.new(1,0,0.3,0)
    title.BackgroundTransparency = 1
    title.Text = "🎉 You hatched from "..eggName.."! 🎉"
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.TextColor3 = Color3.fromRGB(0,0,0)

    local petLabel = Instance.new("TextLabel", popup)
    petLabel.Size = UDim2.new(1,0,0.5,0)
    petLabel.Position = UDim2.new(0,0,0.3,0)
    petLabel.BackgroundTransparency = 1
    petLabel.Text = petName
    petLabel.Font = Enum.Font.GothamBold
    petLabel.TextSize = 28
    petLabel.TextColor3 = Color3.fromRGB(50,100,200)

    local closeBtn = Instance.new("TextButton", popup)
    closeBtn.Size = UDim2.new(0.4,0,0.2,0)
    closeBtn.Position = UDim2.new(0.3,0,0.8,0)
    closeBtn.Text = "OK"
    closeBtn.BackgroundColor3 = Color3.fromRGB(200,200,200)
    closeBtn.Font = Enum.Font.Gotham
    closeBtn.TextSize = 14
    closeBtn.MouseButton1Click:Connect(function()
        popup:Destroy()
    end)
end

-- Randomize logic
HatchBtn.MouseButton1Click:Connect(function()
    if not selectedEgg then return end
    local pool = Pets[selectedEgg]
    if not pool then return end
    local pet = pool[math.random(1, #pool)]
    local age = tonumber(AgeBox.Text)
    if not age or age < 1 or age > 100 then
        age = math.random(1, 100)
    end
    showAboveEgg(pet, age)
    showPopup(pet, selectedEgg) -- << hatch popup added
end)
