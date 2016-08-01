local ldb = LibStub:GetLibrary("LibDataBroker-1.1")

local addonName = "Call To Arms"
local dataobj = ldb:NewDataObject(addonName, {type = "data source", text = "Static Text Here"})

local broker_cta = {}

function broker_cta.listDungeons()
   local result = {}
   for i = 1, GetNumRandomDungeons() do
      local id, name = GetLFGRandomDungeonInfo(i)
      result[i] = {["id"] = id, ["name"] = name}
   end
   return result
end

function broker_cta.listRaids()
   local result = {}
   for i = 1, GetNumRFDungeons() do
      local id, name = GetRFDungeonInfo(i)
      result[i] = {["id"] = id, ["name"] = name}
   end
   return result
end

function  broker_cta.filter(instances)
    local result = {}
    local count = 1
    for i=1,#instances do
        local eligible, needsTank, needsHealer, needsDamage, itemCount, money, xp, secretFourthOption = GetLFGRoleShortageRewards(instances[i]["id"], 1)
        if eligible and needsTank and (itemCount ~= 0 or money ~= 0 or xp ~= 0 or secretFourthOption ~= 0) then
            result[count] = {
                ["needsTank"] = needsTank,
                ["needsHealer"] = needsHealer,
                ["needsDamage"] = needsDamage,
                ["name"] = instances[i]["name"],
                ["id"] = instances[i]["id"]
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

    local sum = 0
    local dungeons = broker_cta.filter(broker_cta.listDungeons())
    if dungeons ~= nil then
        sum = sum + #dungeons
    end
    local raids = broker_cta.filter(broker_cta.listRaids())
    if raids ~= nil then
        sum = sum + #raids
    end
    if sum == 0 then
        dataobj.text = "No satchels"
    else
        dataobj.text = sum
    end
end)


function dataobj:OnTooltipShow()
	self:AddLine(addonName)
    local dungeons = broker_cta.filter(broker_cta.listDungeons())
    self:AddLine("Dungeons", 0, 1, 0)
    if dungeons == nil or #dungeons == 0 then
        self:AddLine("No dungeons currently reward satchels", 1, 1, 1)
    else
        for i=1,#dungeons do
            self:AddLine(dungeons[i]["name"], 1, 1, 1)
        end
    end

    local raids = broker_cta.filter(broker_cta.listRaids())
    if raids == nil or #raids == 0 then
        self:AddLine("No raids currently reward satchels", 1, 1, 1)
    else
        self:AddLine("Raids", 0, 1, 0)
        for i=1,#raids do
            self:AddLine(raids[i]["name"], 1, 1, 1)
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
