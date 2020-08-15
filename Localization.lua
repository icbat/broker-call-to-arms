-- https://phanx.net/addons/tutorials/localize

local _, namespace = ...

local L = setmetatable({}, {
    __index = function(t, k)
        local v = tostring(k)
        rawset(t, k, v)
        return v
    end
})

namespace.L = L

local LOCALE = GetLocale()

if LOCALE == "enUS" then
    -- The EU English game client also
    -- uses the US English locale code.
    return
end


---- To add translations, use this block as a starting point

-- if LOCALE == "deDE" then
--     -- German translations go here
--     L["Tank"] = "German for Tank"
--     L["Heal"] = "German for Healer"
--     L["Damage"] = "German for Damage Dealer"
--     L["Q"] = "A German abbreviation for being Queued"
--     L["No reward satchels found"] = "German for 'there are no rewards available right now'"
--     return
-- end
