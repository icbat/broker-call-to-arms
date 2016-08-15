local ldb = LibStub:GetLibrary("LibDataBroker-1.1")

local addonName = "Call To Arms"
local dataobj = ldb:NewDataObject(addonName, {
    type = "data source",
    text = "Broker: Call to Arms"
})

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

function broker_cta.filter(instances, selectedRoles)
    local result = {}
    for i=1,#instances do
        local eligible, needsTank, needsHealer, needsDamage, itemCount, money, xp, secretFourthOption = GetLFGRoleShortageRewards(instances[i]["id"], 1)
        local neededRoles = broker_cta.wrapRoles(needsTank, needsHealer, needsDamage)
        if eligible and broker_cta.canFillNeed(selectedRoles, neededRoles) and broker_cta.rewardsAreWanted(itemCount, money, xp, secretFourthOption) then
            result[#result + 1] = {
                ["needsTank"] = needsTank,
                ["needsHealer"] = needsHealer,
                ["needsDamage"] = needsDamage,
                ["name"] = instances[i]["name"],
                ["id"] = instances[i]["id"]
            }
        end
    end
    return result
end

function broker_cta.canFillNeed(selectedRoles, neededRoles)
    for i=1, #selectedRoles do
        if selectedRoles[i] and neededRoles[i] then
            return true
        end
    end
    return false
end

-- secretFourthOption is literally undocumented. Including it here, but it may not be worth including, or it may not even be a reward!
function broker_cta.rewardsAreWanted(itemCount, money, xp, secretFourthOption)
    return (itemCount ~= 0 or money ~= 0 or xp ~= 0 or secretFourthOption ~= 0)
end

function broker_cta.getSelectedRoles()
    local leader, tank, healer, damage = GetLFGRoles()
    return broker_cta.wrapRoles(tank, healer, damage)
end

function broker_cta.wrapRoles(tank, healer, damage)
    return {
        [1] = tank,
        [2] = healer,
        [3] = damage
    }
end

function broker_cta.extractRolesFromInstance(instanceObject)
    return {
        [1] = instanceObject["needsTank"],
        [2] = instanceObject["needsHealer"],
        [3] = instanceObject["needsDamage"],
    }
end

local roleNames = {
    [1] = "Tank",
    [2] = "Heal",
    [3] = "Damage",
}

function broker_cta.displayRoles(roles)
    local text = ""
    for i=1, #roles do
        if roles[i] then
            text = text .. roleNames[i] .. " "
        end
    end
    if text == "" then
        text = "None, select some in LFG window"
    end
    return text
end

local f = CreateFrame("frame")
local UPDATEPERIOD = 5
local elapsed = 0
f:SetScript("OnUpdate", function(self, elap)
	elapsed = elapsed + elap
	if elapsed < UPDATEPERIOD then return end
    elapsed = 0

    local roles = broker_cta.getSelectedRoles()
    local dungeons = broker_cta.filter(broker_cta.listDungeons(), roles)
    local raids = broker_cta.filter(broker_cta.listRaids(), roles)
    local displayText = ""
    displayText = displayText .. "Dungeons: "
    if #dungeons > 0 then
        displayText = displayText .. broker_cta.greenText(#dungeons)
    else
        displayText = displayText .. #dungeons
    end
    displayText = displayText .. " Raids: "
    if #raids > 0 then
        displayText = displayText .. broker_cta.greenText(#raids)
    else
        displayText = displayText .. #raids
    end
    dataobj.text = displayText
end)

function broker_cta.greenText(text)
    return "\124c0000FF00" .. text .. "\124r"
end


function dataobj:OnTooltipShow()
	self:AddLine(addonName)
    self:AddLine("Selected Roles", 0, 1, 0)
    local roles = broker_cta.getSelectedRoles()
    self:AddLine(broker_cta.displayRoles(roles))


    self:AddLine("Dungeons", 0, 1, 0)
    broker_cta.displayList(self, broker_cta.filter(broker_cta.listDungeons(), roles))

    self:AddLine("Raids", 0, 1, 0)
    broker_cta.displayList(self, broker_cta.filter(broker_cta.listRaids(), roles))
end

function broker_cta.displayList(self, instanceList)
    if instanceList == nil or #instanceList == 0 then
        self:AddLine("No reward satchels found", 1, 1, 1)
    else
        for i=1,#instanceList do
            local rolesNeeded = broker_cta.extractRolesFromInstance(instanceList[i])
            local text = "" .. instanceList[i]["name"] .. " : " ..  broker_cta.displayRoles(rolesNeeded)
            self:AddLine(text, 1, 1, 1)
        end
    end
end

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
