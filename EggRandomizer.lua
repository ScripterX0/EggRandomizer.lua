-- Egg Randomizer – Grow a Garden Theme by ScripterX (Modified with Pet Popup)

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
Frame.BackgroundColor3 = Color3.fromRGB(102, 51, 0) -- Soil brown
Frame.BorderSizePixel = 3
Frame.Active = true
Frame.Draggable = true
Frame.ClipsDescendants = true
Frame.BackgroundTransparency = 0.05

local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1,0,0,30)
Title.Text = "🌱 Egg Randomizer – Grow a Garden 🌱"
Title.TextColor3 = Color3.fromRGB(255,255,255)
Title.BackgroundColor3 = Color3.fromRGB(34,139,34) -- Garden green
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16

-- Egg Selector
local EggBox = Instance.new("TextButton", Frame)
EggBox.Size = UDim2.new(0.9,0,0,30)
EggBox.Position = UDim2.new(0.05,0,0.18,0)
EggBox.Text = "Select Egg"
EggBox.BackgroundColor3 = Color3.fromRGB(139, 69, 19)
EggBox.TextColor3 = Color3.fromRGB(255,255,255)
EggBox.Font = Enum.Font.Gotham
EggBox.TextSize = 14
EggBox.AutoButtonColor = true

-- Scrollable Egg List
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
HatchBtn.Text = "🎲 Randomize 🎲" -- << changed text here  
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
local activePetPopup = nil

-- Egg button generator
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

-- Show pet popup above player
local function spawnPetPopup(petName, age)
    if activePetPopup then
        activePetPopup:Destroy()
    end

    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local popup = Instance.new("BillboardGui", char)
    popup.Size = UDim2.new(0, 150, 0, 50)
    popup.Adornee = hrp
    popup.StudsOffset = Vector3.new(0, 4, 0)
    popup.AlwaysOnTop = true

    local label = Instance.new("TextLabel", popup)
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = "🎉 You got: " .. petName .. " (Age " .. age .. ") 🎉"
    label.TextColor3 = Color3.fromRGB(255, 215, 0)
    label.TextStrokeTransparency = 0.2
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold

    activePetPopup = popup

    -- Auto-remove after 5 seconds
    game:GetService("Debris"):AddItem(popup, 5)
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

    spawnPetPopup(pet, age)
end)
