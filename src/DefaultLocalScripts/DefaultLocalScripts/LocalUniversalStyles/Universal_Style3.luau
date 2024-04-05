-- Created by %CREATORUSERNAME%

-- Dependencies
local UniversalLocalScripts = require(game.ReplicatedFirst.UniversalLocalScripts)


-- Properties
local script = UniversalLocalScripts.GetOriginal(script) or script
local HasAuthority = UniversalLocalScripts.GetAuthoritativePlayer(script) == game.Players.LocalPlayer


-- Main
print("Hello world!")
