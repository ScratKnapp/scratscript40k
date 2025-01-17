ix.command.Add("Virtues", {
    description = "Display your virtues.",
    OnRun = function(self, client) end
})

ix.command.Add("WP", {
    description = "Spend some Willpower for the day.",
    arguments = {ix.type.number,},
    OnRun = function(self, client, amount) end
})

ix.command.Add("CharSetVirtue", {
    description = "Set virtue for given character.",
    privilege = "Manage Character Attributes",
    adminOnly = true,
    arguments = {ix.type.character, ix.type.string, ix.type.number,},
    OnRun = function(self, client, target, virtue, value) end
})

ix.command.Add("CharSetVirtuePoints", {
    description = "Set virtue points for given character.",
    privilege = "Manage Character Attributes",
    adminOnly = true,
    arguments = {ix.type.character, ix.type.number,},
    OnRun = function(self, client, target, value) end
})

ix.command.Add("CharGiveWP", {
    description = "Give Willpower to a character, up to their maximum.",
    privilege = "Manage Character Attributes",
    adminOnly = true,
    arguments = {ix.type.character, ix.type.number,},
    OnRun = function(self, client, target, amount) end
})

ix.command.Add("CharTakeWP", {
    description = "Take Willpower from a character.",
    privilege = "Manage Character Attributes",
    adminOnly = true,
    arguments = {ix.type.character, ix.type.number,},
    OnRun = function(self, client, target, amount) end
})