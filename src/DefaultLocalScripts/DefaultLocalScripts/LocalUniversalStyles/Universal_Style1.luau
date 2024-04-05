-- Created by %CREATORUSERNAME%

-- The following code is needed for this LocalScript to run properly in the workspace.
local UniversalLocalScripts = require(game.ReplicatedFirst.UniversalLocalScripts)
local script = UniversalLocalScripts.GetOriginal(script) or script
local HasAuthority = UniversalLocalScripts.GetAuthoritativePlayer(script) == game.Players.LocalPlayer

print("Hello world!")