
local RunService = game:GetService("RunService")
local StudioService = game:GetService("StudioService")
local SelectionService = game:GetService("Selection")

local DefaultLocalScriptSettingKey = "DefaultLocalScripts_DefaultLocalScript"
local DefaultUniversalLocalScriptSettingKey = "DefaultLocalScripts_DefaultUniversalLocalScript"
local CustomDefaultLocalScriptSettingKey = "DefaultLocalScripts_CustomDefaultLocalScript"
local CustomDefaultUniversalLocalScriptSettingKey = "DefaultLocalScripts_CustomDefaultUniversalLocalScript"

local CreatorName = game.Players:GetNameFromUserIdAsync(StudioService:GetUserId())
local NewDefaultLocalScript = script.LocalScriptStyles.Default_Style1
local CustomDefaultLocalScript = script.DefaultCustomLocal.Source
local NewDefaultUniversalLocalScript = script.LocalUniversalStyles.Universal_Style1
local CustomDefaultUniversalLocalScript = script.DefaultCustomUniversal.Source
local OldDefaultScript = script.OldDefaultScript

local DefaultScriptSelectedIcon =		"rbxassetid://413366777"
local DefaultScriptNotSelectedIcon =	"rbxassetid://5668278053"

-- Load
do
	local _DefaultLocalScript = plugin:GetSetting(DefaultLocalScriptSettingKey)
	if _DefaultLocalScript == "Custom" then
		NewDefaultLocalScript = _DefaultLocalScript
	elseif _DefaultLocalScript then
		local _DefaultLocalScript = script.LocalScriptStyles:FindFirstChild(tostring(_DefaultLocalScript))
		if _DefaultLocalScript then
			NewDefaultLocalScript = _DefaultLocalScript
		end
	end
	
	local _DefaultUniversalLocalScript = plugin:GetSetting(DefaultUniversalLocalScriptSettingKey)
	if _DefaultUniversalLocalScript == "Custom" then
		NewDefaultUniversalLocalScript = _DefaultUniversalLocalScript
	elseif _DefaultUniversalLocalScript then
		local _DefaultUniversalLocalScript = script.LocalUniversalStyles:FindFirstChild(tostring(_DefaultUniversalLocalScript))
		if _DefaultUniversalLocalScript then
			NewDefaultUniversalLocalScript = _DefaultUniversalLocalScript
		end
	end
	
	local _CustomDefaultLocalScript = plugin:GetSetting(CustomDefaultLocalScriptSettingKey)
	if _CustomDefaultLocalScript then
		CustomDefaultLocalScript = _CustomDefaultLocalScript
	end
	
	local _CustomDefaultUniversalLocalScript = plugin:GetSetting(CustomDefaultUniversalLocalScriptSettingKey)
	if _CustomDefaultUniversalLocalScript then
		CustomDefaultUniversalLocalScript = _CustomDefaultUniversalLocalScript
	end
end

-- helpers
function IsDecendantOfAPlayerCharacter(Obj)
	for i, player in ipairs(game.Players:GetPlayers()) do
		local character = player.Character
		if character and character:IsDescendantOf(workspace) then
			local IsDecendant = Obj:IsDescendantOf(player.Character) or Obj == player.Character
			if IsDecendant then return true end
		end
	end
	return false
end
function IsDecendantOfAPlayerBackpack(Obj : LocalScript)
	for i, player in ipairs(game.Players:GetPlayers()) do
		local IsDecendant = Obj:IsDescendantOf(player.Backpack) or Obj == player.Backpack
		if IsDecendant then return true end
	end
	return false
end
function CanLocalScriptRunUniversally(Obj : LocalScript)
	local UniversalLocalScriptsOBJ = game.ReplicatedFirst:FindFirstChild("UniversalLocalScripts")
	if not UniversalLocalScriptsOBJ then return false end

	local RunInPlayerCharacters = UniversalLocalScriptsOBJ:GetAttribute("RunInPlayerCharacters")
	local RunInPlayerBackpacks = UniversalLocalScriptsOBJ:GetAttribute("RunInPlayerBackpacks")
	local RunInCurrentCamera = UniversalLocalScriptsOBJ:GetAttribute("RunInCurrentCamera")
	local RunInWorkspace = UniversalLocalScriptsOBJ:GetAttribute("RunInWorkspace")

	if IsDecendantOfAPlayerCharacter(Obj) or Obj:IsDescendantOf(game.StarterPlayer.StarterCharacterScripts) then
		return RunInPlayerCharacters end -- this needs to run before the RunInWorkspace check.
	if IsDecendantOfAPlayerBackpack(Obj) or Obj:IsDescendantOf(game.StarterPack) then
		return RunInPlayerBackpacks end
	if Obj:IsDescendantOf(workspace.CurrentCamera) then return RunInCurrentCamera end -- this needs to run before the RunInWorkspace check.
	if Obj:IsDescendantOf(workspace) or Obj == workspace then return RunInWorkspace end -- this needs to be last.

	return false
end

-- Replace contents of (presumably) new scripts.
StudioService:GetPropertyChangedSignal("ActiveScript"):Connect(function()
	if not StudioService.ActiveScript then return end
	if StudioService.ActiveScript:IsA("LocalScript") == false or StudioService.ActiveScript.Name == "OldDefaultScript" then return end -- this second exception is for this plugin.
	if StudioService.ActiveScript.Source ~= OldDefaultScript.Source then return end
	
	local canRunUniversally = CanLocalScriptRunUniversally(StudioService.ActiveScript)
	
	print("Replacing the contents of", StudioService.ActiveScript:GetFullName())
	
	local CustomDefaultScript = CustomDefaultLocalScript
	if canRunUniversally then
		CustomDefaultScript = CustomDefaultUniversalLocalScript
	end
	
	local NewDefaultScript = NewDefaultLocalScript
	if canRunUniversally then
		NewDefaultScript = NewDefaultUniversalLocalScript
	end
	
	local Code = CustomDefaultScript
	if NewDefaultScript and NewDefaultScript ~= "Custom" then
		Code = NewDefaultScript.Source
	end
	StudioService.ActiveScript.Source = string.gsub(Code, "%%CREATORUSERNAME%%", CreatorName, 1)
	if canRunUniversally then
		StudioService.ActiveScript:SetAttribute("RunUniversally", true)
	end
	
	-- close and re-open script because Roblox doesn't show the updated code anymore for some  reason.
	local scriptToSelect = StudioService.ActiveScript
	local newParent = scriptToSelect.Parent
	scriptToSelect.Parent = nil
	RunService.RenderStepped:Wait()
	scriptToSelect.Parent = newParent
	plugin:OpenScript(scriptToSelect, 100)
	SelectionService:Set({scriptToSelect})
end)

-- This was excessive.
--game.DescendantAdded:Connect(function(Decendant)
--	if RunService:IsRunning() then return end

--	local success, msg = pcall(function() _ = Decendant.Parent end) -- indexing some items throws an error for some reason.
--	if not success then return end

--	if Decendant.Parent == game then return end
--	if Decendant:IsA("LocalScript") then
--		if Decendant.Source == OldDefaultScript.Source then
--			print("Replacing the contents of", Decendant:GetFullName())
--			Decendant.Source = string.gsub(script.NewDefaultScript.Source, "%%CREATORUSERNAME%%", CreatorName, 1)
--		end
--	end
--end)

-- Settings
Actions = {}
function OpenSettings()
	-- regular LocalScript styles
	DefaultLocalScriptMenu:Clear()
	for i, styleScript in ipairs(script.LocalScriptStyles:GetChildren()) do
		local Selected = styleScript == NewDefaultLocalScript
		if Selected then
			DefaultLocalScriptMenu:AddAction(Actions[styleScript].Selected)
		else
			DefaultLocalScriptMenu:AddAction(Actions[styleScript].Deselected)
		end
	end
	if NewDefaultLocalScript == "Custom" then
		DefaultLocalScriptMenu:AddAction(SetCustomDefaultLocalScriptAction_Selected)
	else
		DefaultLocalScriptMenu:AddAction(SetCustomDefaultLocalScriptAction_Deselected)
	end
	
	-- universal LocalScript styles
	DefaultUniversalLocalScriptMenu:Clear()
	for i, styleScript in ipairs(script.LocalUniversalStyles:GetChildren()) do
		local Selected = styleScript == NewDefaultUniversalLocalScript
		if Selected then
			DefaultUniversalLocalScriptMenu:AddAction(Actions[styleScript].Selected)
		else
			DefaultUniversalLocalScriptMenu:AddAction(Actions[styleScript].Deselected)
		end
	end
	if NewDefaultUniversalLocalScript == "Custom" then
		DefaultUniversalLocalScriptMenu:AddAction(SetCustomDefaultUniversalLocalScriptAction_Selected)
	else
		DefaultUniversalLocalScriptMenu:AddAction(SetCustomDefaultUniversalLocalScriptAction_Deselected)
	end
	
	SettingsMenu:ShowAsync()
end
function SetCustomDefaultLocalScript()
	NewDefaultLocalScript = "Custom"
	plugin:SetSetting(DefaultLocalScriptSettingKey, "Custom")

	-- Editing:
	warn("Editing custom default local script. Close the tab when done.")

	CustomDefaultLocalScript = OpenDefaultScriptEditor("Custom default local script (close when done)", CustomDefaultLocalScript)
	plugin:SetSetting(CustomDefaultLocalScriptSettingKey, CustomDefaultLocalScript)
	warn("Saved custom default local script.")
end
function SetCustomDefaultUniversalLocalScript()
	NewDefaultUniversalLocalScript = "Custom"
	plugin:SetSetting(DefaultUniversalLocalScriptSettingKey, "Custom")

	-- Editing:
	warn("Editing custom default universal local script. Close the tab when done.")

	CustomDefaultUniversalLocalScript = OpenDefaultScriptEditor("Custom default universal local script (close when done)", CustomDefaultUniversalLocalScript)
	plugin:SetSetting(CustomDefaultUniversalLocalScriptSettingKey, CustomDefaultUniversalLocalScript)
	warn("Saved custom default universal local script.")
end
function OpenDefaultScriptEditor(title : string, defaultScriptContent : string)
	local EditingScript = Instance.new("LocalScript")
	EditingScript.Disabled = true
	EditingScript.Name = title
	EditingScript.Source = defaultScriptContent
	EditingScript.Parent = game.ServerStorage
	plugin:OpenScript(EditingScript)
	repeat wait() until StudioService.ActiveScript ~= EditingScript
	local finalCode = EditingScript.Source 
	EditingScript:Destroy()
	return finalCode
end

for i, styleScript in ipairs(script.LocalScriptStyles:GetChildren()) do
	local DeselectedAction = plugin:CreatePluginAction(
		"DefaultLocalScripts_DefaultLocalScript_".. styleScript.Name.."_Deselected",	-- unique id
		styleScript.Name,											-- name
		"Set the contents of newly created LocalScripts",			-- desc/tooltip
		DefaultScriptNotSelectedIcon,								-- iconId
		false														-- allow binding
	)
	local SelectedAction = plugin:CreatePluginAction(
		"DefaultLocalScripts_DefaultLocalScript_".. styleScript.Name.."_Selected",	-- unique id
		styleScript.Name,											-- name
		"Set the contents of newly created LocalScripts",			-- desc/tooltip
		DefaultScriptSelectedIcon, 									-- iconId
		false														-- allow binding
	)

	DeselectedAction.Triggered:Connect(function()
		NewDefaultLocalScript = styleScript
		plugin:SetSetting(DefaultLocalScriptSettingKey, styleScript.Name)
	end)

	Actions[styleScript] = {Deselected = DeselectedAction, Selected = SelectedAction}
end
for i, styleScript in ipairs(script.LocalUniversalStyles:GetChildren()) do
	local DeselectedAction = plugin:CreatePluginAction(
		"DefaultLocalScripts_DefaultUniversalLocalScript_".. styleScript.Name.."_Deselected",	-- unique id
		styleScript.Name,											-- name
		"Set the contents of newly created Universal LocalScripts",			-- desc/tooltip
		DefaultScriptNotSelectedIcon,								-- iconId
		false														-- allow binding
	)
	local SelectedAction = plugin:CreatePluginAction(
		"DefaultLocalScripts_DefaultUniversalLocalScript_".. styleScript.Name.."_Selected",	-- unique id
		styleScript.Name,											-- name
		"Set the contents of newly created Universal LocalScripts",			-- desc/tooltip
		DefaultScriptSelectedIcon, 									-- iconId
		false														-- allow binding
	)

	DeselectedAction.Triggered:Connect(function()
		NewDefaultUniversalLocalScript = styleScript
		plugin:SetSetting(DefaultUniversalLocalScriptSettingKey, styleScript.Name)
	end)

	Actions[styleScript] = {Deselected = DeselectedAction, Selected = SelectedAction}
end
SetCustomDefaultLocalScriptAction_Deselected = plugin:CreatePluginAction(
	"DefaultLocalScripts_DefaultLocalScript_Custom_Deselected",	-- unique id
	"Custom",													-- name
	"Set the contents of newly created LocalScripts",			-- desc/tooltip
	DefaultScriptNotSelectedIcon,								-- iconId
	false														-- allow binding
)
SetCustomDefaultLocalScriptAction_Selected = plugin:CreatePluginAction(
	"DefaultLocalScripts_DefaultLocalScript_Custom_Selected",	-- unique id
	"Custom",													-- name
	"Set the contents of newly created LocalScripts",			-- desc/tooltip
	DefaultScriptSelectedIcon,									-- iconId
	false														-- allow binding
)
SetCustomDefaultLocalScriptAction_Deselected.Triggered:Connect(SetCustomDefaultLocalScript)
SetCustomDefaultLocalScriptAction_Selected.Triggered:Connect(SetCustomDefaultLocalScript)

SetCustomDefaultUniversalLocalScriptAction_Deselected = plugin:CreatePluginAction(
	"DefaultLocalScripts_DefaultUniversalLocalScript_Custom_Deselected",-- unique id
	"Custom",													-- name
	"Set the contents of newly created Universal LocalScripts",	-- desc/tooltip
	DefaultScriptNotSelectedIcon,								-- iconId
	false														-- allow binding
)
SetCustomDefaultUniversalLocalScriptAction_Selected = plugin:CreatePluginAction(
	"DefaultLocalScripts_DefaultUniversalLocalScript_Custom_Selected",-- unique id
	"Custom",													-- name
	"Set the contents of newly created Universal LocalScripts",	-- desc/tooltip
	DefaultScriptSelectedIcon,									-- iconId
	false														-- allow binding
)
SetCustomDefaultUniversalLocalScriptAction_Deselected.Triggered:Connect(SetCustomDefaultUniversalLocalScript)
SetCustomDefaultUniversalLocalScriptAction_Selected.Triggered:Connect(SetCustomDefaultUniversalLocalScript)

SettingsMenu = plugin:CreatePluginMenu("DefaultLocalScripts_Settings", "Settings")
DefaultLocalScriptMenu = plugin:CreatePluginMenu("DefaultLocalScripts_DefaultLocalScript", "Default LocalScript", "rbxassetid://413366777")
DefaultUniversalLocalScriptMenu = plugin:CreatePluginMenu("DefaultLocalScripts_DefaultUniversalLocalScript", "Default Universal LocalScript", "rbxassetid://413366777")
SettingsMenu:AddMenu(DefaultLocalScriptMenu)
SettingsMenu:AddMenu(DefaultUniversalLocalScriptMenu)

ToolBar = plugin:CreateToolbar("Default LocalScripts")
SettingsButton = ToolBar:CreateButton("Settings", "Configure settings for DefaultLocalScripts", "rbxasset://textures/ui/Settings/MenuBarIcons/GameSettingsTab.png", "Settings")
SettingsButton.ClickableWhenViewportHidden = true
SettingsButton.Click:Connect(OpenSettings)