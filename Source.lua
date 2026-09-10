-- I own the copyright, don't steal it or pretend the template is yours, I'm the owner, an 11-year-old kid. --

local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local KikiUI = {}
KikiUI.__index = KikiUI

local Anims = loadstring(game:HttpGet("ENLACE_ANIMS"))()
local Maker = loadstring(game:HttpGet("ENLACE_MAKER"))()

function KikiUI.NewWindow(userConfig)
	userConfig = userConfig or {}
	
	local Config = {
		Title = userConfig.Title or "KikiUI",
		Author = userConfig.Author or nil,
		TextColor = userConfig.TextColor or Color3.fromRGB(255, 255, 255),
		BGColor = userConfig.BGColor or Color3.fromRGB(35, 35, 35),
		ButtonsBGColor = userConfig.ButtonsBGColor or Color3.fromRGB(15, 15, 15),
		TabsBGColor = userConfig.TabsBGColor or Color3.fromRGB(25, 25, 25),
		BorderColor = userConfig.BorderColor or Color3.fromRGB(0, 0, 0),
		KeySystem = userConfig.KeySystem or false,
		Key = userConfig.Key or "KikiKey123",
		NotificationBGTransparency = userConfig.NotificationBGTransparency or 0.2,
		NotificationBGColor = userConfig.NotificationBGColor or Color3.fromRGB(127.5, 127.5, 127.5),
		NotificationTextColor = userConfig.NotificationTextColor or Color3.fromRGB(255, 255, 255)
	}

	if Config.KeySystem then
		local passed = false
		local KeyGui = Instance.new("ScreenGui")
		KeyGui.Name = "KikiKeySystem"
		KeyGui.Parent = CoreGui
		
		local MainKey = Instance.new("Frame", KeyGui)
		MainKey.Size = UDim2.new(0, 300, 0, 150)
		MainKey.Position = UDim2.new(0.5, -150, 0.5, -75)
		MainKey.BackgroundColor3 = Config.BGColor
		MainKey.BorderSizePixel = 1
		MainKey.BorderColor3 = Config.BorderColor
		
		local TextBox = Instance.new("TextBox", MainKey)
		TextBox.Size = UDim2.new(0, 260, 0, 40)
		TextBox.Position = UDim2.new(0.5, -130, 0.4, 0)
		TextBox.PlaceholderText = "Introduce la Key..."
		TextBox.TextColor3 = Config.TextColor
		TextBox.BackgroundColor3 = Config.ButtonsBGColor
		TextBox.Text = ""
		
		local SubmitBtn = Instance.new("TextButton", MainKey)
		SubmitBtn.Size = UDim2.new(0, 120, 0, 30)
		SubmitBtn.Position = UDim2.new(0.5, -60, 0.75, 0)
		SubmitBtn.Text = "enter"
		SubmitBtn.TextColor3 = Config.TextColor
		SubmitBtn.BackgroundColor3 = Config.TabsBGColor
		
		local conn
		conn = SubmitBtn.MouseButton1Click:Connect(function()
			if TextBox.Text == Config.Key then
				passed = true
				KeyGui:Destroy()
				conn:Disconnect()
			else
				TextBox.Text = ""
				TextBox.PlaceholderText = "incorrect key!"
			end
		end)
		
		repeat task.wait() until passed
	end

	local self = setmetatable({}, KikiUI)
	self.Config = Config
	self.ActiveElements = {}

	self.ScreenGui = Instance.new("ScreenGui")
	self.ScreenGui.Name = "KikiUI_Main"
	self.ScreenGui.Parent = CoreGui
	self.ScreenGui.ResetOnSpawn = false

	self.MainFrame = Instance.new("Frame", self.ScreenGui)
	self.MainFrame.Name = "MainFrame"
	self.MainFrame.Size = UDim2.new(0, 550, 0, 380)
	self.MainFrame.Position = UDim2.new(0.5, -275, 0.5, -190)
	self.MainFrame.BackgroundColor3 = Config.BGColor
	self.MainFrame.BorderSizePixel = 1
	self.MainFrame.BorderColor3 = Config.BorderColor
	self.MainFrame.Active = true
	self.MainFrame.Draggable = true

	self.Topbar = Instance.new("Frame", self.MainFrame)
	self.Topbar.Size = UDim2.new(1, 0, 0, 30)
	self.Topbar.BackgroundColor3 = Config.TabsBGColor
	self.Topbar.BorderSizePixel = 0

	self.TitleLabel = Instance.new("TextLabel", self.Topbar)
	self.TitleLabel.Size = UDim2.new(0, 200, 1, 0)
	self.TitleLabel.Position = UDim2.new(0, 10, 0, 0)
	self.TitleLabel.BackgroundTransparency = 1
	self.TitleLabel.Text = Config.Title
	self.TitleLabel.TextColor3 = Config.TextColor
	self.TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
	self.TitleLabel.Font = Enum.Font.SourceSansBold

	if Config.Author then
		self.AuthorLabel = Instance.new("TextLabel", self.Topbar)
		self.AuthorLabel.Size = UDim2.new(0, 200, 1, 0)
		self.AuthorLabel.Position = UDim2.new(0, 110, 0, 0)
		self.AuthorLabel.BackgroundTransparency = 1
		self.AuthorLabel.Text = "by " .. Config.Author
		self.AuthorLabel.TextColor3 = Config.TextColor
		self.AuthorLabel.TextTransparency = 0.5
		self.AuthorLabel.TextXAlignment = Enum.TextXAlignment.Left
		self.AuthorLabel.Font = Enum.Font.SourceSans
	end

	self.TabContainer = Instance.new("ScrollingFrame", self.MainFrame)
	self.TabContainer.Size = UDim2.new(0, 140, 1, -30)
	self.TabContainer.Position = UDim2.new(0, 0, 0, 30)
	self.TabContainer.BackgroundColor3 = Config.TabsBGColor
	self.TabContainer.BorderSizePixel = 0
	self.TabContainer.CanvasSize = UDim2.new(0, 0, 0, 0)

	self.ContentContainer = Instance.new("ScrollingFrame", self.MainFrame)
	self.ContentContainer.Size = UDim2.new(1, -140, 1, -30)
	self.ContentContainer.Position = UDim2.new(0, 140, 0, 30)
	self.ContentContainer.BackgroundTransparency = 1
	self.ContentContainer.BorderSizePixel = 0
	self.ContentContainer.CanvasSize = UDim2.new(0, 0, 0, 0)

	local CloseBtn = Instance.new("TextButton", self.Topbar)
	CloseBtn.Size = UDim2.new(0, 30, 0, 30)
	CloseBtn.Position = UDim2.new(1, -30, 0, 0)
	CloseBtn.Text = "X"
	CloseBtn.TextColor3 = Config.TextColor
	CloseBtn.BackgroundTransparency = 1
	CloseBtn.MouseButton1Click:Connect(function()
		Anims.CloseWindow(self.MainFrame, function()
			self.ScreenGui:Destroy()
		end)
	end)

	local minimized = false
	local MinimizeBtn = Instance.new("TextButton", self.Topbar)
	MinimizeBtn.Size = UDim2.new(0, 30, 0, 30)
	MinimizeBtn.Position = UDim2.new(1, -60, 0, 0)
	MinimizeBtn.Text = "-"
	MinimizeBtn.TextColor3 = Config.TextColor
	MinimizeBtn.BackgroundTransparency = 1
	MinimizeBtn.MouseButton1Click:Connect(function()
		minimized = not minimized
		Anims.MinimizeWindow(self.MainFrame, minimized)
	end)

	function self:UpdateConfig(newConfig)
		for k, v in pairs(newConfig) do
			Config[k] = v
		end
		self.MainFrame.BackgroundColor3 = Config.BGColor
		self.MainFrame.BorderColor3 = Config.BorderColor
		self.Topbar.BackgroundColor3 = Config.TabsBGColor
		self.TabContainer.BackgroundColor3 = Config.TabsBGColor
		self.TitleLabel.TextColor3 = Config.TextColor
		if self.AuthorLabel then self.AuthorLabel.TextColor3 = Config.TextColor end
	end

	self.MakerInstance = Maker.Initialize(self)

	return self
end

return KikiUI
