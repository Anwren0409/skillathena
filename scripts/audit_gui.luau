--!nocheck
-- Structural audit. Run via execute_luau with datamodel_type = Client during playtest
-- (AbsoluteSize/AbsolutePosition are only meaningful when the GUI is rendered).
-- Set ROOT_NAME to your ScreenGui. This is a NON-visual aid: it never replaces screenshot review or the playtest ledger.
local ROOT_NAME = "REPLACE_ME"
local MIN_TEXT, MIN_TOUCH, MIN_CONTRAST = 12, 44, 4.5
local BANNED_NAME_TOKENS = { "athena", "claude", "anthropic", "generated", "autogen", "chatgpt", "gpt" } -- names must stay generic

if ROOT_NAME == "REPLACE_ME" then return "set ROOT_NAME first" end
local pg = game.Players.LocalPlayer:WaitForChild("PlayerGui")
local root = pg:FindFirstChild(ROOT_NAME)
if not root then return "root not found: " .. ROOT_NAME end

local function lin(c) return c <= 0.03928 and c / 12.92 or ((c + 0.055) / 1.055) ^ 2.4 end
local function lum(c: Color3) return 0.2126 * lin(c.R) + 0.7152 * lin(c.G) + 0.0722 * lin(c.B) end
local function ratio(a: Color3, b: Color3)
	local l1, l2 = lum(a), lum(b)
	if l1 < l2 then l1, l2 = l2, l1 end
	return (l1 + 0.05) / (l2 + 0.05)
end
local function backdrop(o: GuiObject): Color3?
	local p = o.Parent
	while p and p:IsA("GuiObject") do
		if p.BackgroundTransparency < 0.5 then return p.BackgroundColor3 end
		p = p.Parent
	end
	return nil -- over the 3D scene: contrast unknowable here; check by screenshot
end

local vp = workspace.CurrentCamera.ViewportSize
local out = {}
local function add(kind, o, msg) table.insert(out, ("[%s] %s: %s"):format(kind, (o:GetFullName():gsub("^.-PlayerGui%.", "")), msg)) end

local function nameChecks(o: Instance)
	local lowered = string.lower(o.Name)
	for _, token in BANNED_NAME_TOKENS do
		if string.find(lowered, token, 1, true) then add("BRANDEDNAME", o, "name contains '" .. token .. "'") end
	end
	for attr in o:GetAttributes() do
		local la = string.lower(attr)
		for _, token in BANNED_NAME_TOKENS do
			if string.find(la, token, 1, true) then add("BRANDEDATTRIBUTE", o, "attribute '" .. attr .. "' contains '" .. token .. "'") end
		end
	end
end

nameChecks(root)
for _, o in root:GetDescendants() do
	nameChecks(o)
	if o:IsA("GuiObject") then
		if o.Name == o.ClassName or string.match(o.Name, "^" .. o.ClassName .. "%d+$") then add("DEFAULTNAME", o, "default name; use a role-based name") end
		if o.Visible then
			local pos, size = o.AbsolutePosition, o.AbsoluteSize
			if size.X > 0 and size.Y > 0 and (pos.X + size.X < 0 or pos.Y + size.Y < 0 or pos.X > vp.X or pos.Y > vp.Y) then
				add("OFFSCREEN", o, ("pos %d,%d size %d,%d"):format(pos.X, pos.Y, size.X, size.Y))
			end
			if o:IsA("TextLabel") or o:IsA("TextButton") or o:IsA("TextBox") then
				if o.Text ~= "" then
					local eff = o.TextScaled and o.AbsoluteSize.Y or o.TextSize
					if o.TextScaled and o.TextBounds.Y > 0 then eff = o.TextBounds.Y end
					if eff < MIN_TEXT then add("SMALLTEXT", o, ("~%d px"):format(eff)) end
					if o.TextBounds.X > o.AbsoluteSize.X + 1 and not o.TextWrapped and o.TextTruncate == Enum.TextTruncate.None then
						add("CLIPPED_X", o, ("text %d > box %d"):format(o.TextBounds.X, o.AbsoluteSize.X))
					end
					if o.TextBounds.Y > o.AbsoluteSize.Y + 1 and o.AutomaticSize == Enum.AutomaticSize.None then
						add("CLIPPED_Y", o, ("text %d > box %d"):format(o.TextBounds.Y, o.AbsoluteSize.Y))
					end
					local bg = (o.BackgroundTransparency < 0.5) and o.BackgroundColor3 or backdrop(o)
					if bg then
						local r = ratio(o.TextColor3, bg)
						if r < MIN_CONTRAST then add("CONTRAST", o, ("%.2f:1"):format(r)) end
					end
				end
			end
			if o:IsA("GuiButton") then
				if math.min(size.X, size.Y) < MIN_TOUCH then add("TOUCH", o, ("%dx%d < %d"):format(size.X, size.Y, MIN_TOUCH)) end
				if not o.Selectable then add("NOTSELECTABLE", o, "gamepad cannot focus") end
			end
			if o:IsA("ImageLabel") or o:IsA("ImageButton") then
				if o.Image == "" and o.BackgroundTransparency >= 1 then add("EMPTYIMAGE", o, "no Image and no background") end
			end
		end
	end
end
return #out == 0 and "audit: no structural findings (still requires screenshot review and the full playtest ledger)" or table.concat(out, "\n")
