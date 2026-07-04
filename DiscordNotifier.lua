-- ============================================================================
-- DISCORD NOTIFIER - Notifications via Webhook Discord
-- Envoi de notifications sur Discord pendant la récupération
-- ============================================================================

local DiscordNotifier = {}

-- ============================================================================
-- CONFIGURATION
-- ============================================================================

DiscordNotifier.Config = {
    WebhookURL = "", -- À configurer
    Username = "Tower Battles Recovery",
    AvatarURL = "",
    EnableNotifications = true,
    NotifyOnPhaseStart = true,
    NotifyOnPhaseComplete = true,
    NotifyOnErrors = true,
    NotifyOnSuccess = true
}

-- ============================================================================
-- ENVOI DE NOTIFICATIONS
-- ============================================================================

DiscordNotifier.Sender = {
    -- Envoyer une notification Discord
    SendNotification = function(title, description, color, fields, footer)
        if not DiscordNotifier.Config.EnableNotifications then
            return {Success = false, Reason = "Notifications disabled"}
        end
        
        if DiscordNotifier.Config.WebhookURL == "" then
            return {Success = false, Reason = "Webhook URL not configured"}
        end
        
        local httpService = game:GetService("HttpService")
        
        -- Construire l'embed
        local embed = {
            title = title,
            description = description,
            color = color or 3447003, -- Bleu par défaut
            fields = fields or {},
            footer = footer or {
                text = "Tower Battles Recovery System",
                icon_url = ""
            },
            timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }
        
        -- Construire le payload
        local payload = {
            username = DiscordNotifier.Config.Username,
            avatar_url = DiscordNotifier.Config.AvatarURL,
            embeds = {embed}
        }
        
        -- Envoyer le webhook
        local success, response = pcall(function()
            return httpService:RequestAsync({
                Url = DiscordNotifier.Config.WebhookURL,
                Method = "POST",
                Headers = {
                    ["Content-Type"] = "application/json"
                },
                Body = httpService:JSONEncode(payload)
            })
        end)
        
        if not success then
            return {Success = false, Reason = response}
        end
        
        if response.StatusCode ~= 204 then
            return {Success = false, Reason = "HTTP " .. response.StatusCode}
        end
        
        return {Success = true}
    end,
    
    -- Notification de démarrage
    SendStartNotification = function()
        local fields = {
            {name = "Game", value = "Tower Battles", inline = true},
            {name = "PlaceId", value = tostring(game.PlaceId), inline = true},
            {name = "Player", value = game.Players.LocalPlayer.Name, inline = true},
            {name = "Mode", value = "Full Recovery", inline = true}
        }
        
        return DiscordNotifier.Sender.SendNotification(
            "🚀 Récupération Démarrée",
            "Le système de récupération complète a été démarré.",
            3447003, -- Bleu
            fields
        )
    end,
    
    -- Notification de phase
    SendPhaseNotification = function(phaseName, phaseNumber, totalPhases, status)
        local statusEmoji = status == "START" and "▶️" or "✅"
        local color = status == "START" and 16776960 or 50256 -- Orange ou Vert
        
        local fields = {
            {name = "Phase", value = phaseName, inline = true},
            {name = "Progression", value = string.format("%d/%d", phaseNumber, totalPhases), inline = true},
            {name = "Statut", value = status, inline = true}
        }
        
        return DiscordNotifier.Sender.SendNotification(
            string.format("%s Phase: %s", statusEmoji, phaseName),
            string.format("Phase %d sur %d: %s", phaseNumber, totalPhases, phaseName),
            color,
            fields
        )
    end,
    
    -- Notification d'erreur
    SendErrorNotification = function(phase, error)
        local fields = {
            {name = "Phase", value = phase, inline = true},
            {name = "Erreur", value = tostring(error), inline = false}
        }
        
        return DiscordNotifier.Sender.SendNotification(
            "❌ Erreur Détectée",
            string.format("Une erreur s'est produite pendant la phase: %s", phase),
            16711680, -- Rouge
            fields
        )
    end,
    
    -- Notification de succès
    SendSuccessNotification = function(duration, outputFolder)
        local fields = {
            {name = "Durée", value = string.format("%.2f secondes", duration), inline = true},
            {name = "Dossier", value = outputFolder, inline = true},
            {name = "Statut", value = "Terminé avec succès", inline = true}
        }
        
        return DiscordNotifier.Sender.SendNotification(
            "✅ Récupération Terminée",
            "La récupération complète s'est terminée avec succès.",
            50256, -- Vert
            fields
        )
    end,
    
    -- Notification de backdoor détecté
    SendBackdoorNotification = function(backdoorCount, exploitCount)
        local color = backdoorCount > 0 and 16711680 or 16776960 -- Rouge ou Orange
        
        local fields = {
            {name = "Backdoors", value = tostring(backdoorCount), inline = true},
            {name = "Exploits", value = tostring(exploitCount), inline = true},
            {name = "Niveau de risque", value = backdoorCount > 0 and "Élevé" or "Moyen", inline = true}
        }
        
        return DiscordNotifier.Sender.SendNotification(
            "⚠️ Vulnérabilités Détectées",
            string.format("%d backdoors et %d exploits potentiels détectés", backdoorCount, exploitCount),
            color,
            fields
        )
    end,
    
    -- Notification de copie directe
    SendDirectCopyNotification = function(success, method, outputFile)
        local emoji = success and "✅" or "❌"
        local color = success and 50256 or 16711680
        
        local fields = {
            {name = "Méthode", value = method or "N/A", inline = true},
            {name = "Succès", value = tostring(success), inline = true}
        }
        
        if success and outputFile then
            table.insert(fields, {name = "Fichier", value = outputFile, inline = false})
        end
        
        return DiscordNotifier.Sender.SendNotification(
            string.format("%s Copie Directe", emoji),
            success and "La copie directe a réussi" or "La copie directe a échoué",
            color,
            fields
        )
    end,
    
    -- Notification de privilèges
    SendPrivilegeNotification = function(adminAccess, modAccess, ownerAccess, escalationMethods)
        local fields = {
            {name = "Admin Access", value = adminAccess and "✅" or "❌", inline = true},
            {name = "Mod Access", value = modAccess and "✅" or "❌", inline = true},
            {name = "Owner Access", value = ownerAccess and "✅" or "❌", inline = true},
            {name = "Méthodes d'élévation", value = tostring(escalationMethods), inline = true}
        }
        
        local hasAccess = adminAccess or modAccess or ownerAccess
        local color = hasAccess and 50256 or 16776960
        
        return DiscordNotifier.Sender.SendNotification(
            hasAccess and "🔑 Privilèges Détectés" or "🔒 Aucun Privilège",
            hasAccess and "Des privilèges ont été détectés" : "Aucun privilège détecté",
            color,
            fields
        )
    end
}

-- ============================================================================
-- CONFIGURATION
-- ============================================================================

function DiscordNotifier.Configure(config)
    if config.WebhookURL then
        DiscordNotifier.Config.WebhookURL = config.WebhookURL
    end
    if config.Username then
        DiscordNotifier.Config.Username = config.Username
    end
    if config.AvatarURL then
        DiscordNotifier.Config.AvatarURL = config.AvatarURL
    end
    if config.EnableNotifications ~= nil then
        DiscordNotifier.Config.EnableNotifications = config.EnableNotifications
    end
    if config.NotifyOnPhaseStart ~= nil then
        DiscordNotifier.Config.NotifyOnPhaseStart = config.NotifyOnPhaseStart
    end
    if config.NotifyOnPhaseComplete ~= nil then
        DiscordNotifier.Config.NotifyOnPhaseComplete = config.NotifyOnPhaseComplete
    end
    if config.NotifyOnErrors ~= nil then
        DiscordNotifier.Config.NotifyOnErrors = config.NotifyOnErrors
    end
    if config.NotifyOnSuccess ~= nil then
        DiscordNotifier.Config.NotifyOnSuccess = config.NotifyOnSuccess
    end
    
    print("[DISCORD] Configuration mise à jour")
    print(string.format("[DISCORD] Notifications: %s", DiscordNotifier.Config.EnableNotifications and "Activées" or "Désactivées"))
end

-- ============================================================================
-- WRAPPER POUR NOTIFICATIONS AUTOMATIQUES
-- ============================================================================

DiscordNotifier.AutoNotifier = {
    -- Notifier le démarrage
    NotifyStart = function()
        if DiscordNotifier.Config.NotifyOnSuccess then
            return DiscordNotifier.Sender.SendStartNotification()
        end
        return {Success = false, Reason = "Start notification disabled"}
    end,
    
    -- Notifier le début d'une phase
    NotifyPhaseStart = function(phaseName, phaseNumber, totalPhases)
        if DiscordNotifier.Config.NotifyOnPhaseStart then
            return DiscordNotifier.Sender.SendPhaseNotification(phaseName, phaseNumber, totalPhases, "START")
        end
        return {Success = false, Reason = "Phase start notification disabled"}
    end,
    
    -- Notifier la fin d'une phase
    NotifyPhaseComplete = function(phaseName, phaseNumber, totalPhases)
        if DiscordNotifier.Config.NotifyOnPhaseComplete then
            return DiscordNotifier.Sender.SendPhaseNotification(phaseName, phaseNumber, totalPhases, "COMPLETE")
        end
        return {Success = false, Reason = "Phase complete notification disabled"}
    end,
    
    -- Notifier une erreur
    NotifyError = function(phase, error)
        if DiscordNotifier.Config.NotifyOnErrors then
            return DiscordNotifier.Sender.SendErrorNotification(phase, error)
        end
        return {Success = false, Reason = "Error notification disabled"}
    end,
    
    -- Notifier le succès
    NotifySuccess = function(duration, outputFolder)
        if DiscordNotifier.Config.NotifyOnSuccess then
            return DiscordNotifier.Sender.SendSuccessNotification(duration, outputFolder)
        end
        return {Success = false, Reason = "Success notification disabled"}
    end,
    
    -- Notifier les backdoors
    NotifyBackdoors = function(backdoorCount, exploitCount)
        if DiscordNotifier.Config.NotifyOnErrors then
            return DiscordNotifier.Sender.SendBackdoorNotification(backdoorCount, exploitCount)
        end
        return {Success = false, Reason = "Backdoor notification disabled"}
    end,
    
    -- Notifier la copie directe
    NotifyDirectCopy = function(success, method, outputFile)
        if DiscordNotifier.Config.NotifyOnSuccess then
            return DiscordNotifier.Sender.SendDirectCopyNotification(success, method, outputFile)
        end
        return {Success = false, Reason = "Direct copy notification disabled"}
    end,
    
    -- Notifier les privilèges
    NotifyPrivileges = function(adminAccess, modAccess, ownerAccess, escalationMethods)
        if DiscordNotifier.Config.NotifyOnSuccess then
            return DiscordNotifier.Sender.SendPrivilegeNotification(adminAccess, modAccess, ownerAccess, escalationMethods)
        end
        return {Success = false, Reason = "Privilege notification disabled"}
    end
}

return DiscordNotifier
