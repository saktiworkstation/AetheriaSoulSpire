--[[
	BalanceConfig.luau
	
	Berisi semua nilai numerik untuk game balancing.
	File ini MUDAH DI-TWEAK tanpa mengubah core logic.
	
	FILOSOFI DESIGN:
	- Small numbers → Big impact (easy to understand scaling)
	- Exponential growth → Rewarding progression
	- Hardcore difficulty → Challenge-focused gameplay
	
	⚠️ SEMUA NILAI DI SINI ADALAH STARTING POINT!
	   Akan di-adjust berdasarkan playtesting data.
	
	Author: Bisa Bahasa Studio
	Created: 2025-01-03
	Last Modified: 2025-01-03
]]

local BalanceConfig = {}

-- ═══════════════════════════════════════════════════════════════════════════
-- PROGRESSION SYSTEM
-- ═══════════════════════════════════════════════════════════════════════════

--[[
	XP CURVE - EXPONENTIAL GROWTH
	
	Formula: XP_Required = BaseXP * (GrowthRate ^ (Level - 1))
	
	Reasoning:
	- Level 1→2 mudah (onboarding)
	- Level scaling eksponential untuk long-term engagement
	- Total XP ke max level harus terasa achievable tapi challenging
	
	Example progression (1★ character):
	Level 1→2:  100 XP
	Level 2→3:  135 XP
	Level 5→6:  366 XP
	Level 9→10: 1,000 XP
	Total to Lv10: ~4,500 XP
]]
BalanceConfig.XP_CURVE = {
	BASE_XP = 100,           -- XP untuk Level 1→2
	GROWTH_RATE = 1.35,      -- Exponential multiplier (1.35 = 35% increase per level)
	
	-- XP gain modifiers
	PARTY_XP_BONUS = 0.1,    -- +10% XP saat dalam party (encourage co-op)
	BOSS_XP_MULTIPLIER = 5.0, -- Boss memberikan 5x XP monster biasa
	
	-- XP sources
	MONSTER_BASE_XP = 25,    -- Base XP per monster kill (scaled by floor)
	QUEST_XP_MULTIPLIER = 2.0, -- Quests give 2x normal XP (future feature)
}

--[[
	STAT SCALING PER POINT
	
	Setiap 1 point stat yang dialokasikan memberikan bonus:
	- STR: +2 Physical Damage, +5 HP
	- INT: +2.5 Magic Damage, +0 (mana removed)
	- VIT: +10 HP, +0.5 Defense, +0.1 HP Regen/sec
	- DEX: +0.5% Crit Rate, +0.02 Attack Speed, +0.2 Movement Speed
	
	Reasoning:
	- VIT paling "valuable" untuk survival (tapi boring untuk damage)
	- STR/INT balanced untuk damage dealers
	- DEX untuk skill-based players (crit, speed)
]]
BalanceConfig.STAT_SCALING = {
	-- Strength (STR) bonuses
	STR_TO_PHYSICAL_DAMAGE = 2,
	STR_TO_HP = 5,
	
	-- Intellect (INT) bonuses
	INT_TO_MAGIC_DAMAGE = 2.5,
	-- INT_TO_MANA = 0, -- Removed (no mana system)
	
	-- Vitality (VIT) bonuses
	VIT_TO_HP = 10,
	VIT_TO_DEFENSE = 0.5,
	VIT_TO_HP_REGEN = 0.1,
	
	-- Dexterity (DEX) bonuses
	DEX_TO_CRIT_RATE = 0.005,      -- 0.5% per point
	DEX_TO_ATTACK_SPEED = 0.02,    -- 2% per point
	DEX_TO_MOVEMENT_SPEED = 0.2,   -- 0.2 studs/sec per point
}

--[[
	DEATH PENALTY - SOUL DUST REWARD
	
	Formula: SoulDust = (CurrentLevel ÷ 10) * 2 * ExponentialMultiplier
	
	Tier system (per 10 levels):
	- Level 1-10:   2 Soul Dust (Tier 1 multiplier: 1.0x)
	- Level 11-20:  6 Soul Dust (Tier 2 multiplier: 1.5x)
	- Level 21-30:  14 Soul Dust (Tier 3 multiplier: 2.3x)
	- Level 31-40:  30 Soul Dust (Tier 4 multiplier: 3.75x)
	- ... (exponential growth)
	
	Reasoning:
	- Low levels = small Soul Dust (not punishing for new players)
	- High levels = big Soul Dust (death still stings, but rewarding)
	- Encourage high-risk high-reward gameplay
]]
BalanceConfig.SOUL_DUST_ON_DEATH = {
	BASE_DUST_PER_10_LEVELS = 2,
	
	-- Tier multipliers (exponential)
	TIER_MULTIPLIERS = {
		[1] = 1.0,   -- Level 1-10
		[2] = 1.5,   -- Level 11-20
		[3] = 2.3,   -- Level 21-30
		[4] = 3.75,  -- Level 31-40
		[5] = 6.0,   -- Level 41-50
		[6] = 9.5,   -- Level 51-60
		[7] = 15.0,  -- Level 61-70
		[8] = 24.0,  -- Level 71-80
		[9] = 38.0,  -- Level 81-90
		[10] = 60.0, -- Level 91-100
	}
}

-- ═══════════════════════════════════════════════════════════════════════════
-- COMBAT BALANCE
-- ═══════════════════════════════════════════════════════════════════════════

--[[
	DAMAGE FORMULA - DEFENSE REDUCTION
	
	Formula: Final Damage = Raw Damage * (1 - (Defense / (Defense + 100)))
	
	This is a "diminishing returns" formula:
	- 0 Defense   = 0% reduction
	- 50 Defense  = 33% reduction
	- 100 Defense = 50% reduction
	- 200 Defense = 67% reduction
	- 500 Defense = 83% reduction (hard cap effectiveness)
	
	Reasoning:
	- Defense ALWAYS useful, never useless
	- Stacking defense has diminishing returns (prevent invincibility)
	- Attacker can still kill tank, just takes longer
]]
BalanceConfig.DEFENSE_FORMULA = {
	DEFENSE_CONSTANT = 100, -- Higher = defense less effective
	MIN_DAMAGE_PERCENT = 0.05, -- Minimum 5% damage goes through (prevent 0 damage)
}

--[[
	CRITICAL HIT SYSTEM
	
	- Crit Rate: Chance to crit (0.0 - 1.0)
	- Crit Damage: Multiplier when crit occurs
	
	Soft cap: 75% crit rate (beyond ini, diminishing returns)
]]
BalanceConfig.CRIT_SYSTEM = {
	BASE_CRIT_DAMAGE = 1.5,    -- 150% damage on crit (default)
	MAX_CRIT_RATE = 0.75,      -- Soft cap at 75% (can't go higher naturally)
	CRIT_RATE_DIMINISH_START = 0.5, -- After 50% crit, scaling slows down
}

--[[
	ATTACK SPEED CAPS
	
	Prevent absurdly fast attacks (server performance + game feel)
]]
BalanceConfig.ATTACK_SPEED = {
	MIN_ATTACK_SPEED = 0.5,    -- Slowest: 1 attack per 2 seconds
	MAX_ATTACK_SPEED = 3.0,    -- Fastest: 3 attacks per second
}

-- ═══════════════════════════════════════════════════════════════════════════
-- MONSTER BALANCE - HARDCORE SCALING
-- ═══════════════════════════════════════════════════════════════════════════

--[[
	MONSTER SCALING FORMULA - CUSTOM & AGGRESSIVE
	
	Goal: Monster SELALU challenging, bahkan untuk high-level players
	
	Scaling factors:
	1. Floor-based scaling (higher floor = stronger)
	2. Player average level scaling (jika player overlevel, monster catch up)
	3. Archetype multipliers (Minion/Tank/Ranged different stat profiles)
	
	Formula:
	MonsterHP = BaseHP * (FloorMultiplier ^ Floor) * PlayerLevelMultiplier * ArchetypeMultiplier
	MonsterDamage = BaseDamage * (FloorMultiplier ^ Floor) * PlayerLevelMultiplier * ArchetypeMultiplier
	
	Example (Floor 5, Player Lv 15):
	- BaseHP = 30
	- FloorMultiplier = 1.4 ^ 5 = 5.38
	- PlayerLevelMult = 1.0 + (15 / 100) = 1.15
	- ArchetypeMultiplier (Minion) = 0.7
	- Final HP = 30 * 5.38 * 1.15 * 0.7 ≈ 133 HP
	
	Ini membuat monster:
	- Floor 1: 1-2 hit untuk kill (easy onboarding)
	- Floor 10: 5-8 hit untuk kill (decent challenge)
	- Floor 50: 20-30 hit untuk kill (hardcore grind)
]]
BalanceConfig.MONSTER_SCALING = {
	-- Base stats untuk Floor 1 monster
	BASE_HP = 30,
	BASE_DAMAGE = 3,
	BASE_DEFENSE = 0,
	BASE_XP_REWARD = 25,
	BASE_GOLD_DROP = 5,
	
	-- Floor scaling (exponential)
	FLOOR_HP_MULTIPLIER = 1.4,       -- HP tumbuh 40% per floor
	FLOOR_DAMAGE_MULTIPLIER = 1.3,   -- Damage tumbuh 30% per floor
	FLOOR_DEFENSE_MULTIPLIER = 1.25, -- Defense tumbuh 25% per floor
	
	-- Player level adaptive scaling
	PLAYER_LEVEL_SCALING_FACTOR = 0.01, -- +1% per player average level
	MAX_PLAYER_LEVEL_SCALING = 2.0,     -- Cap at 2x (prevent absurd scaling)
	
	-- Archetype multipliers (relative to base)
	ARCHETYPE_MULTIPLIERS = {
		Minion = {
			HP = 0.7,        -- 70% base HP (fragile)
			Damage = 1.0,    -- 100% base damage (standard)
			Defense = 0.5,   -- 50% base defense (paper armor)
			Speed = 1.5,     -- 150% movement speed (fast)
			XP = 1.0,        -- 100% base XP
			Gold = 1.0,      -- 100% base gold
		},
		Tank = {
			HP = 2.5,        -- 250% base HP (very tanky)
			Damage = 0.7,    -- 70% base damage (low threat)
			Defense = 2.0,   -- 200% base defense (hard to kill)
			Speed = 0.6,     -- 60% movement speed (slow)
			XP = 1.5,        -- 150% base XP (worth killing)
			Gold = 1.3,      -- 130% base gold
		},
		Ranged = {
			HP = 1.0,        -- 100% base HP (balanced)
			Damage = 1.3,    -- 130% base damage (high threat)
			Defense = 0.8,   -- 80% base defense (slightly squishy)
			Speed = 1.0,     -- 100% movement speed (normal)
			XP = 1.2,        -- 120% base XP
			Gold = 1.2,      -- 120% base gold
		},
		Elite = {
			HP = 3.0,        -- 300% base HP
			Damage = 1.5,    -- 150% base damage
			Defense = 1.5,   -- 150% base defense
			Speed = 1.2,     -- 120% movement speed
			XP = 3.0,        -- 300% base XP (big reward)
			Gold = 2.5,      -- 250% base gold
		},
		Boss = {
			HP = 10.0,       -- 1000% base HP (raid boss tier)
			Damage = 2.0,    -- 200% base damage
			Defense = 2.0,   -- 200% base defense
			Speed = 0.8,     -- 80% movement speed (bosses are slow but deadly)
			XP = 10.0,       -- 1000% base XP
			Gold = 5.0,      -- 500% base gold
		},
	},
	
	-- Monster density per floor (wave spawning)
	MONSTERS_PER_WAVE = {
		[1] = 3,   -- Floor 1-10: 3-5 monsters per wave
		[2] = 5,   -- Floor 11-20: 5-7 monsters
		[3] = 7,   -- Floor 21-30: 7-10 monsters
		[4] = 10,  -- Floor 31+: 10-15 monsters (chaos)
	},
	
	-- Wave count per floor
	WAVES_PER_FLOOR = 3, -- Standard floors have 3 waves
	BOSS_FLOOR_WAVES = 1, -- Boss floors are single encounter
}

-- ═══════════════════════════════════════════════════════════════════════════
-- SKILL BALANCE
-- ═══════════════════════════════════════════════════════════════════════════

--[[
	SKILL LEVEL SCALING - EXPONENTIAL POWER GROWTH
	
	Formula: SkillPower = BasePower * (1 + (Level - 1) * 0.2)
	
	Example (skill dengan 100% base damage):
	- Level 1:  100% damage
	- Level 5:  180% damage
	- Level 10: 280% damage
	
	Reasoning:
	- Skill upgrade SANGAT berharga (lebih dari character level)
	- Encourage skill scroll farming
	- High level skills = game-changing power
]]
BalanceConfig.SKILL_SCALING = {
	-- Damage scaling per skill level
	DAMAGE_SCALING_PER_LEVEL = 0.2,  -- +20% per level
	
	-- Cooldown reduction per skill level
	COOLDOWN_REDUCTION_PER_LEVEL = 0.05, -- -5% cooldown per level (cap 50%)
	MAX_COOLDOWN_REDUCTION = 0.5,        -- Maximum 50% cooldown reduction
	
	-- Skill evolution thresholds
	EVOLUTION_LEVELS = {
		[5] = "Enhanced",    -- Level 5: Enhanced version (VFX upgrade)
		[10] = "Perfected",  -- Level 10: Perfected version (new mechanics)
	},
}

--[[
	SKILL DROP RATES - DIFFICULT ACQUISITION
	
	Skills harus LEBIH SUSAH didapat daripada character rarity.
	Ini membuat skill scrolls bernilai tinggi dan tradeable (future economy).
	
	Drop rates per monster type:
]]
BalanceConfig.SKILL_DROP_RATES = {
	-- Base drop rate (per monster kill)
	Minion = {
		Common = 0.05,      -- 5% chance
		Rare = 0.01,        -- 1% chance
		Epic = 0.002,       -- 0.2% chance
		Legendary = 0.0005, -- 0.05% chance (extremely rare)
	},
	Tank = {
		Common = 0.08,      -- 8% chance (tanks more rewarding)
		Rare = 0.02,        -- 2% chance
		Epic = 0.005,       -- 0.5% chance
		Legendary = 0.001,  -- 0.1% chance
	},
	Ranged = {
		Common = 0.06,      -- 6% chance
		Rare = 0.015,       -- 1.5% chance
		Epic = 0.003,       -- 0.3% chance
		Legendary = 0.0007, -- 0.07% chance
	},
	Elite = {
		Common = 0.2,       -- 20% chance
		Rare = 0.1,         -- 10% chance
		Epic = 0.03,        -- 3% chance
		Legendary = 0.01,   -- 1% chance
	},
	Boss = {
		Common = 0.5,       -- 50% chance (guaranteed practically)
		Rare = 0.3,         -- 30% chance
		Epic = 0.15,        -- 15% chance
		Legendary = 0.05,   -- 5% chance (masih rare dari boss!)
	},
	
	-- Duplicate skill drops = level up material
	DUPLICATE_LEVEL_UP_CHANCE = 1.0, -- 100% (duplikat otomatis jadi level up material)
}

-- ═══════════════════════════════════════════════════════════════════════════
-- EQUIPMENT BALANCE
-- ═══════════════════════════════════════════════════════════════════════════

--[[
	EQUIPMENT STATS - FLAT BONUSES (No Rarity Multiplier)
	
	Rarity HANYA affect durability, NOT stats.
	Ini berbeda dari typical gacha game (design choice untuk reduce P2W).
	
	Stats progression:
	- Tier 1 Equipment (Floor 1-10):   +5 Damage, +20 HP
	- Tier 2 Equipment (Floor 11-20):  +12 Damage, +50 HP
	- Tier 3 Equipment (Floor 21-30):  +25 Damage, +100 HP
	- ... (exponential growth per tier)
]]
BalanceConfig.EQUIPMENT_STATS = {
	-- Base stats per equipment tier
	WEAPON_TIERS = {
		[1] = {Damage = 5, CritRate = 0.02},      -- +5 damage, +2% crit
		[2] = {Damage = 12, CritRate = 0.04},     -- +12 damage, +4% crit
		[3] = {Damage = 25, CritRate = 0.06},     -- Tier 3
		[4] = {Damage = 50, CritRate = 0.08},     -- Tier 4
		[5] = {Damage = 100, CritRate = 0.10},    -- Tier 5 (endgame)
	},
	
	ARMOR_TIERS = {
		[1] = {HP = 20, Defense = 5},
		[2] = {HP = 50, Defense = 12},
		[3] = {HP = 100, Defense = 25},
		[4] = {HP = 200, Defense = 50},
		[5] = {HP = 400, Defense = 100},
	},
	
	ACCESSORY_TIERS = {
		[1] = {HP = 10, Damage = 3, CritDamage = 0.1}, -- +10% crit damage
		[2] = {HP = 25, Damage = 7, CritDamage = 0.15},
		[3] = {HP = 50, Damage = 15, CritDamage = 0.2},
		[4] = {HP = 100, Damage = 30, CritDamage = 0.25},
		[5] = {HP = 200, Damage = 60, CritDamage = 0.3},
	},
}

--[[
	DURABILITY SYSTEM
	
	Rarity = Durability persistence
	- Common: Breaks very fast (10 deaths)
	- Legendary: Lasts forever (100 deaths)
	
	Repair cost = (100 - Current Durability) * Rarity Multiplier * 5 gold
]]
BalanceConfig.DURABILITY_SYSTEM = {
	-- Durability loss per death (based on rarity)
	DURABILITY_LOSS_PER_DEATH = {
		[1] = 10,  -- Common: 10 durability per death (lasts 10 deaths)
		[2] = 5,   -- Rare: 5 durability per death (lasts 20 deaths)
		[3] = 2,   -- Epic: 2 durability per death (lasts 50 deaths)
		[4] = 1,   -- Legendary: 1 durability per death (lasts 100 deaths)
	},
	
	-- Repair cost formula multiplier
	REPAIR_COST_PER_DURABILITY = 5, -- 5 gold per durability point
	RARITY_REPAIR_MULTIPLIER = {
		[1] = 1.0,  -- Common: base cost
		[2] = 1.5,  -- Rare: 1.5x cost
		[3] = 2.5,  -- Epic: 2.5x cost
		[4] = 5.0,  -- Legendary: 5x cost (very expensive to repair)
	},
}

--[[
	EQUIPMENT DROP RATES
	
	Equipment drops dari monster berdasarkan floor tier.
	Floor 1-10 = Tier 1 equipment only
	Floor 11-20 = Tier 2 equipment, small chance Tier 3
	... etc
]]
BalanceConfig.EQUIPMENT_DROP_RATES = {
	-- Drop chance per monster (base)
	BASE_DROP_CHANCE = 0.1, -- 10% chance untuk drop equipment
	
	-- Tier distribution per floor range
	TIER_DISTRIBUTION = {
		-- Floor 1-10
		[1] = {
			[1] = 0.9,  -- 90% Tier 1
			[2] = 0.1,  -- 10% Tier 2
		},
		-- Floor 11-20
		[2] = {
			[1] = 0.3,  -- 30% Tier 1
			[2] = 0.6,  -- 60% Tier 2
			[3] = 0.1,  -- 10% Tier 3
		},
		-- Floor 21-30
		[3] = {
			[2] = 0.4,  -- 40% Tier 2
			[3] = 0.5,  -- 50% Tier 3
			[4] = 0.1,  -- 10% Tier 4
		},
		-- Floor 31+
		[4] = {
			[3] = 0.5,  -- 50% Tier 3
			[4] = 0.4,  -- 40% Tier 4
			[5] = 0.1,  -- 10% Tier 5
		},
	},
	
	-- Rarity distribution (for durability)
	RARITY_DISTRIBUTION = {
		[1] = 0.5,  -- 50% Common
		[2] = 0.3,  -- 30% Rare
		[3] = 0.15, -- 15% Epic
		[4] = 0.05, -- 5% Legendary
	},
}

-- ═══════════════════════════════════════════════════════════════════════════
-- ECONOMY BALANCE - GOLD & SOUL DUST
-- ═══════════════════════════════════════════════════════════════════════════

--[[
	GOLD ECONOMY - DIFFICULT & EXPONENTIAL
	
	Design Goal:
	- Gold harus VALUABLE (tidak mudah didapat)
	- Encourage grinding & smart play
	- Create player-driven economy (trading future feature)
	
	Gold sources:
	1. Monster drops (primary)
	2. Boss kills (big payout)
	3. Floor completion bonus
	4. Selling equipment (future)
]]
BalanceConfig.GOLD_ECONOMY = {
	-- Monster gold drops (per floor, exponential)
	MONSTER_GOLD_DROP = {
		BASE_GOLD = 5,              -- Floor 1 monster drops 5 gold
		FLOOR_MULTIPLIER = 1.3,     -- +30% per floor
		
		-- Gold drop variance (randomness)
		MIN_VARIANCE = 0.7,         -- Minimum 70% of base
		MAX_VARIANCE = 1.3,         -- Maximum 130% of base
	},
	
	-- Boss gold drops (HUGE payout)
	BOSS_GOLD_MULTIPLIER = 10,      -- Boss drops 10x normal monster gold
	
	-- Floor completion bonus
	FLOOR_CLEAR_BONUS = {
		BASE_BONUS = 50,            -- 50 gold untuk clear Floor 1
		FLOOR_MULTIPLIER = 1.4,     -- +40% per floor
	},
	
	-- Gold sinks (where gold is spent)
	GOLD_SINKS = {
		-- Ascension costs (EXPONENTIAL)
		ASCENSION_BASE_COST = 1000,     -- 1★ → 2★ = 1,000 gold
		ASCENSION_MULTIPLIER = 2.5,     -- Setiap tier 2.5x lebih mahal
		
		-- Equipment repair
		REPAIR_BASE_COST = 5,           -- 5 gold per durability point
		
		-- Gacha roll
		SINGLE_GACHA_COST = 1000,       -- 1,000 gold per roll
		
		-- Shop items (future)
		POTION_COST = 100,              -- Health potion
		BUFF_SCROLL_COST = 500,         -- Temporary buff item
	},
}

--[[
	ASCENSION COSTS - PER RARITY TIER
	
	Formula: Cost = BaseGold * (Multiplier ^ (TargetRarity - 1)) + (SoulDust * DustMultiplier)
	
	Example costs:
	- 1★ → 2★:  1,000 gold + 50 Soul Dust
	- 2★ → 3★:  2,500 gold + 150 Soul Dust
	- 3★ → 4★:  6,250 gold + 400 Soul Dust
	- 4★ → 5★:  15,625 gold + 1,000 Soul Dust (HUGE jump)
	- 5★ → 6★:  39,063 gold + 2,500 Soul Dust
	- ... (exponential scaling to 10★)
	
	Reasoning:
	- Early ascensions affordable (1★-3★)
	- Mid-tier grindy but doable (4★-6★)
	- Late-tier VERY expensive (7★-10★) → long-term goal
]]
BalanceConfig.ASCENSION_COSTS = {
	-- Gold cost per tier
	GOLD_COSTS = {
		[2] = 1000,      -- 1★ → 2★
		[3] = 2500,      -- 2★ → 3★
		[4] = 6250,      -- 3★ → 4★
		[5] = 15625,     -- 4★ → 5★ (big jump)
		[6] = 39063,     -- 5★ → 6★
		[7] = 97656,     -- 6★ → 7★
		[8] = 244141,    -- 7★ → 8★
		[9] = 610352,    -- 8★ → 9★
		[10] = 1525879,  -- 9★ → 10★ (endgame grind)
	},
	
	-- Soul Dust cost per tier
	SOUL_DUST_COSTS = {
		[2] = 50,        -- 1★ → 2★
		[3] = 150,       -- 2★ → 3★
		[4] = 400,       -- 3★ → 4★
		[5] = 1000,      -- 4★ → 5★
		[6] = 2500,      -- 5★ → 6★
		[7] = 6250,      -- 6★ → 7★
		[8] = 15625,     -- 7★ → 8★
		[9] = 39063,     -- 8★ → 9★
		[10] = 97656,    -- 9★ → 10★
	},
}

-- ═══════════════════════════════════════════════════════════════════════════
-- ADAPTIVE ECOLOGY BALANCE
-- ═══════════════════════════════════════════════════════════════════════════

--[[
	ADAPTIVE ECOLOGY - MONSTER EVOLUTION SYSTEM
	
	Sistem ini membuat monster "belajar" dari player behavior.
	Jika 70%+ damage di floor tertentu adalah Physical → Monster gain Physical Resistance.
	
	Balance considerations:
	- Resistance cap 40% (agar tidak unfair)
	- Hybrid builds (50/50 Physical/Magic) tidak ter-counter
	- Adaptation berlaku per-floor, bukan global
]]
BalanceConfig.ADAPTIVE_ECOLOGY = {
	-- Damage type threshold untuk trigger adaptation
	DAMAGE_THRESHOLD = 0.7,         -- 70% dari 1 damage type
	
	-- Resistance yang diberikan saat adapt
	RESISTANCE_BONUS = {
		LIGHT_RESISTANCE = 0.15,    -- 15% resistance (minor adaptation)
		MEDIUM_RESISTANCE = 0.25,   -- 25% resistance (moderate)
		HEAVY_RESISTANCE = 0.40,    -- 40% resistance (hard counter)
	},
	
	-- Adaptation tiers (based on dominance %)
	ADAPTATION_TIERS = {
		[0.70] = "Light",           -- 70-79% dominance
		[0.80] = "Medium",          -- 80-89% dominance
		[0.90] = "Heavy",           -- 90%+ dominance (meta too stale)
	},
	
	-- Decay time (jika meta berubah, resistance hilang)
	RESISTANCE_DECAY_HOURS = 12,   -- 12 jam setelah meta berubah
	
	-- Analysis interval
	ANALYSIS_INTERVAL_HOURS = 6,   -- Analisa data tiap 6 jam
}

-- ═══════════════════════════════════════════════════════════════════════════
-- PARTY SYSTEM BALANCE (Future - Week 10)
-- ═══════════════════════════════════════════════════════════════════════════

BalanceConfig.PARTY_SYSTEM = {
	-- XP sharing
	PARTY_XP_MULTIPLIER = 0.8,      -- Each member gets 80% of solo XP
	PARTY_XP_BONUS = 0.1,           -- +10% total XP bonus untuk party (net 88% per person)
	
	-- Loot distribution
	LOOT_DISTRIBUTION_MODE = "RoundRobin", -- Round-robin by default
	
	-- Monster scaling untuk party
	PARTY_MONSTER_HP_SCALING = {
		[2] = 1.5,  -- 2 players = monsters have 150% HP
		[3] = 2.0,  -- 3 players = monsters have 200% HP
		[4] = 2.5,  -- 4 players = monsters have 250% HP
	},
}

-- ═══════════════════════════════════════════════════════════════════════════
-- PLAYTIME ESTIMATES (For Balancing Reference)
-- ═══════════════════════════════════════════════════════════════════════════

--[[
	TARGET PLAYTIME MILESTONES:
	
	These are design goals untuk player progression speed.
	Adjust BalanceConfig values untuk hit these targets saat playtesting.
	
	- Reach 3★ (casual player):  ~10 hours
	- Reach 5★ (dedicated player): ~50 hours
	- Reach 10★ (hardcore player): ~300 hours
	
	- Floor 10 (first boss): ~2 hours
	- Floor 50: ~50 hours
	- Floor 100: ~200 hours
	
	F2P Path:
	- Can reach 5★ in 1-2 months of daily play
	- Can reach 10★ in 6-12 months
	
	P2W Path:
	- Can reach 5★ in 1-2 weeks
	- Still need skill to clear high floors (money ≠ auto-win)
]]

-- ═══════════════════════════════════════════════════════════════════════════
-- EXPORT
-- ═══════════════════════════════════════════════════════════════════════════
-- boleh beneran?
return BalanceConfig