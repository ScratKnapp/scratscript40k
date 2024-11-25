PLUGIN.name = "Narrate"
PLUGIN.description = "An IC PM of sorts for telling individual characters things."
PLUGIN.author = "Scrat Knapp"



ix.chat.Register("narrate", {
	format = "%s:",
	color = Color(0, 255, 255, 255),
	deadCanChat = true,

	OnChatAdd = function(self, speaker, text, bAnonymous, data)
		chat.AddText(self.color, data.message)
	end
})


ix.command.Add("Narrate", {
    adminOnly = true,
    description = "Narrate to a player.",
    arguments = {ix.type.player, ix.type.text},
    OnRun = function(self, client, target, message)
        
        ix.chat.Send(client, "narrate", message, true,  {client, target}, {
          target = target,
          message = message
        })

           

      
    end
})

ix.command.Add("SkitzoSay", {
  description = "Force a player to say something out loud without them seeing it.",
  adminOnly = true,
  arguments = {ix.type.player, ix.type.text},
  OnRun = function(self, client, target, text)
      local range = ix.config.Get("chatRange", 280) ^ 2
      if IsValid(target) then
          for k, v in ipairs(player.GetAll()) do
              if (target:GetPos() - v:GetPos()):LengthSqr() <= range then
                  if v == target then continue end
                  -- if (SERVER) then
                  ix.chat.Send(target, "ic", text, false, {v})
                  -- end
              end
          end
      end
  end
})

ix.command.Add("SkitzoMe", {
  description = "Force a player to do an action without them seeing it.",
  adminOnly = true,
  arguments = {ix.type.player, ix.type.text},
  OnRun = function(self, client, target, text)
      local range = ix.config.Get("chatRange", 280) ^ 2
      if IsValid(target) then
          for k, v in ipairs(player.GetAll()) do
              if (target:GetPos() - v:GetPos()):LengthSqr() <= range then
                  if v == target then continue end
                  -- if (SERVER) then
                  ix.chat.Send(target, "me", text, false, {v})
                  -- end
              end
          end
      end
  end
})


ix.command.Add("metarget", {
  arguments = {ix.type.player, ix.type.text},
  OnRun = function(self, client, target, message)
      net.Start("MetargetChatMessage")
      net.WriteString(client:Nick())
      net.WriteString(message)
      net.Send({client, target})
  end
})

