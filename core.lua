local addonname,addontable = ...
local CJRReborn = LibStub("AceAddon-3.0"):NewAddon("CJRReborn","AceConsole-3.0","AceEvent-3.0")
local AceGUI = LibStub("AceGUI-3.0")

local LDB = LibStub("LibDataBroker-1.1",true)
local LDBIcon = LDB and LibStub("LibDBIcon-1.0",true)

local running = false
local frame = CreateFrame("frame")
local ClassModule
local CJRHelpers

local currentspec
local AoE = false
local unsupported = false;
local NextAoEPoll = 0
local AoEList
local AoETargetCount = 0

local moduletable={["PALADIN"]="CJRPally",["WARRIOR"]="CJRWar",["HUNTER"]="CJRHunter",
	["ROGUE"]="CJRRogue",["PRIEST"]="CJRPriest",["DEATHKNIGHT"]="CJRDK",["SHAMAN"]="CJRSham",["MAGE"]="CJRMage",
	["WARLOCK"]="CJRWarlock",["MONK"]="CJRMonk",["DRUID"]="CJRDruid"}

function frame:OnUpdate(elapsed)
	if ((CJRReborn.db.char.AoEMode == 0 or AoE == true) and running) then
		if (GetTime() > NextAoEPoll) then
			local checkspell = ClassModule:AoECheckSpell()
			NextAoEPoll = GetTime() + 1.5
			AoEList = {}
			AoETargetCount = 0
			objects = GetTotalObjects(TYPE_UNIT)
            for entry = 1,objects do
                local targuid = IGetObjectListEntry(entry)
                ISetAsUnitID(targuid,"CheckUnit")
                local object = GetObjectFromGUID(targuid)
                if (UnitCanAttack("player","CheckUnit") and UnitHealth("CheckUnit") > 0 and (UnitAffectingCombat("CheckUnit") == 1 or CJRHelpers:IsDummy("CheckUnit"))) then
                    if (IsSpellInRange(checkspell,"CheckUnit") == 1 and CJRHelpers:AmIFacing(targuid) and CJRHelpers:IsLoS(targuid)) then
                        AoEList[#AoEList+1] = targuid
                        AoETargetCount = AoETargetCount + 1
                    end
                end
            end
        end
        if (CJRReborn.db.char.AoEMode == 0) then
	        if (AoETargetCount > 1) then
	        	if (not AoE) then
	        		CJRReborn:Print("AoE Switched On")
	        		AoE = true
	        	end
	        else
	        	if (AoE) then
		        	CJRReborn:Print("AoE Switched Off")
		        	AoE = false
		        end
	        end
	    end
    end
			

	if (running) then
		if (AoE == true) then
			ClassModule:AoE(AoEList,AoETargetCount)
		elseif (running and UnitExists("target")) then
			ClassModule:SingleTarget()
		end
	end
end

function CJRReborn:OnInitialize()
	CJRReborn:RegisterChatCommand("cjr","StartRotation")
	CJRReborn:RegisterEvent("PLAYER_REGEN_ENABLED","LeaveCombat")
	self.db = LibStub("AceDB-3.0"):New("CJRDB",{
		char={
			minimap={
				hide=false,
			},
			AoEMode=0,
			StopAfterCombat=false
		}
	})
end

function CJRReborn:LeaveCombat()
	if (self.db.char.StopAfterCombat) then
		if (running) then
			running = false

			string = (running == true) and "On" or "Off"
			CJRReborn:Print("CJR is now "..string)
		end
	end
end

function CJRReborn:OnEnable()
	frame:SetAttribute("TimeSinceLastUpdate",0)
	frame:SetScript("OnUpdate",frame.OnUpdate)

	if (LDB) then
		local CJRLauncher = LDB:NewDataObject("CJR", {
			type="launcher",
			icon="Interface\\ICONS\\spell_nature_bloodlust",
			OnClick=function(clickedframe,button)
				if button=="RightButton" then CJRReborn:ShowMenu() elseif button=="LeftButton" 
					then CJRReborn:ShowGUI() end
			end,
		})
		if (LDBIcon) then
			LDBIcon:Register("CJR",CJRLauncher,self.db.char.minimap)
		end
	end
	self:Print("Loaded CJR")
	CJRHelpers = CJRReborn:GetModule("CJRHelpers")
	ClassModule = CJRReborn:GetModule(moduletable[select(2,UnitClass("player"))],true)
	if (ClassModule == nil) then
		self:Print("Your class is currently unsupported!")
		unsupported = true
	end	

	local cjrbutton = CreateFrame("BUTTON","CJRAoEToggleButton")
	SetBindingClick("G",cjrbutton:GetName())
	cjrbutton:SetScript("OnClick",function(self,button,down)
		if (CJRReborn.db.char.AoEMode == 1) then
			AoE = not AoE
			string = (AoE == true) and "On" or "Off"
			CJRReborn:Print("AoE Mode is now "..string)
		end
	end)

	local cjrtoggle = CreateFrame("BUTTON","CJRToggleButton")
	SetBindingClick("F",cjrtoggle:GetName())
	cjrtoggle:SetScript("OnClick",function(self,button,down)
		if not unsupported then
			running = not running
			string = (running == true) and "On" or "Off"
			CJRReborn:Print("CJR is now "..string)
		end
	end)
end

function CJRReborn:ShowMenu()
	local menu = {	
		{text="Configure CJR",isTitle=true,notCheckable=1},
		{text="AoE Mode",hasArrow=true,notCheckable=1,
			menuList={
				{text="Automatic",func=function() self.db.char.AoEMode=0; end,checked=function() return self.db.char.AoEMode == 0 end},
				{text="Manual",func=function() self.db.char.AoEMode=1;end,checked=function() return self.db.char.AoEMode == 1 end}
			}
		},
		{text="Stop After Combat",func=function() 
			self.db.char.StopAfterCombat= not self.db.char.StopAfterCombat end,
			checked=function() return self.db.char.StopAfterCombat == true end,keepShownOnClick=true}
	}

	local menuFrame = CreateFrame("Frame","CJRMenuFrame",UIParent,"UIDropDownMenuTemplate")

	EasyMenu(menu,menuFrame,"cursor",0,0,"MENU",5)
end

function CJRReborn:StartRotation(input)
	if (not unsupported) then
		running = not running
	end
end

function CJRReborn:ShowGUI()
	local configFrame = AceGUI:Create("Frame")
	configFrame:SetTitle("CJR Config")
	configFrame:SetStatusText("Configuration frame for CJRotator")
	configFrame:SetCallback("OnClose",function(widget) AceGUI:Release(widget) end)
	configFrame:SetHeight(300)
	configFrame:SetWidth(500)
	configFrame:SetLayout("Flow")
end