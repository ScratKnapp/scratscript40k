PLUGIN.name = "Setup"
PLUGIN.description = ""
PLUGIN.author = "Scrat Knapp"
function PLUGIN:PlayerLoadedCharacter(client, character, currentChar)
  if not character:GetData("RaceSetup") then
    if character:GetBackground() == "none" then
      character:SetBackground("Human")
      client:Notify("No Race selected - defaulting to Human.")
    end

    if character:GetBackground() == "Human" or character:GetBackground() == "Amphi" then
      client:Notify("Your chosen race allows to apply a +1 bonus to any Skill. Use /racebonus to select your skill.")
    else
      character:SetData("RaceSetup", true)
    end
  end

  if not character:GetData("ProfessionSetup") then
    client:Notify("You have not yet chosen a profession!")
    client:Notify("Your Profession provides a +1 bonus to rolls for their related skill.")
    client:Notify("Use /chooseprofession with your choice. Run the command without any arguments for a list of Professions and the skill they boost.")
  end

  if character:GetData("ClassPoints", 3) > 0 then
    local classpoints = character:GetData("ClassPoints", 3)
    client:Notify("You have not yet chosen your classes!")
    client:Notify("Your Class gives you access to abilities. You start with 3 points to spend across 1-3 classes, and currently have " .. classpoints .. " left to spend.")
    client:Notify("Use /chooseclass with your choice. Run the command without any arguments for a list of Classes.")
  end

  if character:GetData("VirtuePoints", 10) > 0 then
    local virtuepoints = character:GetData("VirtuePoints", 3)
    client:Notify("You have not yet chosen your virtues!")
    client:Notify("Your Virtues are a number of values from which others derive, such as your Willpower and Sanity. You currently have " .. virtuepoints .. " points to spend.")
    client:Notify("Use /choosevirtue with your choice of virtue to upgrade. Run the command without any arguments for more information.")
  end
end

ix.command.Add("RaceBonus", {
  description = "If you're a Human or Amphi, choose the skill you want to recieve a bonus.",
  arguments = ix.type.string,
  OnRun = function(self, client, skill)
    local skill = string.lower(skill)
    if client:GetCharacter():GetBackground() ~= "Human" and client:GetCharacter():GetBackground() ~= "Amphi" then
      client:Notify("Your Race does not offer a choice of skill bonus!")
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

    client:GetCharacter():SetData("RaceBonus", skill)
    client:Notify("You've chosen to boost your rolls with the " .. skill .. " skill.")
    client:GetCharacter():SetData("RaceSetup", true)
  end
})

ix.command.Add("ChooseProfession", {
  description = "Select your profession.",
  arguments = {bit.bor(ix.type.string, ix.type.optional)},
  OnRun = function(self, client, profession)
    local char = client:GetCharacter()
    if not profession then
      local professions = ix.professions.list
      client:Notify("Professions:")
      for k, v in pairs(professions) do
        client:Notify(v.name .. ": " .. ix.skills.list[v.skill].name or "Error")
      end
      return
    end

    if char:GetData("ProfessionSetup") then
      client:Notify("You've already set your Profession!")
      return
    end

    for k, v in pairs(ix.professions.list) do
      if ix.util.StringMatches(L(v.name, client), profession) or ix.util.StringMatches(k, profession) then
        char:SetData("Profession", k)
        char:SetData("ProfessionSetup", true)
        return "You chose " .. v.name .. "."
      end
    end
    return "Profession not found!"
  end
})

ix.command.Add("ChooseClass", {
  description = "Select your classes.",
  arguments = {bit.bor(ix.type.string, ix.type.optional)},
  OnRun = function(self, client, class)
    local char = client:GetCharacter()
    local classpoints = char:GetData("ClassPoints", 3)
    if classpoints <= 0 then return "You have no more starting class points to spend." end
    if not class then
      local classes = ix.charclasses.list
      client:Notify("Available Classes:")
      for k, v in pairs(classes) do
        if v.race and v.race ~= char:GetBackground() then continue end
        client:Notify(v.name)
      end
      return
    end

    local chosenclass
    for k, v in pairs(ix.charclasses.list) do
      if ix.util.StringMatches(L(v.name, client), class or ix.util.StringMatches(k, class)) then
        chosenclass = k
        break
      end
    end

    if not chosenclass then return "Class not found!" end
    if ix.charclasses.list[chosenclass].race and ix.charclasses.list[chosenclass].race ~= char:GetBackground() then return "This class is not available for your race." end
    if not char:GetData("PrimaryClass") then
      char:SetData("PrimaryClass", {
        name = ix.charclasses.list[chosenclass].name,
        level = 1,
      })

      classpoints = classpoints - 1
      char:SetData("ClassPoints", classpoints)
      return "You've chosen  " .. ix.charclasses.list[chosenclass].name .. " as your Primary class.\n" .. classpoints .. " Class Points remaining."
    end

    if char:GetData("PrimaryClass") and char:GetData("PrimaryClass").name == ix.charclasses.list[chosenclass].name then
      char:SetData("PrimaryClass", {
        name = ix.charclasses.list[chosenclass].name,
        level = char:GetData("PrimaryClass").level + 1
      })

      classpoints = classpoints - 1
      char:SetData("ClassPoints", classpoints)
      return "You've chosen to spend a point into upgrading your Primary class, increasing it to Level " .. char:GetData("PrimaryClass").level .. ".\n" .. classpoints .. " Class Points remaining."
    end

    if char:GetData("PrimaryClass") and not char:GetData("SecondaryClass") and char:GetData("PrimaryClass").name ~= ix.charclasses.list[chosenclass].name then
      char:SetData("SecondaryClass", {
        name = ix.charclasses.list[chosenclass].name,
        level = 1,
      })

      classpoints = classpoints - 1
      char:SetData("ClassPoints", classpoints)
      return "You've chosen  " .. ix.charclasses.list[chosenclass].name .. " as your Secondary class.\n" .. classpoints .. " Class Points remaining."
    end

    if char:GetData("PrimaryClass") and char:GetData("SecondaryClass") and char:GetData("SecondaryClass").name == ix.charclasses.list[chosenclass].name then
      char:SetData("SecondaryClass", {
        name = ix.charclasses.list[chosenclass].name,
        level = char:GetData("SecondaryClass").level + 1
      })

      classpoints = classpoints - 1
      char:SetData("ClassPoints", classpoints)
      return "You've chosen to spend a point into upgrading your Secondary class, increasing it to Level " .. char:GetData("SecondaryClass").level .. ".\n" .. classpoints .. " Class Points remaining."
    end

    if char:GetData("PrimaryClass") and char:GetData("SecondaryClass") and char:GetData("SecondaryClass").name ~= ix.charclasses.list[chosenclass].name then
      char:SetData("TertiaryClass", {
        name = ix.charclasses.list[chosenclass].name,
        level = 1,
      })

      classpoints = classpoints - 1
      char:SetData("ClassPoints", classpoints)
      return "You've chosen  " .. ix.charclasses.list[chosenclass].name .. " as your Tertiary class.\n" .. classpoints .. " Class Points remaining."
    end
  end
})

ix.command.Add("ChooseVirtues", {
  description = "Allocate your Virtue Points.",
  arguments = {bit.bor(ix.type.string, ix.type.optional)},
  OnRun = function(self, client, virtue)
    local char = client:GetCharacter()
    local virtuepoints = char:GetData("VirtuePoints", 10)
    local upgradecost
    if virtuepoints <= 0 then return "You've already allocated all of your virtue points!" end
    if not virtue then
      client:Notify("You may spend up to 10 Virtue points on one of three virtues: Conscience, Self Control, and Courage, each with a max level of 5.")
      client:Notify("Each level costs 1 Virtue point, but will cost more in Experience later down the line.")
      return
    end

    virtue = string.lower(virtue)
    if virtue == "conscience" then
      local currentlevel = char:GetConscience()
      if currentlevel >= 5 then return "This Virtue is already at its maximum value of 5." end
      char:SetData("Conscience", currentlevel + 1)
      char:SetData("VirtuePoints", virtuepoints - 1)
      client:Notify("You upgraded Conscience from level " .. currentlevel .. " to " .. char:GetConscience() .. ".")
      client:Notify(char:GetData("VirtuePoints", 0) .. " Virtue Points left to spend.")
      return
    elseif virtue == "courage" then
      local currentlevel = char:GetCourage()
      if currentlevel >= 5 then return "This Virtue is already at its maximum value of 5." end
      char:SetData("Courage", currentlevel + 1)
      char:SetData("VirtuePoints", virtuepoints - 1)
      client:Notify("You upgraded Courage from level " .. currentlevel .. " to " .. char:GetCourage() .. ".")
      client:Notify(char:GetData("VirtuePoints", 0) .. " Virtue Points left to spend.")
      return
    elseif virtue == "selfcontrol" then
      local currentlevel = char:GetSelfControl()
      if currentlevel >= 5 then return "This Virtue is already at its maximum value of 5." end
      char:SetData("SelfControl", currentlevel + 1)
      char:SetData("VirtuePoints", virtuepoints - 1)
      client:Notify("You upgraded Self Control from level " .. currentlevel .. " to " .. char:GetSelfControl() .. ".")
      client:Notify(char:GetData("VirtuePoints", 0) .. " Virtue Points left to spend.")
      return
    else
      return "Invalid virtue. Valid options are: conscience, courage, selfcontrol."
    end
  end
})
