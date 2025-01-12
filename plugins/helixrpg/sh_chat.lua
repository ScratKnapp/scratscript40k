ix.chat.Register("rollgeneric", {
  format = "** %s has rolled %s %s on their roll.",
  color = Color(255, 185, 50),
  CanHear = ix.config.Get("chatRange", 280),
  deadCanChat = true,
  OnChatAdd = function(self, speaker, text, bAnonymous, data) chat.AddText(self.color, string.format(self.format, speaker:GetName(), text, data.roll)) end
})

ix.chat.Register("roll20", {
  format = "** %s has rolled %s on their %s roll.",
  color = Color(255, 125, 50),
  CanHear = ix.config.Get("chatRange", 280),
  deadCanChat = true,
  OnChatAdd = function(self, speaker, text, bAnonymous, data) chat.AddText(self.color, string.format(self.format, speaker:GetName(), text, data.rolltype)) end
})

ix.chat.Register("roll20attack", {
  format = "** %s has rolled %s on their Attack roll for %s damage.",
  color = Color(255, 70, 50),
  CanHear = ix.config.Get("chatRange", 280),
  deadCanChat = true,
  OnChatAdd = function(self, speaker, text, bAnonymous, data) chat.AddText(data.color or self.color, string.format(self.format, speaker:GetName(), text, data.damage)) end
})
