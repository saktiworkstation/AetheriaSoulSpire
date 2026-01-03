--[[
	Constants.luau
	
	Berisi semua nilai constant yang digunakan di seluruh game.
	File ini adalah SINGLE SOURCE OF TRUTH untuk semua nilai yang tidak berubah.
	
	⚠️ JANGAN hardcode nilai di script lain - selalu reference dari sini!
	
	Author: Bisa Bahasa Studio
	Created: 2025-01-03
	Last Modified: 2025-01-03
]]

local Constants = {}

-- ═══════════════════════════════════════════════════════════════════════════
-- GAME VERSION & METADATA
-- ═══════════════════════════════════════════════════════════════════════════

Constants.GAME_VERSION = "0.1.0-alpha"
Constants.GAME_NAME = "Aetheria: The Soul Spire"
Constants.RELEASE_PHASE = "Alpha" -- Alpha, Beta, Release

-- ═══════════════════════════════════════════════════════════════════════════
-- RARITY SYSTEM (Star System)
-- ═══════════════════════════════════════════════════════════════════════════

Constants.MIN_RARITY = 1 -- Minimum star (★)
Constants.MAX_RARITY = 10 -- Maximum star (★★★★★★★★★★)

-- Level cap per rarity (Flexible - dapat diubah untuk balancing)
Constants.LEVEL_CAP_PER_RARITY = {
	[1] = 10,   -- 1★ = Max Level 10
	[2] = 20,   -- 2★ = Max Level 20
	[3] = 30,   -- 3★ = Max Level 30
	[4] = 40,   -- 4★ = Max Level 40
	[5] = 50,   -- 5★ = Max Level 50
	[6] = 60,   -- 6★ = Max Level 60
	[7] = 70,   -- 7★ = Max Level 70
	[8] = 80,   -- 8★ = Max Level 80
	[9] = 90,   -- 9★ = Max Level 90
	[10] = 100, -- 10★ = Max Level 100
}

-- Stat multiplier per rarity (Multiplicative bonus)
-- Formula: 1.0 + (Rarity - 1) * 0.5
-- Dapat di-override untuk custom progression
Constants.RARITY_STAT_MULTIPLIER = {
	[1] = 1.0,  -- 1★ = 100% base stats
	[2] = 1.5,  -- 2★ = 150% base stats
	[3] = 2.0,  -- 3★ = 200% base stats
	[4] = 2.5,  -- 4★ = 250% base stats
	[5] = 3.0,  -- 5★ = 300% base stats
	[6] = 3.5,  -- 6★ = 350% base stats
	[7] = 4.0,  -- 7★ = 400% base stats
	[8] = 4.5,  -- 8★ = 450% base stats
	[9] = 5.0,  -- 9★ = 500% base stats
	[10] = 5.5, -- 10★ = 550% base stats (endgame power)
}

-- ═══════════════════════════════════════════════════════════════════════════
-- PLAYER STATS SYSTEM
-- ═══════════════════════════════════════════════════════════════════════════

-- Stat points gained per level up
Constants.STAT_POINTS_PER_LEVEL = 4

-- Stat categories
Constants.STAT_TYPES = {
	STRENGTH = "STR",     -- Physical Damage & HP
	INTELLECT = "INT",    -- Magic Damage & formerly Mana (now unused)
	VITALITY = "VIT",     -- Max HP & HP Regen & Defense
	DEXTERITY = "DEX",    -- Crit Rate, Attack Speed, Movement Speed
}

-- Base stats untuk karakter Level 1 Rarity 1 (SMALL NUMBERS untuk scaling yang baik)
Constants.BASE_STATS = {
	MAX_HP = 50,              -- Base HP
	HP_REGEN_PER_SECOND = 0.5, -- Base HP regeneration per detik
	
	PHYSICAL_DAMAGE = 5,      -- Base physical damage (tanpa weapon)
	MAGIC_DAMAGE = 5,         -- Base magic damage
	
	DEFENSE = 0,              -- Base defense (armor)
	
	CRIT_RATE = 0.05,         -- 5% base crit chance
	CRIT_DAMAGE = 1.5,        -- 150% damage on crit
	
	ATTACK_SPEED = 1.0,       -- Attack per second multiplier
	MOVEMENT_SPEED = 16,      -- Studs per second (Roblox default)
}

-- ═══════════════════════════════════════════════════════════════════════════
-- COMBAT SYSTEM
-- ═══════════════════════════════════════════════════════════════════════════

-- Damage types
Constants.DAMAGE_TYPES = {
	PHYSICAL = "Physical",
	MAGIC = "Magic",
	TRUE = "True", -- Ignores defense
}

-- Combat mechanics
Constants.COMBAT = {
	INVULNERABILITY_AFTER_HIT = 0.5, -- Seconds of i-frames after taking damage
	MAX_COMBAT_RANGE = 100,           -- Maximum combat detection range (studs)
	AGGRO_RANGE = 50,                 -- Monster aggro range (studs)
	DEAGGRO_RANGE = 80,               -- Monster deaggro range (studs)
}

-- ═══════════════════════════════════════════════════════════════════════════
-- SKILL SYSTEM
-- ═══════════════════════════════════════════════════════════════════════════

Constants.MAX_SKILL_LEVEL = 10 -- Maximum level untuk setiap skill
Constants.MAX_EQUIPPED_SKILLS = 4 -- Jumlah skill yang bisa di-equip (LMB, Q, E, R)

-- Skill rarity tiers
Constants.SKILL_RARITY = {
	COMMON = 1,
	RARE = 2,
	EPIC = 3,
	LEGENDARY = 4,
}

-- Skill slots (keybinds)
Constants.SKILL_SLOTS = {
	BASIC_ATTACK = "LMB", -- Left Mouse Button
	SKILL_1 = "Q",
	SKILL_2 = "E",
	ULTIMATE = "R",
}

-- ═══════════════════════════════════════════════════════════════════════════
-- EQUIPMENT SYSTEM
-- ═══════════════════════════════════════════════════════════════════════════

-- Equipment slots
Constants.EQUIPMENT_SLOTS = {
	WEAPON = "Weapon",       -- Main hand weapon
	ARMOR = "Armor",         -- Chest/Body armor
	ACCESSORY = "Accessory", -- Ring/Amulet/etc
}

-- Equipment rarity (affects DURABILITY only, not stats)
Constants.EQUIPMENT_RARITY = {
	COMMON = 1,
	RARE = 2,
	EPIC = 3,
	LEGENDARY = 4,
}

-- Durability system
Constants.DURABILITY = {
	MAX_DURABILITY = 100,     -- All equipment starts at 100 durability
	LOSS_PER_DEATH = 10,      -- Durability lost on player death
	REPAIR_COST_MULTIPLIER = 5, -- Gold cost = (100 - Durability) * Multiplier * Rarity
}

-- ═══════════════════════════════════════════════════════════════════════════
-- MONSTER SYSTEM
-- ═══════════════════════════════════════════════════════════════════════════

-- Monster archetypes
Constants.MONSTER_TYPES = {
	MINION = "Minion",   -- Fast, low HP, standard damage
	TANK = "Tank",       -- Slow, high HP, low damage
	RANGED = "Ranged",   -- Medium speed, medium HP, high damage
	ELITE = "Elite",     -- Stronger version of any type
	BOSS = "Boss",       -- Special encounter with phases
}

-- Monster behavior states
Constants.MONSTER_AI_STATES = {
	IDLE = "Idle",
	PATROL = "Patrol",
	CHASE = "Chase",
	ATTACK = "Attack",
	RETREAT = "Retreat",
	DEAD = "Dead",
}

-- ═══════════════════════════════════════════════════════════════════════════
-- TOWER & FLOOR SYSTEM
-- ═══════════════════════════════════════════════════════════════════════════

Constants.STARTING_FLOOR = 1
Constants.MAX_FLOOR = 100 -- Theoretical max (akan bertambah di future updates)

Constants.CHECKPOINT_INTERVAL = 10 -- Checkpoint setiap 10 lantai
Constants.BOSS_FLOOR_INTERVAL = 10 -- Boss setiap 10 lantai

-- Floor types
Constants.FLOOR_TYPES = {
	NORMAL = "Normal",       -- Standard combat floor
	CHECKPOINT = "Checkpoint", -- Safe zone dengan rewards
	BOSS = "Boss",           -- Boss encounter
	TREASURE = "Treasure",   -- Loot room (future feature)
}

-- ═══════════════════════════════════════════════════════════════════════════
-- CURRENCY SYSTEM
-- ═══════════════════════════════════════════════════════════════════════════

Constants.CURRENCY_TYPES = {
	GOLD = "Gold",                   -- Grindable currency
	SOUL_DUST = "SoulDust",          -- From recycling/death
	SOUL_CRYSTALS = "SoulCrystals",  -- Premium currency (Robux)
}

-- Currency caps (untuk prevent exploits)
Constants.MAX_CURRENCY = {
	GOLD = 999999999,        -- ~1 billion
	SOUL_DUST = 999999,      -- ~1 million
	SOUL_CRYSTALS = 999999,  -- ~1 million
}

-- ═══════════════════════════════════════════════════════════════════════════
-- GACHA SYSTEM
-- ═══════════════════════════════════════════════════════════════════════════

-- Gacha rates (HEAVILY WEIGHTED untuk force Ascension path)
Constants.GACHA_RATES = {
	[1] = 40.0,  -- 40% untuk 1★ (Common)
	[2] = 30.0,  -- 30% untuk 2★ (Uncommon)
	[3] = 20.0,  -- 20% untuk 3★ (Rare)
	[4] = 9.0,   -- 9% untuk 4★ (Epic)
	[5] = 0.8,   -- 0.8% untuk 5★ (VERY HARD) ← Breakpoint mulai dari sini
	[6] = 0.15,  -- 0.15% untuk 6★
	[7] = 0.04,  -- 0.04% untuk 7★
	[8] = 0.008, -- 0.008% untuk 8★
	[9] = 0.0015,-- 0.0015% untuk 9★
	[10] = 0.0005, -- 0.0005% untuk 10★ (EXTREMELY RARE - basically impossible)
}

-- Pity system (guaranteed high rarity after X rolls tanpa Epic+)
Constants.GACHA_PITY_THRESHOLD = 50 -- After 50 rolls without 4★+, guaranteed 4★
Constants.GACHA_SUPER_PITY_THRESHOLD = 100 -- After 100 rolls, guaranteed 5★

-- Gacha costs
Constants.GACHA_COST = {
	SINGLE_ROLL_GOLD = 1000,        -- 1,000 gold per roll (grindable)
	SINGLE_ROLL_CRYSTALS = 50,      -- 50 crystals per roll (premium)
	MULTI_ROLL_CRYSTALS = 450,      -- 10x roll discount (10% off)
}

-- ═══════════════════════════════════════════════════════════════════════════
-- ASCENSION SYSTEM
-- ═══════════════════════════════════════════════════════════════════════════

-- Success rates untuk Ascension (per rarity upgrade)
Constants.ASCENSION_SUCCESS_RATE = {
	[1] = 100,  -- 1★ → 2★ = 100% success (guaranteed)
	[2] = 90,   -- 2★ → 3★ = 90% success
	[3] = 80,   -- 3★ → 4★ = 80% success
	[4] = 70,   -- 4★ → 5★ = 70% success
	[5] = 60,   -- 5★ → 6★ = 60% success
	[6] = 50,   -- 6★ → 7★ = 50% success (coin flip)
	[7] = 40,   -- 7★ → 8★ = 40% success
	[8] = 30,   -- 8★ → 9★ = 30% success
	[9] = 20,   -- 9★ → 10★ = 20% success (very risky)
}

-- Ascension insurance item (protects from rarity downgrade)
Constants.ASCENSION_INSURANCE_COST_CRYSTALS = 300 -- Premium item

-- ═══════════════════════════════════════════════════════════════════════════
-- DATASTORE SETTINGS
-- ═══════════════════════════════════════════════════════════════════════════

Constants.DATASTORE_NAME = "PlayerData_v1" -- Increment version saat major changes
Constants.AUTO_SAVE_INTERVAL = 300 -- Auto-save setiap 5 menit (300 detik)
Constants.SAVE_RETRY_ATTEMPTS = 3 -- Retry 3x jika save gagal
Constants.SESSION_LOCK_TIMEOUT = 600 -- 10 menit (kick player jika stuck)

-- ═══════════════════════════════════════════════════════════════════════════
-- UI CONSTANTS
-- ═══════════════════════════════════════════════════════════════════════════

-- UI Colors (RARITY COLORS)
Constants.RARITY_COLORS = {
	[1] = Color3.fromRGB(150, 150, 150), -- Gray (Common)
	[2] = Color3.fromRGB(100, 200, 100), -- Green (Uncommon)
	[3] = Color3.fromRGB(100, 150, 255), -- Blue (Rare)
	[4] = Color3.fromRGB(200, 100, 255), -- Purple (Epic)
	[5] = Color3.fromRGB(255, 200, 50),  -- Gold (Legendary)
	[6] = Color3.fromRGB(255, 150, 50),  -- Orange (Mythic)
	[7] = Color3.fromRGB(255, 50, 50),   -- Red (Celestial)
	[8] = Color3.fromRGB(100, 255, 255), -- Cyan (Transcendent)
	[9] = Color3.fromRGB(255, 100, 255), -- Magenta (Divine)
	[10] = Color3.fromRGB(255, 255, 100),-- Yellow (Primordial)
}

-- Damage number colors
Constants.DAMAGE_COLORS = {
	PHYSICAL = Color3.fromRGB(255, 100, 100), -- Red
	MAGIC = Color3.fromRGB(100, 150, 255),    -- Blue
	TRUE = Color3.fromRGB(255, 255, 100),     -- Yellow
	CRIT = Color3.fromRGB(255, 200, 50),      -- Gold
	HEAL = Color3.fromRGB(100, 255, 100),     -- Green
}

-- ═══════════════════════════════════════════════════════════════════════════
-- PARTY SYSTEM (Future Feature - Week 10)
-- ═══════════════════════════════════════════════════════════════════════════

Constants.MAX_PARTY_SIZE = 4 -- Maximum 4 players per party
Constants.PARTY_XP_SHARE_MULTIPLIER = 0.8 -- Each member gets 80% of solo XP
Constants.PARTY_LOOT_DISTRIBUTION = "Round-Robin" -- atau "Random", "Need-Greed"

-- ═══════════════════════════════════════════════════════════════════════════
-- DEVELOPER/DEBUG SETTINGS
-- ═══════════════════════════════════════════════════════════════════════════

Constants.DEBUG_MODE = true -- Enable debug prints & visualizations
Constants.GOD_MODE_ENABLED = false -- Invincibility for testing
Constants.SHOW_HITBOXES = true -- Visualize hitboxes in Studio

-- ═══════════════════════════════════════════════════════════════════════════
-- ANTI-CHEAT THRESHOLDS
-- ═══════════════════════════════════════════════════════════════════════════

Constants.ANTI_CHEAT = {
	MAX_DAMAGE_PER_HIT = 99999,       -- Kick if damage > this (for current level)
	MAX_MOVEMENT_SPEED = 100,         -- Kick if speed > 100 studs/sec
	MAX_XP_GAIN_PER_SECOND = 10000,   -- Suspicious XP gain rate
	MAX_GOLD_GAIN_PER_SECOND = 5000,  -- Suspicious gold gain rate
}

-- ═══════════════════════════════════════════════════════════════════════════
-- ADAPTIVE ECOLOGY SYSTEM (Week 3+)
-- ═══════════════════════════════════════════════════════════════════════════

Constants.ADAPTIVE_ECOLOGY = {
	ANALYSIS_INTERVAL = 21600,        -- Analyze data every 6 hours (21600 seconds)
	ADAPTATION_THRESHOLD = 0.7,       -- 70% damage dari satu type → trigger adaptation
	MAX_RESISTANCE_BUFF = 0.4,        -- Maximum 40% resistance buff
	RESISTANCE_DECAY_TIME = 43200,    -- Resistance decays after 12 hours if meta changes
}

-- ═══════════════════════════════════════════════════════════════════════════
-- EXPORT
-- ═══════════════════════════════════════════════════════════════════════════

return Constants