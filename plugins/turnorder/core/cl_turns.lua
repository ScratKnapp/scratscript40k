local PLUGIN = PLUGIN
local turnOrder, initiativeActive, currentTurnIndex = {}, false, 1
local rangeTarget, rangeDistance = "", 0
local startPos, movedDistance = nil, 0
net.Receive("UpdateTurnOrderHUD", function()
    initiativeActive = net.ReadBool()
    turnOrder = net.ReadTable()
    currentTurnIndex = net.ReadUInt(8)
end)

net.Receive("UpdateRangeFinder", function()
    rangeTarget = net.ReadString()
    rangeDistance = net.ReadFloat()
end)

net.Receive("PlayTurnSound", function()
    local soundPath = net.ReadString()
    surface.PlaySound(soundPath)
end)

function PLUGIN:Think()
    if initiativeActive and turnOrder[currentTurnIndex] and turnOrder[currentTurnIndex].player == LocalPlayer() then
        if not startPos then startPos = LocalPlayer():GetPos() end
        movedDistance = math.Round(startPos:Distance(LocalPlayer():GetPos()) / 50, 2)
    else
        startPos, movedDistance = nil, 0
    end
end

function PLUGIN:HUDPaint()
    if not initiativeActive then return end
    local x, y = 50, 50
    draw.SimpleText("Turn Order", "VecnaTurnOrder", x, y, color_white, TEXT_ALIGN_LEFT)
    y = y + 40
    for i, entry in ipairs(turnOrder) do
        local color = color_white
        if i == currentTurnIndex then
            if entry.player == LocalPlayer() then
                color = Color(0, 255, 0)
                draw.SimpleText("It is your turn!", "VecnaTurnOrder", ScrW() / 2, 50, color, TEXT_ALIGN_CENTER)
            elseif entry.entity then
                color = Color(255, 0, 0)
                draw.SimpleText("CENT's Turn!", "VecnaTurnOrder", ScrW() / 2, 50, color, TEXT_ALIGN_CENTER)
            end
        elseif i == currentTurnIndex % #turnOrder + 1 then
            if entry.player == LocalPlayer() then
                color = Color(255, 255, 0)
                draw.SimpleText("Your turn is next!", "VecnaTurnOrder", ScrW() / 2, 80, color, TEXT_ALIGN_CENTER)
            elseif entry.entity then
                color = Color(255, 165, 0)
                draw.SimpleText("CENT is next!", "VecnaTurnOrder", ScrW() / 2, 80, color, TEXT_ALIGN_CENTER)
            end
        end

        draw.SimpleText(string.format("%d. %s (%d)", i, entry.name, entry.roll), "VecnaTurnOrder", x, y, color, TEXT_ALIGN_LEFT)
        y = y + 30
    end

    local rangeX, rangeY = ScrW() - 350, 50
    draw.SimpleText("Range Finder", "VecnaTurnOrder", rangeX, rangeY, color_white, TEXT_ALIGN_RIGHT)
    rangeY = rangeY + 40
    if rangeTarget ~= "" then
        draw.SimpleText(string.format("Target: %s", rangeTarget), "VecnaTurnOrder", rangeX, rangeY, color_white, TEXT_ALIGN_RIGHT)
        rangeY = rangeY + 30
        draw.SimpleText(string.format("Distance: %.2f meters", rangeDistance), "VecnaTurnOrder", rangeX, rangeY, color_white, TEXT_ALIGN_RIGHT)
        rangeY = rangeY + 30
    else
        draw.SimpleText("No target", "VecnaTurnOrder", rangeX, rangeY, color_white, TEXT_ALIGN_RIGHT)
        rangeY = rangeY + 30
    end

    draw.SimpleText(string.format("You've moved: %.2f meters", movedDistance), "VecnaTurnOrder", rangeX, rangeY, color_white, TEXT_ALIGN_RIGHT)
end

surface.CreateFont("VecnaTurnOrder", {
    font = "Vecna",
    size = 32,
    weight = 800
})