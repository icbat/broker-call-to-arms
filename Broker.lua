local LibQTip = LibStub('LibQTip-1.0')
local icon = LibStub("LibDBIcon-1.0")

local ldb = LibStub:GetLibrary("LibDataBroker-1.1")

local addonName = "Call To Arms"
local dataobj = ldb:NewDataObject(addonName, {
    type = "data source",
    text = "Broker: Call to Arms",
    
    -- Find the current satchel icon with this search, grab the icon name and put it behind \\Icons\\
    -- https://www.wowhead.com/search?q=satchel%20of%20cooperation#items;0-3-2
    icon = "Interface\\Icons\\inv_misc_bag_horadricsatchel",
})

local function OnRelease(self)
    LibQTip:Release(self.tooltip)
    self.tooltip = nil
end

local function anchor_OnEnter(self)
    if self.tooltip then
        LibQTip:Release(self.tooltip)
        self.tooltip = nil
    end

    -- Acquire a tooltip with 3 columns, respectively aligned to left, center and right
    local tooltip = LibQTip:Acquire("BrokerCtaTooltip", 3, "LEFT", "LEFT", "LEFT")
    self.tooltip = tooltip
    tooltip.OnRelease = OnRelease
    tooltip.OnLeave = OnLeave
    tooltip:SetAutoHideDelay(.1, self)

    broker_cta_display.build_tooltip(tooltip)

    -- Use smart anchoring code to anchor the tooltip to our frame
    tooltip:SmartAnchorTo(self)

    -- Show it, et voilà !
    tooltip:Show()
end

-- tooltip/broker object settings
function dataobj:OnEnter()
    anchor_OnEnter(self)
end

function dataobj:OnLeave()
    -- Nothing to do. Needs to be defined for some display addons apparently
end

function dataobj:OnClick(button)
    if button == "LeftButton" then
        ToggleLFDParentFrame()
    end

    if button == "RightButton" then
        icbat_cta_minimap_settings["hide"] = not icbat_cta_minimap_settings["hide"]
        if icbat_cta_minimap_settings["hide"] then
            icon:Hide(addonName)
        else
            icon:Show(addonName)
        end
    end
end

function on_load_setup()
    if icbat_cta_minimap_settings == nil then
        icbat_cta_minimap_settings = {
            hide = false,
        }
    end

    if not icon:IsRegistered(addonName) then
        icon:Register(addonName, dataobj, icbat_cta_minimap_settings)
    end

    set_label()
end

function set_label()
    dataobj.text = broker_cta_display.build_label()
end

-- invisible frame for updating/hooking events
local f = CreateFrame("frame")
local UPDATEPERIOD = 5
local elapsed = 0
f:SetScript("OnUpdate", function(self, elap)
    elapsed = elapsed + elap
    if elapsed < UPDATEPERIOD then
        return
    end
    elapsed = 0
    set_label()
end)

f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent", on_load_setup)
