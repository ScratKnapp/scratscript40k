ITEM.name = "Glasses"
ITEM.model = "models/bloocobalt/citizens/male_02_glasses.mdl"
ITEM.description = "A pair of glasses."
ITEM.price = 100
ITEM.outfitCategory = "glasses"
ITEM.isSmall = true
function ITEM:SetStrength(v)
  self:SetData("st", v)
end

function ITEM:GetDescription(item)
  return "A pair of glasses." .. (self:GetData("st", 0) ~= 0 and "The strength is approximately " .. (self:GetData("st", 0) > 0 and "+" .. self:GetData("st", 0) or self:GetData("st", 0)) or "")
end

ITEM.pacData = {
  [1] = {
    ["children"] = {
      [1] = {
        ["children"] = {},
        ["self"] = {
          ["Skin"] = 0,
          ["Invert"] = false,
          ["LightBlend"] = 1,
          ["CellShade"] = 0,
          ["OwnerName"] = "self",
          ["AimPartName"] = "",
          ["IgnoreZ"] = false,
          ["AimPartUID"] = "",
          ["Passes"] = 1,
          ["Name"] = "",
          ["NoTextureFiltering"] = false,
          ["DoubleFace"] = false,
          ["PositionOffset"] = Vector(0, 0, 0),
          ["IsDisturbing"] = false,
          ["Fullbright"] = false,
          ["EyeAngles"] = false,
          ["DrawOrder"] = 0,
          ["TintColor"] = Vector(0, 0, 0),
          ["UniqueID"] = "157999615",
          ["Translucent"] = false,
          ["LodOverride"] = -1,
          ["BlurSpacing"] = 0,
          ["Alpha"] = 1,
          ["Material"] = "",
          ["UseWeaponColor"] = false,
          ["UsePlayerColor"] = false,
          ["UseLegacyScale"] = false,
          ["Bone"] = "head",
          ["Color"] = Vector(255, 255, 255),
          ["Brightness"] = 1,
          ["BoneMerge"] = false,
          ["BlurLength"] = 0,
          ["Position"] = Vector(0, -1, -0.061999998986721),
          ["AngleOffset"] = Angle(-1.2999999523163, 0, 0),
          ["AlternativeScaling"] = false,
          ["Hide"] = false,
          ["OwnerEntity"] = false,
          ["Scale"] = Vector(1, 1, 1),
          ["ClassName"] = "model",
          ["EditorExpand"] = false,
          ["Size"] = 1,
          ["ModelFallback"] = "",
          ["Angles"] = Angle(0, -84.099998474121, -90),
          ["TextureFilter"] = 3,
          ["Model"] = "models/bloocobalt/citizens/male_02_glasses.mdl",
          ["BlendMode"] = "",
        },
      },
    },
    ["self"] = {
      ["DrawOrder"] = 0,
      ["UniqueID"] = "1407914850",
      ["AimPartUID"] = "",
      ["Hide"] = false,
      ["Duplicate"] = false,
      ["ClassName"] = "group",
      ["OwnerName"] = "self",
      ["IsDisturbing"] = false,
      ["Name"] = "my outfit",
      ["EditorExpand"] = true,
    },
  },
}

ITEM.functions.Clean = {
  OnCanRun = function(itemTable)
    if itemTable:GetData("dirty", nil) then return true end
    return false
  end,
  name = "Clean",
  tip = "Clean the glasses.",
  OnRun = function(itemTable)
    if itemTable:GetData("equip", nil) then
      ix.action.Run(itemTable.player, "OnCleanVisor", {
        itemID = itemTable:GetID(),
        uniqueID = itemTable.uniqueID,
        dirty = itemTable:GetData("dirty")
      })
    end

    itemTable:SetData("dirty", nil)
    return false
  end
}

function ITEM:pacAdjust(pacAdjust, client)
  if client:IsFemale() then
    pacAdjust[1]["children"][1]["self"]["Position"] = Vector(-0.8, -1, 0)
    pacAdjust[1]["children"][1]["self"]["Model"] = "models/bloocobalt/citizens/female_02_glasses.mdl"
  else
    if string.find(client:GetModel(), "/male_") then
      local c = string.find(client:GetModel(), "/male_")
      if string.find(client:GetModel(), "male_04.mdl") then
        pacAdjust[1]["children"][1]["self"]["Position"] = Vector(-2.4, -1, 0)
      else
        pacAdjust[1]["children"][1]["self"]["Position"] = Vector(-1.6, -1, 0)
      end

      pacAdjust[1]["children"][1]["self"]["Model"] = "models/bloocobalt/citizens/" .. string.sub(client:GetModel(), c, c + 7) .. "_glasses.mdl"
    end
  end
  return pacAdjust
end

function ITEM:OnEquipped()
  local client = self.player
  local character = client:GetCharacter()
  ix.action.Run(client, "OnEquipVisor", {
    state = true,
    uniqueID = self.uniqueID,
    itemID = self.id,
    dirty = self:GetData("dirty")
  })

  if self:GetData("st", 0) == 0 then self:SetData("st", character:GetData("eStr", 0)) end
  local diff = math.abs(character:GetData("eStr", 0) - self:GetData("st", 2))
  if math.Round(diff, 1) > 0 then
    character:AddBoost("glasses", "per", -(math.max(0, character:GetAttributes()["per"] - 1) + diff * 0.5))
  else
    character:RemoveBoost("glasses", "per")
  end
end

function ITEM:OnUnequipped()
  local client = self.player
  ix.action.Run(client, "OnEquipVisor", {
    state = false,
    uniqueID = self.uniqueID,
    itemID = self.id,
    dirty = self:GetData("dirty")
  })

  local character = client:GetCharacter()
  local diff = math.abs(character:GetData("eStr", 0))
  if diff ~= 0 then
    character:AddBoost("glasses", "per", -(math.max(0, character:GetAttributes()["per"] - 1) + diff * 0.5))
  else
    character:RemoveBoost("glasses", "per")
  end
end
