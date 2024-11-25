PLUGIN.name = "Setup"
PLUGIN.description = ""
PLUGIN.author = "Scrat Knapp"



function PLUGIN:PlayerLoadedCharacter(client, character, currentChar)


  if not character:GetData("RaceSetup")  then 
    
    if character:GetBackground() == "none" then 
      character:SetBackground("Human")
      client:Notify("No Race selected - defaulting to Human.")
    end

    if character:GetBackground() == "Human" then
      client:Notify("As a Human, you may apply a +1 bonus to any Skill. Use /humanbonus to select your skill.")
    else
      character:SetData("RaceSetup", true)
    end 


  end 

end

ix.command.Add("HumanBonus", {
  description = "If you're a Human, choose the skill you want to recieve a bonus.",
  arguments = ix.type.string,
  OnRun = function(self, client, skill)

    local skill = string.lower(skill)

    if client:GetCharacter():GetBackground() ~= "Human" then 
      client:Notify("You are not a Human!")
      return
    end 
  
    
    if client:GetCharacter():GetData("RaceSetup") then
      client:Notify("You've already set your Bonus skill!")
      return
    end 

    local allskills = ix.skills.list
    if not allskills[skill] then 
      client:Notify("Invalid skill.")
      return
    end 

    client:GetCharacter():SetData("HumanBonus", skill)
    client:Notify("You've chosen to boost your rolls with the " .. skill .. " skill.")
    client:GetCharacter():SetData("RaceSetup", true)

      
  end
})

