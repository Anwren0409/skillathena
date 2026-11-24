--!nocheck
-- In-situ asset trial (Stage B). Run with execute_luau, datamodel_type = Client, during playtest.
-- Swaps each candidate image into the REAL GUI slot so you can capture it at real size, on the real surface,
-- next to its real siblings and over the real scene.
-- Workflow: set TARGET_PATH + CANDIDATES (IDs from search_asset results ONLY) -> run with INDEX = 1, screen_capture,
-- INDEX = 2, screen_capture, ... -> finally run with RESTORE = true (before any final capture).
local TARGET_PATH = "REPLACE_ME"   -- dot path under PlayerGui, e.g. "ShopMenu.Root.Hero.Art"
local PROPERTY = "Image"           -- the image property being trialed (confirm in the class docs)
local INDEX = 1
local RESTORE = false
local CANDIDATES = { -- { id = 1234567890, label = "A: brass frame" }
}

if TARGET_PATH == "REPLACE_ME" then return "set TARGET_PATH first" end
local playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
local node = playerGui
for _, name in string.split(TARGET_PATH, ".") do
	node = node and node:FindFirstChild(name)
end
if not node or node == playerGui then return "target not found: " .. TARGET_PATH end
if not (node:IsA("ImageLabel") or node:IsA("ImageButton")) then return "target is not an ImageLabel/ImageButton: " .. node.ClassName end

if RESTORE then
	local original = node:GetAttribute("TrialOriginal")
	if original ~= nil then node[PROPERTY] = original end
	node:SetAttribute("TrialOriginal", nil)
	return "restored original " .. PROPERTY .. " on " .. TARGET_PATH
end

if node:GetAttribute("TrialOriginal") == nil then node:SetAttribute("TrialOriginal", node[PROPERTY]) end
local c = CANDIDATES[INDEX]
if not c then return ("no candidate at INDEX %d (have %d)"):format(INDEX, #CANDIDATES) end
node[PROPERTY] = "rbxassetid://" .. c.id
return ("trialing %d/%d: %s #%d on %s - wait 1-2s for it to load, then screen_capture"):format(INDEX, #CANDIDATES, c.label or "?", c.id, TARGET_PATH)
