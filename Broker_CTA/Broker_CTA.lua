local ldb = LibStub:GetLibrary("LibDataBroker-1.1")

local addonName = "Call To Arms"
local dataobj = ldb:NewDataObject(addonName, {type = "data source", text = "Static Text Here"})

local broker_cta = {}

function broker_cta.listRandomDungeons()
   local result = {}
   for i = 1, GetNumRandomDungeons() do
      local id, name = GetLFGRandomDungeonInfo(i)
      result[i] = {["id"] = id, ["name"] = name}
   end
   return result
end

function  broker_cta.filterToEligible(dungeons)
    local result = {}
    local count = 1
    for i=1,#dungeons do
        local eligible, needsTank, needsHealer, needsDamage, itemCount, money, xp, secretFourthOption = GetLFGRoleShortageRewards(dungeons[i]["id"], 1)
        if eligible and needsTank and (itemCount ~= 0 or money ~= 0 or xp ~= 0 or secretFourthOption ~= 0) then
            result[count] = {
                ["needsTank"] = needsTank,
                ["needsHealer"] = needsHealer,
                ["needsDamage"] = needsDamage,
                ["name"] = dungeons[i]["name"],
                ["id"] = dungeons[i]["id"]
            }

            count = count + 1
        end
    end
    return result
end


local f = CreateFrame("frame")
local UPDATEPERIOD, elapsed = 0.5, 0
f:SetScript("OnUpdate", function(self, elap)
	elapsed = elapsed + elap
	if elapsed < UPDATEPERIOD then return end
    elapsed = 0

    local dungeons = broker_cta.listRandomDungeons()
    local filtered = broker_cta.filterToEligible(dungeons)
    if filtered == nil or #filtered == 0 then
        dataobj.text = "No satchels"
    else
        dataobj.text = #filtered
    end

end)


function dataobj:OnTooltipShow()
	self:AddLine(addonName)
    local dungeons = broker_cta.listRandomDungeons()
    local filtered = broker_cta.filterToEligible(dungeons)
    if filtered == nil or #filtered == 0 then
        self:AddLine("No satchels available", 1, 1, 1)
    else
        for i=1,#filtered do
            self:AddLine(filtered[i]["name"], 1, 1, 1)
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
