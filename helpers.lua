local CJRReborn = LibStub("AceAddon-3.0"):GetAddon("CJRReborn")
local CJRHelpers = CJRReborn:NewModule("CJRHelpers")

local IsUsableSpell = IsUsableSpell
local GetSpellCooldown = GetSpellCooldown
local UnitBuff = UnitBuff
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local CastSpellByName = CastSpellByName
local IsSpellInRange = IsSpellInRange
local GetUnitSpeed = GetUnitSpeed
local GetSpellInfo = GetSpellInfo
local UnitGUID = UnitGUID
local GetTime = GetTime
local UnitCastingInfo = UnitCastingInfo
local GetTalentInfo = GetTalentInfo

local DoTBlacklist = {}

function CJRHelpers:CalculateSpec()
	--[[
		Spec to Number Mappings
		Mage			Paladin				Warrior				Druid
		62 - Arcane		65 - Holy			71 - Arms			102 - Balance
		63 - Fire		66 - Protection		72 - Fury			103 - Feral Combat
		64 - Frost		70 - Retribution	73 - Protection		104 - Guardian
																105 - Restoration
		
		Hunter					Priest				Rogue
		253 - Beast Mastery		256 - Discipline 	259 - Assassination
		254 - Marksmanship		257 - Holy			260 - Combat
		255 - Survival			258 - Shadow		261 - Subtlety

		Shaman					Warlock				Death Knight	Monk
		262 - Elemental			265 - Affliction	250 - Blood		268 - Brewmaster
		263 - Enhancement		266 - Demonology	251 - Frost		269 - Windwalker
		264 - Restoration		267 - Destruction	252 - Unholy	270 - Mistweaver
	]]
	globalid = GetSpecializationInfo(GetSpecialization())
	return globalid
end

function CJRHelpers:IsMoving()
	return GetUnitSpeed("player") > 0
end

function CJRHelpers:GCDActive()
	start,duration,_ = GetSpellCooldown(61304)
	if (start == 0) then
		_,_,_,_,starttime = UnitCastingInfo("player")
		if (starttime) then
			return true
		else
			return false
		end
	else
		return true
	end
end

function CJRHelpers:HasAura(buffname,target)
	if (not target) then
		target = "player"
	end
	_,_,_,_,_,duration,_,_,_,_,_ = UnitAura(target,buffname,nil,"PLAYER")
	if (duration == nil) then
		return false
	else
		return true
	end
end

function CJRHelpers:IsDummy(target)
	name = UnitName(target)
	if (name:find("Training Dummy") == nil) then
		return false
	else
		return true
	end
end

function CJRHelpers:IsChanneling(target)
	return UnitChannelInfo(target)
end

function CJRHelpers:HasTalent(index)
	_,_,_,_,selected = GetTalentInfo(index)
	return selected
end

function CJRHelpers:AmIFacing(guid)
	return Player:IsFacing(GetObjectFromGUID(guid))
end

function CJRHelpers:IsLoS(guid)
	return GetObjectFromGUID(guid):InLineOfSight()
end

function CJRHelpers:CalculateDoT(dotname,target)
	local guid = UnitGUID("target")
	local key = guid..dotname
	local blacklistTime = DoTBlacklist[key]
	local time = GetTime()
	if (blacklistTime) then
		if (time >= blacklistTime) then
			DoTBlacklist[key] = nil
		else
			return false
		end
	end
	name,_,_,_,_,_,duration = UnitDebuff(target,dotname,nil,"PLAYER")
	_,_,_,_,_,_,casttime = GetSpellInfo(dotname)
	if (not name or ((duration - time) < ((casttime/1000) + 1))) then
		if (CJRHelpers:CastSpell(dotname,target)) then
			blacklistTime = time + (casttime/1000) + 1.5
			DoTBlacklist[key] = blacklistTime
			return true
		else
			return false
		end
	else
		return false
	end
end

function CJRHelpers:PlayerHealth()
	return ((UnitHealth("player") / UnitHealthMax("player")) * 100)
end

function CJRHelpers:TargetHealth(target)
	return ((UnitHealth(target) / UnitHealthMax("player")) * 100)
end


function CJRHelpers:CastSpell(spellname,target,override)
	if (not target) then
		target = "target"
	end

	if (self:CanCast(spellname,target,override)) then
		--print("Casting "..spellname)
		CastSpellByName(spellname,target)
		return true
	else
		return false
	end
end

function CJRHelpers:CanCast(spellname,target,override)
	usable,nomana = IsUsableSpell(spellname)

	if (not usable) then
		return false
	else
		if (self:SpellCooldownReady(spellname)) then
			range = 0
			if (override) then
				range = IsSpellInRange(override,target)
			else
				range = IsSpellInRange(spellname,target)
			end
			if (range == 1) then
				return true
			else
				return false
			end
		else
			return false
		end
	end
end

function CJRHelpers:HasSpell(spellname)
	usable,nomana = IsUsableSpell(spellname)

	if (not usable) then
		if not nomana then
			return false
		else
			return true
		end
	else
		return true
	end
end

function CJRHelpers:SpellCooldownReady(spellname)
	start,duration,_ = GetSpellCooldown(spellname)
	if (start == 0) then
		return true
	else
		return false
	end
end

function CJRHelpers:ShouldInterrupt()
	spell,_,_,_,starttime,endtime,tradeskill,_,interrupt = UnitCastingInfo("target")
	if (spell == nil) then return false end
	casttime = endtime - starttime
	if (casttime < 700) then
		return false
	elseif interrupt or tradeskill then
		return false
	else
		currentcastpoint = endtime - GetTime()
		if (currentcastpoint / casttime < .7) then
			return false
		else
			return true
		end
	end
end