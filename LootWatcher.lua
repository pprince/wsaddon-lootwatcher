-----------------------------------------------------------------------------------------------
-- Client Lua Script for LootWatcher
-- Copyright (c) NCsoft. All rights reserved
-----------------------------------------------------------------------------------------------
 
require "Window"
 
-----------------------------------------------------------------------------------------------
-- LootWatcher Module Definition
-----------------------------------------------------------------------------------------------
local LootWatcher = {} 

-----------------------------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------------------------
-- e.g. local kiExampleVariableMax = 999
 
-----------------------------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------------------------
function LootWatcher:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self 

    -- initialize variables here

    return o
end

function LootWatcher:Init()
	local bHasConfigureFunction = false
	local strConfigureButtonText = ""
	local tDependencies = {
		-- "UnitOrPackageName",
	}
    Apollo.RegisterAddon(self, bHasConfigureFunction, strConfigureButtonText, tDependencies)
end
 

-----------------------------------------------------------------------------------------------
-- LootWatcher OnLoad
-----------------------------------------------------------------------------------------------
function LootWatcher:OnLoad()
    -- load our form file
	self.xmlDoc = XmlDoc.CreateFromFile("LootWatcher.xml")
	self.xmlDoc:RegisterCallback("OnDocLoaded", self)
end

-----------------------------------------------------------------------------------------------
-- LootWatcher OnDocLoaded
-----------------------------------------------------------------------------------------------
function LootWatcher:OnDocLoaded()

	if self.xmlDoc ~= nil and self.xmlDoc:IsLoaded() then
	    self.wndMain = Apollo.LoadForm(self.xmlDoc, "LootWatcherForm", nil, self)
		if self.wndMain == nil then
			Apollo.AddAddonErrorText(self, "Could not load the main window for some reason.")
			return
		end
		self.tLootLog = {}
	    self.wndMain:Show(false, true)

		-- if the xmlDoc is no longer needed, you should set it to nil
		-- self.xmlDoc = nil
		
		-- Register handlers for events, slash commands and timer, etc.
		-- e.g. Apollo.RegisterEventHandler("KeyDown", "OnKeyDown", self)
		Apollo.RegisterSlashCommand("lootlist", "OnLootWatcherOn", self)
		Apollo.RegisterEventHandler("ChatMessage", "OnChatMessage", self)


		-- Do additional Addon initialization here
	end
end

-----------------------------------------------------------------------------------------------
-- LootWatcher Functions
-----------------------------------------------------------------------------------------------
-- Define general functions here

-- on SlashCommand "/lootlist"
function LootWatcher:OnLootWatcherOn()
	self.json = Apollo.GetPackage("Lib:dkJSON-2.5").tPackage
	self.wndMain:Invoke() -- show the window
	--SendVarToRover("Loot List",self.tLootLog)
	self.wndMain:FindChild("CopyBox"):SetText(self.json.encode(self.tLootLog))

end

function LootWatcher:OnChatMessage(channelCurrent, tMessage)
if channelCurrent:GetName() == "Loot" then
	local strMessage = ""
		for idx, tSegment in ipairs(tMessage.arMessageSegments) do
			strMessage = strMessage .. tSegment.strText
		end
		if strMessage:match("The Master Looter") then
		table.insert(self.tLootLog, strMessage)
		--SendVarToRover("Message ".. channelCurrent:GetName(),tMessage)
		--ChatSystemLib.Command('/p ' ..  " Logging that " .. strMessage)
		end
			--fixme self.tLootLog:insert(strMessage)
	end
end

-----------------------------------------------------------------------------------------------
-- LootWatcher Cleaner Functions
-----------------------------------------------------------------------------------------------
 function LootWatcher:OnClearLog()
	self.tLootLog = {}
 end

 function LootWatcher:OnUpdateLog()
 	self.wndMain:FindChild("CopyBox"):SetText(self.json.encode(self.tLootLog))
 end


-----------------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------------
function LootWatcher:OnSave(eLevel)
    if eLevel ~= GameLib.CodeEnumAddonSaveLevel.Character then
        return nil
    end
    return  self.tLootLog
end

function LootWatcher:OnRestore(eLevel, tSaveData)
	if self.tLootLog then
		self.tLootLog = tSaveData
	end
end


-----------------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------
-- LootWatcherForm Functions
-----------------------------------------------------------------------------------------------
-- when the OK button is clicked
function LootWatcher:OnOK()
	self.wndMain:Close() -- hide the window
end

-- when the Cancel button is clicked
function LootWatcher:OnCancel()
	self.wndMain:Close() -- hide the window
end


-----------------------------------------------------------------------------------------------
-- LootWatcher Instance
-----------------------------------------------------------------------------------------------
local LootWatcherInst = LootWatcher:new()
LootWatcherInst:Init()
