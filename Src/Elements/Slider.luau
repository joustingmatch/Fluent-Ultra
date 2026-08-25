local UserInputService = game:GetService("UserInputService")
local Root = script.Parent.Parent
local Creator = require(Root.Modules.Creator)

local New = Creator.New

local Element = {}
Element.__index = Element
Element.__type = "Slider"

function Element:New(Idx, Config)
	local Library = self.Library
	assert(Config.Max, "Slider - Missing maximum value.")

	local Slider = {
		Value = nil,
		Min = typeof(Config.Min) == "number" and Config.Min or 0,
		Max = Config.Max,
		Rounding = typeof(Config.Rounding) == "number" and Config.Rounding or 0,
		Suffix = typeof(Config.Suffix) == "string" and Config.Suffix or "",
		Callback = typeof(Config.Callback) == "function" and Config.Callback or function(Value, OldValue) end,
		Changed = Config.Changed or function() end,
		Type = "Slider",
	}

	local Dragging = false
	local HasDesc = typeof(Config.Description) == "string" and Config.Description ~= ""
	local FrameHeight = HasDesc and 74 or 58

	-- Title / optional description, stacked top-left.
	local TitleLabel = New("TextLabel", {
		FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
		Text = Config.Title or "Slider",
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(1, 0, 0, 14),
		BackgroundTransparency = 1,
		ThemeTag = { TextColor3 = "Text" },
	})

	local DescLabel = New("TextLabel", {
		FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
		Text = Config.Description or "",
		Visible = HasDesc,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(1, 0, 0, 14),
		BackgroundTransparency = 1,
		ThemeTag = { TextColor3 = "SubText" },
	})

	local LabelHolder = New("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(12, 11),
		Size = UDim2.new(1, -130, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
	}, {
		New("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 2),
		}),
		TitleLabel,
		DescLabel,
	})

	-- Value pill (editable) at the top-right.
	local SliderDisplay = New("TextBox", {
		FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
		Text = "0",
		ClearTextOnFocus = true,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Center,
		Size = UDim2.new(0, 0, 1, 0),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundTransparency = 1,
		ThemeTag = { TextColor3 = "SubText" },
	})

	local ValuePill = New("Frame", {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -12, 0, 10),
		Size = UDim2.new(0, 0, 0, 22),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundTransparency = 0.85,
		ThemeTag = { BackgroundColor3 = "DropdownFrame" },
	}, {
		New("UICorner", { CornerRadius = UDim.new(0, 6) }),
		New("UIPadding", {
			PaddingLeft = UDim.new(0, 10),
			PaddingRight = UDim.new(0, 10),
		}),
		New("UIStroke", {
			Transparency = 0.7,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			ThemeTag = { Color = "InElementBorder" },
		}),
		SliderDisplay,
	})

	-- Full-width track along the bottom.
	local SliderFill = New("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 0, 0.5, 0),
		Size = UDim2.new(0, 0, 1, 0),
		ThemeTag = { BackgroundColor3 = "Accent" },
	}, {
		New("UICorner", { CornerRadius = UDim.new(1, 0) }),
	})

	local SliderRail = New("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 0, 0.5, 0),
		Size = UDim2.new(1, 0, 0, 6),
		BackgroundTransparency = 0.4,
		ThemeTag = { BackgroundColor3 = "SliderRail" },
	}, {
		New("UICorner", { CornerRadius = UDim.new(1, 0) }),
		SliderFill,
	})

	local SliderKnob = New("ImageLabel", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0, 0, 0.5, 0),
		Size = UDim2.fromOffset(14, 14),
		Image = "http://www.roblox.com/asset/?id=12266946128",
		ThemeTag = { ImageColor3 = "Accent" },
	})

	local SliderHit = New("Frame", {
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 12, 1, -12),
		Size = UDim2.new(1, -24, 0, 16),
		BackgroundTransparency = 1,
	}, {
		SliderRail,
		SliderKnob,
	})

	-- Hairline divider so the slider fits the groupbox (Section hides the last).
	local Divider = New("Frame", {
		Name = "GroupboxDivider",
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, 0),
		Size = UDim2.new(1, -20, 0, 1),
		BackgroundTransparency = 0.9,
		ThemeTag = { BackgroundColor3 = "ElementBorder" },
	})

	local SliderFrame = New("TextButton", {
		Size = UDim2.new(1, 0, 0, FrameHeight),
		BackgroundTransparency = 1,
		BackgroundColor3 = Color3.fromRGB(130, 130, 130),
		Parent = self.Container,
		Text = "",
		AutoButtonColor = false,
		LayoutOrder = 7,
		ThemeTag = { BackgroundColor3 = "Element" },
	}, {
		Divider,
		LabelHolder,
		ValuePill,
		SliderHit,
	})

	-- Subtle hover fill, matching the other groupbox rows.
	do
		local Base, Hovered = 1, 0.93
		local _, SetTransparency = Creator.SpringMotor(Base, SliderFrame, "BackgroundTransparency")
		Creator.AddSignal(SliderFrame.MouseEnter, function() SetTransparency(Hovered) end)
		Creator.AddSignal(SliderFrame.MouseLeave, function() SetTransparency(Base) end)
	end

	function Slider:OnChanged(Func)
		Slider.Changed = Func
		Library:SafeCallback(Func, Slider.Value, Slider.Value)
	end

	function Slider:SetValue(Value: number)
		local OldValue = self.Value or Value

		rawset(self, "Value", Library.Utilities:Round(math.clamp(Value, Slider.Min, Slider.Max), Slider.Rounding))

		local Ratio = (self.Value - Slider.Min) / (Slider.Max - Slider.Min)
		SliderFill.Size = UDim2.new(Ratio, 0, 1, 0)
		SliderKnob.Position = UDim2.new(Ratio, 0, 0.5, 0)
		SliderDisplay.Text = tostring(self.Value) .. (Slider.Suffix ~= "" and " " .. Slider.Suffix or "")

		if typeof(Slider.Callback) == "function" then
			Library:SafeCallback(Slider.Callback, self.Value, OldValue)
		end
		if typeof(Slider.Changed) == "function" then
			Library:SafeCallback(Slider.Changed, self.Value, OldValue)
		end
	end

	local function SetFromX(X)
		local Scale = math.clamp((X - SliderRail.AbsolutePosition.X) / SliderRail.AbsoluteSize.X, 0, 1)
		Slider:SetValue(Slider.Min + ((Slider.Max - Slider.Min) * Scale))
	end

	Creator.AddSignal(SliderHit.InputBegan, function(Input)
		if
			Input.UserInputType == Enum.UserInputType.MouseButton1
			or Input.UserInputType == Enum.UserInputType.Touch
		then
			Dragging = true
			SetFromX(Input.Position.X)
		end
	end)

	Creator.AddSignal(UserInputService.InputEnded, function(Input)
		if
			Input.UserInputType == Enum.UserInputType.MouseButton1
			or Input.UserInputType == Enum.UserInputType.Touch
		then
			Dragging = false
		end
	end)

	Creator.AddSignal(UserInputService.InputChanged, function(Input)
		if
			Dragging
			and (
				Input.UserInputType == Enum.UserInputType.MouseMovement
				or Input.UserInputType == Enum.UserInputType.Touch
			)
		then
			SetFromX(Input.Position.X)
		end
	end)

	Creator.AddSignal(SliderDisplay.FocusLost, function()
		Slider:SetValue(tonumber((SliderDisplay.Text:gsub("%a", ""))) or Slider.Value)
	end)

	function Slider:SetTitle(Set)
		TitleLabel.Text = Set
	end
	function Slider:SetDesc(Set)
		DescLabel.Text = Set or ""
		DescLabel.Visible = Set ~= nil and Set ~= ""
	end

	function Slider:Destroy()
		SliderFrame:Destroy()
		Library.Options[Idx] = nil
	end

	Slider:SetValue(typeof(Config.Default) == "number" and Config.Default or Slider.Min)

	Library.Options[Idx] = Slider

	Slider.Instance = SliderFrame

	return setmetatable(Slider, {
		__newindex = function(self, index, newvalue)
			if index == "Value" then
				task.spawn(Slider.SetValue, Slider, newvalue)
			end
			rawset(self, index, newvalue)
		end,
	})
end

return Element
