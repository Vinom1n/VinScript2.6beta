-- Author: Vinomin (tg: @vinom1n)
-- VinScript
-- Maded by Vinomin

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer

-- ========================================
-- DISCORD RICH PRESENCE MODULE (PRIORITY)
-- ========================================

-- Discord Webhook для уведомлений
local DISCORD_WEBHOOK = "https://discord.com/api/webhooks/1436051750032506911/7GrHKIkXFu3hYnWoUhf97jmKRd0im41OuhCORhYUptt59jAI3lzooYfnt_6NxRmDBl3x"

local DiscordRichPresence = {}

-- Проверка наличия функций HTTP запросов
local function getHttpRequest()
    return (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
end

function DiscordRichPresence.Initialize()
    local success, result = pcall(function()
        local httpRequest = getHttpRequest()
        
        if syn and syn.websocket then
            local discordApp = syn.websocket.connect("wss://gateway.discord.gg/?v=10&encoding=json")
            
            if discordApp then
                print("[Discord Rich Presence] ✅ Connected via Synapse WebSocket!")
                
                local presence = {
                    op = 3,
                    d = {
                        activities = {{
                            name = "VinScript",
                            type = 0,
                            details = "Using VinScript v2.0",
                            state = "Premium Cheat Menu",
                            timestamps = {
                                start = os.time()
                            },
                            assets = {
                                large_image = "vinscript_logo",
                                large_text = "VinScript v2.0"
                            }
                        }},
                        status = "online",
                        since = os.time() * 1000,
                        afk = false
                    }
                }
                
                discordApp:Send(HttpService:JSONEncode(presence))
                return true
            end
        end
        
        if DISCORD_WEBHOOK ~= "" and httpRequest then
            local gameInfo = pcall(function()
                return game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
            end) and game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name or "Unknown Game"
            
            local webhookData = {
                Url = DISCORD_WEBHOOK,
                Method = "POST",
                Headers = {
                    ["Content-Type"] = "application/json"
                },
                Body = HttpService:JSONEncode({
                    content = "<@873893790371430440>",
                    username = "VinScript | Notification",
                    avatar_url = "https://i.imgur.com/VinScript.png",
                    embeds = {{
                        title = "🟪 VinScript Premium 🟪",
                        description = "**_" .. player.Name .. "_** запустил 🟪**VinScript**🟪 **Premium!**\n\n" ..
                                      "✅ **Хочешь чтобы другие пользователи видели такое же уведомление?**\n" ..
                                      "**Приобрети премиум версию по низкой цене!** ✅\n\n" ..
                                      "💎 **Приобрести:** ??? (soon...) 💎\n\n" ..
                                      "=======================================",
                        color = 10181046,
                        fields = {
                            {name = "👤 Пользователь", value = "```" .. player.Name .. "```", inline = true},
                            {name = "🎮 Игра", value = "```" .. gameInfo .. "```", inline = true},
                            {name = "⏰ Время", value = "```" .. os.date("%H:%M:%S") .. "```", inline = true},
                            {name = "📦 Версия", value = "```VinScript v2.0```", inline = true},
                            {name = "🔥 Статус", value = "```Premium Active```", inline = true},
                            {name = "🌐 Place ID", value = "```" .. game.PlaceId .. "```", inline = true}
                        },
                        footer = {
                            text = "Author: @Vinomin • VinScript Premium",
                            icon_url = "https://i.imgur.com/vinomin-avatar.png"
                        },
                        thumbnail = {
                            url = "https://i.imgur.com/VinScript-logo.png"
                        },
                        timestamp = os.date("!%Y-%m-%dT%H:%M:%S")
                    }}
                })
            }
            
            httpRequest(webhookData)
            print("[Discord Rich Presence] ✅ Activity sent via Webhook!")
            print("[Discord Rich Presence] 🟪 Premium notification sent with author mention!")
            return true
        end
        
        print("[Discord Rich Presence] ℹ️ Running in local mode")
        print("[Discord Rich Presence] User: " .. player.Name)
        
        return true
    end)
    
    if success and result then
        print("[Discord Rich Presence] ✅ Successfully initialized!")
        return true
    else
        print("[Discord Rich Presence] ⚠️ Limited functionality - " .. tostring(result))
        return false
    end
end

function DiscordRichPresence.UpdateStatus(statusText)
    pcall(function()
        local httpRequest = getHttpRequest()
        
        if DISCORD_WEBHOOK ~= "" and httpRequest then
            local webhookData = {
                Url = DISCORD_WEBHOOK,
                Method = "POST",
                Headers = {
                    ["Content-Type"] = "application/json"
                },
                Body = HttpService:JSONEncode({
                    username = "VinScript | Notification",
                    avatar_url = "https://i.imgur.com/VinScript.png",
                    embeds = {{
                        title = "🔄 Status Update",
                        description = "**" .. statusText .. "**\n\n" ..
                                      "Пользователь: **" .. player.Name .. "**\n" ..
                                      "Время: **" .. os.date("%H:%M:%S") .. "**",
                        color = 3447003,
                        footer = {
                            text = "Author: @Vinomin • VinScript Premium",
                            icon_url = "https://i.imgur.com/vinomin-avatar.png"
                        },
                        timestamp = os.date("!%Y-%m-%dT%H:%M:%S")
                    }}
                })
            }
            
            httpRequest(webhookData)
        else
            print("[Discord Rich Presence] Status: " .. statusText)
        end
    end)
end

-- ========================================
-- ANTI-CHEAT BYPASS MODULE
-- ========================================

local AntiCheatBypass = {}

-- Сохраняем оригинальные функции до их перехвата
local originalMethods = {
    newindex = getrawmetatable and getrawmetatable(game).__newindex or nil,
    namecall = getrawmetatable and getrawmetatable(game).__namecall or nil,
    index = getrawmetatable and getrawmetatable(game).__index or nil
}

-- Скрываем executor environment
local function hideExecutorEnvironment()
    local suspiciousGlobals = {
        "syn", "Synapse", "synapse",
        "SENTINEL_V2", "sentinel",
        "KRNL_LOADED", "krnl",
        "OXYGEN_LOADED", "oxygen",
        "fluxus", "FLUXUS_LOADED",
        "solara", "Solara", "SOLARA_LOADED",
        "getexecutorname", "identifyexecutor",
        "isexecutorclosure", "checkcaller"
    }
    
    for _, globalName in ipairs(suspiciousGlobals) do
        pcall(function()
            getfenv()[globalName] = nil
            _G[globalName] = nil
        end)
    end
end

-- Защита метатаблицы
local function protectMetatable()
    if not getrawmetatable then return end
    
    local mt = getrawmetatable(game)
    local oldNamecall = mt.__namecall
    local oldIndex = mt.__index
    local oldNewindex = mt.__newindex
    
    setreadonly(mt, false)
    
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        
        if method == "FireServer" or method == "InvokeServer" then
            local remoteName = tostring(self)
            
            local blacklist = {
                "anticheat", "AntiCheat", "AC", "detection",
                "kick", "ban", "report", "log", "security",
                "validate", "check", "verify"
            }
            
            for _, keyword in ipairs(blacklist) do
                if string.find(string.lower(remoteName), string.lower(keyword)) then
                    return
                end
            end
        end
        
        return oldNamecall(self, ...)
    end)
    
    mt.__index = newcclosure(function(self, key)
        if key == "__namecall" or key == "__index" or key == "__newindex" then
            return originalMethods[key:sub(3)]
        end
        return oldIndex(self, key)
    end)
    
    mt.__newindex = newcclosure(function(self, key, value)
        local suspiciousProps = {
            "WalkSpeed", "JumpPower", "JumpHeight",
            "HipHeight", "MaxSlopeAngle", "Health",
            "MaxHealth", "CFrame", "Position", "Velocity"
        }
        
        for _, prop in ipairs(suspiciousProps) do
            if key == prop then
                task.wait(0.02)
            end
        end
        
        return oldNewindex(self, key, value)
    end)
    
    setreadonly(mt, true)
end

-- Защита Remote Events
local blockedRemotes = {}

local function setupRemoteProtection()
    for _, descendant in pairs(game:GetDescendants()) do
        if descendant:IsA("RemoteEvent") or descendant:IsA("RemoteFunction") then
            local remoteName = descendant.Name:lower()
            
            if string.match(remoteName, "anti") or 
               string.match(remoteName, "cheat") or
               string.match(remoteName, "detect") or
               string.match(remoteName, "security") or
               string.match(remoteName, "kick") or
               string.match(remoteName, "ban") then
                
                blockedRemotes[descendant] = true
                
                if descendant:IsA("RemoteEvent") then
                    pcall(function()
                        descendant.OnClientEvent:Connect(function() end)
                    end)
                end
            end
        end
    end
    
    game.DescendantAdded:Connect(function(descendant)
        if descendant:IsA("RemoteEvent") or descendant:IsA("RemoteFunction") then
            local remoteName = descendant.Name:lower()
            
            if string.match(remoteName, "anti") or 
               string.match(remoteName, "cheat") or
               string.match(remoteName, "detect") then
                blockedRemotes[descendant] = true
            end
        end
    end)
end

-- Защита от кика
local function setupAntiKick()
    local oldKick = player.Kick
    player.Kick = function(...)
        warn("Blocked kick attempt")
        return
    end
end

-- Рандомизация heartbeat
local function randomizeHeartbeat()
    local lastTick = tick()
    
    RunService.Heartbeat:Connect(function()
        local currentTick = tick()
        local delta = currentTick - lastTick
        
        if delta < 0.001 then
            task.wait(math.random(1, 5) / 1000)
        end
        
        lastTick = currentTick
    end)
end

-- Инициализация античита
function AntiCheatBypass.Initialize()
    print("[AntiCheat Bypass] Initializing...")
    
    pcall(hideExecutorEnvironment)
    pcall(protectMetatable)
    pcall(setupRemoteProtection)
    pcall(setupAntiKick)
    pcall(randomizeHeartbeat)
    
    print("[AntiCheat Bypass] ✅ Successfully initialized!")
    return true
end

-- ========================================
-- MAIN SCRIPT
-- ========================================

-- Настройки Rage
local MAX_ANGLE = math.rad(60)
local AIM_KEY = Enum.UserInputType.MouseButton2
local MAX_DISTANCE = 1000

-- Настройки FOV
local currentFOV = 70
local MIN_FOV = 70
local MAX_FOV = 120
local isFOVEnabled = false
local originalFOV = 70

-- Состояние
local isAimbotEnabled = false
local isChamsEnabled = false
local isAiming = false
local isStrafeEnabled = false
local isPlayerGlowEnabled = false
local isTriggerBotEnabled = false
local isSpeedHackEnabled = false
local isBunnyHopEnabled = false
local isPingDisplayEnabled = false
local isFPSDisplayEnabled = false
local aimConnection = nil
local strafeConnection = nil
local triggerConnection = nil
local speedHackConnection = nil
local bunnyHopConnection = nil

-- Новые визуальные функции
local isCustomSkyEnabled = false
local isXRayEnabled = false
local isModelChangerEnabled = false

-- WorldModulation настройки
local worldModulationSettings = {
    timeOfDay = "Day", -- Day or Night
    fog = false,
    shadows = true,
    customSky = false
}

-- Настройки Aimbot
local aimbotSettings = {
    tracers = false,
    tracerColor = Color3.fromRGB(101, 218, 255), -- Aurora Cyan
    mode = "Normal", -- Normal or Silent
    showTargetGui = false
}

-- TargetGui переменная
local targetGui = nil
local currentTarget = nil

-- Переменные для приветственного экрана
local welcomeScreen = nil
local mainGUI = nil
local isGUIVisible = true
local welcomeShown = false

-- Система уведомлений
local activeNotifications = {}
local notificationOffset = 0

-- Настройки Chams
local chamsSettings = {
    fillColor = Color3.fromRGB(101, 218, 255),
    fillTransparency = 0.3,
    outlineColor = Color3.fromRGB(132, 171, 251),
    outlineTransparency = 0.0,
    showNames = false,
    showDistance = false
}

-- Настройки Glow
local glowSettings = {
    color = Color3.fromRGB(101, 218, 255),
    range = 15,
    enabled = false
}

-- Настройки TriggerBot
local triggerSettings = {
    enabled = false,
    delay = 0.1,
    maxDistance = 100
}

-- Настройки BunnyHop
local bunnyHopSettings = {
    enabled = false,
    currentSpeed = 16,
    maxSpeed = 26,
    speedIncrement = 1,
    jumpCount = 0
}


-- Настройки ModelChanger
local modelChangerSettings = {
    enabled = false,
    material = Enum.Material.Neon,
    color = Color3.fromRGB(132, 171, 251) -- Aurora Blue
}

-- Цвета GUI (Aurora Theme из Discord)
local GUI_COLORS = {
    mainBackground = Color3.fromRGB(29, 34, 47),      -- Aurora dark blue
    columnBackground = Color3.fromRGB(37, 43, 59),    -- Aurora lighter blue
    title = Color3.fromRGB(132, 171, 251),            -- Aurora blue
    accent = Color3.fromRGB(101, 218, 255),           -- Aurora cyan
    text = Color3.fromRGB(221, 226, 239),             -- Aurora light text
    enabled = Color3.fromRGB(101, 218, 255),          -- Aurora cyan
    disabled = Color3.fromRGB(136, 144, 167)          -- Aurora muted
}

-- Текущие цвета
local TEXT_COLOR = GUI_COLORS.text
local TITLE_COLOR = GUI_COLORS.title

-- FOV Circle
local fovCircle = nil
local playerGlows = {}
local chamsInstances = {}
local nameLabels = {}
local distanceLabels = {}
local bulletTracers = {}
local pingDisplay = nil
local fpsDisplay = nil

-- Новые визуальные элементы
local originalSkybox = nil

-- Глобальные переменные для элементов GUI
local guiElements = nil
local settingsFrames = {}
local mobileControlsGui = nil

-- Создание мобильных кнопок управления (доступны всегда)
local function createMobileControls()
    
    -- Удаляем старое меню если есть
    if mobileControlsGui then
        mobileControlsGui:Destroy()
    end
    
    mobileControlsGui = Instance.new("ScreenGui")
    mobileControlsGui.Name = "MobileControls"
    mobileControlsGui.ResetOnSpawn = false
    mobileControlsGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    mobileControlsGui.Parent = game:GetService("CoreGui")
    
    -- Контейнер для кнопок
    local container = Instance.new("Frame")
    container.Name = "ButtonContainer"
    container.Size = UDim2.new(0, 180, 0, 200)
    container.Position = UDim2.new(1, -190, 0.5, -100)
    container.BackgroundColor3 = GUI_COLORS.mainBackground
    container.BackgroundTransparency = 0.3
    container.BorderSizePixel = 0
    container.Parent = mobileControlsGui
    
    local containerCorner = Instance.new("UICorner")
    containerCorner.CornerRadius = UDim.new(0, 12)
    containerCorner.Parent = container
    
    local containerStroke = Instance.new("UIStroke")
    containerStroke.Color = GUI_COLORS.accent
    containerStroke.Thickness = 2
    containerStroke.Transparency = 0.5
    containerStroke.Parent = container
    
    -- Заголовок
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30)
    title.Position = UDim2.new(0, 0, 0, 5)
    title.BackgroundTransparency = 1
    title.Text = "⚡ Quick Controls"
    title.TextColor3 = GUI_COLORS.title
    title.TextSize = 14
    title.Font = Enum.Font.GothamBold
    title.Parent = container
    
    -- Функция создания кнопки
    local function createMobileButton(text, yPos, callback)
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(1, -20, 0, 45)
        button.Position = UDim2.new(0, 10, 0, yPos)
        button.BackgroundColor3 = GUI_COLORS.columnBackground
        button.BackgroundTransparency = 0.2
        button.Text = text
        button.TextColor3 = GUI_COLORS.text
        button.TextSize = 13
        button.Font = Enum.Font.GothamBold
        button.BorderSizePixel = 0
        button.Parent = container
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 8)
        btnCorner.Parent = button
        
        local btnStroke = Instance.new("UIStroke")
        btnStroke.Color = GUI_COLORS.accent
        btnStroke.Thickness = 1.5
        btnStroke.Transparency = 0.7
        btnStroke.Parent = button
        
        button.MouseButton1Click:Connect(function()
            animateButtonClick(button)
            callback(button)
        end)
        
        return button
    end
    
    -- Кнопка 1: Toggle GUI
    local guiButton = createMobileButton("🖥️ Toggle GUI", 40, function(btn)
        isGUIVisible = not isGUIVisible
        if guiElements and guiElements.mainPanel then
            guiElements.mainPanel.Visible = isGUIVisible
            showNotification("GUI " .. (isGUIVisible and "Enabled!" or "Disabled!"))
        end
        btn.BackgroundColor3 = isGUIVisible and GUI_COLORS.enabled or GUI_COLORS.disabled
    end)
    
    -- Кнопка 2: Toggle Aimbot
    local aimbotButton = createMobileButton("🎯 Aimbot: OFF", 95, function(btn)
        isAimbotEnabled = not isAimbotEnabled
        if guiElements and guiElements.aimbotButton then
            updateButtonTextColor(guiElements.aimbotButton, isAimbotEnabled)
        end
        btn.Text = "🎯 Aimbot: " .. (isAimbotEnabled and "ON" or "OFF")
        btn.BackgroundColor3 = isAimbotEnabled and GUI_COLORS.enabled or GUI_COLORS.disabled
        showNotification("RAGE Aimbot " .. (isAimbotEnabled and "Enabled!" or "Disabled!"))
        
        -- Если аимбот включен, автоматически активируем прицеливание на мобильном
        if isAimbotEnabled then
            startAiming()
        else
            stopAiming()
        end
    end)
    
    -- Кнопка 3: Toggle Strafe
    local strafeButton = createMobileButton("💨 Strafe: OFF", 150, function(btn)
        if isStrafeEnabled then
            stopStrafe()
        else
            startStrafe()
        end
        if guiElements and guiElements.strafeButton then
            updateButtonTextColor(guiElements.strafeButton, isStrafeEnabled)
        end
        btn.Text = "💨 Strafe: " .. (isStrafeEnabled and "ON" or "OFF")
        btn.BackgroundColor3 = isStrafeEnabled and GUI_COLORS.enabled or GUI_COLORS.disabled
    end)
    
    -- Обновляем цвета кнопок при создании
    guiButton.BackgroundColor3 = isGUIVisible and GUI_COLORS.enabled or GUI_COLORS.disabled
    aimbotButton.BackgroundColor3 = isAimbotEnabled and GUI_COLORS.enabled or GUI_COLORS.disabled
    strafeButton.BackgroundColor3 = isStrafeEnabled and GUI_COLORS.enabled or GUI_COLORS.disabled
    
    -- Делаем контейнер перетаскиваемым
    local dragging = false
    local dragInput, dragStart, startPos
    
    container.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = container.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    container.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            container.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    showNotification("Quick Controls Loaded!")
end

-- Функция для копирования текста в буфер обмена
local function copyToClipboard(text)
    local clipboard = setclipboard or toclipboard or set_clipboard or (Clipboard and Clipboard.set)
    if clipboard then
        clipboard(text)
        return true
    else
        local ScreenGui = Instance.new("ScreenGui")
        local TextBox = Instance.new("TextBox")
        ScreenGui.Parent = game:GetService("CoreGui")
        TextBox.Parent = ScreenGui
        TextBox.Text = text
        TextBox:SelectAll()
        TextBox:Copy()
        ScreenGui:Destroy()
        return true
    end
end

-- Функция для показа уведомлений
local function showNotification(message)
    task.spawn(function()
        notificationOffset = notificationOffset + 45
        
        local notificationGui = Instance.new("ScreenGui")
        notificationGui.Name = "Notification"
        notificationGui.Parent = game:GetService("CoreGui")
        
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 200, 0, 35)
        frame.Position = UDim2.new(0.5, -100, 0.6, notificationOffset)
        frame.BackgroundColor3 = GUI_COLORS.title
        frame.BackgroundTransparency = 0.3
        frame.BorderSizePixel = 0
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = frame
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -10, 1, -10)
        label.Position = UDim2.new(0, 5, 0, 5)
        label.BackgroundTransparency = 1
        label.Text = message
        label.TextColor3 = TEXT_COLOR
        label.TextTransparency = 0
        label.TextSize = 14
        label.Font = Enum.Font.Gotham
        label.Parent = frame
        
        frame.Parent = notificationGui
        
        local notificationData = {
            gui = notificationGui,
            frame = frame,
            label = label,
            offset = notificationOffset
        }
        table.insert(activeNotifications, notificationData)
        
        frame.BackgroundTransparency = 1
        label.TextTransparency = 1
        
        local appearTween = TweenService:Create(frame, TweenInfo.new(0.3), {
            BackgroundTransparency = 0.3
        })
        
        local textAppearTween = TweenService:Create(label, TweenInfo.new(0.3), {
            TextTransparency = 0
        })
        
        appearTween:Play()
        textAppearTween:Play()
        
        task.wait(1.5)
        
        local textDisappearTween = TweenService:Create(label, TweenInfo.new(0.2), {
            TextTransparency = 1
        })
        textDisappearTween:Play()
        
        task.wait(0.1)
        
        local disappearTween = TweenService:Create(frame, TweenInfo.new(0.2), {
            BackgroundTransparency = 1
        })
        
        disappearTween:Play()
        
        disappearTween.Completed:Connect(function()
            notificationGui:Destroy()
            
            for i, notif in ipairs(activeNotifications) do
                if notif.gui == notificationGui then
                    table.remove(activeNotifications, i)
                    break
                end
            end
            
            for i, notif in ipairs(activeNotifications) do
                local newOffset = (i - 1) * 45
                local tween = TweenService:Create(notif.frame, TweenInfo.new(0.3), {
                    Position = UDim2.new(0.5, -100, 0.6, newOffset)
                })
                tween:Play()
                notif.offset = newOffset
            end
            
            notificationOffset = #activeNotifications * 45
        end)
    end)
end

-- Функция для анимации нажатия кнопки
local function animateButtonClick(button)
    task.spawn(function()
        local originalSize = button.Size
        local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        
        local clickTween = TweenService:Create(button, tweenInfo, {
            Size = UDim2.new(originalSize.X.Scale * 0.95, originalSize.X.Offset * 0.95, originalSize.Y.Scale * 0.95, originalSize.Y.Offset * 0.95)
        })
        clickTween:Play()
        
        task.wait(0.1)
        
        local releaseTween = TweenService:Create(button, tweenInfo, {
            Size = originalSize
        })
        releaseTween:Play()
    end)
end

-- Функция для создания цветовой палитры как на csscolor.ru
local function createColorPicker(parent, currentColor, callback)
    local colorPickerGui = Instance.new("ScreenGui")
    colorPickerGui.Name = "ColorPicker"
    colorPickerGui.Parent = game:GetService("CoreGui")
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 300, 0, 350)
    mainFrame.Position = UDim2.new(0.5, -150, 0.5, -175)
    mainFrame.BackgroundColor3 = GUI_COLORS.columnBackground
    mainFrame.BackgroundTransparency = 0.1
    mainFrame.BorderSizePixel = 0
    mainFrame.ZIndex = 100
    mainFrame.Parent = colorPickerGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = mainFrame
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 35)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundColor3 = GUI_COLORS.title
    title.BackgroundTransparency = 0.3
    title.Text = "Color Picker"
    title.TextColor3 = TEXT_COLOR
    title.TextSize = 16
    title.Font = Enum.Font.GothamBold
    title.Parent = mainFrame
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 12)
    titleCorner.Parent = title
    
    -- Основные цвета как на csscolor.ru
    local colorGroups = {
        {
            name = "Pink Colors",
            colors = {
                Color3.fromRGB(255, 182, 193), -- LightPink
                Color3.fromRGB(255, 105, 180), -- HotPink
                Color3.fromRGB(255, 20, 147),  -- DeepPink
                Color3.fromRGB(199, 21, 133),  -- MediumVioletRed
                Color3.fromRGB(219, 112, 147)  -- PaleVioletRed
            }
        },
        {
            name = "Red Colors",
            colors = {
                Color3.fromRGB(255, 0, 0),     -- Red
                Color3.fromRGB(178, 34, 34),   -- FireBrick
                Color3.fromRGB(139, 0, 0),     -- DarkRed
                Color3.fromRGB(255, 69, 0),    -- RedOrange
                Color3.fromRGB(205, 92, 92)    -- IndianRed
            }
        },
        {
            name = "Purple Colors",
            colors = {
                Color3.fromRGB(128, 0, 128),   -- Purple
                Color3.fromRGB(147, 112, 219), -- MediumPurple
                Color3.fromRGB(138, 43, 226),  -- BlueViolet
                Color3.fromRGB(75, 0, 130),    -- Indigo
                Color3.fromRGB(186, 85, 211)   -- MediumOrchid
            }
        },
        {
            name = "Blue Colors",
            colors = {
                Color3.fromRGB(0, 0, 255),     -- Blue
                Color3.fromRGB(30, 144, 255),  -- DodgerBlue
                Color3.fromRGB(0, 191, 255),   -- DeepSkyBlue
                Color3.fromRGB(65, 105, 225),  -- RoyalBlue
                Color3.fromRGB(135, 206, 250)  -- LightSkyBlue
            }
        },
        {
            name = "Green Colors",
            colors = {
                Color3.fromRGB(0, 128, 0),     -- Green
                Color3.fromRGB(50, 205, 50),   -- LimeGreen
                Color3.fromRGB(34, 139, 34),   -- ForestGreen
                Color3.fromRGB(144, 238, 144), -- LightGreen
                Color3.fromRGB(60, 179, 113)   -- MediumSeaGreen
            }
        },
        {
            name = "Yellow/Orange",
            colors = {
                Color3.fromRGB(255, 255, 0),   -- Yellow
                Color3.fromRGB(255, 165, 0),   -- Orange
                Color3.fromRGB(255, 215, 0),   -- Gold
                Color3.fromRGB(218, 165, 32),  -- GoldenRod
                Color3.fromRGB(210, 105, 30)   -- Chocolate
            }
        }
    }
    
    local yOffset = 45
    for _, group in ipairs(colorGroups) do
        local groupLabel = Instance.new("TextLabel")
        groupLabel.Size = UDim2.new(1, -20, 0, 20)
        groupLabel.Position = UDim2.new(0, 10, 0, yOffset)
        groupLabel.BackgroundTransparency = 1
        groupLabel.Text = group.name
        groupLabel.TextColor3 = TEXT_COLOR
        groupLabel.TextSize = 12
        groupLabel.Font = Enum.Font.Gotham
        groupLabel.TextXAlignment = Enum.TextXAlignment.Left
        groupLabel.Parent = mainFrame
        
        yOffset = yOffset + 25
        
        local colorRow = Instance.new("Frame")
        colorRow.Size = UDim2.new(1, -20, 0, 30)
        colorRow.Position = UDim2.new(0, 10, 0, yOffset)
        colorRow.BackgroundTransparency = 1
        colorRow.Parent = mainFrame
        
        for i, color in ipairs(group.colors) do
            local colorButton = Instance.new("TextButton")
            colorButton.Size = UDim2.new(0, 50, 0, 25)
            colorButton.Position = UDim2.new(0, (i-1) * 55, 0, 2)
            colorButton.BackgroundColor3 = color
            colorButton.BorderSizePixel = 1
            colorButton.BorderColor3 = Color3.fromRGB(255, 255, 255)
            colorButton.Text = ""
            colorButton.ZIndex = 101
            colorButton.Parent = colorRow
            
            local colorCorner = Instance.new("UICorner")
            colorCorner.CornerRadius = UDim.new(0, 4)
            colorCorner.Parent = colorButton
            
            colorButton.MouseButton1Click:Connect(function()
                callback(color)
                colorPickerGui:Destroy()
                showNotification("Color selected!")
            end)
        end
        
        yOffset = yOffset + 35
    end
    
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 100, 0, 30)
    closeButton.Position = UDim2.new(0.5, -50, 1, -40)
    closeButton.BackgroundColor3 = GUI_COLORS.title
    closeButton.Text = "Close"
    closeButton.TextColor3 = TEXT_COLOR
    closeButton.TextSize = 14
    closeButton.Font = Enum.Font.GothamBold
    closeButton.ZIndex = 101
    closeButton.Parent = mainFrame
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 6)
    closeCorner.Parent = closeButton
    
    closeButton.MouseButton1Click:Connect(function()
        colorPickerGui:Destroy()
    end)
    
    return colorPickerGui
end

-- Функция для воспроизведения звука колокольчика
local function playBellSound()
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://4590662766"
    sound.Volume = 0.3
    sound.Parent = SoundService
    sound:Play()
    
    sound.Ended:Connect(function()
        sound:Destroy()
    end)
end

-- Анимация появления/исчезновения
local function tweenPosition(object, targetPosition, duration, callback)
    local tweenInfo = TweenInfo.new(
        duration,
        Enum.EasingStyle.Quad,
        Enum.EasingDirection.Out
    )
    
    local tween = TweenService:Create(object, tweenInfo, {Position = targetPosition})
    tween:Play()
    
    if callback then
        tween.Completed:Connect(callback)
    end
end

-- Функция для плавного изменения размера фрейма
local function tweenSize(frame, targetSize, duration, callback)
    local tweenInfo = TweenInfo.new(
        duration,
        Enum.EasingStyle.Quad,
        Enum.EasingDirection.Out
    )
    
    local tween = TweenService:Create(frame, tweenInfo, {Size = targetSize})
    tween:Play()
    
    if callback then
        tween.Completed:Connect(callback)
    end
end

-- Функция для обновления цвета текста в зависимости от состояния
local function updateButtonTextColor(button, isEnabled)
    button.TextColor3 = isEnabled and GUI_COLORS.enabled or GUI_COLORS.disabled
end

-- ========================================
-- НОВЫЕ ВИЗУАЛЬНЫЕ ФУНКЦИИ
-- ========================================

-- ========================================
-- WORLD MODULATION ФУНКЦИИ
-- ========================================

local function applyWorldModulation()
    local Lighting = game:GetService("Lighting")
    
    -- Time of Day
    if worldModulationSettings.timeOfDay == "Night" then
        Lighting.ClockTime = 0
        Lighting.Brightness = 0.5
        Lighting.Ambient = Color3.fromRGB(50, 50, 70)
        Lighting.OutdoorAmbient = Color3.fromRGB(50, 50, 70)
        Lighting.ColorShift_Top = Color3.fromRGB(135, 206, 250)
    else -- Day
        Lighting.ClockTime = 14
        Lighting.Brightness = 2
        Lighting.Ambient = Color3.fromRGB(170, 170, 170)
        Lighting.OutdoorAmbient = Color3.fromRGB(170, 170, 170)
        Lighting.ColorShift_Top = Color3.fromRGB(255, 255, 255)
    end
    
    -- Fog - правильное выключение
    if worldModulationSettings.fog then
        Lighting.FogEnd = 500
        Lighting.FogStart = 0
        Lighting.FogColor = Color3.fromRGB(192, 192, 192)
    else
        -- Полностью убираем туман
        Lighting.FogEnd = 100000000
        Lighting.FogStart = 0
    end
    
    -- Shadows - правильное выключение
    Lighting.GlobalShadows = worldModulationSettings.shadows
    
    -- Custom Sky в зависимости от времени суток
    if worldModulationSettings.customSky then
        -- Удаляем существующее небо
        for _, sky in pairs(Lighting:GetChildren()) do
            if sky:IsA("Sky") then
                sky:Destroy()
            end
        end
        
        local sky = Instance.new("Sky")
        
        if worldModulationSettings.timeOfDay == "Night" then
            -- Чёрное небо с бело-голубой кометой для ночи
            sky.SkyboxBk = "rbxassetid://8139677359"
            sky.SkyboxDn = "rbxassetid://8139677253"
            sky.SkyboxFt = "rbxassetid://8139677111"
            sky.SkyboxLf = "rbxassetid://8139676988"
            sky.SkyboxRt = "rbxassetid://8139676842"
            sky.SkyboxUp = "rbxassetid://8139676647"
            sky.SunAngularSize = 0
            sky.MoonAngularSize = 15
            sky.StarCount = 5000
            sky.Parent = Lighting
            
            -- Атмосфера для ночи с кометой
            local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
            if not atmosphere then
                atmosphere = Instance.new("Atmosphere")
                atmosphere.Parent = Lighting
            end
            atmosphere.Density = 0.4
            atmosphere.Offset = 0.3
            atmosphere.Color = Color3.fromRGB(150, 200, 255)
            atmosphere.Decay = Color3.fromRGB(30, 50, 80)
            atmosphere.Glare = 0.5
            atmosphere.Haze = 0.8
        else
            -- Северное сияние для дня
            sky.SkyboxBk = "rbxassetid://159454299"
            sky.SkyboxDn = "rbxassetid://159454296"
            sky.SkyboxFt = "rbxassetid://159454293"
            sky.SkyboxLf = "rbxassetid://159454286"
            sky.SkyboxRt = "rbxassetid://159454300"
            sky.SkyboxUp = "rbxassetid://159454288"
            sky.SunAngularSize = 0
            sky.MoonAngularSize = 11
            sky.StarCount = 3000
            sky.Parent = Lighting
            
            -- Атмосфера для северного сияния
            local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
            if not atmosphere then
                atmosphere = Instance.new("Atmosphere")
                atmosphere.Parent = Lighting
            end
            atmosphere.Density = 0.35
            atmosphere.Offset = 0.5
            atmosphere.Color = Color3.fromRGB(100, 255, 200)
            atmosphere.Decay = Color3.fromRGB(50, 100, 150)
            atmosphere.Glare = 0.2
            atmosphere.Haze = 1.5
        end
    else
        -- Удаляем кастомное небо
        for _, sky in pairs(Lighting:GetChildren()) do
            if sky:IsA("Sky") then
                sky:Destroy()
            end
        end
        -- Удаляем атмосферу
        local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
        if atmosphere then
            atmosphere:Destroy()
        end
    end
end


-- X-Ray функция
local function enableXRay()
    if isXRayEnabled then return end
    
    -- Делаем все BasePart полупрозрачными кроме игроков
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            -- Проверяем, не является ли это частью персонажа
            local isPlayerPart = false
            local parent = obj.Parent
            while parent do
                if parent:IsA("Model") and parent:FindFirstChildOfClass("Humanoid") then
                    isPlayerPart = true
                    break
                end
                parent = parent.Parent
            end
            
            if not isPlayerPart then
                obj.LocalTransparencyModifier = 0.7
            end
        end
    end
    
    isXRayEnabled = true
    showNotification("X-Ray Enabled!")
end

local function disableXRay()
    if not isXRayEnabled then return end
    
    -- Восстанавливаем прозрачность
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            obj.LocalTransparencyModifier = 0
        end
    end
    
    isXRayEnabled = false
    showNotification("X-Ray Disabled!")
end

-- ========================================
-- MODEL CHANGER ФУНКЦИЯ (Phantom Forces)
-- ========================================

local modelChangerConnection = nil

local function applyModelChangerToTool(tool)
    if not tool or not isModelChangerEnabled then return end
    
    -- Применяем материал и цвет ТОЛЬКО к видимым частям оружия
    -- НЕ трогаем Scripts, Animations, Sounds и другие функциональные объекты
    for _, part in pairs(tool:GetDescendants()) do
        if part:IsA("BasePart") or part:IsA("MeshPart") or part:IsA("UnionOperation") or part:IsA("Part") then
            -- Сохраняем оригинальные свойства для восстановления
            if not part:FindFirstChild("OriginalMaterial") then
                local originalMat = Instance.new("StringValue")
                originalMat.Name = "OriginalMaterial"
                originalMat.Value = tostring(part.Material)
                originalMat.Parent = part
                
                local originalColor = Instance.new("Color3Value")
                originalColor.Name = "OriginalColor"
                originalColor.Value = part.Color
                originalColor.Parent = part
            end
            
            -- Применяем материал и цвет
            part.Material = modelChangerSettings.material
            part.Color = modelChangerSettings.color
            
            -- Убираем отражение (но не трогаем прозрачность!)
            part.Reflectance = 0
            
            -- Сглаживаем поверхности
            part.TopSurface = Enum.SurfaceType.Smooth
            part.BottomSurface = Enum.SurfaceType.Smooth
            part.LeftSurface = Enum.SurfaceType.Smooth
            part.RightSurface = Enum.SurfaceType.Smooth
            part.FrontSurface = Enum.SurfaceType.Smooth
            part.BackSurface = Enum.SurfaceType.Smooth
        end
    end
    
    -- Дополнительно: обрабатываем Handle если есть
    local handle = tool:FindFirstChild("Handle")
    if handle and handle:IsA("BasePart") then
        if not handle:FindFirstChild("OriginalMaterial") then
            local originalMat = Instance.new("StringValue")
            originalMat.Name = "OriginalMaterial"
            originalMat.Value = tostring(handle.Material)
            originalMat.Parent = handle
            
            local originalColor = Instance.new("Color3Value")
            originalColor.Name = "OriginalColor"
            originalColor.Value = handle.Color
            originalColor.Parent = handle
        end
        
        handle.Material = modelChangerSettings.material
        handle.Color = modelChangerSettings.color
        handle.Reflectance = 0
    end
end

local function enableModelChanger()
    if not player.Character then return end
    isModelChangerEnabled = true
    
    -- Применяем к текущему оружию в руках
    local tool = player.Character:FindFirstChildOfClass("Tool")
    if tool then
        applyModelChangerToTool(tool)
    end
    
    -- Отслеживаем когда игрок берет новое оружие
    if modelChangerConnection then
        modelChangerConnection:Disconnect()
    end
    
    modelChangerConnection = player.Character.ChildAdded:Connect(function(child)
        if child:IsA("Tool") and isModelChangerEnabled then
            wait(0.1) -- Небольшая задержка для загрузки модели
            applyModelChangerToTool(child)
        end
    end)
    
    showNotification("Model Changer Enabled! Equip weapon to apply")
end

local function disableModelChanger()
    if not player.Character then return end
    isModelChangerEnabled = false
    
    if modelChangerConnection then
        modelChangerConnection:Disconnect()
        modelChangerConnection = nil
    end
    
    -- Восстанавливаем оригинальный материал и цвет текущего оружия
    local tool = player.Character:FindFirstChildOfClass("Tool")
    if tool then
        for _, part in pairs(tool:GetDescendants()) do
            if part:IsA("BasePart") or part:IsA("MeshPart") or part:IsA("UnionOperation") or part:IsA("Part") then
                local originalMat = part:FindFirstChild("OriginalMaterial")
                local originalColor = part:FindFirstChild("OriginalColor")
                
                if originalMat and originalMat:IsA("StringValue") then
                    part.Material = Enum.Material[originalMat.Value] or Enum.Material.Plastic
                    originalMat:Destroy()
                end
                
                if originalColor and originalColor:IsA("Color3Value") then
                    part.Color = originalColor.Value
                    originalColor:Destroy()
                end
                
                part.Reflectance = 0
            end
        end
    end
    
    showNotification("Model Changer Disabled! Re-equip weapon to restore")
end

-- ========================================
-- ОСТАЛЬНЫЕ ФУНКЦИИ СКРИПТА
-- ========================================

-- RAGE функции прицеливания
local function calculateAngle(cameraPos, cameraLook, targetPos)
    local toTarget = (targetPos - cameraPos).Unit
    local dot = cameraLook:Dot(toTarget)
    return math.acos(math.clamp(dot, -1, 1))
end

local function findTargetNearCrosshair()
    if not player.Character then return nil end
    
    local bestTarget = nil
    local smallestAngle = MAX_ANGLE + 0.1
    local camera = workspace.CurrentCamera
    local cameraPos = camera.CFrame.Position
    local cameraLook = camera.CFrame.LookVector
    
    local playerPos = cameraPos
    if player.Character:FindFirstChild("HumanoidRootPart") then
        playerPos = player.Character.HumanoidRootPart.Position
    end
    
    for _, otherPlayer in pairs(Players:GetPlayers()) do
        if otherPlayer ~= player and otherPlayer.Character then
            local character = otherPlayer.Character
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            
            if humanoid and humanoid.Health > 0 then
                local head = character:FindFirstChild("Head")
                if head then
                    local distance = (head.Position - playerPos).Magnitude
                    if distance <= MAX_DISTANCE then
                        local angle = calculateAngle(cameraPos, cameraLook, head.Position)
                        
                        if angle <= MAX_ANGLE and angle < smallestAngle then
                            smallestAngle = angle
                            bestTarget = head
                        end
                    end
                end
            end
        end
    end
    
    return bestTarget
end

-- Tracers функция (длинная неоновая линия при нажатии ЛКМ)
local function createBulletTracer()
    if not aimbotSettings.tracers then return end
    
    local camera = workspace.CurrentCamera
    local mouse = player:GetMouse()
    
    -- Создаем луч от камеры до точки, куда смотрит мышь (смещение: 2.5см вправо и 0.8см вверх)
    local rayOrigin = camera.CFrame.Position
    local mouseHitPos = mouse.Hit.Position
    local adjustedHitPos = Vector3.new(
        mouseHitPos.X + 0.025, -- 2.5 см вправо
        mouseHitPos.Y + 0.008, -- 0.8 см вверх
        mouseHitPos.Z
    )
    local rayDirection = (adjustedHitPos - rayOrigin).Unit * 1000
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {player.Character}
    raycastParams.IgnoreWater = true
    
    local raycastResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
    local endPosition = raycastResult and raycastResult.Position or (rayOrigin + rayDirection)
    
    -- Создаем неоновую линию
    local tracer = Instance.new("Part")
    tracer.Name = "BulletTracer"
    tracer.Anchored = true
    tracer.CanCollide = false
    tracer.Material = Enum.Material.Neon
    tracer.Color = aimbotSettings.tracerColor
    tracer.Transparency = 0.3
    
    -- Вычисляем длину и позицию линии
    local distance = (endPosition - rayOrigin).Magnitude
    tracer.Size = Vector3.new(0.1, 0.1, distance)
    tracer.CFrame = CFrame.lookAt(rayOrigin, endPosition) * CFrame.new(0, 0, -distance/2)
    
    tracer.Parent = workspace
    
    -- Исчезает через 1 секунду
    delay(1, function()
        for i = 1, 10 do
            if tracer then
                tracer.Transparency = tracer.Transparency + 0.1
                wait(0.1)
            end
        end
        if tracer then
            tracer:Destroy()
        end
    end)
    
    table.insert(bulletTracers, tracer)
end

local function startTracers()
    aimbotSettings.tracers = true
    
    -- Обработчик нажатия ЛКМ
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.UserInputType == Enum.UserInputType.MouseButton1 and aimbotSettings.tracers then
            createBulletTracer()
        end
    end)
    
    showNotification("Bullet Tracers Enabled!")
end

local function stopTracers()
    aimbotSettings.tracers = false
    
    -- Удаляем все трассеры
    for _, tracer in ipairs(bulletTracers) do
        if tracer then
            tracer:Destroy()
        end
    end
    bulletTracers = {}
    
    showNotification("Bullet Tracers Disabled!")
end

-- Функция для создания TargetGui
-- Создание постоянного TargetGui
local function createTargetGui()
    -- Удаляем старый GUI если существует
    if targetGui and targetGui.Parent then
        pcall(function()
            targetGui:Destroy()
        end)
        targetGui = nil
    end
    
    if not aimbotSettings.showTargetGui then return end
    
    local targetGuiScreen = Instance.new("ScreenGui")
    targetGuiScreen.Name = "TargetGui"
    targetGuiScreen.ResetOnSpawn = false
    targetGuiScreen.Parent = game:GetService("CoreGui")
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 190, 0, 95)
    mainFrame.Position = UDim2.new(0.5, -95, 0.7, 0)
    mainFrame.BackgroundColor3 = GUI_COLORS.mainBackground
    mainFrame.BackgroundTransparency = 0.2
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = targetGuiScreen
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = mainFrame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = GUI_COLORS.accent
    stroke.Thickness = 1.5
    stroke.Transparency = 0.3
    stroke.Parent = mainFrame
    
    -- Аватарка слева
    local avatar = Instance.new("ImageLabel")
    avatar.Name = "Avatar"
    avatar.Size = UDim2.new(0, 85, 0, 85)
    avatar.Position = UDim2.new(0, 5, 0, 5)
    avatar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    avatar.BorderSizePixel = 0
    avatar.Image = ""
    avatar.Parent = mainFrame
    
    local avatarCorner = Instance.new("UICorner")
    avatarCorner.CornerRadius = UDim.new(0, 6)
    avatarCorner.Parent = avatar
    
    -- UserName сверху справа
    local userName = Instance.new("TextLabel")
    userName.Name = "UserName"
    userName.Size = UDim2.new(0, 90, 0, 30)
    userName.Position = UDim2.new(0, 95, 0, 10)
    userName.BackgroundTransparency = 1
    userName.Text = "Nobody Locked"
    userName.TextColor3 = TEXT_COLOR
    userName.TextSize = 14
    userName.Font = Enum.Font.GothamBold
    userName.TextXAlignment = Enum.TextXAlignment.Left
    userName.TextYAlignment = Enum.TextYAlignment.Top
    userName.TextTruncate = Enum.TextTruncate.AtEnd
    userName.Parent = mainFrame
    
    -- DisplayName под UserName
    local displayName = Instance.new("TextLabel")
    displayName.Name = "DisplayName"
    displayName.Size = UDim2.new(0, 90, 0, 25)
    displayName.Position = UDim2.new(0, 95, 0, 35)
    displayName.BackgroundTransparency = 1
    displayName.Text = ""
    displayName.TextColor3 = GUI_COLORS.disabled
    displayName.TextSize = 11
    displayName.Font = Enum.Font.Gotham
    displayName.TextXAlignment = Enum.TextXAlignment.Left
    displayName.TextYAlignment = Enum.TextYAlignment.Top
    displayName.TextTruncate = Enum.TextTruncate.AtEnd
    displayName.Parent = mainFrame
    
    -- Здоровье
    local healthLabel = Instance.new("TextLabel")
    healthLabel.Name = "HealthLabel"
    healthLabel.Size = UDim2.new(0, 90, 0, 20)
    healthLabel.Position = UDim2.new(0, 95, 0, 65)
    healthLabel.BackgroundTransparency = 1
    healthLabel.Text = ""
    healthLabel.TextColor3 = Color3.fromRGB(101, 218, 255)
    healthLabel.TextSize = 11
    healthLabel.Font = Enum.Font.GothamBold
    healthLabel.TextXAlignment = Enum.TextXAlignment.Left
    healthLabel.TextYAlignment = Enum.TextYAlignment.Top
    healthLabel.Parent = mainFrame
    
    targetGui = targetGuiScreen
end

-- Переменная для подключения к обновлению HP
local healthConnection = nil

-- Обновление TargetGui
local function updateTargetGui(targetPlayer)
    if not targetGui or not targetGui.Parent then return end
    
    local mainFrame = targetGui:FindFirstChild("MainFrame")
    if not mainFrame then return end
    
    local avatar = mainFrame:FindFirstChild("Avatar")
    local userName = mainFrame:FindFirstChild("UserName")
    local displayName = mainFrame:FindFirstChild("DisplayName")
    local healthLabel = mainFrame:FindFirstChild("HealthLabel")
    
    -- Отключаем старое обновление HP
    if healthConnection then
        healthConnection:Disconnect()
        healthConnection = nil
    end
    
    if targetPlayer then
        -- Обновляем информацию о цели
        if avatar then
            avatar.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. targetPlayer.UserId .. "&width=150&height=150&format=png"
        end
        if userName then
            userName.Text = targetPlayer.Name
        end
        if displayName then
            displayName.Text = "@" .. targetPlayer.DisplayName
        end
        if healthLabel and targetPlayer.Character then
            local humanoid = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                healthLabel.Text = "HP: " .. math.floor(humanoid.Health) .. "/" .. math.floor(humanoid.MaxHealth)
                
                -- Подключаем динамическое обновление HP
                healthConnection = humanoid:GetPropertyChangedSignal("Health"):Connect(function()
                    if healthLabel and healthLabel.Parent then
                        healthLabel.Text = "HP: " .. math.floor(humanoid.Health) .. "/" .. math.floor(humanoid.MaxHealth)
                    end
                end)
            else
                healthLabel.Text = ""
            end
        end
    else
        -- Нет цели - показываем "Nobody Locked"
        if avatar then
            avatar.Image = ""
        end
        if userName then
            userName.Text = "Nobody Locked"
        end
        if displayName then
            displayName.Text = ""
        end
        if healthLabel then
            healthLabel.Text = ""
        end
    end
end

local function startAiming()
    if not isAimbotEnabled or not player.Character then 
        return 
    end
    
    isAiming = true
    
    local camera = workspace.CurrentCamera
    if camera then
        originalFOV = camera.FieldOfView
    end
    
    -- Проверяем режим аимбота
    if aimbotSettings.mode == "Normal" then
        -- Normal Aimbot - двигает камеру
        aimConnection = RunService.Heartbeat:Connect(function(delta)
            if not isAiming or not isAimbotEnabled or not player.Character then 
                if aimConnection then
                    aimConnection:Disconnect()
                end
                return 
            end
            
            local targetHead = findTargetNearCrosshair()
            if targetHead then
                local camera = workspace.CurrentCamera
                camera.CFrame = CFrame.new(camera.CFrame.Position, targetHead.Position)
                
                -- Обновляем TargetGui
                if aimbotSettings.showTargetGui then
                    local targetPlayer = Players:GetPlayerFromCharacter(targetHead.Parent)
                    if targetPlayer ~= currentTarget then
                        currentTarget = targetPlayer
                        updateTargetGui(targetPlayer)
                    end
                end
            else
                -- Нет цели - показываем "Nobody Locked"
                if aimbotSettings.showTargetGui and currentTarget then
                    currentTarget = nil
                    updateTargetGui(nil)
                end
            end
        end)
    elseif aimbotSettings.mode == "Silent" then
        -- Silent Aim - мгновенно наводится на цель при выстреле, камера остаётся на месте
        local silentTarget = nil
        local originalCamCFrame = nil
        
        aimConnection = RunService.Heartbeat:Connect(function(delta)
            if not isAiming or not isAimbotEnabled or not player.Character then 
                if aimConnection then
                    aimConnection:Disconnect()
                end
                return 
            end
            
            local targetHead = findTargetNearCrosshair()
            if targetHead then
                local camera = workspace.CurrentCamera
                
                -- Проверяем, что камера в режиме от первого лица
                local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                if humanoid and player.Character:FindFirstChild("Head") then
                    local cameraMode = player.CameraMode
                    local cameraDistance = (camera.CFrame.Position - player.Character.Head.Position).Magnitude
                    
                    -- Если камера от первого лица (расстояние < 1.5)
                    if cameraDistance < 1.5 or cameraMode == Enum.CameraMode.LockFirstPerson then
                        silentTarget = targetHead
                        
                        -- Обновляем TargetGui
                        if aimbotSettings.showTargetGui then
                            local targetPlayer = Players:GetPlayerFromCharacter(targetHead.Parent)
                            if targetPlayer ~= currentTarget then
                                currentTarget = targetPlayer
                                updateTargetGui(targetPlayer)
                            end
                        end
                    end
                end
            else
                silentTarget = nil
                -- Нет цели - показываем "Nobody Locked"
                if aimbotSettings.showTargetGui and currentTarget then
                    currentTarget = nil
                    updateTargetGui(nil)
                end
            end
        end)
        
        -- Обработчик для мгновенного наведения при выстреле (LMB)
        local silentAimInputConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            
            if input.UserInputType == Enum.UserInputType.MouseButton1 and isAiming and isAimbotEnabled and silentTarget then
                local camera = workspace.CurrentCamera
                
                -- Сохраняем текущую позицию камеры
                originalCamCFrame = camera.CFrame
                
                -- Мгновенно наводим на цель
                camera.CFrame = CFrame.new(camera.CFrame.Position, silentTarget.Position)
                
                -- Возвращаем камеру обратно через 1 кадр
                task.spawn(function()
                    task.wait()
                    if originalCamCFrame and camera then
                        camera.CFrame = originalCamCFrame
                    end
                end)
            end
        end)
        
        -- Отключаем обработчик при выключении аимбота
        task.spawn(function()
            repeat task.wait() until not isAiming or not isAimbotEnabled
            if silentAimInputConnection then
                silentAimInputConnection:Disconnect()
            end
        end)
    end
end

local function stopAiming()
    isAiming = false
    
    if isFOVEnabled then
        updateCameraFOV()
    else
        restoreOriginalFOV()
    end
    
    if aimConnection then
        aimConnection:Disconnect()
        aimConnection = nil
    end
    
    -- Показываем "Nobody Locked" когда прицеливание остановлено
    currentTarget = nil
    if aimbotSettings.showTargetGui then
        updateTargetGui(nil)
    end
end

-- TriggerBot функция
local function startTriggerBot()
    if not player.Character then return end
    
    isTriggerBotEnabled = true
    
    triggerConnection = RunService.Heartbeat:Connect(function()
        if not isTriggerBotEnabled or not player.Character then
            if triggerConnection then
                triggerConnection:Disconnect()
                triggerConnection = nil
            end
            return
        end
        
        local camera = workspace.CurrentCamera
        if not camera then return end
        
        local mouse = player:GetMouse()
        local mouseTarget = mouse.Target
        
        if mouseTarget then
            local targetModel = mouseTarget:FindFirstAncestorOfClass("Model")
            if targetModel then
                local targetPlayer = Players:GetPlayerFromCharacter(targetModel)
                if targetPlayer and targetPlayer ~= player then
                    local humanoid = targetModel:FindFirstChildOfClass("Humanoid")
                    if humanoid and humanoid.Health > 0 then
                        local distance = (targetModel:FindFirstChild("Head") or targetModel:FindFirstChild("HumanoidRootPart") or mouseTarget).Position - camera.CFrame.Position
                        if distance.Magnitude <= triggerSettings.maxDistance then
                            local raycastParams = RaycastParams.new()
                            raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
                            raycastParams.FilterDescendantsInstances = {player.Character, targetModel}
                            raycastParams.IgnoreWater = true
                            
                            local raycastResult = workspace:Raycast(
                                camera.CFrame.Position,
                                distance.Unit * distance.Magnitude,
                                raycastParams
                            )
                            
                            if not raycastResult then
                                mouse1click()
                                wait(triggerSettings.delay)
                            end
                        end
                    end
                end
            end
        end
    end)
    
    showNotification("TriggerBot Enabled!")
end

local function stopTriggerBot()
    isTriggerBotEnabled = false
    if triggerConnection then
        triggerConnection:Disconnect()
        triggerConnection = nil
    end
    showNotification("TriggerBot Disabled!")
end


-- Strafe функция с FastStop (скорость 27)
local function startStrafe()
    if not player.Character then return end
    
    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    
    isStrafeEnabled = true
    
    if not humanoid:FindFirstChild("OriginalWalkSpeed") then
        local originalWalkSpeed = Instance.new("NumberValue")
        originalWalkSpeed.Name = "OriginalWalkSpeed"
        originalWalkSpeed.Value = humanoid.WalkSpeed
        originalWalkSpeed.Parent = humanoid
    end
    
    -- Установка скорости 27
    humanoid.WalkSpeed = 27
    
    -- Убираем замедление при смене направления
    strafeConnection = RunService.Heartbeat:Connect(function()
        if not isStrafeEnabled or not player.Character or not humanoid then
            if strafeConnection then
                strafeConnection:Disconnect()
                strafeConnection = nil
            end
            return
        end
        
        local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            local currentVelocity = rootPart.Velocity
            local moveDirection = humanoid.MoveDirection
            
            -- Убираем замедление при резкой смене направления
            if moveDirection.Magnitude > 0.1 then
                -- Сохраняем полную скорость при движении в любом направлении
                local newVelocity = moveDirection * humanoid.WalkSpeed
                rootPart.Velocity = Vector3.new(newVelocity.X, currentVelocity.Y, newVelocity.Z)
            elseif moveDirection.Magnitude < 0.1 and currentVelocity.Magnitude > 1 then
                -- Мгновенная остановка только когда нет направления движения
                rootPart.Velocity = Vector3.new(0, currentVelocity.Y, 0)
            end
        end
    end)
    
    showNotification("Strafe Enabled! Speed 27 + No Slowdown [X]")
end

local function stopStrafe()
    if not player.Character then return end
    
    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    
    isStrafeEnabled = false
    
    local originalWalkSpeed = humanoid:FindFirstChild("OriginalWalkSpeed")
    if originalWalkSpeed then
        humanoid.WalkSpeed = originalWalkSpeed.Value
    end
    
    if strafeConnection then
        strafeConnection:Disconnect()
        strafeConnection = nil
    end
    
    showNotification("Strafe Disabled! Speed restored")
end

-- SpeedHack функция (скорость 22)
local function startSpeedHack()
    if not player.Character then return end
    
    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    
    isSpeedHackEnabled = true
    
    if not humanoid:FindFirstChild("OriginalWalkSpeed") then
        local originalWalkSpeed = Instance.new("NumberValue")
        originalWalkSpeed.Name = "OriginalWalkSpeed"
        originalWalkSpeed.Value = humanoid.WalkSpeed
        originalWalkSpeed.Parent = humanoid
    end
    
    -- Установка скорости 22
    humanoid.WalkSpeed = 22
    
    showNotification("SpeedHack Enabled! Speed 22 [H]")
end

local function stopSpeedHack()
    if not player.Character then return end
    
    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    
    isSpeedHackEnabled = false
    
    local originalWalkSpeed = humanoid:FindFirstChild("OriginalWalkSpeed")
    if originalWalkSpeed then
        humanoid.WalkSpeed = originalWalkSpeed.Value
    end
    
    showNotification("SpeedHack Disabled! Speed restored")
end

-- BunnyHop функция
local function startBunnyHop()
    if not player.Character then return end
    
    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    
    isBunnyHopEnabled = true
    
    -- Сохраняем оригинальную скорость
    if not humanoid:FindFirstChild("OriginalWalkSpeed") then
        local originalWalkSpeed = Instance.new("NumberValue")
        originalWalkSpeed.Name = "OriginalWalkSpeed"
        originalWalkSpeed.Value = humanoid.WalkSpeed
        originalWalkSpeed.Parent = humanoid
    end
    
    -- Сбрасываем счетчик прыжков
    bunnyHopSettings.jumpCount = 0
    bunnyHopSettings.currentSpeed = 16
    
    bunnyHopConnection = RunService.Heartbeat:Connect(function()
        if not isBunnyHopEnabled or not player.Character or not humanoid then
            if bunnyHopConnection then
                bunnyHopConnection:Disconnect()
                bunnyHopConnection = nil
            end
            return
        end
        
        -- Проверяем, зажат ли пробел
        local spacePressed = UserInputService:IsKeyDown(Enum.KeyCode.Space)
        
        if spacePressed and humanoid:GetState() == Enum.HumanoidStateType.Running then
            -- Прыжок
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            
            -- Увеличиваем скорость после прыжка
            if bunnyHopSettings.jumpCount < 10 then
                bunnyHopSettings.jumpCount = bunnyHopSettings.jumpCount + 1
                bunnyHopSettings.currentSpeed = math.min(
                    bunnyHopSettings.currentSpeed + bunnyHopSettings.speedIncrement,
                    bunnyHopSettings.maxSpeed
                )
            end
            
            -- Устанавливаем текущую скорость
            humanoid.WalkSpeed = bunnyHopSettings.currentSpeed
            
            -- Небольшая задержка между прыжками
            task.wait(0.2)
        end
    end)
    
    showNotification("BunnyHop Enabled! Hold Space to bunny hop")
end

local function stopBunnyHop()
    if not player.Character then return end
    
    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    
    isBunnyHopEnabled = false
    
    -- Восстанавливаем оригинальную скорость
    local originalWalkSpeed = humanoid:FindFirstChild("OriginalWalkSpeed")
    if originalWalkSpeed then
        humanoid.WalkSpeed = originalWalkSpeed.Value
    end
    
    if bunnyHopConnection then
        bunnyHopConnection:Disconnect()
        bunnyHopConnection = nil
    end
    
    showNotification("BunnyHop Disabled!")
end


-- Ping Display функция
local function createPingDisplay()
    if pingDisplay then
        pingDisplay:Destroy()
        pingDisplay = nil
    end
    
    local pingGui = Instance.new("ScreenGui")
    pingGui.Name = "PingDisplay"
    pingGui.ResetOnSpawn = false
    pingGui.Parent = game:GetService("CoreGui")
    
    local pingFrame = Instance.new("Frame")
    pingFrame.Size = UDim2.new(0, 100, 0, 30)
    pingFrame.Position = UDim2.new(0, 10, 0, 50)
    pingFrame.BackgroundColor3 = GUI_COLORS.mainBackground
    pingFrame.BackgroundTransparency = 0.3
    pingFrame.BorderSizePixel = 0
    pingFrame.Parent = pingGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = pingFrame
    
    local pingLabel = Instance.new("TextLabel")
    pingLabel.Size = UDim2.new(1, -10, 1, -10)
    pingLabel.Position = UDim2.new(0, 5, 0, 5)
    pingLabel.BackgroundTransparency = 1
    pingLabel.Text = "Ping: 0ms"
    pingLabel.TextColor3 = TEXT_COLOR
    pingLabel.TextSize = 14
    pingLabel.Font = Enum.Font.Gotham
    pingLabel.Parent = pingFrame
    
    -- Делаем фрейм перетаскиваемым
    local dragging = false
    local dragInput, dragStart, startPos
    
    pingFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = pingFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    pingFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            pingFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    -- Обновление пинга
    local pingConnection
    pingConnection = RunService.Heartbeat:Connect(function()
        if not isPingDisplayEnabled then
            pingConnection:Disconnect()
            pingGui:Destroy()
            return
        end
        
        -- Симуляция пинга (в реальном скрипте нужно получать реальный пинг)
        local simulatedPing = math.random(20, 60)
        pingLabel.Text = "Ping: " .. simulatedPing .. "ms"
    end)
    
    pingDisplay = pingGui
    showNotification("Ping Display Enabled! Drag to move")
end

-- FPS Display функция
local function createFPSDisplay()
    if fpsDisplay then
        fpsDisplay:Destroy()
        fpsDisplay = nil
    end
    
    local fpsGui = Instance.new("ScreenGui")
    fpsGui.Name = "FPSDisplay"
    fpsGui.ResetOnSpawn = false
    fpsGui.Parent = game:GetService("CoreGui")
    
    local fpsFrame = Instance.new("Frame")
    fpsFrame.Size = UDim2.new(0, 100, 0, 30)
    fpsFrame.Position = UDim2.new(0, 10, 0, 90)
    fpsFrame.BackgroundColor3 = GUI_COLORS.mainBackground
    fpsFrame.BackgroundTransparency = 0.3
    fpsFrame.BorderSizePixel = 0
    fpsFrame.Parent = fpsGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = fpsFrame
    
    local fpsLabel = Instance.new("TextLabel")
    fpsLabel.Size = UDim2.new(1, -10, 1, -10)
    fpsLabel.Position = UDim2.new(0, 5, 0, 5)
    fpsLabel.BackgroundTransparency = 1
    fpsLabel.Text = "FPS: 0"
    fpsLabel.TextColor3 = TEXT_COLOR
    fpsLabel.TextSize = 14
    fpsLabel.Font = Enum.Font.Gotham
    fpsLabel.Parent = fpsFrame
    
    -- Делаем фрейм перетаскиваемым
    local dragging = false
    local dragInput, dragStart, startPos
    
    fpsFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = fpsFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    fpsFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            fpsFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    -- Обновление FPS
    local fpsConnection
    local lastTime = tick()
    local frameCount = 0
    
    fpsConnection = RunService.Heartbeat:Connect(function()
        if not isFPSDisplayEnabled then
            fpsConnection:Disconnect()
            fpsGui:Destroy()
            return
        end
        
        frameCount = frameCount + 1
        local currentTime = tick()
        
        if currentTime - lastTime >= 1 then
            local fps = math.floor(frameCount / (currentTime - lastTime))
            fpsLabel.Text = "FPS: " .. fps
            frameCount = 0
            lastTime = currentTime
        end
    end)
    
    fpsDisplay = fpsGui
    showNotification("FPS Display Enabled! Drag to move")
end

-- Функция для обновления FOV
local function updateFOV()
    if isFOVEnabled then
        local camera = workspace.CurrentCamera
        if camera then
            camera.FieldOfView = currentFOV
        end
        showNotification("FOV Enabled: " .. currentFOV)
    else
        restoreOriginalFOV()
        showNotification("FOV Disabled")
    end
end

-- Функция для сохранения оригинального FOV
local function saveOriginalFOV()
    local camera = workspace.CurrentCamera
    if camera then
        originalFOV = camera.FieldOfView
    end
end

-- Функция для восстановления оригинального FOV
local function restoreOriginalFOV()
    local camera = workspace.CurrentCamera
    if camera then
        camera.FieldOfView = originalFOV
    end
end

-- Функция для обновления FOV камеры
local function updateCameraFOV()
    if not isFOVEnabled then return end
    
    local camera = workspace.CurrentCamera
    if camera then
        camera.FieldOfView = currentFOV
    end
end

-- Player Glow функция
local function createPlayerGlow(character)
    if not character or not character.Parent or not isPlayerGlowEnabled then return end
    
    if playerGlows[character] then
        playerGlows[character]:Destroy()
        playerGlows[character] = nil
    end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    
    local glow = Instance.new("PointLight")
    glow.Name = "PlayerGlow"
    glow.Color = glowSettings.color
    glow.Brightness = 1.5
    glow.Range = glowSettings.range
    glow.Shadows = false
    glow.Parent = humanoidRootPart
    
    playerGlows[character] = glow
end

local function removePlayerGlow(character)
    if playerGlows[character] then
        playerGlows[character]:Destroy()
        playerGlows[character] = nil
    end
end

local function updatePlayerGlow(character)
    if playerGlows[character] then
        playerGlows[character].Color = glowSettings.color
        playerGlows[character].Range = glowSettings.range
    end
end

local function updatePlayerGlows()
    for _, otherPlayer in pairs(Players:GetPlayers()) do
        if otherPlayer.Character then
            createPlayerGlow(otherPlayer.Character)
        end
    end
    if player.Character then
        createPlayerGlow(player.Character)
    end
end

local function togglePlayerGlows()
    if isPlayerGlowEnabled then
        updatePlayerGlows()
        showNotification("Player Glow Enabled! [G]")
    else
        for character, _ in pairs(playerGlows) do
            removePlayerGlow(character)
        end
        playerGlows = {}
        showNotification("Player Glow Disabled!")
    end
end

-- Chams система с Forcefield (без цилиндра)
local function applyForcefieldMaterial(character)
    if not character or not character.Parent then return end
    
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Material = Enum.Material.ForceField
            part.Transparency = 0.3
            part.Color = GUI_COLORS.title
        end
    end
end

local function removeForcefieldMaterial(character)
    if not character then return end
    
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Material = Enum.Material.Plastic
            part.Transparency = 0
            part.Color = Color3.fromRGB(255, 255, 255)
        end
    end
end

local function createNameLabel(player, character)
    if nameLabels[player] then
        if nameLabels[player].connection then
            nameLabels[player].connection:Disconnect()
        end
        nameLabels[player].gui:Destroy()
        nameLabels[player] = nil
    end
    
    local nameGui = Instance.new("ScreenGui")
    nameGui.Name = "NameLabel_" .. player.Name
    nameGui.ResetOnSpawn = false
    nameGui.Parent = game:GetService("CoreGui")
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 200, 0, 20)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = player.Name
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 14
    label.Font = Enum.Font.GothamBold
    label.Visible = false
    label.ZIndex = 10
    label.Parent = nameGui
    
    nameLabels[player] = {gui = nameGui, label = label}
    
    local function updateNameLabel()
        if not chamsSettings.showNames or not character or not character.Parent then 
            label.Visible = false
            return 
        end
        
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        local head = character:FindFirstChild("Head")
        
        if not humanoidRootPart or not head then 
            label.Visible = false
            return 
        end
        
        local camera = workspace.CurrentCamera
        if not camera then return end
        
        local headPosition = head.Position + Vector3.new(0, 2, 0)
        local screenPoint, onScreen = camera:WorldToViewportPoint(headPosition)
        
        if onScreen then
            label.Position = UDim2.new(0, screenPoint.X - 100, 0, screenPoint.Y - 50)
            label.Visible = true
        else
            label.Visible = false
        end
    end
    
    local connection = RunService.RenderStepped:Connect(updateNameLabel)
    nameLabels[player].connection = connection
end

local function createDistanceLabel(player, character)
    if distanceLabels[player] then
        if distanceLabels[player].connection then
            distanceLabels[player].connection:Disconnect()
        end
        distanceLabels[player].gui:Destroy()
        distanceLabels[player] = nil
    end
    
    local distanceGui = Instance.new("ScreenGui")
    distanceGui.Name = "DistanceLabel_" .. player.Name
    distanceGui.ResetOnSpawn = false
    distanceGui.Parent = game:GetService("CoreGui")
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 200, 0, 20)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = "0m"
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 12
    label.Font = Enum.Font.Gotham
    label.Visible = false
    label.ZIndex = 10
    label.Parent = distanceGui
    
    distanceLabels[player] = {gui = distanceGui, label = label}
    
    local function updateDistanceLabel()
        if not chamsSettings.showDistance or not character or not character.Parent then 
            label.Visible = false
            return 
        end
        
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        local head = character:FindFirstChild("Head")
        
        if not humanoidRootPart or not head then 
            label.Visible = false
            return 
        end
        
        local camera = workspace.CurrentCamera
        if not camera then return end
        
        local headPosition = head.Position + Vector3.new(0, 1.5, 0)
        local screenPoint, onScreen = camera:WorldToViewportPoint(headPosition)
        
        if onScreen then
            local distance = (humanoidRootPart.Position - camera.CFrame.Position).Magnitude
            label.Text = math.floor(distance) .. "m"
            label.Position = UDim2.new(0, screenPoint.X - 100, 0, screenPoint.Y - 30)
            label.Visible = true
        else
            label.Visible = false
        end
    end
    
    local connection = RunService.RenderStepped:Connect(updateDistanceLabel)
    distanceLabels[player].connection = connection
end

local function removeNameLabel(player)
    if nameLabels[player] then
        if nameLabels[player].connection then
            nameLabels[player].connection:Disconnect()
        end
        nameLabels[player].gui:Destroy()
        nameLabels[player] = nil
    end
end

local function removeDistanceLabel(player)
    if distanceLabels[player] then
        if distanceLabels[player].connection then
            distanceLabels[player].connection:Disconnect()
        end
        distanceLabels[player].gui:Destroy()
        distanceLabels[player] = nil
    end
end

local function applyChams(character, playerObj)
    if not character or not character.Parent or not isChamsEnabled then return end
    
    if chamsInstances[character] then
        for _, instance in pairs(chamsInstances[character]) do
            if instance then
                instance:Destroy()
            end
        end
    end
    
    chamsInstances[character] = {}
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "NeonChams"
    highlight.Parent = character
    highlight.Adornee = character
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    
    highlight.FillColor = chamsSettings.fillColor
    highlight.FillTransparency = chamsSettings.fillTransparency
    highlight.OutlineColor = chamsSettings.outlineColor
    highlight.OutlineTransparency = chamsSettings.outlineTransparency
    highlight.Enabled = true
    
    table.insert(chamsInstances[character], highlight)
    
    if playerObj and playerObj ~= player then
        if chamsSettings.showNames then
            createNameLabel(playerObj, character)
        end
        if chamsSettings.showDistance then
            createDistanceLabel(playerObj, character)
        end
    end
end

local function removeChams(character, playerObj)
    if chamsInstances[character] then
        for _, instance in pairs(chamsInstances[character]) do
            if instance then
                instance:Destroy()
            end
        end
        chamsInstances[character] = nil
    end
    
    if playerObj then
        removeNameLabel(playerObj)
        removeDistanceLabel(playerObj)
    end
end

local function updateChams()
    if isChamsEnabled then
        for _, otherPlayer in pairs(Players:GetPlayers()) do
            if otherPlayer ~= player and otherPlayer.Character then
                applyChams(otherPlayer.Character, otherPlayer)
            end
        end
    else
        for character, _ in pairs(chamsInstances) do
            removeChams(character)
        end
        chamsInstances = {}
        
        for playerObj, _ in pairs(nameLabels) do
            removeNameLabel(playerObj)
        end
        nameLabels = {}
        
        for playerObj, _ in pairs(distanceLabels) do
            removeDistanceLabel(playerObj)
        end
        distanceLabels = {}
    end
end

local function updateNameAndDistanceLabels()
    for playerObj, data in pairs(nameLabels) do
        if playerObj.Character then
            removeNameLabel(playerObj)
            if chamsSettings.showNames then
                createNameLabel(playerObj, playerObj.Character)
            end
        end
    end
    
    for playerObj, data in pairs(distanceLabels) do
        if playerObj.Character then
            removeDistanceLabel(playerObj)
            if chamsSettings.showDistance then
                createDistanceLabel(playerObj, playerObj.Character)
            end
        end
    end
end

-- Функция для применения ночных настроек
local function applyNightSettings()
    if not Lighting:FindFirstChild("OriginalSettings") then
        local original = Instance.new("Folder")
        original.Name = "OriginalSettings"
        original.Parent = Lighting
        
        local time = Instance.new("NumberValue")
        time.Name = "TimeOfDay"
        time.Value = Lighting.TimeOfDay
        time.Parent = original
        
        local brightness = Instance.new("NumberValue")
        brightness.Name = "Brightness"
        brightness.Value = Lighting.Brightness
        brightness.Parent = original
        
        local ambient = Instance.new("Color3Value")
        ambient.Name = "Ambient"
        ambient.Value = Lighting.Ambient
        ambient.Parent = original
        
        local outdoorAmbient = Instance.new("Color3Value")
        outdoorAmbient.Name = "OutdoorAmbient"
        outdoorAmbient.Value = Lighting.OutdoorAmbient
        outdoorAmbient.Parent = original
    end
    
    Lighting.TimeOfDay = "00:00:00"
    Lighting.Brightness = 0.1
    Lighting.Ambient = Color3.fromRGB(50, 50, 70)
    Lighting.OutdoorAmbient = Color3.fromRGB(50, 50, 70)
end

-- Функция для удаления анимаций
local function removeAnimations()
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("AnimationController") or obj:IsA("Animator") then
            obj:Destroy()
        end
    end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player.Character then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid:SetStateEnabled(Enum.HumanoidStateType.Running, false)
                humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
                humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, false)
                humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
            end
        end
    end
end

-- Функция для создания FOV круга
local function createFOVCircle()
    if fovCircle then
        fovCircle:Destroy()
    end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "FOVCircle"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = game:GetService("CoreGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 100, 0, 100)
    frame.Position = UDim2.new(0.5, -50, 0.5, -50)
    frame.BackgroundTransparency = 1
    frame.Visible = true
    frame.Parent = screenGui
    
    local circle = Instance.new("ImageLabel")
    circle.Size = UDim2.new(1, 0, 1, 0)
    circle.BackgroundTransparency = 1
    circle.Image = "rbxassetid://5533218378"
    circle.ImageColor3 = GUI_COLORS.title
    circle.ImageTransparency = 0.4
    circle.Parent = frame
    
    fovCircle = frame
end

-- Функция для создания настроек функции
local function createFunctionSettings(parentFrame, functionName, yOffset, height)
    local settingsFrame = Instance.new("Frame")
    settingsFrame.Name = functionName .. "Settings"
    settingsFrame.Size = UDim2.new(1, -20, 0, 0)
    settingsFrame.Position = UDim2.new(0, 10, 0, yOffset)
    settingsFrame.BackgroundColor3 = GUI_COLORS.mainBackground
    settingsFrame.BackgroundTransparency = 0.5
    settingsFrame.BorderSizePixel = 0
    settingsFrame.Visible = false
    settingsFrame.ClipsDescendants = true
    settingsFrame.Parent = parentFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = settingsFrame
    
    settingsFrames[functionName] = {
        frame = settingsFrame,
        height = height or 120
    }
    return settingsFrame
end

-- Функция для пересчета позиций фреймов
local function updateFramePositions(parentFrame)
    local baseY = 45
    local currentY = baseY
    
    for _, child in pairs(parentFrame:GetChildren()) do
        if child:IsA("TextButton") and child.Name ~= "TitleLabel" then
            child.Position = UDim2.new(0, 10, 0, currentY)
            currentY = currentY + child.Size.Y.Offset + 5
            
            local settingsKey = child.Name
            if settingsFrames[settingsKey] and settingsFrames[settingsKey].frame.Visible then
                settingsFrames[settingsKey].frame.Position = UDim2.new(0, 10, 0, currentY)
                currentY = currentY + settingsFrames[settingsKey].height + 5
            end
        end
    end
    
    parentFrame.Size = UDim2.new(0, 280, 0, currentY + 10)
end

-- Функция для переключения настроек функции
local function toggleFunctionSettings(functionName, parentFrame)
    local settingsData = settingsFrames[functionName]
    if not settingsData then return end
    
    local settingsFrame = settingsData.frame
    local isOpening = not settingsFrame.Visible
    
    for name, data in pairs(settingsFrames) do
        if name ~= functionName and data.frame.Visible and data.frame.Parent == parentFrame then
            tweenSize(data.frame, UDim2.new(1, -20, 0, 0), 0.2, function()
                data.frame.Visible = false
                updateFramePositions(parentFrame)
            end)
        end
    end
    
    if isOpening then
        settingsFrame.Visible = true
        tweenSize(settingsFrame, UDim2.new(1, -20, 0, settingsData.height), 0.2, function()
            updateFramePositions(parentFrame)
        end)
    else
        tweenSize(settingsFrame, UDim2.new(1, -20, 0, 0), 0.2, function()
            settingsFrame.Visible = false
            updateFramePositions(parentFrame)
        end)
    end
end

-- Обработчики для игроков
local function setupPlayerHandlers()
    local function onPlayerAdded(otherPlayer)
        otherPlayer.CharacterAdded:Connect(function(character)
            wait(1)
            
            if isChamsEnabled then
                applyChams(character, otherPlayer)
            end
            
            if isPlayerGlowEnabled then
                createPlayerGlow(character)
            end
        end)
        
        otherPlayer.CharacterRemoving:Connect(function(character)
            removeChams(character, otherPlayer)
            removePlayerGlow(character)
        end)
        
        if otherPlayer.Character then
            wait(1)
            if isChamsEnabled then
                applyChams(otherPlayer.Character, otherPlayer)
            end
            if isPlayerGlowEnabled then
                createPlayerGlow(otherPlayer.Character)
            end
        end
    end

    player.CharacterAdded:Connect(function(character)
        wait(1)
        if isPlayerGlowEnabled then
            createPlayerGlow(character)
        end
    end)

    player.CharacterRemoving:Connect(function(character)
        removePlayerGlow(character)
    end)

    for _, otherPlayer in pairs(Players:GetPlayers()) do
        if otherPlayer ~= player then
            onPlayerAdded(otherPlayer)
        else
            if player.Character then
                wait(1)
                if isPlayerGlowEnabled then
                    createPlayerGlow(player.Character)
                end
            end
        end
    end

    Players.PlayerAdded:Connect(onPlayerAdded)
    
    Players.PlayerRemoving:Connect(function(leftPlayer)
        if leftPlayer.Character then
            removeChams(leftPlayer.Character, leftPlayer)
            removePlayerGlow(leftPlayer.Character)
        end
        removeNameLabel(leftPlayer)
        removeDistanceLabel(leftPlayer)
    end)
end

-- Глобальные обработчики ввода
local function setupGlobalInputHandlers()
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == Enum.KeyCode.RightShift then
            isGUIVisible = not isGUIVisible
            if guiElements and guiElements.mainPanel then
                guiElements.mainPanel.Visible = isGUIVisible
                showNotification("GUI " .. (isGUIVisible and "Enabled!" or "Disabled!"))
            end
        end
        
        if input.KeyCode == Enum.KeyCode.RightControl then
            isAimbotEnabled = not isAimbotEnabled
            if guiElements and guiElements.aimbotButton then
                updateButtonTextColor(guiElements.aimbotButton, isAimbotEnabled)
            end
            showNotification("RAGE Aimbot " .. (isAimbotEnabled and "Enabled!" or "Disabled!"))
        end
        
        if input.KeyCode == Enum.KeyCode.B then
            isChamsEnabled = not isChamsEnabled
            if guiElements and guiElements.chamsButton then
                updateButtonTextColor(guiElements.chamsButton, isChamsEnabled)
            end
            updateChams()
            showNotification("Chams " .. (isChamsEnabled and "Enabled!" or "Disabled!"))
        end
        
        if input.KeyCode == Enum.KeyCode.G then
            isPlayerGlowEnabled = not isPlayerGlowEnabled
            if guiElements and guiElements.glowButton then
                updateButtonTextColor(guiElements.glowButton, isPlayerGlowEnabled)
            end
            togglePlayerGlows()
        end
        
        if input.KeyCode == Enum.KeyCode.X then
            if isStrafeEnabled then
                stopStrafe()
            else
                startStrafe()
            end
            if guiElements and guiElements.strafeButton then
                updateButtonTextColor(guiElements.strafeButton, isStrafeEnabled)
            end
        end
        
        if input.KeyCode == Enum.KeyCode.H then
            if isSpeedHackEnabled then
                stopSpeedHack()
            else
                startSpeedHack()
            end
            if guiElements and guiElements.speedHackButton then
                updateButtonTextColor(guiElements.speedHackButton, isSpeedHackEnabled)
            end
        end
        
        if input.UserInputType == AIM_KEY and isAimbotEnabled then
            startAiming()
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == AIM_KEY then
            stopAiming()
        end
    end)
end

-- Функция для создания эффекта свечения курсора
local function createCursorGlowEffect(welcomeScreen)
    local cursorGui = Instance.new("ScreenGui")
    cursorGui.Name = "CursorGlow"
    cursorGui.ResetOnSpawn = false
    cursorGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    cursorGui.Parent = welcomeScreen
    
    -- Основное свечение курсора
    local glowFrame = Instance.new("Frame")
    glowFrame.Size = UDim2.new(0, 120, 0, 120)
    glowFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    glowFrame.BackgroundTransparency = 1
    glowFrame.ZIndex = 10
    glowFrame.Parent = cursorGui
    
    local glowCorner = Instance.new("UICorner")
    glowCorner.CornerRadius = UDim.new(1, 0)
    glowCorner.Parent = glowFrame
    
    -- Внешнее свечение
    local outerGlow = Instance.new("ImageLabel")
    outerGlow.Size = UDim2.new(1, 0, 1, 0)
    outerGlow.BackgroundTransparency = 1
    outerGlow.Image = "rbxassetid://5533218378"
    outerGlow.ImageColor3 = Color3.fromRGB(255, 105, 180)
    outerGlow.ImageTransparency = 0.7
    outerGlow.ScaleType = Enum.ScaleType.Slice
    outerGlow.SliceCenter = Rect.new(100, 100, 100, 100)
    outerGlow.Parent = glowFrame
    
    -- Внутреннее свечение
    local innerGlow = Instance.new("ImageLabel")
    innerGlow.Size = UDim2.new(0.6, 0, 0.6, 0)
    innerGlow.AnchorPoint = Vector2.new(0.5, 0.5)
    innerGlow.Position = UDim2.new(0.5, 0, 0.5, 0)
    innerGlow.BackgroundTransparency = 1
    innerGlow.Image = "rbxassetid://5533218378"
    innerGlow.ImageColor3 = Color3.fromRGB(255, 20, 147)
    innerGlow.ImageTransparency = 0.5
    innerGlow.Parent = glowFrame
    
    -- Анимация пульсации
    local pulseConnection
    pulseConnection = RunService.Heartbeat:Connect(function()
        local mouse = game:GetService("Players").LocalPlayer:GetMouse()
        glowFrame.Position = UDim2.new(0, mouse.X, 0, mouse.Y)
        
        -- Пульсация свечения
        local time = tick()
        local pulse = math.sin(time * 3) * 0.1 + 0.9
        outerGlow.ImageTransparency = 0.7 + (pulse * 0.2)
        innerGlow.ImageTransparency = 0.5 + (pulse * 0.3)
    end)
    
    return cursorGui, pulseConnection
end

-- Функция для создания вращающихся элементов (уменьшена скорость)
local function createRotatingElements(parent)
    local rotatingContainer = Instance.new("Frame")
    rotatingContainer.Size = UDim2.new(1, 0, 1, 0)
    rotatingContainer.BackgroundTransparency = 1
    rotatingContainer.ZIndex = 10  -- Поверх всего
    rotatingContainer.Parent = parent
    
    -- Создаем несколько вращающихся кругов
    local circles = {}
    local circleCount = 3
    
    for i = 1, circleCount do
        local circleFrame = Instance.new("Frame")
        circleFrame.Size = UDim2.new(0, (80 + i * 40) * 1.5, 0, (80 + i * 40) * 1.5)  -- Увеличено в 1.5 раза
        circleFrame.AnchorPoint = Vector2.new(0.5, 0.5)
        circleFrame.Position = UDim2.new(0.5, 0, 0.5, -20)  -- Поднято на 20px (~2см)
        circleFrame.BackgroundTransparency = 1
        circleFrame.ZIndex = 10
        circleFrame.Parent = rotatingContainer
        
        local elements = {}
        local elementCount = 8
        
        for j = 1, elementCount do
            local element = Instance.new("Frame")
            element.Size = UDim2.new(0, 18, 0, 18)  -- Увеличено с 12 до 18 (12 * 1.5)
            element.AnchorPoint = Vector2.new(0.5, 0.5)
            element.BackgroundColor3 = Color3.fromRGB(101, 218, 255)
            element.BackgroundTransparency = 0.7
            element.BorderSizePixel = 0
            element.ZIndex = 10  -- Поверх всего
            element.Parent = circleFrame
            
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(1, 0)
            corner.Parent = element
            
            table.insert(elements, {
                frame = element,
                angle = (j - 1) * (360 / elementCount),
                radius = (35 + i * 20) * 1.5,  -- Увеличен радиус в 1.5 раза
                speed = 0.2 + i * 0.15 -- Уменьшена скорость вращения
            })
        end
        
        table.insert(circles, elements)
    end
    
    -- Анимация вращения
    local rotationConnection
    rotationConnection = RunService.Heartbeat:Connect(function()
        for _, circle in ipairs(circles) do
            for _, element in ipairs(circle) do
                element.angle = element.angle + element.speed
                if element.angle >= 360 then
                    element.angle = element.angle - 360
                end
                
                local rad = math.rad(element.angle)
                local x = math.cos(rad) * element.radius
                local y = math.sin(rad) * element.radius
                
                element.frame.Position = UDim2.new(0.5, x, 0.5, y)
                
                -- Пульсация прозрачности
                local pulse = (math.sin(element.angle * 0.1) + 1) * 0.5
                element.frame.BackgroundTransparency = 0.3 + pulse * 0.4
            end
        end
    end)
    
    return rotatingContainer, rotationConnection
end

-- Создание приветственного экрана с вращающимися элементами
local function createWelcomeScreen()
    welcomeScreen = Instance.new("ScreenGui")
    welcomeScreen.Name = "WelcomeScreen"
    welcomeScreen.IgnoreGuiInset = true
    welcomeScreen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    welcomeScreen.Parent = game:GetService("CoreGui")
    
    -- Основной фрейм с закругленными углами
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0.6, 0, 0.6, 0)
    mainFrame.Position = UDim2.new(0.2, 0, -0.6, 0)
    mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    mainFrame.Position = UDim2.new(0.5, 0, -0.6, 0)
    mainFrame.BackgroundColor3 = Color3.fromRGB(29, 34, 47)
    mainFrame.BackgroundTransparency = 0.1
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.ZIndex = 2
    mainFrame.Parent = welcomeScreen
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 24)
    corner.Parent = mainFrame

    -- Aurora градиент для приветственного экрана
    local welcomeGradient = Instance.new("UIGradient")
    welcomeGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(29, 34, 47)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(37, 43, 59)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(45, 52, 71))
    })
    welcomeGradient.Rotation = 135
    welcomeGradient.Parent = mainFrame

    -- Пульсирующая обводка для фрейма
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(0, 255, 196)
    stroke.Thickness = 2
    stroke.Transparency = 0.3
    stroke.Parent = mainFrame
    
    -- Анимация пульсации обводки приветственного экрана
    task.spawn(function()
        local colorProgress = 0
        local transparencyProgress = 0
        while mainFrame.Parent do
            -- Плавный переход цвета
            colorProgress = colorProgress + 0.01
            if colorProgress >= 1 then colorProgress = 0 end
            
            local color1 = Color3.fromRGB(0, 255, 196)
            local color2 = Color3.fromRGB(0, 149, 255)
            local t = (math.sin(colorProgress * math.pi * 2) + 1) / 2
            stroke.Color = color1:Lerp(color2, t)
            
            -- Пульсация прозрачности
            transparencyProgress = transparencyProgress + 0.02
            if transparencyProgress >= 1 then transparencyProgress = 0 end
            stroke.Transparency = 0.1 + (math.sin(transparencyProgress * math.pi * 2) + 1) / 2 * 0.4
            
            task.wait(0.03)
        end
    end)

    -- Добавляем вращающиеся элементы на фон
    local rotatingContainer, rotationConnection = createRotatingElements(mainFrame)
    
    -- ========================================
    -- НОВОГОДНИЕ ЭФФЕКТЫ
    -- ========================================
    
    -- 1. Северное сияние (Aurora Borealis) - более заметное
    local auroraContainer = Instance.new("Frame")
    auroraContainer.Size = UDim2.new(1, 0, 1, 0)
    auroraContainer.BackgroundTransparency = 1
    auroraContainer.ZIndex = 1
    auroraContainer.Parent = mainFrame
    
    for i = 1, 5 do
        local auroraWave = Instance.new("Frame")
        auroraWave.Size = UDim2.new(1, 0, 0, 100)  -- Убрана ширина 1.5, теперь 1
        auroraWave.Position = UDim2.new(0, 0, 0.15 + i * 0.12, 0)  -- Позиция без выхода за края
        auroraWave.BackgroundColor3 = ({
            Color3.fromRGB(64, 224, 208),  -- Turquoise
            Color3.fromRGB(138, 43, 226),  -- Blue Violet
            Color3.fromRGB(0, 191, 255),   -- Deep Sky Blue
            Color3.fromRGB(147, 112, 219), -- Medium Purple
            Color3.fromRGB(101, 218, 255)  -- Aurora Cyan
        })[i]
        auroraWave.BackgroundTransparency = 0.8  -- Яркость уменьшена на 50%
        auroraWave.BorderSizePixel = 0
        auroraWave.ZIndex = 1
        auroraWave.Parent = auroraContainer
        
        -- Закругленные углы для Aurora
        local auroraCorner = Instance.new("UICorner")
        auroraCorner.CornerRadius = UDim.new(0, 50)  -- Закругление 50px
        auroraCorner.Parent = auroraWave
        
        local auroraGradient = Instance.new("UIGradient")
        auroraGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(0.5, auroraWave.BackgroundColor3),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
        })
        auroraGradient.Rotation = 90
        auroraGradient.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(0.3, 0.7),  -- Яркость уменьшена на 50%
            NumberSequenceKeypoint.new(0.7, 0.7),
            NumberSequenceKeypoint.new(1, 1)
        })
        auroraGradient.Parent = auroraWave
        
        -- Анимация волн с изгибом
        task.spawn(function()
            local progress = (i - 1) * 0.2
            while auroraWave.Parent do
                progress = progress + 0.005
                if progress >= 1 then progress = 0 end
                
                -- Создаем изгиб через rotation
                local bend = math.sin(progress * math.pi * 2) * 3  -- Легкий изгиб ±3 градуса
                local offset = math.sin(progress * math.pi * 2) * 20  -- Покачивание
                
                auroraWave.Position = UDim2.new(0, offset, 0.15 + i * 0.12, 0)
                auroraWave.Rotation = bend + (-3 + i * 1.5)  -- Базовый наклон + изгиб
                auroraWave.BackgroundTransparency = 0.7 + math.sin(progress * math.pi * 4) * 0.15
                
                task.wait(0.05)
            end
        end)
    end
    
    
    -- 1. Падающий снег (голубой)
    local snowContainer = Instance.new("Frame")
    snowContainer.Size = UDim2.new(1, 0, 1, 0)
    snowContainer.BackgroundTransparency = 1
    snowContainer.ZIndex = 3
    snowContainer.ClipsDescendants = true  -- Снег не выходит за края
    snowContainer.Parent = mainFrame
    
    local snowflakes = {}
    for i = 1, 25 do
        local snowflake = Instance.new("ImageLabel")
        snowflake.Size = UDim2.new(0, math.random(8, 16), 0, math.random(8, 16))
        snowflake.Position = UDim2.new(math.random(5, 95) / 100, 0, math.random(-50, 0) / 100, 0)  -- 5-95% вместо 0-100%
        snowflake.BackgroundTransparency = 1
        snowflake.Image = "rbxassetid://6031068420"
        snowflake.ImageColor3 = Color3.fromRGB(150, 200, 255)  -- Голубой цвет
        snowflake.ImageTransparency = math.random(20, 60) / 100
        snowflake.Rotation = math.random(0, 360)
        snowflake.ZIndex = 3
        snowflake.Parent = snowContainer
        
        table.insert(snowflakes, {
            frame = snowflake,
            speed = math.random(2, 6) / 100,
            sway = math.random(-5, 5) / 1000,  -- Уменьшено покачивание
            rotSpeed = math.random(-2, 2)
        })
    end
    
    -- Анимация падающего снега
    task.spawn(function()
        while snowContainer.Parent do
            for _, snow in ipairs(snowflakes) do
                local currentY = snow.frame.Position.Y.Scale
                local currentX = snow.frame.Position.X.Scale
                local newY = currentY + snow.speed
                local newX = currentX + snow.sway
                
                -- Ограничиваем позицию по X
                if newX < 0.05 then newX = 0.05 end
                if newX > 0.95 then newX = 0.95 end
                
                if newY > 1.05 then
                    newY = -0.05
                    newX = math.random(5, 95) / 100
                end
                
                snow.frame.Position = UDim2.new(newX, 0, newY, 0)
                snow.frame.Rotation = (snow.frame.Rotation + snow.rotSpeed) % 360
            end
            
            task.wait(0.03)
        end
    end)
    
    -- 5. Блестящие частицы (звездная пыль)
    local particlesContainer = Instance.new("Frame")
    particlesContainer.Size = UDim2.new(1, 0, 1, 0)
    particlesContainer.BackgroundTransparency = 1
    particlesContainer.ZIndex = 2
    particlesContainer.ClipsDescendants = true
    particlesContainer.Parent = mainFrame
    
    local particles = {}
    for i = 1, 35 do
        local particle = Instance.new("Frame")
        particle.Size = UDim2.new(0, math.random(2, 5), 0, math.random(2, 5))
        particle.Position = UDim2.new(math.random(5, 95) / 100, 0, math.random(5, 95) / 100, 0)
        particle.BackgroundColor3 = ({
            Color3.fromRGB(255, 255, 200),  -- Золотистый
            Color3.fromRGB(200, 230, 255),  -- Голубой
            Color3.fromRGB(255, 240, 255),  -- Розоватый
            Color3.fromRGB(220, 255, 220)   -- Зеленоватый
        })[math.random(1, 4)]
        particle.BackgroundTransparency = 0.5
        particle.BorderSizePixel = 0
        particle.ZIndex = 2
        particle.Parent = particlesContainer
        
        local particleCorner = Instance.new("UICorner")
        particleCorner.CornerRadius = UDim.new(1, 0)
        particleCorner.Parent = particle
        
        table.insert(particles, {
            frame = particle,
            baseX = particle.Position.X.Scale,
            baseY = particle.Position.Y.Scale,
            speedX = math.random(-10, 10) / 1000,
            speedY = math.random(-10, 10) / 1000,
            fadeSpeed = math.random(2, 5) / 100
        })
    end
    
    -- Анимация блестящих частиц
    task.spawn(function()
        while particlesContainer.Parent do
            for _, p in ipairs(particles) do
                local currentX = p.frame.Position.X.Scale
                local currentY = p.frame.Position.Y.Scale
                local newX = currentX + p.speedX
                local newY = currentY + p.speedY
                
                -- Ограничиваем позицию
                if newX < 0.05 or newX > 0.95 then
                    p.speedX = -p.speedX
                    newX = math.max(0.05, math.min(0.95, newX))
                end
                if newY < 0.05 or newY > 0.95 then
                    p.speedY = -p.speedY
                    newY = math.max(0.05, math.min(0.95, newY))
                end
                
                p.frame.Position = UDim2.new(newX, 0, newY, 0)
                
                -- Мерцание
                local transparency = p.frame.BackgroundTransparency + p.fadeSpeed
                if transparency > 0.9 or transparency < 0.2 then
                    p.fadeSpeed = -p.fadeSpeed
                end
                p.frame.BackgroundTransparency = math.max(0.2, math.min(0.9, transparency))
            end
            
            task.wait(0.03)
        end
    end)

    -- Заголовок (без прозрачности)
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(0.6, 0, 0.4, 0)
    titleLabel.Position = UDim2.new(0.05, 0, 0.1, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "VinScript"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 48
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.ZIndex = 3
    titleLabel.Parent = mainFrame
    
    -- Подзаголовок (без прозрачности)
    local subtitleLabel = Instance.new("TextLabel")
    subtitleLabel.Size = UDim2.new(0.6, 0, 0.1, 0)
    subtitleLabel.Position = UDim2.new(0.05, 0, 0.5, 0)
    subtitleLabel.BackgroundTransparency = 1
    subtitleLabel.Text = "Made by Vinomin, with love"
    subtitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    subtitleLabel.TextSize = 19
    subtitleLabel.Font = Enum.Font.Gotham
    subtitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    subtitleLabel.ZIndex = 3
    subtitleLabel.Parent = mainFrame
    
    -- Кнопка START (без прозрачности)
    local startButton = Instance.new("TextButton")
    startButton.Size = UDim2.new(0.4, 0, 0.12, 0)
    startButton.Position = UDim2.new(0.05, 0, 0.7, 0)
    startButton.BackgroundColor3 = GUI_COLORS.title
    startButton.BackgroundTransparency = 0
    startButton.Text = "START"
    startButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    startButton.TextSize = 24
    startButton.Font = Enum.Font.GothamBold
    startButton.ZIndex = 3
    startButton.Visible = true
    startButton.Parent = mainFrame
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 12)
    buttonCorner.Parent = startButton
    
    -- Aurora градиент для кнопки START
    local startButtonGradient = Instance.new("UIGradient")
    startButtonGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(132, 171, 251)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(101, 218, 255))
    })
    startButtonGradient.Rotation = 45
    startButtonGradient.Parent = startButton
    
    -- Пульсирующая обводка кнопки
    local buttonStroke = Instance.new("UIStroke")
    buttonStroke.Color = Color3.fromRGB(0, 255, 196)
    buttonStroke.Thickness = 2
    buttonStroke.Transparency = 0.3
    buttonStroke.Parent = startButton
    
    -- Анимация пульсации обводки кнопки START
    task.spawn(function()
        local progress = 0
        while startButton.Parent do
            progress = progress + 0.015
            if progress >= 1 then progress = 0 end
            
            local color1 = Color3.fromRGB(0, 255, 196)
            local color2 = Color3.fromRGB(0, 149, 255)
            local t = (math.sin(progress * math.pi * 2) + 1) / 2
            buttonStroke.Color = color1:Lerp(color2, t)
            
            task.wait(0.03)
        end
    end)
    
    -- Кнопка Discord
    local discordButton = Instance.new("TextButton")
    discordButton.Size = UDim2.new(0, 70, 0, 70)
    discordButton.Position = UDim2.new(0.85, -35, 0.85, -35)
    discordButton.BackgroundColor3 = Color3.fromRGB(23, 23, 23)
    discordButton.BackgroundTransparency = 0.1
    discordButton.Text = "D"
    discordButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    discordButton.TextSize = 28
    discordButton.Font = Enum.Font.GothamBold
    discordButton.ZIndex = 3
    discordButton.Parent = mainFrame
    
    local discordCorner = Instance.new("UICorner")
    discordCorner.CornerRadius = UDim.new(0, 12)
    discordCorner.Parent = discordButton
    
    -- Эффекты при наведении на кнопки
    startButton.MouseEnter:Connect(function()
        local tween = TweenService:Create(startButton, TweenInfo.new(0.2), {
            BackgroundColor3 = GUI_COLORS.accent
        })
        tween:Play()
    end)
    
    startButton.MouseLeave:Connect(function()
        local tween = TweenService:Create(startButton, TweenInfo.new(0.2), {
            BackgroundColor3 = GUI_COLORS.title
        })
        tween:Play()
    end)
    
    discordButton.MouseEnter:Connect(function()
        local tween = TweenService:Create(discordButton, TweenInfo.new(0.2), {
            BackgroundTransparency = 0,
            Size = UDim2.new(0, 75, 0, 75)
        })
        tween:Play()
    end)
    
    discordButton.MouseLeave:Connect(function()
        local tween = TweenService:Create(discordButton, TweenInfo.new(0.2), {
            BackgroundTransparency = 0.1,
            Size = UDim2.new(0, 70, 0, 70)
        })
        tween:Play()
    end)
    
    discordButton.MouseButton1Click:Connect(function()
        local discordLink = "https://discord.gg/YKCS4CkQ2s"
        if copyToClipboard(discordLink) then
            showNotification("Discord link copied!")
        else
            showNotification("Failed to copy: " .. discordLink)
        end
    end)
    
    return mainFrame, startButton, rotationConnection
end

-- Создание основного GUI
local function createMainGUI()
    mainGUI = Instance.new("ScreenGui")
    mainGUI.Name = "MainGUI"
    mainGUI.ResetOnSpawn = false
    mainGUI.Parent = game:GetService("CoreGui")
    
    -- Основная темно-серая панель
    local mainPanel = Instance.new("Frame")
    mainPanel.Size = UDim2.new(0, 911, 0, 500)
    mainPanel.Position = UDim2.new(0.5, -455, 0.5, -250)
    mainPanel.BackgroundColor3 = GUI_COLORS.mainBackground
    mainPanel.BackgroundTransparency = 0.05
    mainPanel.BorderSizePixel = 0
    mainPanel.Visible = true
    mainPanel.Parent = mainGUI

    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 15)
    mainCorner.Parent = mainPanel
    
    -- Aurora градиент для главной панели
    local mainGradient = Instance.new("UIGradient")
    mainGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(29, 34, 47)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(37, 43, 59)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(45, 52, 71))
    })
    mainGradient.Rotation = 135
    mainGradient.Parent = mainPanel
    
    -- Пульсирующая обводка с переходом цвета
    local mainStroke = Instance.new("UIStroke")
    mainStroke.Color = Color3.fromRGB(0, 255, 196)
    mainStroke.Thickness = 1.5
    mainStroke.Transparency = 0.3
    mainStroke.Parent = mainPanel
    
    -- Анимация пульсации и перехода цвета
    task.spawn(function()
        local colorProgress = 0
        local transparencyProgress = 0
        while mainPanel.Parent do
            -- Плавный переход цвета
            colorProgress = colorProgress + 0.01
            if colorProgress >= 1 then colorProgress = 0 end
            
            local color1 = Color3.fromRGB(0, 255, 196)
            local color2 = Color3.fromRGB(0, 149, 255)
            local t = (math.sin(colorProgress * math.pi * 2) + 1) / 2
            mainStroke.Color = color1:Lerp(color2, t)
            
            -- Пульсация прозрачности
            transparencyProgress = transparencyProgress + 0.02
            if transparencyProgress >= 1 then transparencyProgress = 0 end
            mainStroke.Transparency = 0.1 + (math.sin(transparencyProgress * math.pi * 2) + 1) / 2 * 0.4
            
            task.wait(0.03)
        end
    end)
    
    -- ========================================
    -- НОВОГОДНИЙ ДЕКОР ДЛЯ ГЛАВНОГО GUI
    -- ========================================
    
    -- Гирлянда сверху
    local garlandContainer = Instance.new("Frame")
    garlandContainer.Size = UDim2.new(1, -40, 0, 8)
    garlandContainer.Position = UDim2.new(0, 20, 0, 5)
    garlandContainer.BackgroundTransparency = 1
    garlandContainer.ZIndex = 5
    garlandContainer.Parent = mainPanel
    
    for i = 1, 15 do
        local light = Instance.new("Frame")
        light.Size = UDim2.new(0, 8, 0, 8)
        light.Position = UDim2.new((i - 1) / 14, 0, 0, 0)
        light.BackgroundColor3 = ({
            Color3.fromRGB(150, 200, 255),  -- Голубой
            Color3.fromRGB(0, 149, 255),    -- Синий
        })[(i - 1) % 2 + 1]
        light.BackgroundTransparency = 0.3
        light.BorderSizePixel = 0
        light.ZIndex = 5
        light.Parent = garlandContainer
        
        local lightCorner = Instance.new("UICorner")
        lightCorner.CornerRadius = UDim.new(1, 0)
        lightCorner.Parent = light
        
        -- Анимация мигания
        task.spawn(function()
            local offset = (i - 1) * 0.1
            local progress = offset
            while light.Parent do
                progress = progress + 0.05
                if progress >= 1 then progress = 0 end
                
                local pulse = (math.sin(progress * math.pi * 2) + 1) / 2
                light.BackgroundTransparency = 0.2 + pulse * 0.6
                
                task.wait(0.05)
            end
        end)
    end
    
    -- Зимние звездочки в случайных местах
    for i = 1, 8 do
        local star = Instance.new("Frame")
        star.Size = UDim2.new(0, 3, 0, 3)
        star.Position = UDim2.new(math.random(10, 90) / 100, 0, math.random(10, 90) / 100, 0)
        star.BackgroundColor3 = Color3.fromRGB(200, 230, 255)
        star.BackgroundTransparency = 0.3
        star.BorderSizePixel = 0
        star.ZIndex = 1
        star.Parent = mainPanel
        
        local starCorner = Instance.new("UICorner")
        starCorner.CornerRadius = UDim.new(1, 0)
        starCorner.Parent = star
        
        -- Мерцание
        task.spawn(function()
            local progress = math.random(0, 100) / 100
            while star.Parent do
                progress = progress + 0.03
                if progress >= 1 then progress = 0 end
                
                local pulse = (math.sin(progress * math.pi * 2) + 1) / 2
                star.BackgroundTransparency = 0.2 + pulse * 0.7
                
                task.wait(0.05)
            end
        end)
    end

    -- Столбец Combat
    local combatFrame = Instance.new("Frame")
    combatFrame.Size = UDim2.new(0, 280, 0, 450)
    combatFrame.Position = UDim2.new(0, 20, 0, 20)
    combatFrame.BackgroundColor3 = GUI_COLORS.columnBackground
    combatFrame.BackgroundTransparency = 0.3
    combatFrame.BorderSizePixel = 0
    combatFrame.Visible = true
    combatFrame.Parent = mainPanel

    local combatCorner = Instance.new("UICorner")
    combatCorner.CornerRadius = UDim.new(0, 10)
    combatCorner.Parent = combatFrame
    

    local combatTitleLabel = Instance.new("TextLabel")
    combatTitleLabel.Name = "TitleLabel"
    combatTitleLabel.Size = UDim2.new(1, -20, 0, 35)
    combatTitleLabel.Position = UDim2.new(0, 10, 0, 5)
    combatTitleLabel.BackgroundColor3 = GUI_COLORS.title
    combatTitleLabel.BackgroundTransparency = 0.1
    combatTitleLabel.BorderSizePixel = 0
    combatTitleLabel.Text = "COMBAT"
    combatTitleLabel.TextColor3 = TEXT_COLOR
    combatTitleLabel.TextTransparency = 0
    combatTitleLabel.TextSize = 16
    combatTitleLabel.Font = Enum.Font.GothamBold
    combatTitleLabel.Parent = combatFrame

    local combatTitleCorner = Instance.new("UICorner")
    combatTitleCorner.CornerRadius = UDim.new(0, 8)
    combatTitleCorner.Parent = combatTitleLabel
    
    -- Aurora градиент для заголовка Combat
    local combatTitleGradient = Instance.new("UIGradient")
    combatTitleGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(132, 171, 251)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(101, 218, 255))
    })
    combatTitleGradient.Rotation = 90
    combatTitleGradient.Parent = combatTitleLabel
    

    -- Aimbot
    local aimbotButton = Instance.new("TextButton")
    aimbotButton.Name = "AimbotButton"
    aimbotButton.Size = UDim2.new(1, -20, 0, 35)
    aimbotButton.Position = UDim2.new(0, 10, 0, 45)
    aimbotButton.BackgroundColor3 = GUI_COLORS.mainBackground
    aimbotButton.BackgroundTransparency = 0.3
    aimbotButton.Text = "Aimbot [R-Ctrl]"
    aimbotButton.TextColor3 = GUI_COLORS.disabled
    aimbotButton.TextSize = 14
    aimbotButton.Font = Enum.Font.Gotham
    aimbotButton.TextXAlignment = Enum.TextXAlignment.Left
    aimbotButton.Parent = combatFrame

    local aimbotCorner = Instance.new("UICorner")
    aimbotCorner.CornerRadius = UDim.new(0, 6)
    aimbotCorner.Parent = aimbotButton

    -- FOV
    local fovButton = Instance.new("TextButton")
    fovButton.Name = "FOVButton"
    fovButton.Size = UDim2.new(1, -20, 0, 35)
    fovButton.Position = UDim2.new(0, 10, 0, 85)
    fovButton.BackgroundColor3 = GUI_COLORS.mainBackground
    fovButton.BackgroundTransparency = 0.3
    fovButton.Text = "FOV"
    fovButton.TextColor3 = GUI_COLORS.disabled
    fovButton.TextSize = 14
    fovButton.Font = Enum.Font.Gotham
    fovButton.TextXAlignment = Enum.TextXAlignment.Left
    fovButton.Parent = combatFrame

    local fovCorner = Instance.new("UICorner")
    fovCorner.CornerRadius = UDim.new(0, 6)
    fovCorner.Parent = fovButton

    -- TriggerBot
    local triggerButton = Instance.new("TextButton")
    triggerButton.Name = "TriggerButton"
    triggerButton.Size = UDim2.new(1, -20, 0, 35)
    triggerButton.Position = UDim2.new(0, 10, 0, 125)
    triggerButton.BackgroundColor3 = GUI_COLORS.mainBackground
    triggerButton.BackgroundTransparency = 0.3
    triggerButton.Text = "TriggerBot"
    triggerButton.TextColor3 = GUI_COLORS.disabled
    triggerButton.TextSize = 14
    triggerButton.Font = Enum.Font.Gotham
    triggerButton.TextXAlignment = Enum.TextXAlignment.Left
    triggerButton.Parent = combatFrame

    local triggerCorner = Instance.new("UICorner")
    triggerCorner.CornerRadius = UDim.new(0, 6)
    triggerCorner.Parent = triggerButton

    -- ModelChanger
    local modelChangerButton = Instance.new("TextButton")
    modelChangerButton.Name = "ModelChangerButton"
    modelChangerButton.Size = UDim2.new(1, -20, 0, 35)
    modelChangerButton.Position = UDim2.new(0, 10, 0, 165)
    modelChangerButton.BackgroundColor3 = GUI_COLORS.mainBackground
    modelChangerButton.BackgroundTransparency = 0.3
    modelChangerButton.Text = "Model Changer"
    modelChangerButton.TextColor3 = GUI_COLORS.disabled
    modelChangerButton.TextSize = 14
    modelChangerButton.Font = Enum.Font.Gotham
    modelChangerButton.TextXAlignment = Enum.TextXAlignment.Left
    modelChangerButton.Parent = combatFrame

    local modelChangerCorner = Instance.new("UICorner")
    modelChangerCorner.CornerRadius = UDim.new(0, 6)
    modelChangerCorner.Parent = modelChangerButton

    -- Столбец Visual
    local visualFrame = Instance.new("Frame")
    visualFrame.Size = UDim2.new(0, 280, 0, 450)
    visualFrame.Position = UDim2.new(0, 315, 0, 20)
    visualFrame.BackgroundColor3 = GUI_COLORS.columnBackground
    visualFrame.BackgroundTransparency = 0.3
    visualFrame.BorderSizePixel = 0
    visualFrame.Visible = true
    visualFrame.Parent = mainPanel

    local visualCorner = Instance.new("UICorner")
    visualCorner.CornerRadius = UDim.new(0, 10)
    visualCorner.Parent = visualFrame
    

    local visualTitleLabel = Instance.new("TextLabel")
    visualTitleLabel.Name = "TitleLabel"
    visualTitleLabel.Size = UDim2.new(1, -20, 0, 35)
    visualTitleLabel.Position = UDim2.new(0, 10, 0, 5)
    visualTitleLabel.BackgroundColor3 = GUI_COLORS.title
    visualTitleLabel.BackgroundTransparency = 0.1
    visualTitleLabel.BorderSizePixel = 0
    visualTitleLabel.Text = "VISUAL"
    visualTitleLabel.TextColor3 = TEXT_COLOR
    visualTitleLabel.TextTransparency = 0
    visualTitleLabel.TextSize = 16
    visualTitleLabel.Font = Enum.Font.GothamBold
    visualTitleLabel.Parent = visualFrame

    local visualTitleCorner = Instance.new("UICorner")
    visualTitleCorner.CornerRadius = UDim.new(0, 8)
    visualTitleCorner.Parent = visualTitleLabel
    
    -- Aurora градиент для заголовка Visual
    local visualTitleGradient = Instance.new("UIGradient")
    visualTitleGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(132, 171, 251)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(101, 218, 255))
    })
    visualTitleGradient.Rotation = 90
    visualTitleGradient.Parent = visualTitleLabel
    

    -- Chams
    local chamsButton = Instance.new("TextButton")
    chamsButton.Name = "ChamsButton"
    chamsButton.Size = UDim2.new(1, -20, 0, 35)
    chamsButton.Position = UDim2.new(0, 10, 0, 45)
    chamsButton.BackgroundColor3 = GUI_COLORS.mainBackground
    chamsButton.BackgroundTransparency = 0.3
    chamsButton.Text = "Chams [B]"
    chamsButton.TextColor3 = GUI_COLORS.disabled
    chamsButton.TextSize = 14
    chamsButton.Font = Enum.Font.Gotham
    chamsButton.TextXAlignment = Enum.TextXAlignment.Left
    chamsButton.Parent = visualFrame

    local chamsCorner = Instance.new("UICorner")
    chamsCorner.CornerRadius = UDim.new(0, 6)
    chamsCorner.Parent = chamsButton

    -- Player Glow
    local glowButton = Instance.new("TextButton")
    glowButton.Name = "GlowButton"
    glowButton.Size = UDim2.new(1, -20, 0, 35)
    glowButton.Position = UDim2.new(0, 10, 0, 85)
    glowButton.BackgroundColor3 = GUI_COLORS.mainBackground
    glowButton.BackgroundTransparency = 0.3
    glowButton.Text = "Player Glow [G]"
    glowButton.TextColor3 = GUI_COLORS.disabled
    glowButton.TextSize = 14
    glowButton.Font = Enum.Font.Gotham
    glowButton.TextXAlignment = Enum.TextXAlignment.Left
    glowButton.Parent = visualFrame

    local glowCorner = Instance.new("UICorner")
    glowCorner.CornerRadius = UDim.new(0, 6)
    glowCorner.Parent = glowButton

    -- X-Ray
    local xrayButton = Instance.new("TextButton")
    xrayButton.Name = "XRayButton"
    xrayButton.Size = UDim2.new(1, -20, 0, 35)
    xrayButton.Position = UDim2.new(0, 10, 0, 125)
    xrayButton.BackgroundColor3 = GUI_COLORS.mainBackground
    xrayButton.BackgroundTransparency = 0.3
    xrayButton.Text = "X-Ray"
    xrayButton.TextColor3 = GUI_COLORS.disabled
    xrayButton.TextSize = 14
    xrayButton.Font = Enum.Font.Gotham
    xrayButton.TextXAlignment = Enum.TextXAlignment.Left
    xrayButton.Parent = visualFrame

    local xrayCorner = Instance.new("UICorner")
    xrayCorner.CornerRadius = UDim.new(0, 6)
    xrayCorner.Parent = xrayButton

    -- World Modulation
    local worldModButton = Instance.new("TextButton")
    worldModButton.Name = "WorldModButton"
    worldModButton.Size = UDim2.new(1, -20, 0, 35)
    worldModButton.Position = UDim2.new(0, 10, 0, 165)
    worldModButton.BackgroundColor3 = GUI_COLORS.mainBackground
    worldModButton.BackgroundTransparency = 0.3
    worldModButton.Text = "World Modulation"
    worldModButton.TextColor3 = GUI_COLORS.disabled
    worldModButton.TextSize = 14
    worldModButton.Font = Enum.Font.Gotham
    worldModButton.TextXAlignment = Enum.TextXAlignment.Left
    worldModButton.Parent = visualFrame

    local worldModCorner = Instance.new("UICorner")
    worldModCorner.CornerRadius = UDim.new(0, 6)
    worldModCorner.Parent = worldModButton

    -- Столбец Movement
    local movementFrame = Instance.new("Frame")
    movementFrame.Size = UDim2.new(0, 280, 0, 450)
    movementFrame.Position = UDim2.new(0, 610, 0, 20)
    movementFrame.BackgroundColor3 = GUI_COLORS.columnBackground
    movementFrame.BackgroundTransparency = 0.3
    movementFrame.BorderSizePixel = 0
    movementFrame.Visible = true
    movementFrame.Parent = mainPanel

    local movementCorner = Instance.new("UICorner")
    movementCorner.CornerRadius = UDim.new(0, 10)
    movementCorner.Parent = movementFrame
    

    local movementTitleLabel = Instance.new("TextLabel")
    movementTitleLabel.Name = "TitleLabel"
    movementTitleLabel.Size = UDim2.new(1, -20, 0, 35)
    movementTitleLabel.Position = UDim2.new(0, 10, 0, 5)
    movementTitleLabel.BackgroundColor3 = GUI_COLORS.title
    movementTitleLabel.BackgroundTransparency = 0.1
    movementTitleLabel.BorderSizePixel = 0
    movementTitleLabel.Text = "MOVEMENT"
    movementTitleLabel.TextColor3 = TEXT_COLOR
    movementTitleLabel.TextTransparency = 0
    movementTitleLabel.TextSize = 16
    movementTitleLabel.Font = Enum.Font.GothamBold
    movementTitleLabel.Parent = movementFrame

    local movementTitleCorner = Instance.new("UICorner")
    movementTitleCorner.CornerRadius = UDim.new(0, 8)
    movementTitleCorner.Parent = movementTitleLabel
    
    -- Aurora градиент для заголовка Movement
    local movementTitleGradient = Instance.new("UIGradient")
    movementTitleGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(132, 171, 251)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(101, 218, 255))
    })
    movementTitleGradient.Rotation = 90
    movementTitleGradient.Parent = movementTitleLabel
    

    -- Strafe
    local strafeButton = Instance.new("TextButton")
    strafeButton.Name = "StrafeButton"
    strafeButton.Size = UDim2.new(1, -20, 0, 35)
    strafeButton.Position = UDim2.new(0, 10, 0, 45)
    strafeButton.BackgroundColor3 = GUI_COLORS.mainBackground
    strafeButton.BackgroundTransparency = 0.3
    strafeButton.Text = "Strafe + FastStop [X]"
    strafeButton.TextColor3 = GUI_COLORS.disabled
    strafeButton.TextSize = 14
    strafeButton.Font = Enum.Font.Gotham
    strafeButton.TextXAlignment = Enum.TextXAlignment.Left
    strafeButton.Parent = movementFrame

    local strafeCorner = Instance.new("UICorner")
    strafeCorner.CornerRadius = UDim.new(0, 6)
    strafeCorner.Parent = strafeButton

    -- SpeedHack
    local speedHackButton = Instance.new("TextButton")
    speedHackButton.Name = "SpeedHackButton"
    speedHackButton.Size = UDim2.new(1, -20, 0, 35)
    speedHackButton.Position = UDim2.new(0, 10, 0, 85)
    speedHackButton.BackgroundColor3 = GUI_COLORS.mainBackground
    speedHackButton.BackgroundTransparency = 0.3
    speedHackButton.Text = "SpeedHack [H]"
    speedHackButton.TextColor3 = GUI_COLORS.disabled
    speedHackButton.TextSize = 14
    speedHackButton.Font = Enum.Font.Gotham
    speedHackButton.TextXAlignment = Enum.TextXAlignment.Left
    speedHackButton.Parent = movementFrame

    local speedHackCorner = Instance.new("UICorner")
    speedHackCorner.CornerRadius = UDim.new(0, 6)
    speedHackCorner.Parent = speedHackButton

    -- BunnyHop
    local bunnyHopButton = Instance.new("TextButton")
    bunnyHopButton.Name = "BunnyHopButton"
    bunnyHopButton.Size = UDim2.new(1, -20, 0, 35)
    bunnyHopButton.Position = UDim2.new(0, 10, 0, 125)
    bunnyHopButton.BackgroundColor3 = GUI_COLORS.mainBackground
    bunnyHopButton.BackgroundTransparency = 0.3
    bunnyHopButton.Text = "BunnyHop"
    bunnyHopButton.TextColor3 = GUI_COLORS.disabled
    bunnyHopButton.TextSize = 14
    bunnyHopButton.Font = Enum.Font.Gotham
    bunnyHopButton.TextXAlignment = Enum.TextXAlignment.Left
    bunnyHopButton.Parent = movementFrame

    local bunnyHopCorner = Instance.new("UICorner")
    bunnyHopCorner.CornerRadius = UDim.new(0, 6)
    bunnyHopCorner.Parent = bunnyHopButton

    -- Создаем настройки для функций
    local aimbotSettingsFrame = createFunctionSettings(combatFrame, "AimbotButton", 85, 190)
    local chamsSettingsFrame = createFunctionSettings(visualFrame, "ChamsButton", 85, 180)
    local glowSettingsFrame = createFunctionSettings(visualFrame, "GlowButton", 125, 120)
    local triggerSettingsFrame = createFunctionSettings(combatFrame, "TriggerButton", 125, 120)
    local modelChangerSettingsFrame = createFunctionSettings(combatFrame, "ModelChangerButton", 205, 120)
    local worldModSettingsFrame = createFunctionSettings(visualFrame, "WorldModButton", 205, 135)
    
    -- Настройки для Aimbot
    local tracersFrame = Instance.new("Frame")
    tracersFrame.Size = UDim2.new(1, -20, 0, 25)
    tracersFrame.Position = UDim2.new(0, 10, 0, 10)
    tracersFrame.BackgroundTransparency = 1
    tracersFrame.Parent = aimbotSettingsFrame

    local tracersLabel = Instance.new("TextLabel")
    tracersLabel.Size = UDim2.new(0.7, 0, 1, 0)
    tracersLabel.Position = UDim2.new(0, 0, 0, 0)
    tracersLabel.BackgroundTransparency = 1
    tracersLabel.Text = "Bullet Tracers"
    tracersLabel.TextColor3 = TEXT_COLOR
    tracersLabel.TextSize = 12
    tracersLabel.Font = Enum.Font.Gotham
    tracersLabel.TextXAlignment = Enum.TextXAlignment.Left
    tracersLabel.Parent = tracersFrame

    local tracersToggle = Instance.new("TextButton")
    tracersToggle.Size = UDim2.new(0, 20, 0, 20)
    tracersToggle.Position = UDim2.new(0.7, 0, 0, 2)
    tracersToggle.BackgroundColor3 = aimbotSettings.tracers and GUI_COLORS.enabled or GUI_COLORS.disabled
    tracersToggle.Text = ""
    tracersToggle.Parent = tracersFrame

    local tracersToggleCorner = Instance.new("UICorner")
    tracersToggleCorner.CornerRadius = UDim.new(0, 4)
    tracersToggleCorner.Parent = tracersToggle

    -- Цвет трассеров
    local tracerColorLabel = Instance.new("TextLabel")
    tracerColorLabel.Size = UDim2.new(1, -20, 0, 25)
    tracerColorLabel.Position = UDim2.new(0, 10, 0, 40)
    tracerColorLabel.BackgroundTransparency = 1
    tracerColorLabel.Text = "Tracer Color"
    tracerColorLabel.TextColor3 = TEXT_COLOR
    tracerColorLabel.TextSize = 12
    tracerColorLabel.Font = Enum.Font.Gotham
    tracerColorLabel.TextXAlignment = Enum.TextXAlignment.Left
    tracerColorLabel.Parent = aimbotSettingsFrame

    local tracerColorPreview = Instance.new("TextButton")
    tracerColorPreview.Size = UDim2.new(0, 60, 0, 20)
    tracerColorPreview.Position = UDim2.new(0, 10, 0, 65)
    tracerColorPreview.BackgroundColor3 = aimbotSettings.tracerColor
    tracerColorPreview.BorderSizePixel = 1
    tracerColorPreview.BorderColor3 = Color3.fromRGB(255, 255, 255)
    tracerColorPreview.Text = ""
    tracerColorPreview.Parent = aimbotSettingsFrame

    local tracerColorPreviewCorner = Instance.new("UICorner")
    tracerColorPreviewCorner.CornerRadius = UDim.new(0, 4)
    tracerColorPreviewCorner.Parent = tracerColorPreview

    local aimbotInfoLabel = Instance.new("TextLabel")
    aimbotInfoLabel.Size = UDim2.new(1, -20, 0, 30)
    aimbotInfoLabel.Position = UDim2.new(0, 10, 0, 90)
    aimbotInfoLabel.BackgroundTransparency = 1
    aimbotInfoLabel.Text = "Creates neon bullet tracers when shooting"
    aimbotInfoLabel.TextColor3 = TEXT_COLOR
    aimbotInfoLabel.TextSize = 10
    aimbotInfoLabel.Font = Enum.Font.Gotham
    aimbotInfoLabel.TextXAlignment = Enum.TextXAlignment.Left
    aimbotInfoLabel.TextYAlignment = Enum.TextYAlignment.Top
    aimbotInfoLabel.Parent = aimbotSettingsFrame
    
    -- Режим аимбота
    local aimbotModeFrame = Instance.new("Frame")
    aimbotModeFrame.Size = UDim2.new(1, -20, 0, 25)
    aimbotModeFrame.Position = UDim2.new(0, 10, 0, 125)
    aimbotModeFrame.BackgroundTransparency = 1
    aimbotModeFrame.Parent = aimbotSettingsFrame

    local aimbotModeLabel = Instance.new("TextLabel")
    aimbotModeLabel.Size = UDim2.new(0.5, 0, 1, 0)
    aimbotModeLabel.Position = UDim2.new(0, 0, 0, 0)
    aimbotModeLabel.BackgroundTransparency = 1
    aimbotModeLabel.Text = "Mode: " .. aimbotSettings.mode
    aimbotModeLabel.TextColor3 = TEXT_COLOR
    aimbotModeLabel.TextSize = 12
    aimbotModeLabel.Font = Enum.Font.Gotham
    aimbotModeLabel.TextXAlignment = Enum.TextXAlignment.Left
    aimbotModeLabel.Parent = aimbotModeFrame

    local aimbotModeButton = Instance.new("TextButton")
    aimbotModeButton.Size = UDim2.new(0, 70, 0, 20)
    aimbotModeButton.Position = UDim2.new(0.5, 0, 0, 2)
    aimbotModeButton.BackgroundColor3 = GUI_COLORS.title
    aimbotModeButton.BorderSizePixel = 0
    aimbotModeButton.Text = "Change"
    aimbotModeButton.TextColor3 = TEXT_COLOR
    aimbotModeButton.TextSize = 11
    aimbotModeButton.Font = Enum.Font.GothamBold
    aimbotModeButton.Parent = aimbotModeFrame

    local aimbotModeCorner = Instance.new("UICorner")
    aimbotModeCorner.CornerRadius = UDim.new(0, 4)
    aimbotModeCorner.Parent = aimbotModeButton
    
    -- TargetGui toggle
    local targetGuiFrame = Instance.new("Frame")
    targetGuiFrame.Size = UDim2.new(1, -20, 0, 25)
    targetGuiFrame.Position = UDim2.new(0, 10, 0, 155)
    targetGuiFrame.BackgroundTransparency = 1
    targetGuiFrame.Parent = aimbotSettingsFrame

    local targetGuiLabel = Instance.new("TextLabel")
    targetGuiLabel.Size = UDim2.new(0.7, 0, 1, 0)
    targetGuiLabel.Position = UDim2.new(0, 0, 0, 0)
    targetGuiLabel.BackgroundTransparency = 1
    targetGuiLabel.Text = "Target GUI"
    targetGuiLabel.TextColor3 = TEXT_COLOR
    targetGuiLabel.TextSize = 12
    targetGuiLabel.Font = Enum.Font.Gotham
    targetGuiLabel.TextXAlignment = Enum.TextXAlignment.Left
    targetGuiLabel.Parent = targetGuiFrame

    local targetGuiToggle = Instance.new("TextButton")
    targetGuiToggle.Size = UDim2.new(0, 20, 0, 20)
    targetGuiToggle.Position = UDim2.new(0.7, 0, 0, 2)
    targetGuiToggle.BackgroundColor3 = aimbotSettings.showTargetGui and GUI_COLORS.enabled or GUI_COLORS.disabled
    targetGuiToggle.Text = ""
    targetGuiToggle.Parent = targetGuiFrame

    local targetGuiToggleCorner = Instance.new("UICorner")
    targetGuiToggleCorner.CornerRadius = UDim.new(0, 4)
    targetGuiToggleCorner.Parent = targetGuiToggle

    -- Настройки для Chams
    local fillColorLabel = Instance.new("TextLabel")
    fillColorLabel.Size = UDim2.new(1, -20, 0, 25)
    fillColorLabel.Position = UDim2.new(0, 10, 0, 10)
    fillColorLabel.BackgroundTransparency = 1
    fillColorLabel.Text = "Fill Color"
    fillColorLabel.TextColor3 = TEXT_COLOR
    fillColorLabel.TextSize = 12
    fillColorLabel.Font = Enum.Font.Gotham
    fillColorLabel.TextXAlignment = Enum.TextXAlignment.Left
    fillColorLabel.Parent = chamsSettingsFrame

    local fillColorPreview = Instance.new("TextButton")
    fillColorPreview.Size = UDim2.new(0, 60, 0, 20)
    fillColorPreview.Position = UDim2.new(0, 10, 0, 35)
    fillColorPreview.BackgroundColor3 = chamsSettings.fillColor
    fillColorPreview.BackgroundTransparency = chamsSettings.fillTransparency
    fillColorPreview.BorderSizePixel = 1
    fillColorPreview.BorderColor3 = Color3.fromRGB(255, 255, 255)
    fillColorPreview.Text = ""
    fillColorPreview.Parent = chamsSettingsFrame

    local fillColorPreviewCorner = Instance.new("UICorner")
    fillColorPreviewCorner.CornerRadius = UDim.new(0, 4)
    fillColorPreviewCorner.Parent = fillColorPreview

    local outlineColorLabel = Instance.new("TextLabel")
    outlineColorLabel.Size = UDim2.new(1, -20, 0, 25)
    outlineColorLabel.Position = UDim2.new(0, 10, 0, 60)
    outlineColorLabel.BackgroundTransparency = 1
    outlineColorLabel.Text = "Outline Color"
    outlineColorLabel.TextColor3 = TEXT_COLOR
    outlineColorLabel.TextSize = 12
    outlineColorLabel.Font = Enum.Font.Gotham
    outlineColorLabel.TextXAlignment = Enum.TextXAlignment.Left
    outlineColorLabel.Parent = chamsSettingsFrame

    local outlineColorPreview = Instance.new("TextButton")
    outlineColorPreview.Size = UDim2.new(0, 60, 0, 20)
    outlineColorPreview.Position = UDim2.new(0, 10, 0, 85)
    outlineColorPreview.BackgroundColor3 = chamsSettings.outlineColor
    outlineColorPreview.BackgroundTransparency = chamsSettings.outlineTransparency
    outlineColorPreview.BorderSizePixel = 1
    outlineColorPreview.BorderColor3 = Color3.fromRGB(255, 255, 255)
    outlineColorPreview.Text = ""
    outlineColorPreview.Parent = chamsSettingsFrame

    local outlineColorPreviewCorner = Instance.new("UICorner")
    outlineColorPreviewCorner.CornerRadius = UDim.new(0, 4)
    outlineColorPreviewCorner.Parent = outlineColorPreview

    -- Names toggle
    local namesFrame = Instance.new("Frame")
    namesFrame.Size = UDim2.new(1, -20, 0, 25)
    namesFrame.Position = UDim2.new(0, 10, 0, 110)
    namesFrame.BackgroundTransparency = 1
    namesFrame.Parent = chamsSettingsFrame

    local namesLabel = Instance.new("TextLabel")
    namesLabel.Size = UDim2.new(0.7, 0, 1, 0)
    namesLabel.Position = UDim2.new(0, 0, 0, 0)
    namesLabel.BackgroundTransparency = 1
    namesLabel.Text = "Names"
    namesLabel.TextColor3 = TEXT_COLOR
    namesLabel.TextSize = 12
    namesLabel.Font = Enum.Font.Gotham
    namesLabel.TextXAlignment = Enum.TextXAlignment.Left
    namesLabel.Parent = namesFrame

    local namesToggle = Instance.new("TextButton")
    namesToggle.Size = UDim2.new(0, 20, 0, 20)
    namesToggle.Position = UDim2.new(0.7, 0, 0, 2)
    namesToggle.BackgroundColor3 = chamsSettings.showNames and GUI_COLORS.enabled or GUI_COLORS.disabled
    namesToggle.Text = ""
    namesToggle.Parent = namesFrame

    local namesToggleCorner = Instance.new("UICorner")
    namesToggleCorner.CornerRadius = UDim.new(0, 4)
    namesToggleCorner.Parent = namesToggle

    -- Distance toggle
    local distanceFrame = Instance.new("Frame")
    distanceFrame.Size = UDim2.new(1, -20, 0, 25)
    distanceFrame.Position = UDim2.new(0, 10, 0, 135)
    distanceFrame.BackgroundTransparency = 1
    distanceFrame.Parent = chamsSettingsFrame

    local distanceLabel = Instance.new("TextLabel")
    distanceLabel.Size = UDim2.new(0.7, 0, 1, 0)
    distanceLabel.Position = UDim2.new(0, 0, 0, 0)
    distanceLabel.BackgroundTransparency = 1
    distanceLabel.Text = "Distance"
    distanceLabel.TextColor3 = TEXT_COLOR
    distanceLabel.TextSize = 12
    distanceLabel.Font = Enum.Font.Gotham
    distanceLabel.TextXAlignment = Enum.TextXAlignment.Left
    distanceLabel.Parent = distanceFrame

    local distanceToggle = Instance.new("TextButton")
    distanceToggle.Size = UDim2.new(0, 20, 0, 20)
    distanceToggle.Position = UDim2.new(0.7, 0, 0, 2)
    distanceToggle.BackgroundColor3 = chamsSettings.showDistance and GUI_COLORS.enabled or GUI_COLORS.disabled
    distanceToggle.Text = ""
    distanceToggle.Parent = distanceFrame

    local distanceToggleCorner = Instance.new("UICorner")
    distanceToggleCorner.CornerRadius = UDim.new(0, 4)
    distanceToggleCorner.Parent = distanceToggle

    -- Настройки для Player Glow
    local glowColorLabel = Instance.new("TextLabel")
    glowColorLabel.Size = UDim2.new(1, -20, 0, 25)
    glowColorLabel.Position = UDim2.new(0, 10, 0, 10)
    glowColorLabel.BackgroundTransparency = 1
    glowColorLabel.Text = "Glow Color"
    glowColorLabel.TextColor3 = TEXT_COLOR
    glowColorLabel.TextSize = 12
    glowColorLabel.Font = Enum.Font.Gotham
    glowColorLabel.TextXAlignment = Enum.TextXAlignment.Left
    glowColorLabel.Parent = glowSettingsFrame

    local glowColorPreview = Instance.new("TextButton")
    glowColorPreview.Size = UDim2.new(0, 60, 0, 20)
    glowColorPreview.Position = UDim2.new(0, 10, 0, 35)
    glowColorPreview.BackgroundColor3 = glowSettings.color
    glowColorPreview.BorderSizePixel = 1
    glowColorPreview.BorderColor3 = Color3.fromRGB(255, 255, 255)
    glowColorPreview.Text = ""
    glowColorPreview.Parent = glowSettingsFrame

    local glowColorPreviewCorner = Instance.new("UICorner")
    glowColorPreviewCorner.CornerRadius = UDim.new(0, 4)
    glowColorPreviewCorner.Parent = glowColorPreview

    -- Строка для настройки дальности свечения
    local glowRangeFrame = Instance.new("Frame")
    glowRangeFrame.Size = UDim2.new(1, -20, 0, 25)
    glowRangeFrame.Position = UDim2.new(0, 10, 0, 60)
    glowRangeFrame.BackgroundTransparency = 1
    glowRangeFrame.Parent = glowSettingsFrame

    local glowRangeLabel = Instance.new("TextLabel")
    glowRangeLabel.Size = UDim2.new(0.5, 0, 1, 0)
    glowRangeLabel.Position = UDim2.new(0, 0, 0, 0)
    glowRangeLabel.BackgroundTransparency = 1
    glowRangeLabel.Text = "Range:"
    glowRangeLabel.TextColor3 = TEXT_COLOR
    glowRangeLabel.TextSize = 12
    glowRangeLabel.Font = Enum.Font.Gotham
    glowRangeLabel.TextXAlignment = Enum.TextXAlignment.Left
    glowRangeLabel.Parent = glowRangeFrame

    local glowRangeValue = Instance.new("TextLabel")
    glowRangeValue.Size = UDim2.new(0.3, 0, 1, 0)
    glowRangeValue.Position = UDim2.new(0.4, 0, 0, 0)
    glowRangeValue.BackgroundTransparency = 1
    glowRangeValue.Text = tostring(glowSettings.range)
    glowRangeValue.TextColor3 = TEXT_COLOR
    glowRangeValue.TextSize = 12
    glowRangeValue.Font = Enum.Font.GothamBold
    glowRangeValue.TextXAlignment = Enum.TextXAlignment.Center
    glowRangeValue.Parent = glowRangeFrame

    -- Кнопка минус для уменьшения дальности
    local glowRangeMinusButton = Instance.new("TextButton")
    glowRangeMinusButton.Size = UDim2.new(0, 25, 0, 20)
    glowRangeMinusButton.Position = UDim2.new(0.7, -30, 0, 2)
    glowRangeMinusButton.BackgroundColor3 = GUI_COLORS.title
    glowRangeMinusButton.BorderSizePixel = 0
    glowRangeMinusButton.Text = "-"
    glowRangeMinusButton.TextColor3 = TEXT_COLOR
    glowRangeMinusButton.TextSize = 14
    glowRangeMinusButton.Font = Enum.Font.GothamBold
    glowRangeMinusButton.Parent = glowRangeFrame

    local glowRangeMinusCorner = Instance.new("UICorner")
    glowRangeMinusCorner.CornerRadius = UDim.new(0, 4)
    glowRangeMinusCorner.Parent = glowRangeMinusButton

    -- Кнопка плюс для увеличения дальности
    local glowRangePlusButton = Instance.new("TextButton")
    glowRangePlusButton.Size = UDim2.new(0, 25, 0, 20)
    glowRangePlusButton.Position = UDim2.new(0.7, 0, 0, 2)
    glowRangePlusButton.BackgroundColor3 = GUI_COLORS.title
    glowRangePlusButton.BorderSizePixel = 0
    glowRangePlusButton.Text = "+"
    glowRangePlusButton.TextColor3 = TEXT_COLOR
    glowRangePlusButton.TextSize = 14
    glowRangePlusButton.Font = Enum.Font.GothamBold
    glowRangePlusButton.Parent = glowRangeFrame

    local glowRangePlusCorner = Instance.new("UICorner")
    glowRangePlusCorner.CornerRadius = UDim.new(0, 4)
    glowRangePlusCorner.Parent = glowRangePlusButton

    -- Настройки для TriggerBot
    local triggerDelayLabel = Instance.new("TextLabel")
    triggerDelayLabel.Size = UDim2.new(1, -20, 0, 25)
    triggerDelayLabel.Position = UDim2.new(0, 10, 0, 10)
    triggerDelayLabel.BackgroundTransparency = 1
    triggerDelayLabel.Text = "Delay: " .. triggerSettings.delay .. "s"
    triggerDelayLabel.TextColor3 = TEXT_COLOR
    triggerDelayLabel.TextSize = 12
    triggerDelayLabel.Font = Enum.Font.Gotham
    triggerDelayLabel.TextXAlignment = Enum.TextXAlignment.Left
    triggerDelayLabel.Parent = triggerSettingsFrame

    local triggerDistanceLabel = Instance.new("TextLabel")
    triggerDistanceLabel.Size = UDim2.new(1, -20, 0, 25)
    triggerDistanceLabel.Position = UDim2.new(0, 10, 0, 40)
    triggerDistanceLabel.BackgroundTransparency = 1
    triggerDistanceLabel.Text = "Max Distance: " .. triggerSettings.maxDistance
    triggerDistanceLabel.TextColor3 = TEXT_COLOR
    triggerDistanceLabel.TextSize = 12
    triggerDistanceLabel.Font = Enum.Font.Gotham
    triggerDistanceLabel.TextXAlignment = Enum.TextXAlignment.Left
    triggerDistanceLabel.Parent = triggerSettingsFrame

    local triggerInfoLabel = Instance.new("TextLabel")
    triggerInfoLabel.Size = UDim2.new(1, -20, 0, 50)
    triggerInfoLabel.Position = UDim2.new(0, 10, 0, 70)
    triggerInfoLabel.BackgroundTransparency = 1
    triggerInfoLabel.Text = "Auto-shoots when aiming at visible enemies"
    triggerInfoLabel.TextColor3 = TEXT_COLOR
    triggerInfoLabel.TextSize = 10
    triggerInfoLabel.Font = Enum.Font.Gotham
    triggerInfoLabel.TextXAlignment = Enum.TextXAlignment.Left
    triggerInfoLabel.TextYAlignment = Enum.TextYAlignment.Top
    triggerInfoLabel.Parent = triggerSettingsFrame

    -- Настройки для ModelChanger
    local modelChangerMaterialLabel = Instance.new("TextLabel")
    modelChangerMaterialLabel.Size = UDim2.new(1, -20, 0, 25)
    modelChangerMaterialLabel.Position = UDim2.new(0, 10, 0, 10)
    modelChangerMaterialLabel.BackgroundTransparency = 1
    modelChangerMaterialLabel.Text = "Material: Neon"
    modelChangerMaterialLabel.TextColor3 = TEXT_COLOR
    modelChangerMaterialLabel.TextSize = 12
    modelChangerMaterialLabel.Font = Enum.Font.Gotham
    modelChangerMaterialLabel.TextXAlignment = Enum.TextXAlignment.Left
    modelChangerMaterialLabel.Parent = modelChangerSettingsFrame

    -- Кнопка переключения материала
    local materialToggleButton = Instance.new("TextButton")
    materialToggleButton.Size = UDim2.new(0, 100, 0, 20)
    materialToggleButton.Position = UDim2.new(0, 10, 0, 35)
    materialToggleButton.BackgroundColor3 = GUI_COLORS.title
    materialToggleButton.BorderSizePixel = 0
    materialToggleButton.Text = "Change"
    materialToggleButton.TextColor3 = TEXT_COLOR
    materialToggleButton.TextSize = 11
    materialToggleButton.Font = Enum.Font.GothamBold
    materialToggleButton.Parent = modelChangerSettingsFrame

    local materialToggleCorner = Instance.new("UICorner")
    materialToggleCorner.CornerRadius = UDim.new(0, 4)
    materialToggleCorner.Parent = materialToggleButton

    local modelChangerColorLabel = Instance.new("TextLabel")
    modelChangerColorLabel.Size = UDim2.new(1, -20, 0, 25)
    modelChangerColorLabel.Position = UDim2.new(0, 10, 0, 60)
    modelChangerColorLabel.BackgroundTransparency = 1
    modelChangerColorLabel.Text = "Color"
    modelChangerColorLabel.TextColor3 = TEXT_COLOR
    modelChangerColorLabel.TextSize = 12
    modelChangerColorLabel.Font = Enum.Font.Gotham
    modelChangerColorLabel.TextXAlignment = Enum.TextXAlignment.Left
    modelChangerColorLabel.Parent = modelChangerSettingsFrame

    local modelChangerColorPreview = Instance.new("TextButton")
    modelChangerColorPreview.Size = UDim2.new(0, 60, 0, 20)
    modelChangerColorPreview.Position = UDim2.new(0, 10, 0, 85)
    modelChangerColorPreview.BackgroundColor3 = modelChangerSettings.color
    modelChangerColorPreview.BorderSizePixel = 1
    modelChangerColorPreview.BorderColor3 = Color3.fromRGB(255, 255, 255)
    modelChangerColorPreview.Text = ""
    modelChangerColorPreview.Parent = modelChangerSettingsFrame

    local modelChangerColorPreviewCorner = Instance.new("UICorner")
    modelChangerColorPreviewCorner.CornerRadius = UDim.new(0, 4)
    modelChangerColorPreviewCorner.Parent = modelChangerColorPreview

    local modelChangerInfoLabel = Instance.new("TextLabel")
    modelChangerInfoLabel.Size = UDim2.new(1, -20, 0, 60)
    modelChangerInfoLabel.Position = UDim2.new(0, 10, 0, 115)
    modelChangerInfoLabel.BackgroundTransparency = 1
    modelChangerInfoLabel.Text = "Full weapon model replacement!\nRemoves textures, changes material & color\nWorks with all weapon parts"
    modelChangerInfoLabel.TextColor3 = TEXT_COLOR
    modelChangerInfoLabel.TextSize = 10
    modelChangerInfoLabel.Font = Enum.Font.Gotham
    modelChangerInfoLabel.TextXAlignment = Enum.TextXAlignment.Left
    modelChangerInfoLabel.TextYAlignment = Enum.TextYAlignment.Top
    modelChangerInfoLabel.Parent = modelChangerSettingsFrame

    -- Настройки для WorldModulation
    -- Time of Day toggle
    local timeOfDayFrame = Instance.new("Frame")
    timeOfDayFrame.Size = UDim2.new(1, -20, 0, 25)
    timeOfDayFrame.Position = UDim2.new(0, 10, 0, 10)
    timeOfDayFrame.BackgroundTransparency = 1
    timeOfDayFrame.Parent = worldModSettingsFrame

    local timeOfDayLabel = Instance.new("TextLabel")
    timeOfDayLabel.Size = UDim2.new(0.5, 0, 1, 0)
    timeOfDayLabel.Position = UDim2.new(0, 0, 0, 0)
    timeOfDayLabel.BackgroundTransparency = 1
    timeOfDayLabel.Text = "Time: " .. worldModulationSettings.timeOfDay
    timeOfDayLabel.TextColor3 = TEXT_COLOR
    timeOfDayLabel.TextSize = 12
    timeOfDayLabel.Font = Enum.Font.Gotham
    timeOfDayLabel.TextXAlignment = Enum.TextXAlignment.Left
    timeOfDayLabel.Parent = timeOfDayFrame

    local timeOfDayButton = Instance.new("TextButton")
    timeOfDayButton.Size = UDim2.new(0, 70, 0, 20)
    timeOfDayButton.Position = UDim2.new(0.5, 0, 0, 2)
    timeOfDayButton.BackgroundColor3 = GUI_COLORS.title
    timeOfDayButton.BorderSizePixel = 0
    timeOfDayButton.Text = "Toggle"
    timeOfDayButton.TextColor3 = TEXT_COLOR
    timeOfDayButton.TextSize = 11
    timeOfDayButton.Font = Enum.Font.GothamBold
    timeOfDayButton.Parent = timeOfDayFrame

    local timeOfDayCorner = Instance.new("UICorner")
    timeOfDayCorner.CornerRadius = UDim.new(0, 4)
    timeOfDayCorner.Parent = timeOfDayButton

    -- Fog toggle
    local fogFrame = Instance.new("Frame")
    fogFrame.Size = UDim2.new(1, -20, 0, 25)
    fogFrame.Position = UDim2.new(0, 10, 0, 40)
    fogFrame.BackgroundTransparency = 1
    fogFrame.Parent = worldModSettingsFrame

    local fogLabel = Instance.new("TextLabel")
    fogLabel.Size = UDim2.new(0.7, 0, 1, 0)
    fogLabel.Position = UDim2.new(0, 0, 0, 0)
    fogLabel.BackgroundTransparency = 1
    fogLabel.Text = "Fog"
    fogLabel.TextColor3 = TEXT_COLOR
    fogLabel.TextSize = 12
    fogLabel.Font = Enum.Font.Gotham
    fogLabel.TextXAlignment = Enum.TextXAlignment.Left
    fogLabel.Parent = fogFrame

    local fogToggle = Instance.new("TextButton")
    fogToggle.Size = UDim2.new(0, 20, 0, 20)
    fogToggle.Position = UDim2.new(0.7, 0, 0, 2)
    fogToggle.BackgroundColor3 = worldModulationSettings.fog and GUI_COLORS.enabled or GUI_COLORS.disabled
    fogToggle.Text = ""
    fogToggle.Parent = fogFrame

    local fogToggleCorner = Instance.new("UICorner")
    fogToggleCorner.CornerRadius = UDim.new(0, 4)
    fogToggleCorner.Parent = fogToggle

    -- Shadows toggle
    local shadowsFrame = Instance.new("Frame")
    shadowsFrame.Size = UDim2.new(1, -20, 0, 25)
    shadowsFrame.Position = UDim2.new(0, 10, 0, 70)
    shadowsFrame.BackgroundTransparency = 1
    shadowsFrame.Parent = worldModSettingsFrame

    local shadowsLabel = Instance.new("TextLabel")
    shadowsLabel.Size = UDim2.new(0.7, 0, 1, 0)
    shadowsLabel.Position = UDim2.new(0, 0, 0, 0)
    shadowsLabel.BackgroundTransparency = 1
    shadowsLabel.Text = "Shadows"
    shadowsLabel.TextColor3 = TEXT_COLOR
    shadowsLabel.TextSize = 12
    shadowsLabel.Font = Enum.Font.Gotham
    shadowsLabel.TextXAlignment = Enum.TextXAlignment.Left
    shadowsLabel.Parent = shadowsFrame

    local shadowsToggle = Instance.new("TextButton")
    shadowsToggle.Size = UDim2.new(0, 20, 0, 20)
    shadowsToggle.Position = UDim2.new(0.7, 0, 0, 2)
    shadowsToggle.BackgroundColor3 = worldModulationSettings.shadows and GUI_COLORS.enabled or GUI_COLORS.disabled
    shadowsToggle.Text = ""
    shadowsToggle.Parent = shadowsFrame

    local shadowsToggleCorner = Instance.new("UICorner")
    shadowsToggleCorner.CornerRadius = UDim.new(0, 4)
    shadowsToggleCorner.Parent = shadowsToggle

    -- Custom Sky toggle
    local customSkyToggleFrame = Instance.new("Frame")
    customSkyToggleFrame.Size = UDim2.new(1, -20, 0, 25)
    customSkyToggleFrame.Position = UDim2.new(0, 10, 0, 100)
    customSkyToggleFrame.BackgroundTransparency = 1
    customSkyToggleFrame.Parent = worldModSettingsFrame

    local customSkyToggleLabel = Instance.new("TextLabel")
    customSkyToggleLabel.Size = UDim2.new(0.7, 0, 1, 0)
    customSkyToggleLabel.Position = UDim2.new(0, 0, 0, 0)
    customSkyToggleLabel.BackgroundTransparency = 1
    customSkyToggleLabel.Text = "Custom Sky"
    customSkyToggleLabel.TextColor3 = TEXT_COLOR
    customSkyToggleLabel.TextSize = 12
    customSkyToggleLabel.Font = Enum.Font.Gotham
    customSkyToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    customSkyToggleLabel.Parent = customSkyToggleFrame

    local customSkyToggle = Instance.new("TextButton")
    customSkyToggle.Size = UDim2.new(0, 20, 0, 20)
    customSkyToggle.Position = UDim2.new(0.7, 0, 0, 2)
    customSkyToggle.BackgroundColor3 = worldModulationSettings.customSky and GUI_COLORS.enabled or GUI_COLORS.disabled
    customSkyToggle.Text = ""
    customSkyToggle.Parent = customSkyToggleFrame

    local customSkyToggleCorner = Instance.new("UICorner")
    customSkyToggleCorner.CornerRadius = UDim.new(0, 4)
    customSkyToggleCorner.Parent = customSkyToggle

    local worldModInfoLabel = Instance.new("TextLabel")
    worldModInfoLabel.Size = UDim2.new(1, -20, 0, 30)
    worldModInfoLabel.Position = UDim2.new(0, 10, 0, 130)
    worldModInfoLabel.BackgroundTransparency = 1
    worldModInfoLabel.Text = "Control world lighting, fog, shadows and sky"
    worldModInfoLabel.TextColor3 = TEXT_COLOR
    worldModInfoLabel.TextSize = 10
    worldModInfoLabel.Font = Enum.Font.Gotham
    worldModInfoLabel.TextXAlignment = Enum.TextXAlignment.Left
    worldModInfoLabel.TextYAlignment = Enum.TextYAlignment.Top
    worldModInfoLabel.Parent = worldModSettingsFrame

    guiElements = {
        mainFrame = combatFrame,
        visualFrame = visualFrame,
        movementFrame = movementFrame,
        mainPanel = mainPanel,
        aimbotButton = aimbotButton,
        fovButton = fovButton,
        triggerButton = triggerButton,
        modelChangerButton = modelChangerButton,
        chamsButton = chamsButton,
        glowButton = glowButton,
        xrayButton = xrayButton,
        strafeButton = strafeButton,
        speedHackButton = speedHackButton,
        bunnyHopButton = bunnyHopButton,
        fillColorPreview = fillColorPreview,
        outlineColorPreview = outlineColorPreview,
        namesToggle = namesToggle,
        distanceToggle = distanceToggle,
        glowColorPreview = glowColorPreview,
        glowRangeValue = glowRangeValue,
        glowRangeMinusButton = glowRangeMinusButton,
        glowRangePlusButton = glowRangePlusButton,
        tracersToggle = tracersToggle,
        tracerColorPreview = tracerColorPreview,
        modelChangerColorPreview = modelChangerColorPreview,
        materialToggleButton = materialToggleButton,
        modelChangerMaterialLabel = modelChangerMaterialLabel,
        aimbotModeButton = aimbotModeButton,
        aimbotModeLabel = aimbotModeLabel,
        targetGuiToggle = targetGuiToggle,
        worldModButton = worldModButton,
        timeOfDayButton = timeOfDayButton,
        timeOfDayLabel = timeOfDayLabel,
        fogToggle = fogToggle,
        shadowsToggle = shadowsToggle,
        customSkyToggle = customSkyToggle
    }
    
    -- Добавляем анимации при наведении на все кнопки
    local allButtons = {
        aimbotButton, fovButton, triggerButton, modelChangerButton,
        chamsButton, glowButton, xrayButton, worldModButton,
        strafeButton, speedHackButton, bunnyHopButton
    }
    
    for _, button in ipairs(allButtons) do
        -- Добавляем тонкую обводку для каждой кнопки
        local buttonStroke = Instance.new("UIStroke")
        buttonStroke.Color = Color3.fromRGB(0, 149, 255)
        buttonStroke.Thickness = 0.8
        buttonStroke.Transparency = 0.5
        buttonStroke.Parent = button
        
        button.MouseEnter:Connect(function()
            -- Анимация при наведении
            local hoverTween = TweenService:Create(button, TweenInfo.new(0.2), {
                BackgroundTransparency = 0.1,
                Size = button.Size + UDim2.new(0, 5, 0, 2)
            })
            local strokeTween = TweenService:Create(buttonStroke, TweenInfo.new(0.2), {
                Transparency = 0.2
            })
            hoverTween:Play()
            strokeTween:Play()
        end)
        
        button.MouseLeave:Connect(function()
            -- Анимация при убирании курсора
            local leaveTween = TweenService:Create(button, TweenInfo.new(0.2), {
                BackgroundTransparency = 0.3,
                Size = UDim2.new(1, -20, 0, 35)
            })
            local strokeTween = TweenService:Create(buttonStroke, TweenInfo.new(0.2), {
                Transparency = 0.5
            })
            leaveTween:Play()
            strokeTween:Play()
        end)
    end
    
    return guiElements
end

-- Функция для настройки обработчиков кнопок
local function setupButtonHandlers()
    -- Обработчики для кнопок COMBAT
    guiElements.aimbotButton.MouseButton1Click:Connect(function()
        animateButtonClick(guiElements.aimbotButton)
        isAimbotEnabled = not isAimbotEnabled
        updateButtonTextColor(guiElements.aimbotButton, isAimbotEnabled)
        showNotification("Aimbot " .. (isAimbotEnabled and "Enabled!" or "Disabled!"))
    end)
    
    guiElements.fovButton.MouseButton1Click:Connect(function()
        animateButtonClick(guiElements.fovButton)
        isFOVEnabled = not isFOVEnabled
        updateButtonTextColor(guiElements.fovButton, isFOVEnabled)
        updateFOV()
    end)
    
    guiElements.triggerButton.MouseButton1Click:Connect(function()
        animateButtonClick(guiElements.triggerButton)
        if isTriggerBotEnabled then
            stopTriggerBot()
        else
            startTriggerBot()
        end
        updateButtonTextColor(guiElements.triggerButton, isTriggerBotEnabled)
    end)
    
    guiElements.modelChangerButton.MouseButton1Click:Connect(function()
        animateButtonClick(guiElements.modelChangerButton)
        isModelChangerEnabled = not isModelChangerEnabled
        updateButtonTextColor(guiElements.modelChangerButton, isModelChangerEnabled)
        if isModelChangerEnabled then
            enableModelChanger()
        else
            disableModelChanger()
        end
    end)
    
    -- Обработчики для кнопок VISUAL
    guiElements.chamsButton.MouseButton1Click:Connect(function()
        animateButtonClick(guiElements.chamsButton)
        isChamsEnabled = not isChamsEnabled
        updateButtonTextColor(guiElements.chamsButton, isChamsEnabled)
        updateChams()
        showNotification("Chams " .. (isChamsEnabled and "Enabled!" or "Disabled!"))
    end)
    
    guiElements.glowButton.MouseButton1Click:Connect(function()
        animateButtonClick(guiElements.glowButton)
        isPlayerGlowEnabled = not isPlayerGlowEnabled
        updateButtonTextColor(guiElements.glowButton, isPlayerGlowEnabled)
        togglePlayerGlows()
    end)
    
    guiElements.xrayButton.MouseButton1Click:Connect(function()
        animateButtonClick(guiElements.xrayButton)
        if isXRayEnabled then
            disableXRay()
        else
            enableXRay()
        end
    end)
    
    guiElements.worldModButton.MouseButton1Click:Connect(function()
        animateButtonClick(guiElements.worldModButton)
        -- Просто применяем настройки
        applyWorldModulation()
        showNotification("World Modulation Applied!")
    end)
    
    -- Обработчики для кнопок MOVEMENT
    guiElements.strafeButton.MouseButton1Click:Connect(function()
        animateButtonClick(guiElements.strafeButton)
        if isStrafeEnabled then
            stopStrafe()
        else
            startStrafe()
        end
        updateButtonTextColor(guiElements.strafeButton, isStrafeEnabled)
    end)
    
    guiElements.speedHackButton.MouseButton1Click:Connect(function()
        animateButtonClick(guiElements.speedHackButton)
        if isSpeedHackEnabled then
            stopSpeedHack()
        else
            startSpeedHack()
        end
        updateButtonTextColor(guiElements.speedHackButton, isSpeedHackEnabled)
    end)
    
    guiElements.bunnyHopButton.MouseButton1Click:Connect(function()
        animateButtonClick(guiElements.bunnyHopButton)
        if isBunnyHopEnabled then
            stopBunnyHop()
        else
            startBunnyHop()
        end
        updateButtonTextColor(guiElements.bunnyHopButton, isBunnyHopEnabled)
    end)
    
    -- Обработчики для настроек Aimbot
    guiElements.aimbotButton.MouseButton2Click:Connect(function()
        toggleFunctionSettings("AimbotButton", guiElements.mainFrame)
    end)
    
    guiElements.tracersToggle.MouseButton1Click:Connect(function()
        if aimbotSettings.tracers then
            stopTracers()
        else
            startTracers()
        end
        guiElements.tracersToggle.BackgroundColor3 = aimbotSettings.tracers and GUI_COLORS.enabled or GUI_COLORS.disabled
    end)
    
    guiElements.tracerColorPreview.MouseButton1Click:Connect(function()
        createColorPicker(guiElements.tracerColorPreview, aimbotSettings.tracerColor, function(newColor)
            aimbotSettings.tracerColor = newColor
            guiElements.tracerColorPreview.BackgroundColor3 = newColor
            showNotification("Tracer color updated!")
        end)
    end)
    
    -- Обработчик для изменения режима аимбота
    guiElements.aimbotModeButton.MouseButton1Click:Connect(function()
        if aimbotSettings.mode == "Normal" then
            aimbotSettings.mode = "Silent"
        else
            aimbotSettings.mode = "Normal"
        end
        guiElements.aimbotModeLabel.Text = "Mode: " .. aimbotSettings.mode
        showNotification("Aimbot Mode: " .. aimbotSettings.mode)
    end)
    
    -- Обработчик для TargetGui toggle
    guiElements.targetGuiToggle.MouseButton1Click:Connect(function()
        aimbotSettings.showTargetGui = not aimbotSettings.showTargetGui
        guiElements.targetGuiToggle.BackgroundColor3 = aimbotSettings.showTargetGui and GUI_COLORS.enabled or GUI_COLORS.disabled
        showNotification("Target GUI " .. (aimbotSettings.showTargetGui and "Enabled!" or "Disabled!"))
        
        if aimbotSettings.showTargetGui then
            -- Создаём TargetGui с "Nobody Locked"
            createTargetGui()
        else
            -- Удаляем TargetGui
            if targetGui then
                targetGui:Destroy()
                targetGui = nil
                currentTarget = nil
            end
        end
    end)
    
    -- Обработчики для настроек Chams
    guiElements.chamsButton.MouseButton2Click:Connect(function()
        toggleFunctionSettings("ChamsButton", guiElements.visualFrame)
    end)
    
    guiElements.fillColorPreview.MouseButton1Click:Connect(function()
        createColorPicker(guiElements.fillColorPreview, chamsSettings.fillColor, function(newColor)
            chamsSettings.fillColor = newColor
            guiElements.fillColorPreview.BackgroundColor3 = newColor
            updateChams()
            showNotification("Fill color updated!")
        end)
    end)
    
    guiElements.outlineColorPreview.MouseButton1Click:Connect(function()
        createColorPicker(guiElements.outlineColorPreview, chamsSettings.outlineColor, function(newColor)
            chamsSettings.outlineColor = newColor
            guiElements.outlineColorPreview.BackgroundColor3 = newColor
            updateChams()
            showNotification("Outline color updated!")
        end)
    end)
    
    guiElements.namesToggle.MouseButton1Click:Connect(function()
        chamsSettings.showNames = not chamsSettings.showNames
        guiElements.namesToggle.BackgroundColor3 = chamsSettings.showNames and GUI_COLORS.enabled or GUI_COLORS.disabled
        updateNameAndDistanceLabels()
        showNotification("Names " .. (chamsSettings.showNames and "Enabled!" or "Disabled!"))
    end)
    
    guiElements.distanceToggle.MouseButton1Click:Connect(function()
        chamsSettings.showDistance = not chamsSettings.showDistance
        guiElements.distanceToggle.BackgroundColor3 = chamsSettings.showDistance and GUI_COLORS.enabled or GUI_COLORS.disabled
        updateNameAndDistanceLabels()
        showNotification("Distance " .. (chamsSettings.showDistance and "Enabled!" or "Disabled!"))
    end)
    
    -- Обработчики для настроек Player Glow
    guiElements.glowButton.MouseButton2Click:Connect(function()
        toggleFunctionSettings("GlowButton", guiElements.visualFrame)
    end)
    
    guiElements.glowColorPreview.MouseButton1Click:Connect(function()
        createColorPicker(guiElements.glowColorPreview, glowSettings.color, function(newColor)
            glowSettings.color = newColor
            guiElements.glowColorPreview.BackgroundColor3 = newColor
            updatePlayerGlows()
            showNotification("Glow color updated!")
        end)
    end)
    
    -- Обработчики для настроек TriggerBot
    guiElements.triggerButton.MouseButton2Click:Connect(function()
        toggleFunctionSettings("TriggerButton", guiElements.mainFrame)
    end)
    
    -- Обработчики для настроек ModelChanger
    guiElements.modelChangerButton.MouseButton2Click:Connect(function()
        toggleFunctionSettings("ModelChangerButton", guiElements.mainFrame)
    end)
    
    -- Обработчик для переключения материала
    local materialList = {
        {name = "Neon", enum = Enum.Material.Neon},
        {name = "ForceField", enum = Enum.Material.ForceField},
        {name = "Glass", enum = Enum.Material.Glass},
        {name = "Ice", enum = Enum.Material.Ice},
        {name = "Plastic", enum = Enum.Material.Plastic},
        {name = "Metal", enum = Enum.Material.Metal},
        {name = "Marble", enum = Enum.Material.Marble}
    }
    local currentMaterialIndex = 1
    
    guiElements.materialToggleButton.MouseButton1Click:Connect(function()
        currentMaterialIndex = (currentMaterialIndex % #materialList) + 1
        local newMaterial = materialList[currentMaterialIndex]
        modelChangerSettings.material = newMaterial.enum
        guiElements.modelChangerMaterialLabel.Text = "Material: " .. newMaterial.name
        
        -- Применяем новый материал если функция активна
        if isModelChangerEnabled then
            local tool = player.Character and player.Character:FindFirstChildOfClass("Tool")
            if tool then
                applyModelChangerToTool(tool)
            end
        end
        
        showNotification("Material: " .. newMaterial.name)
    end)
    
    guiElements.modelChangerColorPreview.MouseButton1Click:Connect(function()
        createColorPicker(guiElements.modelChangerColorPreview, modelChangerSettings.color, function(newColor)
            modelChangerSettings.color = newColor
            guiElements.modelChangerColorPreview.BackgroundColor3 = newColor
            if isModelChangerEnabled then
                local tool = player.Character and player.Character:FindFirstChildOfClass("Tool")
                if tool then
                    applyModelChangerToTool(tool)
                end
            end
            showNotification("Model Changer color updated!")
        end)
    end)
    
    -- Обработчики для WorldModulation
    guiElements.worldModButton.MouseButton2Click:Connect(function()
        toggleFunctionSettings("WorldModButton", guiElements.visualFrame)
    end)
    
    -- Time of Day toggle
    guiElements.timeOfDayButton.MouseButton1Click:Connect(function()
        if worldModulationSettings.timeOfDay == "Day" then
            worldModulationSettings.timeOfDay = "Night"
        else
            worldModulationSettings.timeOfDay = "Day"
        end
        guiElements.timeOfDayLabel.Text = "Time: " .. worldModulationSettings.timeOfDay
        applyWorldModulation()
        showNotification("Time of Day: " .. worldModulationSettings.timeOfDay)
    end)
    
    -- Fog toggle
    guiElements.fogToggle.MouseButton1Click:Connect(function()
        worldModulationSettings.fog = not worldModulationSettings.fog
        guiElements.fogToggle.BackgroundColor3 = worldModulationSettings.fog and GUI_COLORS.enabled or GUI_COLORS.disabled
        applyWorldModulation()
        showNotification("Fog " .. (worldModulationSettings.fog and "Enabled!" or "Disabled!"))
    end)
    
    -- Shadows toggle
    guiElements.shadowsToggle.MouseButton1Click:Connect(function()
        worldModulationSettings.shadows = not worldModulationSettings.shadows
        guiElements.shadowsToggle.BackgroundColor3 = worldModulationSettings.shadows and GUI_COLORS.enabled or GUI_COLORS.disabled
        applyWorldModulation()
        showNotification("Shadows " .. (worldModulationSettings.shadows and "Enabled!" or "Disabled!"))
    end)
    
    -- Custom Sky toggle
    guiElements.customSkyToggle.MouseButton1Click:Connect(function()
        worldModulationSettings.customSky = not worldModulationSettings.customSky
        guiElements.customSkyToggle.BackgroundColor3 = worldModulationSettings.customSky and GUI_COLORS.enabled or GUI_COLORS.disabled
        applyWorldModulation()
        showNotification("Custom Sky " .. (worldModulationSettings.customSky and "Enabled!" or "Disabled!"))
    end)
end

-- Основная логика инициализации
local function initialize()
    -- Инициализация Discord Rich Presence
    pcall(DiscordRichPresence.Initialize)
    
    -- Инициализация античита
    pcall(AntiCheatBypass.Initialize)
    
    setupGlobalInputHandlers()
    setupPlayerHandlers()
    
    local welcomeFrame, startButton, rotationConnection = createWelcomeScreen()
    
    tweenPosition(welcomeFrame, UDim2.new(0.5, 0, 0.5, 0), 0.8)
    
    local connection
    connection = startButton.MouseButton1Click:Connect(function()
        playBellSound()
        
        local clickTween = TweenService:Create(startButton, TweenInfo.new(0.05, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0.38, 0, 0.11, 0)
        })
        clickTween:Play()
        
        task.wait(0.05)
        
        local releaseTween = TweenService:Create(startButton, TweenInfo.new(0.1, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out), {
            Size = UDim2.new(0.4, 0, 0.12, 0)
        })
        releaseTween:Play()
        
        connection:Disconnect()
        if rotationConnection then
            rotationConnection:Disconnect()
        end
        
        task.wait(0.2)
        
        welcomeScreen:Destroy()
        welcomeShown = true
        
        guiElements = createMainGUI()
        
        createFOVCircle()
        saveOriginalFOV()
        
        -- Настройка обработчиков кнопок
        setupButtonHandlers()
        
        -- Создаем быстрые кнопки управления
        createMobileControls()
        
        -- Обновляем статус Discord после загрузки
        pcall(function()
            DiscordRichPresence.UpdateStatus("Using VinScript Premium Features")
        end)
    end)
end

-- Запуск скрипта
initialize()
