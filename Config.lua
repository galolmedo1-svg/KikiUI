local TweenService = game:GetService("TweenService")
local Maker = {}
Maker.__index = Maker

function Maker.Initialize(windowInstance)
	local self = setmetatable({}, Maker)
	self.Window = windowInstance
	self.Tabs = {}
	return self
end

local function applyOverrides(element, options, windowConfig)
	if options and options.TextColor then
		element.TextColor3 = options.TextColor
	else
		element.TextColor3 = windowConfig.TextColor
	end
end

local function wrapDynamicElement(guiObject, selfRef)
	local obj = {}
	obj.Instance = guiObject
	
	function obj:Hide()
		guiObject.Visible = false
	end
	
	function obj:Show()
		guiObject.Visible = true
	end
	
	function obj:Kill()
		guiObject:Destroy()
	end
	
	function obj:ChangeValue(newValue)
		if guiObject:IsA("TextButton") or guiObject:IsA("TextLabel") then
			guiObject.Text = tostring(newValue)
		elseif guiObject:IsA("TextBox") then
			guiObject.PlaceholderText = tostring(newValue)
		end
	end
	
	return obj
end

function Maker:CreateTab(name, options)
	options = options or {}
	local config = self.Window.Config
	
	local TabBtn = Instance.new("TextButton", self.Window.TabContainer)
	TabBtn.Size = UDim2.new(1, 0, 0, 35)
	TabBtn.BackgroundColor3 = config.TabsBGColor
	TabBtn.BorderSizePixel = 0
	TabBtn.Text = "  " .. name
	applyOverrides(TabBtn, options, config)
	TabBtn.TextXAlignment = Enum.TextXAlignment.Left
	TabBtn.Font = Enum.Font.SourceSans

	if options.Icon then
		local IconImg = Instance.new("ImageLabel", TabBtn)
		IconImg.Size = UDim2.new(0, 20, 0, 20)
		IconImg.Position = UDim2.new(0, 5, 0.5, -10)
		IconImg.BackgroundTransparency = 1
		IconImg.Image = "rbxassetid://" .. tostring(options.Icon)
		TabBtn.Text = "       " .. name
	end

	local TabContent = Instance.new("ScrollingFrame", self.Window.ContentContainer)
	TabContent.Size = UDim2.new(1, 0, 1, 0)
	TabContent.BackgroundTransparency = 1
	TabContent.Visible = false
	TabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
	
	local UIList = Instance.new("UIListLayout", TabContent)
	UIList.SortOrder = Enum.SortOrder.LayoutOrder
	UIList.Padding = UDim.new(0, 5)

	UIList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		TabContent.CanvasSize = UDim2.new(0, 0, 0, UIList.AbsoluteContentSize.Y + 10)
	end)

	TabBtn.MouseButton1Click:Connect(function()
		for _, tab in pairs(self.Tabs) do
			tab.Content.Visible = false
		end
		TabContent.Visible = true
	end)

	if #self.Tabs == 0 then
		TabContent.Visible = true
	end

	local tabData = { Button = TabBtn, Content = TabContent }
	table.insert(self.Tabs, tabData)

	local tabObject = wrapDynamicElement(TabBtn, self)
	
	function tabObject:CreateButton(btnName, callback, btnOptions)
		btnOptions = btnOptions or {}
		local btn = Instance.new("TextButton", TabContent)
		btn.Size = UDim2.new(1, -10, 0, 30)
		btn.BackgroundColor3 = btnOptions.ButtonsBGColor or config.ButtonsBGColor
		btn.BorderSizePixel = 0
		btn.Text = btnName
		applyOverrides(btn, btnOptions, config)
		
		btn.MouseButton1Click:Connect(function()
			if callback then callback() end
		end)
		
		return wrapDynamicElement(btn, self)
	end

	function tabObject:CreateToggle(toggleName, defaultState, trueFunc, falseFunc, toggleOptions)
		toggleOptions = toggleOptions or {}
		local state = defaultState or false
		
		local toggFrame = Instance.new("TextButton", TabContent)
		toggFrame.Size = UDim2.new(1, -10, 0, 30)
		toggFrame.BackgroundColor3 = toggleOptions.ButtonsBGColor or config.ButtonsBGColor
		toggFrame.BorderSizePixel = 0
		toggFrame.Text = "  " .. toggleName .. ": " .. tostring(state)
		applyOverrides(toggFrame, toggleOptions, config)
		toggFrame.TextXAlignment = Enum.TextXAlignment.Left

		toggFrame.MouseButton1Click:Connect(function()
			state = not state
			toggFrame.Text = "  " .. toggleName .. ": " .. tostring(state)
			if state then
				if trueFunc then trueFunc() end
			else
				if falseFunc then falseFunc() end
			end
		end)

		local wrapped = wrapDynamicElement(toggFrame, self)
		function wrapped:ChangeValue(val)
			state = val
			toggFrame.Text = "  " .. toggleName .. ": " .. tostring(state)
			if state and trueFunc then trueFunc() elseif not state and falseFunc then falseFunc() end
		end
		return wrapped
	end

	function tabObject:CreateDropDown(dropName, items, itemFunctions, dropOptions)
		dropOptions = dropOptions or {}
		local dropFrame = Instance.new("Frame", TabContent)
		dropFrame.Size = UDim2.new(1, -10, 0, 30)
		dropFrame.BackgroundColor3 = dropOptions.ButtonsBGColor or config.ButtonsBGColor
		dropFrame.BorderSizePixel = 0

		local dropBtn = Instance.new("TextButton", dropFrame)
		dropBtn.Size = UDim2.new(1, 0, 0, 30)
		dropBtn.BackgroundTransparency = 1
		dropBtn.Text = "  " .. dropName .. " ▼"
		applyOverrides(dropBtn, dropOptions, config)
		dropBtn.TextXAlignment = Enum.TextXAlignment.Left

		local isOpen = false
		local listFrame = Instance.new("ScrollingFrame", dropFrame)
		listFrame.Size = UDim2.new(1, 0, 0, 0)
		listFrame.Position = UDim2.new(0, 0, 1, 0)
		listFrame.BackgroundColor3 = config.TabsBGColor
		listFrame.BorderSizePixel = 0
		listFrame.Visible = false
		listFrame.ZIndex = 5

		local uilist = Instance.new("UIListLayout", listFrame)
		uilist.SortOrder = Enum.SortOrder.LayoutOrder

		for _, item in ipairs(items) do
			local itemBtn = Instance.new("TextButton", listFrame)
			itemBtn.Size = UDim2.new(1, 0, 0, 25)
			itemBtn.BackgroundColor3 = config.TabsBGColor
			itemBtn.Text = tostring(item)
			itemBtn.TextColor3 = config.TextColor
			itemBtn.ZIndex = 6
			itemBtn.MouseButton1Click:Connect(function()
				if itemFunctions and itemFunctions[item] then
					itemFunctions[item]()
				end
				isOpen = false
				listFrame.Visible = false
				dropFrame.Size = UDim2.new(1, -10, 0, 30)
			end)
		end

		listFrame.CanvasSize = UDim2.new(0, 0, 0, #items * 25)

		dropBtn.MouseButton1Click:Connect(function()
			isOpen = not isOpen
			if isOpen then
				listFrame.Visible = true
				dropFrame.Size = UDim2.new(1, -10, 0, 30 + (#items * 25))
			else
				listFrame.Visible = false
				dropFrame.Size = UDim2.new(1, -10, 0, 30)
			end
		end)

		return wrapDynamicElement(dropFrame, self)
	end

	function tabObject:CreateInput(inputName, placeholder, callback, inputOptions)
		inputOptions = inputOptions or {}
		local inputFrame = Instance.new("TextBox", TabContent)
		inputFrame.Size = UDim2.new(1, -10, 0, 30)
		inputFrame.BackgroundColor3 = inputOptions.ButtonsBGColor or config.ButtonsBGColor
		inputFrame.BorderSizePixel = 0
		inputFrame.PlaceholderText = placeholder or "Type here..."
		inputFrame.Text = ""
		applyOverrides(inputFrame, inputOptions, config)
		inputFrame.ClearTextOnFocus = false

		inputFrame.FocusLost:Connect(function(enterPressed)
			if enterPressed and callback then
				callback(inputFrame.Text)
			end
		end)

		return wrapDynamicElement(inputFrame, self)
	end

	function tabObject:CreateText(textContent, textOptions)
		textOptions = textOptions or {}
		local textLabel = Instance.new("TextLabel", TabContent)
		textLabel.Size = UDim2.new(1, -10, 0, 25)
		textLabel.BackgroundTransparency = 1
		textLabel.Text = textContent
		applyOverrides(textLabel, textOptions, config)
		textLabel.TextXAlignment = Enum.TextXAlignment.Left

		return wrapDynamicElement(textLabel, self)
	end

	return tabObject
end

return Maker
