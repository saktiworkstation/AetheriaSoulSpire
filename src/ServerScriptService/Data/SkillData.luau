--[[
	SkillData.luau
	
	Centralized database untuk semua skill definitions di game.
	
	Setiap skill memiliki:
	- Base damage/effects
	- Cooldown (NO MANA - pure cooldown based)
	- Level scaling properties
	- Visual/audio references
	- Keybind slot compatibility
	
	SKILL ACQUISITION PHILOSOPHY:
	- Skills HARDER to get than character rarity (encourage farming)
	- Skill scrolls tradeable (future economy feature)
	- Skill level = exponential power (max level 10)
	
	Author: Bisa Bahasa Studio
	Created: 2025-01-03
	Last Modified: 2025-01-03
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Constants = require(ReplicatedStorage.Shared.Constants)
local BalanceConfig = require(ReplicatedStorage.Shared.BalanceConfig)

local SkillData = {}

-- ═══════════════════════════════════════════════════════════════════════════
-- SKILL DEFINITIONS
-- ═══════════════════════════════════════════════════════════════════════════

SkillData.Skills = {
	
	-- ═══════════════════════════════════════════════════════════════════════
	-- PHYSICAL SKILLS (STR-Based)
	-- ═══════════════════════════════════════════════════════════════════════
	
	HeavySlash = {
		-- Metadata
		ID = "HeavySlash",
		Name = "Heavy Slash",
		Description = "A powerful vertical sword strike that cleaves enemies.",
		
		-- Classification
		Rarity = Constants.SKILL_RARITY.COMMON,
		DamageType = Constants.DAMAGE_TYPES.PHYSICAL,
		ScalingStat = "STR", -- Primary scaling stat
		
		-- Slot compatibility
		CompatibleSlots = {
			Constants.SKILL_SLOTS.BASIC_ATTACK,
			Constants.SKILL_SLOTS.SKILL_1,
		},
		
		-- Base properties (Level 1)
		BaseDamage = 1.2, -- 120% of weapon damage
		BaseCooldown = 3, -- 3 seconds
		Range = 8, -- 8 studs (melee range)
		AOERadius = 0, -- Single target
		CastTime = 0.3, -- 0.3 second windup
		
		-- Scaling per level (calculated by FormulaCalculator)
		-- Level 10: 120% → 280% damage, 3s → 1.65s cooldown
		
		-- Effects
		Effects = {
			-- No special effects untuk Common skill
		},
		
		-- Visual/Audio
		Animation = "Skill_HeavySlash",
		VFX = "HeavySlash_Trail", -- Sword trail effect
		SFX = "SwordWhoosh_Heavy",
		HitSFX = "SwordHit_Metal",
		
		-- Acquisition
		DropSources = {
			"DustMite",
			"StoneGuard",
			"ThornWolf",
		},
		
		DesignNotes = "Starter skill. Simple, reliable damage. No complexity.",
	},
	
	Whirlwind = {
		ID = "Whirlwind",
		Name = "Whirlwind",
		Description = "Spin rapidly, damaging all nearby enemies. Can move while spinning.",
		
		Rarity = Constants.SKILL_RARITY.RARE,
		DamageType = Constants.DAMAGE_TYPES.PHYSICAL,
		ScalingStat = "STR",
		
		CompatibleSlots = {
			Constants.SKILL_SLOTS.SKILL_1,
			Constants.SKILL_SLOTS.SKILL_2,
		},
		
		BaseDamage = 0.5, -- 50% per tick (ticks 4 times = 200% total)
		BaseCooldown = 8,
		Range = 10, -- 10 studs radius
		AOERadius = 10,
		CastTime = 0,
		Duration = 2, -- Spins for 2 seconds
		TickRate = 0.5, -- Damage every 0.5 seconds (4 ticks total)
		
		Effects = {
			CanMoveWhileCasting = true,
			MovementSpeedMultiplier = 0.7, -- 70% movement speed while spinning
		},
		
		Animation = "Skill_Whirlwind",
		VFX = "Whirlwind_Spin",
		SFX = "Whirlwind_Swoosh",
		HitSFX = "Whirlwind_Hit",
		
		DropSources = {
			"StoneGuard",
			"ObsidianKnight",
			"Gargantua", -- Boss drop
		},
		
		DesignNotes = "AoE clear skill. Risk/reward: stay in melee range to maximize damage.",
	},
	
	FlashStep = {
		ID = "FlashStep",
		Name = "Flash Step",
		Description = "Dash instantly to cursor position and strike with a piercing thrust. Stuns hit enemy.",
		
		Rarity = Constants.SKILL_RARITY.EPIC,
		DamageType = Constants.DAMAGE_TYPES.PHYSICAL,
		ScalingStat = "STR",
		
		CompatibleSlots = {
			Constants.SKILL_SLOTS.SKILL_1,
			Constants.SKILL_SLOTS.SKILL_2,
		},
		
		BaseDamage = 2.0, -- 200% damage
		BaseCooldown = 12,
		Range = 30, -- Can dash up to 30 studs
		AOERadius = 0,
		CastTime = 0, -- Instant
		
		Effects = {
			Dash = {
				Type = "Teleport",
				MaxDistance = 30,
				TargetType = "Cursor", -- Dashes to cursor position
			},
			
			Stun = {
				Duration = 1.0, -- 1 second stun
				Target = "Hit", -- Only stuns hit enemy
			},
		},
		
		Animation = "Skill_FlashStep",
		VFX = "FlashStep_Trail",
		SFX = "FlashStep_Whoosh",
		HitSFX = "FlashStep_Impact",
		
		DropSources = {
			"ShadowArcher", -- Rare drop
			"Gargantua", -- Boss drop
		},
		
		DesignNotes = "Mobility + damage. Skill expression: use for gap close, damage, or escape. High cooldown = tactical choice.",
	},
	
	TitansWrath = {
		ID = "TitansWrath",
		Name = "Titan's Wrath",
		Description = "Leap into the air and crash down with devastating force. Massive AoE damage.",
		
		Rarity = Constants.SKILL_RARITY.LEGENDARY,
		DamageType = Constants.DAMAGE_TYPES.PHYSICAL,
		ScalingStat = "STR",
		
		CompatibleSlots = {
			Constants.SKILL_SLOTS.SKILL_2,
			Constants.SKILL_SLOTS.ULTIMATE,
		},
		
		BaseDamage = 4.0, -- 400% damage (Ultimate-tier)
		BaseCooldown = 25,
		Range = 40, -- Can leap up to 40 studs
		AOERadius = 20, -- 20 studs explosion radius
		CastTime = 0.5, -- 0.5s leap time (telegraphed)
		
		Effects = {
			Leap = {
				Type = "Jump",
				Height = 20, -- Leaps 20 studs up
				TargetType = "Cursor",
			},
			
			Knockback = {
				Distance = 15, -- Knocks enemies 15 studs away from impact
				Force = 100,
			},
			
			CameraShake = true, -- Screen shake on impact
		},
		
		Animation = "Skill_TitansWrath",
		VFX = "TitansWrath_Explosion",
		SFX = "TitansWrath_Impact",
		HitSFX = "TitansWrath_Thunder",
		
		DropSources = {
			"Gargantua", -- Boss-only drop (5% chance)
		},
		
		DesignNotes = "Ultimate skill. Feels POWERFUL. Long cooldown = save for big moments. Visual spectacle important.",
	},
	
	-- ═══════════════════════════════════════════════════════════════════════
	-- MAGICAL SKILLS (INT-Based)
	-- ═══════════════════════════════════════════════════════════════════════
	
	Fireball = {
		ID = "Fireball",
		Name = "Fireball",
		Description = "Launch a blazing fireball in a straight line. Explodes on contact.",
		
		Rarity = Constants.SKILL_RARITY.COMMON,
		DamageType = Constants.DAMAGE_TYPES.MAGIC,
		ScalingStat = "INT",
		
		CompatibleSlots = {
			Constants.SKILL_SLOTS.BASIC_ATTACK,
			Constants.SKILL_SLOTS.SKILL_1,
		},
		
		BaseDamage = 1.3, -- 130% magic damage
		BaseCooldown = 3,
		Range = 50, -- Projectile max range
		AOERadius = 5, -- Small explosion on hit
		CastTime = 0.4,
		
		Effects = {
			Projectile = {
				Speed = 60, -- Studs per second
				Type = "Homing", -- Slight homing (5 degrees max turn)
				HomingStrength = 0.2,
			},
		},
		
		Animation = "Skill_Fireball_Cast",
		VFX = "Fireball_Projectile",
		SFX = "Fireball_Cast",
		HitSFX = "Fireball_Explode",
		
		DropSources = {
			"Wisp",
			"SporeFungus",
		},
		
		DesignNotes = "Basic ranged skill. Teaches projectile mechanics. Slight homing helps new players.",
	},
	
	IceNova = {
		ID = "IceNova",
		Name = "Ice Nova",
		Description = "Unleash a burst of frost around you, freezing nearby enemies.",
		
		Rarity = Constants.SKILL_RARITY.RARE,
		DamageType = Constants.DAMAGE_TYPES.MAGIC,
		ScalingStat = "INT",
		
		CompatibleSlots = {
			Constants.SKILL_SLOTS.SKILL_1,
			Constants.SKILL_SLOTS.SKILL_2,
		},
		
		BaseDamage = 0.8, -- 80% damage (lower damage, utility focused)
		BaseCooldown = 10,
		Range = 0, -- Self-cast
		AOERadius = 15, -- 15 studs around player
		CastTime = 0.2,
		
		Effects = {
			Freeze = {
				Duration = 1.5, -- 1.5 second freeze
				SlowPercent = 1.0, -- 100% slow (completely frozen)
			},
			
			SelfKnockback = false, -- Player doesn't get knocked back
		},
		
		Animation = "Skill_IceNova",
		VFX = "IceNova_Burst",
		SFX = "IceNova_Shatter",
		HitSFX = "IceNova_Freeze",
		
		DropSources = {
			"Wisp",
			"ShadowArcher",
		},
		
		DesignNotes = "Defensive/CC skill. Low damage, high utility. Combo with AoE skills while enemies frozen.",
	},
	
	ThunderLance = {
		ID = "ThunderLance",
		Name = "Thunder Lance",
		Description = "Call down a lightning bolt on a single enemy. Deals TRUE damage.",
		
		Rarity = Constants.SKILL_RARITY.EPIC,
		DamageType = Constants.DAMAGE_TYPES.TRUE, -- Ignores defense!
		ScalingStat = "INT",
		
		CompatibleSlots = {
			Constants.SKILL_SLOTS.SKILL_2,
			Constants.SKILL_SLOTS.ULTIMATE,
		},
		
		BaseDamage = 2.5, -- 250% magic damage as TRUE damage
		BaseCooldown = 15,
		Range = 60, -- Long range
		AOERadius = 0, -- Single target
		CastTime = 0.8, -- Longer cast time (telegraphed)
		
		Effects = {
			TrueDamage = true, -- Bypasses all defense
			
			Lightning = {
				Type = "Instant",
				TargetType = "Enemy", -- Targets nearest enemy to cursor
			},
		},
		
		Animation = "Skill_ThunderLance",
		VFX = "ThunderLance_Strike",
		SFX = "ThunderLance_Crackle",
		HitSFX = "ThunderLance_Boom",
		
		DropSources = {
			"Wisp", -- Rare drop
			"Gargantua",
		},
		
		DesignNotes = "Tank buster. Counters high-defense enemies. Long cast = vulnerable. Risk/reward.",
	},
	
	VoidHole = {
		ID = "VoidHole",
		Name = "Void Hole",
		Description = "Summon a black hole that pulls enemies in, then explodes violently.",
		
		Rarity = Constants.SKILL_RARITY.LEGENDARY,
		DamageType = Constants.DAMAGE_TYPES.MAGIC,
		ScalingStat = "INT",
		
		CompatibleSlots = {
			Constants.SKILL_SLOTS.ULTIMATE,
		},
		
		BaseDamage = 5.0, -- 500% total damage (100% per tick + 200% explosion)
		BaseCooldown = 30,
		Range = 50,
		AOERadius = 25, -- Large AoE
		CastTime = 1.0, -- Long cast (interruptible)
		Duration = 3, -- Pulls for 3 seconds, then explodes
		
		Effects = {
			Pull = {
				Strength = 50, -- Pull force (studs per second toward center)
				Duration = 3,
			},
			
			Explosion = {
				Damage = 2.0, -- 200% damage on final explosion
				Radius = 25,
			},
			
			TickDamage = {
				Damage = 1.0, -- 100% per tick
				TickRate = 1.0, -- Every 1 second (3 ticks total)
			},
		},
		
		Animation = "Skill_VoidHole",
		VFX = "VoidHole_Sphere",
		SFX = "VoidHole_Suction",
		HitSFX = "VoidHole_Explosion",
		
		DropSources = {
			"Gargantua", -- Boss-only (5%)
		},
		
		DesignNotes = "Ultimate AoE skill. Wombo combo potential. Groups enemies for team. High risk (long cast).",
	},
	
	-- ═══════════════════════════════════════════════════════════════════════
	-- SUPPORT/SURVIVAL SKILLS (VIT/DEX-Based)
	-- ═══════════════════════════════════════════════════════════════════════
	
	IronSkin = {
		ID = "IronSkin",
		Name = "Iron Skin",
		Description = "Passive: Permanently increases Defense. No cooldown.",
		
		Rarity = Constants.SKILL_RARITY.COMMON,
		DamageType = nil, -- No damage type (support skill)
		ScalingStat = "VIT",
		
		CompatibleSlots = {
			Constants.SKILL_SLOTS.ULTIMATE, -- Passive slot
		},
		
		BaseDamage = 0, -- No damage
		BaseCooldown = 0, -- Passive (always active)
		Range = 0,
		AOERadius = 0,
		CastTime = 0,
		
		Effects = {
			Passive = true,
			
			DefenseBonus = {
				Flat = 15, -- +15 flat defense (scales with level)
				-- Level 10: +15 → +42 defense
			},
		},
		
		Animation = nil, -- No animation (passive)
		VFX = "IronSkin_Aura", -- Subtle metallic glow
		SFX = nil,
		HitSFX = nil,
		
		DropSources = {
			"StoneGuard",
			"ObsidianKnight",
		},
		
		DesignNotes = "Tank passive. Boring but effective. For players who want survivability over damage.",
	},
	
	LifestealAura = {
		ID = "LifestealAura",
		Name = "Lifesteal Aura",
		Description = "For 5 seconds, convert 20% of damage dealt into HP. Self-buff.",
		
		Rarity = Constants.SKILL_RARITY.RARE,
		DamageType = nil,
		ScalingStat = "VIT",
		
		CompatibleSlots = {
			Constants.SKILL_SLOTS.SKILL_2,
			Constants.SKILL_SLOTS.ULTIMATE,
		},
		
		BaseDamage = 0,
		BaseCooldown = 15,
		Range = 0, -- Self-cast
		AOERadius = 0,
		CastTime = 0.2,
		Duration = 5, -- 5 seconds
		
		Effects = {
			Lifesteal = {
				Percent = 0.2, -- 20% of damage becomes HP
				Duration = 5,
			},
			
			VisualBuff = "LifestealAura_Glow", -- Green glow around player
		},
		
		Animation = "Skill_LifestealAura",
		VFX = "LifestealAura_Cast",
		SFX = "LifestealAura_Activate",
		HitSFX = "LifestealAura_Heal", -- Sound when healing
		
		DropSources = {
			"ThornWolf",
			"Gargantua",
		},
		
		DesignNotes = "Sustain skill. Pairs well with high-attack-speed builds. Skill expression: activate before big damage burst.",
	},
	
	ShadowDash = {
		ID = "ShadowDash",
		Name = "Shadow Dash",
		Description = "Dash forward quickly, becoming briefly invulnerable. No damage dealt.",
		
		Rarity = Constants.SKILL_RARITY.EPIC,
		DamageType = nil,
		ScalingStat = "DEX",
		
		CompatibleSlots = {
			Constants.SKILL_SLOTS.SKILL_1,
			Constants.SKILL_SLOTS.SKILL_2,
		},
		
		BaseDamage = 0,
		BaseCooldown = 8,
		Range = 20, -- Dashes 20 studs
		AOERadius = 0,
		CastTime = 0,
		
		Effects = {
			Dash = {
				Distance = 20,
				Speed = 100, -- Very fast dash
				Direction = "Forward", -- Dashes in movement direction
			},
			
			Invulnerability = {
				Duration = 0.5, -- 0.5 seconds i-frames
			},
		},
		
		Animation = "Skill_ShadowDash",
		VFX = "ShadowDash_Trail",
		SFX = "ShadowDash_Whoosh",
		HitSFX = nil,
		
		DropSources = {
			"ShadowArcher",
			"ThornWolf",
		},
		
		DesignNotes = "Pure mobility/survival. For skilled players (dodge boss attacks). No damage = trade-off.",
	},
	
	WindWalker = {
		ID = "WindWalker",
		Name = "Wind Walker",
		Description = "Passive: Permanently increases Movement Speed and Attack Speed.",
		
		Rarity = Constants.SKILL_RARITY.RARE,
		DamageType = nil,
		ScalingStat = "DEX",
		
		CompatibleSlots = {
			Constants.SKILL_SLOTS.ULTIMATE, -- Passive slot
		},
		
		BaseDamage = 0,
		BaseCooldown = 0, -- Passive
		Range = 0,
		AOERadius = 0,
		CastTime = 0,
		
		Effects = {
			Passive = true,
			
			MovementSpeedBonus = {
				Flat = 4, -- +4 studs/sec (scales with level)
				-- Level 10: +4 → +11.2 studs/sec
			},
			
			AttackSpeedBonus = {
				Percent = 0.15, -- +15% attack speed
				-- Level 10: +15% → +42% attack speed
			},
		},
		
		Animation = nil,
		VFX = "WindWalker_Aura", -- Wind particles around feet
		SFX = nil,
		HitSFX = nil,
		
		DropSources = {
			"ShadowArcher",
			"DustMite",
		},
		
		DesignNotes = "Speed passive. For kiting/chasing builds. Pairs with fast attack skills.",
	},
}

-- ═══════════════════════════════════════════════════════════════════════════
-- SKILL COLLECTIONS (Pre-made loadouts untuk inspiration)
-- ═══════════════════════════════════════════════════════════════════════════

SkillData.LoadoutPresets = {
	Berserker = {
		Name = "Berserker",
		Description = "High-damage melee build. All-in aggression.",
		Skills = {
			BasicAttack = "HeavySlash",
			Skill1 = "Whirlwind",
			Skill2 = "FlashStep",
			Ultimate = "TitansWrath",
		},
		RecommendedStats = {STR = 70, VIT = 20, DEX = 10},
	},
	
	Mage = {
		Name = "Battlemage",
		Description = "Ranged magic damage with crowd control.",
		Skills = {
			BasicAttack = "Fireball",
			Skill1 = "IceNova",
			Skill2 = "ThunderLance",
			Ultimate = "VoidHole",
		},
		RecommendedStats = {INT = 80, VIT = 15, DEX = 5},
	},
	
	Tank = {
		Name = "Immortal",
		Description = "Maximum survivability. Outlast enemies.",
		Skills = {
			BasicAttack = "HeavySlash",
			Skill1 = "Whirlwind",
			Skill2 = "LifestealAura",
			Ultimate = "IronSkin",
		},
		RecommendedStats = {VIT = 60, STR = 30, DEX = 10},
	},
	
	Speedster = {
		Name = "Shadow Dancer",
		Description = "High mobility, high skill ceiling. Dodge everything.",
		Skills = {
			BasicAttack = "HeavySlash",
			Skill1 = "ShadowDash",
			Skill2 = "FlashStep",
			Ultimate = "WindWalker",
		},
		RecommendedStats = {DEX = 50, STR = 40, VIT = 10},
	},
}

-- ═══════════════════════════════════════════════════════════════════════════
-- HELPER FUNCTIONS
-- ═══════════════════════════════════════════════════════════════════════════

--[[
	Get skill data by ID
	
	@param skillID string
	@return table - Skill data or nil
]]
function SkillData.GetSkillData(skillID)
	return SkillData.Skills[skillID]
end

--[[
	Get all skills by rarity
	
	@param rarity number (1-4)
	@return table - Array of skill IDs
]]
function SkillData.GetSkillsByRarity(rarity)
	local skills = {}
	
	for skillID, data in pairs(SkillData.Skills) do
		if data.Rarity == rarity then
			table.insert(skills, skillID)
		end
	end
	
	return skills
end

--[[
	Get all skills by damage type
	
	@param damageType string ("Physical", "Magic", "True", or nil for support)
	@return table - Array of skill IDs
]]
function SkillData.GetSkillsByDamageType(damageType)
	local skills = {}
	
	for skillID, data in pairs(SkillData.Skills) do
		if data.DamageType == damageType then
			table.insert(skills, skillID)
		end
	end
	
	return skills
end

--[[
	Check if skill compatible dengan slot tertentu
	
	@param skillID string
	@param slot string (e.g., "Q", "E", "R")
	@return boolean
]]
function SkillData.IsSkillCompatibleWithSlot(skillID, slot)
	local skillData = SkillData.Skills[skillID]
	
	if not skillData then
		return false
	end
	
	for _, compatibleSlot in ipairs(skillData.CompatibleSlots) do
		if compatibleSlot == slot then
			return true
		end
	end
	
	return false
end

--[[
	Get random skill drop dari monster
	
	Uses drop rates dari BalanceConfig
	
	@param monsterType string - Monster archetype
	@return string - Skill ID or nil (if no drop)
]]
function SkillData.RollSkillDrop(monsterType)
	local dropRates = BalanceConfig.SKILL_DROP_RATES[monsterType]
	
	if not dropRates then
		return nil
	end
	
	-- Roll rarity tier first
	local roll = math.random()
	local cumulativeChance = 0
	local droppedRarity = nil
	
	for _, rarityName in ipairs({"Legendary", "Epic", "Rare", "Common"}) do
		cumulativeChance = cumulativeChance + dropRates[rarityName]
		
		if roll <= cumulativeChance then
			-- Map name to constant
			local rarityMap = {
				Common = Constants.SKILL_RARITY.COMMON,
				Rare = Constants.SKILL_RARITY.RARE,
				Epic = Constants.SKILL_RARITY.EPIC,
				Legendary = Constants.SKILL_RARITY.LEGENDARY,
			}
			droppedRarity = rarityMap[rarityName]
			break
		end
	end
	
	if not droppedRarity then
		return nil -- No drop
	end
	
	-- Get skills of that rarity
	local skillsOfRarity = SkillData.GetSkillsByRarity(droppedRarity)
	
	if #skillsOfRarity == 0 then
		return nil
	end
	
	-- Random skill from that rarity
	local randomSkill = skillsOfRarity[math.random(1, #skillsOfRarity)]
	
	return randomSkill
end

--[[
	Calculate skill's effective stats at specific level
	
	Uses FormulaCalculator untuk scaling
	
	@param skillID string
	@param skillLevel number (1-10)
	@param playerStats table - Player's final stats
	@return table - {Damage, Cooldown, etc.}
]]
function SkillData.GetSkillStatsAtLevel(skillID, skillLevel, playerStats)
	local skillData = SkillData.Skills[skillID]
	
	if not skillData then
		return nil
	end
	
	local FormulaCalculator = require(ReplicatedStorage.Shared.FormulaCalculator)
	
	-- Get player's relevant damage stat
	local playerDamage = 0
	if skillData.ScalingStat == "STR" then
		playerDamage = playerStats.PhysicalDamage or 0
	elseif skillData.ScalingStat == "INT" then
		playerDamage = playerStats.MagicDamage or 0
	end
	
	-- Calculate scaled damage
	local scaledDamage = FormulaCalculator.CalculateSkillDamage(
		skillData.BaseDamage,
		skillLevel,
		playerDamage
	)
	
	-- Calculate scaled cooldown
	local scaledCooldown = FormulaCalculator.CalculateSkillCooldown(
		skillData.BaseCooldown,
		skillLevel
	)
	
	return {
		Damage = scaledDamage,
		Cooldown = scaledCooldown,
		Range = skillData.Range,
		AOERadius = skillData.AOERadius,
		CastTime = skillData.CastTime,
		Duration = skillData.Duration,
	}
end

--[[
	Get skill's evolution tier (for visual upgrades)
	
	@param skillLevel number
	@return string - "Base", "Enhanced", or "Perfected"
]]
function SkillData.GetSkillEvolution(skillLevel)
	if skillLevel >= 10 then
		return "Perfected"
	elseif skillLevel >= 5 then
		return "Enhanced"
	else
		return "Base"
	end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- EXPORT
-- ═══════════════════════════════════════════════════════════════════════════

return SkillData