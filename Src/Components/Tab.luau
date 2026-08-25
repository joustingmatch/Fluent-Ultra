local TweenService = game:GetService("TweenService")
local Root = script.Parent.Parent
local Flipper = require(Root.Packages.Flipper)
local Creator = require(Root.Modules.Creator)

local New = Creator.New
local Spring = Flipper.Spring.new
local Instant = Flipper.Instant.new
local Components = Root.Components

local TabModule = {
	Window = nil,
	Tabs = {},
	Containers = {},
	SelectedTab = 0,
	TabCount = 0,
}

function TabModule:Init(Window)
	TabModule.Window = Window
	return TabModule
end

function TabModule:GetCurrentTabPos()
	local TabHolderPos = TabModule.Window.TabHolder.AbsolutePosition.Y
	local TabPos = TabModule.Tabs[TabModule.SelectedTab].Frame.AbsolutePosition.Y

	return TabPos - TabHolderPos
end

function TabModule:New(Title, Icon, Parent)
	local Library = require(Root)
	local Window = TabModule.Window
	local Elements = Library.Elements

	TabModule.TabCount = TabModule.TabCount + 1
	local TabIndex = TabModule.TabCount

	local Tab = {
		Selected = false,
		Name = Title,
		Type = "Tab",
	}

	Icon = Icon:find("^rbxasset[://|id://]") == nil and Library.Utilities:GetIcon(Icon) or {
		Image = Icon,
		ImageRectOffset = Vector2.zero,
		ImageRectSize = Vector2.zero
	}

	-- Icon-only rail button: the icon is centered, the tab name lives in a
	-- hover tooltip (see below) rather than beside the icon.
	Tab.IconImage = New("ImageLabel", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.fromOffset(20, 20),
		Position = UDim2.fromScale(0.5, 0.5),
		BackgroundTransparency = 1,
		ImageRectOffset = Icon and Icon.ImageRectOffset or Vector2.zero,
		ImageRectSize = Icon and Icon.ImageRectSize or Vector2.zero,
		Image = Icon and Icon.Image or nil,
		ThemeTag = {
			ImageColor3 = "Text",
		},
	})

	Tab.Frame = New("TextButton", {
		Size = UDim2.new(1, 0, 0, 44),
		BackgroundTransparency = 1,
		Parent = Parent,
		Text = "",
		ThemeTag = {
			BackgroundColor3 = "Tab",
		},
	}, {
		New("UICorner", {
			CornerRadius = UDim.new(0, 12),
		}),
		Tab.IconImage,
	})

	-- Tooltip that reveals the tab name to the right of the rail on hover,
	-- with a smooth scale + fade pop.
	local TooltipScale = New("UIScale", { Scale = 0.85 })
	local TooltipStroke = New("UIStroke", {
		Transparency = 0.7,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		ThemeTag = {
			Color = "DropdownBorder",
		},
	})
	local TooltipLabel = New("TextLabel", {
		Text = Title,
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.fromScale(0, 1),
		BackgroundTransparency = 1,
		FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
		TextSize = 13,
		TextYAlignment = "Center",
		ZIndex = 1000,
		ThemeTag = {
			TextColor3 = "Text",
		},
	})

	local Tooltip = New("Frame", {
		Parent = Window.Root,
		Visible = false,
		AnchorPoint = Vector2.new(0, 0.5),
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.fromOffset(0, 26),
		BackgroundTransparency = 0.05,
		ZIndex = 999,
		ThemeTag = {
			BackgroundColor3 = "DropdownHolder",
		},
	}, {
		New("UICorner", {
			CornerRadius = UDim.new(0, 6),
		}),
		New("UIPadding", {
			PaddingLeft = UDim.new(0, 10),
			PaddingRight = UDim.new(0, 10),
		}),
		TooltipStroke,
		TooltipLabel,
		TooltipScale,
	})

	local TooltipOpen = false

	local function ShowTooltip()
		local RelY = Tab.Frame.AbsolutePosition.Y - Window.Root.AbsolutePosition.Y
		Tooltip.Position = UDim2.fromOffset(12 + Window.TabWidth + 10, RelY + 20)
		TooltipOpen = true
		Tooltip.Visible = true

		TooltipScale.Scale = 0.85
		Tooltip.BackgroundTransparency = 1
		TooltipStroke.Transparency = 1
		TooltipLabel.TextTransparency = 1

		local Info = TweenInfo.new(0.16, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
		local FadeInfo = TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		TweenService:Create(TooltipScale, Info, { Scale = 1 }):Play()
		TweenService:Create(Tooltip, FadeInfo, { BackgroundTransparency = 0.05 }):Play()
		TweenService:Create(TooltipStroke, FadeInfo, { Transparency = 0.7 }):Play()
		TweenService:Create(TooltipLabel, FadeInfo, { TextTransparency = 0 }):Play()
	end

	local function HideTooltip()
		TooltipOpen = false
		local Info = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		TweenService:Create(TooltipScale, Info, { Scale = 0.85 }):Play()
		TweenService:Create(Tooltip, Info, { BackgroundTransparency = 1 }):Play()
		TweenService:Create(TooltipStroke, Info, { Transparency = 1 }):Play()
		TweenService:Create(TooltipLabel, Info, { TextTransparency = 1 }):Play()
		task.delay(0.13, function()
			if not TooltipOpen then
				Tooltip.Visible = false
			end
		end)
	end

	local ContainerLayout = New("UIListLayout", {
		Padding = UDim.new(0, 5),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})

	Tab.ContainerFrame = New("ScrollingFrame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Parent = Window.ContainerHolder,
		Visible = false,
		BottomImage = "rbxassetid://6889812791",
		MidImage = "rbxassetid://6889812721",
		TopImage = "rbxassetid://6276641225",
		ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255),
		ScrollBarImageTransparency = 0.95,
		ScrollBarThickness = 3,
		BorderSizePixel = 0,
		CanvasSize = UDim2.fromScale(0, 0),
		ScrollingDirection = Enum.ScrollingDirection.Y,
	}, {
		ContainerLayout,
		New("UIPadding", {
			PaddingRight = UDim.new(0, 10),
			PaddingLeft = UDim.new(0, 1),
			PaddingTop = UDim.new(0, 1),
			PaddingBottom = UDim.new(0, 1),
		}),
	})

	Creator.AddSignal(ContainerLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
		if Tab.ContainerFrame.CanvasSize ~= UDim2.fromOffset(0, ContainerLayout.AbsoluteContentSize.Y + 2) then
			Tab.ContainerFrame.CanvasSize = UDim2.fromOffset(0, ContainerLayout.AbsoluteContentSize.Y + 2)
		end
	end)

	Tab.Motor, Tab.SetTransparency = Creator.SpringMotor(1, Tab.Frame, "BackgroundTransparency")

	Creator.AddSignal(Tab.Frame.MouseEnter, function()
		Tab.SetTransparency(Tab.Selected and 0.85 or 0.89)
		ShowTooltip()
	end)
	Creator.AddSignal(Tab.Frame.MouseLeave, function()
		Tab.SetTransparency(Tab.Selected and 0.89 or 1)
		HideTooltip()
	end)
	Creator.AddSignal(Tab.Frame.MouseButton1Down, function()
		Tab.SetTransparency(0.92)
	end)
	Creator.AddSignal(Tab.Frame.MouseButton1Up, function()
		Tab.SetTransparency(Tab.Selected and 0.85 or 0.89)
	end)
	Creator.AddSignal(Tab.Frame.MouseButton1Click, function()
		HideTooltip()
		TabModule:SelectTab(TabIndex)
	end)

	TabModule.Containers[TabIndex] = Tab.ContainerFrame
	TabModule.Tabs[TabIndex] = Tab

	Tab.Container = Tab.ContainerFrame
	Tab.ScrollFrame = Tab.Container

	-- Builds two side-by-side columns (Obsidian-style Left/Right groupboxes)
	-- inside the given parent frame.
	local function BuildColumns(ParentFrame)
		local function Column(XScale, XOffset)
			return New("Frame", {
				Parent = ParentFrame,
				BackgroundTransparency = 1,
				Position = UDim2.new(XScale, XOffset, 0, 0),
				Size = UDim2.new(0.5, -8, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
			}, {
				New("UIListLayout", {
					Padding = UDim.new(0, 14),
					SortOrder = Enum.SortOrder.LayoutOrder,
				}),
			})
		end
		return Column(0, 0), Column(0.5, 8)
	end

	local function MakeSection(SectionTitle, Column, ScrollFrame)
		local Section = { Type = "Section" }
		local SectionFrame = require(Components.Section)(SectionTitle, Column)
		Section.Container = SectionFrame.Container
		Section.ScrollFrame = ScrollFrame
		setmetatable(Section, Elements)
		return Section
	end

	-- Plain (non-sub-tab) tab content: a single wrapper holding two columns.
	Tab.ContentWrapper = New("Frame", {
		Parent = Tab.ContainerFrame,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = 1,
	})
	Tab.LeftColumn, Tab.RightColumn = BuildColumns(Tab.ContentWrapper)

	function Tab:CreateLeftGroupbox(SectionTitle)
		return MakeSection(SectionTitle, Tab.LeftColumn, Tab.ContainerFrame)
	end
	function Tab:CreateRightGroupbox(SectionTitle)
		return MakeSection(SectionTitle, Tab.RightColumn, Tab.ContainerFrame)
	end
	Tab.AddLeftGroupbox = Tab.CreateLeftGroupbox
	Tab.AddRightGroupbox = Tab.CreateRightGroupbox

	-- Section defaults to the left column for backward compatibility.
	function Tab:Section(SectionTitle)
		return MakeSection(SectionTitle, Tab.LeftColumn, Tab.ContainerFrame)
	end

	Tab.CreateSection = Tab.Section
	Tab.AddSection = Tab.Section

	-- ============================ Sub-Tabs ============================
	-- A top-level tab can hold sub-tabs, rendered as a centered text nav
	-- (Farming / Hatching / ...) at the top of the content area with an
	-- accent underline on the active one.
	Tab.SubTabs = {}
	Tab.SelectedSubTab = 0

	Tab.HeaderUnderline = New("Frame", {
		AnchorPoint = Vector2.new(0, 1),
		Size = UDim2.fromOffset(0, 2),
		Position = UDim2.fromScale(0, 1),
		BackgroundColor3 = Color3.fromRGB(76, 194, 255),
		Visible = false,
		ZIndex = 2,
		ThemeTag = {
			BackgroundColor3 = "Accent",
		},
	}, {
		New("UICorner", { CornerRadius = UDim.new(1, 0) }),
	})

	Tab.HeaderButtons = New("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
	}, {
		New("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 22),
		}),
	})

	Tab.HeaderRow = New("Frame", {
		Parent = Window.Root,
		Visible = false,
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(Window.TabWidth + 26, 44),
		Size = UDim2.new(1, -(Window.TabWidth + 52), 0, 30),
	}, {
		Tab.HeaderButtons,
		Tab.HeaderUnderline,
	})

	local function UpdateHeaderUnderline(Animate)
		local Active = Tab.SubTabs[Tab.SelectedSubTab]
		if not Active then
			Tab.HeaderUnderline.Visible = false
			return
		end
		local X = Active.Button.AbsolutePosition.X - Tab.HeaderRow.AbsolutePosition.X
		Tab.HeaderUnderline.Visible = true
		local GoalPos = UDim2.new(0, X, 1, 0)
		local GoalSize = UDim2.fromOffset(Active.Button.AbsoluteSize.X, 2)
		if Animate then
			local Info = TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
			TweenService:Create(Tab.HeaderUnderline, Info, { Position = GoalPos, Size = GoalSize }):Play()
		else
			Tab.HeaderUnderline.Position = GoalPos
			Tab.HeaderUnderline.Size = GoalSize
		end
	end

	Creator.AddSignal(Tab.HeaderRow:GetPropertyChangedSignal("AbsoluteSize"), UpdateHeaderUnderline)

	-- Show the header (and hide the single centered title) whenever this tab
	-- is the visible one and it actually has sub-tabs.
	Creator.AddSignal(Tab.ContainerFrame:GetPropertyChangedSignal("Visible"), function()
		local HasSubs = #Tab.SubTabs > 0
		local Active = Tab.ContainerFrame.Visible
		Tab.HeaderRow.Visible = Active and HasSubs
		if Active then
			-- Sub-tabbed tabs show the header; plain tabs show the centered title.
			Window.TabDisplay.Visible = not HasSubs
			Window.TabDisplayUnderline.Visible = not HasSubs
			Window:SetContentTop(HasSubs)
			if HasSubs then
				task.defer(UpdateHeaderUnderline)
			end
		end
	end)

	function Tab:SelectSubTab(Index)
		Tab.SelectedSubTab = Index
		local FadeInfo = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		for i, Sub in next, Tab.SubTabs do
			local On = i == Index
			if On then
				Sub.Page.Visible = true
				Sub.Page.GroupTransparency = 1
				TweenService:Create(Sub.Page, FadeInfo, { GroupTransparency = 0 }):Play()
			else
				Sub.Page.Visible = false
			end
			TweenService:Create(Sub.Button, FadeInfo, { TextTransparency = On and 0 or 0.45 }):Play()
		end
		UpdateHeaderUnderline(true)
	end

	function Tab:SubTab(SubConfig)
		SubConfig = typeof(SubConfig) == "table" and SubConfig or { Title = tostring(SubConfig) }
		local Title = SubConfig.Title or "SubTab"

		local Index = #Tab.SubTabs + 1

		local SubTab = {
			Type = "SubTab",
			Name = Title,
		}

		SubTab.Button = New("TextButton", {
			Parent = Tab.HeaderButtons,
			BackgroundTransparency = 1,
			AutomaticSize = Enum.AutomaticSize.X,
			Size = UDim2.fromScale(0, 1),
			Text = Title,
			TextTransparency = 0.45,
			FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
			TextSize = 15,
			LayoutOrder = Index,
			ThemeTag = {
				TextColor3 = "Text",
			},
		})

		SubTab.Page = New("CanvasGroup", {
			Parent = Tab.ContainerFrame,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			GroupTransparency = 0,
			Visible = Index == 1,
			LayoutOrder = Index,
		})

		SubTab.LeftColumn, SubTab.RightColumn = BuildColumns(SubTab.Page)
		SubTab.Container = SubTab.Page
		SubTab.ScrollFrame = Tab.ContainerFrame

		Creator.AddSignal(SubTab.Button.MouseButton1Click, function()
			Tab:SelectSubTab(Index)
		end)

		function SubTab:CreateLeftGroupbox(SectionTitle)
			return MakeSection(SectionTitle, SubTab.LeftColumn, Tab.ContainerFrame)
		end
		function SubTab:CreateRightGroupbox(SectionTitle)
			return MakeSection(SectionTitle, SubTab.RightColumn, Tab.ContainerFrame)
		end
		SubTab.AddLeftGroupbox = SubTab.CreateLeftGroupbox
		SubTab.AddRightGroupbox = SubTab.CreateRightGroupbox

		function SubTab:Section(SectionTitle)
			return MakeSection(SectionTitle, SubTab.LeftColumn, Tab.ContainerFrame)
		end
		SubTab.CreateSection = SubTab.Section
		SubTab.AddSection = SubTab.Section

		Tab.SubTabs[Index] = SubTab
		setmetatable(SubTab, Elements)

		if Index == 1 then
			Tab.SelectedSubTab = 1
			SubTab.Button.TextTransparency = 0
			task.defer(UpdateHeaderUnderline)
		end

		return SubTab
	end

	Tab.CreateSubTab = Tab.SubTab
	Tab.AddSubTab = Tab.SubTab

	setmetatable(Tab, Elements)
	return Tab
end

function TabModule:SelectTab(Tab)
	local Window = TabModule.Window

	TabModule.SelectedTab = Tab

	for _, TabObject in next, TabModule.Tabs do
		TabObject.SetTransparency(1)
		TabObject.Selected = false
	end

	TabModule.Tabs[Tab].SetTransparency(0.89)
	TabModule.Tabs[Tab].Selected = true

	-- Active icon renders dark on the accent highlight; others stay light.
	for Index, TabObject in next, TabModule.Tabs do
		if TabObject.IconImage then
			Creator.OverrideTag(TabObject.IconImage, {
				ImageColor3 = Index == Tab and "ToggleToggled" or "Text",
			})
		end
	end

	Window.TabDisplay.Text = TabModule.Tabs[Tab].Name
	Window.SelectorPosMotor:setGoal(Spring(TabModule:GetCurrentTabPos(), { frequency = 6 }))

	task.spawn(function()
		Window.ContainerHolder.Parent = Window.ContainerAnim
		
		Window.ContainerPosMotor:setGoal(Spring(15, { frequency = 10 }))
		Window.ContainerBackMotor:setGoal(Spring(1, { frequency = 10 }))

		task.wait(0.12)

		for _, Container in next, TabModule.Containers do
			Container.Visible = false
		end
	
		TabModule.Containers[Tab].Visible = true
		Window.ContainerPosMotor:setGoal(Spring(0, { frequency = 5 }))
		Window.ContainerBackMotor:setGoal(Spring(0, { frequency = 8 }))

		task.wait(0.12)

		Window.ContainerHolder.Parent = Window.ContainerCanvas
	end)
end

return TabModule
