local UnitPower = UnitPower
local GetSpecialization = GetSpecialization
local CJRReborn = LibStub("AceAddon-3.0"):GetAddon("CJRReborn")
local CJRHelpers = CJRReborn:GetModule("CJRHelpers")
local CJRPally = CJRReborn:NewModule("CJRPally")

function CJRPally:AoECheckSpell()
	return "Crusader Strike"
end

function CJRPally:AoE(AoETargetList,count)
	spec = GetSpecialization()
	if (spec == 2) then
		self:ProtPallyAoE(count)
	elseif (spec == 3) then
		self:RetributionAoE(count)
	end
end

function CJRPally:SingleTarget()
	spec = GetSpecialization()
	if (spec == 2) then
		self:ProtPallySingleTarget()
	elseif (spec == 3) then
		self:RetributionSingleTarget()
	end
end

function CJRPally:ProtPallySingleTarget()
	--Shield of the Righteous and Word of Glory are both off the GCD, so let's figure these out first
	if (UnitPower("player",9) == 3) then
		if (CJRHelpers:PlayerHealth() < .3) then
			CJRHelpers:CastSpell("Word of Glory","player")
		else
			CJRHelpers:CastSpell("Shield of the Righteous")
		end
	end

	if (CJRHelpers:ShouldInterrupt()) then
		CJRHelpers:CastSpell("Rebuke")
		return
	end

	if (not UnitIsUnit("targettarget","player") and UnitExists("targettarget")) then
		CJRHelpers:CastSpell("Reckoning")
	end

	if (not CJRHelpers:GCDActive()) then
		if (CJRHelpers:ShouldInterrupt() and not SpellCooldownReady("Rebuke")) then
			CJRHelpers:CastSpell("Avenger's Shield")
		end
		if (CJRHelpers:CastSpell("Crusader Strike")) then return end
		if (CJRHelpers:CastSpell("Judgment")) then return end
		if (CJRHelpers:CastSpell("Avenger's Shield")) then return end
		--Tier 6 Talents Block
		if (CJRHelpers:HasSpell("Execution Sentence")) then
			if (CJRHelpers:CastSpell("Execution Sentence")) then
				return
			end
		end
	
		if (CJRHelpers:CastSpell("Holy Wrath","target","Crusader Strike")) then return end	
		if (CJRHelpers:CastSpell("Hammer of Wrath")) then return end
		if (CJRHelpers:CastSpell("Consecration","target","Crusader Strike")) then return end
	end
end

function CJRPally:ProtPallyAoE()
	if (UnitPower("player",9) == 3) then
		if (CJRHelpers:PlayerHealth() < .3) then
			CJRHelpers:CastSpell("Word of Glory")
		else
			CJRHelpers:CastSpell("Shield of the Righteous")
		end
	end

	if (CJRHelpers:ShouldInterrupt()) then
		CJRHelpers:CastSpell("Rebuke")
		return
	end

	if (not UnitIsUnit("targettarget","player") and UnitExists("targettarget")) then
		CJRHelpers:CastSpell("Reckoning")
	end

	if (not CJRHelpers:GCDActive()) then
		if (CJRHelpers:CastSpell("Hammer of the Righteous")) then return end
		if (CJRHelpers:CastSpell("Judgment")) then return end
		if (CJRHelpers:HasAura("Grand Crusader","player")) then	
			if (CJRHelpers:CastSpell("Avenger's Shield")) then return end
		end
		if (CJRHelpers:CastSpell("Consecration","target","Crusader Strike")) then return end
		if (CJRHelpers:CastSpell("Avenger's Shield")) then return end
		--Tier 6 Talents Block
		if (CJRHelpers:HasSpell("Execution Sentence")) then
			if (CJRHelpers:CastSpell("Execution Sentence")) then
				return
			end
		end
		if (CJRHelpers:CastSpell("Holy Wrath","target","Crusader Strike")) then return end
		if (CJRHelpers:CastSpell("Hammer of Wrath")) then return end
	end
end

function CJRPally:RetributionSingleTarget()
	if (CJRHelpers:ShouldInterrupt()) then
		CJRHelpers:CastSpell("Rebuke")
		return
	end

	if (not self:GCDActive()) then
		if (not CJRHelpers:HasAura("Inquisition","player")) then 
			if (CJRHelpers:CastSpell("Inquisition")) then return end
		end
		if (UnitPower("player",9) == 5) then 
			if (CJRHelpers:CastSpell("Templar's Verdict")) then return end
		end
		if (CJRHelpers:CastSpell("Hammer of Wrath")) then return end
		if (CJRHelpers:CastSpell("Crusader Strike")) then return end
		if (CJRHelpers:CastSpell("Exorcism")) then return end
		if (CJRHelpers:CastSpell("Judgment")) then return end
		if (UnitPower("player",9) == 3) then
			if (CJRHelpers:CastSpell("Templar's Verdict")) then return end
		end
	end
end

function CJRPally:RetributionAoE()
	if (CJRHelpers:ShouldInterrupt()) then
		CJRHelpers:CastSpell("Rebuke")
		return
	end

	if (not self:GCDActive()) then
		if (not CJRHelpers:HasAura("Inquisition","player")) then 
			if (CJRHelpers:CastSpell("Inquisition")) then return end
		end
		if (UnitPower("player",9) == 5) then 
			if (CJRHelpers:CastSpell("Divine Storm")) then return end
		end
		if (CJRHelpers:CastSpell("Hammer of Wrath")) then return end
		if (CJRHelpers:CastSpell("Hammer of the Righteous")) then return end
		if (CJRHelpers:CastSpell("Exorcism")) then return end
		if (CJRHelpers:CastSpell("Judgment")) then return end
		if (UnitPower("player",9) == 3) then
			if (CJRHelpers:CastSpell("Divine Storm")) then return end
		end
	end
end