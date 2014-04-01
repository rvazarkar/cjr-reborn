local CJRReborn = LibStub("AceAddon-3.0"):GetAddon("CJRReborn")
local CJRHelpers = CJRReborn:GetModule("CJRHelpers")
local CJRPriest = CJRReborn:NewModule("CJRPriest")

local UnitPower = UnitPower

function CJRPriest:ShadowSingleTarget()
    if (not CJRHelpers:GCDActive()) then
        orbs = UnitPower("player",13)

        if (CJRHelpers:IsMoving()) then
            if (orbs == 3) then
                if (CJRHelpers:CastSpell("Devouring Plague")) then return end
            end

            if (CJRHelpers:CastSpell("Shadow Word: Death")) then return end
            if (CJRHelpers:CalculateDoT("Shadow Word: Pain","target")) then return end
            if (CJRHelpers:CastSpell("Halo","target","Shadow Word: Pain")) then return end
        else
            if (orbs == 3) then
                if (CJRHelpers:CastSpell("Devouring Plague")) then return end
            end

            if (CJRHelpers:CastSpell("Mind Blast")) then return end
            if (CJRHelpers:CastSpell("Shadow Word: Death")) then return end
            if (CJRHelpers:HasAura("Devouring Plague","target") and CJRHelpers:HasTalent(9)) then
                if (CJRHelpers:CastSpell("Mind Flay")) then return end
            end

            if (CJRHelpers:CalculateDoT("Shadow Word: Pain","target")) then return end
            if (CJRHelpers:CalculateDoT("Vampiric Embrace","target")) then return end
            if (CJRHelpers:CastSpell("Halo","target","Shadow Word: Pain")) then return end
            if (CJRHelpers:CastSpell("Mind Flay")) then return end
        end
end