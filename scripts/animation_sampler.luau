--!nocheck
-- Per-frame animation sampler. Run via execute_luau with datamodel_type = Client during playtest.
-- Records numeric property values on every Heartbeat while TRIGGER runs the transition, then reports
-- start -> end, measured duration, overshoot, snaps/pops, stalls, direction reversals, and end-state accuracy.
-- IMPORTANT: TRIGGER is a PROGRAMMATIC trigger (it is not real player input). Say so in the report and pair this
-- numeric pass with a real-input pass using slow-motion screen captures (playtest-protocol.md section 4).
-- Confirm every property name and value type in the class docs before listing it.
local TARGET_PATH = "REPLACE_ME"                          -- dot path under PlayerGui, e.g. "ShopMenu.Root"
local PROPERTIES = { "Position", "Size", "GroupTransparency" }
local DURATION = 1.0                                      -- seconds to record: expected transition + settle time
local EXPECTED_END = {                                    -- fill from the canonical state table, e.g.:
	-- Position = UDim2.fromScale(0.5, 0.5), GroupTransparency = 0,
}
local function TRIGGER()
	-- Start the transition the way the controller expects (e.g. fire the BindableEvent or set the attribute it listens to).
end

if TARGET_PATH == "REPLACE_ME" then return "set TARGET_PATH first" end
local RunService = game:GetService("RunService")
local playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
local node = playerGui
for _, name in string.split(TARGET_PATH, ".") do node = node and node:FindFirstChild(name) end
if not node or node == playerGui then return "target not found: " .. TARGET_PATH end

local LABELS = {
	number = { "" }, boolean = { "" }, UDim = { ".Scale", ".Offset" },
	UDim2 = { ".X.Scale", ".X.Offset", ".Y.Scale", ".Y.Offset" }, Vector2 = { ".X", ".Y" }, Color3 = { ".R", ".G", ".B" },
}
local function flatten(v)
	local t = typeof(v)
	if t == "number" then return { v }
	elseif t == "boolean" then return { v and 1 or 0 }
	elseif t == "UDim" then return { v.Scale, v.Offset }
	elseif t == "UDim2" then return { v.X.Scale, v.X.Offset, v.Y.Scale, v.Y.Offset }
	elseif t == "Vector2" then return { v.X, v.Y }
	elseif t == "Color3" then return { v.R, v.G, v.B }
	end
	return nil
end

local times, data, unsupported = {}, {}, {}
local t0 = os.clock()
local function sample()
	table.insert(times, os.clock() - t0)
	for _, prop in PROPERTIES do
		local ok, value = pcall(function() return node[prop] end)
		local flat = ok and flatten(value) or nil
		if flat then
			local d = data[prop]
			if not d then
				d = { labels = LABELS[typeof(value)], comps = {} }
				for i = 1, #flat do d.comps[i] = {} end
				data[prop] = d
			end
			for i, v in flat do table.insert(d.comps[i], v) end
		else
			unsupported[prop] = ok and ("unsupported type " .. typeof(value)) or "invalid property for " .. node.ClassName
		end
	end
end

sample() -- initial value before the trigger
local conn = RunService.Heartbeat:Connect(sample)
local okTrigger, errTrigger = pcall(TRIGGER)
task.wait(DURATION)
conn:Disconnect()

local EPS = 1e-4
local function analyze(label, series, expectedEnd)
	local n = #series
	local s, e = series[1], series[n]
	local lo, hi = math.min(s, e), math.max(s, e)
	local range = hi - lo
	local mn, mx = math.huge, -math.huge
	for _, v in series do mn, mx = math.min(mn, v), math.max(mx, v) end
	if mx - mn < EPS then
		return ("%s: NO CHANGE recorded (%.3f)%s"):format(label, s, expectedEnd and math.abs(e - expectedEnd) > 0.01 and (" | END MISMATCH expected %.3f"):format(expectedEnd) or "")
	end
	local firstMove, lastMove, maxStep, maxStepAt, reversals, lastSign = nil, nil, 0, 0, 0, 0
	for i = 2, n do
		local step = series[i] - series[i - 1]
		if math.abs(step) > EPS then
			firstMove = firstMove or i
			lastMove = i
			if math.abs(step) > maxStep then maxStep, maxStepAt = math.abs(step), i end
			local sign = step > 0 and 1 or -1
			if lastSign ~= 0 and sign ~= lastSign then reversals += 1 end
			lastSign = sign
		end
	end
	if not firstMove then return ("%s: change is below the sampling threshold (%.6f)"):format(label, mx - mn) end
	local flags = {}
	local tol = math.max(range * 0.005, 0.01)
	if range > EPS then
		if mx > hi + tol then table.insert(flags, ("OVERSHOOT_HIGH +%.3f"):format(mx - hi)) end
		if mn < lo - tol then table.insert(flags, ("OVERSHOOT_LOW -%.3f"):format(lo - mn)) end
		if maxStep > 0.6 * range then table.insert(flags, ("SNAP %.0f%% of range in one frame at t=%.3fs"):format(maxStep / range * 100, times[maxStepAt])) end
	else
		table.insert(flags, ("EXCURSION %.3f then returned (pulse?)"):format(mx - mn))
	end
	if reversals > 0 then table.insert(flags, ("REVERSALS=%d (overshoot, bounce, or jitter)"):format(reversals)) end
	-- stall: a gap with zero movement between the first and last move
	local run, runStart, worst = 0, 0, 0
	for i = firstMove + 1, lastMove do
		if math.abs(series[i] - series[i - 1]) <= EPS then
			if run == 0 then runStart = i - 1 end
			run += 1
			worst = math.max(worst, times[i] - times[runStart])
		else
			run = 0
		end
	end
	if worst > 0.1 then table.insert(flags, ("STALL %.0f ms mid-transition"):format(worst * 1000)) end
	if expectedEnd and math.abs(e - expectedEnd) > (string.find(label, "Offset", 1, true) and 0.5 or 0.01) then
		table.insert(flags, ("END MISMATCH expected %.3f got %.3f"):format(expectedEnd, e))
	end
	local duration = (times[lastMove] - times[firstMove - 1]) * 1000
	return ("%s: %.3f -> %.3f | %.0f ms | %s"):format(label, s, e, duration, #flags == 0 and "no anomalies" or table.concat(flags, "; "))
end

local report = {}
local frames = #times
table.insert(report, ("target %s | frames %d | avg frame %.1f ms | trigger %s"):format(TARGET_PATH, frames, (times[frames] - times[1]) / math.max(frames - 1, 1) * 1000, okTrigger and "ok (programmatic)" or ("ERROR: " .. tostring(errTrigger))))
for _, prop in PROPERTIES do
	local d = data[prop]
	if d then
		local expected = EXPECTED_END[prop] and flatten(EXPECTED_END[prop]) or nil
		for i, series in d.comps do
			table.insert(report, analyze(prop .. d.labels[i], series, expected and expected[i] or nil))
		end
	else
		table.insert(report, prop .. ": " .. (unsupported[prop] or "no data"))
	end
end
return table.concat(report, "\n")
