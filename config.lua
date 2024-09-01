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
Config.AdminClothing_M      =   {                               -- Konfiguration der Admin Kleidung (Männlich)

    ['tshirt_1']    =   28,     -- T-Shirt 1
    ['tshirt_2']    =   2,      -- T-Shirt 2 (Veriante)
    ['torso_1']     =   72,     -- Oberteil 1
    ['torso_2']     =   2,      -- Oberteil 2 (Veriante)
    ['arms']        =   4,      -- Arme
    ['pants_1']     =   25,     -- Hose 1
    ['pants_2']     =   0,      -- Hose 2 (Veriante)
    ['shoes_1']     =   25,     -- Schuhe 1
    ['shoes_2']     =   0,      -- Schuhe 2 (Veriante)
    ['mask_1']      =   2,      -- Maske 1
    ['mask_2']      =   3,      -- Maske 2 (Veriante)
    ['helmet_1']    =   -1,     -- Helm 1
    ['helmet_2']    =   0,      -- Helm 2 (Veriante)
    ['chain_1']     =   18,     -- Kette 1
    ['chain_2']     =   0,      -- Kette 2 (Veriante)
    ['glasses_1']   =   24,     -- Brille 1
    ['glasses_2']   =   2,      -- Brille 2 (Veriante)

}

Config.AdminClothing_F      =   {                               -- Konfiguration der Admin Kleidung (Weiblich)

    ['tshirt_1']    =   28,     -- T-Shirt 1
    ['tshirt_2']    =   2,      -- T-Shirt 2 (Veriante)
    ['torso_1']     =   169,    -- Oberteil 1
    ['torso_2']     =   0,      -- Oberteil 2 (Veriante)
    ['arms']        =   15,     -- Arme
    ['pants_1']     =   12,     -- Hose 1
    ['pants_2']     =   7,      -- Hose 2 (Veriante)
    ['shoes_1']     =   8,      -- Schuhe 1
    ['shoes_2']     =   3,      -- Schuhe 2 (Veriante)
    ['mask_1']      =   2,      -- Maske 1
    ['mask_2']      =   3,      -- Maske 2 (Veriante)
    ['helmet_1']    =   -1,     -- Helm 1
    ['helmet_2']    =   0,      -- Helm 2 (Veriante)
    ['chain_1']     =   -1,     -- Kette 1
    ['chain_2']     =   0,      -- Kette 2 (Veriante)
    ['glasses_1']   =   24,     -- Brille 1
    ['glasses_2']   =   2,      -- Brille 2 (Veriante)

}