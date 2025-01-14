ix.command.Add("UpgradeAttribute", {
    arguments = {ix.type.string,},
    description = "Spend your XP and upgrade your attributes.",
    OnRun = function(self, client, att) end
})

ix.command.Add("UpgradeSkill", {
    arguments = {ix.type.string,},
    description = "Spend your XP and upgrade your skills.",
    OnRun = function(self, client, skill) end
})

ix.command.Add("UpgradeClass", {
    arguments = {ix.type.number},
    description = "Spend your XP and upgrade your class(es).",
    OnRun = function(self, client, slot) end
})

ix.command.Add("UpgradeVirtue", {
    arguments = {ix.type.string,},
    description = "Spend your XP and upgrade your Virtues.",
    OnRun = function(self, client, virtue) end
})

ix.command.Add("CharGiveXP", {
    arguments = {ix.type.character, ix.type.number},
    adminOnly = true,
    description = "Add XP to target.",
    OnRun = function(self, client, target, amount) end
})