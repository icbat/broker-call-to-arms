-- Dev helper functions
local function starts_with(str, start)
    if type(str) ~= "string" then
        return
    end
    return str:sub(1, #start) == start
end

local function print_keys(table, start)
    for k, v in pairs(table) do
        print(k)
        print(v)
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

-- returns names and ids for all the instances found with listFunction, populated w/ infoFunction
local function fetch_lfx_names(listFunction, infoFunction)
    local result = {}
    for i = 1, listFunction() do
        -- https://wow.gamepedia.com/API_GetRFDungeonInfo for example of everything you can get here
        local id, name = infoFunction(i)
        result[i] = {
            ["instance_id"] = id,
            ["name"] = name
        }
    end
    return result
end

local function rewards_exist(itemCount, money, xp)
    return (itemCount ~= 0 or money ~= 0 or xp ~= 0)
end

-- wraps Blizzard's multiple returns into a table that we care about
local function build_satchel_object(instance_id, name)
    local shortage_severity = 1

    -- https://wow.gamepedia.com/API_GetLFGRoleShortageRewards
    local eligible, needs_tank, needs_healer, needs_damage, items, money, xp =
        GetLFGRoleShortageRewards(instance_id, shortage_severity)
    local total_encounters, completed_encounters = GetLFGDungeonNumEncounters(instance_id)
   
    return {
        instance_id = instance_id,
        name = name,
        eligible = eligible,
        needs_tank = needs_tank,
        needs_healer = needs_healer,
        needs_damage = needs_damage,
        rewards = rewards_exist(items, money, xp),
        total_encounters = total_encounters,
        completed_encounters = completed_encounters,
    }
end

local function filter_interesting_dungeons(instances)
    local filtered_instances = {}

    for i = 1, #instances do
        local satchel = build_satchel_object(instances[i]["instance_id"], instances[i]["name"])
        if satchel["eligible"] and satchel["rewards"] then
            -- print_keys(satchel)
            filtered_instances[#filtered_instances + 1] = satchel
        end
    end

    return filtered_instances
end

-- Broker CTA / addon-specific functions
broker_cta = {}

function broker_cta.build_list()
    local dungeons = fetch_lfx_names(GetNumRandomDungeons, GetLFGRandomDungeonInfo)
    local raids = fetch_lfx_names(GetNumRFDungeons, GetRFDungeonInfo)
    return filter_interesting_dungeons(concatTables(dungeons, raids))
end

function broker_cta.split_by_role(instances)
    local tank = {}
    local healer = {}
    local dps = {}

    for i = 1, #instances do
        if instances[i]["needs_tank"] then
            tank[#tank + 1] = instances[i]
        end
        if instances[i]["needs_healer"] then
            healer[#healer + 1] = instances[i]
        end
        if instances[i]["needs_damage"] then
            dps[#dps + 1] = instances[i]
        end
    end

    return tank, healer, dps
end

function broker_cta.get_queued_instance_ids()
    local instance_ids = {}

    for id, _ in pairs(GetLFGQueuedList(1)) do
        instance_ids[#instance_ids + 1] = id
    end

    for id, _ in pairs(GetLFGQueuedList(3)) do
        instance_ids[#instance_ids + 1] = id
    end

    return instance_ids
end

