-- ============================================================================
-- TOWER BATTLES EXTRACTOR - AUTO RUN
-- Script de lancement automatique pour GitHub
-- ============================================================================

print("==========================================")
print("TOWER BATTLES EXTRACTOR - AUTO RUN")
print("==========================================")

-- ============================================================================
-- VARIABLES DE PARAMÈTRES (À DÉFINIR AVANT L'EXÉCUTION)
-- ============================================================================

-- Définir ces variables avant d'exécuter le script pour personnaliser
_G.TowerBattlesExtractorConfig = _G.TowerBattlesExtractorConfig or {}

-- Modules de récupération
_G.TowerBattlesExtractorConfig.UseDeepScan = _G.TowerBattlesExtractorConfig.UseDeepScan or true
_G.TowerBattlesExtractorConfig.UseScriptDecryptor = _G.TowerBattlesExtractorConfig.UseScriptDecryptor or true
_G.TowerBattlesExtractorConfig.UseScriptAnalyzer = _G.TowerBattlesExtractorConfig.UseScriptAnalyzer or true
_G.TowerBattlesExtractorConfig.UseScriptReconstructor = _G.TowerBattlesExtractorConfig.UseScriptReconstructor or true
_G.TowerBattlesExtractorConfig.UseScriptRepairer = _G.TowerBattlesExtractorConfig.UseScriptRepairer or true
_G.TowerBattlesExtractorConfig.UseMapExtractor = _G.TowerBattlesExtractorConfig.UseMapExtractor or true
_G.TowerBattlesExtractorConfig.UseAssetRecovery = _G.TowerBattlesExtractorConfig.UseAssetRecovery or true
_G.TowerBattlesExtractorConfig.UseExternalAPI = _G.TowerBattlesExtractorConfig.UseExternalAPI or false

-- Security modules
_G.TowerBattlesExtractorConfig.UseVulnerabilityScanner = _G.TowerBattlesExtractorConfig.UseVulnerabilityScanner or true
_G.TowerBattlesExtractorConfig.UseBackdoorScanner = _G.TowerBattlesExtractorConfig.UseBackdoorScanner or true
_G.TowerBattlesExtractorConfig.UseExploitScanner = _G.TowerBattlesExtractorConfig.UseExploitScanner or true
_G.TowerBattlesExtractorConfig.UsePrivilegeEscalation = _G.TowerBattlesExtractorConfig.UsePrivilegeEscalation or true
_G.TowerBattlesExtractorConfig.UseDirectCopy = _G.TowerBattlesExtractorConfig.UseDirectCopy or false -- DANGEREUX

-- Discord Webhook
_G.TowerBattlesExtractorConfig.UseDiscordNotifier = _G.TowerBattlesExtractorConfig.UseDiscordNotifier or false
_G.TowerBattlesExtractorConfig.DiscordWebhookURL = _G.TowerBattlesExtractorConfig.DiscordWebhookURL or ""

-- External API Configuration
_G.TowerBattlesExtractorConfig.ExternalAPIConfig = _G.TowerBattlesExtractorConfig.ExternalAPIConfig or nil

-- Export
_G.TowerBattlesExtractorConfig.ExportFormat = _G.TowerBattlesExtractorConfig.ExportFormat or "JSON"
_G.TowerBattlesExtractorConfig.OutputPath = _G.TowerBattlesExtractorConfig.OutputPath or "TowerBattles_FullRecovery"

-- ============================================================================
-- FONCTION DE LANCEMENT
-- ============================================================================

function RunTowerBattlesExtractor(config)
    config = config or _G.TowerBattlesExtractorConfig
    
    print("==========================================")
    print("CONFIGURATION")
    print("==========================================")
    print(string.format("UseDeepScan: %s", tostring(config.UseDeepScan)))
    print(string.format("UseScriptDecryptor: %s", tostring(config.UseScriptDecryptor)))
    print(string.format("UseScriptAnalyzer: %s", tostring(config.UseScriptAnalyzer)))
    print(string.format("UseScriptReconstructor: %s", tostring(config.UseScriptReconstructor)))
    print(string.format("UseScriptRepairer: %s", tostring(config.UseScriptRepairer)))
    print(string.format("UseMapExtractor: %s", tostring(config.UseMapExtractor)))
    print(string.format("UseAssetRecovery: %s", tostring(config.UseAssetRecovery)))
    print(string.format("UseExternalAPI: %s", tostring(config.UseExternalAPI)))
    print(string.format("UseVulnerabilityScanner: %s", tostring(config.UseVulnerabilityScanner)))
    print(string.format("UseBackdoorScanner: %s", tostring(config.UseBackdoorScanner)))
    print(string.format("UseExploitScanner: %s", tostring(config.UseExploitScanner)))
    print(string.format("UsePrivilegeEscalation: %s", tostring(config.UsePrivilegeEscalation)))
    print(string.format("UseDirectCopy: %s", tostring(config.UseDirectCopy)))
    print(string.format("UseDiscordNotifier: %s", tostring(config.UseDiscordNotifier)))
    print(string.format("DiscordWebhookURL: %s", config.DiscordWebhookURL ~= "" and "OUI" or "NON"))
    print("==========================================")
    
    local success = pcall(function()
        -- Charger FullRecovery
        local FullRecovery = loadstring(readfile("TowerBattlesExtractor/FullRecovery.lua"))()
        
        -- Configurer
        FullRecovery.ConfigureFullRecovery(config)
        
        -- Démarrer
        FullRecovery.RunFullRecovery()
    end)
    
    if not success then
        print("==========================================")
        print("ERREUR - ÉCHEC DU LANCEMENT")
        print("==========================================")
        print("Vérifiez que tous les fichiers sont présents dans le dossier TowerBattlesExtractor/")
        print("==========================================")
    end
end

-- ============================================================================
-- INSTRUCTIONS D'UTILISATION
-- ============================================================================

print("==========================================")
print("INSTRUCTIONS")
print("==========================================")
print("Pour lancer avec la configuration par défaut:")
print("  RunTowerBattlesExtractor()")
print("")
print("Pour personnaliser avant l'exécution:")
print("  _G.TowerBattlesExtractorConfig.DiscordWebhookURL = \"YOUR_WEBHOOK_URL\"")
print("  _G.TowerBattlesExtractorConfig.UseDirectCopy = true")
print("  RunTowerBattlesExtractor()")
print("")
print("Ou passer une config directement:")
print("  RunTowerBattlesExtractor({")
print("    DiscordWebhookURL = \"YOUR_WEBHOOK_URL\",")
print("    UseDirectCopy = true")
print("  })")
print("==========================================")

-- Lancement automatique (commenté pour permettre configuration)
-- RunTowerBattlesExtractor()
