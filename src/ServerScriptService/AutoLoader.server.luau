--[[
	AutoLoader.server.luau

	AUTO-RUN script that loads ServerInit on server startup.
	This file will be automatically executed by Roblox when the server starts.

	HOW IT WORKS:
	- Files with .server.luau extension run automatically in ServerScriptService
	- This script simply requires ServerInit to start the initialization process

	Author: Bisa Bahasa Studio
	Created: 2025-01-07
	Version: 1.0.0
]]

-- Simply require ServerInit to start the server initialization
-- ServerInit will handle all the loading, setup, and error handling
local ServerScriptService = game:GetService("ServerScriptService")

print("[AutoLoader] Starting server initialization...")
print("[AutoLoader] Loading ServerInit module...")

-- Load ServerInit - it will handle everything from here
require(ServerScriptService.ServerInit)

print("[AutoLoader] ServerInit loaded successfully!")
