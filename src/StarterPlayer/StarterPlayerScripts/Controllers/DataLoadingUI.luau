--[[
	DataLoadingUI.luau
	
	Client-side UI controller untuk data loading & save feedback.
	
	FEATURES:
	- Loading screen saat data di-load
	- Save warning UI (friendly untuk anak-anak)
	- Error messages yang mudah dimengerti
	- Progress indicators
	
	DESIGN PHILOSOPHY:
	- Child-friendly language (Indonesia)
	- Visual feedback (icons, colors, animations)
	- Non-intrusive tapi clear
	- No scary technical jargon
	
	Author: Bisa Bahasa Studio
	Created: 2025-01-03
	Version: 1.0.0
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- RemoteEvents
local RemoteEventsFolder = ReplicatedStorage:WaitForChild("RemoteEvents")
local DataLoadedEvent = RemoteEventsFolder:WaitForChild("DataLoaded")
local SaveWarningEvent = RemoteEventsFolder:WaitForChild("SaveWarning")

local DataLoadingUI = {}

-- ═══════════════════════════════════════════════════════════════════════════
-- CONFIGURATION
-- ═══════════════════════════════════════════════════════════════════════════

local CONFIG = {
	-- Colors (child-friendly, warm colors)
	COLOR_SUCCESS = Color3.fromRGB(100, 200, 100), -- Green
	COLOR_WARNING = Color3.fromRGB(255, 200, 50),  -- Yellow
	COLOR_ERROR = Color3.fromRGB(255, 100, 100),   -- Red
	COLOR_INFO = Color3.fromRGB(100, 150, 255),    -- Blue
	
	-- Animation settings
	FADE_IN_TIME = 0.3,
	FADE_OUT_TIME = 0.5,
	SLIDE_TIME = 0.4,
	
	-- Warning display time
	WARNING_DISPLAY_TIME = 5, -- seconds
}

-- ═══════════════════════════════════════════════════════════════════════════
-- UI REFERENCES (will be created)
-- ═══════════════════════════════════════════════════════════════════════════

local LoadingScreen = nil
local SaveWarningFrame = nil

-- ═══════════════════════════════════════════════════════════════════════════
-- LOADING SCREEN UI
-- ═══════════════════════════════════════════════════════════════════════════

--[[
	Create loading screen UI
]]
function DataLoadingUI.CreateLoadingScreen()
	-- Create ScreenGui
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "DataLoadingScreen"
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = true
	screenGui.DisplayOrder = 100 -- High priority
	screenGui.Parent = playerGui
	
	-- Background (full screen, dark overlay)
	local background = Instance.new("Frame")
	background.Name = "Background"
	background.Size = UDim2.new(1, 0, 1, 0)
	background.Position = UDim2.new(0, 0, 0, 0)
	background.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
	background.BorderSizePixel = 0
	background.Parent = screenGui
	
	-- Content frame (centered)
	local contentFrame = Instance.new("Frame")
	contentFrame.Name = "ContentFrame"
	contentFrame.Size = UDim2.new(0, 400, 0, 300)
	contentFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
	contentFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	contentFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
	contentFrame.BorderSizePixel = 0
	contentFrame.Parent = background
	
	-- Corner rounding
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 20)
	corner.Parent = contentFrame
	
	-- Title
	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Size = UDim2.new(1, -40, 0, 50)
	title.Position = UDim2.new(0, 20, 0, 20)
	title.BackgroundTransparency = 1
	title.Font = Enum.Font.GothamBold
	title.TextSize = 28
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.Text = "✨ Memuat Data..."
	title.TextXAlignment = Enum.TextXAlignment.Center
	title.Parent = contentFrame
	
	-- Status text
	local statusText = Instance.new("TextLabel")
	statusText.Name = "StatusText"
	statusText.Size = UDim2.new(1, -40, 0, 60)
	statusText.Position = UDim2.new(0, 20, 0, 80)
	statusText.BackgroundTransparency = 1
	statusText.Font = Enum.Font.Gotham
	statusText.TextSize = 18
	statusText.TextColor3 = Color3.fromRGB(200, 200, 220)
	statusText.Text = "Tunggu sebentar ya...\nKami sedang menyiapkan petualanganmu!"
	statusText.TextWrapped = true
	statusText.TextYAlignment = Enum.TextYAlignment.Top
	statusText.Parent = contentFrame
	
	-- Loading spinner (rotating circle)
	local spinner = Instance.new("ImageLabel")
	spinner.Name = "Spinner"
	spinner.Size = UDim2.new(0, 80, 0, 80)
	spinner.Position = UDim2.new(0.5, 0, 0, 180)
	spinner.AnchorPoint = Vector2.new(0.5, 0.5)
	spinner.BackgroundTransparency = 1
	spinner.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png" -- Replace with actual spinner
	spinner.Parent = contentFrame
	
	-- Animate spinner
	local spinnerTween = TweenService:Create(
		spinner,
		TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1),
		{Rotation = 360}
	)
	spinnerTween:Play()
	
	-- Progress bar
	local progressBarBG = Instance.new("Frame")
	progressBarBG.Name = "ProgressBarBG"
	progressBarBG.Size = UDim2.new(0.8, 0, 0, 8)
	progressBarBG.Position = UDim2.new(0.5, 0, 1, -40)
	progressBarBG.AnchorPoint = Vector2.new(0.5, 0.5)
	progressBarBG.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
	progressBarBG.BorderSizePixel = 0
	progressBarBG.Parent = contentFrame
	
	local progressBarCorner = Instance.new("UICorner")
	progressBarCorner.CornerRadius = UDim.new(1, 0)
	progressBarCorner.Parent = progressBarBG
	
	local progressBar = Instance.new("Frame")
	progressBar.Name = "ProgressBar"
	progressBar.Size = UDim2.new(0, 0, 1, 0)
	progressBar.BackgroundColor3 = CONFIG.COLOR_INFO
	progressBar.BorderSizePixel = 0
	progressBar.Parent = progressBarBG
	
	local progressCorner = Instance.new("UICorner")
	progressCorner.CornerRadius = UDim.new(1, 0)
	progressCorner.Parent = progressBar
	
	-- Animate progress bar (indeterminate)
	local function animateProgressBar()
		while screenGui.Parent do
			-- Expand
			TweenService:Create(
				progressBar,
				TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
				{Size = UDim2.new(0.7, 0, 1, 0)}
			):Play()
			
			task.wait(1.5)
			
			-- Contract
			TweenService:Create(
				progressBar,
				TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
				{Size = UDim2.new(0.1, 0, 1, 0)}
			):Play()
			
			task.wait(1.5)
		end
	end
	
	task.spawn(animateProgressBar)
	
	LoadingScreen = screenGui
	
	return screenGui
end

--[[
	Update loading screen status
]]
function DataLoadingUI.UpdateLoadingStatus(status, message)
	if not LoadingScreen then return end
	
	local contentFrame = LoadingScreen:FindFirstChild("Background"):FindFirstChild("ContentFrame")
	local statusText = contentFrame:FindFirstChild("StatusText")
	
	if status == "Loading" then
		statusText.Text = message or "Tunggu sebentar ya...\nKami sedang menyiapkan petualanganmu!"
		statusText.TextColor3 = CONFIG.COLOR_INFO
		
	elseif status == "Success" then
		statusText.Text = "✅ Berhasil!\nSelamat datang kembali!"
		statusText.TextColor3 = CONFIG.COLOR_SUCCESS
		
		-- Hide loading screen after delay
		task.wait(1)
		DataLoadingUI.HideLoadingScreen()
		
	elseif status == "Error" then
		statusText.Text = message or "❌ Terjadi kesalahan...\nMohon coba lagi!"
		statusText.TextColor3 = CONFIG.COLOR_ERROR
	end
end

--[[
	Hide loading screen with animation
]]
function DataLoadingUI.HideLoadingScreen()
	if not LoadingScreen then return end
	
	local background = LoadingScreen:FindFirstChild("Background")
	
	-- Fade out
	TweenService:Create(
		background,
		TweenInfo.new(CONFIG.FADE_OUT_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{BackgroundTransparency = 1}
	):Play()
	
	-- Fade out all children
	for _, child in ipairs(background:GetDescendants()) do
		if child:IsA("GuiObject") then
			TweenService:Create(
				child,
				TweenInfo.new(CONFIG.FADE_OUT_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					BackgroundTransparency = 1,
					TextTransparency = 1,
					ImageTransparency = 1
				}
			):Play()
		end
	end
	
	-- Destroy after animation
	task.wait(CONFIG.FADE_OUT_TIME + 0.1)
	LoadingScreen:Destroy()
	LoadingScreen = nil
end

-- ═══════════════════════════════════════════════════════════════════════════
-- SAVE WARNING UI
-- ═══════════════════════════════════════════════════════════════════════════

--[[
	Create save warning UI (top banner)
]]
function DataLoadingUI.CreateSaveWarning()
	-- Create ScreenGui if not exists
	local screenGui = playerGui:FindFirstChild("SaveWarningUI")
	
	if not screenGui then
		screenGui = Instance.new("ScreenGui")
		screenGui.Name = "SaveWarningUI"
		screenGui.ResetOnSpawn = false
		screenGui.DisplayOrder = 99
		screenGui.Parent = playerGui
	end
	
	-- Warning banner (top of screen)
	local banner = Instance.new("Frame")
	banner.Name = "WarningBanner"
	banner.Size = UDim2.new(0, 600, 0, 100)
	banner.Position = UDim2.new(0.5, 0, 0, -110) -- Start off-screen
	banner.AnchorPoint = Vector2.new(0.5, 0)
	banner.BackgroundColor3 = CONFIG.COLOR_WARNING
	banner.BorderSizePixel = 0
	banner.Parent = screenGui
	
	-- Corner
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 15)
	corner.Parent = banner
	
	-- Drop shadow
	local shadow = Instance.new("ImageLabel")
	shadow.Name = "Shadow"
	shadow.Size = UDim2.new(1, 20, 1, 20)
	shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
	shadow.AnchorPoint = Vector2.new(0.5, 0.5)
	shadow.BackgroundTransparency = 1
	shadow.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png" -- Replace with shadow
	shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
	shadow.ImageTransparency = 0.7
	shadow.ZIndex = -1
	shadow.Parent = banner
	
	-- Icon (warning symbol)
	local icon = Instance.new("TextLabel")
	icon.Name = "Icon"
	icon.Size = UDim2.new(0, 60, 0, 60)
	icon.Position = UDim2.new(0, 20, 0.5, 0)
	icon.AnchorPoint = Vector2.new(0, 0.5)
	icon.BackgroundTransparency = 1
	icon.Font = Enum.Font.GothamBold
	icon.TextSize = 40
	icon.Text = "⚠️"
	icon.Parent = banner
	
	-- Message text
	local messageText = Instance.new("TextLabel")
	messageText.Name = "MessageText"
	messageText.Size = UDim2.new(1, -100, 0, 40)
	messageText.Position = UDim2.new(0, 90, 0, 15)
	messageText.BackgroundTransparency = 1
	messageText.Font = Enum.Font.GothamBold
	messageText.TextSize = 18
	messageText.TextColor3 = Color3.fromRGB(40, 40, 40)
	messageText.Text = "Data belum tersimpan!"
	messageText.TextXAlignment = Enum.TextXAlignment.Left
	messageText.TextWrapped = true
	messageText.Parent = banner
	
	-- Subtitle
	local subtitle = Instance.new("TextLabel")
	subtitle.Name = "Subtitle"
	subtitle.Size = UDim2.new(1, -100, 0, 30)
	subtitle.Position = UDim2.new(0, 90, 0, 55)
	subtitle.BackgroundTransparency = 1
	subtitle.Font = Enum.Font.Gotham
	subtitle.TextSize = 14
	subtitle.TextColor3 = Color3.fromRGB(60, 60, 60)
	subtitle.Text = "Jangan keluar dulu ya! Tunggu sebentar..."
	subtitle.TextXAlignment = Enum.TextXAlignment.Left
	subtitle.TextWrapped = true
	subtitle.Parent = banner
	
	SaveWarningFrame = banner
	
	return banner
end

--[[
	Show save warning with message
]]
function DataLoadingUI.ShowSaveWarning(level, message, canRetry)
	-- Create if doesn't exist
	if not SaveWarningFrame then
		DataLoadingUI.CreateSaveWarning()
	end
	
	local banner = SaveWarningFrame
	local messageText = banner:FindFirstChild("MessageText")
	local subtitle = banner:FindFirstChild("Subtitle")
	local icon = banner:FindFirstChild("Icon")
	
	-- Update colors based on severity
	if level == "Critical" then
		banner.BackgroundColor3 = CONFIG.COLOR_ERROR
		icon.Text = "🚨"
		messageText.Text = "PENTING: Data belum tersimpan!"
		subtitle.Text = message or "Jangan keluar! Kami sedang menyimpan data kamu..."
		
	elseif level == "Warning" then
		banner.BackgroundColor3 = CONFIG.COLOR_WARNING
		icon.Text = "⚠️"
		messageText.Text = "Peringatan: Menyimpan data..."
		subtitle.Text = message or "Tunggu sebentar, data sedang disimpan..."
		
	else -- Info
		banner.BackgroundColor3 = CONFIG.COLOR_INFO
		icon.Text = "ℹ️"
		messageText.Text = "Info: Menyimpan data..."
		subtitle.Text = message or "Kami sedang menyimpan progress kamu..."
	end
	
	-- Slide in from top
	TweenService:Create(
		banner,
		TweenInfo.new(CONFIG.SLIDE_TIME, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{Position = UDim2.new(0.5, 0, 0, 20)}
	):Play()
	
	-- Auto-hide after delay (unless critical)
	if level ~= "Critical" then
		task.wait(CONFIG.WARNING_DISPLAY_TIME)
		DataLoadingUI.HideSaveWarning()
	end
end

--[[
	Hide save warning
]]
function DataLoadingUI.HideSaveWarning()
	if not SaveWarningFrame then return end
	
	-- Slide out to top
	local slideTween = TweenService:Create(
		SaveWarningFrame,
		TweenInfo.new(CONFIG.SLIDE_TIME, Enum.EasingStyle.Back, Enum.EasingDirection.In),
		{Position = UDim2.new(0.5, 0, 0, -110)}
	)
	
	slideTween:Play()
	slideTween.Completed:Connect(function()
		if SaveWarningFrame then
			SaveWarningFrame:Destroy()
			SaveWarningFrame = nil
		end
	end)
end

--[[
	Show success notification (quick toast)
]]
function DataLoadingUI.ShowSuccessToast(message)
	local screenGui = playerGui:FindFirstChild("ToastNotifications")
	
	if not screenGui then
		screenGui = Instance.new("ScreenGui")
		screenGui.Name = "ToastNotifications"
		screenGui.ResetOnSpawn = false
		screenGui.DisplayOrder = 98
		screenGui.Parent = playerGui
	end
	
	-- Toast notification
	local toast = Instance.new("Frame")
	toast.Name = "Toast"
	toast.Size = UDim2.new(0, 300, 0, 60)
	toast.Position = UDim2.new(0.5, 0, 1, 20) -- Start below screen
	toast.AnchorPoint = Vector2.new(0.5, 1)
	toast.BackgroundColor3 = CONFIG.COLOR_SUCCESS
	toast.BorderSizePixel = 0
	toast.Parent = screenGui
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = toast
	
	-- Icon
	local icon = Instance.new("TextLabel")
	icon.Size = UDim2.new(0, 40, 0, 40)
	icon.Position = UDim2.new(0, 10, 0.5, 0)
	icon.AnchorPoint = Vector2.new(0, 0.5)
	icon.BackgroundTransparency = 1
	icon.Font = Enum.Font.GothamBold
	icon.TextSize = 28
	icon.Text = "✅"
	icon.Parent = toast
	
	-- Message
	local text = Instance.new("TextLabel")
	text.Size = UDim2.new(1, -60, 1, 0)
	text.Position = UDim2.new(0, 55, 0, 0)
	text.BackgroundTransparency = 1
	text.Font = Enum.Font.GothamBold
	text.TextSize = 16
	text.TextColor3 = Color3.fromRGB(255, 255, 255)
	text.Text = message or "✅ Data tersimpan!"
	text.TextXAlignment = Enum.TextXAlignment.Left
	text.TextWrapped = true
	text.Parent = toast
	
	-- Slide up
	TweenService:Create(
		toast,
		TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{Position = UDim2.new(0.5, 0, 1, -80)}
	):Play()
	
	-- Auto-hide
	task.wait(3)
	
	TweenService:Create(
		toast,
		TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
		{Position = UDim2.new(0.5, 0, 1, 20)}
	):Play()
	
	task.wait(0.4)
	toast:Destroy()
end

-- ═══════════════════════════════════════════════════════════════════════════
-- EVENT HANDLERS
-- ═══════════════════════════════════════════════════════════════════════════

--[[
	Handle DataLoaded event from server
]]
DataLoadedEvent.OnClientEvent:Connect(function(data)
	local status = data.Status
	local message = data.Message
	
	if status == "Loading" then
		-- Show loading screen
		if not LoadingScreen then
			DataLoadingUI.CreateLoadingScreen()
		end
		
		DataLoadingUI.UpdateLoadingStatus("Loading", message)
		
	elseif status == "Success" then
		-- Data loaded successfully
		DataLoadingUI.UpdateLoadingStatus("Success")
		
	elseif status == "Error" then
		-- Error loading data
		DataLoadingUI.UpdateLoadingStatus("Error", message)
	end
end)

--[[
	Handle SaveWarning event from server
]]
SaveWarningEvent.OnClientEvent:Connect(function(data)
	local level = data.Level or "Info"
	local message = data.Message
	local canRetry = data.CanRetry
	
	DataLoadingUI.ShowSaveWarning(level, message, canRetry)
end)

-- ═══════════════════════════════════════════════════════════════════════════
-- INITIALIZATION
-- ═══════════════════════════════════════════════════════════════════════════

function DataLoadingUI.Initialize()
	print("[DataLoadingUI] Client UI controller initialized")
	
	-- Show loading screen immediately on join
	DataLoadingUI.CreateLoadingScreen()
	
	-- Hide core GUI during loading
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
	
	-- Wait for data to load, then re-enable
	DataLoadedEvent.OnClientEvent:Connect(function(data)
		if data.Status == "Success" then
			task.wait(1)
			StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, true)
		end
	end)
end

-- Auto-initialize
DataLoadingUI.Initialize()

-- ═══════════════════════════════════════════════════════════════════════════
-- EXPORT
-- ═══════════════════════════════════════════════════════════════════════════

return DataLoadingUI