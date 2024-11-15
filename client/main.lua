ESX = nil

ESX = exports["es_extended"]:getSharedObject()

local ticketMenu = nil
local archivedMenu = nil
local adminMode = false
local godMode = false
local namesEnabled = false
local blipsEnabled = false
local clothequipped = false

if Config.SupportEnabled then
    RegisterKeyMapping(Config.MenuCommand, _('keymap_open_support'), 'keyboard', Config.MenuDefaultKey)

    RegisterCommand(Config.MenuCommand, function()
        TriggerServerEvent("tg_admin:requestOpenMenu")
    end, false)
end

RegisterNetEvent("tg_admin:openticketsmenu")
AddEventHandler("tg_admin:openticketsmenu", function()
    if Config.Debug then
        print("^0[^3DEBUG^0] ^1tg_admin^0: tg_admin:openticketsmenu Event Triggered on Client")
    end
    OpenAdminTicketsMenu()
end)

function OpenAdminTicketsMenu()
    ESX.TriggerServerCallback('tg_admin:getAdminTickets', function(tickets)
        local elements = {
            {label = "Refresh Page", name = "refresh"}
        }

        for i=1, #tickets, 1 do
            local statusLabel = tickets[i].status
            local color = ""

            if string.find(tickets[i].status:lower(), "open") then
                color = '<span style="color:green;">'
            elseif string.find(tickets[i].status:lower(), "closed") then
                color = '<span style="color:red;">'
            elseif string.find(tickets[i].status:lower(), "claimed") then
                color = '<span style="color:yellow;">'
            end

            statusLabel = color .. statusLabel .. '</span>'

            if tickets[i].status == "open" or string.find(tickets[i].status:lower(), "claimed") then
                table.insert(elements, {
                    label = tickets[i].id .. ' - ' .. tickets[i].created_at .. ' (' .. statusLabel .. ')',
                    value = tickets[i]
                })
            end
        end

        table.insert(elements, {label = _('ticket_main_archieved'), name = "archived_tickets"})

        if ticketMenu then
            ticketMenu.close()
        end

        ticketMenu = ESX.UI.Menu.Open(
            'default', GetCurrentResourceName(), 'admin_tickets',
            {
                title    = 'Admin Tickets',
                align    = 'top-left',
                elements = elements
            },
            function(data, menu)
                if data.current.name == 'refresh' then
                    menu.close()
                    OpenAdminTicketsMenu()
                elseif data.current.name == 'archived_tickets' then
                    OpenArchivedTicketsMenu()
                else
                    OpenTicketDetailsMenu(data.current.value)
                end
            end,
            function(data, menu)
                menu.close()
                ticketMenu = nil
            end
        )
    end)
end

function OpenArchivedTicketsMenu()
    ESX.TriggerServerCallback('tg_admin:getAdminTickets', function(tickets)
        local elements = {
            {label = _('ticket_second_back'), name = "back_to_open_tickets"}
        }

        for i=1, #tickets, 1 do
            if string.find(tickets[i].status:lower(), "closed") then
                local statusLabel = '<span style="color:red;">' .. tickets[i].status .. '</span>'
                table.insert(elements, {
                    label = tickets[i].id .. ' - ' .. tickets[i].created_at .. ' (' .. statusLabel .. ')',
                    value = tickets[i]
                })
            end
        end

        if archivedMenu then
            archivedMenu.close()
        end

        archivedMenu = ESX.UI.Menu.Open(
            'default', GetCurrentResourceName(), 'archived_tickets',
            {
                title    = _('ticket_main_archieved'),
                align    = 'top-left',
                elements = elements
            },
            function(data, menu)
                if data.current.name == 'back_to_open_tickets' then
                    menu.close()
                    OpenAdminTicketsMenu()
                else
                    OpenTicketDetailsMenu(data.current.value)
                end
            end,
            function(data, menu)
                menu.close()
                archivedMenu = nil
            end
        )
    end)
end

function OpenTicketDetailsMenu(ticket)
    local elements = {
        {label = _('ticket_details_playerid') .. ticket.PlayerID},
        {label = _('ticket_details_name') .. ticket.FivemName},
        {label = _('ticket_details_rpname') .. ticket.IngameName},
        {label = ''},
        {label = _('ticket_details_created_at') .. ticket.created_at},
        {label = _('ticket_details_reason') .. ticket.reason},
        {label = ''},
        {label = _('ticket_details_state') .. ticket.status},
        {label = _('ticket_details_claim'), value = 'claim_ticket'},
        {label = _('ticket_details_release'), value = 'release_ticket'},
        {label = _('ticket_details_close'), value = 'close_ticket'},
        {label = ''},
        {label = _('ticket_details_tp_to_ticket'), value = 'tp_ticket'},
        {label = _('ticket_details_wp_to_ticket'), value = 'wp_ticket'},
        {label = _('ticket_details_tp_to_player'), value = 'tp_player'},
        {label = _('ticket_details_wp_to_player'), value = 'wp_player'}
    }

    ESX.UI.Menu.Open(
        'default', GetCurrentResourceName(), 'ticket_details',
        {
            title    = 'Ticket Details - ' .. ticket.id,
            align    = 'top-left',
            elements = elements
        },
        function(data, menu)
            if data.current.value == 'tp_ticket' then
                local coords = json.decode(ticket.ticketcoords)
                SetEntityCoords(PlayerPedId(), coords.x, coords.y, coords.z)
                ESX.ShowNotification(_('notify_success_tp_ticket'),"success")
            elseif data.current.value == 'wp_ticket' then
                local coords = json.decode(ticket.ticketcoords)
                SetNewWaypoint(coords.x, coords.y)
                ESX.ShowNotification(_('notify_success_wp_ticket'),"success")
            elseif data.current.value == 'tp_player' then
                ESX.TriggerServerCallback('tg_admin:getPlayerCoords', function(coords)
                    if coords then
                        SetEntityCoords(PlayerPedId(), coords.x, coords.y, coords.z)
                        ESX.ShowNotification(_('notify_success_tp_player'),"success")
                    else
                        ESX.ShowNotification(_('notify_error_player_404'),"error")
                    end
                end, ticket.source)
            elseif data.current.value == 'wp_player' then
                ESX.TriggerServerCallback('tg_admin:getPlayerCoords', function(coords)
                    if coords then
                        SetNewWaypoint(coords.x, coords.y)
                        ESX.ShowNotification(_('notify_success_wp_player'),"success")
                    else
                        ESX.ShowNotification(_('notify_error_player_404'),"error")
                    end
                end, ticket.source)
            elseif data.current.value == 'claim_ticket' then
                ClaimTicket(ticket)
                menu.close()
            elseif data.current.value == 'release_ticket' then
                ReleaseTicket(ticket)
                menu.close()
            elseif data.current.value == 'close_ticket' then
                CloseTicket(ticket)
                menu.close()
            else
                if data.current.label ~= "" then
                    ESX.ShowNotification("[~r~tg_admin~s~ - ~b~Ticket Details~s~] "..data.current.label)
                end
            end
        end,
        function(data, menu)
            menu.close()
        end
    )
end

function ClaimTicket(ticket)
    local adminName = GetPlayerName(PlayerId())
    local newStatus = "claimed - " .. adminName

    TriggerServerEvent('tg_admin:updateTicketStatus', ticket.id, newStatus)
    ESX.ShowNotification("[~r~tg_admin~s~ - ~b~Ticket Status~s~] Ticket ~b~" .. ticket.id .. "~s~ ~y~".._('ticket_claimed').."~s~.", "success")
end

function ReleaseTicket(ticket)
    local newStatus = "open"

    TriggerServerEvent('tg_admin:updateTicketStatus', ticket.id, newStatus)
    ESX.ShowNotification("[~r~tg_admin~s~ - ~b~Ticket Status~s~] Ticket ~b~" .. ticket.id .. "~s~ ~g~".._('ticket_released').."~s~.", "success")
end

function CloseTicket(ticket)
    local adminName = GetPlayerName(PlayerId())
    local newStatus = "closed - " .. adminName

    TriggerServerEvent('tg_admin:updateTicketStatus', ticket.id, newStatus)
    ESX.ShowNotification("[~r~tg_admin~s~ - ~b~Ticket Status~s~] Ticket ~b~" .. ticket.id .. "~s~ ~r~".._('ticket_closed').."~s~.", "success")
end

RegisterNetEvent('tg_admin:ticketStatusUpdated')
AddEventHandler('tg_admin:ticketStatusUpdated', function(ticketId, newStatus)
    if ticketMenu then
        ticketMenu.close()
        ticketMenu = nil
    end
    if archivedMenu then
        archivedMenu.close()
        archivedMenu = nil
    end
    OpenAdminTicketsMenu()
end)

RegisterNetEvent('tg_admin:ticketcreatednotify')
AddEventHandler('tg_admin:ticketcreatednotify', function(ticketID)
    ESX.ShowNotification(_('notify_new_ticket'), "error", 15000)
end)

RegisterNetEvent("tg_admin:adminmode")
AddEventHandler("tg_admin:adminmode", function()
    if adminMode == false then
        adminMode = true

        if Config.EnableGodMode then
            if godMode == false then
                SetPlayerInvincible(PlayerId(), true)
                godMode = true
            end
        end

        if Config.EnableNames then
            namesEnabled = true
        end

        if Config.EnableBlips then
            blipsEnabled = true
        end

        if Config.EnableClothing then
            if clothequipped == false then
                clothequipped = true
                ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
                    if skin.sex == 0 then
                        TriggerEvent('skinchanger:loadClothes', skin, Config.AdminClothing_M)
                    else
                        TriggerEvent('skinchanger:loadClothes', skin, Config.AdminClothing_F)
                    end
                end)
            end
        end

        ESX.ShowNotification(_('admin_activated'), "success")
    else
        adminMode = false

        if Config.EnableGodMode then
            if godMode == true then
                SetPlayerInvincible(PlayerId(), false)
                godMode = false
            end
        end

        if Config.EnableNames then
            namesEnabled = false
        end

        if Config.EnableBlips then
            blipsEnabled = false
        end

        if Config.EnableClothing then
            TriggerServerEvent('tg_admin:changetolastclothing')
            clothequipped = false
        end

        ESX.ShowNotification(_('admin_deactivated'), "success")
    end
end)

RegisterNetEvent("tg_admin:names")
AddEventHandler("tg_admin:names", function()
    if Config.EnableNames then
        if namesEnabled == false then
            namesEnabled = true
            ESX.ShowNotification(_('names_activated'), "success")
        else
            namesEnabled = false
            ESX.ShowNotification(_('names_deactivated'), "success")
        end
    end
end)

RegisterNetEvent("tg_admin:blips")
AddEventHandler("tg_admin:blips", function()
    if Config.EnableBlips then
        if blipsEnabled == false then
            blipsEnabled = true
            ESX.ShowNotification(_('blips_activated'), "success")
        else
            blipsEnabled = false
            ESX.ShowNotification(_('blips_deactivated'), "success")
        end
    end
end)

RegisterNetEvent("tg_admin:godmode")
AddEventHandler("tg_admin:godmode", function()
    if Config.EnableGodMode then
        if godMode == false then
            godMode = true
            SetPlayerInvincible(PlayerId(), true)
            ESX.ShowNotification(_('godmode_activated'), "success")
        else
            godMode = false
            SetPlayerInvincible(PlayerId(), false)
            ESX.ShowNotification(_('godmode_deactivated'), "success")
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        while namesEnabled do
            Citizen.Wait(0)
            for _, player in ipairs(GetActivePlayers()) do
                local ped = GetPlayerPed(player)

                local playerCoords = GetEntityCoords(ped)
                local x, y, z = table.unpack(playerCoords)
                local playerId = GetPlayerServerId(player)
                local playerName = GetPlayerName(player)
                Draw3DText(x, y, z + 1.0, 0.5, "ID: " .. playerId .. " | " .. playerName)
            end
        end
        Citizen.Wait(0)
    end
    Citizen.Wait(0)
end)

Citizen.CreateThread(function()
    local blips = {}

    while true do
        for _, blip in pairs(blips) do
            RemoveBlip(blip)
        end

        blips = {}

        while blipsEnabled do
            for _, blip in pairs(blips) do
                RemoveBlip(blip)
            end

            blips = {}

            for _, player in ipairs(GetActivePlayers()) do
                local ped = GetPlayerPed(player)
                local playerId = GetPlayerServerId(player)
                local blip = AddBlipForEntity(ped)

                SetBlipSprite(blip, 1)
                SetBlipColour(blip, 0)
                SetBlipScale(blip, 0.85)
                ShowHeadingIndicatorOnBlip(blip, true)

                table.insert(blips, blip)

                BeginTextCommandSetBlipName("STRING")
                AddTextComponentString("ID: " .. playerId .. " | " .. GetPlayerName(player))
                EndTextCommandSetBlipName(blip)
            end
            Citizen.Wait(500)
        end
        Citizen.Wait(1000)
    end
end)

function Draw3DText(x, y, z, scl_factor, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local p = GetGameplayCamCoords()
    local distance = GetDistanceBetweenCoords(p.x, p.y, p.z, x, y, z, 1)
    local scale = (1 / distance) * 2
    local fov = (1 / GetGameplayCamFov()) * 100
    local scale = scale * fov * scl_factor

    if onScreen then
        SetTextScale(0.0, scale)
        SetTextFont(0)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end