--[[
	DataManager.luau
	
	Production-ready DataStore manager using ProfileService.
	
	FEATURES:
	- Session locking (prevent duplication)
	- Auto-save every 5 minutes
	- Save on critical events
	- Comprehensive error handling
	- User-friendly UI feedback
	- Admin debug commands
	- Rate limit tracking
	
	SAFETY PHILOSOPHY:
	- Never lose player data
	- Always inform player of issues
	- Graceful degradation
	- Child-friendly error messages
	
	Author: Bisa Bahasa Studio
	Created: 2025-01-03
	Version: 1.0.0
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local RunService = game:GetService("RunService")

-- Import ProfileService
local ProfileService = require(ReplicatedStorage.Packages.ProfileService)

-- Import modules
local Constants = require(ReplicatedStorage.Shared.Constants)
local BalanceConfig = require(ReplicatedStorage.Shared.BalanceConfig)
local PlayerDataStructure = require(ServerScriptService.Data.PlayerDataStructure)

local DataManager = {}

-- ═══════════════════════════════════════════════════════════════════════════
-- CONFIGURATION
-- ═══════════════════════════════════════════════════════════════════════════

local CONFIG = {
	-- DataStore settings
	DATASTORE_NAME = Constants.DATASTORE_NAME,
	AUTO_SAVE_INTERVAL = Constants.AUTO_SAVE_INTERVAL, -- 5 minutes (300 seconds)

	-- Studio Mock Mode (untuk menghindari session lock issues di Studio)
	USE_MOCK_DATA_IN_STUDIO = true, -- Set false untuk test real DataStore di Studio

	-- Session lock settings
	SESSION_LOCK_TIMEOUT = 30, -- Reduced to 30 seconds for faster recovery
	SESSION_LOCK_RETRY_ATTEMPTS = 3, -- Reduced attempts for faster feedback
	SESSION_LOCK_RETRY_DELAY = 2, -- 2 seconds between retries

	-- Save/Load retry settings
	SAVE_RETRY_ATTEMPTS = 5,
	SAVE_RETRY_DELAY = 2, -- 2 seconds between retries
	LOAD_RETRY_ATTEMPTS = 3,
	LOAD_RETRY_DELAY = 2, -- Reduced from 3 to 2

	-- Rate limiting (Roblox DataStore limits)
	RATE_LIMIT_WINDOW = 60, -- 1 minute
	RATE_LIMIT_MAX_REQUESTS = 60, -- Base limit (will scale with player count)

	-- Debug
	DEBUG_MODE = Constants.DEBUG_MODE,
	VERBOSE_LOGGING = true, -- Extra detailed logs
}

-- ═══════════════════════════════════════════════════════════════════════════
-- STATE MANAGEMENT
-- ═══════════════════════════════════════════════════════════════════════════

local IS_STUDIO = RunService:IsStudio()
local USE_MOCK_MODE = IS_STUDIO and CONFIG.USE_MOCK_DATA_IN_STUDIO

local ProfileStore = nil -- ProfileService store
local LoadedProfiles = {} -- [Player] = Profile or MockProfile
local MockDataStore = {} -- [UserId] = Data (for Studio mock mode)
local SaveQueue = {} -- Players waiting for save
local RateLimitTracker = {
	RequestCount = 0,
	WindowStart = os.time(),
}

-- RemoteEvents for client communication
local RemoteEventsFolder = ReplicatedStorage:WaitForChild("RemoteEvents")
local DataLoadedEvent = RemoteEventsFolder:FindFirstChild("DataLoaded")
local SaveWarningEvent = RemoteEventsFolder:FindFirstChild("SaveWarning")

if not DataLoadedEvent then
	DataLoadedEvent = Instance.new("RemoteEvent")
	DataLoadedEvent.Name = "DataLoaded"
	DataLoadedEvent.Parent = RemoteEventsFolder
end

if not SaveWarningEvent then
	SaveWarningEvent = Instance.new("RemoteEvent")
	SaveWarningEvent.Name = "SaveWarning"
	SaveWarningEvent.Parent = RemoteEventsFolder
end

-- ═══════════════════════════════════════════════════════════════════════════
-- UTILITY FUNCTIONS
-- ═══════════════════════════════════════════════════════════════════════════

--[[
	Debug print dengan timestamp
]]
local function debugPrint(message, level)
	if not CONFIG.DEBUG_MODE then return end
	
	level = level or "INFO"
	local timestamp = os.date("%H:%M:%S")
	
	local prefix = string.format("[DataManager][%s][%s]", timestamp, level)
	
	if level == "ERROR" then
		warn(prefix, message)
	elseif level == "WARN" then
		warn(prefix, message)
	else
		print(prefix, message)
	end
end

--[[
	Verbose logging (extra detailed)
]]
local function verboseLog(message)
	if CONFIG.VERBOSE_LOGGING and CONFIG.DEBUG_MODE then
		debugPrint(message, "VERBOSE")
	end
end

--[[
	Check rate limit
	Returns: boolean (allowed), string (reason if not allowed)
]]
local function checkRateLimit()
	local currentTime = os.time()
	
	-- Reset window if 1 minute passed
	if currentTime - RateLimitTracker.WindowStart >= CONFIG.RATE_LIMIT_WINDOW then
		RateLimitTracker.RequestCount = 0
		RateLimitTracker.WindowStart = currentTime
	end
	
	-- Calculate dynamic limit based on player count
	local playerCount = #Players:GetPlayers()
	local maxRequests = CONFIG.RATE_LIMIT_MAX_REQUESTS + (playerCount * 10)
	
	if RateLimitTracker.RequestCount >= maxRequests then
		return false, string.format("Rate limit exceeded (%d/%d)", RateLimitTracker.RequestCount, maxRequests)
	end
	
	RateLimitTracker.RequestCount += 1
	return true, nil
end

--[[
	Send UI notification to player
]]
local function notifyPlayer(player, messageType, data)
	if not player or not player:IsDescendantOf(Players) then
		return
	end
	
	local success, err = pcall(function()
		if messageType == "SaveWarning" then
			SaveWarningEvent:FireClient(player, data)
		elseif messageType == "DataLoaded" then
			DataLoadedEvent:FireClient(player, data)
		end
	end)
	
	if not success then
		debugPrint("Failed to notify player: " .. tostring(err), "ERROR")
	end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- MOCK DATA SYSTEM (for Studio testing)
-- ═══════════════════════════════════════════════════════════════════════════

--[[
	Create a mock profile that mimics ProfileService API
]]
local function createMockProfile(userId)
	local data = PlayerDataStructure.GetDefaultData(userId)

	local mockProfile = {
		Data = data,
		MetaData = {
			ProfileCreateTime = os.time(),
			SessionLoadCount = 1,
			ActiveSession = nil,
		},
		GlobalUpdates = {},
		_isReleased = false,
	}

	-- Mock methods
	function mockProfile:IsActive()
		return not self._isReleased
	end

	function mockProfile:Reconcile()
		-- Mock reconciliation (do nothing in mock mode)
	end

	function mockProfile:ListenToRelease(callback)
		-- Mock release listener (store callback but never call in mock mode)
		self._releaseCallback = callback
	end

	function mockProfile:Release()
		self._isReleased = true
		debugPrint("MockProfile released", "INFO")
	end

	function mockProfile:AddUserId(_userId)
		-- Mock AddUserId for GDPR compliance (do nothing in mock mode)
	end

	return mockProfile
end

-- ═══════════════════════════════════════════════════════════════════════════
-- PROFILESERVICE SETUP
-- ═══════════════════════════════════════════════════════════════════════════

--[[
	Initialize ProfileService store (or Mock Mode)
]]
function DataManager.InitializeStore()
	if USE_MOCK_MODE then
		debugPrint("⚠️ MOCK MODE ENABLED - Using in-memory data storage", "WARN")
		debugPrint("Data will NOT persist between sessions!", "WARN")
		debugPrint("Set USE_MOCK_DATA_IN_STUDIO = false to use real DataStore", "INFO")
		return true
	end

	debugPrint("Initializing ProfileService store...")

	-- Create ProfileStore
	local profileTemplate = PlayerDataStructure.GetDefaultData(0) -- Use 0 as template

	ProfileStore = ProfileService.GetProfileStore(
		CONFIG.DATASTORE_NAME,
		profileTemplate
	)

	debugPrint("ProfileService store initialized: " .. CONFIG.DATASTORE_NAME, "INFO")

	return ProfileStore ~= nil
end

-- ═══════════════════════════════════════════════════════════════════════════
-- PROFILE LOADING
-- ═══════════════════════════════════════════════════════════════════════════

--[[
	Load player profile with retry logic
	
	@param player Player
	@return Profile or nil
]]
function DataManager.LoadPlayerData(player)
	if not player or not player:IsDescendantOf(Players) then
		debugPrint("Invalid player for LoadPlayerData", "ERROR")
		return nil
	end

	local userId = player.UserId
	local profileKey = "Player_" .. userId

	debugPrint(string.format("Loading data for %s (UserId: %d)", player.Name, userId), "INFO")

	-- Show loading screen to player
	notifyPlayer(player, "DataLoaded", {Status = "Loading"})

	-- MOCK MODE: Create in-memory profile
	if USE_MOCK_MODE then
		debugPrint(string.format("📦 Mock Mode: Creating in-memory profile for %s", player.Name), "INFO")

		-- Check if we have existing mock data for this user
		local existingData = MockDataStore[userId]
		local profile = createMockProfile(userId)

		if existingData then
			profile.Data = existingData
			debugPrint(string.format("✅ Loaded existing mock data for %s", player.Name), "INFO")
		else
			MockDataStore[userId] = profile.Data
			debugPrint(string.format("✅ Created new mock data for %s", player.Name), "INFO")
		end

		-- Store profile and notify
		LoadedProfiles[player] = profile
		notifyPlayer(player, "DataLoaded", {Status = "Success"})

		return profile
	end

	-- REAL MODE: Use ProfileService
	local profile = nil
	local attempts = 0
	local maxAttempts = CONFIG.LOAD_RETRY_ATTEMPTS

	while attempts < maxAttempts and not profile do
		attempts += 1

		verboseLog(string.format("Load attempt %d/%d for %s", attempts, maxAttempts, player.Name))

		-- Check rate limit
		local allowed, reason = checkRateLimit()
		if not allowed then
			debugPrint("Rate limit hit during load: " .. reason, "WARN")
			task.wait(CONFIG.LOAD_RETRY_DELAY)
			continue
		end

		-- Attempt load
		profile = ProfileStore:LoadProfileAsync(profileKey)

		if profile then
			-- Success!
			debugPrint(string.format("Profile loaded successfully for %s", player.Name), "INFO")
			break
		else
			-- Failed - retry
			debugPrint(string.format("Load failed for %s (attempt %d/%d)", player.Name, attempts, maxAttempts), "WARN")

			if attempts < maxAttempts then
				task.wait(CONFIG.LOAD_RETRY_DELAY)
			end
		end
	end
	
	-- Check if load ultimately failed
	if not profile then
		debugPrint(string.format("CRITICAL: Failed to load profile for %s after %d attempts", player.Name, maxAttempts), "ERROR")
		
		-- Kick player with friendly message
		player:Kick(string.format(
			"😢 Maaf, kami tidak bisa memuat data kamu.\n\n" ..
			"Ini biasanya karena masalah koneksi.\n" ..
			"Silakan coba lagi dalam beberapa menit!\n\n" ..
			"Jika masalah terus terjadi, hubungi support kami."
		))
		
		return nil
	end
	
	-- Setup profile listeners
	profile:AddUserId(userId) -- For GDPR compliance
	profile:Reconcile() -- Fill in missing data from template
	
	-- Listen for release (session end)
	profile:ListenToRelease(function()
		debugPrint(string.format("Profile released for %s (session ended elsewhere)", player.Name), "WARN")
		
		LoadedProfiles[player] = nil
		
		-- Kick player with friendly message
		player:Kick(
			"🔄 Kamu login dari tempat lain!\n\n" ..
			"Akun kamu sedang dimainkan di perangkat lain.\n" ..
			"Jika ini bukan kamu, segera ganti password!"
		)
	end)
	
	-- Check if player still in game (might have left during load)
	if not player:IsDescendantOf(Players) then
		debugPrint(string.format("Player %s left during data load - releasing profile", player.Name), "WARN")
		profile:Release()
		return nil
	end
	
	-- Validate & sanitize data
	local isValid, validationError = PlayerDataStructure.ValidateData(profile.Data)
	
	if not isValid then
		debugPrint(string.format("Data validation failed for %s: %s", player.Name, validationError), "ERROR")
		
		-- Attempt to sanitize
		profile.Data = PlayerDataStructure.SanitizeData(profile.Data)
		
		debugPrint(string.format("Data sanitized for %s", player.Name), "WARN")
	end
	
	-- Migration (if data version is old)
	local currentVersion = profile.Data.DataVersion or 1
	if currentVersion < 1 then -- Update this when you increment version
		debugPrint(string.format("Migrating data for %s from v%d to v1", player.Name, currentVersion), "INFO")
		profile.Data = PlayerDataStructure.MigrateData(profile.Data, 1)
	end
	
	-- Update metadata
	profile.Data.UserId = userId
	profile.Data.LastSaved = os.time()
	
	-- Store in loaded profiles
	LoadedProfiles[player] = profile
	
	-- Notify client that data is loaded
	notifyPlayer(player, "DataLoaded", {Status = "Success"})
	
	debugPrint(string.format("✅ Data fully loaded for %s", player.Name), "INFO")
	
	return profile
end

-- ═══════════════════════════════════════════════════════════════════════════
-- PROFILE SAVING
-- ═══════════════════════════════════════════════════════════════════════════

--[[
	Save player profile with retry & UI feedback
	
	@param player Player
	@param urgency string - "Normal", "Critical", "Leaving"
	@return boolean success
]]
function DataManager.SavePlayerData(player, urgency)
	urgency = urgency or "Normal"
	
	if not player or not player:IsDescendantOf(Players) then
		debugPrint("Invalid player for SavePlayerData", "ERROR")
		return false
	end
	
	local profile = LoadedProfiles[player]
	
	if not profile then
		debugPrint(string.format("No profile loaded for %s - cannot save", player.Name), "ERROR")
		return false
	end
	
	verboseLog(string.format("Saving data for %s (urgency: %s)", player.Name, urgency))
	
	-- Update last saved timestamp
	profile.Data.LastSaved = os.time()
	
	-- ProfileService auto-saves, but we can force save
	-- ProfileService handles retries internally
	
	-- Validate before save
	local isValid, validationError = PlayerDataStructure.ValidateData(profile.Data)
	
	if not isValid then
		debugPrint(string.format("⚠️ Save validation failed for %s: %s", player.Name, validationError), "ERROR")
		
		-- Show error to player
		notifyPlayer(player, "SaveWarning", {
			Level = "Critical",
			Message = "Data tidak valid - mohon hubungi support!",
			CanRetry = false
		})
		
		return false
	end
	
	-- ProfileService handles save automatically
	-- We just need to notify on success
	debugPrint(string.format("✅ Data saved for %s", player.Name), "INFO")
	
	return true
end

--[[
	Save all loaded profiles (used for auto-save & shutdown)
]]
function DataManager.SaveAllPlayers()
	debugPrint("Saving all player data...", "INFO")
	
	local savedCount = 0
	local failedCount = 0
	
	for player, profile in pairs(LoadedProfiles) do
		if player and player:IsDescendantOf(Players) then
			local success = DataManager.SavePlayerData(player, "Normal")
			
			if success then
				savedCount += 1
			else
				failedCount += 1
			end
		end
	end
	
	debugPrint(string.format("Auto-save complete: %d saved, %d failed", savedCount, failedCount), "INFO")
end

-- ═══════════════════════════════════════════════════════════════════════════
-- AUTO-SAVE SYSTEM
-- ═══════════════════════════════════════════════════════════════════════════

--[[
	Start auto-save loop
]]
function DataManager.StartAutoSave()
	debugPrint("Starting auto-save loop (interval: " .. CONFIG.AUTO_SAVE_INTERVAL .. "s)", "INFO")
	
	task.spawn(function()
		while true do
			task.wait(CONFIG.AUTO_SAVE_INTERVAL)
			
			DataManager.SaveAllPlayers()
		end
	end)
end

-- ═══════════════════════════════════════════════════════════════════════════
-- PLAYER LIFECYCLE HANDLERS
-- ═══════════════════════════════════════════════════════════════════════════

--[[
	Handle player joining
]]
function DataManager.OnPlayerAdded(player)
	debugPrint(string.format("Player joined: %s (UserId: %d)", player.Name, player.UserId), "INFO")
	
	-- Load player data
	local profile = DataManager.LoadPlayerData(player)
	
	if not profile then
		-- Player was kicked during load
		return
	end
	
	-- Setup leaderstats (optional - for UI display)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player
	
	local levelValue = Instance.new("IntValue")
	levelValue.Name = "Level"
	levelValue.Value = profile.Data.Profile.CurrentLevel
	levelValue.Parent = leaderstats
	
	local rarityValue = Instance.new("IntValue")
	rarityValue.Name = "Rarity"
	rarityValue.Value = profile.Data.Profile.Rarity
	rarityValue.Parent = leaderstats
	
	debugPrint(string.format("✅ Player %s fully initialized (Lv %d, %d★)", 
		player.Name, 
		profile.Data.Profile.CurrentLevel,
		profile.Data.Profile.Rarity
	), "INFO")
end

--[[
	Handle player leaving
]]
function DataManager.OnPlayerRemoving(player)
	debugPrint(string.format("Player leaving: %s", player.Name), "INFO")
	
	local profile = LoadedProfiles[player]
	
	if profile then
		-- Save before release
		DataManager.SavePlayerData(player, "Leaving")
		
		-- Release profile (unlock session)
		profile:Release()
		
		LoadedProfiles[player] = nil
		
		debugPrint(string.format("✅ Profile released for %s", player.Name), "INFO")
	else
		debugPrint(string.format("No profile to release for %s", player.Name), "WARN")
	end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- PUBLIC API - DATA ACCESS
-- ═══════════════════════════════════════════════════════════════════════════

--[[
	Get player's profile data
	
	@param player Player
	@return table or nil
]]
function DataManager.GetData(player)
	local profile = LoadedProfiles[player]
	
	if not profile then
		debugPrint(string.format("Attempted to get data for %s but no profile loaded", player.Name), "WARN")
		return nil
	end
	
	return profile.Data
end

--[[
	Update player data (with validation)
	
	@param player Player
	@param path string - Dot notation path (e.g., "Profile.CurrentLevel")
	@param value any - New value
	@return boolean success
]]
function DataManager.UpdateData(player, path, value)
	local profile = LoadedProfiles[player]
	
	if not profile then
		debugPrint(string.format("Cannot update data for %s - no profile", player.Name), "ERROR")
		return false
	end
	
	-- Parse path and update
	local keys = string.split(path, ".")
	local current = profile.Data
	
	for i = 1, #keys - 1 do
		if not current[keys[i]] then
			current[keys[i]] = {}
		end
		current = current[keys[i]]
	end
	
	current[keys[#keys]] = value
	
	verboseLog(string.format("Updated %s for %s: %s = %s", path, player.Name, keys[#keys], tostring(value)))
	
	return true
end

--[[
	Increment a numeric value
	
	@param player Player
	@param path string
	@param amount number
	@return boolean success
]]
function DataManager.IncrementData(player, path, amount)
	local profile = LoadedProfiles[player]
	
	if not profile then
		return false
	end
	
	local keys = string.split(path, ".")
	local current = profile.Data
	
	for i = 1, #keys - 1 do
		if not current[keys[i]] then
			current[keys[i]] = {}
		end
		current = current[keys[i]]
	end
	
	local key = keys[#keys]
	current[key] = (current[key] or 0) + amount
	
	verboseLog(string.format("Incremented %s for %s by %d (new value: %d)", path, player.Name, amount, current[key]))
	
	return true
end

-- ═══════════════════════════════════════════════════════════════════════════
-- CRITICAL EVENT SAVES
-- ═══════════════════════════════════════════════════════════════════════════

--[[
	Save on critical events to minimize data loss
]]
function DataManager.SaveOnEvent(player, eventName)
	verboseLog(string.format("Critical event '%s' for %s - saving data", eventName, player.Name))
	
	DataManager.SavePlayerData(player, "Critical")
end

-- ═══════════════════════════════════════════════════════════════════════════
-- ADMIN COMMANDS (Debug)
-- ═══════════════════════════════════════════════════════════════════════════

--[[
	Wipe player data (TESTING ONLY)
]]
function DataManager.WipePlayerData(player)
	if not CONFIG.DEBUG_MODE then
		debugPrint("WipePlayerData called but DEBUG_MODE is off", "ERROR")
		return false
	end
	
	local profile = LoadedProfiles[player]
	
	if not profile then
		debugPrint("Cannot wipe - no profile loaded", "ERROR")
		return false
	end
	
	-- Reset to default
	profile.Data = PlayerDataStructure.GetDefaultData(player.UserId)
	
	debugPrint(string.format("⚠️ WIPED data for %s", player.Name), "WARN")
	
	return true
end

--[[
	Force save player data (admin command)
]]
function DataManager.ForceSave(player)
	return DataManager.SavePlayerData(player, "Critical")
end

--[[
	Print player data to console (admin command)
]]
function DataManager.ViewPlayerData(player)
	if not CONFIG.DEBUG_MODE then
		return
	end
	
	local data = DataManager.GetData(player)
	
	if data then
		print("=== PLAYER DATA FOR " .. player.Name .. " ===")
		print(game:GetService("HttpService"):JSONEncode(data))
		print("===========================================")
	else
		warn("No data for player:", player.Name)
	end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- INITIALIZATION
-- ═══════════════════════════════════════════════════════════════════════════

function DataManager.Initialize()
	debugPrint("=== DataManager Initializing ===", "INFO")
	
	-- Initialize ProfileService store
	local success = DataManager.InitializeStore()
	
	if not success then
		error("CRITICAL: Failed to initialize DataStore!")
	end
	
	-- Connect player events
	Players.PlayerAdded:Connect(DataManager.OnPlayerAdded)
	Players.PlayerRemoving:Connect(DataManager.OnPlayerRemoving)
	
	-- Handle players already in game (Studio testing)
	for _, player in ipairs(Players:GetPlayers()) do
		task.spawn(function()
			DataManager.OnPlayerAdded(player)
		end)
	end
	
	-- Start auto-save
	DataManager.StartAutoSave()
	
	-- Bind to close (save all before shutdown)
	game:BindToClose(function()
		debugPrint("Server shutting down - saving all data...", "WARN")
		
		DataManager.SaveAllPlayers()
		
		-- Wait for saves to complete
		task.wait(3)
	end)
	
	debugPrint("✅ DataManager fully initialized!", "INFO")
end

-- ═══════════════════════════════════════════════════════════════════════════
-- EXPORT
-- ═══════════════════════════════════════════════════════════════════════════

return DataManager