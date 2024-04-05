-- Created by %CREATORUSERNAME%
do
	UniversalLocalScripts = require(game.ReplicatedFirst.UniversalLocalScripts)
	script = UniversalLocalScripts.GetOriginal(script) or script
	HasAuthority = UniversalLocalScripts.GetAuthoritativePlayer(script) == game.Players.LocalPlayer
end -- UniversalLocalScripts

print("Hello world!")
