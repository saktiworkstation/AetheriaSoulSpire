--[[
	PlayerDataStructure.luau
	
	Template dan helper functions untuk Player Data structure.
	Ini adalah "blueprint" untuk semua player data yang disimpan di DataStore.
	
	IMPORTANT:
	- Ini adalah ModuleScript yang define structure, BUKAN actual DataStore handler
	- DataManager.lua akan menggunakan template ini untuk create/load/save data
	
	Author: Bisa Bahasa Studio
	Created: 2025-01-03
	Last Modified: 2025-01-03
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Constants = require(ReplicatedStorage.Shared.Constants)
local BalanceConfig = require(ReplicatedStorage.Shared.BalanceConfig)

local PlayerDataStructure = {}

-- ═══════════════════════════════════════════════════════════════════════════
-- DEFAULT PLAYER DATA TEMPLATE
-- ═══════════════════════════════════════════════════════════════════════════

--[[
	Get default player data untuk new player
	
	Ini adalah "clean slate" data structure yang akan di-save ke DataStore.
	
	@param userId number - Player's UserId
	@return table - Default player data
]]
function PlayerDataStructure.GetDefaultData(userId)
	return {
		-- ═══════════════════════════════════════════════════════════════════
		-- METADATA
		-- ═══════════════════════════════════════════════════════════════════
		
		DataVersion = 1, -- Untuk migration system jika struktur berubah
		UserId = userId,
		CreatedAt = os.time(), -- Unix timestamp saat account dibuat
		LastSaved = os.time(), -- Unix timestamp last save
		
		-- ═══════════════════════════════════════════════════════════════════
		-- PROFILE DATA (Character Core)
		-- ═══════════════════════════════════════════════════════════════════
		
		Profile = {
			-- Character progression
			Rarity = 1, -- Star level (1-10)
			CurrentLevel = 1,
			CurrentXP = 0,
			
			-- Statistics tracking
			TotalDeaths = 0,
			TotalMonsterKills = 0,
			TotalFloorClears = 0,
			TotalPlaytimeSeconds = 0,
			
			-- Records
			HighestFloorReached = 0,
			HighestLevelReached = 1,
			FastestFloorClearTime = 0, -- Seconds (0 = not set)
		},
		
		-- ═══════════════════════════════════════════════════════════════════
		-- STATS (Allocated Stat Points)
		-- ═══════════════════════════════════════════════════════════════════
		
		Stats = {
			-- Allocated points per stat
			STR = 0, -- Strength
			INT = 0, -- Intellect
			VIT = 0, -- Vitality
			DEX = 0, -- Dexterity
			
			-- Unspent points (calculated, but stored untuk backup)
			UnspentPoints = 0,
		},
		
		-- ═══════════════════════════════════════════════════════════════════
		-- INVENTORY
		-- ═══════════════════════════════════════════════════════════════════
		
		Inventory = {
			-- Skills (Array of skill objects)
			Skills = {
				--[[
				Example entry:
				{
					SkillID = "FireballBasic",
					Level = 1,
					TimesUsed = 0,
					UnlockedAt = os.time(),
				}
				]]
			},
			
			-- Equipment (Currently equipped items)
			EquippedGear = {
				Weapon = nil, -- Equipment ID atau nil
				Armor = nil,
				Accessory = nil,
			},
			
			-- Equipment storage (Array of equipment objects)
			EquipmentStorage = {
				--[[
				Example entry:
				{
					EquipmentID = "IronSword_T1_Common",
					Tier = 1,
					Rarity = 1,
					CurrentDurability = 100,
					Stats = {Damage = 5, CritRate = 0.02},
					AcquiredAt = os.time(),
				}
				]]
			},
			
			-- Materials (Crafting materials - future feature)
			Materials = {
				--[[
				Example:
				["IronOre"] = 50,
				["LeatherScraps"] = 20,
				]]
			},
			
			-- Consumables (Potions, buffs, etc - future feature)
			Consumables = {
				--[[
				Example:
				["HealthPotion"] = 5,
				["XPBoost"] = 2,
				]]
			},
		},
		
		-- ═══════════════════════════════════════════════════════════════════
		-- EQUIPPED SKILLS (Current loadout)
		-- ═══════════════════════════════════════════════════════════════════
		
		EquippedSkills = {
			BasicAttack = nil, -- Skill ID untuk LMB (usually nil = default attack)
			Skill1 = nil,      -- Q key
			Skill2 = nil,      -- E key
			Ultimate = nil,    -- R key
		},
		
		-- ═══════════════════════════════════════════════════════════════════
		-- CURRENCY
		-- ═══════════════════════════════════════════════════════════════════
		
		Currency = {
			Gold = 0,           -- Grindable currency
			SoulDust = 0,       -- From deaths/recycling
			SoulCrystals = 0,   -- Premium currency (Robux)
			
			-- Lifetime earnings (for analytics)
			TotalGoldEarned = 0,
			TotalSoulDustEarned = 0,
			TotalCrystalsEarned = 0,
			
			-- Spending tracking (for analytics)
			TotalGoldSpent = 0,
			TotalSoulDustSpent = 0,
			TotalCrystalsSpent = 0,
		},
		
		-- ═══════════════════════════════════════════════════════════════════
		-- TOWER PROGRESS
		-- ═══════════════════════════════════════════════════════════════════
		
		TowerProgress = {
			-- Unlocked floors (array of floor numbers)
			UnlockedFloors = {1}, -- Start dengan Floor 1 unlocked
			
			-- Completed floors (array of floor numbers)
			CompletedFloors = {},
			
			-- Bosses defeated (array of boss IDs)
			BossesDefeated = {},
			
			-- Checkpoint unlocks (setiap 10 lantai)
			Checkpoints = {1}, -- Floor 1 checkpoint always available
			
			-- Current run data (reset saat mati atau kembali ke lobby)
			CurrentRun = {
				Active = false,
				StartFloor = 1,
				CurrentFloor = 1,
				StartTime = 0,
				DeathsThisRun = 0,
				MonstersKilledThisRun = 0,
			},
		},
		
		-- ═══════════════════════════════════════════════════════════════════
		-- GACHA SYSTEM
		-- ═══════════════════════════════════════════════════════════════════
		
		Gacha = {
			-- Total rolls lifetime
			TotalRolls = 0,
			
			-- Last roll timestamp (untuk daily roll tracking - future)
			LastRollTime = 0,
			
			-- Pity counter (resets on 4★+ pull)
			PityCounter = 0,
			
			-- Roll history (last 10 rolls untuk display)
			RollHistory = {
				--[[
				Example:
				{Rarity = 3, Timestamp = os.time()},
				]]
			},
			
			-- Banner-specific pity (future feature untuk limited banners)
			BannerPity = {},
		},
		
		-- ═══════════════════════════════════════════════════════════════════
		-- ASCENSION SYSTEM
		-- ═══════════════════════════════════════════════════════════════════
		
		Ascension = {
			-- Total successful ascensions
			TotalAscensions = 0,
			
			-- Total failed ascensions
			TotalFailedAscensions = 0,
			
			-- Ascension history (untuk statistics)
			AscensionHistory = {
				--[[
				Example:
				{
					FromRarity = 3,
					ToRarity = 4,
					Success = true,
					Timestamp = os.time(),
				}
				]]
			},
			
			-- Insurance items owned (protects from rarity downgrade)
			InsuranceItems = 0,
		},
		
		-- ═══════════════════════════════════════════════════════════════════
		-- SOCIAL (Party & Guild - Future Feature)
		-- ═══════════════════════════════════════════════════════════════════
		
		Social = {
			-- Party
			CurrentPartyID = nil, -- Party ID jika sedang dalam party
			PartyInvites = {},    -- Pending invites
			
			-- Guild/Clan
			GuildID = nil,
			GuildRank = nil,
			
			-- Friends (future feature)
			Friends = {},
			
			-- Blocked players
			BlockedPlayers = {},
		},
		
		-- ═══════════════════════════════════════════════════════════════════
		-- ACHIEVEMENTS (Future Feature)
		-- ═══════════════════════════════════════════════════════════════════
		
		Achievements = {
			Unlocked = {
				--[[
				Example:
				["FirstBlood"] = true, -- Kill first monster
				["Survivor"] = true,   -- Survive to Floor 10
				]]
			},
			
			Progress = {
				--[[
				Example (for progressive achievements):
				["MonsterSlayer"] = 50, -- Kill 100 monsters (50/100)
				]]
			},
		},
		
		-- ═══════════════════════════════════════════════════════════════════
		-- SETTINGS & PREFERENCES
		-- ═══════════════════════════════════════════════════════════════════
		
		Settings = {
			-- Audio
			MasterVolume = 1.0,
			MusicVolume = 0.7,
			SFXVolume = 1.0,
			
			-- Graphics (mobile optimization)
			GraphicsQuality = "Auto", -- "Low", "Medium", "High", "Auto"
			ShowDamageNumbers = true,
			ShowHealthBars = true,
			
			-- Gameplay
			AutoLootPickup = true,
			ConfirmAscension = true, -- Require confirmation untuk ascension
			
			-- UI
			UIScale = 1.0,
			MinimapEnabled = true,
		},
		
		-- ═══════════════════════════════════════════════════════════════════
		-- ANALYTICS & TELEMETRY (Optional - untuk game balancing)
		-- ═══════════════════════════════════════════════════════════════════
		
		Analytics = {
			-- Session data
			TotalSessions = 0,
			LastLoginTime = 0,
			
			-- Combat analytics
			DamageDealt = {
				Physical = 0,
				Magic = 0,
				True = 0,
			},
			
			DamageTaken = {
				Physical = 0,
				Magic = 0,
			},
			
			-- Death causes (untuk balancing)
			DeathsByFloor = {
				--[[
				[1] = 5,  -- Died 5 times on Floor 1
				[5] = 10, -- Died 10 times on Floor 5
				]]
			},
			
			-- Skill usage (untuk meta analysis)
			SkillUsageCount = {
				--[[
				["FireballBasic"] = 150,
				]]
			},
		},
		
		-- ═══════════════════════════════════════════════════════════════════
		-- DEVELOPER FLAGS (Debug/Testing)
		-- ═══════════════════════════════════════════════════════════════════
		
		DevFlags = {
			IsTester = false,      -- Beta tester flag
			IsAdmin = false,       -- Admin privileges
			BannedUntil = 0,       -- Ban expiry timestamp (0 = not banned)
			BanReason = "",        -- Reason untuk ban
		},
	}
end

-- ═══════════════════════════════════════════════════════════════════════════
-- DATA VALIDATION FUNCTIONS
-- ═══════════════════════════════════════════════════════════════════════════

--[[
	Validate player data structure
	
	Checks untuk:
	- Required fields exist
	- Values dalam valid range
	- No exploited/hacked values
	
	@param data table - Player data to validate
	@return boolean isValid - Data valid atau tidak
	@return string errorMessage - Error message jika invalid
]]
function PlayerDataStructure.ValidateData(data)
	if not data then
		return false, "Data is nil"
	end
	
	-- Check critical fields
	if not data.Profile then
		return false, "Missing Profile data"
	end
	
	if not data.Stats then
		return false, "Missing Stats data"
	end
	
	-- Validate rarity range
	if data.Profile.Rarity < Constants.MIN_RARITY or data.Profile.Rarity > Constants.MAX_RARITY then
		return false, "Invalid Rarity: " .. tostring(data.Profile.Rarity)
	end
	
	-- Validate level range
	local maxLevel = Constants.LEVEL_CAP_PER_RARITY[data.Profile.Rarity] or 10
	if data.Profile.CurrentLevel < 1 or data.Profile.CurrentLevel > maxLevel then
		return false, "Invalid Level: " .. tostring(data.Profile.CurrentLevel)
	end
	
	-- Validate currency (check for negative values = exploit)
	if data.Currency.Gold < 0 or data.Currency.SoulDust < 0 or data.Currency.SoulCrystals < 0 then
		return false, "Negative currency detected (possible exploit)"
	end
	
	-- Validate currency caps
	if data.Currency.Gold > Constants.MAX_CURRENCY.GOLD then
		return false, "Gold exceeds maximum cap"
	end
	
	-- Validate stat points
	local totalAllocated = (data.Stats.STR or 0) + (data.Stats.INT or 0) + 
	                       (data.Stats.VIT or 0) + (data.Stats.DEX or 0)
	
	local maxAllowedPoints = (data.Profile.CurrentLevel - 1) * Constants.STAT_POINTS_PER_LEVEL
	
	if totalAllocated > maxAllowedPoints then
		return false, "Allocated stats exceed allowed amount (possible exploit)"
	end
	
	-- All checks passed
	return true, "Valid"
end

--[[
	Sanitize player data (remove invalid values, cap at limits)
	
	Digunakan untuk "auto-fix" data yang slightly corrupted
	daripada reject completely.
	
	@param data table - Player data
	@return table - Sanitized data
]]
function PlayerDataStructure.SanitizeData(data)
	-- Clamp currency values
	data.Currency.Gold = math.max(0, math.min(data.Currency.Gold, Constants.MAX_CURRENCY.GOLD))
	data.Currency.SoulDust = math.max(0, math.min(data.Currency.SoulDust, Constants.MAX_CURRENCY.SOUL_DUST))
	data.Currency.SoulCrystals = math.max(0, math.min(data.Currency.SoulCrystals, Constants.MAX_CURRENCY.SOUL_CRYSTALS))
	
	-- Clamp rarity
	data.Profile.Rarity = math.max(Constants.MIN_RARITY, math.min(data.Profile.Rarity, Constants.MAX_RARITY))
	
	-- Clamp level to rarity cap
	local maxLevel = Constants.LEVEL_CAP_PER_RARITY[data.Profile.Rarity] or 10
	data.Profile.CurrentLevel = math.max(1, math.min(data.Profile.CurrentLevel, maxLevel))
	
	-- Ensure XP doesn't overflow
	if data.Profile.CurrentXP < 0 then
		data.Profile.CurrentXP = 0
	end
	
	return data
end

-- ═══════════════════════════════════════════════════════════════════════════
-- DATA MIGRATION FUNCTIONS
-- ═══════════════════════════════════════════════════════════════════════════

--[[
	Migrate old data structure ke new version
	
	Digunakan saat game update dan struktur data berubah.
	
	@param oldData table - Data dengan version lama
	@param targetVersion number - Target version
	@return table - Migrated data
]]
function PlayerDataStructure.MigrateData(oldData, targetVersion)
	if not oldData or not oldData.DataVersion then
		warn("Cannot migrate data: missing DataVersion")
		return oldData
	end
	
	local currentVersion = oldData.DataVersion
	
	-- No migration needed
	if currentVersion >= targetVersion then
		return oldData
	end
	
	-- Example migration: v1 → v2
	if currentVersion == 1 and targetVersion >= 2 then
		-- Add new fields that don't exist in v1
		-- oldData.NewField = defaultValue
		
		oldData.DataVersion = 2
		currentVersion = 2
	end
	
	-- Future migrations can be chained here
	-- if currentVersion == 2 and targetVersion >= 3 then
	--     ...migrate v2 to v3...
	-- end
	
	return oldData
end

-- ═══════════════════════════════════════════════════════════════════════════
-- HELPER FUNCTIONS
-- ═══════════════════════════════════════════════════════════════════════════

--[[
	Deep copy table (untuk avoid reference issues)
	
	@param original table - Table to copy
	@return table - Deep copy
]]
function PlayerDataStructure.DeepCopy(original)
	local copy
	if type(original) == 'table' then
		copy = {}
		for key, value in pairs(original) do
			copy[key] = PlayerDataStructure.DeepCopy(value)
		end
	else
		copy = original
	end
	return copy
end

--[[
	Get player display name berdasarkan rarity
	
	@param rarity number - Player rarity
	@return string - Title (e.g., "★★★ Ascendant")
]]
function PlayerDataStructure.GetRarityTitle(rarity)
	local stars = string.rep("★", rarity)
	
	local titles = {
		[1] = "Novice Soul",
		[2] = "Awakened Soul",
		[3] = "Rising Star",
		[4] = "Ascendant",
		[5] = "Luminary",
		[6] = "Radiant",
		[7] = "Celestial",
		[8] = "Transcendent",
		[9] = "Divine",
		[10] = "Primordial",
	}
	
	return stars .. " " .. (titles[rarity] or "Unknown")
end

-- ═══════════════════════════════════════════════════════════════════════════
-- EXPORT
-- ═══════════════════════════════════════════════════════════════════════════

return PlayerDataStructure