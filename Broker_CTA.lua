-- Dev helper functions
local function starts_with(str, start)
    if type(str) ~= "string" then return end
    return str:sub(1, #start) == start
end

local function print_keys(table, start)
    for k, _ in pairs(table) do
        if starts_with(k, start) then
            print(k)
        end
    end
    print('---')
end
---


local function concatTables(t1, t2)
    for i = 1, #t2 do
        t1[#t1 + 1] = t2[i]
    end
    return t1
end

-- the list function returns a list of IDs, the info function gets you all the info about that raid/dungeon
local function fetch_lfx_list(listFunction, infoFunction)
    local result = {}
    for i = 1, listFunction() do
        local id, name = infoFunction(i)
        result[i] = {
            ["id"] = id,
            ["name"] = name
        }
    end
    return result
end


-- Broker CTA / addon-specific functions
broker_cta = {}

function broker_cta.build_list()
    local dungeons = fetch_lfx_list(GetNumRandomDungeons, GetLFGRandomDungeonInfo)
    local raids = fetch_lfx_list(GetNumRFDungeons, GetRFDungeonInfo)
    return concatTables(dungeons, raids)
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

