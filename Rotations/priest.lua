local CJRReborn = LibStub("AceAddon-3.0"):GetAddon("CJRReborn")
local CJRHelpers = CJRReborn:GetModule("CJRHelpers")
local CJRPriest = CJRReborn:NewModule("CJRPriest")

local UnitPower = UnitPower
local UnitGUID = UnitGUID
local GetSpecialization = GetSpecialization

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

function CJRPriest:SetClassConfigFrame(container)

end

function CJRPriest:CheckBuffs()
    if (not CJRHelpers:GCDActive()) then
        spec = GetSpecialization()
        if (spec == 3) then
            if (not CJRHelpers:HasAura("Shadowform","player")) then
                CastSpellByName("Shadowform")
                return true
            end

            if (not CJRHelpers:HasAura("Power Word: Fortitude","player")) then
                CastSpellByName("Power Word: Fortitude")
                return true
            end

            if (not CJRHelpers:HasAura("Inner Fire","player")) then
                CastSpellByName("Inner Fire")
                return true
            end
        end
    end

    return false
end

function CJRPriest:ShadowAoE(AoEList,count)
    if (not CJRHelpers:GCDActive()) then
        if (count >= 5 and not CJRHelpers:IsMoving()) then
            if (not CJRHelpers:IsChanneling("player")) then
                if (not UnitExists("target")) then
                    ISetAsUnitID(AoEList[1],"CastUnit")
                    if (CJRHelpers:CastSpell("Mind Sear","CastUnit")) then return end
                else
                    if (CJRHelpers:CastSpell("Mind Sear")) then return end
                end
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
            if (not UnitExists("target")) then
                casttarget = "CastUnit"
            else
                casttarget = "target"
            end

            if (CJRHelpers:IsMoving()) then
                if (orbs == 3) then
                    if (CJRHelpers:CastSpell("Devouring Plague",casttarget)) then return end
                end

                if (CJRHelpers:CastSpell("Halo",casttarget,"Shadow Word: Pain")) then return end
            else
                if (orbs == 3) then
                    if (CJRHelpers:CastSpell("Devouring Plague",casttarget)) then return end
                end

                if (CJRHelpers:CastSpell("Mind Blast",casttarget)) then return end
                if (CJRHelpers:CastSpell("Shadow Word: Death",casttarget)) then return end
                if (CJRHelpers:HasAura("Devouring Plague",casttarget) and CJRHelpers:HasTalent(9)) then
                    name,_,_,_,_,endtime = CJRHelpers:IsChanneling("player")
                    if (not name or (name == "Mind Sear" and (endtime - (GetTime()*1000) < 1))) then
                        if (CJRHelpers:CastSpell("Mind Sear",casttarget,"Shadow Word: Pain")) then return end
                    end
                end

                if (CJRHelpers:CastSpell("Halo",casttarget,"Shadow Word: Pain")) then return end
                name,_,_,_,_,endtime = CJRHelpers:IsChanneling("player")
                if (not name or (name == "Mind Sear" and (endtime - (GetTime()*1000) < 1))) then
                    if (CJRHelpers:CastSpell("Mind Sear",casttarget,"Shadow Word: Pain")) then return end
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