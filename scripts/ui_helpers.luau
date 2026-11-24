--!nocheck
-- Small construction helpers to paste at the top of build code run via execute_luau.
-- They are plumbing only: they carry NO visual style. Styling comes from your art-direction tokens.
local function new(class: string, props: {[string]: any}?, children: {Instance}?, parent: Instance?)
	local o = Instance.new(class)
	for k, v in (props or {}) do o[k] = v end
	for _, c in (children or {}) do c.Parent = o end
	if parent then o.Parent = parent end
	return o
end

local function pad(all: number | {top: number?, bottom: number?, left: number?, right: number?})
	local t = type(all) == "number" and {top = all, bottom = all, left = all, right = all} or all
	return new("UIPadding", {
		PaddingTop = UDim.new(0, t.top or 0), PaddingBottom = UDim.new(0, t.bottom or 0),
		PaddingLeft = UDim.new(0, t.left or 0), PaddingRight = UDim.new(0, t.right or 0),
	})
end
local function corner(px: number) return new("UICorner", {CornerRadius = UDim.new(0, px)}) end
local function stroke(color: Color3, px: number, transparency: number?)
	return new("UIStroke", {Color = color, Thickness = px, Transparency = transparency or 0, ApplyStrokeMode = Enum.ApplyStrokeMode.Border})
end
local function list(dir: Enum.FillDirection, gap: number, h: Enum.HorizontalAlignment?, v: Enum.VerticalAlignment?)
	return new("UIListLayout", {FillDirection = dir, Padding = UDim.new(0, gap), SortOrder = Enum.SortOrder.LayoutOrder,
		HorizontalAlignment = h or Enum.HorizontalAlignment.Left, VerticalAlignment = v or Enum.VerticalAlignment.Top})
end
local function text(props, children, parent) -- TextLabel with sane defaults (no stock font/colors imposed)
	props.BackgroundTransparency = props.BackgroundTransparency or 1
	props.BorderSizePixel = 0
	return new("TextLabel", props, children, parent)
end
local function button(props, children, parent) -- custom-state button: you implement states
	props.AutoButtonColor = false; props.BorderSizePixel = 0; props.Selectable = true
	return new("TextButton", props, children, parent)
end

-- Idempotent root: removes only the previous root YOU created this session under this exact name, nothing else.
-- Use a descriptive role-based name (e.g. "ShopMenu"); never a brand/tool name. Never call this with a name you did not create.
local function freshRoot(container: Instance, name: string, props: {[string]: any}?)
	local old = container:FindFirstChild(name); if old then old:Destroy() end
	local p = {Name = name, ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling}
	for k, v in (props or {}) do p[k] = v end
	return new("ScreenGui", p, nil, container)
end

-- Canonical-state tweens (motion.md section 4): ALWAYS tween to absolute target values from a state table,
-- never "current + delta". The caller owns the state table; set AnchorPoint once at build time.
local TweenService = game:GetService("TweenService")
local activeTweens: {[Instance]: Tween} = {}

-- motionScale: pass root:GetAttribute("MotionScale") or 1 so slow-motion playtests and reduced motion work.
local function tweenToState(obj: Instance, targets: {[string]: any}, info: TweenInfo, motionScale: number?)
	local previous = activeTweens[obj]
	if previous then previous:Cancel() end
	local scale = motionScale or 1
	local scaledInfo = TweenInfo.new(info.Time * scale, info.EasingStyle, info.EasingDirection, info.RepeatCount, info.Reverses, info.DelayTime * scale)
	local tween = TweenService:Create(obj, scaledInfo, targets)
	activeTweens[obj] = tween
	tween.Completed:Once(function()
		if activeTweens[obj] == tween then activeTweens[obj] = nil end
	end)
	tween:Play()
	return tween
end

-- Instant version (used after viewport/layout-mode changes: recompute the state table, then snap to it).
local function snapToState(obj: Instance, targets: {[string]: any})
	local previous = activeTweens[obj]
	if previous then previous:Cancel(); activeTweens[obj] = nil end
	for k, v in targets do obj[k] = v end
end

