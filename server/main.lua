ESX = nil

ESX = exports["es_extended"]:getSharedObject()

local function support_startup()
    MySQL.Async.execute("CREATE TABLE IF NOT EXISTS tg_admin_tickets (id INT AUTO_INCREMENT PRIMARY KEY, source INT NOT NULL, FivemName VARCHAR(255) NOT NULL, PlayerID INT NOT NULL, IngameName VARCHAR(255) NOT NULL, reason TEXT, ticketcoords JSON, status VARCHAR(50) DEFAULT 'open', created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP);")
end

if Config.SupportEnabled then
    support_startup()

    if Config.Debug then
        print("^0[^3DEBUG^0] ^1tg_admin^0: ^4Support^0-System ^2enabled^0.")
    end
    
    RegisterCommand(Config.SupportCommand, function(source, args)
        if source > 0 then
            local _source = source
            if Config.Debug then
                print("^0[^3DEBUG^0] ^1tg_admin^0: Source is valid player: " .. _source)
            end
            
            local xPlayer = ESX.GetPlayerFromId(_source)
            if xPlayer then
                if Config.Debug then
                    print("^0[^3DEBUG^0] ^1tg_admin^0: xPlayer object retrieved.")
                end
                
                local FivemName = GetPlayerName(_source)
                if Config.Debug then
                    print("^0[^3DEBUG^0] ^1tg_admin^0: FivemName: " .. FivemName)
                end
                
                local PlayerID = _source
                if Config.Debug then
                    print("^0[^3DEBUG^0] ^1tg_admin^0: PlayerID: " .. PlayerID)
                end
                
                local IngameName = xPlayer.getName()
                if Config.Debug then
                    print("^0[^3DEBUG^0] ^1tg_admin^0: IngameName: " .. IngameName)
                end
                
                local reason = table.concat(args, " ")
                if reason == "" then
                    reason = "NULL"
                end

                if Config.Debug then
                    print("^0[^3DEBUG^0] ^1tg_admin^0: Reason: " .. reason)
                end
                
                local ticketcoords = GetEntityCoords(GetPlayerPed(_source))
                local ticketcoordsJSON = json.encode(ticketcoords)
                if Config.Debug then
                    print("^0[^3DEBUG^0] ^1tg_admin^0: TicketCoords: " .. ticketcoordsJSON)
                end

                local ticketID = nil
                MySQL.Async.insert('INSERT INTO tg_admin_tickets (source, FivemName, PlayerID, IngameName, reason, ticketcoords, status) VALUES (@source, @fivemName, @playerID, @ingameName, @reason, @ticketcoords, @status)', {
                    ['@source'] = _source,
                    ['@fivemName'] = FivemName,
                    ['@playerID'] = PlayerID,
                    ['@ingameName'] = IngameName,
                    ['@reason'] = reason,
                    ['@ticketcoords'] = ticketcoordsJSON,
                    ['@status'] = 'open'
                }, function(insertId)
                    ticketID = insertId

                    local players = ESX.GetPlayers()
                    for _, player in ipairs(players) do
                        local xPlayer = ESX.GetPlayerFromId(player)
                        local playerGroup = xPlayer.getGroup()

                        for _, AllowedGroup in ipairs(Config.SupportGroups) do
                            if playerGroup == AllowedGroup then
                                TriggerClientEvent("tg_admin:ticketcreatednotify", player, ticketID)
                            end
                        end
                    end

                    if Config.Debug then
                        print("^0[^3DEBUG^0] ^1tg_admin^0: /"..Config.SupportCommand.." was executed: Ticket ID: ^2"..ticketID.."^0 - FiveM Name: ^4"..FivemName.." ^0- Player ID: ^4"..PlayerID.." ^0- RP Name: ^4"..IngameName.." ^0| Grund: ^4"..reason.." ^0| Ticket Coords: ^4"..ticketcoordsJSON)
                    end

                end)
            else
                if Config.Debug then
                    print("^0[^3DEBUG^0] ^1tg_admin^0: xPlayer object not found.")
                end
            end
        else
            if Config.Debug then
                print("^0[^3DEBUG^0] ^1tg_admin^0: /"..Config.SupportCommand.." was executed by ^4server console^0, ^4RCON client^0 or a ^4resource^0.")
            end
        end
    end, false)
end

ESX.RegisterServerCallback('tg_admin:getAdminTickets', function(source, cb)
    MySQL.Async.fetchAll('SELECT id, source, FivemName, PlayerID, IngameName, reason, ticketcoords, status, DATE_FORMAT(created_at, "%d.%m.%Y %H:%i:%s") AS created_at FROM tg_admin_tickets', {}, function(tickets)
        cb(tickets)
    end)
end)

ESX.RegisterServerCallback('tg_admin:getPlayerCoords', function(source, cb, playerSource)
    local targetPlayer = ESX.GetPlayerFromId(playerSource)

    if targetPlayer then
        local coords = targetPlayer.getCoords(true)
        cb(coords)
    else
        cb(nil)
    end
end)

RegisterServerEvent('tg_admin:updateTicketStatus')
AddEventHandler('tg_admin:updateTicketStatus', function(ticketId, newStatus)
    local _source = source

    MySQL.Async.execute(
        'UPDATE tg_admin_tickets SET status = @newStatus WHERE id = @ticketId',
        {
            ['@ticketId'] = ticketId,
            ['@newStatus'] = newStatus
        },
        function(rowsChanged)
            if rowsChanged > 0 then
                TriggerClientEvent('tg_admin:ticketStatusUpdated', -1, ticketId, newStatus)
            else
                print('Error: Ticket update failed')
            end
        end
    )
end)

if Config.SupportEnabled then
    RegisterNetEvent("tg_admin:requestOpenMenu")
    AddEventHandler("tg_admin:requestOpenMenu", function()
        local _source = source
        local xPlayer = ESX.GetPlayerFromId(_source)
        if xPlayer then
            if Config.Debug then
                print("^0[^3DEBUG^0] ^1tg_admin^0: xPlayer object retrieved.")
            end

            local playerGroup = xPlayer.getGroup()

            for _, AllowedGroup in ipairs(Config.SupportGroups) do
                if playerGroup == AllowedGroup then
                    if Config.Debug then
                        print("^0[^3DEBUG^0] ^1tg_admin^0: Sending openticketsmenu event to player ID: ".._source)
                    end
                    
                    TriggerClientEvent("tg_admin:openticketsmenu", _source)
                    return
                end
            end

            if Config.Debug then
                print("^0[^3DEBUG^0] ^1tg_admin^0: Player ID: ".._source.." is not authorized to open the menu.")
            end
        end
    end)
end

RegisterCommand(Config.AdminCommand, function(source, args)
    if source > 0 then
        local _source = source
        local xPlayer = ESX.GetPlayerFromId(_source)
        if xPlayer then
            if Config.Debug then
                print("^0[^3DEBUG^0] ^1tg_admin^0: xPlayer object retrieved.")
            end

            local players = ESX.GetPlayers()
            for _, player in ipairs(players) do
                local xPlayer = ESX.GetPlayerFromId(player)
                local playerGroup = xPlayer.getGroup()

                for _, AllowedGroup in ipairs(Config.AdminGroups) do
                    if playerGroup == AllowedGroup then
                        TriggerClientEvent("tg_admin:adminmode", _source)
                        return
                    end
                end
            end

            if Config.Debug then
                print("^0[^3DEBUG^0] ^1tg_admin^0: /"..Config.AdminCommand.." was executed by ID: ".._source)
            end
        end
    else
        if Config.Debug then
            print("^0[^3DEBUG^0] ^1tg_admin^0: /"..Config.AdminCommand.." was executed by ^4server console^0, ^4RCON client^0 or a ^4resource^0.")
        end
    end
end, false)

if Config.EnableNames then
    RegisterCommand(Config.NameCommand, function(source, args)
        if source > 0 then
            local _source = source
            local xPlayer = ESX.GetPlayerFromId(_source)
            if xPlayer then
                if Config.Debug then
                    print("^0[^3DEBUG^0] ^1tg_admin^0: xPlayer object retrieved.")
                end

                local players = ESX.GetPlayers()
                for _, player in ipairs(players) do
                    local xPlayer = ESX.GetPlayerFromId(player)
                    local playerGroup = xPlayer.getGroup()

                    for _, AllowedGroup in ipairs(Config.AdminGroups) do
                        if playerGroup == AllowedGroup then
                            TriggerClientEvent("tg_admin:names", _source)
                            return
                        end
                    end
                end

                if Config.Debug then
                    print("^0[^3DEBUG^0] ^1tg_admin^0: /"..Config.NameCommand.." was executed by ID: ".._source)
                end
            end
        else
            if Config.Debug then
                print("^0[^3DEBUG^0] ^1tg_admin^0: /"..Config.NameCommand.." was executed by ^4server console^0, ^4RCON client^0 or a ^4resource^0.")
            end
        end
    end, false)
end

if Config.EnableBlips then
    RegisterCommand(Config.BlipCommand, function(source, args)
        if source > 0 then
            local _source = source
            local xPlayer = ESX.GetPlayerFromId(_source)
            if xPlayer then
                if Config.Debug then
                    print("^0[^3DEBUG^0] ^1tg_admin^0: xPlayer object retrieved.")
                end

                local players = ESX.GetPlayers()
                for _, player in ipairs(players) do
                    local xPlayer = ESX.GetPlayerFromId(player)
                    local playerGroup = xPlayer.getGroup()

                    for _, AllowedGroup in ipairs(Config.AdminGroups) do
                        if playerGroup == AllowedGroup then
                            TriggerClientEvent("tg_admin:blips", _source)
                            return
                        end
                    end
                end

                if Config.Debug then
                    print("^0[^3DEBUG^0] ^1tg_admin^0: /"..Config.BlipCommand.." was executed by ID: ".._source)
                end
            end
        else
            if Config.Debug then
                print("^0[^3DEBUG^0] ^1tg_admin^0: /"..Config.BlipCommand.." was executed by ^4server console^0, ^4RCON client^0 or a ^4resource^0.")
            end
        end
    end, false)
end

if Config.EnableGodMode then
    RegisterCommand(Config.GodModeCommand, function(source, args)
        if source > 0 then
            local _source = source
            local xPlayer = ESX.GetPlayerFromId(_source)
            if xPlayer then
                if Config.Debug then
                    print("^0[^3DEBUG^0] ^1tg_admin^0: xPlayer object retrieved.")
                end

                local players = ESX.GetPlayers()
                for _, player in ipairs(players) do
                    local xPlayer = ESX.GetPlayerFromId(player)
                    local playerGroup = xPlayer.getGroup()

                    for _, AllowedGroup in ipairs(Config.AdminGroups) do
                        if playerGroup == AllowedGroup then
                            TriggerClientEvent("tg_admin:godmode", _source)
                            return
                        end
                    end
                end

                if Config.Debug then
                    print("^0[^3DEBUG^0] ^1tg_admin^0: /"..Config.GodModeCommand.." was executed by ID: ".._source)
                end
            end
        else
            if Config.Debug then
                print("^0[^3DEBUG^0] ^1tg_admin^0: /"..Config.GodModeCommand.." was executed by ^4server console^0, ^4RCON client^0 or a ^4resource^0.")
            end
        end
    end, false)
end

RegisterServerEvent('tg_admin:changetolastclothing')
AddEventHandler('tg_admin:changetolastclothing', function()
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    
    if not xPlayer then
        print("^0[^1ERROR^0] ^1tg_admin^0: xPlayer ist nil")
        return
    end

    local identifier = xPlayer.getIdentifier()

    MySQL.Async.fetchAll('SELECT skin FROM users WHERE identifier = @identifier', {
        ['@identifier'] = identifier
    }, function(result)
        if result[1] and result[1].skin ~= nil then
            local skin = json.decode(result[1].skin)
            TriggerClientEvent('skinchanger:loadClothes', _source, skin)
        else
            print("^0[^1ERROR^0] ^1tg_admin^0: No saved clothing found.")
        end
    end)
end)