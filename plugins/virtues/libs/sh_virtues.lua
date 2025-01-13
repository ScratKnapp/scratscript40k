local charMeta = ix.meta.character
function charMeta:GetConscience()
    return self:GetData("Conscience", 0)
end

function charMeta:GetSelfControl()
    return self:GetData("SelfControl", 0)
end

function charMeta:GetCourage()
    return self:GetData("Courage", 0)
end

function charMeta:GetSanity()
    local sanity = self:GetConscience() + self:GetSelfControl()
    if self:GetBackground() == "Gland Warrior" then sanity = sanity - 2 end
    return sanity
end

function charMeta:GetWillpower()
    local WP = (self:GetCourage() + self:GetData("Willpower", 0)) - self:GetData("SpentWP", 0)
    if WP < 0 then WP = 0 end
    return WP
end