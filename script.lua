--========================================================================--
--  GROW A GARDEN 2 - WOODEN HUB  |  by: Toast42
--========================================================================--

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")
local Workspace = game:GetService("Workspace")
local ProximityPromptService = game:GetService("ProximityPromptService")

----------------------------------------------------------------
-- CLEANUP OLD VERSIONS
----------------------------------------------------------------
local TargetGuiParent = (gethui and gethui()) or CoreGui
for _, v in ipairs(TargetGuiParent:GetDescendants()) do
    if v.Name == "ToastHub_Wood" or v.Name == "ToastHub_V2" or v.Name == "ToastHub" then
        pcall(function() v:Destroy() end)
    end
end

if _G.ToastHubKeybind then ContextActionService:UnbindAction("ToastHubToggle") end
if _G.ToastHubLoop then _G.ToastHubLoop:Disconnect() end
if _G.ToastEventLoop then _G.ToastEventLoop:Disconnect() end
if _G.ToastClickTP then _G.ToastClickTP:Disconnect() end

----------------------------------------------------------------
-- GAME MODULES
----------------------------------------------------------------
local SeedData, Networking, PlayerStateClient, Replica

pcall(function() SeedData = require(ReplicatedStorage.SharedModules.SeedData) end)
pcall(function() Networking = require(ReplicatedStorage.SharedModules.Networking) end)
pcall(function()
    PlayerStateClient = require(ReplicatedStorage.ClientModules.PlayerStateClient)
    Replica = PlayerStateClient:WaitForLocalReplica(10)
end)

----------------------------------------------------------------
-- CONFIG 
----------------------------------------------------------------
local CFG_FILE = "Toast42_GAG2_Wood.json"
local CFG = { AutoBuy = false, AntiAFK = true, EventFarm = true, InstantPrompt = false, Seeds = {} }

local function Save()
    pcall(function() if writefile then writefile(CFG_FILE, HttpService:JSONEncode(CFG)) end end)
end
local function Load()
    pcall(function()
        if isfile and isfile(CFG_FILE) then
            local d = HttpService:JSONDecode(readfile(CFG_FILE))
            for k,v in pairs(d) do CFG[k]=v end
        end
    end)
end
Load()

local originalDurations = {} -- Store original hold durations

ProximityPromptService.PromptShown:Connect(function(prompt)
    if CFG.InstantPrompt then
        task.spawn(function()
            if not originalDurations[prompt] then
                originalDurations[prompt] = prompt.HoldDuration
            end
            prompt.HoldDuration = 0
        end)
    end
end)

----------------------------------------------------------------
-- BLOCK BUY SOUNDS (Metatable Hook - SAFE VERSION)
----------------------------------------------------------------
pcall(function()
    if getrawmetatable and hookmetamethod then
        local oldNamecall
        oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
            if not checkcaller() then
                local method = getnamecallmethod()
                -- Using ClassName instead of IsA to prevent recursive __namecall C Stack Overflow
                if method == "Play" and typeof(self) == "Instance" and self.ClassName == "Sound" then
                    if CFG.AutoBuy then
                        local block = false
                        pcall(function()
                            local sn = string.lower(self.Name)
                            if string.find(sn, "buy") or string.find(sn, "purchase") or string.find(sn, "cash") or string.find(sn, "coin") then
                                block = true
                            end
                        end)
                        if block then return end -- Mute the sound
                    end
                end
            end
            return oldNamecall(self, ...)
        end)
    end
end)

----------------------------------------------------------------
-- CREATE GUI
----------------------------------------------------------------
local Gui = Instance.new("ScreenGui")
Gui.Name = "ToastHub_Wood"
Gui.ResetOnSpawn = false
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function() if syn and syn.protect_gui then syn.protect_gui(Gui) end end)
Gui.Parent = TargetGuiParent

local Main = Instance.new("CanvasGroup")
Main.Name = "Main"
Main.Parent = Gui
Main.BackgroundColor3 = Color3.fromRGB(112, 72, 56)
Main.Size = UDim2.new(0, 750, 0, 480)
Main.Position = UDim2.new(0.5, -375, 0.5, -240)
Main.GroupTransparency = 0
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 16)

local Border = Instance.new("UIStroke", Main)
Border.Color = Color3.fromRGB(66, 40, 24)
Border.Thickness = 6

-- Pattern
local Pattern = Instance.new("ImageLabel", Main)
Pattern.BackgroundTransparency = 1
Pattern.Size = UDim2.new(1, 0, 1, 0)
Pattern.Image = "rbxassetid://4141697274"
Pattern.ImageTransparency = 0.6
Pattern.ScaleType = Enum.ScaleType.Tile
Pattern.TileSize = UDim2.new(0, 200, 0, 200)

-- ========== DRAG ==========
local dragConn, dragStart, startPos
Main.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
        dragStart = inp.Position
        startPos = Main.Position
        if dragConn then dragConn:Disconnect() end
        dragConn = inp.Changed:Connect(function()
            if inp.UserInputState == Enum.UserInputState.End then dragConn:Disconnect(); dragConn = nil end
        end)
    end
end)
UserInputService.InputChanged:Connect(function(inp)
    if dragStart and dragConn and (inp.UserInputType == Enum.UserInputType.MouseMovement) then
        local d = inp.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
    end
end)

-- ========== HEADER ==========
local Header = Instance.new("Frame", Main)
Header.BackgroundColor3 = Color3.fromRGB(86, 52, 38)
Header.Size = UDim2.new(1, 0, 0, 55)
Header.BorderSizePixel = 0
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 16)
local HFix = Instance.new("Frame", Header)
HFix.BackgroundColor3 = Header.BackgroundColor3
HFix.Size = UDim2.new(1, 0, 0, 16)
HFix.Position = UDim2.new(0, 0, 1, -16)
HFix.BorderSizePixel = 0
local HStroke = Instance.new("Frame", Header)
HStroke.BackgroundColor3 = Color3.fromRGB(66, 40, 24)
HStroke.Size = UDim2.new(1, 0, 0, 4)
HStroke.Position = UDim2.new(0, 0, 1, 0)
HStroke.BorderSizePixel = 0

local Title = Instance.new("TextLabel", Header)
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 20, 0, 0)
Title.Size = UDim2.new(0, 300, 1, 0)
Title.Font = Enum.Font.FredokaOne
Title.Text = "Toast's Garden"
Title.TextColor3 = Color3.fromRGB(255, 230, 180)
Title.TextSize = 28
Title.TextXAlignment = Enum.TextXAlignment.Left

local TitleShadow = Title:Clone()
TitleShadow.Parent = Header
TitleShadow.Position = UDim2.new(0, 22, 0, 2)
TitleShadow.TextColor3 = Color3.fromRGB(50, 30, 20)
TitleShadow.ZIndex = 0

local WM = Instance.new("TextLabel", Header)
WM.BackgroundTransparency = 1
WM.Position = UDim2.new(1, -150, 0, 0)
WM.Size = UDim2.new(0, 130, 1, 0)
WM.Font = Enum.Font.FredokaOne
WM.Text = "by: Toast42"
WM.TextColor3 = Color3.fromRGB(200, 170, 120)
WM.TextSize = 18
WM.TextXAlignment = Enum.TextXAlignment.Right

-- ========== CONTENT PANELS ==========
local function MakePanel(pos, size)
    local P = Instance.new("Frame", Main)
    P.BackgroundColor3 = Color3.fromRGB(140, 95, 75)
    P.Position = pos
    P.Size = size
    Instance.new("UICorner", P).CornerRadius = UDim.new(0, 10)
    Instance.new("UIStroke", P).Color = Color3.fromRGB(66, 40, 24)
    Instance.new("UIStroke", P).Thickness = 3
    return P
end

local ShopPanel = MakePanel(UDim2.new(0, 15, 0, 75), UDim2.new(0, 480, 0, 340))
local CtrlPanel = MakePanel(UDim2.new(0, 510, 0, 75), UDim2.new(0, 225, 0, 340))

-- Shop Title
local ShopTitle = Instance.new("TextLabel", ShopPanel)
ShopTitle.BackgroundTransparency = 1
ShopTitle.Position = UDim2.new(0, 15, 0, 10)
ShopTitle.Size = UDim2.new(1, -30, 0, 30)
ShopTitle.Font = Enum.Font.FredokaOne
ShopTitle.Text = "Seed Shop Auto-Buyer"
ShopTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
ShopTitle.TextSize = 22
ShopTitle.TextXAlignment = Enum.TextXAlignment.Left

local ShopStatus = Instance.new("TextLabel", ShopPanel)
ShopStatus.BackgroundTransparency = 1
ShopStatus.Position = UDim2.new(0, 15, 0, 35)
ShopStatus.Size = UDim2.new(1, -30, 0, 20)
ShopStatus.Font = Enum.Font.FredokaOne
ShopStatus.Text = "Status: Idle"
ShopStatus.TextColor3 = Color3.fromRGB(255, 220, 150)
ShopStatus.TextSize = 14
ShopStatus.TextXAlignment = Enum.TextXAlignment.Left

-- ========== SEED LIST ==========
local SeedScroll = Instance.new("ScrollingFrame", ShopPanel)
SeedScroll.BackgroundTransparency = 1
SeedScroll.Position = UDim2.new(0, 10, 0, 65)
SeedScroll.Size = UDim2.new(1, -20, 1, -75)
SeedScroll.ScrollBarThickness = 8
SeedScroll.ScrollBarImageColor3 = Color3.fromRGB(66, 40, 24)
SeedScroll.BorderSizePixel = 0

local Layout = Instance.new("UIGridLayout", SeedScroll)
Layout.CellSize = UDim2.new(0, 220, 0, 75)
Layout.CellPadding = UDim2.new(0, 10, 0, 10)
Layout.SortOrder = Enum.SortOrder.LayoutOrder

Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    SeedScroll.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 10)
end)

local RarityCol = {
    Common = Color3.fromRGB(200,200,200),
    Uncommon = Color3.fromRGB(100,255,100),
    Rare = Color3.fromRGB(80,180,255),
    Epic = Color3.fromRGB(200,80,255),
    Legendary = Color3.fromRGB(255,215,0),
    Mythic = Color3.fromRGB(255,80,80),
    Secret = Color3.fromRGB(255,100,200),
}

-- Fetch seeds from shop to ensure none are skipped
local shopItems = ReplicatedStorage:FindFirstChild("StockValues")
if shopItems then shopItems = shopItems:FindFirstChild("SeedShop") end
if shopItems then shopItems = shopItems:FindFirstChild("Items") end

if shopItems then
    local seeds = {}
    for _, item in ipairs(shopItems:GetChildren()) do
        local name = item.Name
        local price = 0
        local rarity = "Common"
        local imgId = ""
        local layoutOrder = 999
        
        if SeedData then
            for i, sd in ipairs(SeedData) do
                if sd.SeedName == name then
                    price = sd.PurchasePrice or 0
                    rarity = sd.Rarity or "Common"
                    pcall(function() imgId = sd.SeedImage.Value end)
                    layoutOrder = i -- Keep original game layout order
                    break
                end
            end
        end
        
        table.insert(seeds, {
            Name = name,
            Price = price,
            Rarity = rarity,
            Image = imgId,
            Order = layoutOrder
        })
    end
    
    table.sort(seeds, function(a, b) return a.Order < b.Order end)

    for i, v in ipairs(seeds) do
        local name = v.Name
        local price = v.Price
        local rarity = v.Rarity
        local imgId = v.Image

        local Card = Instance.new("TextButton", SeedScroll)
        Card.BackgroundColor3 = Color3.fromRGB(120, 75, 55)
        Card.AutoButtonColor = false
        Card.Text = ""
        Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 8)
        Instance.new("UIStroke", Card).Color = Color3.fromRGB(66, 40, 24)
        Instance.new("UIStroke", Card).Thickness = 2
        Card.LayoutOrder = i

        local Ico = Instance.new("ImageLabel", Card)
        Ico.BackgroundColor3 = Color3.fromRGB(100, 60, 45)
        Ico.Position = UDim2.new(0, 5, 0, 12)
        Ico.Size = UDim2.new(0, 50, 0, 50)
        Ico.Image = imgId
        Instance.new("UICorner", Ico).CornerRadius = UDim.new(0, 6)

        local Nm = Instance.new("TextLabel", Card)
        Nm.BackgroundTransparency = 1
        Nm.Position = UDim2.new(0, 65, 0, 5)
        Nm.Size = UDim2.new(1, -100, 0, 25)
        Nm.Font = Enum.Font.FredokaOne
        Nm.Text = name
        Nm.TextColor3 = Color3.fromRGB(255,255,255)
        Nm.TextSize = 16
        Nm.TextXAlignment = Enum.TextXAlignment.Left

        local function formatMoney(n)
            if n >= 1000000 then
                return string.format("%gM", n / 1000000) .. "¢"
            elseif n >= 1000 then
                return string.format("%gK", n / 1000) .. "¢"
            else
                return tostring(n) .. "¢"
            end
        end

        local Info = Instance.new("TextLabel", Card)
        Info.BackgroundTransparency = 1
        Info.Position = UDim2.new(0, 65, 0, 30)
        Info.Size = UDim2.new(1, -100, 0, 20)
        Info.Font = Enum.Font.FredokaOne
        Info.Text = price > 0 and formatMoney(price) or "Event"
        Info.TextColor3 = RarityCol[rarity] or RarityCol.Common
        Info.TextSize = 14
        Info.TextXAlignment = Enum.TextXAlignment.Left

        local stockStr = "OUT OF STOCK"
        local stockCol = Color3.fromRGB(255, 100, 100)

        local StockLabel = Instance.new("TextLabel", Card)
        StockLabel.BackgroundTransparency = 1
        StockLabel.Position = UDim2.new(0, 65, 0, 50)
        StockLabel.Size = UDim2.new(1, -100, 0, 20)
        StockLabel.Font = Enum.Font.FredokaOne
        StockLabel.Text = stockStr
        StockLabel.TextColor3 = stockCol
        StockLabel.TextSize = 12
        StockLabel.TextXAlignment = Enum.TextXAlignment.Left

        pcall(function()
            local sv = shopItems:FindFirstChild(name)
            if sv then
                local function updateStock()
                    if sv.Value > 0 then
                        StockLabel.Text = "IN STOCK (" .. sv.Value .. ")"
                        StockLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
                    else
                        StockLabel.Text = "OUT OF STOCK"
                        StockLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
                    end
                end
                updateStock()
                sv:GetPropertyChangedSignal("Value"):Connect(updateStock)
            end
        end)

        local Chk = Instance.new("TextButton", Card)
        Chk.Size = UDim2.new(0, 26, 0, 26)
        Chk.Position = UDim2.new(1, -34, 0.5, -13)
        Chk.BackgroundColor3 = CFG.Seeds[name] and Color3.fromRGB(80, 200, 100) or Color3.fromRGB(90, 55, 40)
        Chk.Text = CFG.Seeds[name] and "X" or ""
        Chk.Font = Enum.Font.FredokaOne
        Chk.TextColor3 = Color3.fromRGB(255,255,255)
        Chk.TextSize = 18
        Instance.new("UICorner", Chk).CornerRadius = UDim.new(0, 6)
        Instance.new("UIStroke", Chk).Color = Color3.fromRGB(66, 40, 24)
        Instance.new("UIStroke", Chk).Thickness = 2

        local function toggle()
            CFG.Seeds[name] = not CFG.Seeds[name] or nil
            local on = CFG.Seeds[name]
            Chk.BackgroundColor3 = on and Color3.fromRGB(80, 200, 100) or Color3.fromRGB(90, 55, 40)
            Chk.Text = on and "X" or ""
            Save()
        end
        Chk.Activated:Connect(toggle)
        Card.Activated:Connect(toggle)
    end
end

-- ========== CONTROL BUTTONS ==========
local function MakeMenuBtn(parent, pos, label, default, callback)
    local Btn = Instance.new("TextButton", parent)
    Btn.Position = pos
    Btn.Size = UDim2.new(1, -20, 0, 45)
    Btn.BackgroundColor3 = default and Color3.fromRGB(100, 180, 100) or Color3.fromRGB(120, 75, 55)
    Btn.Text = label
    Btn.Font = Enum.Font.FredokaOne
    Btn.TextColor3 = Color3.fromRGB(255,255,255)
    Btn.TextSize = 18
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)
    Instance.new("UIStroke", Btn).Color = Color3.fromRGB(66, 40, 24)
    Instance.new("UIStroke", Btn).Thickness = 3

    local state = default
    Btn.Activated:Connect(function()
        state = not state
        Btn.BackgroundColor3 = state and Color3.fromRGB(100, 180, 100) or Color3.fromRGB(120, 75, 55)
        callback(state)
    end)
end

MakeMenuBtn(CtrlPanel, UDim2.new(0, 10, 0, 15), "Auto-Buy Seeds", CFG.AutoBuy, function(v)
    CFG.AutoBuy = v; Save()
end)

MakeMenuBtn(CtrlPanel, UDim2.new(0, 10, 0, 75), "Anti-AFK", CFG.AntiAFK, function(v)
    CFG.AntiAFK = v; Save()
end)

MakeMenuBtn(CtrlPanel, UDim2.new(0, 10, 0, 135), "Auto-Event Farm", CFG.EventFarm, function(v)
    CFG.EventFarm = v; Save()
end)

MakeMenuBtn(CtrlPanel, UDim2.new(0, 10, 0, 195), "Instant Prompt", CFG.InstantPrompt, function(v)
    CFG.InstantPrompt = v; Save()
    if not v then
        task.spawn(function()
            for prompt, originalTime in pairs(originalDurations) do
                if prompt and prompt.Parent then
                    prompt.HoldDuration = originalTime
                end
            end
            table.clear(originalDurations)
        end)
    end
end)

local InfoTxt = Instance.new("TextLabel", CtrlPanel)
InfoTxt.BackgroundTransparency = 1
InfoTxt.Position = UDim2.new(0, 10, 0, 255)
InfoTxt.Size = UDim2.new(1, -20, 0, 50)
InfoTxt.Font = Enum.Font.FredokaOne
InfoTxt.Text = "TELEPORT: 'Z' key\nHIDE MENU: RightShift"
InfoTxt.TextColor3 = Color3.fromRGB(255, 230, 180)
InfoTxt.TextSize = 14
InfoTxt.TextWrapped = true

-- ========== USER INFO ==========
local UBox = Instance.new("Frame", Main)
UBox.BackgroundColor3 = Color3.fromRGB(86, 52, 38)
UBox.Position = UDim2.new(0, 15, 1, -60)
UBox.Size = UDim2.new(1, -30, 0, 50)
Instance.new("UICorner", UBox).CornerRadius = UDim.new(0, 10)
Instance.new("UIStroke", UBox).Color = Color3.fromRGB(66, 40, 24)
Instance.new("UIStroke", UBox).Thickness = 3

local Ava = Instance.new("ImageLabel", UBox)
Ava.BackgroundColor3 = Color3.fromRGB(66, 40, 24)
Ava.Position = UDim2.new(0, 5, 0, 5)
Ava.Size = UDim2.new(0, 40, 0, 40)
Instance.new("UICorner", Ava).CornerRadius = UDim.new(1, 0)
pcall(function() Ava.Image = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100) end)

local DN = Instance.new("TextLabel", UBox)
DN.BackgroundTransparency = 1
DN.Position = UDim2.new(0, 55, 0, 5)
DN.Size = UDim2.new(0, 300, 0, 20)
DN.Font = Enum.Font.FredokaOne
DN.Text = LocalPlayer.DisplayName
DN.TextColor3 = Color3.fromRGB(255, 255, 255)
DN.TextSize = 18
DN.TextXAlignment = Enum.TextXAlignment.Left

local UN = Instance.new("TextLabel", UBox)
UN.BackgroundTransparency = 1
UN.Position = UDim2.new(0, 55, 0, 25)
UN.Size = UDim2.new(0, 300, 0, 20)
UN.Font = Enum.Font.FredokaOne
UN.Text = "@"..LocalPlayer.Name
UN.TextColor3 = Color3.fromRGB(200, 170, 120)
UN.TextSize = 14
UN.TextXAlignment = Enum.TextXAlignment.Left

-- ========== AUTO BUY SYSTEM ==========
local lastStock = {}

local function GetShopTimer()
    local res = "Scanning..."
    pcall(function()
        local pg = LocalPlayer:FindFirstChild("PlayerGui")
        local ui = pg and pg:FindFirstChild("UI")
        local main = ui and ui:FindFirstChild("Main")
        local ss = main and main:FindFirstChild("SeedShop")
        
        if ss then
            for _, v in ipairs(ss:GetDescendants()) do
                if v:IsA("TextLabel") and string.find(string.lower(v.Text), "restock in") then
                    res = v.Text
                    break
                end
            end
        end
    end)
    return res
end

_G.ToastHubLoop = RunService.Heartbeat:Connect(function()
    if not CFG.AutoBuy then
        ShopStatus.Text = "Status: Idle"
        return
    end

    local money = 0
    pcall(function()
        if Replica and Replica.Data then money = Replica.Data.Sheckles or 0 end
    end)
    if money == 0 then
        pcall(function()
            local obj = LocalPlayer:FindFirstChild("leaderstats")
            obj = obj and obj:FindFirstChild("Sheckles")
            if obj then money = obj.Value end
        end)
    end

    local stockFolder
    pcall(function() stockFolder = ReplicatedStorage.StockValues.SeedShop.Items end)

    local bought = false
    local broke = true

    for seedName, sel in pairs(CFG.Seeds) do
        if not sel then continue end

        local price = 999999
        if SeedData then
            for _, v in ipairs(SeedData) do
                if v.SeedName == seedName then price = v.PurchasePrice or 999999; break end
            end
        end

        if money >= price then
            broke = false
            local sv = stockFolder and stockFolder:FindFirstChild(seedName)
            
            if sv and sv.Value > 0 then
                -- Buy ALL available stock at once
                if lastStock[seedName] ~= sv.Value then
                    lastStock[seedName] = sv.Value
                    
                    local toBuy = sv.Value
                    if money < (toBuy * price) then
                        toBuy = math.floor(money / price)
                    end
                    
                    if toBuy > 0 then
                        ShopStatus.Text = "Bought " .. toBuy .. "x " .. seedName .. "!"
                        for i = 1, toBuy do
                            pcall(function() Networking.SeedShop.PurchaseSeed:Fire(seedName) end)
                        end
                        bought = true
                        money = money - (toBuy * price)
                    end
                end
            else
                -- If it goes out of stock, reset lastStock so it can buy again later
                lastStock[seedName] = 0
            end
        end
    end

    if not bought and broke then
        ShopStatus.Text = "Waiting for money... (" .. money .. "c)"
    elseif not bought then
        ShopStatus.Text = GetShopTimer()
    end
end)

-- ========== EVENT SEED FARMER ==========
local function firePrompt(prompt)
    if prompt:IsA("ProximityPrompt") then
        if fireproximityprompt then
            fireproximityprompt(prompt, 1)
        else
            pcall(function()
                prompt:InputHoldBegin()
                task.wait(prompt.HoldDuration + 0.1)
                prompt:InputHoldEnd()
            end)
        end
    end
end

local eventDebounce = false
_G.ToastEventLoop = RunService.Heartbeat:Connect(function()
    if not CFG.EventFarm or eventDebounce then return end
    
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end

    local hrp = char.HumanoidRootPart

    for _, v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("ProximityPrompt") then
            local text = string.lower(v.ActionText .. " " .. v.ObjectText)
            if string.find(text, "gold") or string.find(text, "rainbow") or string.find(text, "star") then
                local part = v.Parent
                if part and part:IsA("BasePart") then
                    eventDebounce = true
                    local origCFrame = hrp.CFrame
                    
                    -- Teleport to the seed
                    hrp.CFrame = part.CFrame * CFrame.new(0, 3, 0)
                    task.wait(0.2) -- Wait for server to register position
                    
                    local oldDur = v.HoldDuration
                    if CFG.InstantPrompt then v.HoldDuration = 0 end
                    firePrompt(v)
                    
                    task.wait(0.5) -- Wait for prompt to finish collecting
                    if CFG.InstantPrompt then v.HoldDuration = oldDur end
                    
                    -- Teleport back
                    hrp.CFrame = origCFrame
                    task.wait(0.5) -- Wait a bit before farming next to avoid anti-cheat
                    eventDebounce = false
                    return
                end
            end
        end
    end
end)

-- ========== CLICK TELEPORT ==========
local Mouse = LocalPlayer:GetMouse()
_G.ToastClickTP = UserInputService.InputBegan:Connect(function(inp, gp)
    if not gp and inp.KeyCode == Enum.KeyCode.Z then
        if Mouse.Hit then
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local hrp = char.HumanoidRootPart
                local target = Mouse.Hit.Position + Vector3.new(0, 3, 0)
                local lookDir = (target - hrp.Position)
                local lookPos = target + Vector3.new(lookDir.X, 0, lookDir.Z)
                if lookDir.Magnitude < 0.1 then lookPos = target + hrp.CFrame.LookVector end
                TweenService:Create(hrp, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {CFrame = CFrame.lookAt(target, lookPos)}):Play()
            end
        end
    end
end)

-- ========== SHIFT LOCK OVERRIDE ==========
local isToggling = false
ContextActionService:BindActionAtPriority("ToastHubToggle", function(actionName, state, input)
    if state == Enum.UserInputState.Begin then
        if isToggling then return Enum.ContextActionResult.Sink end
        isToggling = true
        
        if Main.Visible then
            local tw = TweenService:Create(Main, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {GroupTransparency = 1})
            tw:Play()
            tw.Completed:Wait()
            Main.Visible = false
        else
            Main.Visible = true
            local tw = TweenService:Create(Main, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {GroupTransparency = 0})
            tw:Play()
            tw.Completed:Wait()
        end
        isToggling = false
        return Enum.ContextActionResult.Sink 
    end
    return Enum.ContextActionResult.Pass
end, false, 999999, Enum.KeyCode.RightShift)

-- ========== ANTI-AFK ==========
LocalPlayer.Idled:Connect(function()
    if CFG.AntiAFK then
        VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end
end)

warn("[Toast42 Wood Hub] Final Version Loaded!")
