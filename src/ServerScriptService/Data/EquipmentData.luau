--[[
	EquipmentData.luau
	
	Centralized database untuk semua equipment definitions di game.
	
	EQUIPMENT PHILOSOPHY (UNIQUE DESIGN):
	- Rarity affects DURABILITY ONLY, NOT stats
	- Stats are FLAT bonuses (no percentage scaling)
	- Tier determines stat power (Tier 1-5)
	- All equipment can break (durability system)
	
	This design REDUCES pay-to-win:
	- Low rarity equipment = same stats, just breaks faster
	- High rarity equipment = more durable, less repair costs
	- Skill > Gear rarity
	
	Author: Bisa Bahasa Studio
	Created: 2025-01-03
	Last Modified: 2025-01-03
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Constants = require(ReplicatedStorage.Shared.Constants)
local BalanceConfig = require(ReplicatedStorage.Shared.BalanceConfig)

local EquipmentData = {}

-- ═══════════════════════════════════════════════════════════════════════════
-- EQUIPMENT TEMPLATES BY TIER
-- ═══════════════════════════════════════════════════════════════════════════

--[[
	Equipment Stats Reference (from BalanceConfig):
	
	WEAPON TIERS:
	T1: +5 Damage, +2% Crit
	T2: +12 Damage, +4% Crit
	T3: +25 Damage, +6% Crit
	T4: +50 Damage, +8% Crit
	T5: +100 Damage, +10% Crit
	
	ARMOR TIERS:
	T1: +20 HP, +5 Defense
	T2: +50 HP, +12 Defense
	T3: +100 HP, +25 Defense
	T4: +200 HP, +50 Defense
	T5: +400 HP, +100 Defense
	
	ACCESSORY TIERS:
	T1: +10 HP, +3 Damage, +10% Crit Damage
	T2: +25 HP, +7 Damage, +15% Crit Damage
	T3: +50 HP, +15 Damage, +20% Crit Damage
	T4: +100 HP, +30 Damage, +25% Crit Damage
	T5: +200 HP, +60 Damage, +30% Crit Damage
]]

-- ═══════════════════════════════════════════════════════════════════════════
-- WEAPON DEFINITIONS
-- ═══════════════════════════════════════════════════════════════════════════

EquipmentData.Weapons = {
	
	-- ═══════════════════════════════════════════════════════════════════════
	-- TIER 1 WEAPONS (Floors 1-10)
	-- ═══════════════════════════════════════════════════════════════════════
	
	RustySword_T1 = {
		-- Metadata
		ID = "RustySword_T1",
		Name = "Rusty Sword",
		Description = "An old, worn blade. It's seen better days, but it still cuts.",
		
		-- Classification
		Slot = Constants.EQUIPMENT_SLOTS.WEAPON,
		Tier = 1,
		ItemLevel = 1, -- Minimum player level to equip
		
		-- Stats (FLAT - same for all rarities)
		Stats = {
			PhysicalDamage = 5,
			CritRate = 0.02, -- +2%
		},
		
		-- Visual/Model
		Model = "RustySword_Model",
		EquipAnimation = "Sword_Equip",
		AttackAnimation = "Sword_Swing",
		
		-- Rarity variations (only affects durability & repair cost)
		CanDropAsRarity = {
			[Constants.EQUIPMENT_RARITY.COMMON] = true,
			[Constants.EQUIPMENT_RARITY.RARE] = true,
		},
		
		-- Drop sources
		DropSources = {
			Floors = {1, 2, 3, 4, 5},
			Monsters = {"DustMite", "StoneGuard", "ThornWolf"},
		},
		
		DesignNotes = "Starter weapon. Common drop. Players will replace quickly.",
	},
	
	IronSword_T1 = {
		ID = "IronSword_T1",
		Name = "Iron Sword",
		Description = "A standard iron blade. Reliable and sturdy.",
		
		Slot = Constants.EQUIPMENT_SLOTS.WEAPON,
		Tier = 1,
		ItemLevel = 3,
		
		Stats = {
			PhysicalDamage = 5,
			CritRate = 0.02,
		},
		
		Model = "IronSword_Model",
		EquipAnimation = "Sword_Equip",
		AttackAnimation = "Sword_Swing",
		
		CanDropAsRarity = {
			[Constants.EQUIPMENT_RARITY.COMMON] = true,
			[Constants.EQUIPMENT_RARITY.RARE] = true,
			[Constants.EQUIPMENT_RARITY.EPIC] = true,
		},
		
		DropSources = {
			Floors = {3, 4, 5, 6, 7},
			Monsters = {"StoneGuard", "ThornWolf", "ObsidianKnight"},
		},
		
		DesignNotes = "Mid-tier 1 weapon. Better model, same stats as Rusty Sword.",
	},
	
	MagicStaff_T1 = {
		ID = "MagicStaff_T1",
		Name = "Apprentice Staff",
		Description = "A simple wooden staff imbued with basic magic.",
		
		Slot = Constants.EQUIPMENT_SLOTS.WEAPON,
		Tier = 1,
		ItemLevel = 1,
		
		Stats = {
			MagicDamage = 5, -- Magic weapon variant
			CritRate = 0.02,
		},
		
		Model = "ApprenticeStaff_Model",
		EquipAnimation = "Staff_Equip",
		AttackAnimation = "Staff_Cast",
		
		CanDropAsRarity = {
			[Constants.EQUIPMENT_RARITY.COMMON] = true,
			[Constants.EQUIPMENT_RARITY.RARE] = true,
		},
		
		DropSources = {
			Floors = {1, 2, 3, 4, 5},
			Monsters = {"Wisp", "SporeFungus"},
		},
		
		DesignNotes = "Magic weapon for INT builds. Same power as physical weapons.",
	},
	
	-- ═══════════════════════════════════════════════════════════════════════
	-- TIER 2 WEAPONS (Floors 11-20)
	-- ═══════════════════════════════════════════════════════════════════════
	
	SteelGreatsword_T2 = {
		ID = "SteelGreatsword_T2",
		Name = "Steel Greatsword",
		Description = "A massive two-handed blade forged from quality steel.",
		
		Slot = Constants.EQUIPMENT_SLOTS.WEAPON,
		Tier = 2,
		ItemLevel = 15,
		
		Stats = {
			PhysicalDamage = 12,
			CritRate = 0.04,
		},
		
		Model = "SteelGreatsword_Model",
		EquipAnimation = "Greatsword_Equip",
		AttackAnimation = "Greatsword_Slam",
		
		CanDropAsRarity = {
			[Constants.EQUIPMENT_RARITY.RARE] = true,
			[Constants.EQUIPMENT_RARITY.EPIC] = true,
			[Constants.EQUIPMENT_RARITY.LEGENDARY] = true,
		},
		
		DropSources = {
			Floors = {11, 12, 13, 14, 15},
			Monsters = {}, -- Future Floor 11-20 monsters
		},
		
		DesignNotes = "Tier 2 upgrade. Big power spike. Future content placeholder.",
	},
	
	ElementalStaff_T2 = {
		ID = "ElementalStaff_T2",
		Name = "Elemental Staff",
		Description = "A staff crackling with elemental energy.",
		
		Slot = Constants.EQUIPMENT_SLOTS.WEAPON,
		Tier = 2,
		ItemLevel = 15,
		
		Stats = {
			MagicDamage = 12,
			CritRate = 0.04,
		},
		
		Model = "ElementalStaff_Model",
		EquipAnimation = "Staff_Equip",
		AttackAnimation = "Staff_Cast",
		
		CanDropAsRarity = {
			[Constants.EQUIPMENT_RARITY.RARE] = true,
			[Constants.EQUIPMENT_RARITY.EPIC] = true,
			[Constants.EQUIPMENT_RARITY.LEGENDARY] = true,
		},
		
		DropSources = {
			Floors = {11, 12, 13, 14, 15},
			Monsters = {},
		},
		
		DesignNotes = "Tier 2 magic weapon. Future content.",
	},
	
	-- ═══════════════════════════════════════════════════════════════════════
	-- BOSS WEAPONS (Unique/Special)
	-- ═══════════════════════════════════════════════════════════════════════
	
	GatekeeperBlade_T1 = {
		ID = "GatekeeperBlade_T1",
		Name = "Gatekeeper's Blade",
		Description = "Forged from the core of Gargantua. Radiates immense power.",
		
		Slot = Constants.EQUIPMENT_SLOTS.WEAPON,
		Tier = 1, -- Still T1, but boss-exclusive = rare
		ItemLevel = 10,
		
		Stats = {
			PhysicalDamage = 8, -- Slightly higher than normal T1 (+3 bonus)
			CritRate = 0.03, -- +3% (better than normal T1)
			HP = 20, -- Bonus HP (unique stat)
		},
		
		Model = "GatekeeperBlade_Model",
		EquipAnimation = "Sword_Equip",
		AttackAnimation = "Sword_Swing",
		
		-- Boss drops are always Epic or Legendary
		CanDropAsRarity = {
			[Constants.EQUIPMENT_RARITY.EPIC] = true,
			[Constants.EQUIPMENT_RARITY.LEGENDARY] = true,
		},
		
		DropSources = {
			Floors = {10},
			Monsters = {"Gargantua"}, -- Boss-only
		},
		
		IsUnique = true, -- Can only have 1 in inventory
		
		DesignNotes = "Boss weapon. Stronger than normal T1. Trophy item. Show-off value.",
	},
}

-- ═══════════════════════════════════════════════════════════════════════════
-- ARMOR DEFINITIONS
-- ═══════════════════════════════════════════════════════════════════════════

EquipmentData.Armor = {
	
	-- ═══════════════════════════════════════════════════════════════════════
	-- TIER 1 ARMOR (Floors 1-10)
	-- ═══════════════════════════════════════════════════════════════════════
	
	LeatherVest_T1 = {
		ID = "LeatherVest_T1",
		Name = "Leather Vest",
		Description = "Basic leather armor. Provides minimal protection.",
		
		Slot = Constants.EQUIPMENT_SLOTS.ARMOR,
		Tier = 1,
		ItemLevel = 1,
		
		Stats = {
			HP = 20,
			Defense = 5,
		},
		
		Model = "LeatherVest_Model",
		
		CanDropAsRarity = {
			[Constants.EQUIPMENT_RARITY.COMMON] = true,
			[Constants.EQUIPMENT_RARITY.RARE] = true,
		},
		
		DropSources = {
			Floors = {1, 2, 3, 4, 5},
			Monsters = {"DustMite", "StoneGuard", "ThornWolf"},
		},
		
		DesignNotes = "Starter armor. Common drop.",
	},
	
	ChainmailArmor_T1 = {
		ID = "ChainmailArmor_T1",
		Name = "Chainmail Armor",
		Description = "Interlocking metal rings provide decent protection.",
		
		Slot = Constants.EQUIPMENT_SLOTS.ARMOR,
		Tier = 1,
		ItemLevel = 5,
		
		Stats = {
			HP = 20,
			Defense = 5,
		},
		
		Model = "ChainmailArmor_Model",
		
		CanDropAsRarity = {
			[Constants.EQUIPMENT_RARITY.RARE] = true,
			[Constants.EQUIPMENT_RARITY.EPIC] = true,
		},
		
		DropSources = {
			Floors = {5, 6, 7, 8, 9},
			Monsters = {"ObsidianKnight", "StoneGuard"},
		},
		
		DesignNotes = "Mid-tier 1 armor.",
	},
	
	MageRobes_T1 = {
		ID = "MageRobes_T1",
		Name = "Apprentice Robes",
		Description = "Lightweight robes enchanted with protective magic.",
		
		Slot = Constants.EQUIPMENT_SLOTS.ARMOR,
		Tier = 1,
		ItemLevel = 1,
		
		Stats = {
			HP = 20,
			Defense = 5,
		},
		
		Model = "ApprenticeRobes_Model",
		
		CanDropAsRarity = {
			[Constants.EQUIPMENT_RARITY.COMMON] = true,
			[Constants.EQUIPMENT_RARITY.RARE] = true,
		},
		
		DropSources = {
			Floors = {1, 2, 3, 4, 5},
			Monsters = {"Wisp", "SporeFungus"},
		},
		
		DesignNotes = "Magic-themed armor (cosmetic difference only).",
	},
	
	-- ═══════════════════════════════════════════════════════════════════════
	-- TIER 2 ARMOR (Floors 11-20)
	-- ═══════════════════════════════════════════════════════════════════════
	
	PlateArmor_T2 = {
		ID = "PlateArmor_T2",
		Name = "Steel Plate Armor",
		Description = "Heavy full-body plate armor. Maximum protection.",
		
		Slot = Constants.EQUIPMENT_SLOTS.ARMOR,
		Tier = 2,
		ItemLevel = 15,
		
		Stats = {
			HP = 50,
			Defense = 12,
		},
		
		Model = "PlateArmor_Model",
		
		CanDropAsRarity = {
			[Constants.EQUIPMENT_RARITY.RARE] = true,
			[Constants.EQUIPMENT_RARITY.EPIC] = true,
			[Constants.EQUIPMENT_RARITY.LEGENDARY] = true,
		},
		
		DropSources = {
			Floors = {11, 12, 13, 14, 15},
			Monsters = {},
		},
		
		DesignNotes = "Tier 2 armor. Future content.",
	},
	
	-- ═══════════════════════════════════════════════════════════════════════
	-- BOSS ARMOR
	-- ═══════════════════════════════════════════════════════════════════════
	
	GatekeeperPlate_T1 = {
		ID = "GatekeeperPlate_T1",
		Name = "Gatekeeper's Plate",
		Description = "Armor fragment from Gargantua. Incredibly durable.",
		
		Slot = Constants.EQUIPMENT_SLOTS.ARMOR,
		Tier = 1,
		ItemLevel = 10,
		
		Stats = {
			HP = 30, -- +10 bonus HP
			Defense = 8, -- +3 bonus Defense
		},
		
		Model = "GatekeeperPlate_Model",
		
		CanDropAsRarity = {
			[Constants.EQUIPMENT_RARITY.EPIC] = true,
			[Constants.EQUIPMENT_RARITY.LEGENDARY] = true,
		},
		
		DropSources = {
			Floors = {10},
			Monsters = {"Gargantua"},
		},
		
		IsUnique = true,
		
		DesignNotes = "Boss armor. Stronger than normal T1.",
	},
}

-- ═══════════════════════════════════════════════════════════════════════════
-- ACCESSORY DEFINITIONS
-- ═══════════════════════════════════════════════════════════════════════════

EquipmentData.Accessories = {
	
	-- ═══════════════════════════════════════════════════════════════════════
	-- TIER 1 ACCESSORIES (Floors 1-10)
	-- ═══════════════════════════════════════════════════════════════════════
	
	BronzeRing_T1 = {
		ID = "BronzeRing_T1",
		Name = "Bronze Ring",
		Description = "A simple bronze ring. Provides minor stat bonuses.",
		
		Slot = Constants.EQUIPMENT_SLOTS.ACCESSORY,
		Tier = 1,
		ItemLevel = 1,
		
		Stats = {
			HP = 10,
			PhysicalDamage = 3,
			CritDamage = 0.1, -- +10% crit damage
		},
		
		Model = "BronzeRing_Model",
		
		CanDropAsRarity = {
			[Constants.EQUIPMENT_RARITY.COMMON] = true,
			[Constants.EQUIPMENT_RARITY.RARE] = true,
		},
		
		DropSources = {
			Floors = {1, 2, 3, 4, 5},
			Monsters = {"DustMite", "Wisp", "ThornWolf"},
		},
		
		DesignNotes = "Starter accessory. All-around stats.",
	},
	
	VitalityAmulet_T1 = {
		ID = "VitalityAmulet_T1",
		Name = "Amulet of Vitality",
		Description = "An amulet that bolsters the wearer's life force.",
		
		Slot = Constants.EQUIPMENT_SLOTS.ACCESSORY,
		Tier = 1,
		ItemLevel = 3,
		
		Stats = {
			HP = 15, -- More HP focused
			Defense = 2,
			CritDamage = 0.05,
		},
		
		Model = "VitalityAmulet_Model",
		
		CanDropAsRarity = {
			[Constants.EQUIPMENT_RARITY.RARE] = true,
			[Constants.EQUIPMENT_RARITY.EPIC] = true,
		},
		
		DropSources = {
			Floors = {3, 4, 5, 6, 7},
			Monsters = {"StoneGuard", "SporeFungus"},
		},
		
		DesignNotes = "Tank-focused accessory.",
	},
	
	AssassinRing_T1 = {
		ID = "AssassinRing_T1",
		Name = "Assassin's Ring",
		Description = "Enhances critical strike potential.",
		
		Slot = Constants.EQUIPMENT_SLOTS.ACCESSORY,
		Tier = 1,
		ItemLevel = 5,
		
		Stats = {
			HP = 5,
			PhysicalDamage = 5, -- More damage focused
			CritRate = 0.03, -- +3% crit rate (unique!)
			CritDamage = 0.15, -- +15% crit damage
		},
		
		Model = "AssassinRing_Model",
		
		CanDropAsRarity = {
			[Constants.EQUIPMENT_RARITY.EPIC] = true,
			[Constants.EQUIPMENT_RARITY.LEGENDARY] = true,
		},
		
		DropSources = {
			Floors = {7, 8, 9, 10},
			Monsters = {"ShadowArcher"},
		},
		
		DesignNotes = "Crit-focused build enabler. Rare drop.",
	},
	
	-- ═══════════════════════════════════════════════════════════════════════
	-- TIER 2 ACCESSORIES (Floors 11-20)
	-- ═══════════════════════════════════════════════════════════════════════
	
	SilverRing_T2 = {
		ID = "SilverRing_T2",
		Name = "Silver Ring",
		Description = "A finely crafted silver ring imbued with power.",
		
		Slot = Constants.EQUIPMENT_SLOTS.ACCESSORY,
		Tier = 2,
		ItemLevel = 15,
		
		Stats = {
			HP = 25,
			PhysicalDamage = 7,
			CritDamage = 0.15,
		},
		
		Model = "SilverRing_Model",
		
		CanDropAsRarity = {
			[Constants.EQUIPMENT_RARITY.RARE] = true,
			[Constants.EQUIPMENT_RARITY.EPIC] = true,
			[Constants.EQUIPMENT_RARITY.LEGENDARY] = true,
		},
		
		DropSources = {
			Floors = {11, 12, 13, 14, 15},
			Monsters = {},
		},
		
		DesignNotes = "Tier 2 accessory. Future content.",
	},
	
	-- ═══════════════════════════════════════════════════════════════════════
	-- BOSS ACCESSORIES
	-- ═══════════════════════════════════════════════════════════════════════
	
	GatekeepersEye_T1 = {
		ID = "GatekeepersEye_T1",
		Name = "Gatekeeper's Eye",
		Description = "The crystallized eye of Gargantua. Grants foresight in battle.",
		
		Slot = Constants.EQUIPMENT_SLOTS.ACCESSORY,
		Tier = 1,
		ItemLevel = 10,
		
		Stats = {
			HP = 15,
			PhysicalDamage = 5,
			MagicDamage = 5, -- Hybrid damage (unique!)
			CritRate = 0.05, -- +5% crit rate
			CritDamage = 0.2, -- +20% crit damage
		},
		
		Model = "GatekeepersEye_Model",
		
		CanDropAsRarity = {
			[Constants.EQUIPMENT_RARITY.LEGENDARY] = true, -- Always Legendary
		},
		
		DropSources = {
			Floors = {10},
			Monsters = {"Gargantua"},
		},
		
		IsUnique = true,
		
		DesignNotes = "BiS (Best in Slot) for Tier 1. Trophy item. Very rare (2% drop from boss).",
	},
}

-- ═══════════════════════════════════════════════════════════════════════════
-- EQUIPMENT SETS (Future Feature)
-- ═══════════════════════════════════════════════════════════════════════════

--[[
	Equipment Sets provide bonuses when wearing multiple pieces
	
	Example:
	Gatekeeper's Set (3 pieces):
	- 2-piece: +10% HP
	- 3-piece: +15% All Damage
	
	This is a FUTURE FEATURE for v0.2+
]]
EquipmentData.Sets = {
	GatekeeperSet = {
		Name = "Gatekeeper's Legacy",
		Pieces = {
			"GatekeeperBlade_T1",
			"GatekeeperPlate_T1",
			"GatekeepersEye_T1",
		},
		
		Bonuses = {
			[2] = {
				Description = "2-Piece: +10% Maximum HP",
				Stats = {HPPercent = 0.1},
			},
			[3] = {
				Description = "3-Piece: +15% All Damage",
				Stats = {DamagePercent = 0.15},
			},
		},
	},
}

-- ═══════════════════════════════════════════════════════════════════════════
-- HELPER FUNCTIONS
-- ═══════════════════════════════════════════════════════════════════════════

--[[
	Get all equipment data (weapons + armor + accessories)
	
	@return table - Combined equipment database
]]
function EquipmentData.GetAllEquipment()
	local allEquipment = {}
	
	-- Merge all categories
	for id, data in pairs(EquipmentData.Weapons) do
		allEquipment[id] = data
	end
	
	for id, data in pairs(EquipmentData.Armor) do
		allEquipment[id] = data
	end
	
	for id, data in pairs(EquipmentData.Accessories) do
		allEquipment[id] = data
	end
	
	return allEquipment
end

--[[
	Get equipment data by ID
	
	@param equipmentID string
	@return table - Equipment data or nil
]]
function EquipmentData.GetEquipmentData(equipmentID)
	local allEquipment = EquipmentData.GetAllEquipment()
	return allEquipment[equipmentID]
end

--[[
	Get equipment by slot type
	
	@param slot string - "Weapon", "Armor", or "Accessory"
	@return table - Array of equipment IDs
]]
function EquipmentData.GetEquipmentBySlot(slot)
	local equipment = {}
	local allEquipment = EquipmentData.GetAllEquipment()
	
	for id, data in pairs(allEquipment) do
		if data.Slot == slot then
			table.insert(equipment, id)
		end
	end
	
	return equipment
end

--[[
	Get equipment by tier
	
	@param tier number (1-5)
	@return table - Array of equipment IDs
]]
function EquipmentData.GetEquipmentByTier(tier)
	local equipment = {}
	local allEquipment = EquipmentData.GetAllEquipment()
	
	for id, data in pairs(allEquipment) do
		if data.Tier == tier then
			table.insert(equipment, id)
		end
	end
	
	return equipment
end

--[[
	Roll equipment drop dari monster/floor
	
	@param floorNumber number
	@param monsterType string (optional)
	@return table - {EquipmentID, Rarity} or nil
]]
function EquipmentData.RollEquipmentDrop(floorNumber, monsterType)
	-- Base drop chance
	local baseChance = BalanceConfig.EQUIPMENT_DROP_RATES.BASE_DROP_CHANCE
	
	local roll = math.random()
	if roll > baseChance then
		return nil -- No drop
	end
	
	-- Determine tier based on floor
	local floorTier = math.ceil(floorNumber / 10)
	floorTier = math.min(floorTier, 4) -- Max tier 4 for now
	
	local tierDistribution = BalanceConfig.EQUIPMENT_DROP_RATES.TIER_DISTRIBUTION[floorTier]
	
	if not tierDistribution then
		return nil
	end
	
	-- Roll for equipment tier
	local tierRoll = math.random()
	local cumulativeChance = 0
	local droppedTier = nil
	
	for tier, chance in pairs(tierDistribution) do
		cumulativeChance = cumulativeChance + chance
		if tierRoll <= cumulativeChance then
			droppedTier = tier
			break
		end
	end
	
	if not droppedTier then
		return nil
	end
	
	-- Get equipment of that tier
	local equipmentOfTier = EquipmentData.GetEquipmentByTier(droppedTier)
	
	if #equipmentOfTier == 0 then
		return nil
	end
	
	-- Filter by floor/monster compatibility
	local validEquipment = {}
	for _, equipID in ipairs(equipmentOfTier) do
		local equipData = EquipmentData.GetEquipmentData(equipID)
		
		if equipData and equipData.DropSources then
			-- Check if floor is valid
			local validFloor = false
			for _, floor in ipairs(equipData.DropSources.Floors) do
				if floor == floorNumber then
					validFloor = true
					break
				end
			end
			
			-- Check if monster is valid (if specified)
			local validMonster = true
			if monsterType and #equipData.DropSources.Monsters > 0 then
				validMonster = false
				for _, monster in ipairs(equipData.DropSources.Monsters) do
					if monster == monsterType then
						validMonster = true
						break
					end
				end
			end
			
			if validFloor and validMonster then
				table.insert(validEquipment, equipID)
			end
		end
	end
	
	if #validEquipment == 0 then
		return nil
	end
	
	-- Random equipment from valid pool
	local chosenEquipment = validEquipment[math.random(1, #validEquipment)]
	
	-- Roll rarity (affects durability only)
	local rarityDistribution = BalanceConfig.EQUIPMENT_DROP_RATES.RARITY_DISTRIBUTION
	local rarityRoll = math.random()
	local cumulativeRarity = 0
	local droppedRarity = Constants.EQUIPMENT_RARITY.COMMON
	
	for rarity, chance in pairs(rarityDistribution) do
		cumulativeRarity = cumulativeRarity + chance
		if rarityRoll <= cumulativeRarity then
			droppedRarity = rarity
			break
		end
	end
	
	-- Verify equipment can drop as this rarity
	local equipData = EquipmentData.GetEquipmentData(chosenEquipment)
	if equipData and not equipData.CanDropAsRarity[droppedRarity] then
		-- Re-roll rarity within allowed rarities
		local allowedRarities = {}
		for rarity, allowed in pairs(equipData.CanDropAsRarity) do
			if allowed then
				table.insert(allowedRarities, rarity)
			end
		end
		
		if #allowedRarities > 0 then
			droppedRarity = allowedRarities[math.random(1, #allowedRarities)]
		end
	end
	
	return {
		EquipmentID = chosenEquipment,
		Rarity = droppedRarity,
	}
end

--[[
	Create equipment instance (untuk inventory)
	
	@param equipmentID string
	@param rarity number
	@return table - Equipment instance
]]
function EquipmentData.CreateEquipmentInstance(equipmentID, rarity)
	local equipData = EquipmentData.GetEquipmentData(equipmentID)
	
	if not equipData then
		warn("Unknown equipment ID:", equipmentID)
		return nil
	end
	
	-- Create instance
	local instance = {
		EquipmentID = equipmentID,
		Rarity = rarity or Constants.EQUIPMENT_RARITY.COMMON,
		CurrentDurability = Constants.DURABILITY.MAX_DURABILITY,
		
		-- Copy stats (flat values)
		Stats = {},
		
		-- Metadata
		AcquiredAt = os.time(),
		TimesRepaired = 0,
	}
	
	-- Copy stats
	for statName, value in pairs(equipData.Stats) do
		instance.Stats[statName] = value
	end
	
	return instance
end

--[[
	Get equipment display name with rarity
	
	@param equipmentID string
	@param rarity number
	@return string - "★★★ Iron Sword" (Epic)
]]
function EquipmentData.GetDisplayName(equipmentID, rarity)
	local equipData = EquipmentData.GetEquipmentData(equipmentID)
	
	if not equipData then
		return "Unknown Equipment"
	end
	
	local stars = string.rep("★", rarity)
	
	local rarityNames = {
		[1] = "Common",
		[2] = "Rare",
		[3] = "Epic",
		[4] = "Legendary",
	}
	
	return string.format("%s %s (%s)", stars, equipData.Name, rarityNames[rarity] or "Unknown")
end

--[[
	Check if equipment needs repair
	
	@param durability number
	@return boolean - True if below 50% durability
]]
function EquipmentData.NeedsRepair(durability)
	return durability < 50
end

--[[
	Check if equipment is broken
	
	@param durability number
	@return boolean - True if 0 durability
]]
function EquipmentData.IsBroken(durability)
	return durability <= 0
end

-- ═══════════════════════════════════════════════════════════════════════════
-- EXPORT
-- ═══════════════════════════════════════════════════════════════════════════

return EquipmentData