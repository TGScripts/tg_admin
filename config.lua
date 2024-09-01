Config = {}

Config.Debug                =   false                           -- Debug Modus aktivieren / deaktivieren

-- Ticketsystem
Config.SupportEnabled       =   true                            -- Ingame Ticketsystem aktivieren / deaktivieren
Config.SupportCommand       =   "support"                       -- Command um ein Ingame Ticket zu eröffnen
Config.SupportGroups        =   {"owner", "admin"}              -- Rechtegruppen (aus der cfg) welche Tickets erhalten und Zugriff haben
Config.MenuCommand          =   "tickets"                       -- Command um das Ticket Menu zu öffnen
Config.MenuDefaultKey       =   'F5'                            -- Standard Key um das Ticket Menu zu öffnen

-- Admin Modus
Config.AdminCommand         =   "admin"                         -- Command um den Admin Modus zu aktivieren / deaktivieren
Config.AdminGroups          =   {"owner", "admin"}              -- Rechtegruppen (aus der cfg) welche den Command nutzen dürfen
Config.EnableGodMode        =   true                            -- Godmode Command aktivieren / deaktivieren
Config.EnableNames          =   true                            -- Names Command aktivieren / deaktivieren
Config.EnableBlips          =   true                            -- Blips Command aktivieren / deaktivieren
Config.GodModeCommand       =   "godmode"                       -- Command um den Godmode zu aktivieren
Config.NameCommand          =   "names"                         -- Command um die Spieler Namen über Kopf anzuzeigen (Names)
Config.BlipCommand          =   "blips"                         -- Command um alle Spieler Blips anzuzeigen
Config.EnableClothing       =   true                            -- Admin Kleidung anziehen wenn man den Command benutzt aktivieren / deaktivieren
Config.AdminClothing        =   {                               -- Konfiguration der Admin Kleidung

    ['tshirt_1']    =   15,     -- T-Shirt 1
    ['tshirt_2']    =   0,      -- T-Shirt 2 (Veriante)
    ['torso_1']     =   15,     -- Oberteil 1
    ['torso_2']     =   0,      -- Oberteil 2 (Veriante)
    ['arms']        =   15,     -- Arme
    ['pants_1']     =   61,     -- Hose 1
    ['pants_2']     =   0,      -- Hose 2 (Veriante)
    ['shoes_1']     =   34,     -- Schuhe 1
    ['shoes_2']     =   0,      -- Schuhe 2 (Veriante)
    ['helmet_1']    =   -1,     -- Helm 1
    ['helmet_2']    =   0,      -- Helm 2 (Veriante)

}