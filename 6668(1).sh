```lua
local _CK_Players = game:GetService("Players")
local _CK_RS = game:GetService("RunService")
local _CK_GS = game:GetService("GuiService")
local _CK_HTTP = game:GetService("HttpService")
local _CK_WS = game:GetService("Workspace")
local _CK_LP = _CK_Players.LocalPlayer
if not _CK_LP then
	_CK_Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
	_CK_LP = _CK_Players.LocalPlayer
end

local _CK_AK = { enabled = true }
local _CK_prevNC
do
	local ok, old = pcall(function()
		return hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
			local m = getnamecallmethod()
			if _CK_AK.enabled then
				if m == "Kick" and (self == _CK_LP or self == _CK_Players) then return nil end
				if m == "Shutdown" and (self == game or self == _CK_Players or self == _CK_WS) then return nil end
				if m == "Teleport" then return nil end
				if (m == "FireServer" or m == "InvokeServer") then
					local a = ...
					if type(a) == "string" then
						local l = string.lower(a)
						if string.find(l,"kick",1,true) or string.find(l,"ban",1,true)
						or string.find(l,"shutdown",1,true) or string.find(l,"disconnect",1,true)
						or string.find(l,"remove",1,true) then
							return nil
						end
					end
				end
			end
			return _CK_prevNC(self, ...)
		end))
	end)
	if ok then _CK_prevNC = old end
end

pcall(function()
	if hookfunction then
		if _CK_LP.Kick then
			local o = _CK_LP.Kick
			hookfunction(o, newcclosure(function(s, ...)
				if _CK_AK.enabled then return end
				return o(s, ...)
			end))
		end
		if _CK_Players.Kick then
			local o = _CK_Players.Kick
			hookfunction(o, newcclosure(function(s, t, ...)
				if _CK_AK.enabled and t == _CK_LP then return end
				return o(s, t, ...)
			end))
		end
		if game.Shutdown then
			local o = game.Shutdown
			hookfunction(o, newcclosure(function(s, ...)
				if _CK_AK.enabled then return end
				return o(s, ...)
			end))
		end
		if _CK_Players.Shutdown then
			local o = _CK_Players.Shutdown
			hookfunction(o, newcclosure(function(s, ...)
				if _CK_AK.enabled then return end
				return o(s, ...)
			end))
		end
	end
end)

pcall(function()
	if hookfunction and _CK_GS and _CK_GS.SetCore then
		local o = _CK_GS.SetCore
		hookfunction(o, newcclosure(function(s, c, ...)
			if _CK_AK.enabled and type(c) == "string" then
				if c == "SendNotification" or c == "SetCore" then
					local a = ...
					if type(a) == "table" then
						local ti = string.lower(tostring(a.Title or ""))
						local tx = string.lower(tostring(a.Text or ""))
						if string.find(ti,"kick",1,true) or string.find(ti,"ban",1,true)
						or string.find(tx,"kicked",1,true) or string.find(tx,"banned",1,true)
						or string.find(tx,"disconnect",1,true) then return end
					end
				end
			end
			return o(s, c, ...)
		end))
	end
end)

pcall(function()
	if getconnections then
		for _, c in ipairs(getconnections(_CK_Players.PlayerRemoving)) do pcall(function() c:Disable() end) end
		for _, c in ipairs(getconnections(_CK_LP.OnTeleport)) do pcall(function() c:Disable() end) end
	end
end)

pcall(function()
	if blockgc then blockgc() end
end)

pcall(function()
	if setfflag then
		setfflag("FFlagDisablePostFx", "True")
		setfflag("DFIntTaskSchedulerTargetFps", "9999")
	end
end)

pcall(function()
	if getrawmetatable and setreadonly then
		local mt = getrawmetatable(game)
		local oi = mt.__index
		setreadonly(mt, false)
		mt.__index = newcclosure(function(self, k)
			if _CK_AK.enabled and self == _CK_LP and k == "Kick" then
				return function() end
			end
			return oi(self, k)
		end)
		setreadonly(mt, true)
	end
end)

_CK_LP.AncestryChanged:Connect(function()
	if _CK_AK.enabled and not _CK_LP:IsDescendantOf(game) then
		pcall(function() _CK_Players:ClearAllChildren() end)
	end
end)

_CK_RS.Heartbeat:Connect(function()
	if _CK_AK.enabled and _CK_LP.Parent ~= _CK_Players then
		pcall(function() _CK_LP.Parent = _CK_Players end)
	end
end)

local _CK_URL = "https://www.keyt.cn/kami/xhgnb66666/check.php"
local _CK_AID = "a"
local _CK_AKEY = "7162446fc4705b7e3dcf00a641297b1d"

local function _CK_deviceID()
	local id = ""
	pcall(function() if gethwid then id = gethwid() end end)
	pcall(function() if syn and syn.get_hwid then id = syn.get_hwid() end end)
	if id == "" then pcall(function() id = game:GetService("RbxAnalyticsService"):GetClientId() end) end
	if id == "" then id = tostring(_CK_LP.UserId).."_"..tostring(game.PlaceId) end
	return id
end

local function _CK_verify(key)
	local url = _CK_URL.."?appid=".._CK_AID.."&appkey=".._CK_AKEY.."&kami="..key.."&markcode=".._CK_deviceID()
	local ok, res = pcall(function() return _CK_HTTP:JSONDecode(game:HttpGet(url)) end)
	if not ok or not res then return false, "网络请求失败" end
	if res.code == 1 or res.code == "1" then return true, res.msg or "验证成功" end
	return false, res.msg or "卡密无效"
end

local function _CK_showGui()
	local gui = Instance.new("ScreenGui")
	gui.Name = "CK_Gui"
	gui.ResetOnSpawn = false
	pcall(function() gui.Parent = game:GetService("CoreGui") end)
	if not gui.Parent then gui.Parent = _CK_LP:WaitForChild("PlayerGui") end

	local f = Instance.new("Frame")
	f.Size = UDim2.new(0, 380, 0, 240)
	f.Position = UDim2.new(0.5, -190, 0.5, -120)
	f.BackgroundColor3 = Color3.fromRGB(25, 28, 38)
	f.BorderSizePixel = 0
	f.Parent = gui
	Instance.new("UICorner", f).CornerRadius = UDim.new(0, 12)
	local st = Instance.new("UIStroke"); st.Color = Color3.fromRGB(80,130,255); st.Thickness = 1.5; st.Parent = f

	local t = Instance.new("TextLabel")
	t.Size = UDim2.new(1, 0, 0, 50); t.BackgroundTransparency = 1
	t.Text = "KEY"; t.TextColor3 = Color3.new(1,1,1)
	t.TextSize = 23; t.Font = Enum.Font.GothamBold; t.Parent = f

	local sub = Instance.new("TextLabel")
	sub.Size = UDim2.new(1, 0, 0, 20); sub.Position = UDim2.new(0, 0, 0, 45)
	sub.BackgroundTransparency = 1; sub.Text = ""
	sub.TextColor3 = Color3.fromRGB(150,150,160); sub.TextSize = 12; sub.Parent = f

	local box = Instance.new("TextBox")
	box.Size = UDim2.new(0, 320, 0, 45); box.Position = UDim2.new(0, 30, 0, 75)
	box.BackgroundColor3 = Color3.fromRGB(40,45,60); box.TextColor3 = Color3.new(1,1,1)
	box.PlaceholderText = "KEY"; box.Text = ""; box.TextSize = 15
	box.ClearTextOnFocus = false; box.Parent = f
	Instance.new("UICorner", box).CornerRadius = UDim.new(0, 8)

	local s = Instance.new("TextLabel")
	s.Size = UDim2.new(1, 0, 0, 25); s.Position = UDim2.new(0, 0, 0, 128)
	s.BackgroundTransparency = 1; s.Text = ""; s.TextColor3 = Color3.fromRGB(255,100,100)
	s.TextSize = 13; s.Parent = f

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 320, 0, 45); btn.Position = UDim2.new(0, 30, 0, 160)
	btn.BackgroundColor3 = Color3.fromRGB(37,99,235); btn.Text = "OK"
	btn.TextColor3 = Color3.new(1,1,1); btn.TextSize = 17; btn.Font = Enum.Font.GothamBold
	btn.Parent = f
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

	btn.MouseButton1Click:Connect(function()
		if box.Text == "" then s.Text = "❌" return end
		s.Text = "..."; s.TextColor3 = Color3.fromRGB(255,200,0)
		btn.Active = false
		task.spawn(function()
			local ok, msg = _CK_verify(box.Text)
			if ok then
				pcall(function() writefile("card_key.txt", box.Text) end)
				s.Text = "✅"
				s.TextColor3 = Color3.fromRGB(0,255,100)
				task.wait(1.2)
				gui:Destroy()
				_G.CK_VERIFIED = true
			else
				s.Text = "❌"
				s.TextColor3 = Color3.fromRGB(255,100,100)
				btn.Active = true
			end
		end)
	end)
end

_G.CK_VERIFIED = false
local _savedKey = nil
pcall(function() _savedKey = readfile("card_key.txt") end)
if _savedKey and _savedKey ~= "" then
	local ok = _CK_verify(_savedKey)
	if ok then
		_G.CK_VERIFIED = true
	end
end
if not _G.CK_VERIFIED then
	_CK_showGui()
end

while not _G.CK_VERIFIED do
	task.wait(0.1)
end
```