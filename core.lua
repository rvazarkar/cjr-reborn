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
local unsupported = false
local NextAoEPoll = 0
local AoEList
local AoETargetCount = 0
local cjrbutton
local cjrtoggle
local configopen = false

local moduletable={["PALADIN"]="CJRPally",["WARRIOR"]="CJRWar",["HUNTER"]="CJRHunter",
	["ROGUE"]="CJRRogue",["PRIEST"]="CJRPriest",["DEATHKNIGHT"]="CJRDK",["SHAMAN"]="CJRSham",["MAGE"]="CJRMage",
	["WARLOCK"]="CJRWarlock",["MONK"]="CJRMonk",["DRUID"]="CJRDruid"}

function frame:OnUpdate(elapsed)
	if (unsupported or not FireHack) then return end

	if (CJRReborn.db.char.MaintainBuffs) then
		if (ClassModule:CheckBuffs()) then return end
	end

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
	        if (AoETargetCount > self.db.char.AoEThreshold) then
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
	CJRReborn:RegisterChatCommand("cjr","ShowGUI")
	CJRReborn:RegisterEvent("PLAYER_REGEN_ENABLED","LeaveCombat")
	CJRReborn:RegisterEvent("PLAYER_REGEN_DISABLED",function() NextAoEPoll=0 end)
	self.db = LibStub("AceDB-3.0"):New("CJRDB",{
		char={
			minimap={
				hide=false,
			},
			AoEMode=0,
			StopAfterCombat=false,
			AoEButton="G",
			ToggleButton="F",
			MaintainBuffs=false,
			AoEThreshold=2
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

function CJRReborn:TalentsChanged()
	if (not ClassModule:IsSupportedSpec()) then
		unsupported = true
		self:Print("Your new specialization is unsupported. CJR Disabled")
	else
		unsupported = false
		self:Print("Your new specialization is supported. CJR Enabled")
	end
end

function CJRReborn:OnEnable()
	StaticPopupDialogs["CJR_UNSUPPORTED"] = {
		text="Your current specialization is unsupported by CJR",
		button1="Ok",
		timeout=0,
		hideOnEscape=true,
		preferredIndex=3
	}
	frame:SetAttribute("TimeSinceLastUpdate",0)
	frame:SetScript("OnUpdate",frame.OnUpdate)

	if (LDB) then
		local CJRLauncher = LDB:NewDataObject("CJR", {
			type="launcher",
			icon="Interface\\ICONS\\spell_nature_bloodlust",
			OnClick=function(clickedframe,button)
				if button=="RightButton" then 
					CJRReborn:ShowMenu() 
				elseif (button=="LeftButton" and configopen==false) then
					CJRReborn:ShowGUI() 
				end
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
		StaticPopup_Show("CJR_UNSUPPORTED")
		unsupported = true
	elseif (not ClassModule:IsSupportedSpec()) then
		StaticPopup_Show("CJR_UNSUPPORTED")
		unsupported = true
	end	

	cjrbutton = CreateFrame("BUTTON","CJRAoEToggleButton")
	SetBindingClick(self.db.char.AoEButton,cjrbutton:GetName())
	cjrbutton:SetScript("OnClick",function(self,button,down)
		if (CJRReborn.db.char.AoEMode == 1) then
			AoE = not AoE
			string = (AoE == true) and "On" or "Off"
			CJRReborn:Print("AoE Mode is now "..string)
		end
	end)

	cjrtoggle = CreateFrame("BUTTON","CJRToggleButton")
	SetBindingClick(self.db.char.ToggleButton,cjrtoggle:GetName())
	cjrtoggle:SetScript("OnClick",function(self,button,down)
		if not unsupported then
			running = not running
			string = (running == true) and "On" or "Off"
			CJRReborn:Print("CJR is now "..string)
		end
	end)

	CJRReborn:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED","TalentsChanged")
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
			checked=function() return self.db.char.StopAfterCombat == true end,keepShownOnClick=true},
		{text="Maintain Buffs",func=function()
			self.db.char.MaintainBuffs=not self.db.char.MaintainBuffs end,
			checked=function() return self.db.char.MaintainBuffs == true end,keepShownOnClick=true}
	}

	local menuFrame = CreateFrame("Frame","CJRMenuFrame",UIParent,"UIDropDownMenuTemplate")

	EasyMenu(menu,menuFrame,"cursor",0,0,"MENU",5)
end

function CJRReborn:StartRotation(input)
	if (not unsupported) then
		running = not running
	end
end

function CJRReborn:CJRGuiTab(container)
	local cjrkeybind = AceGUI:Create("Keybinding")
	cjrkeybind:SetKey(self.db.char.ToggleButton)
	cjrkeybind:SetLabel("CJR Toggle Keybind")
	cjrkeybind.width = "fill"
	cjrkeybind:SetCallback("OnKeyChanged",function(key)
		SetBinding(CJRReborn.db.char.ToggleButton)
		SetBindingClick(cjrkeybind:GetKey(),cjrtoggle:GetName())
		CJRReborn.db.char.ToggleButton = cjrkeybind:GetKey()
	end)
	container:AddChild(cjrkeybind)

	local checkbox = AceGUI:Create("CheckBox")
	checkbox:SetValue(self.db.char.StopAfterCombat)
	checkbox:SetCallback("OnValueChanged",function (value)
		CJRReborn.db.char.StopAfterCombat = not CJRReborn.db.char.StopAfterCombat
	end)
	checkbox:SetLabel("Stop CJR After Combat")
	container:AddChild(checkbox)

	local buffbox = AceGUI:Create("CheckBox")
	buffbox:SetValue(self.db.char.MaintainBuffs)
	buffbox:SetCallback("OnValueChanged",function (value)
		CJRReborn.db.char.MaintainBuffs = not CJRReborn.db.char.MaintainBuffs
	end)
	buffbox:SetLabel("Recast Buffs Automatically")
	container:AddChild(buffbox)

	local aoeheading = AceGUI:Create("Heading")
	aoeheading:SetText("AoE Options")
	aoeheading.width = "fill"
	container:AddChild(aoeheading)

	local aoekeybind = AceGUI:Create("Keybinding")
	aoekeybind:SetKey(self.db.char.AoEButton)
	aoekeybind:SetLabel("AoE Toggle Keybind")
	aoekeybind.width = "fill"
	aoekeybind:SetCallback("OnKeyChanged",function(key)
		SetBinding(CJRReborn.db.char.AoEButton)
		SetBindingClick(aoekeybind:GetKey(),cjrbutton:GetName())
		CJRReborn.db.char.AoEButton = aoekeybind:GetKey()
	end)
	container:AddChild(aoekeybind)

	local aoedropdown = AceGUI:Create("Dropdown")
	aoedropdown:SetList({
		["auto"] = "Automatic",
		["manual"] = "Manual",
	})
	aoedropdown:SetValue(self.db.char.AoEMode == 0 and "auto" or "manual")
	aoedropdown:SetLabel("AoE Selection Mode")

	aoedropdown:SetCallback("OnValueChanged",function(choice)
		if (choice=="auto") then
			CJRReborn.db.char.AoEMode = 0
			aoekeybind:SetDisabled(true)
		else
			CJRReborn.db.char.AoEMode = 1
			aoekeybind:SetDisabled(false)
		end
	end)
	aoedropdown.width = "fill"
	container:AddChild(aoedropdown)

	local autolabel = AceGUI:Create("Label")
	autolabel:SetText("Automatic - Swaps between AoE and Single Target Automatically")
	autolabel.width = "fill"
	container:AddChild(autolabel)

	local manuallabel = AceGUI:Create("Label")
	manuallabel:SetText("Manual - Choose AoE and Single Target using Keybind")
	manuallabel.width = "fill"
	container:AddChild(manuallabel)

	local aoeslider = AceGUI:Create("Slider")
	aoeslider:SetLabel("Automatic AoE Threshold")
	aoeslider:SetSliderValues(2,8,1)
	aoeslider:SetValue(self.db.char.AoEThreshold)
	aoeslider:SetIsPercent(false)
	aoeslider.width = "fill"
	aoeslider:SetCallback("OnMouseUp",function(value)
		CJRReborn.db.char.AoEThreshold = aoeslider:GetValue()
	end)
	container:AddChild(aoeslider)
end

function CJRReborn:ShowGUI()
	configopen = true
	local configFrame = AceGUI:Create("Frame")
	configFrame:SetTitle("CJR Config")
	configFrame:SetStatusText("Configuration frame for CJRotator")
	configFrame:SetCallback("OnClose",function(widget) configopen = false; AceGUI:Release(widget) end)
	configFrame:SetHeight(400)
	configFrame:SetWidth(400)
	configFrame:SetLayout("Fill")

	local tabgroup = AceGUI:Create("TabGroup")
	tabgroup:SetLayout("Flow")
	tabgroup:SetTabs({
		{text="CJR Config",value="tab1"},{text="Class Config",value="tab2"}
		})
	tabgroup:SetCallback("OnGroupSelected",function(container,event,group)
		container:ReleaseChildren()
		if group == "tab1" then
			CJRReborn:CJRGuiTab(container)
		elseif group == "tab2" then
			ClassModule:SetClassConfigFrame(container)
		end
	end)
	tabgroup:SelectTab("tab1")
	configFrame:AddChild(tabgroup)
end