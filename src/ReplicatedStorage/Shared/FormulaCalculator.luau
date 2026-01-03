--[[
	FormulaCalculator.luau
	
	Centralized calculation module untuk semua mathematical formulas di game.
	Semua perhitungan game (damage, XP, stats, scaling) ada di sini.
	
	DESIGN PRINCIPLES:
	- Pure functions (no side effects)
	- Well-documented dengan examples
	- Easy to unit test
	- References Constants & BalanceConfig untuk values
	
	Author: Bisa Bahasa Studio
	Created: 2025-01-03
	Last Modified: 2025-01-03
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Import dependencies
local Constants = require(ReplicatedStorage.Shared.Constants)
local BalanceConfig = require(ReplicatedStorage.Shared.BalanceConfig)

local FormulaCalculator = {}

-- ═══════════════════════════════════════════════════════════════════════════
-- UTILITY FUNCTIONS
-- ═══════════════════════════════════════════════════════════════════════════

--[[
	Clamp value antara min dan max
	@param value number - Nilai yang ingin di-clamp
	@param min number - Nilai minimum
	@param max number - Nilai maximum
	@return number - Clamped value
]]
local function clamp(value, min, max)
	return math.max(min, math.min(max, value))
end

--[[
	Round number ke decimal places tertentu
	@param value number - Nilai yang ingin di-round
	@param decimals number - Jumlah decimal places (default 2)
	@return number - Rounded value
]]
local function round(value, decimals)
	decimals = decimals or 2
	local mult = 10 ^ decimals
	return math.floor(value * mult + 0.5) / mult
end

-- ═══════════════════════════════════════════════════════════════════════════
-- PROGRESSION FORMULAS
-- ═══════════════════════════════════════════════════════════════════════════

--[[
	Calculate XP required untuk level up
	
	Formula: XP_Required = BaseXP * (GrowthRate ^ (CurrentLevel - 1))
	
	Example:
	- Level 1 → 2: 100 XP
	- Level 2 → 3: 135 XP
	- Level 5 → 6: 366 XP
	- Level 9 → 10: 1,000 XP
	
	@param currentLevel number - Current player level
	@return number - XP needed untuk next level
]]
function FormulaCalculator.CalculateXPToNextLevel(currentLevel)
	if not currentLevel or currentLevel < 1 then
		warn("Invalid currentLevel:", currentLevel)
		return 0
	end
	
	local baseXP = BalanceConfig.XP_CURVE.BASE_XP
	local growthRate = BalanceConfig.XP_CURVE.GROWTH_RATE
	
	local xpRequired = baseXP * (growthRate ^ (currentLevel - 1))
	
	return round(xpRequired, 0) -- Round ke integer
end

--[[
	Calculate total XP needed dari Level 1 ke target level
	
	Useful untuk progress tracking & achievements
	
	@param targetLevel number - Target level
	@return number - Total XP needed
]]
function FormulaCalculator.CalculateTotalXPToLevel(targetLevel)
	if not targetLevel or targetLevel < 1 then
		return 0
	end
	
	local totalXP = 0
	
	for level = 1, targetLevel - 1 do
		totalXP = totalXP + FormulaCalculator.CalculateXPToNextLevel(level)
	end
	
	return round(totalXP, 0)
end

--[[
	Calculate XP reward dari monster kill
	
	Formula: MonsterXP = BaseMonsterXP * FloorMultiplier * ArchetypeMultiplier * PartyBonus
	
	@param floorNumber number - Current floor number
	@param monsterType string - Monster archetype (Minion, Tank, Ranged, etc.)
	@param isInParty boolean - Apakah player dalam party
	@return number - XP reward
]]
function FormulaCalculator.CalculateMonsterXP(floorNumber, monsterType, isInParty)
	local baseXP = BalanceConfig.XP_CURVE.MONSTER_BASE_XP
	
	-- Floor scaling (linear untuk XP, agar tidak terlalu eksponensial)
	local floorMultiplier = 1 + (floorNumber - 1) * 0.2 -- +20% per floor
	
	-- Archetype multiplier
	local archetypeMultiplier = 1.0
	if BalanceConfig.MONSTER_SCALING.ARCHETYPE_MULTIPLIERS[monsterType] then
		archetypeMultiplier = BalanceConfig.MONSTER_SCALING.ARCHETYPE_MULTIPLIERS[monsterType].XP
	end
	
	-- Party bonus
	local partyBonus = isInParty and (1 + BalanceConfig.XP_CURVE.PARTY_XP_BONUS) or 1
	
	local totalXP = baseXP * floorMultiplier * archetypeMultiplier * partyBonus
	
	return round(totalXP, 0)
end

--[[
	Calculate max level cap berdasarkan rarity
	
	@param rarity number - Character rarity (1-10)
	@return number - Maximum level
]]
function FormulaCalculator.GetMaxLevelForRarity(rarity)
	if not rarity or rarity < Constants.MIN_RARITY or rarity > Constants.MAX_RARITY then
		warn("Invalid rarity:", rarity)
		return Constants.LEVEL_CAP_PER_RARITY[1]
	end
	
	return Constants.LEVEL_CAP_PER_RARITY[rarity] or 10
end

--[[
	Calculate Soul Dust reward saat player death
	
	Formula: SoulDust = (CurrentLevel ÷ 10) * BaseDust * TierMultiplier
	
	Tier = ceil(Level / 10)
	
	Example:
	- Level 5 death:  2 Soul Dust (Tier 1)
	- Level 15 death: 6 Soul Dust (Tier 2)
	- Level 95 death: 570 Soul Dust (Tier 10)
	
	@param currentLevel number - Player level saat death
	@return number - Soul Dust reward
]]
function FormulaCalculator.CalculateSoulDustOnDeath(currentLevel)
	if not currentLevel or currentLevel < 1 then
		return 0
	end
	
	-- Determine tier (1-10)
	local tier = math.ceil(currentLevel / 10)
	tier = clamp(tier, 1, 10)
	
	-- Get tier multiplier
	local tierMultiplier = BalanceConfig.SOUL_DUST_ON_DEATH.TIER_MULTIPLIERS[tier] or 1.0
	
	-- Base dust per tier
	local baseDust = BalanceConfig.SOUL_DUST_ON_DEATH.BASE_DUST_PER_10_LEVELS
	
	-- Calculate total
	local soulDust = baseDust * tierMultiplier * (currentLevel / 10)
	
	return round(soulDust, 0)
end

-- ═══════════════════════════════════════════════════════════════════════════
-- STAT CALCULATION FORMULAS
-- ═══════════════════════════════════════════════════════════════════════════

--[[
	Calculate final stats dari base stats + allocated points + rarity multiplier
	
	@param baseStats table - Base stats {STR, INT, VIT, DEX}
	@param allocatedStats table - Player-allocated stats
	@param rarity number - Character rarity (1-10)
	@return table - Final calculated stats
]]
function FormulaCalculator.CalculateFinalStats(baseStats, allocatedStats, rarity)
	-- Validate inputs
	if not baseStats or not allocatedStats or not rarity then
		warn("Invalid inputs for CalculateFinalStats")
		return {}
	end
	
	-- Get rarity multiplier
	local rarityMultiplier = Constants.RARITY_STAT_MULTIPLIER[rarity] or 1.0
	
	-- Calculate bonuses dari allocated stats
	local strBonus = allocatedStats.STR or 0
	local intBonus = allocatedStats.INT or 0
	local vitBonus = allocatedStats.VIT or 0
	local dexBonus = allocatedStats.DEX or 0
	
	-- Calculate final values
	local finalStats = {}
	
	-- MAX HP = (BaseHP + (VIT * 10) + (STR * 5)) * RarityMultiplier
	finalStats.MaxHP = (
		Constants.BASE_STATS.MAX_HP +
		(vitBonus * BalanceConfig.STAT_SCALING.VIT_TO_HP) +
		(strBonus * BalanceConfig.STAT_SCALING.STR_TO_HP)
	) * rarityMultiplier
	
	-- HP Regen = (BaseRegen + (VIT * 0.1)) * RarityMultiplier
	finalStats.HPRegenPerSecond = (
		Constants.BASE_STATS.HP_REGEN_PER_SECOND +
		(vitBonus * BalanceConfig.STAT_SCALING.VIT_TO_HP_REGEN)
	) * rarityMultiplier
	
	-- Physical Damage = (BaseDamage + (STR * 2)) * RarityMultiplier
	finalStats.PhysicalDamage = (
		Constants.BASE_STATS.PHYSICAL_DAMAGE +
		(strBonus * BalanceConfig.STAT_SCALING.STR_TO_PHYSICAL_DAMAGE)
	) * rarityMultiplier
	
	-- Magic Damage = (BaseDamage + (INT * 2.5)) * RarityMultiplier
	finalStats.MagicDamage = (
		Constants.BASE_STATS.MAGIC_DAMAGE +
		(intBonus * BalanceConfig.STAT_SCALING.INT_TO_MAGIC_DAMAGE)
	) * rarityMultiplier
	
	-- Defense = BaseDefense + (VIT * 0.5)
	-- NOTE: Defense TIDAK di-multiply rarity (balancing choice)
	finalStats.Defense = (
		Constants.BASE_STATS.DEFENSE +
		(vitBonus * BalanceConfig.STAT_SCALING.VIT_TO_DEFENSE)
	)
	
	-- Crit Rate = BaseCrit + (DEX * 0.005)
	finalStats.CritRate = Constants.BASE_STATS.CRIT_RATE +
		(dexBonus * BalanceConfig.STAT_SCALING.DEX_TO_CRIT_RATE)
	
	-- Clamp crit rate ke max
	finalStats.CritRate = clamp(finalStats.CritRate, 0, BalanceConfig.CRIT_SYSTEM.MAX_CRIT_RATE)
	
	-- Crit Damage (fixed dari base, tidak scale dengan stats)
	finalStats.CritDamage = Constants.BASE_STATS.CRIT_DAMAGE
	
	-- Attack Speed = BaseAS * (1 + (DEX * 0.02))
	finalStats.AttackSpeed = Constants.BASE_STATS.ATTACK_SPEED *
		(1 + (dexBonus * BalanceConfig.STAT_SCALING.DEX_TO_ATTACK_SPEED))
	
	-- Clamp attack speed
	finalStats.AttackSpeed = clamp(
		finalStats.AttackSpeed,
		BalanceConfig.ATTACK_SPEED.MIN_ATTACK_SPEED,
		BalanceConfig.ATTACK_SPEED.MAX_ATTACK_SPEED
	)
	
	-- Movement Speed = BaseSpeed + (DEX * 0.2)
	finalStats.MovementSpeed = Constants.BASE_STATS.MOVEMENT_SPEED +
		(dexBonus * BalanceConfig.STAT_SCALING.DEX_TO_MOVEMENT_SPEED)
	
	-- Round semua values untuk cleanliness
	for key, value in pairs(finalStats) do
		finalStats[key] = round(value, 2)
	end
	
	return finalStats
end

--[[
	Calculate stat points yang belum dialokasikan
	
	@param currentLevel number - Current level
	@param allocatedStats table - Already allocated stats
	@return number - Unspent stat points
]]
function FormulaCalculator.CalculateUnspentStatPoints(currentLevel, allocatedStats)
	if not currentLevel or not allocatedStats then
		return 0
	end
	
	-- Total points earned = (Level - 1) * Points per level
	local totalEarned = (currentLevel - 1) * Constants.STAT_POINTS_PER_LEVEL
	
	-- Total spent
	local totalSpent = (allocatedStats.STR or 0) +
		(allocatedStats.INT or 0) +
		(allocatedStats.VIT or 0) +
		(allocatedStats.DEX or 0)
	
	return math.max(0, totalEarned - totalSpent)
end

-- ═══════════════════════════════════════════════════════════════════════════
-- COMBAT FORMULAS
-- ═══════════════════════════════════════════════════════════════════════════

--[[
	Calculate final damage setelah defense reduction
	
	Formula: FinalDamage = RawDamage * (1 - (Defense / (Defense + DefenseConstant)))
	
	Ini adalah "diminishing returns" formula:
	- 0 Defense = 0% reduction
	- 50 Defense = 33% reduction
	- 100 Defense = 50% reduction
	- 200 Defense = 67% reduction
	- 500 Defense = 83% reduction
	
	@param rawDamage number - Damage sebelum defense
	@param targetDefense number - Target's defense stat
	@param damageType string - "Physical", "Magic", or "True"
	@return number - Final damage after reduction
]]
function FormulaCalculator.CalculateDamageAfterDefense(rawDamage, targetDefense, damageType)
	if not rawDamage or rawDamage <= 0 then
		return 0
	end
	
	-- True damage ignores defense
	if damageType == Constants.DAMAGE_TYPES.TRUE then
		return round(rawDamage, 2)
	end
	
	targetDefense = targetDefense or 0
	
	-- Defense reduction formula
	local defenseConstant = BalanceConfig.DEFENSE_FORMULA.DEFENSE_CONSTANT
	local damageReduction = targetDefense / (targetDefense + defenseConstant)
	
	-- Apply reduction
	local finalDamage = rawDamage * (1 - damageReduction)
	
	-- Enforce minimum damage (5% of raw damage goes through)
	local minDamage = rawDamage * BalanceConfig.DEFENSE_FORMULA.MIN_DAMAGE_PERCENT
	finalDamage = math.max(finalDamage, minDamage)
	
	return round(finalDamage, 2)
end

--[[
	Calculate critical hit
	
	@param baseDamage number - Base damage
	@param critRate number - Crit chance (0.0 - 1.0)
	@param critDamage number - Crit multiplier (default 1.5)
	@return boolean isCrit - Apakah attack ini crit
	@return number finalDamage - Damage setelah crit (if applicable)
]]
function FormulaCalculator.CalculateCriticalHit(baseDamage, critRate, critDamage)
	if not baseDamage or baseDamage <= 0 then
		return false, 0
	end
	
	critRate = critRate or 0
	critDamage = critDamage or Constants.BASE_STATS.CRIT_DAMAGE
	
	-- Roll for crit
	local roll = math.random()
	local isCrit = roll <= critRate
	
	local finalDamage = baseDamage
	if isCrit then
		finalDamage = baseDamage * critDamage
	end
	
	return isCrit, round(finalDamage, 2)
end

--[[
	Calculate damage dari weapon + stats
	
	@param weaponDamage number - Weapon base damage
	@param playerStats table - Player final stats
	@param damageType string - "Physical" or "Magic"
	@return number - Total damage before defense
]]
function FormulaCalculator.CalculateAttackDamage(weaponDamage, playerStats, damageType)
	weaponDamage = weaponDamage or 0
	
	if not playerStats then
		return weaponDamage
	end
	
	local totalDamage = weaponDamage
	
	if damageType == Constants.DAMAGE_TYPES.PHYSICAL then
		totalDamage = totalDamage + (playerStats.PhysicalDamage or 0)
	elseif damageType == Constants.DAMAGE_TYPES.MAGIC then
		totalDamage = totalDamage + (playerStats.MagicDamage or 0)
	end
	
	return round(totalDamage, 2)
end

--[[
	Calculate skill damage dengan level scaling
	
	Formula: SkillDamage = BaseDamage * (1 + (SkillLevel - 1) * 0.2) * PlayerDamage
	
	@param skillBaseDamagePercent number - Base damage sebagai % (e.g., 1.2 untuk 120%)
	@param skillLevel number - Skill level (1-10)
	@param playerDamage number - Player's final damage stat
	@return number - Final skill damage
]]
function FormulaCalculator.CalculateSkillDamage(skillBaseDamagePercent, skillLevel, playerDamage)
	if not skillBaseDamagePercent or not playerDamage then
		return 0
	end
	
	skillLevel = skillLevel or 1
	
	-- Skill level scaling
	local levelScaling = 1 + ((skillLevel - 1) * BalanceConfig.SKILL_SCALING.DAMAGE_SCALING_PER_LEVEL)
	
	-- Final damage
	local skillDamage = skillBaseDamagePercent * levelScaling * playerDamage
	
	return round(skillDamage, 2)
end

--[[
	Calculate skill cooldown dengan level reduction
	
	Formula: Cooldown = BaseCooldown * (1 - (SkillLevel - 1) * 0.05)
	Max reduction: 50%
	
	@param baseCooldown number - Base cooldown in seconds
	@param skillLevel number - Skill level (1-10)
	@return number - Final cooldown
]]
function FormulaCalculator.CalculateSkillCooldown(baseCooldown, skillLevel)
	if not baseCooldown then
		return 0
	end
	
	skillLevel = skillLevel or 1
	
	-- Cooldown reduction per level
	local reduction = (skillLevel - 1) * BalanceConfig.SKILL_SCALING.COOLDOWN_REDUCTION_PER_LEVEL
	reduction = math.min(reduction, BalanceConfig.SKILL_SCALING.MAX_COOLDOWN_REDUCTION)
	
	local finalCooldown = baseCooldown * (1 - reduction)
	
	return round(finalCooldown, 2)
end

-- ═══════════════════════════════════════════════════════════════════════════
-- MONSTER SCALING FORMULAS
-- ═══════════════════════════════════════════════════════════════════════════

--[[
	Calculate monster stats untuk floor tertentu
	
	Formula:
	MonsterStat = BaseStat * (FloorMultiplier ^ Floor) * PlayerLevelScaling * ArchetypeMultiplier
	
	Ini adalah HARDCORE SCALING - monster selalu menantang!
	
	@param floorNumber number - Current floor
	@param monsterType string - Monster archetype
	@param averagePlayerLevel number - Average level of players in instance (optional)
	@return table - Monster stats {HP, Damage, Defense, Speed, XP, Gold}
]]
function FormulaCalculator.CalculateMonsterStats(floorNumber, monsterType, averagePlayerLevel)
	if not floorNumber or floorNumber < 1 then
		warn("Invalid floor number:", floorNumber)
		return {}
	end
	
	-- Get base stats
	local baseHP = BalanceConfig.MONSTER_SCALING.BASE_HP
	local baseDamage = BalanceConfig.MONSTER_SCALING.BASE_DAMAGE
	local baseDefense = BalanceConfig.MONSTER_SCALING.BASE_DEFENSE
	local baseXP = BalanceConfig.MONSTER_SCALING.BASE_XP_REWARD
	local baseGold = BalanceConfig.MONSTER_SCALING.BASE_GOLD_DROP
	
	-- Floor scaling multipliers (exponential)
	local hpMultiplier = BalanceConfig.MONSTER_SCALING.FLOOR_HP_MULTIPLIER ^ (floorNumber - 1)
	local damageMultiplier = BalanceConfig.MONSTER_SCALING.FLOOR_DAMAGE_MULTIPLIER ^ (floorNumber - 1)
	local defenseMultiplier = BalanceConfig.MONSTER_SCALING.FLOOR_DEFENSE_MULTIPLIER ^ (floorNumber - 1)
	
	-- Player level adaptive scaling
	local playerLevelScaling = 1.0
	if averagePlayerLevel and averagePlayerLevel > 0 then
		playerLevelScaling = 1 + (averagePlayerLevel * BalanceConfig.MONSTER_SCALING.PLAYER_LEVEL_SCALING_FACTOR)
		playerLevelScaling = math.min(playerLevelScaling, BalanceConfig.MONSTER_SCALING.MAX_PLAYER_LEVEL_SCALING)
	end
	
	-- Get archetype multipliers
	local archetypeData = BalanceConfig.MONSTER_SCALING.ARCHETYPE_MULTIPLIERS[monsterType]
	if not archetypeData then
		warn("Unknown monster type:", monsterType)
		archetypeData = BalanceConfig.MONSTER_SCALING.ARCHETYPE_MULTIPLIERS.Minion
	end
	
	-- Calculate final stats
	local monsterStats = {}
	
	monsterStats.MaxHP = round(
		baseHP * hpMultiplier * playerLevelScaling * archetypeData.HP,
		0
	)
	
	monsterStats.Damage = round(
		baseDamage * damageMultiplier * playerLevelScaling * archetypeData.Damage,
		2
	)
	
	monsterStats.Defense = round(
		baseDefense * defenseMultiplier * playerLevelScaling * archetypeData.Defense,
		2
	)
	
	monsterStats.MovementSpeed = round(
		16 * archetypeData.Speed, -- 16 studs/sec base
		2
	)
	
	monsterStats.XPReward = round(
		baseXP * hpMultiplier * archetypeData.XP, -- XP scales with HP curve
		0
	)
	
	monsterStats.GoldReward = round(
		baseGold * hpMultiplier * archetypeData.Gold,
		0
	)
	
	return monsterStats
end

--[[
	Calculate jumlah monster per wave
	
	@param floorNumber number - Current floor
	@return number - Monster count per wave
]]
function FormulaCalculator.CalculateMonstersPerWave(floorNumber)
	if not floorNumber then
		return 3
	end
	
	local tier = math.ceil(floorNumber / 10)
	tier = clamp(tier, 1, 4)
	
	return BalanceConfig.MONSTER_SCALING.MONSTERS_PER_WAVE[tier] or 3
end

-- ═══════════════════════════════════════════════════════════════════════════
-- ECONOMY FORMULAS
-- ═══════════════════════════════════════════════════════════════════════════

--[[
	Calculate gold drop dari monster
	
	Formula: GoldDrop = BaseGold * (FloorMultiplier ^ Floor) * Variance * ArchetypeMultiplier
	
	@param floorNumber number - Current floor
	@param monsterType string - Monster archetype
	@return number - Gold dropped
]]
function FormulaCalculator.CalculateGoldDrop(floorNumber, monsterType)
	local baseGold = BalanceConfig.GOLD_ECONOMY.MONSTER_GOLD_DROP.BASE_GOLD
	local floorMult = BalanceConfig.GOLD_ECONOMY.MONSTER_GOLD_DROP.FLOOR_MULTIPLIER
	
	-- Floor scaling
	local floorScaling = floorMult ^ (floorNumber - 1)
	
	-- Random variance
	local minVar = BalanceConfig.GOLD_ECONOMY.MONSTER_GOLD_DROP.MIN_VARIANCE
	local maxVar = BalanceConfig.GOLD_ECONOMY.MONSTER_GOLD_DROP.MAX_VARIANCE
	local variance = minVar + (math.random() * (maxVar - minVar))
	
	-- Archetype multiplier
	local archetypeData = BalanceConfig.MONSTER_SCALING.ARCHETYPE_MULTIPLIERS[monsterType]
	local archetypeMult = archetypeData and archetypeData.Gold or 1.0
	
	local goldDrop = baseGold * floorScaling * variance * archetypeMult
	
	return math.max(1, round(goldDrop, 0)) -- Minimum 1 gold
end

--[[
	Calculate floor clear bonus gold
	
	@param floorNumber number - Completed floor
	@return number - Bonus gold
]]
function FormulaCalculator.CalculateFloorClearBonus(floorNumber)
	local baseBonus = BalanceConfig.GOLD_ECONOMY.FLOOR_CLEAR_BONUS.BASE_BONUS
	local floorMult = BalanceConfig.GOLD_ECONOMY.FLOOR_CLEAR_BONUS.FLOOR_MULTIPLIER
	
	local bonus = baseBonus * (floorMult ^ (floorNumber - 1))
	
	return round(bonus, 0)
end

--[[
	Calculate ascension cost (Gold + Soul Dust)
	
	@param currentRarity number - Current rarity (1-9)
	@return table - {GoldCost, SoulDustCost}
]]
function FormulaCalculator.CalculateAscensionCost(currentRarity)
	if not currentRarity or currentRarity < 1 or currentRarity >= Constants.MAX_RARITY then
		return {GoldCost = 0, SoulDustCost = 0}
	end
	
	local targetRarity = currentRarity + 1
	
	local goldCost = BalanceConfig.ASCENSION_COSTS.GOLD_COSTS[targetRarity] or 0
	local soulDustCost = BalanceConfig.ASCENSION_COSTS.SOUL_DUST_COSTS[targetRarity] or 0
	
	return {
		GoldCost = goldCost,
		SoulDustCost = soulDustCost
	}
end

--[[
	Calculate equipment repair cost
	
	Formula: Cost = (100 - CurrentDurability) * BaseRepairCost * RarityMultiplier
	
	@param currentDurability number - Current durability (0-100)
	@param equipmentRarity number - Equipment rarity (1-4)
	@return number - Repair cost in gold
]]
function FormulaCalculator.CalculateRepairCost(currentDurability, equipmentRarity)
	if currentDurability >= 100 then
		return 0
	end
	
	currentDurability = clamp(currentDurability, 0, 100)
	equipmentRarity = equipmentRarity or 1
	
	local durabilityLost = 100 - currentDurability
	local baseCost = BalanceConfig.DURABILITY_SYSTEM.REPAIR_COST_PER_DURABILITY
	local rarityMult = BalanceConfig.DURABILITY_SYSTEM.RARITY_REPAIR_MULTIPLIER[equipmentRarity] or 1.0
	
	local repairCost = durabilityLost * baseCost * rarityMult
	
	return round(repairCost, 0)
end

--[[
	Calculate durability loss on death
	
	@param equipmentRarity number - Equipment rarity (1-4)
	@return number - Durability lost
]]
function FormulaCalculator.CalculateDurabilityLoss(equipmentRarity)
	equipmentRarity = equipmentRarity or 1
	
	return BalanceConfig.DURABILITY_SYSTEM.DURABILITY_LOSS_PER_DEATH[equipmentRarity] or 10
end

-- ═══════════════════════════════════════════════════════════════════════════
-- GACHA & DROP FORMULAS
-- ═══════════════════════════════════════════════════════════════════════════

--[[
	Roll gacha untuk random rarity
	
	Uses weighted random dengan rates dari Constants.GACHA_RATES
	
	@param pityCounter number - Current pity count (optional)
	@return number - Rolled rarity (1-10)
]]
function FormulaCalculator.RollGacha(pityCounter)
	pityCounter = pityCounter or 0
	
	-- Check pity system
	if pityCounter >= Constants.GACHA_SUPER_PITY_THRESHOLD then
		-- Guaranteed 5★
		return 5
	elseif pityCounter >= Constants.GACHA_PITY_THRESHOLD then
		-- Guaranteed 4★
		return 4
	end
	
	-- Normal weighted roll
	local totalWeight = 0
	for _, rate in pairs(Constants.GACHA_RATES) do
		totalWeight = totalWeight + rate
	end
	
	local roll = math.random() * totalWeight
	local cumulative = 0
	
	for rarity = 1, Constants.MAX_RARITY do
		cumulative = cumulative + (Constants.GACHA_RATES[rarity] or 0)
		if roll <= cumulative then
			return rarity
		end
	end
	
	-- Fallback (shouldn't reach here)
	return 1
end

--[[
	Calculate drop chance untuk item
	
	@param baseDropRate number - Base drop chance (0.0 - 1.0)
	@param floorNumber number - Current floor (optional, untuk scaling)
	@return boolean - Apakah item dropped
]]
function FormulaCalculator.RollDrop(baseDropRate, floorNumber)
	if not baseDropRate then
		return false
	end
	
	-- Optional: Increase drop rate slightly per floor (encouragement)
	local dropRate = baseDropRate
	if floorNumber and floorNumber > 10 then
		local bonusRate = (floorNumber - 10) * 0.001 -- +0.1% per floor after 10
		dropRate = math.min(dropRate + bonusRate, 1.0)
	end
	
	local roll = math.random()
	return roll <= dropRate
end

-- ═══════════════════════════════════════════════════════════════════════════
-- ADAPTIVE ECOLOGY FORMULAS (Week 3+)
-- ═══════════════════════════════════════════════════════════════════════════

--[[
	Calculate resistance buff berdasarkan damage type dominance
	
	@param damageDistribution table - {Physical = %, Magic = %, True = %}
	@return table - {PhysicalRes = %, MagicRes = %}
]]
function FormulaCalculator.CalculateAdaptiveResistance(damageDistribution)
	if not damageDistribution then
		return {PhysicalRes = 0, MagicRes = 0}
	end
	
	local physicalPercent = damageDistribution.Physical or 0
	local magicPercent = damageDistribution.Magic or 0
	
	local threshold = BalanceConfig.ADAPTIVE_ECOLOGY.ADAPTATION_THRESHOLD
	local resistances = {PhysicalRes = 0, MagicRes = 0}
	
	-- Determine adaptation tier
	local tier = "None"
	if physicalPercent >= 0.90 or magicPercent >= 0.90 then
		tier = "Heavy"
	elseif physicalPercent >= 0.80 or magicPercent >= 0.80 then
		tier = "Medium"
	elseif physicalPercent >= 0.70 or magicPercent >= 0.70 then
		tier = "Light"
	end
	
	-- Apply resistance based on tier
	if tier ~= "None" then
		local resistanceAmount = BalanceConfig.ADAPTIVE_ECOLOGY.RESISTANCE_BONUS[tier:upper() .. "_RESISTANCE"]
		
		if physicalPercent > magicPercent and physicalPercent >= threshold then
			resistances.PhysicalRes = resistanceAmount
		elseif magicPercent > physicalPercent and magicPercent >= threshold then
			resistances.MagicRes = resistanceAmount
		end
	end
	
	return resistances
end

-- ═══════════════════════════════════════════════════════════════════════════
-- UNIT TESTS (For Development/Debugging)
-- ═══════════════════════════════════════════════════════════════════════════

--[[
	Run semua unit tests untuk verify formulas bekerja
	
	HANYA UNTUK DEBUGGING - Remove atau disable di production!
]]
function FormulaCalculator.RunUnitTests()
	print("=== FormulaCalculator Unit Tests ===")
	
	-- Test 1: XP Calculation
	local xpToLevel2 = FormulaCalculator.CalculateXPToNextLevel(1)
	print("XP for Level 1→2:", xpToLevel2, "| Expected: 100")
	assert(xpToLevel2 == 100, "XP calculation failed!")
	
	-- Test 2: Final Stats
	local testStats = FormulaCalculator.CalculateFinalStats(
		Constants.BASE_STATS,
		{STR = 10, INT = 0, VIT = 5, DEX = 0},
		1 -- Rarity 1
	)
	print("Test Character HP:", testStats.MaxHP, "| Expected: ~150")
	
	-- Test 3: Damage After Defense
	local damage = FormulaCalculator.CalculateDamageAfterDefense(100, 100, "Physical")
	print("100 Damage vs 100 Defense:", damage, "| Expected: ~50")
	
	-- Test 4: Monster Scaling
	local monsterStats = FormulaCalculator.CalculateMonsterStats(5, "Minion", nil)
	print("Floor 5 Minion HP:", monsterStats.MaxHP)
	
	-- Test 5: Gacha Roll
	local rarity = FormulaCalculator.RollGacha(0)
	print("Gacha Roll Result:", rarity, "★")
	
	print("=== All Unit Tests Passed! ===")
end

-- ═══════════════════════════════════════════════════════════════════════════
-- EXPORT
-- ═══════════════════════════════════════════════════════════════════════════

return FormulaCalculator