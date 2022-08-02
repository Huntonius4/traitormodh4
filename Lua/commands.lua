----- USER COMMANDS -----
Traitormod.AddCommand("!help", function (client, args)
    Traitormod.SendMessage(client, Traitormod.Language.Help)

    return true
end)

Traitormod.AddCommand("!version", function (client, args)
    Traitormod.SendMessage(client, "Running Evil Factory's Traitor Mod v" .. Traitormod.VERSION)

    return true
end)

Traitormod.AddCommand("!traitor", function (client, args)
    if Game.ServerSettings.TraitorsEnabled == 0 then
        Traitormod.SendMessage(client, Traitormod.Language.NoTraitors)
    elseif Game.RoundStarted and Traitormod.SelectedGamemode and Traitormod.SelectedGamemode.GetTraitorObjectiveSummary then
        local summary = Traitormod.SelectedGamemode.GetTraitorObjectiveSummary(client.Character)
        Traitormod.SendMessage(client, summary)
    elseif Game.RoundStarted then
        Traitormod.SendMessage(client, Traitormod.Language.NoTraitor)
    else
        Traitormod.SendMessage(client, Traitormod.Language.RoundNotStarted)
    end

    return true
end)

Traitormod.AddCommand("!points", function (client, args)
    Traitormod.SendMessage(client, Traitormod.GetDataInfo(client, true))

    return true
end)

Traitormod.AddCommand("!info", function (client, args)
    Traitormod.SendWelcome(client)
    
    return true
end)

----- ADMIN COMMANDS -----
Traitormod.AddCommand("!alive", function (client, args)
    if not (client.Character == nil or client.Character.IsDead) and not client.HasPermission(ClientPermissions.ConsoleCommands) then return end

    if not Game.RoundStarted or Traitormod.SelectedGamemode == nil then
        Traitormod.SendMessage(client, Traitormod.Language.RoundNotStarted)

        return true
    end

    local msg = ""
    for index, value in pairs(Character.CharacterList) do
        if value.IsHuman and not value.IsBot then
            if value.IsDead then
                msg = msg .. value.Name .. " ---- " .. Traitormod.Language.Dead .. "\n"
            else
                msg = msg .. value.Name .. " ++++ " .. Traitormod.Language.Alive .. "\n"
            end
        end
    end

    Traitormod.SendMessage(client, msg)

    return true
end)

Traitormod.AddCommand("!roundinfo", function (client, args)
    if not client.HasPermission(ClientPermissions.ConsoleCommands) then return end

    if Game.RoundStarted and Traitormod.SelectedGamemode and Traitormod.SelectedGamemode.GetRoundSummary then
        Traitormod.SendMessage(client, Traitormod.SelectedGamemode.GetRoundSummary())
    elseif Traitormod.LastRoundSummary ~= nil then
        Traitormod.SendMessage(client, Traitormod.LastRoundSummary)
    else
        Traitormod.SendMessage(client, Traitormod.Language.RoundNotStarted)
    end

    return true
end)

Traitormod.AddCommand("!allpoints", function (client, args)
    if not client.HasPermission(ClientPermissions.ConsoleCommands) then return end
    
    local messageToSend = ""

    for index, value in pairs(Client.ClientList) do
        messageToSend = messageToSend .. "\n" .. value.Name .. ": " .. math.floor(Traitormod.GetData(value, "Points") or 0) .. " Points - " .. math.floor(Traitormod.GetData(value, "Weight") or 0) .. " Weight"
    end

    Traitormod.SendMessage(client, messageToSend)

    return true
end)

Traitormod.AddCommand("!addpoint", function (client, args)
    if not client.HasPermission(ClientPermissions.ConsoleCommands) then return end
    
    if #args < 2 then
        Traitormod.SendMessage(client, "Incorrect amount of arguments. usage: !addpoint \"Client Name\" 500")

        return true
    end

    local name = table.remove(args, 1)
    local amount = tonumber(table.remove(args, 1))

    if amount == nil or amount ~= amount then
        Traitormod.SendMessage(client, "Invalid number value.")
        return true
    end

    local found = nil

    for key, value in pairs(Client.ClientList) do
        if value.Name == name or tostring(value.SteamID) == name then
            found = value
            break
        end
    end

    if found == nil then
        Traitormod.SendMessage(client, "Couldn't find a client with name / steamID " .. name)
        return true
    end

    Traitormod.AddData(found, "Points", amount)
    Traitormod.SendMessage(client, string.format("Gave %s points to %s.", amount, found.Name))

    return true
end)

Traitormod.AddCommand("!removepoint", function (client, args)
    if not client.HasPermission(ClientPermissions.ConsoleCommands) then return end

    if #args < 2 then
        Traitormod.SendMessage(client, "Incorrect amount of arguments. usage: !removepoint \"Client Name\" 500")

        return true
    end

    local name = table.remove(args, 1)
    local amount = tonumber(table.remove(args, 1))

    if amount == nil or amount ~= amount then
        Traitormod.SendMessage(client, "Invalid number value.")
        return true
    end

    local found = nil

    for key, value in pairs(Client.ClientList) do
        if value.Name == name or tostring(value.SteamID) == name then
            found = value
            break
        end
    end

    if found == nil then
        Traitormod.SendMessage(client, "Couldn't find a client with name / steamID " .. name)
        return true
    end

    Traitormod.AddData(found, "Points", -amount)
    Traitormod.SendMessage(client, string.format("Removed %s points from %s.", amount, found.Name))

    return true
end)

Traitormod.AddCommand("!addlife", function (client, args)
    if not client.HasPermission(ClientPermissions.ConsoleCommands) then return end

    if #args < 1 then
        Traitormod.SendMessage(client, "Incorrect amount of arguments. usage: !addlife \"Client Name\" 1")

        return true
    end

    local name = table.remove(args, 1)

    local amount = 1
    if #args > 1 then
        amount = tonumber(table.remove(args, 1))
    end

    if amount == nil or amount ~= amount then
        Traitormod.SendMessage(client, "Invalid number value.")
        return true
    end

    local found = nil

    for key, value in pairs(Client.ClientList) do
        if value.Name == name or tostring(value.SteamID) == name then
            found = value
            break
        end
    end

    if found == nil then
        Traitormod.SendMessage(client, "Couldn't find a client with name / steamID " .. name)
        return true
    end

    local lifeMsg, lifeIcon = Traitormod.AdjustLives(found, amount)

    if lifeMsg then
        Traitormod.SendMessage(found, lifeMsg, lifeIcon)
    end

    return true
end)

Traitormod.AddCommand("!revive", function (client, args)
    if not client.HasPermission(ClientPermissions.ConsoleCommands) then return end

    local reviveClient = client
    local name = client.Name

    if #args > 0 then
        -- if client name is given, revive related character
        name = table.remove(args, 1)
        -- find character by client name
        for player in Client.ClientList do
            if player.Name == name then
                reviveClient = player
            end
        end
    end

    if reviveClient.Character and reviveClient.Character.IsDead then
        reviveClient.Character.Revive()
        client.SetClientCharacter(reviveClient.Character);
        local lifeMsg, lifeIcon = Traitormod.AdjustLives(reviveClient, 1)

        if lifeMsg then
            Traitormod.SendMessage(reviveClient, lifeMsg, lifeIcon)
        end

        Game.SendDirectChatMessage("", "Character of " .. name .. " revived and given back 1 life.", nil, ChatMessageType.Error, client)

    elseif reviveClient.Character then
        Game.SendDirectChatMessage("", "Character of " .. name .. " is not dead.", nil, ChatMessageType.Error, client)
    else
        Game.SendDirectChatMessage("", "Character of " .. name .. " not found.", nil, ChatMessageType.Error, client)
    end

    return true
end)