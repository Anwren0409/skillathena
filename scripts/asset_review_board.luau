--!nocheck
-- Temporary in-game comparison board for image candidates (Stage A triage). Run with execute_luau.
-- Use datamodel_type Edit (adds to StarterGui) or Client during play (adds to PlayerGui), then screen_capture.
-- ALWAYS destroy afterwards: run again with CLEANUP = true.
-- Each candidate is shown on a dark tile, a light tile, a mid-tone tile, and AT ACTUAL SIZE on your real surface color.
local CLEANUP = false
local CANDIDATES = { -- fill from search_asset results ONLY; never invent IDs
	-- { id = 1234567890, label = "A: brass frame" },
}
local ACTUAL_SIZE = Vector2.new(64, 64)                 -- the on-screen size this asset will have in the real GUI
local SURFACE_COLOR = Color3.fromRGB(60, 60, 66)        -- replace with the real surface token it will sit on
local NAME = "Temp_AssetBoard"

local target = (game:GetService("RunService"):IsRunning() and game.Players.LocalPlayer:WaitForChild("PlayerGui")) or game:GetService("StarterGui")
local old = target:FindFirstChild(NAME)
if old then old:Destroy() end
if CLEANUP then return "board removed" end

local gui = Instance.new("ScreenGui")
gui.Name, gui.ResetOnSpawn, gui.DisplayOrder, gui.IgnoreGuiInset = NAME, false, 999, true
local bg = Instance.new("Frame"); bg.Name = "Backdrop"; bg.Size = UDim2.fromScale(1, 1); bg.BackgroundColor3 = Color3.fromRGB(32, 32, 36); bg.BorderSizePixel = 0; bg.Parent = gui
local grid = Instance.new("UIGridLayout"); grid.CellSize = UDim2.fromOffset(200, 320); grid.CellPadding = UDim2.fromOffset(12, 12); grid.SortOrder = Enum.SortOrder.LayoutOrder; grid.Parent = bg
local pad = Instance.new("UIPadding"); pad.PaddingTop, pad.PaddingLeft = UDim.new(0, 12), UDim.new(0, 12); pad.Parent = bg

local function image(parent: Instance, id: number, size: UDim2, position: UDim2, scaleType: Enum.ScaleType)
	local img = Instance.new("ImageLabel")
	img.Name = "Preview"; img.BackgroundTransparency = 1; img.Size = size; img.Position = position
	img.Image = "rbxassetid://" .. id; img.ScaleType = scaleType; img.Parent = parent
	return img
end

for i, c in CANDIDATES do
	local cell = Instance.new("Frame"); cell.Name = "Candidate_" .. i; cell.BackgroundTransparency = 1; cell.LayoutOrder = i; cell.Parent = bg

	-- Row 1: dark and light tiles (edge/halo check)
	for k, shade in { Color3.fromRGB(20, 20, 20), Color3.fromRGB(235, 235, 235) } do
		local tile = Instance.new("Frame"); tile.Name = "Tile_" .. k; tile.BackgroundColor3 = shade; tile.BorderSizePixel = 0
		tile.Size = UDim2.fromOffset(96, 96); tile.Position = UDim2.fromOffset((k - 1) * 100, 0); tile.Parent = cell
		image(tile, c.id, UDim2.fromScale(1, 1), UDim2.fromScale(0, 0), Enum.ScaleType.Fit)
	end

	-- Row 2: mid-tone tile, large preview
	local mid = Instance.new("Frame"); mid.Name = "MidTile"; mid.BackgroundColor3 = Color3.fromRGB(128, 128, 134); mid.BorderSizePixel = 0
	mid.Size = UDim2.fromOffset(196, 100); mid.Position = UDim2.fromOffset(0, 104); mid.Parent = cell
	image(mid, c.id, UDim2.fromScale(1, 1), UDim2.fromScale(0, 0), Enum.ScaleType.Fit)

	-- Row 3: actual size on the real surface color
	local real = Instance.new("Frame"); real.Name = "ActualSizeSurface"; real.BackgroundColor3 = SURFACE_COLOR; real.BorderSizePixel = 0
	real.Size = UDim2.fromOffset(196, 100); real.Position = UDim2.fromOffset(0, 212); real.Parent = cell
	local actual = image(real, c.id, UDim2.fromOffset(ACTUAL_SIZE.X, ACTUAL_SIZE.Y), UDim2.fromScale(0.5, 0.5), Enum.ScaleType.Fit)
	actual.Name = "ActualSize"; actual.AnchorPoint = Vector2.new(0.5, 0.5)

	-- Label
	local t = Instance.new("TextLabel"); t.Name = "Label"; t.BackgroundTransparency = 1; t.Size = UDim2.fromOffset(196, 22); t.Position = UDim2.fromOffset(0, 296)
	t.Text = (c.label or "?") .. "  #" .. c.id; t.TextColor3 = Color3.new(1, 1, 1); t.TextSize = 12; t.Font = Enum.Font.Gotham; t.TextXAlignment = Enum.TextXAlignment.Left; t.Parent = cell
end
gui.Parent = target
return "board created; wait ~1-2s for images, then screen_capture, then re-run with CLEANUP = true"
