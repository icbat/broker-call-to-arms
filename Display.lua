broker_cta_display = {}

local ADDON, namespace = ...
local L = namespace.L

local roleNames = {_G["TANK"], _G["HEALER"], _G["DAMAGER"]}

local roleColors = {"003498db", "0000f269", "00e74c3c"}
local grey = "00aaaaaa"
local green = "0000ff00"
local white = "00ffffff"
local orange = "ffa500ff"
local red = "00e74c3c"

local num_columns = 3

local function coloredText(text, color, is_eligible)
    if is_eligible then
        return "\124c" .. color .. text .. "\124r"
    end

    return "\124c" .. grey .. text .. "\124r"
end

local function buildCompletionMessage(instance_table, is_eligible)
    local completed = instance_table["completed_encounters"]
    local total = instance_table["total_encounters"]
    local text = "  " .. completed .. "/" .. total

    if total == 0 then
        -- Dungeons, for example, show 0/0 otherwise
        return ""
    end

    if completed == total then
        return coloredText(text, red, is_eligible)
    end

    if completed > 0 then
        return coloredText(text, orange, is_eligible)
    end

    return coloredText(text, white, is_eligible)
end

local function displayList(self, instanceList, is_eligible, queued_ids)
    if instanceList == nil or #instanceList == 0 then
        self:AddLine()
        local text = coloredText("  " .. L["No reward satchels found"], grey)
        self:SetCell(self:GetLineCount(), 1, text, nil, "LEFT", num_columns)
        return
    end

    for i = 1, #instanceList do
        local text = coloredText("  " .. instanceList[i]["name"], white, is_eligible)
        local completion = buildCompletionMessage(instanceList[i], is_eligible)
        local queued = ""

        for _, k in pairs(queued_ids) do
            if k == instanceList[i]["instance_id"] then
                queued = coloredText(L["Q"], green, true)
            end
        end
        self:AddLine(text, completion, queued)
    end
end

function broker_cta_display.build_tooltip(self)
    -- col 1 is for words
    -- col 2 is for completion rate (0/3 bosses killed)
    -- col 3 is for queue status

    self:AddHeader("Call To Arms")
    self:SetCell(1, 1, "Call To Arms", nil, "CENTER", num_columns)
    self:AddLine()

    self:AddSeparator()

    local tank, healer, dps = broker_cta.split_by_role(broker_cta.build_list())
    local queued_ids = broker_cta.get_queued_instance_ids()
    local canBeTank, canBeHealer, canBeDPS = UnitGetAvailableRoles("player")

    self:AddLine(coloredText(roleNames[1], roleColors[1], canBeTank))
    displayList(self, tank, canBeTank, queued_ids)
    self:AddLine()

    self:AddLine(coloredText(roleNames[2], roleColors[2], canBeHealer))
    displayList(self, healer, canBeHealer, queued_ids)
    self:AddLine()

    self:AddLine(coloredText(roleNames[3], roleColors[3], canBeDPS))
    displayList(self, dps, canBeDPS, queued_ids)
    self:AddLine()
end

function broker_cta_display.build_label()
    local tank, healer, dps = broker_cta.split_by_role(broker_cta.build_list())
    local canBeTank, canBeHealer, canBeDPS = UnitGetAvailableRoles("player")
    local displayText = ""
    displayText = displayText .. coloredText(roleNames[1] .. " " .. #tank .. " ", roleColors[1], canBeTank)
    displayText = displayText .. coloredText(roleNames[2] .. " " .. #healer .. " ", roleColors[2], canBeHealer)
    displayText = displayText .. coloredText(roleNames[3] .. " " .. #dps .. " ", roleColors[3], canBeDPS)
    return displayText
end
