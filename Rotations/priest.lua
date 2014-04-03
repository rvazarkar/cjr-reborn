local CJRReborn = LibStub("AceAddon-3.0"):GetAddon("CJRReborn")
local CJRHelpers = CJRReborn:GetModule("CJRHelpers")
local CJRPriest = CJRReborn:NewModule("CJRPriest")

local UnitPower = UnitPower
local UnitGUID = UnitGUID

function CJRPriest:IsSupportedSpec()
    spec = GetSpecialization()
    if (spec == 3) then return true else return false end
end

function CJRPriest:SingleTarget()
    self:ShadowSingleTarget()
end

function CJRPriest:AoE(AoEList,count)
    self:ShadowAoE(AoEList,count)
end

function CJRPriest:AoECheckSpell()
    return "Shadow Word: Pain"
end

function CJRPriest:ShadowAoE(AoEList,count)
    if (not CJRHelpers:GCDActive()) then
        if (count >= 5) then
            if (not CJRHelpers:IsChanneling("player")) then
                if (CJRHelpers:CastSpell("Mind Sear")) then return end
            end
        else
            for k=1,#AoEList do
                local object = AoEList[k]
                ISetAsUnitID(object,"CastUnit")
                if (CJRHelpers:IsMoving()) then
                    if (CJRHelpers:CalculateDoT("Shadow Word: Pain","CastUnit")) then return end
                else
                    if (CJRHelpers:CalculateDoT("Shadow Word: Pain","CastUnit")) then return end
                    if (CJRHelpers:CalculateDoT("Vampiric Touch","CastUnit")) then return end
                end
            end
            orbs = UnitPower("player",13)
            if (CJRHelpers:IsMoving()) then
                if (orbs == 3) then
                    if (CJRHelpers:CastSpell("Devouring Plague")) then return end
                end

                if (CJRHelpers:CastSpell("Halo","target","Shadow Word: Pain")) then return end
            else
                if (orbs == 3) then
                    if (CJRHelpers:CastSpell("Devouring Plague")) then return end
                end

                if (CJRHelpers:CastSpell("Mind Blast")) then return end
                if (CJRHelpers:CastSpell("Shadow Word: Death")) then return end
                if (CJRHelpers:HasAura("Devouring Plague","target") and CJRHelpers:HasTalent(9)) then
                    name,_,_,_,_,endtime = CJRHelpers:IsChanneling("player")
                    if (not name or (name == "Mind Sear" and (endtime - (GetTime()*1000) < 1))) then
                        if (CJRHelpers:CastSpell("Mind Sear","target","Shadow Word: Pain")) then return end
                    end
                end

                if (CJRHelpers:CastSpell("Halo","target","Shadow Word: Pain")) then return end
                name,_,_,_,_,endtime = CJRHelpers:IsChanneling("player")
                if (not name or (name == "Mind Sear" and (endtime - (GetTime()*1000) < 1))) then
                    if (CJRHelpers:CastSpell("Mind Sear","target","Shadow Word: Pain")) then return end
                end
            end
        end
    end
end

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
                name,_,_,_,_,endtime = CJRHelpers:IsChanneling("player")
                if (not name or (name == "Mind Flay" and (endtime - (GetTime()*1000) < 1))) then
                    if (CJRHelpers:CastSpell("Mind Flay","target","Shadow Word: Pain")) then return end
                end
            end

            if (CJRHelpers:CalculateDoT("Shadow Word: Pain","target")) then return end
            if (CJRHelpers:CalculateDoT("Vampiric Touch","target")) then return end
            if (CJRHelpers:CastSpell("Halo","target","Shadow Word: Pain")) then return end
            name,_,_,_,_,endtime = CJRHelpers:IsChanneling("player")
            if (not name or (name == "Mind Flay" and (endtime - (GetTime()*1000) < 1))) then
                if (CJRHelpers:CastSpell("Mind Flay","target","Shadow Word: Pain")) then return end
            end
        end
    end
end