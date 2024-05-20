local PluginComponents = script.PluginComponents
local StudioComponents = script.StudioComponents

return {
	
	Toolbar = require(PluginComponents.Toolbar),
	ToolbarButton = require(PluginComponents.ToolbarButton),
	Widget = require(PluginComponents.Widget),
	
	BaseScrollFrame = require(StudioComponents.BaseScrollFrame),
	Dropdown = require(StudioComponents.Dropdown),
	Background = require(StudioComponents.Background),
	BaseButton = require(StudioComponents.BaseButton),
	BoxBorder = require(StudioComponents.BoxBorder),
	Button = require(StudioComponents.Button),
	Checkbox = require(StudioComponents.Checkbox),
	ClassIcon = require(StudioComponents.ClassIcon),
	ColorPicker = require(StudioComponents.ColorPicker),
	IconButton = require(StudioComponents.IconButton),
	Label = require(StudioComponents.Label),
	LimitedTextInput = require(StudioComponents.LimitedTextInput),
	Loading = require(StudioComponents.Loading),
	MainButton = require(StudioComponents.MainButton),
	ProgressBar = require(StudioComponents.ProgressBar),
	ScrollFrame = require(StudioComponents.ScrollFrame),
	Shadow = require(StudioComponents.Shadow),
	Slider = require(StudioComponents.Slider),
	TextInput = require(StudioComponents.TextInput),
	Title = require(StudioComponents.Title),
	VerticalCollapsibleSection = require(StudioComponents.VerticalCollapsibleSection),
	VerticalExpandingList = require(StudioComponents.VerticalExpandingList)
	
}