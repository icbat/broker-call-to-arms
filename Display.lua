broker_cta_display = {}

local function coloredText(text, color)
    return "\124c" .. color .. text .. "\124r"
end

local function wrapRoles(tank, healer, damage)
    return {tank, healer, damage}
end

local roleNames = {"Tank", "Heal", "Damage"}

local roleColors = {"003498db", "0000f269", "00e74c3c"}

local function displayRoles(roles)
    local text = ""
    for i = 1, #roles do
        if roles[i] then
            text = text .. coloredText(roleNames[i], roleColors[i]) .. " "
        end
    end

    if text == "" then
        return "None, select some in LFG window"
    end

    return text
end


local function displayList(self, instanceList)
    if instanceList == nil or #instanceList == 0 then
        self:AddLine("No reward satchels found")
        return
    end

    for i=1,#instanceList do
        local text = instanceList[i]
        self:AddLine(text)
    end
end

function broker_cta_display.build_tooltip(self)
    self:AddHeader("Call To Arms")
    self:AddLine()

    self:AddLine("Selected Roles")
    local leader, tank, healer, damage = GetLFGRoles()
    local roles = wrapRoles(tank, healer, damage)
    self:AddLine(displayRoles(roles))
    self:AddLine()
    self:AddSeparator()

    local tank, healer, dps = broker_cta.filter(broker_cta.build_list())
    local canBeTank, canBeHealer, canBeDPS = UnitGetAvailableRoles("player")

    if canBeTank then
        self:AddLine(coloredText(roleNames[1], roleColors[1]))
        displayList(self, tank)
        self:AddLine()
    end

    if canBeHealer then
        self:AddLine(coloredText(roleNames[2], roleColors[2]))
        displayList(self, healer)
        self:AddLine()
    end

    if canBeDPS then
        self:AddLine(coloredText(roleNames[3], roleColors[3]))
        displayList(self, dps)
        self:AddLine()
    end
end

function broker_cta_display.build_label()
    local tank, healer, dps = broker_cta.filter(broker_cta.build_list())
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



