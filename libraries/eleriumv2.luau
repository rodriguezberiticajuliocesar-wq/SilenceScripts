--[[
    Modified Elerium V2
	EleriumV2 was made by github.com/memejames
	Project url: https://github.com/memejames/elerium-v2-ui-library
	modified by honen @cianami1
]]

local ui_options = {
	main_color = Color3.fromRGB(41, 74, 122),
	min_size = Vector2.new(400, 300),
	toggle_key = Enum.KeyCode.RightShift,
	can_resize = true,
}

do
	local function destroyImguiIn(parent)
		if parent and parent.FindFirstChild then
			local existing = parent:FindFirstChild("imgui")
			if existing then
				pcall(function() existing:Destroy() end)
			end
		end
	end

	destroyImguiIn(game:GetService("CoreGui"))

	local Players = game:GetService("Players")
	if Players and Players.LocalPlayer then
		destroyImguiIn(Players.LocalPlayer:FindFirstChild("PlayerGui"))
	end

	if type(gethui) == "function" then
		local ok, gh = pcall(gethui)
		if ok and gh then
			destroyImguiIn(gh)
		end
	end

	for _,v in pairs(game:GetDescendants()) do
		if v.Name == "imgui" and v:IsA("ScreenGui") then
			pcall(function() v:Destroy() end)
		end
	end
end

local imgui = Instance.new("ScreenGui")
local prefabs = Instance.new("Frame")
local label = Instance.new("TextLabel")
local window = Instance.new("ImageLabel")
local resizer = Instance.new("Frame")
local bar = Instance.new("Frame")
local toggle = Instance.new("ImageButton")
local base = Instance.new("ImageLabel")
local top = Instance.new("ImageLabel")
local tabs = Instance.new("Frame")
local titleLabel = Instance.new("TextLabel")
local tabSelection = Instance.new("ImageLabel")
local tabButtons = Instance.new("Frame")
local uiListLayout = Instance.new("UIListLayout")
local frame = Instance.new("Frame")
local tab = Instance.new("Frame")
local uiListLayout2 = Instance.new("UIListLayout")
local textBox = Instance.new("TextBox")
local textBoxRoundify4px = Instance.new("ImageLabel")
local slider = Instance.new("ImageLabel")
local sliderTitle = Instance.new("TextLabel")
local indicator = Instance.new("ImageLabel")
local sliderValue = Instance.new("TextLabel")
local textLabel = Instance.new("TextLabel")
local textLabel2 = Instance.new("TextLabel")
local circle = Instance.new("ImageLabel")
local uiListLayout3 = Instance.new("UIListLayout")
local dropdown = Instance.new("TextButton")
local dropdownIndicator = Instance.new("ImageLabel")
local dropdownBox = Instance.new("ImageButton")
local dropdownObjects = Instance.new("ScrollingFrame")
local uiListLayout4 = Instance.new("UIListLayout")
local textButtonRoundify4px = Instance.new("ImageLabel")
local tabButton = Instance.new("TextButton")
local textButtonRoundify4px_2 = Instance.new("ImageLabel")
local folder = Instance.new("ImageLabel")
local button = Instance.new("TextButton")
local textButtonRoundify4px_3 = Instance.new("ImageLabel")
local toggle2 = Instance.new("ImageLabel")
local objects2 = Instance.new("Frame")
local uiListLayout5 = Instance.new("UIListLayout")
local horizontalAlignment = Instance.new("Frame")
local uiListLayout6 = Instance.new("UIListLayout")
local console = Instance.new("ImageLabel")
local scrollingFrame = Instance.new("ScrollingFrame")
local source = Instance.new("TextBox")
local commentsLabel = Instance.new("TextLabel")
local globalsLabel = Instance.new("TextLabel")
local keywordsLabel = Instance.new("TextLabel")
local remoteHighlight = Instance.new("TextLabel")
local stringsLabel = Instance.new("TextLabel")
local tokensLabel = Instance.new("TextLabel")
local numbersLabel = Instance.new("TextLabel")
local infoLabel = Instance.new("TextLabel")
local linesLabel = Instance.new("TextLabel")
local colorPicker = Instance.new("ImageLabel")
local palette = Instance.new("ImageLabel")
local indicator3 = Instance.new("ImageLabel")
local sample = Instance.new("ImageLabel")
local saturation = Instance.new("ImageLabel")
local indicator4 = Instance.new("Frame")
local switchButton = Instance.new("TextButton")
local textButtonRoundify4px_4 = Instance.new("ImageLabel")
local title3Label = Instance.new("TextLabel")
local button2 = Instance.new("TextButton")
local textButtonRoundify4px_5 = Instance.new("ImageLabel")
local dropdownButton = Instance.new("TextButton")
local keybind = Instance.new("ImageLabel")
local title4Label = Instance.new("TextLabel")
local inputButton = Instance.new("TextButton")
local inputRoundify4px = Instance.new("ImageLabel")
local windowsFrame = Instance.new("Frame")
local cloneref = cloneref and cloneref or function(...) return ... end
local CoreGui= cloneref(game:GetService("CoreGui"))


imgui.Name = "imgui"
imgui.Parent = gethui and gethui() or (CoreGui or game.Players.LocalPlayer:WaitForChild("PlayerGui"))
prefabs.Name = "Prefabs"
prefabs.Parent = imgui
prefabs.BackgroundColor3 = Color3.new(1, 1, 1)
prefabs.Size = UDim2.new(0, 100, 0, 100)
prefabs.Visible = false

label.Name = "Label"
label.Parent = prefabs
label.BackgroundColor3 = Color3.new(1, 1, 1)
label.BackgroundTransparency = 1
label.Size = UDim2.new(0, 200, 0, 20)
label.Font = Enum.Font.GothamSemibold
label.Text = "Hello, world 123"
label.TextColor3 = Color3.new(1, 1, 1)
label.TextSize = 14
label.TextXAlignment = Enum.TextXAlignment.Left

window.Name = "Window"
window.Parent = prefabs
window.Active = true
window.BackgroundColor3 = Color3.new(1, 1, 1)
window.BackgroundTransparency = 1
window.ClipsDescendants = true
window.Position = UDim2.new(0, 20, 0, 20)
window.Selectable = true
window.Size = UDim2.new(0, 200, 0, 200)
window.Image = "rbxassetid://2851926732"
window.ImageColor3 = Color3.new(0.0823529, 0.0862745, 0.0901961)
window.ScaleType = Enum.ScaleType.Slice
window.SliceCenter = Rect.new(12, 12, 12, 12)

resizer.Name = "Resizer"
resizer.Parent = window
resizer.Active = true
resizer.BackgroundColor3 = Color3.new(1, 1, 1)
resizer.BackgroundTransparency = 1
resizer.BorderSizePixel = 0
resizer.Position = UDim2.new(1, -20, 1, -20)
resizer.Size = UDim2.new(0, 20, 0, 20)

bar.Name = "Bar"
bar.Parent = window
bar.BackgroundColor3 = Color3.new(0.160784, 0.290196, 0.478431)
bar.BorderSizePixel = 0
bar.Position = UDim2.new(0, 0, 0, 5)
bar.Size = UDim2.new(1, 0, 0, 15)

toggle.Name = "Toggle"
toggle.Parent = bar
toggle.BackgroundColor3 = Color3.new(1, 1, 1)
toggle.BackgroundTransparency = 1
toggle.Position = UDim2.new(0, 5, 0, -2)
toggle.Rotation = 0
toggle.Size = UDim2.new(0, 20, 0, 20)
toggle.ZIndex = 2
toggle.Image = "https://www.roblox.com/Thumbs/Asset.ashx?width=420&height=420&assetId=11176073582"

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0.5, 0)
toggleCorner.Parent = toggle

base.Name = "Base"
base.Parent = bar
base.BackgroundColor3 = Color3.new(0.160784, 0.290196, 0.478431)
base.BorderSizePixel = 0
base.Position = UDim2.new(0, 0, 0.800000012, 0)
base.Size = UDim2.new(1, 0, 0, 10)
base.Image = "rbxassetid://2851926732"
base.ImageColor3 = Color3.new(0.160784, 0.290196, 0.478431)
base.ScaleType = Enum.ScaleType.Slice
base.SliceCenter = Rect.new(12, 12, 12, 12)

top.Name = "Top"
top.Parent = bar
top.BackgroundColor3 = Color3.new(1, 1, 1)
top.BackgroundTransparency = 1
top.Position = UDim2.new(0, 0, 0, -5)
top.Size = UDim2.new(1, 0, 0, 10)
top.Image = "rbxassetid://2851926732"
top.ImageColor3 = Color3.new(0.160784, 0.290196, 0.478431)
top.ScaleType = Enum.ScaleType.Slice
top.SliceCenter = Rect.new(12, 12, 12, 12)

tabs.Name = "Tabs"
tabs.Parent = window
tabs.BackgroundColor3 = Color3.new(1, 1, 1)
tabs.BackgroundTransparency = 1
tabs.Position = UDim2.new(0, 15, 0, 60)
tabs.Size = UDim2.new(1, -30, 1, -60)

titleLabel.Name = "Title"
titleLabel.Parent = window
titleLabel.BackgroundColor3 = Color3.new(1, 1, 1)
titleLabel.BackgroundTransparency = 1
titleLabel.Position = UDim2.new(0, 30, 0, 3)
titleLabel.Size = UDim2.new(0, 200, 0, 20)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Text = "Gamer Time"
titleLabel.TextColor3 = Color3.new(1, 1, 1)
titleLabel.TextSize = 14
titleLabel.TextXAlignment = Enum.TextXAlignment.Left

tabSelection.Name = "TabSelection"
tabSelection.Parent = window
tabSelection.BackgroundColor3 = Color3.new(1, 1, 1)
tabSelection.BackgroundTransparency = 1
tabSelection.Position = UDim2.new(0, 15, 0, 30)
tabSelection.Size = UDim2.new(1, -30, 0, 25)
tabSelection.Visible = false
tabSelection.Image = "rbxassetid://2851929490"
tabSelection.ImageColor3 = Color3.new(0.145098, 0.14902, 0.156863)
tabSelection.ScaleType = Enum.ScaleType.Slice
tabSelection.SliceCenter = Rect.new(4, 4, 4, 4)

tabButtons.Name = "TabButtons"
tabButtons.Parent = tabSelection
tabButtons.BackgroundColor3 = Color3.new(1, 1, 1)
tabButtons.BackgroundTransparency = 1
tabButtons.Size = UDim2.new(1, 0, 1, 0)

uiListLayout.Parent = tabButtons
uiListLayout.FillDirection = Enum.FillDirection.Horizontal
uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
uiListLayout.Padding = UDim.new(0, 2)

frame.Parent = tabSelection
frame.BackgroundColor3 = Color3.new(0.12549, 0.227451, 0.372549)
frame.BorderColor3 = Color3.new(0.105882, 0.164706, 0.207843)
frame.BorderSizePixel = 0
frame.Position = UDim2.new(0, 0, 1, 0)
frame.Size = UDim2.new(1, 0, 0, 2)

tab.Name = "Tab"
tab.Parent = prefabs
tab.BackgroundColor3 = Color3.new(1, 1, 1)
tab.BackgroundTransparency = 1
tab.Size = UDim2.new(1, 0, 1, 0)
tab.Visible = false

uiListLayout2.Parent = tab
uiListLayout2.SortOrder = Enum.SortOrder.LayoutOrder
uiListLayout2.Padding = UDim.new(0, 5)

textBox.Parent = prefabs
textBox.BackgroundColor3 = Color3.new(1, 1, 1)
textBox.BackgroundTransparency = 1
textBox.BorderSizePixel = 0
textBox.Size = UDim2.new(1, 0, 0, 20)
textBox.ZIndex = 2
textBox.Font = Enum.Font.GothamSemibold
textBox.PlaceholderColor3 = Color3.new(0.698039, 0.698039, 0.698039)
textBox.PlaceholderText = "Input Text"
textBox.Text = ""
textBox.TextColor3 = Color3.new(0.784314, 0.784314, 0.784314)
textBox.TextSize = 14

textBoxRoundify4px.Name = "TextBox_Roundify_4px"
textBoxRoundify4px.Parent = textBox
textBoxRoundify4px.BackgroundColor3 = Color3.new(1, 1, 1)
textBoxRoundify4px.BackgroundTransparency = 1
textBoxRoundify4px.Size = UDim2.new(1, 0, 1, 0)
textBoxRoundify4px.Image = "rbxassetid://2851929490"
textBoxRoundify4px.ImageColor3 = Color3.new(0.203922, 0.207843, 0.219608)
textBoxRoundify4px.ScaleType = Enum.ScaleType.Slice
textBoxRoundify4px.SliceCenter = Rect.new(4, 4, 4, 4)

slider.Name = "Slider"
slider.Parent = prefabs
slider.BackgroundColor3 = Color3.new(1, 1, 1)
slider.BackgroundTransparency = 1
slider.Position = UDim2.new(0, 0, 0.178571433, 0)
slider.Size = UDim2.new(1, 0, 0, 20)
slider.Image = "rbxassetid://2851929490"
slider.ImageColor3 = Color3.new(0.145098, 0.14902, 0.156863)
slider.ScaleType = Enum.ScaleType.Slice
slider.SliceCenter = Rect.new(4, 4, 4, 4)

sliderTitle.Name = "Title"
sliderTitle.Parent = slider
sliderTitle.BackgroundColor3 = Color3.new(1, 1, 1)
sliderTitle.BackgroundTransparency = 1
sliderTitle.Position = UDim2.new(0.5, 0, 0.5, -10)
sliderTitle.Size = UDim2.new(0, 0, 0, 20)
sliderTitle.ZIndex = 2
sliderTitle.Font = Enum.Font.GothamSemibold
sliderTitle.Text = "Slider"
sliderTitle.TextColor3 = Color3.new(0.784314, 0.784314, 0.784314)
sliderTitle.TextSize = 14

indicator.Name = "Indicator"
indicator.Parent = slider
indicator.BackgroundColor3 = Color3.new(1, 1, 1)
indicator.BackgroundTransparency = 1
indicator.Size = UDim2.new(0, 0, 0, 20)
indicator.Image = "rbxassetid://2851929490"
indicator.ImageColor3 = Color3.new(0.254902, 0.262745, 0.278431)
indicator.ScaleType = Enum.ScaleType.Slice
indicator.SliceCenter = Rect.new(4, 4, 4, 4)

sliderValue.Name = "Value"
sliderValue.Parent = slider
sliderValue.BackgroundColor3 = Color3.new(1, 1, 1)
sliderValue.BackgroundTransparency = 1
sliderValue.Position = UDim2.new(1, -55, 0.5, -10)
sliderValue.Size = UDim2.new(0, 50, 0, 20)
sliderValue.Font = Enum.Font.GothamSemibold
sliderValue.Text = "0%"
sliderValue.TextColor3 = Color3.new(0.784314, 0.784314, 0.784314)
sliderValue.TextSize = 14

textLabel.Parent = slider
textLabel.BackgroundColor3 = Color3.new(1, 1, 1)
textLabel.BackgroundTransparency = 1
textLabel.Position = UDim2.new(1, -20, -0.75, 0)
textLabel.Size = UDim2.new(0, 26, 0, 50)
textLabel.Font = Enum.Font.GothamSemibold
textLabel.Text = "]"
textLabel.TextColor3 = Color3.new(0.627451, 0.627451, 0.627451)
textLabel.TextSize = 14

textLabel2.Parent = slider
textLabel2.BackgroundColor3 = Color3.new(1, 1, 1)
textLabel2.BackgroundTransparency = 1
textLabel2.Position = UDim2.new(1, -65, -0.75, 0)
textLabel2.Size = UDim2.new(0, 26, 0, 50)
textLabel2.Font = Enum.Font.GothamSemibold
textLabel2.Text = "["
textLabel2.TextColor3 = Color3.new(0.627451, 0.627451, 0.627451)
textLabel2.TextSize = 14

circle.Name = "Circle"
circle.Parent = prefabs
circle.BackgroundColor3 = Color3.new(1, 1, 1)
circle.BackgroundTransparency = 1
circle.Image = "rbxassetid://266543268"
circle.ImageTransparency = 0.5

uiListLayout3.Parent = prefabs
uiListLayout3.FillDirection = Enum.FillDirection.Horizontal
uiListLayout3.SortOrder = Enum.SortOrder.LayoutOrder
uiListLayout3.Padding = UDim.new(0, 20)

dropdown.Name = "Dropdown"
dropdown.Parent = prefabs
dropdown.BackgroundColor3 = Color3.new(1, 1, 1)
dropdown.BackgroundTransparency = 1
dropdown.BorderSizePixel = 0
dropdown.Position = UDim2.new(0, 0, 0.0833333284, 0)
dropdown.Size = UDim2.new(1, 0, 0, 20)
dropdown.ZIndex = 2
dropdown.Font = Enum.Font.GothamSemibold
dropdown.Text = "      Dropdown"
dropdown.TextColor3 = Color3.new(0.784314, 0.784314, 0.784314)
dropdown.TextSize = 14
dropdown.TextXAlignment = Enum.TextXAlignment.Left

dropdownIndicator.Name = "Indicator"
dropdownIndicator.Parent = dropdown
dropdownIndicator.BackgroundColor3 = Color3.new(1, 1, 1)
dropdownIndicator.BackgroundTransparency = 1
dropdownIndicator.Position = UDim2.new(1, -25, 0.100000001, 0)
dropdownIndicator.Rotation = -90
dropdownIndicator.Size = UDim2.new(0, 15, 0, 15)
dropdownIndicator.ZIndex = 2
dropdownIndicator.Image = "https://www.roblox.com/Thumbs/Asset.ashx?width=420&height=420&assetId=4744658743"

dropdownBox.Name = "Box"
dropdownBox.Parent = dropdown
dropdownBox.BackgroundColor3 = Color3.new(1, 1, 1)
dropdownBox.BackgroundTransparency = 1
dropdownBox.Position = UDim2.new(0, 0, 0, 25)
dropdownBox.Size = UDim2.new(1, 0, 0, 150)
dropdownBox.ZIndex = 3
dropdownBox.Image = "rbxassetid://2851929490"
dropdownBox.ImageColor3 = Color3.new(0.129412, 0.133333, 0.141176)
dropdownBox.ScaleType = Enum.ScaleType.Slice
dropdownBox.SliceCenter = Rect.new(4, 4, 4, 4)

dropdownObjects.Name = "Objects"
dropdownObjects.Parent = dropdownBox
dropdownObjects.BackgroundColor3 = Color3.new(1, 1, 1)
dropdownObjects.BackgroundTransparency = 1
dropdownObjects.BorderSizePixel = 0
dropdownObjects.Size = UDim2.new(1, 0, 1, 0)
dropdownObjects.ZIndex = 3
dropdownObjects.CanvasSize = UDim2.new(0, 0, 0, 0)
dropdownObjects.ScrollBarThickness = 8

uiListLayout4.Parent = dropdownObjects
uiListLayout4.SortOrder = Enum.SortOrder.LayoutOrder

textButtonRoundify4px.Name = "TextButton_Roundify_4px"
textButtonRoundify4px.Parent = dropdown
textButtonRoundify4px.BackgroundColor3 = Color3.new(1, 1, 1)
textButtonRoundify4px.BackgroundTransparency = 1
textButtonRoundify4px.Size = UDim2.new(1, 0, 1, 0)
textButtonRoundify4px.Image = "rbxassetid://2851929490"
textButtonRoundify4px.ImageColor3 = Color3.new(0.203922, 0.207843, 0.219608)
textButtonRoundify4px.ScaleType = Enum.ScaleType.Slice
textButtonRoundify4px.SliceCenter = Rect.new(4, 4, 4, 4)

tabButton.Name = "TabButton"
tabButton.Parent = prefabs
tabButton.BackgroundColor3 = Color3.new(0.160784, 0.290196, 0.478431)
tabButton.BackgroundTransparency = 1
tabButton.BorderSizePixel = 0
tabButton.Position = UDim2.new(0.185185179, 0, 0, 0)
tabButton.Size = UDim2.new(0, 71, 0, 20)
tabButton.ZIndex = 2
tabButton.Font = Enum.Font.GothamSemibold
tabButton.Text = "Test tab"
tabButton.TextColor3 = Color3.new(0.784314, 0.784314, 0.784314)
tabButton.TextSize = 14

textButtonRoundify4px_2.Name = "TextButton_Roundify_4px"
textButtonRoundify4px_2.Parent = tabButton
textButtonRoundify4px_2.BackgroundColor3 = Color3.new(1, 1, 1)
textButtonRoundify4px_2.BackgroundTransparency = 1
textButtonRoundify4px_2.Size = UDim2.new(1, 0, 1, 0)
textButtonRoundify4px_2.Image = "rbxassetid://2851929490"
textButtonRoundify4px_2.ImageColor3 = Color3.new(0.203922, 0.207843, 0.219608)
textButtonRoundify4px_2.ScaleType = Enum.ScaleType.Slice
textButtonRoundify4px_2.SliceCenter = Rect.new(4, 4, 4, 4)

folder.Name = "Folder"
folder.Parent = prefabs
folder.BackgroundColor3 = Color3.new(1, 1, 1)
folder.BackgroundTransparency = 1
folder.Position = UDim2.new(0, 0, 0, 50)
folder.Size = UDim2.new(1, 0, 0, 20)
folder.Image = "rbxassetid://2851929490"
folder.ImageColor3 = Color3.new(0.0823529, 0.0862745, 0.0901961)
folder.ScaleType = Enum.ScaleType.Slice
folder.SliceCenter = Rect.new(4, 4, 4, 4)

button.Name = "Button"
button.Parent = folder
button.BackgroundColor3 = Color3.new(0.160784, 0.290196, 0.478431)
button.BackgroundTransparency = 1
button.BorderSizePixel = 0
button.Size = UDim2.new(1, 0, 0, 20)
button.ZIndex = 2
button.Font = Enum.Font.GothamSemibold
button.Text = "      Folder"
button.TextColor3 = Color3.new(1, 1, 1)
button.TextSize = 14
button.TextXAlignment = Enum.TextXAlignment.Left

textButtonRoundify4px_3.Name = "TextButton_Roundify_4px"
textButtonRoundify4px_3.Parent = button
textButtonRoundify4px_3.BackgroundColor3 = Color3.new(1, 1, 1)
textButtonRoundify4px_3.BackgroundTransparency = 1
textButtonRoundify4px_3.Size = UDim2.new(1, 0, 1, 0)
textButtonRoundify4px_3.Image = "rbxassetid://2851929490"
textButtonRoundify4px_3.ImageColor3 = Color3.new(0.160784, 0.290196, 0.478431)
textButtonRoundify4px_3.ScaleType = Enum.ScaleType.Slice
textButtonRoundify4px_3.SliceCenter = Rect.new(4, 4, 4, 4)

	toggle2.Name = "Toggle"
	toggle2.Parent = button
	toggle2.BackgroundColor3 = Color3.new(1, 1, 1)
	toggle2.BackgroundTransparency = 1
	toggle2.Position = UDim2.new(0, 5, 0, 0)
	toggle2.Size = UDim2.new(0, 20, 0, 20)
	toggle2.Image = "https://www.roblox.com/Thumbs/Asset.ashx?width=420&height=420&assetId=4731371541"

	local toggle2Corner = Instance.new("UICorner")
	toggle2Corner.CornerRadius = UDim.new(0.5, 0)
	toggle2Corner.Parent = toggle2

objects2.Name = "Objects"
objects2.Parent = folder
objects2.BackgroundColor3 = Color3.new(1, 1, 1)
objects2.BackgroundTransparency = 1
objects2.Position = UDim2.new(0, 10, 0, 25)
objects2.Size = UDim2.new(1, -10, 1, -25)
objects2.Visible = false

uiListLayout5.Parent = objects2
uiListLayout5.SortOrder = Enum.SortOrder.LayoutOrder
uiListLayout5.Padding = UDim.new(0, 5)

horizontalAlignment.Name = "HorizontalAlignment"
horizontalAlignment.Parent = prefabs
horizontalAlignment.BackgroundColor3 = Color3.new(1, 1, 1)
horizontalAlignment.BackgroundTransparency = 1
horizontalAlignment.Size = UDim2.new(1, 0, 0, 20)

uiListLayout6.Parent = horizontalAlignment
uiListLayout6.FillDirection = Enum.FillDirection.Horizontal
uiListLayout6.SortOrder = Enum.SortOrder.LayoutOrder
uiListLayout6.Padding = UDim.new(0, 5)

console.Name = "Console"
console.Parent = prefabs
console.BackgroundColor3 = Color3.new(1, 1, 1)
console.BackgroundTransparency = 1
console.Size = UDim2.new(1, 0, 0, 200)
console.Image = "rbxassetid://2851928141"
console.ImageColor3 = Color3.new(0.129412, 0.133333, 0.141176)
console.ScaleType = Enum.ScaleType.Slice
console.SliceCenter = Rect.new(8, 8, 8, 8)

scrollingFrame.Parent = console
scrollingFrame.BackgroundColor3 = Color3.new(1, 1, 1)
scrollingFrame.BackgroundTransparency = 1
scrollingFrame.BorderSizePixel = 0
scrollingFrame.Size = UDim2.new(1, 0, 1, 1)
scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollingFrame.ScrollBarThickness = 4

source.Name = "Source"
source.Parent = scrollingFrame
source.BackgroundColor3 = Color3.new(1, 1, 1)
source.BackgroundTransparency = 1
source.Position = UDim2.new(0, 40, 0, 0)
source.Size = UDim2.new(1, -40, 0, 10000)
source.ZIndex = 3
source.ClearTextOnFocus = false
source.Font = Enum.Font.Code
source.MultiLine = true
source.PlaceholderColor3 = Color3.new(0.8, 0.8, 0.8)
source.Text = ""
source.TextColor3 = Color3.new(1, 1, 1)
source.TextSize = 15
source.TextStrokeColor3 = Color3.new(1, 1, 1)
source.TextWrapped = true
source.TextXAlignment = Enum.TextXAlignment.Left
source.TextYAlignment = Enum.TextYAlignment.Top

commentsLabel.Name = "Comments"
commentsLabel.Parent = source
commentsLabel.BackgroundColor3 = Color3.new(1, 1, 1)
commentsLabel.BackgroundTransparency = 1
commentsLabel.Size = UDim2.new(1, 0, 1, 0)
commentsLabel.ZIndex = 5
commentsLabel.Font = Enum.Font.Code
commentsLabel.Text = ""
commentsLabel.TextColor3 = Color3.new(0.231373, 0.784314, 0.231373)
commentsLabel.TextSize = 15
commentsLabel.TextXAlignment = Enum.TextXAlignment.Left
commentsLabel.TextYAlignment = Enum.TextYAlignment.Top

globalsLabel.Name = "Globals"
globalsLabel.Parent = source
globalsLabel.BackgroundColor3 = Color3.new(1, 1, 1)
globalsLabel.BackgroundTransparency = 1
globalsLabel.Size = UDim2.new(1, 0, 1, 0)
globalsLabel.ZIndex = 5
globalsLabel.Font = Enum.Font.Code
globalsLabel.Text = ""
globalsLabel.TextColor3 = Color3.new(0.517647, 0.839216, 0.968628)
globalsLabel.TextSize = 15
globalsLabel.TextXAlignment = Enum.TextXAlignment.Left
globalsLabel.TextYAlignment = Enum.TextYAlignment.Top

keywordsLabel.Name = "Keywords"
keywordsLabel.Parent = source
keywordsLabel.BackgroundColor3 = Color3.new(1, 1, 1)
keywordsLabel.BackgroundTransparency = 1
keywordsLabel.Size = UDim2.new(1, 0, 1, 0)
keywordsLabel.ZIndex = 5
keywordsLabel.Font = Enum.Font.Code
keywordsLabel.Text = ""
keywordsLabel.TextColor3 = Color3.new(0.972549, 0.427451, 0.486275)
keywordsLabel.TextSize = 15
keywordsLabel.TextXAlignment = Enum.TextXAlignment.Left
keywordsLabel.TextYAlignment = Enum.TextYAlignment.Top

remoteHighlight.Name = "RemoteHighlight"
remoteHighlight.Parent = source
remoteHighlight.BackgroundColor3 = Color3.new(1, 1, 1)
remoteHighlight.BackgroundTransparency = 1
remoteHighlight.Size = UDim2.new(1, 0, 1, 0)
remoteHighlight.ZIndex = 5
remoteHighlight.Font = Enum.Font.Code
remoteHighlight.Text = ""
remoteHighlight.TextColor3 = Color3.new(0, 0.568627, 1)
remoteHighlight.TextSize = 15
remoteHighlight.TextXAlignment = Enum.TextXAlignment.Left
remoteHighlight.TextYAlignment = Enum.TextYAlignment.Top

stringsLabel.Name = "Strings"
stringsLabel.Parent = source
stringsLabel.BackgroundColor3 = Color3.new(1, 1, 1)
stringsLabel.BackgroundTransparency = 1
stringsLabel.Size = UDim2.new(1, 0, 1, 0)
stringsLabel.ZIndex = 5
stringsLabel.Font = Enum.Font.Code
stringsLabel.Text = ""
stringsLabel.TextColor3 = Color3.new(0.678431, 0.945098, 0.584314)
stringsLabel.TextSize = 15
stringsLabel.TextXAlignment = Enum.TextXAlignment.Left
stringsLabel.TextYAlignment = Enum.TextYAlignment.Top

tokensLabel.Name = "Tokens"
tokensLabel.Parent = source
tokensLabel.BackgroundColor3 = Color3.new(1, 1, 1)
tokensLabel.BackgroundTransparency = 1
tokensLabel.Size = UDim2.new(1, 0, 1, 0)
tokensLabel.ZIndex = 5
tokensLabel.Font = Enum.Font.Code
tokensLabel.Text = ""
tokensLabel.TextColor3 = Color3.new(1, 1, 1)
tokensLabel.TextSize = 15
tokensLabel.TextXAlignment = Enum.TextXAlignment.Left
tokensLabel.TextYAlignment = Enum.TextYAlignment.Top

numbersLabel.Name = "Numbers"
numbersLabel.Parent = source
numbersLabel.BackgroundColor3 = Color3.new(1, 1, 1)
numbersLabel.BackgroundTransparency = 1
numbersLabel.Size = UDim2.new(1, 0, 1, 0)
numbersLabel.ZIndex = 4
numbersLabel.Font = Enum.Font.Code
numbersLabel.Text = ""
numbersLabel.TextColor3 = Color3.new(1, 0.776471, 0)
numbersLabel.TextSize = 15
numbersLabel.TextXAlignment = Enum.TextXAlignment.Left
numbersLabel.TextYAlignment = Enum.TextYAlignment.Top

infoLabel.Name = "Info"
infoLabel.Parent = source
infoLabel.BackgroundColor3 = Color3.new(1, 1, 1)
infoLabel.BackgroundTransparency = 1
infoLabel.Size = UDim2.new(1, 0, 1, 0)
infoLabel.ZIndex = 5
infoLabel.Font = Enum.Font.Code
infoLabel.Text = ""
infoLabel.TextColor3 = Color3.new(0, 0.635294, 1)
infoLabel.TextSize = 15
infoLabel.TextXAlignment = Enum.TextXAlignment.Left
infoLabel.TextYAlignment = Enum.TextYAlignment.Top

linesLabel.Name = "Lines"
linesLabel.Parent = scrollingFrame
linesLabel.BackgroundColor3 = Color3.new(1, 1, 1)
linesLabel.BackgroundTransparency = 1
linesLabel.BorderSizePixel = 0
linesLabel.Size = UDim2.new(0, 40, 0, 10000)
linesLabel.ZIndex = 4
linesLabel.Font = Enum.Font.Code
linesLabel.Text = "1\n"
linesLabel.TextColor3 = Color3.new(1, 1, 1)
linesLabel.TextSize = 15
linesLabel.TextWrapped = true
linesLabel.TextYAlignment = Enum.TextYAlignment.Top

colorPicker.Name = "ColorPicker"
colorPicker.Parent = prefabs
colorPicker.BackgroundColor3 = Color3.new(1, 1, 1)
colorPicker.BackgroundTransparency = 1
colorPicker.Size = UDim2.new(0, 180, 0, 110)
colorPicker.Image = "rbxassetid://2851929490"
colorPicker.ImageColor3 = Color3.new(0.203922, 0.207843, 0.219608)
colorPicker.ScaleType = Enum.ScaleType.Slice
colorPicker.SliceCenter = Rect.new(4, 4, 4, 4)

palette.Name = "Palette"
palette.Parent = colorPicker
palette.BackgroundColor3 = Color3.new(1, 1, 1)
palette.BackgroundTransparency = 1
palette.Position = UDim2.new(0.0500000007, 0, 0.0500000007, 0)
palette.Size = UDim2.new(0, 100, 0, 100)
palette.Image = "rbxassetid://698052001"
palette.ScaleType = Enum.ScaleType.Slice
palette.SliceCenter = Rect.new(4, 4, 4, 4)

indicator3.Name = "Indicator"
indicator3.Parent = palette
indicator3.BackgroundColor3 = Color3.new(1, 1, 1)
indicator3.BackgroundTransparency = 1
indicator3.Size = UDim2.new(0, 5, 0, 5)
indicator3.ZIndex = 2
indicator3.Image = "rbxassetid://2851926732"
indicator3.ImageColor3 = Color3.new(0, 0, 0)
indicator3.ScaleType = Enum.ScaleType.Slice
indicator3.SliceCenter = Rect.new(12, 12, 12, 12)

sample.Name = "Sample"
sample.Parent = colorPicker
sample.BackgroundColor3 = Color3.new(1, 1, 1)
sample.BackgroundTransparency = 1
sample.Position = UDim2.new(0.800000012, 0, 0.0500000007, 0)
sample.Size = UDim2.new(0, 25, 0, 25)
sample.Image = "rbxassetid://2851929490"
sample.ScaleType = Enum.ScaleType.Slice
sample.SliceCenter = Rect.new(4, 4, 4, 4)

saturation.Name = "Saturation"
saturation.Parent = colorPicker
saturation.BackgroundColor3 = Color3.new(1, 1, 1)
saturation.Position = UDim2.new(0.649999976, 0, 0.0500000007, 0)
saturation.Size = UDim2.new(0, 15, 0, 100)
saturation.Image = "rbxassetid://3641079629"

indicator4.Name = "Indicator"
indicator4.Parent = saturation
indicator4.BackgroundColor3 = Color3.new(1, 1, 1)
indicator4.BorderSizePixel = 0
indicator4.Size = UDim2.new(0, 20, 0, 2)
indicator4.ZIndex = 2

switchButton.Name = "Switch"
switchButton.Parent = prefabs
switchButton.BackgroundColor3 = Color3.new(1, 1, 1)
switchButton.BackgroundTransparency = 1
switchButton.BorderSizePixel = 0
switchButton.Position = UDim2.new(0.229411766, 0, 0.20714286, 0)
switchButton.Size = UDim2.new(0, 20, 0, 20)
switchButton.ZIndex = 2
switchButton.Font = Enum.Font.GothamSemibold
switchButton.Text = ""
switchButton
