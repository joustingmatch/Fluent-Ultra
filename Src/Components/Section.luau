local Root = script.Parent.Parent
local Creator = require(Root.Modules.Creator)

local New = Creator.New

return function(Title, Parent)
	local Section = {}

	Section.Layout = New("UIListLayout", {
		Padding = UDim.new(0, 0),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})

	-- The groupbox: a rounded panel that wraps the section's rows, with
	-- hairline dividers between them (see Element.luau).
	Section.Container = New("Frame", {
		Size = UDim2.new(1, 0, 0, 26),
		Position = UDim2.fromOffset(0, 24),
		BackgroundTransparency = 0.9,
		ClipsDescendants = true,
		ThemeTag = {
			BackgroundColor3 = "Element",
		},
	}, {
		Section.Layout,
		New("UICorner", {
			CornerRadius = UDim.new(0, 8),
		}),
		New("UIStroke", {
			Transparency = 0.55,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			ThemeTag = {
				Color = "ElementBorder",
			},
		}),
	})

	Section.Root = New("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 26),
		LayoutOrder = 7,
		Parent = Parent,
	}, {
		New("TextLabel", {
			RichText = true,
			Text = string.upper(Title),
			TextTransparency = 0,
			FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
			TextSize = 12,
			TextXAlignment = "Left",
			TextYAlignment = "Center",
			Size = UDim2.new(1, -16, 0, 14),
			Position = UDim2.fromOffset(2, 4),
			ThemeTag = {
				TextColor3 = "SubText",
			},
		}),
		Section.Container,
	})

	-- Show every row divider except the one on the final row.
	local function UpdateDividers()
		local Last, LastY = nil, -math.huge
		for _, Child in next, Section.Container:GetChildren() do
			local Divider = Child:IsA("GuiObject") and Child:FindFirstChild("GroupboxDivider")
			if Divider then
				Divider.Visible = true
				if Child.AbsolutePosition.Y >= LastY then
					LastY = Child.AbsolutePosition.Y
					Last = Divider
				end
			end
		end
		if Last then
			Last.Visible = false
		end
	end

	Creator.AddSignal(Section.Container.ChildAdded, function()
		task.defer(UpdateDividers)
	end)

	Creator.AddSignal(Section.Layout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
		if Section.Container.Size ~= UDim2.new(1, 0, 0, Section.Layout.AbsoluteContentSize.Y) or Section.Root.Size ~= UDim2.new(1, 0, 0, Section.Layout.AbsoluteContentSize.Y + 25) then
			Section.Container.Size = UDim2.new(1, 0, 0, Section.Layout.AbsoluteContentSize.Y)
			Section.Root.Size = UDim2.new(1, 0, 0, Section.Layout.AbsoluteContentSize.Y + 25)
		end
		UpdateDividers()
	end)

	return Section
end
