broker_cta_display = {}

local ADDON, namespace = ...
local L = namespace.L

local function coloredText(text, color)
    return "\124c" .. color .. text .. "\124r"
end

local function wrapRoles(tank, healer, damage)
    return {tank, healer, damage}
end

local roleNames = {L["Tank"], L["Heal"], L["Damage"]}

local roleColors = {"003498db", "0000f269", "00e74c3c"}

local function displayList(self, instanceList, queued_ids)
    if instanceList == nil or #instanceList == 0 then
        self:AddLine("", coloredText(L["No reward satchels found"], "00aaaaaa"))
        return
    end

    for i=1,#instanceList do
        local text = instanceList[i]["name"]
        local queued = ""

        for _, k in pairs(queued_ids) do
            if k == instanceList[i]["instance_id"] then
                queued = coloredText(L["Q"], "0000ff00")
            end
        end
        self:AddLine(queued, text)
    end
end

function broker_cta_display.build_tooltip(self)
    -- col 1 is for queue status
    -- col 2 is for words

    self:AddHeader("", "Call To Arms")
    self:AddLine()

    self:AddSeparator()

    local tank, healer, dps = broker_cta.split_by_role(broker_cta.build_list())
    local queued_ids = broker_cta.get_queued_instance_ids()
    local canBeTank, canBeHealer, canBeDPS = UnitGetAvailableRoles("player")

    if canBeTank then
        self:AddLine("", coloredText(roleNames[1], roleColors[1]))
        displayList(self, tank, queued_ids)
        self:AddLine()
    end

    if canBeHealer then
        self:AddLine("", coloredText(roleNames[2], roleColors[2]))
        displayList(self, healer, queued_ids)
        self:AddLine()
    end

    if canBeDPS then
        self:AddLine("", coloredText(roleNames[3], roleColors[3]))
        displayList(self, dps, queued_ids)
        self:AddLine()
    end
end

function broker_cta_display.build_label()
    local tank, healer, dps = broker_cta.split_by_role(broker_cta.build_list())
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
    return displayText
end



