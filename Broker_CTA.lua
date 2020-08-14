local ldb = LibStub:GetLibrary("LibDataBroker-1.1")

local addonName = "Call To Arms"
local dataobj = ldb:NewDataObject(addonName, {
    type = "data source",
    text = "Broker: Call to Arms"
})

-- utils/helpers
local function concatTables(t1,t2)
    for i=1,#t2 do
        t1[#t1+1] = t2[i]
    end
    return t1
end

local function coloredText(text, color)
    return "\124c" .. color .. text .. "\124r"
end

-- Broker CTA / addon-specific functions
local broker_cta = {}

function broker_cta.listDungeons()
   return broker_cta.list(GetNumRandomDungeons, GetLFGRandomDungeonInfo)
end

function broker_cta.listRaids()
   return broker_cta.list(GetNumRFDungeons, GetRFDungeonInfo)
end

function broker_cta.list(listFunction, infoFunction)
    local result = {}
    for i = 1, listFunction() do
       local id, name = infoFunction(i)
       result[i] = {["id"] = id, ["name"] = name}
    end
    return result
end

function broker_cta.filter(instances)
    local instancesNeedingTank = {}
    local instancesNeedingHealer = {}
    local instancesNeedingDPS = {}
    for i=1,#instances do
        local eligible, needsTank, needsHealer, needsDamage, itemCount, money, xp = GetLFGRoleShortageRewards(instances[i]["id"], 1)
        if eligible and broker_cta.rewardsAreWanted(itemCount, money, xp) then
            if needsTank then
                instancesNeedingTank[#instancesNeedingTank + 1] = instances[i]["name"]
            end

            if needsHealer then
                instancesNeedingHealer[#instancesNeedingHealer + 1] = instances[i]["name"]
            end

            if needsDamage then
                instancesNeedingDPS[#instancesNeedingDPS + 1] = instances[i]["name"]
            end

        end
    end

    return instancesNeedingTank, instancesNeedingHealer, instancesNeedingDPS
end

function broker_cta.rewardsAreWanted(itemCount, money, xp)
    return (itemCount ~= 0 or money ~= 0 or xp ~= 0)
end

function broker_cta.getSelectedRoles()
    local leader, tank, healer, damage = GetLFGRoles()
    return broker_cta.wrapRoles(tank, healer, damage)
end

function broker_cta.wrapRoles(tank, healer, damage)
    return {
        tank,
        healer,
        damage
    }
end

local roleNames = {
    "Tank",
    "Heal",
    "Damage",
}

local roleColors = {
    "003498db",
    "0000f269",
    "00e74c3c",
}

function broker_cta.displayRoles(roles)
    local text = ""
    for i=1, #roles do
        if roles[i] then
            text = text .. coloredText(roleNames[i], roleColors[i]) .. " "
        end
    end
    if text == "" then
        text = "None, select some in LFG window"
    end
    return text
end

function broker_cta.update()
    local tank, healer, dps = broker_cta.filter(concatTables(broker_cta.listDungeons(), broker_cta.listRaids()))
    local canBeTank, canBeHealer, canBeDPS = UnitGetAvailableRoles("player")
    local displayText = ""
    if canBeTank then
        displayText = displayText .. coloredText(roleNames[1] .. " " .. #tank .. " ", roleColors[1])
    end
    if canBeHealer then
        displayText = displayText .. coloredText(roleNames[2] .. " " .. #healer .. " ", roleColors[2])
    end
    if canBeDPS then
        displayText = displayText .. coloredText(roleNames[3] .. " " .. #dps .. " ", roleColors[3])
    end
    dataobj.text = displayText
end

function broker_cta.displayList(self, instanceList)
    if instanceList == nil or #instanceList == 0 then
        self:AddLine("No reward satchels found", 1, 1, 1)
    else

        for i=1,#instanceList do
            local text = instanceList[i]
            self:AddLine(text, 1, 1, 1)
        end
    end
end

-- tooltip/broker object settings
function dataobj:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_NONE")
	GameTooltip:SetPoint("TOPLEFT", self, "BOTTOMLEFT")
	GameTooltip:ClearLines()
	dataobj.OnTooltipShow(GameTooltip)
	GameTooltip:Show()
end

function dataobj:OnLeave()
	GameTooltip:Hide()
end

function dataobj:OnClick()
    ToggleLFDParentFrame()
end

function dataobj:OnTooltipShow()
	self:AddLine(addonName)
    self:AddLine(" -- Selected Roles", 0.58, 0.65, 0.65)
    local roles = broker_cta.getSelectedRoles()
    self:AddLine(broker_cta.displayRoles(roles))

    local tank, healer, dps = broker_cta.filter(concatTables(broker_cta.listDungeons(), broker_cta.listRaids()))
    local canBeTank, canBeHealer, canBeDPS = UnitGetAvailableRoles("player")

    if canBeTank then
        self:AddLine(" -- " .. coloredText(roleNames[1], roleColors[1]))
        broker_cta.displayList(self, tank)
    end

    if canBeHealer then
        self:AddLine(" -- " .. coloredText(roleNames[2], roleColors[2]))
        broker_cta.displayList(self, healer)
    end

    if canBeDPS then
        self:AddLine(" -- " .. coloredText(roleNames[3], roleColors[3]))
        broker_cta.displayList(self, dps)
    end
end

-- invisible frame for updating/hooking events
local f = CreateFrame("frame")
local UPDATEPERIOD = 5
local elapsed = 0
f:SetScript("OnUpdate", function(self, elap)
    elapsed = elapsed + elap
	if elapsed < UPDATEPERIOD then return end
    elapsed = 0
    broker_cta.update()
end)

f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent", broker_cta.update)