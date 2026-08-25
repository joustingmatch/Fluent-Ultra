local Root = script.Parent.Parent
local Creator = require(Root.Modules.Creator)

local New = Creator.New

return function(Title, Parent)
	local Section = {}

	Section.Layout = New("UIListLayout", {
		Padding = UDim.new(0, 5),
	})

	Section.Container = New("Frame", {
		Size = UDim2.new(1, 0, 0, 26),
		Position = UDim2.fromOffset(0, 24),
		BackgroundTransparency = 1,
	}, {
		Section.Layout,
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
			Position = UDim2.fromOffset(0, 4),
			ThemeTag = {
				TextColor3 = "SubText",
			},
		}),
		Section.Container,
	})

	Creator.AddSignal(Section.Layout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
		if Section.Container.Size ~= UDim2.new(1, 0, 0, Section.Layout.AbsoluteContentSize.Y) or Section.Root.Size ~= UDim2.new(1, 0, 0, Section.Layout.AbsoluteContentSize.Y + 25) then
			Section.Container.Size = UDim2.new(1, 0, 0, Section.Layout.AbsoluteContentSize.Y)
			Section.Root.Size = UDim2.new(1, 0, 0, Section.Layout.AbsoluteContentSize.Y + 25)
		end
	end)

	return Section
end
