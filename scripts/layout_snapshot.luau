--!nocheck
-- Layout snapshot + drift detector. Run via execute_luau with datamodel_type = Client during playtest.
-- 1) Run once -> returns a snapshot as text. Keep it.
-- 2) Perform the action with real input (minimize/unminimize, close/reopen, resize and back, ...), wait for it to settle.
-- 3) Run again with the earlier text pasted into PREVIOUS -> lists everything that moved, resized, rotated or changed visibility.
-- Anything beyond TOLERANCE that the design does not intend is a defect.
local ROOT_NAME = "REPLACE_ME"
local TOLERANCE = 0.5 -- pixels
local PREVIOUS = [[
]]

if ROOT_NAME == "REPLACE_ME" then return "set ROOT_NAME first" end
local pg = game.Players.LocalPlayer:WaitForChild("PlayerGui")
local root = pg:FindFirstChild(ROOT_NAME)
if not root then return "root not found: " .. ROOT_NAME end

local lines, current, seen = {}, {}, {}
for _, o in root:GetDescendants() do
	if o:IsA("GuiObject") then
		local path = (o:GetFullName():gsub("^.-PlayerGui%.", ""))
		seen[path] = (seen[path] or 0) + 1
		if seen[path] > 1 then path = path .. "#" .. seen[path] end -- disambiguate same-named siblings
		local p, s = o.AbsolutePosition, o.AbsoluteSize
		local entry = { x = p.X, y = p.Y, w = s.X, h = s.Y, v = o.Visible and "1" or "0", r = o.Rotation }
		current[path] = entry
		table.insert(lines, ("%s|%.1f|%.1f|%.1f|%.1f|%s|%.1f"):format(path, entry.x, entry.y, entry.w, entry.h, entry.v, entry.r))
	end
end

local function parse(text)
	local t = {}
	for line in string.gmatch(text, "[^\r\n]+") do
		local path, x, y, w, h, v, r = string.match(line, "^(.-)|(%-?[%d%.]+)|(%-?[%d%.]+)|(%-?[%d%.]+)|(%-?[%d%.]+)|([01])|(%-?[%d%.]+)$")
		if path then t[path] = { x = tonumber(x), y = tonumber(y), w = tonumber(w), h = tonumber(h), v = v, r = tonumber(r) } end
	end
	return t
end

local prev = parse(PREVIOUS)
if next(prev) == nil then
	return ("snapshot of %d objects (paste into PREVIOUS for the next run):\n%s"):format(#lines, table.concat(lines, "\n"))
end

local diffs = {}
for path, c in current do
	local o = prev[path]
	if not o then
		table.insert(diffs, "[ADDED] " .. path)
	else
		if math.abs(c.x - o.x) > TOLERANCE or math.abs(c.y - o.y) > TOLERANCE then
			table.insert(diffs, ("[MOVED] %s: (%.1f, %.1f) -> (%.1f, %.1f)"):format(path, o.x, o.y, c.x, c.y))
		end
		if math.abs(c.w - o.w) > TOLERANCE or math.abs(c.h - o.h) > TOLERANCE then
			table.insert(diffs, ("[RESIZED] %s: %.1fx%.1f -> %.1fx%.1f"):format(path, o.w, o.h, c.w, c.h))
		end
		if c.v ~= o.v then table.insert(diffs, ("[VISIBILITY] %s: %s -> %s"):format(path, o.v, c.v)) end
		if math.abs(c.r - o.r) > 0.1 then table.insert(diffs, ("[ROTATED] %s: %.1f -> %.1f"):format(path, o.r, c.r)) end
	end
end
for path in prev do
	if not current[path] then table.insert(diffs, "[REMOVED] " .. path) end
end
table.sort(diffs)
return #diffs == 0 and ("no drift: %d objects identical within %.1f px"):format(#lines, TOLERANCE) or table.concat(diffs, "\n")
