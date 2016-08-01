local ldb = LibStub:GetLibrary("LibDataBroker-1.1")

local dataobj = ldb:NewDataObject("Call To Arms", {type = "data source", text = "Static Text Here"})

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
        local eligible, needsTank, needsHealer, needsDamage = GetLFGRoleShortageRewards(dungeons[i]["id"], 1)
        if eligible then
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
    if filtered ~= nil then
        dataobj.text = #filtered
    end

end)
