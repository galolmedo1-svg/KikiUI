local TweenService = game:GetService("TweenService")
local Anims = {}

local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

function Anims.CloseWindow(mainFrame, callback)
	local tween = TweenService:Create(mainFrame, tweenInfo, {
		Size = UDim2.new(0, 0, 0, 0),
		Position = mainFrame.Position + UDim2.new(0, mainFrame.AbsoluteSize.X/2, 0, mainFrame.AbsoluteSize.Y/2)
	})
	tween:Play()
	tween.Completed:Connect(function()
		if callback then callback() end
	end)
end

local originalSize = UDim2.new(0, 550, 0, 380)
function Anims.MinimizeWindow(mainFrame, minimizeState)
	if minimizeState then
		originalSize = mainFrame.Size
		local tween = TweenService:Create(mainFrame, tweenInfo, {
			Size = UDim2.new(0, 550, 0, 30)
		})
		tween:Play()
	else
		local tween = TweenService:Create(mainFrame, tweenInfo, {
			Size = originalSize
		})
		tween:Play()
	end
end

function Anims.TabTransition(contentFrame)
	contentFrame.Position = UDim2.new(0, 20, 0, 0)
	contentFrame.BackgroundTransparency = 1
	local tween = TweenService:Create(contentFrame, tweenInfo, {
		Position = UDim2.new(0, 0, 0, 0)
	})
	tween:Play()
end

return Anims
