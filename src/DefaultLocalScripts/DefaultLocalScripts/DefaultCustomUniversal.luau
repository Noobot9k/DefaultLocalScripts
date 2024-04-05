-- Created by %CREATORUSERNAME% <-- your username will be subbed in here.

--[[

	Code you write in this script will be what new Universal LocalScripts you create contain by default.
	
	Universal LocalScripts are scripts that can run in the workspace, powered by the UniversalLocalScripts module by Noobot9k.
	
	When you're finished editing, close this script and changes will apply.
	To change the default script contents later simply select "Custom" in the default local script contents setting again.
	
	Also, remember to delete this comment or it will be in every new script you create from now on.
	
]]

local UniversalLocalScripts = require(game.ReplicatedFirst.UniversalLocalScripts)
local script = UniversalLocalScripts.GetOriginal(script) or script -- if this gives you a warning, don't worry about it.
local HasAuthority = UniversalLocalScripts.GetAuthoritativePlayer(script) == game.Players.LocalPlayer
-- useful if UniversalLocalScripts.RunInPlayerCharacters is true. ^

--[[This code is not needed if your script is in a location that would normally run your localscript the way you expect it to
	(IE: StarterPlayerScripts or ReplicatedFirst) but is designed so it will still work as expected with this code present. ]]

print("Hello world!")