--[[
	ServerInit.luau
    
	Main server initialization script.
	Loads all core systems in correct order.
	
	INITIALIZATION ORDER:
	1. Constants & Configuration
	2. DataManager (ProfileService)
	3. Game Systems (Combat, Skills, etc.)
	4. Admin Commands
	
	This is the ENTRY POINT for the server.
	
	Author: Bisa Bahasa Studio
	Created: 2025-01-03
	Version: 1.0.0
]]

local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- ═══════════════════════════════════════════════════════════════════════════
-- CONFIGURATION
-- ═══════════════════════════════════════════════════════════════════════════

local INIT_CONFIG = {
	DEBUG_MODE = true, -- Set to false in production
	STARTUP_DELAY = 0, -- Delay before initialization (for testing)
	SHOW_STARTUP_MESSAGES = true,
}

-- ═══════════════════════════════════════════════════════════════════════════
-- UTILITY FUNCTIONS
-- ═══════════════════════════════════════════════════════════════════════════

local function log(message, level)
	level = level or "INFO"
	
	local timestamp = os.date("%H:%M:%S")
	local prefix = string.format("[ServerInit][%s][%s]", timestamp, level)
	
	if level == "ERROR" then
		warn(prefix, message)
	else
		print(prefix, message)
	end
end

local function logSuccess(message)
	log("✅ " .. message, "SUCCESS")
end

local function logError(message)
	log("❌ " .. message, "ERROR")
end

local function logWarning(message)
	log("⚠️ " .. message, "WARN")
end

-- ═══════════════════════════════════════════════════════════════════════════
-- MODULE LOADING
-- ═══════════════════════════════════════════════════════════════════════════

--[[
	Safe module loader with error handling
	
	@param modulePath Instance - Path to module
	@param moduleName string - Display name for logging
	@return table or nil - Loaded module or nil if failed
]]
local function loadModule(modulePath, moduleName)
	log(string.format("Loading %s...", moduleName), "INFO")
	
	local success, result = pcall(function()
		return require(modulePath)
	end)
	
	if success then
		logSuccess(string.format("%s loaded", moduleName))
		return result
	else
		logError(string.format("Failed to load %s: %s", moduleName, tostring(result)))
		return nil
	end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- REMOTE EVENTS SETUP
-- ═══════════════════════════════════════════════════════════════════════════

--[[
	Create all RemoteEvents & RemoteFunctions needed
]]
local function setupRemoteEvents()
	log("Setting up RemoteEvents...", "INFO")
	
	local remoteEventsFolder = ReplicatedStorage:FindFirstChild("RemoteEvents")
	
	if not remoteEventsFolder then
		remoteEventsFolder = Instance.new("Folder")
		remoteEventsFolder.Name = "RemoteEvents"
		remoteEventsFolder.Parent = ReplicatedStorage
	end
	
	-- List of required RemoteEvents
	local requiredEvents = {
		"DataLoaded",
		"SaveWarning",
		"UpdateStats",
		"UpdateInventory",
		"DamageEvent",
		"HealEvent",
		"DeathEvent",
	}
	
	for _, eventName in ipairs(requiredEvents) do
		if not remoteEventsFolder:FindFirstChild(eventName) then
			local remoteEvent = Instance.new("RemoteEvent")
			remoteEvent.Name = eventName
			remoteEvent.Parent = remoteEventsFolder
			
			log(string.format("  Created RemoteEvent: %s", eventName), "INFO")
		end
	end
	
	logSuccess("RemoteEvents setup complete")
end

-- ═══════════════════════════════════════════════════════════════════════════
-- ADMIN COMMANDS SETUP
-- ═══════════════════════════════════════════════════════════════════════════

--[[
	Setup admin commands for testing/debugging
]]
local function setupAdminCommands(dataManager)
	if not INIT_CONFIG.DEBUG_MODE then
		log("Admin commands disabled (DEBUG_MODE = false)", "INFO")
		return
	end
	
	log("Setting up admin commands...", "INFO")
	
	-- Admin user IDs (add your UserId here)
	local ADMIN_IDS = {
		-- 123456789, -- Replace with your UserId
	}
	
	local function isAdmin(player)
		for _, adminId in ipairs(ADMIN_IDS) do
			if player.UserId == adminId then
				return true
			end
		end
		return false
	end
	
	-- Command handler
	Players.PlayerAdded:Connect(function(player)
		player.Chatted:Connect(function(message)
			if not isAdmin(player) then return end
			
			local args = string.split(message, " ")
			local command = args[1]:lower()
			
			-- :wipedata [player]
			if command == ":wipedata" then
				local targetName = args[2]
				local target = targetName and Players:FindFirstChild(targetName) or player
				
				if target then
					local success = dataManager.WipePlayerData(target)
					if success then
						player:SendNotification({
							Title = "Admin Command",
							Text = string.format("Wiped data for %s", target.Name),
							Duration = 3,
						})
						
						log(string.format("Admin %s wiped data for %s", player.Name, target.Name), "WARN")
					end
				end
				
			-- :savedata [player]
			elseif command == ":savedata" then
				local targetName = args[2]
				local target = targetName and Players:FindFirstChild(targetName) or player
				
				if target then
					local success = dataManager.ForceSave(target)
					if success then
						player:SendNotification({
							Title = "Admin Command",
							Text = string.format("Saved data for %s", target.Name),
							Duration = 3,
						})
						
						log(string.format("Admin %s forced save for %s", player.Name, target.Name), "INFO")
					end
				end
				
			-- :viewdata [player]
			elseif command == ":viewdata" then
				local targetName = args[2]
				local target = targetName and Players:FindFirstChild(targetName) or player
				
				if target then
					dataManager.ViewPlayerData(target)
					
					player:SendNotification({
						Title = "Admin Command",
						Text = string.format("Data printed to console for %s", target.Name),
						Duration = 3,
					})
				end
				
			-- :givegold [player] [amount]
			elseif command == ":givegold" then
				local targetName = args[2]
				local amount = tonumber(args[3]) or 1000
				local target = targetName and Players:FindFirstChild(targetName) or player
				
				if target then
					dataManager.IncrementData(target, "Currency.Gold", amount)
					
					player:SendNotification({
						Title = "Admin Command",
						Text = string.format("Gave %d gold to %s", amount, target.Name),
						Duration = 3,
					})
					
					log(string.format("Admin %s gave %d gold to %s", player.Name, amount, target.Name), "INFO")
				end
				
			-- :givelevel [player] [level]
			elseif command == ":givelevel" then
				local targetName = args[2]
				local level = tonumber(args[3]) or 10
				local target = targetName and Players:FindFirstChild(targetName) or player
				
				if target then
					dataManager.UpdateData(target, "Profile.CurrentLevel", level)
					
					player:SendNotification({
						Title = "Admin Command",
						Text = string.format("Set level to %d for %s", level, target.Name),
						Duration = 3,
					})
					
					log(string.format("Admin %s set level to %d for %s", player.Name, level, target.Name), "INFO")
				end
				
			-- :giverarity [player] [rarity]
			elseif command == ":giverarity" then
				local targetName = args[2]
				local rarity = tonumber(args[3]) or 5
				local target = targetName and Players:FindFirstChild(targetName) or player
				
				if target then
					dataManager.UpdateData(target, "Profile.Rarity", rarity)
					
					player:SendNotification({
						Title = "Admin Command",
						Text = string.format("Set rarity to %d★ for %s", rarity, target.Name),
						Duration = 3,
					})
					
					log(string.format("Admin %s set rarity to %d★ for %s", player.Name, rarity, target.Name), "INFO")
				end
			end
		end)
	end)
	
	logSuccess("Admin commands setup complete")
	log("Available commands: :wipedata, :savedata, :viewdata, :givegold, :givelevel, :giverarity", "INFO")
end

-- ═══════════════════════════════════════════════════════════════════════════
-- MAIN INITIALIZATION
-- ═══════════════════════════════════════════════════════════════════════════

local function initialize()
	log("═══════════════════════════════════════════════════════════", "INFO")
	log("     AETHERIA: THE SOUL SPIRE - SERVER INITIALIZATION     ", "INFO")
	log("═══════════════════════════════════════════════════════════", "INFO")
	log("", "INFO")
	
	-- Startup delay (for testing)
	if INIT_CONFIG.STARTUP_DELAY > 0 then
		log(string.format("Startup delay: %d seconds", INIT_CONFIG.STARTUP_DELAY), "INFO")
		task.wait(INIT_CONFIG.STARTUP_DELAY)
	end
	
	-- ═══════════════════════════════════════════════════════════════════════
	-- PHASE 1: Load Configuration
	-- ═══════════════════════════════════════════════════════════════════════
	
	log("═══ PHASE 1: Loading Configuration ═══", "INFO")
	
	local Constants = loadModule(ReplicatedStorage.Shared.Constants, "Constants")
	local BalanceConfig = loadModule(ReplicatedStorage.Shared.BalanceConfig, "BalanceConfig")
	local FormulaCalculator = loadModule(ReplicatedStorage.Shared.FormulaCalculator, "FormulaCalculator")
	
	if not Constants or not BalanceConfig or not FormulaCalculator then
		logError("CRITICAL: Failed to load core configuration modules!")
		error("Server initialization failed - core modules missing")
	end
	
	log("", "INFO")
	
	-- ═══════════════════════════════════════════════════════════════════════
	-- PHASE 2: Load Data Structures
	-- ═══════════════════════════════════════════════════════════════════════
	
	log("═══ PHASE 2: Loading Data Structures ═══", "INFO")
	
	local PlayerDataStructure = loadModule(
		ServerScriptService.Data.PlayerDataStructure,
		"PlayerDataStructure"
	)
	
	local MonsterData = loadModule(
		ServerScriptService.Data.MonsterData,
		"MonsterData"
	)
	
	local SkillData = loadModule(
		ServerScriptService.Data.SkillData,
		"SkillData"
	)
	
	local EquipmentData = loadModule(
		ServerScriptService.Data.EquipmentData,
		"EquipmentData"
	)
	
	if not PlayerDataStructure or not MonsterData or not SkillData or not EquipmentData then
		logError("CRITICAL: Failed to load data structure modules!")
		error("Server initialization failed - data modules missing")
	end
	
	log("", "INFO")
	
	-- ═══════════════════════════════════════════════════════════════════════
	-- PHASE 3: Setup RemoteEvents
	-- ═══════════════════════════════════════════════════════════════════════
	
	log("═══ PHASE 3: Setting up RemoteEvents ═══", "INFO")
	
	setupRemoteEvents()
	
	log("", "INFO")
	
	-- ═══════════════════════════════════════════════════════════════════════
	-- PHASE 4: Initialize DataManager (CRITICAL)
	-- ═══════════════════════════════════════════════════════════════════════
	
	log("═══ PHASE 4: Initializing DataManager ═══", "INFO")
	
	local DataManager = loadModule(
		ServerScriptService.Core.DataManager,
		"DataManager"
	)
	
	if not DataManager then
		logError("CRITICAL: Failed to load DataManager!")
		error("Server initialization failed - DataManager missing")
	end
	
	-- Initialize DataManager (ProfileService setup)
	local initSuccess = pcall(function()
		DataManager.Initialize()
	end)
	
	if not initSuccess then
		logError("CRITICAL: DataManager initialization failed!")
		error("Server initialization failed - DataStore not accessible")
	end
	
	logSuccess("DataManager initialized and running")
	
	log("", "INFO")
	
	-- ═══════════════════════════════════════════════════════════════════════
	-- PHASE 5: Load Game Systems (Future - Week 2+)
	-- ═══════════════════════════════════════════════════════════════════════
	
	log("═══ PHASE 5: Loading Game Systems ═══", "INFO")
	
	-- Combat System (Week 2)
	-- local CombatSystem = loadModule(ServerScriptService.Systems.CombatSystem, "CombatSystem")
	log("  [PLACEHOLDER] CombatSystem - Coming in Week 2", "INFO")
	
	-- Skill System (Week 3)
	-- local SkillSystem = loadModule(ServerScriptService.Systems.SkillSystem, "SkillSystem")
	log("  [PLACEHOLDER] SkillSystem - Coming in Week 3", "INFO")
	
	-- Monster Spawner (Week 4)
	-- local MonsterSpawner = loadModule(ServerScriptService.Systems.MonsterSpawner, "MonsterSpawner")
	log("  [PLACEHOLDER] MonsterSpawner - Coming in Week 4", "INFO")
	
	log("", "INFO")
	
	-- ═══════════════════════════════════════════════════════════════════════
	-- PHASE 6: Setup Admin Commands
	-- ═══════════════════════════════════════════════════════════════════════
	
	log("═══ PHASE 6: Setting up Admin Commands ═══", "INFO")
	
	setupAdminCommands(DataManager)
	
	log("", "INFO")
	
	-- ═══════════════════════════════════════════════════════════════════════
	-- INITIALIZATION COMPLETE
	-- ═══════════════════════════════════════════════════════════════════════
	
	log("═══════════════════════════════════════════════════════════", "INFO")
	log("     ✅ SERVER INITIALIZATION COMPLETE                     ", "SUCCESS")
	log("═══════════════════════════════════════════════════════════", "INFO")
	log("", "INFO")
	log("Game Version: " .. Constants.GAME_VERSION, "INFO")
	log("DataStore: " .. Constants.DATASTORE_NAME, "INFO")
	log("Debug Mode: " .. tostring(Constants.DEBUG_MODE), "INFO")
	log("", "INFO")
	log("Server is ready to accept players!", "INFO")
	log("═══════════════════════════════════════════════════════════", "INFO")
end

-- ═══════════════════════════════════════════════════════════════════════════
-- ERROR HANDLING
-- ═══════════════════════════════════════════════════════════════════════════

local function safeInitialize()
	local success, errorMessage = pcall(initialize)
	
	if not success then
		logError("═══════════════════════════════════════════════════════════")
		logError("     CRITICAL ERROR DURING INITIALIZATION                 ")
		logError("═══════════════════════════════════════════════════════════")
		logError("")
		logError("Error: " .. tostring(errorMessage))
		logError("")
		logError("The server failed to start properly.")
		logError("Please check the error message above and fix the issue.")
		logError("═══════════════════════════════════════════════════════════")
		
		-- Prevent players from joining broken server
		Players.PlayerAdded:Connect(function(player)
			player:Kick(
				"🚧 Server sedang dalam perbaikan\n\n" ..
				"Mohon maaf, server mengalami masalah saat startup.\n" ..
				"Silakan coba lagi dalam beberapa menit!\n\n" ..
				"Error: " .. tostring(errorMessage)
			)
		end)
		
		error("Server initialization failed - see error above")
	end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- START SERVER
-- ═══════════════════════════════════════════════════════════════════════════

safeInitialize()

-- Return empty table to satisfy module requirement
return {}