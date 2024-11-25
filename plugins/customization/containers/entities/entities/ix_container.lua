ENT.Type = "anim"
ENT.PrintName = "Container"
ENT.Category = "Helix"
ENT.Spawnable = false
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.bNoPersist = true

function ENT:SetupDataTables()
    self:NetworkVar("Int", 0, "ID")
    self:NetworkVar("Bool", 0, "Locked")
    self:NetworkVar("Bool", 1, "Hidden")
    self:NetworkVar("String", 0, "DisplayName")
end

if SERVER then
    function ENT:Initialize()
        -- self:DrawShadow(false)
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)
        self:SetUseType(SIMPLE_USE)
        self.receivers = {}
        local physObj = self:GetPhysicsObject()

        if IsValid(physObj) then
            physObj:EnableMotion(true)
            physObj:Wake()
        end
    end

    function ENT:SetInventory(inventory)
        if inventory then
            self:SetID(inventory:GetID())
        end
    end

    function ENT:SetMoney(amount)
        self.money = math.max(0, math.Round(tonumber(amount) or 0))
    end

    function ENT:GetMoney()
        return self.money or 0
    end

    function ENT:OnRemove()
        local index = self:GetID()

        if not ix.shuttingDown and not self.ixIsSafe and ix.entityDataLoaded and index then
            local inventory = ix.item.inventories[index]

            if inventory then
                ix.item.inventories[index] = nil
                local query = mysql:Delete("ix_items")
                query:Where("inventory_id", index)
                query:Execute()
                query = mysql:Delete("ix_inventories")
                query:Where("inventory_id", index)
                query:Execute()
                hook.Run("ContainerRemoved", self, inventory)
            end
        end
    end

    function ENT:OpenInventory(activator, t)
        local inventory = self:GetInventory()

        if inventory then
            local name = self:GetDisplayName()
            -- self:EmitSound("games/ue4/horrorengine/draweropen0" .. math.random(9) .. ".wav")
            self:EmitSound(self:GetNetVar("openSound", "Pathos.OpenDrawer"), 70, 100, 1, CHAN_STATIC, SND_NOFLAGS, 1)

            ix.storage.Open(activator, inventory, {
                name = name,
                entity = self,
                searchTime = t and 0 or ix.config.Get("containerOpenTime", 0.7),
                bMultipleUsers = self:GetNetVar("multipleUsers", false),
                data = {
                    money = self:GetMoney()
                },
                OnPlayerClose = function()
                    -- self:EmitSound("games/ue4/horrorengine/drawerclose0" .. math.random(4) .. ".wav")
                    self:EmitSound(self:GetNetVar("closeSound", "Pathos.CloseDrawer"), 70, 100, 1, CHAN_STATIC, SND_NOFLAGS, 1)
                    ix.log.Add(activator, "closeContainer", name, inventory:GetID())
                end
            })

            if self:GetLocked() then
                self.Sessions[activator:GetCharacter():GetID()] = true
            end

            ix.log.Add(activator, "openContainer", name, inventory:GetID())
        end
    end

    function ENT:OnOptionSelected(activator, option, data)
        if option == "search" then
            -- local character = activator:GetCharacter()
            --  and not self.Sessions[character:GetID()]
            if self:GetLocked() then
                self:EmitSound(self:GetNetVar("lockedSound", "games/ue4/horrorengine/handlerelease04.wav"), 70, 100, 1, CHAN_STATIC, SND_NOFLAGS, 1)

                if (not self.keypad) and (not self:GetNetVar("useKey", false)) then
                    net.Start("ixContainerPassword")
                    net.WriteEntity(self)
                    net.Send(activator)
                end

                if self:GetNetVar("useKey", false) then
                    activator:Hint("The container is locked.")
                end
            else
                self:OpenInventory(activator)
            end
        end
    end

    function ENT:Use(activator)
        if self:IsPlayerHolding() == true then return end
        local inventory = self:GetInventory()

        if inventory and (activator.ixNextOpen or 0) < CurTime() then
            local character = activator:GetCharacter()

            if character then
                activator:PerformInteraction(ix.config.Get("containerOpenTime", 0.7), self, function()
                    --  and not self.Sessions[character:GetID()]
                    if self:GetLocked() then
                        self:EmitSound(self:GetNetVar("lockedSound", "games/ue4/horrorengine/handlerelease04.wav"), 70, 100, 1, CHAN_STATIC, SND_NOFLAGS, 1)

                        if (not self.keypad) and (not self:GetNetVar("useKey", false)) then
                            net.Start("ixContainerPassword")
                            net.WriteEntity(self)
                            net.Send(activator)
                        end

                        if self:GetNetVar("useKey", false) then
                            activator:Hint("The container is locked.")
                        end
                    else
                        self:OpenInventory(activator, 1)
                    end

                    return false
                end)
            end

            activator.ixNextOpen = CurTime() + math.max(ix.config.Get("containerOpenTime", 0.7), 1)
        end
    end
else
    ENT.PopulateEntityInfo = true
    local COLOR_LOCKED = Color(200, 38, 19, 200)
    local COLOR_UNLOCKED = Color(135, 211, 124, 200)

    -- function ENT:Initialize()
    --     self:DrawShadow(false)
    -- end
    function ENT:OnPopulateEntityInfo(tooltip)
        local bLocked = self:GetLocked()
        surface.SetFont("ixIconsSmall")
        local iconText = bLocked and "P" or "Q"
        local iconWidth, iconHeight = surface.GetTextSize(iconText)

        -- minimal tooltips have centered text so we'll draw the icon above the name instead
        if tooltip:IsMinimal() then
            local icon = tooltip:AddRow("icon")
            icon:SetFont("ixIconsSmall")
            icon:SetTextColor(bLocked and COLOR_LOCKED or COLOR_UNLOCKED)
            icon:SetText(iconText)
            icon:SizeToContents()
        end

        local title = tooltip:AddRow("name")
        title:SetImportant()
        title:SetText(self:GetDisplayName())
        title:SetBackgroundColor(ix.config.Get("color"))
        title:SetTextInset(iconWidth + 8, 0)
        title:SizeToContents()

        if not tooltip:IsMinimal() then
            title.Paint = function(panel, width, height)
                panel:PaintBackground(width, height)
                surface.SetFont("ixIconsSmall")
                surface.SetTextColor(bLocked and COLOR_LOCKED or COLOR_UNLOCKED)
                surface.SetTextPos(4, height * 0.5 - iconHeight * 0.5)
                surface.DrawText(iconText)
            end
        end

        local description = tooltip:AddRow("description")
        description:SetText(self:GetNetVar("desc", ""))
        description:SizeToContents()
    end
    -- function ENT:Draw()
    -- self:DrawModel()
    -- end
    -- end
    -- function ENT:DrawTranslucent()
    -- self:Draw(STUDIO_NOSHADOWS)
    -- end
end

function ENT:GetInventory()
    return ix.inventory.Get(self:GetID())
end