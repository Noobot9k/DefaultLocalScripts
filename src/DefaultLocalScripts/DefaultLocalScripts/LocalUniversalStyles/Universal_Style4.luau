-- Created by %CREATORUSERNAME%
do
	-- <-- Collapse this 'do' to clean up your code
	UniversalLocalScripts = require(game.ReplicatedFirst.UniversalLocalScripts)
	script = UniversalLocalScripts.GetOriginal(script) or script -- don't worry about this warning.
	HasAuthority = UniversalLocalScripts.GetAuthoritativePlayer(script) == game.Players.LocalPlayer
	-- useful if UniversalLocalScripts.RunInPlayerCharacters is true. ^
end -- UniversalLocalScripts

print("Hello world!")
