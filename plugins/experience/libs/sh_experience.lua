local charMeta = ix.meta.character

function charMeta:GetXP()
    return self:GetData("XP", 0)
end