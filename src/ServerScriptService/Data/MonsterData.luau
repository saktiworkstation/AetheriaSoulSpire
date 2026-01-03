--[[
	MonsterData.luau
	
	Centralized database untuk semua monster definitions di game.
	
	Setiap monster memiliki:
	- Base stats (akan di-scale oleh FormulaCalculator)
	- AI behavior patterns
	- Loot tables
	- Visual/audio references
	
	DESIGN PHILOSOPHY:
	- Data-driven (easy untuk add new monsters tanpa code changes)
	- Modular (monster bisa share behaviors)
	- Balanced (stats calculated based on archetype + floor)
	
	Author: Bisa Bahasa Studio
	Created: 2025-01-03
	Last Modified: 2025-01-03
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Constants = require(ReplicatedStorage.Shared.Constants)
local BalanceConfig = require(ReplicatedStorage.Shared.BalanceConfig)

local MonsterData = {}

-- ═══════════════════════════════════════════════════════════════════════════
-- MONSTER BEHAVIOR PATTERNS
-- ═══════════════════════════════════════════════════════════════════════════

--[[
	AI Behavior presets yang bisa di-assign ke monsters
	
	Behaviors define bagaimana monster bertindak in combat
]]
MonsterData.Behaviors = {
	-- Aggressive: Always chase player, never retreat
	Aggressive = {
		AggroRange = 50,
		DeaggroRange = 80,
		ChaseSpeed = 1.0,
		AttackRange = 5,
		AttackCooldown = 2.0,
		RetreatAtHP = 0, -- Never retreat
		PreferredTarget = "Nearest", -- "Nearest", "Weakest", "Strongest"
	},
	
	-- Defensive: Patrols area, chases if provoked
	Defensive = {
		AggroRange = 30,
		DeaggroRange = 60,
		ChaseSpeed = 0.8,
		AttackRange = 5,
		AttackCooldown = 2.5,
		RetreatAtHP = 0.2, -- Retreat at 20% HP
		PreferredTarget = "Nearest",
	},
	
	-- Ranged: Keeps distance, attacks from afar
	Ranged = {
		AggroRange = 60,
		DeaggroRange = 100,
		ChaseSpeed = 1.0,
		AttackRange = 30, -- Long range
		AttackCooldown = 3.0,
		RetreatAtHP = 0, -- Never retreat
		PreferredTarget = "Farthest", -- Prioritize distant targets
		KeepDistance = 25, -- Try to maintain 25 studs away
	},
	
	-- Swarm: Weak alone, dangerous in groups
	Swarm = {
		AggroRange = 40,
		DeaggroRange = 70,
		ChaseSpeed = 1.5, -- Fast
		AttackRange = 4,
		AttackCooldown = 1.5, -- Attacks quickly
		RetreatAtHP = 0,
		PreferredTarget = "Nearest",
		SwarmBonus = true, -- Deal +10% damage per nearby ally
	},
	
	-- Boss: Complex behavior with phases
	Boss = {
		AggroRange = 100,
		DeaggroRange = 150,
		ChaseSpeed = 0.8,
		AttackRange = 10,
		AttackCooldown = 4.0,
		RetreatAtHP = 0, -- Bosses never retreat
		PreferredTarget = "HighestThreat",
		HasPhases = true,
	},
}

-- ═══════════════════════════════════════════════════════════════════════════
-- LOOT TABLE TEMPLATES
-- ═══════════════════════════════════════════════════════════════════════════

MonsterData.LootTables = {
	-- Common mobs (Floors 1-10)
	Common = {
		Gold = {Min = 5, Max = 15},
		SkillScrollChance = 0.05, -- 5% untuk Common skill
		EquipmentChance = 0.1,    -- 10% untuk equipment
		MaterialDrops = {
			-- Future feature
		},
	},
	
	-- Elite mobs
	Elite = {
		Gold = {Min = 50, Max = 100},
		SkillScrollChance = 0.2,
		EquipmentChance = 0.3,
		GuaranteedDrops = 1, -- Always drop at least 1 item
	},
	
	-- Boss loot
	Boss = {
		Gold = {Min = 500, Max = 1000},
		SkillScrollChance = 0.5, -- 50% untuk Rare+ skill
		EquipmentChance = 0.8,
		GuaranteedDrops = 3, -- Always drop 3+ items
		UniqueDrops = true,  -- Bisa drop boss-exclusive items
	},
}

-- ═══════════════════════════════════════════════════════════════════════════
-- MONSTER DEFINITIONS - FLOORS 1-10 (The Crumbling Ruins)
-- ═══════════════════════════════════════════════════════════════════════════

MonsterData.Monsters = {
	
	-- ═══════════════════════════════════════════════════════════════════════
	-- FLOOR 1-3: The Crumbling Ruins
	-- ═══════════════════════════════════════════════════════════════════════
	
	DustMite = {
		-- Metadata
		ID = "DustMite",
		Name = "Dust Mite",
		Description = "Tiny insect corrupted by the Void. Weak but fast.",
		
		-- Classification
		Type = Constants.MONSTER_TYPES.MINION,
		Tier = 1, -- Floor tier (1 = Floor 1-10)
		
		-- AI Behavior
		Behavior = "Swarm",
		
		-- Loot
		LootTable = "Common",
		
		-- Visual/Audio (references to assets)
		Model = "DustMiteModel", -- Name di ReplicatedStorage.Assets.MonsterModels
		AttackAnimation = "DustMite_Attack",
		DeathAnimation = "DustMite_Death",
		AttackSound = "DustMite_Screech",
		DeathSound = "DustMite_Squish",
		
		-- Spawn settings
		SpawnWeight = 50, -- Higher = more common (relative to other monsters)
		MinFloor = 1,
		MaxFloor = 5,
		
		-- Special abilities (optional)
		Abilities = {
			-- None untuk basic monster
		},
		
		-- Notes untuk designers
		DesignNotes = "Entry-level enemy. Introduces basic combat. Dies in 1-2 hits.",
	},
	
	StoneGuard = {
		ID = "StoneGuard",
		Name = "Stone Guard",
		Description = "Animated golem made of crumbling stone. Slow but durable.",
		
		Type = Constants.MONSTER_TYPES.TANK,
		Tier = 1,
		
		Behavior = "Defensive",
		LootTable = "Common",
		
		Model = "StoneGuardModel",
		AttackAnimation = "StoneGuard_Slam",
		DeathAnimation = "StoneGuard_Crumble",
		AttackSound = "StoneGuard_Slam",
		DeathSound = "StoneGuard_Break",
		
		SpawnWeight = 30,
		MinFloor = 1,
		MaxFloor = 6,
		
		Abilities = {
			-- Basic shield bash (stuns player for 0.5s)
			ShieldBash = {
				Type = "Stun",
				Duration = 0.5,
				Cooldown = 10,
			},
		},
		
		DesignNotes = "Tank archetype. Teaches players to kite and avoid direct trades.",
	},
	
	Wisp = {
		ID = "Wisp",
		Name = "Void Wisp",
		Description = "Floating spirit that fires void energy bolts.",
		
		Type = Constants.MONSTER_TYPES.RANGED,
		Tier = 1,
		
		Behavior = "Ranged",
		LootTable = "Common",
		
		Model = "WispModel",
		AttackAnimation = "Wisp_Shoot",
		DeathAnimation = "Wisp_Dissipate",
		AttackSound = "Wisp_LaserShoot",
		DeathSound = "Wisp_Vanish",
		
		SpawnWeight = 25,
		MinFloor = 2,
		MaxFloor = 7,
		
		Abilities = {
			VoidBolt = {
				Type = "Projectile",
				Damage = 1.0, -- Multiplier on base damage
				Speed = 50, -- Studs per second
				Range = 40,
				Cooldown = 3,
			},
		},
		
		DesignNotes = "Ranged enemy. Teaches importance of dodging projectiles.",
	},
	
	-- ═══════════════════════════════════════════════════════════════════════
	-- FLOOR 4-6: The Overgrown Garden
	-- ═══════════════════════════════════════════════════════════════════════
	
	ThornWolf = {
		ID = "ThornWolf",
		Name = "Thorn Wolf",
		Description = "Feral beast covered in thorny vines. Applies bleeding.",
		
		Type = Constants.MONSTER_TYPES.MINION,
		Tier = 1,
		
		Behavior = "Aggressive",
		LootTable = "Common",
		
		Model = "ThornWolfModel",
		AttackAnimation = "ThornWolf_Bite",
		DeathAnimation = "ThornWolf_Collapse",
		AttackSound = "ThornWolf_Growl",
		DeathSound = "ThornWolf_Whimper",
		
		SpawnWeight = 40,
		MinFloor = 4,
		MaxFloor = 10,
		
		Abilities = {
			BleedingBite = {
				Type = "StatusEffect",
				Effect = "Bleed",
				Damage = 5, -- 5 damage per second
				Duration = 3, -- 3 seconds
				Cooldown = 8,
			},
		},
		
		DesignNotes = "Introduces DoT (Damage over Time) mechanics. Players learn to manage status effects.",
	},
	
	SporeFungus = {
		ID = "SporeFungus",
		Name = "Spore Fungus",
		Description = "Stationary mushroom that releases toxic spores in an area.",
		
		Type = Constants.MONSTER_TYPES.RANGED,
		Tier = 1,
		
		Behavior = "Defensive",
		LootTable = "Common",
		
		Model = "SporeFungusModel",
		AttackAnimation = "SporeFungus_Release",
		DeathAnimation = "SporeFungus_Wither",
		AttackSound = "SporeFungus_Hiss",
		DeathSound = "SporeFungus_Pop",
		
		SpawnWeight = 20,
		MinFloor = 5,
		MaxFloor = 10,
		
		Abilities = {
			ToxicCloud = {
				Type = "AoE",
				Radius = 15, -- 15 studs
				Damage = 0.5, -- Multiplier (DoT)
				Duration = 5, -- Cloud lasts 5 seconds
				TickRate = 0.5, -- Damage every 0.5 seconds
				Cooldown = 10,
			},
		},
		
		DesignNotes = "Area denial enemy. Teaches positioning and avoiding danger zones.",
	},
	
	-- ═══════════════════════════════════════════════════════════════════════
	-- FLOOR 7-9: The Obsidian Halls
	-- ═══════════════════════════════════════════════════════════════════════
	
	ObsidianKnight = {
		ID = "ObsidianKnight",
		Name = "Obsidian Knight",
		Description = "Armored warrior with a shield that must be broken first.",
		
		Type = Constants.MONSTER_TYPES.TANK,
		Tier = 1,
		
		Behavior = "Defensive",
		LootTable = "Common",
		
		Model = "ObsidianKnightModel",
		AttackAnimation = "ObsidianKnight_Slash",
		DeathAnimation = "ObsidianKnight_Shatter",
		AttackSound = "ObsidianKnight_Clang",
		DeathSound = "ObsidianKnight_Break",
		
		SpawnWeight = 25,
		MinFloor = 7,
		MaxFloor = 10,
		
		Abilities = {
			Shield = {
				Type = "Barrier",
				HP = 50, -- Shield has 50 HP (must break before damaging knight)
				Regenerates = false,
			},
			
			ShieldBash = {
				Type = "Knockback",
				Distance = 10, -- Knocks player back 10 studs
				Cooldown = 12,
			},
		},
		
		DesignNotes = "Mechanic tutorial: break shield first. Teaches target prioritization.",
	},
	
	ShadowArcher = {
		ID = "ShadowArcher",
		Name = "Shadow Archer",
		Description = "Stealthy archer that flees when approached.",
		
		Type = Constants.MONSTER_TYPES.RANGED,
		Tier = 1,
		
		Behavior = "Ranged",
		LootTable = "Common",
		
		Model = "ShadowArcherModel",
		AttackAnimation = "ShadowArcher_Shoot",
		DeathAnimation = "ShadowArcher_Fade",
		AttackSound = "ShadowArcher_BowRelease",
		DeathSound = "ShadowArcher_Whisper",
		
		SpawnWeight = 20,
		MinFloor = 8,
		MaxFloor = 10,
		
		Abilities = {
			RapidShot = {
				Type = "Projectile",
				Damage = 1.2, -- Higher damage than Wisp
				Speed = 80, -- Faster projectile
				Range = 50,
				Cooldown = 2.5,
			},
			
			ShadowStep = {
				Type = "Teleport",
				Distance = 20, -- Teleports 20 studs away if player gets close
				Cooldown = 8,
				TriggerRange = 10, -- Triggers if player within 10 studs
			},
		},
		
		DesignNotes = "Kiting enemy. Frustrating if player has no gap-closers. Rewards mobility.",
	},
	
	-- ═══════════════════════════════════════════════════════════════════════
	-- FLOOR 10: BOSS - Gargantua, The Gatekeeper
	-- ═══════════════════════════════════════════════════════════════════════
	
	Gargantua = {
		ID = "Gargantua",
		Name = "Gargantua, The Gatekeeper",
		Description = "Massive golem guardian. The first true test for climbers.",
		
		Type = Constants.MONSTER_TYPES.BOSS,
		Tier = 1,
		
		Behavior = "Boss",
		LootTable = "Boss",
		
		Model = "GargantuaModel",
		AttackAnimation = "Gargantua_Slam",
		DeathAnimation = "Gargantua_Collapse",
		AttackSound = "Gargantua_Roar",
		DeathSound = "Gargantua_Explode",
		
		SpawnWeight = 0, -- Bosses don't spawn randomly
		MinFloor = 10,
		MaxFloor = 10,
		
		-- Boss Phases
		Phases = {
			Phase1 = {
				HPRange = {100, 50}, -- 100% to 50% HP
				Abilities = {"GroundSlam", "ShockwaveWalk"},
			},
			
			Phase2 = {
				HPRange = {50, 0}, -- 50% to 0% HP
				Abilities = {"GroundSlam", "ShockwaveWalk", "LaserSpin"},
				EnrageMultiplier = 1.3, -- 30% faster/stronger attacks
			},
		},
		
		Abilities = {
			GroundSlam = {
				Type = "AoE",
				Damage = 2.0, -- 200% base damage
				Radius = 20,
				Windup = 1.5, -- 1.5 second telegraph (player can dodge)
				Cooldown = 8,
				Visual = "Gargantua_SlamIndicator", -- Red circle on ground
			},
			
			ShockwaveWalk = {
				Type = "Projectile",
				Damage = 1.5,
				Speed = 30,
				Range = 40,
				Cooldown = 10,
				Description = "Stomps ground, sending shockwave that must be jumped over",
			},
			
			LaserSpin = {
				Type = "Beam",
				Damage = 1.0, -- 100% per tick
				Duration = 4, -- Spins for 4 seconds
				TickRate = 0.2, -- Damage every 0.2 seconds if touching beam
				Cooldown = 20,
				Phase = 2, -- Only in Phase 2
				Visual = "Gargantua_LaserBeam",
			},
		},
		
		-- Special drops
		GuaranteedDrops = {
			"GatekeeperKey", -- Unlocks Floor 11
		},
		
		DesignNotes = [[
			First major boss fight. Teaches:
			- Dodge telegraphed attacks (GroundSlam indicator)
			- Jump over hazards (Shockwave)
			- Phase transitions (enrage at 50%)
			- Movement during beam attack
			
			Should take 3-5 minutes for appropriately-leveled player.
			Difficulty spike to make victory feel earned.
		]],
	},
}

-- ═══════════════════════════════════════════════════════════════════════════
-- ELITE VARIANTS (Auto-generated stronger versions)
-- ═══════════════════════════════════════════════════════════════════════════

--[[
	Generate Elite version dari monster biasa
	
	Elite monsters:
	- 3x HP
	- 1.5x Damage
	- Glowing visual effect
	- Better loot
	- Rare spawn (5% chance)
]]
function MonsterData.GenerateEliteVariant(baseMonsterID)
	local baseMon = MonsterData.Monsters[baseMonsterID]
	
	if not baseMon or baseMon.Type == Constants.MONSTER_TYPES.BOSS then
		return nil -- Can't make Elite boss
	end
	
	local elite = {}
	
	-- Copy base monster data
	for key, value in pairs(baseMon) do
		if type(value) == "table" then
			elite[key] = {}
			for k, v in pairs(value) do
				elite[key][k] = v
			end
		else
			elite[key] = value
		end
	end
	
	-- Modify untuk Elite
	elite.ID = baseMonsterID .. "_Elite"
	elite.Name = "Elite " .. baseMon.Name
	elite.Type = Constants.MONSTER_TYPES.ELITE
	elite.LootTable = "Elite"
	elite.SpawnWeight = baseMon.SpawnWeight * 0.05 -- 5% spawn rate
	
	-- Visual indicator (gold glow)
	elite.VisualEffect = "EliteGlow"
	
	return elite
end

-- ═══════════════════════════════════════════════════════════════════════════
-- HELPER FUNCTIONS
-- ═══════════════════════════════════════════════════════════════════════════

--[[
	Get all monsters that can spawn pada floor tertentu
	
	@param floorNumber number
	@return table - Array of monster IDs
]]
function MonsterData.GetMonstersForFloor(floorNumber)
	local validMonsters = {}
	
	for monsterID, data in pairs(MonsterData.Monsters) do
		if floorNumber >= data.MinFloor and floorNumber <= data.MaxFloor then
			table.insert(validMonsters, monsterID)
		end
	end
	
	return validMonsters
end

--[[
	Get weighted random monster untuk floor
	
	Monsters dengan SpawnWeight lebih tinggi lebih sering muncul.
	
	@param floorNumber number
	@param excludeBosses boolean - Exclude boss monsters
	@return string - Monster ID
]]
function MonsterData.GetRandomMonsterForFloor(floorNumber, excludeBosses)
	local validMonsters = {}
	local totalWeight = 0
	
	for monsterID, data in pairs(MonsterData.Monsters) do
		-- Check floor range
		if floorNumber >= data.MinFloor and floorNumber <= data.MaxFloor then
			-- Check boss exclusion
			if not excludeBosses or data.Type ~= Constants.MONSTER_TYPES.BOSS then
				table.insert(validMonsters, {ID = monsterID, Weight = data.SpawnWeight})
				totalWeight = totalWeight + data.SpawnWeight
			end
		end
	end
	
	if #validMonsters == 0 then
		warn("No valid monsters for floor", floorNumber)
		return nil
	end
	
	-- Weighted random selection
	local roll = math.random() * totalWeight
	local cumulative = 0
	
	for _, monster in ipairs(validMonsters) do
		cumulative = cumulative + monster.Weight
		if roll <= cumulative then
			return monster.ID
		end
	end
	
	-- Fallback
	return validMonsters[1].ID
end

--[[
	Get monster data by ID
	
	@param monsterID string
	@return table - Monster data atau nil
]]
function MonsterData.GetMonsterData(monsterID)
	return MonsterData.Monsters[monsterID]
end

--[[
	Get boss untuk floor tertentu
	
	@param floorNumber number
	@return string - Boss ID atau nil
]]
function MonsterData.GetBossForFloor(floorNumber)
	for monsterID, data in pairs(MonsterData.Monsters) do
		if data.Type == Constants.MONSTER_TYPES.BOSS and 
		   floorNumber >= data.MinFloor and 
		   floorNumber <= data.MaxFloor then
			return monsterID
		end
	end
	
	return nil
end

--[[
	Check jika floor adalah boss floor
	
	@param floorNumber number
	@return boolean
]]
function MonsterData.IsBossFloor(floorNumber)
	return floorNumber % Constants.BOSS_FLOOR_INTERVAL == 0
end

-- ═══════════════════════════════════════════════════════════════════════════
-- EXPORT
-- ═══════════════════════════════════════════════════════════════════════════

return MonsterData