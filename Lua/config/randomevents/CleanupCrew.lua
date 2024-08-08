local event = {}
event.Name = "CleanupCrew"
event.MinRoundTime = 5
event.MinIntensity = 0
event.MaxIntensity = 0.1
event.ChancePerMinute = 0.01
event.OnlyOncePerRound = true

event.Start = function()
    local deadCharacters = {}
    for _,client in pairs(Client.ClientList) do
        if client.Character == nil or client.Character.IsDead then
            table.insert(deadCharacters, client)
        end
    end

    if #deadCharacters == 0 then
        event.End()
        return
    end

    for _, deadCharacter in ipairs(deadCharacters) do
        local submarine = Submarine.MainSub
        local subPosition = submarine.WorldPosition
        local angle = math.random() * 2 * math.pi
        local distance = math.random(1000, 2000)
        local offsetX = math.cos(angle) * distance
        local offsetY = math.sin(angle) * distance
        local position = Vector2(subPosition.X + offsetX, subPosition.Y + offsetY)
        Traitormod.GeneratePirate(position)
    end

    Traitormod.RoundEvents.SendEventMessage("The Cleanup Crew has arrived!", "CrewWalletIconLarge")
end

event.End = function()
end

return event