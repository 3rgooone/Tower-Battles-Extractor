-- ============================================================================
-- TOWER BATTLES FULL RECOVERY SYSTEM
-- Complete 100% game recovery - Scripts, Map, Assets, Hidden parts
-- Version 1.0
-- ============================================================================

print("==========================================")
print("TOWER BATTLES FULL RECOVERY SYSTEM")
print("Version 1.0 - Complete Recovery")
print("==========================================")

-- ============================================================================
-- MODULE LOADING
-- ============================================================================

local HttpService = game:GetService("HttpService")

-- Global recovery state
_G.FullRecoveryState = _G.FullRecoveryState or {
    StartTime = tick(),
    CurrentPhase = "INITIALIZATION",
    Progress = 0,
    
    -- Results
    DeepScanResults = nil,
    ScriptDecryptResults = nil,
    ScriptAnalysisResults = nil,
    ScriptReconstructionResults = nil,
    ScriptRepairResults = nil,
    MapExtractionResults = nil,
    AssetRecoveryResults = nil,
    ExternalAPIAnalysisResults = nil,
    VulnerabilityScanResults = nil,
    BackdoorScanResults = nil,
    ExploitScanResults = nil,
    PrivilegeEscalationResults = nil,
    DirectCopyResults = nil,
    
    -- Configuration
    Config = {
        UseDeepScan = true,
        UseScriptDecryptor = true,
        UseScriptAnalyzer = true,
        UseScriptReconstructor = true,
        UseScriptRepairer = true,
        UseMapExtractor = true,
        UseAssetRecovery = true,
        UseExternalAPI = false, -- Requires API key
        UseVulnerabilityScanner = true,
        UseBackdoorScanner = true,
        UseExploitScanner = true,
        UsePrivilegeEscalation = true,
        UseDirectCopy = false, -- Dangerous, disabled by default
        UseDiscordNotifier = false, -- Discord webhook
        ExportFormat = "JSON",
        OutputPath = "TowerBattles_FullRecovery",
        DiscordWebhookURL = "" -- Discord webhook URL
    }
}

-- ============================================================================
-- MODULE LOADING WITH FALLBACKS
-- ============================================================================

local DeepScanner = nil
local ScriptDecryptor = nil
local ScriptAnalyzer = nil
local ScriptReconstructor = nil
local ScriptRepairer = nil
local MapExtractor = nil
local AssetRecovery = nil
local ExternalAPIIntegration = nil

-- Create folders
if makefolder then
    makefolder(_G.FullRecoveryState.Config.OutputPath)
end

-- Charger DeepScanner
local successDeepScanner = pcall(function()
    return loadstring(readfile("TowerBattlesExtractor/DeepScanner.lua"))()
end)

if successDeepScanner then
    DeepScanner = successDeepScanner
    print("[SYSTEM] DeepScanner chargé ✓")
else
    print("[SYSTEM] DeepScanner non disponible (fichier introuvable)")
    DeepScanner = {
        RunFullScan = function()
            return {Available = false, Reason = "Module not loaded"}
        end
    }
end

-- Charger ScriptDecryptor
local successScriptDecryptor = pcall(function()
    return loadstring(readfile("TowerBattlesExtractor/ScriptDecryptor.lua"))()
end)

if successScriptDecryptor then
    ScriptDecryptor = successScriptDecryptor
    print("[SYSTEM] ScriptDecryptor chargé ✓")
else
    print("[SYSTEM] ScriptDecryptor non disponible")
    ScriptDecryptor = {
        ScanAllScripts = function()
            return {Available = false, Reason = "Module not loaded"}
        end
    }
end

-- Charger ScriptAnalyzer
local successScriptAnalyzer = pcall(function()
    return loadstring(readfile("TowerBattlesExtractor/ScriptAnalyzer.lua"))()
end)

if successScriptAnalyzer then
    ScriptAnalyzer = successScriptAnalyzer
    print("[SYSTEM] ScriptAnalyzer chargé ✓")
else
    print("[SYSTEM] ScriptAnalyzer non disponible")
    ScriptAnalyzer = {
        AnalyzeAllScripts = function()
            return {Available = false, Reason = "Module not loaded"}
        end
    }
end

-- Charger ScriptReconstructor
local successScriptReconstructor = pcall(function()
    return loadstring(readfile("TowerBattlesExtractor/ScriptReconstructor.lua"))()
end)

if successScriptReconstructor then
    ScriptReconstructor = successScriptReconstructor
    print("[SYSTEM] ScriptReconstructor chargé ✓")
else
    print("[SYSTEM] ScriptReconstructor non disponible")
    ScriptReconstructor = {
        ReconstructAllScripts = function()
            return {Available = false, Reason = "Module not loaded"}
        end
    }
end

-- Charger ScriptRepairer
local successScriptRepairer = pcall(function()
    return loadstring(readfile("TowerBattlesExtractor/ScriptRepairer.lua"))()
end)

if successScriptRepairer then
    ScriptRepairer = successScriptRepairer
    print("[SYSTEM] ScriptRepairer chargé ✓")
else
    print("[SYSTEM] ScriptRepairer non disponible")
    ScriptRepairer = {
        RepairAllScripts = function()
            return {Available = false, Reason = "Module not loaded"}
        end
    }
end

-- Charger MapExtractor
local successMapExtractor = pcall(function()
    return loadstring(readfile("TowerBattlesExtractor/MapExtractor.lua"))()
end)

if successMapExtractor then
    MapExtractor = successMapExtractor
    print("[SYSTEM] MapExtractor chargé ✓")
else
    print("[SYSTEM] MapExtractor non disponible")
    MapExtractor = {
        ExtractFullMap = function()
            return {Available = false, Reason = "Module not loaded"}
        end
    }
end

-- Charger AssetRecovery
local successAssetRecovery = pcall(function()
    return loadstring(readfile("TowerBattlesExtractor/AssetRecovery.lua"))()
end)

if successAssetRecovery then
    AssetRecovery = successAssetRecovery
    print("[SYSTEM] AssetRecovery chargé ✓")
else
    print("[SYSTEM] AssetRecovery non disponible")
    AssetRecovery = {
        RecoverAllAssets = function()
            return {Available = false, Reason = "Module not loaded"}
        end
    }
end

-- Load ExternalAPIIntegration
local successExternalAPIIntegration = pcall(function()
    return loadstring(readfile("TowerBattlesExtractor/LLMIntegration.lua"))()
end)

if successExternalAPIIntegration then
    ExternalAPIIntegration = successExternalAPIIntegration
    print("[SYSTEM] ExternalAPIIntegration loaded ✓")
else
    print("[SYSTEM] ExternalAPIIntegration not available")
    ExternalAPIIntegration = {
        Configure = function() end,
        BatchAnalyzer = {
            AnalyzeBatch = function()
                return {Available = false, Reason = "Module not loaded"}
            end
        }
    }
end

-- Charger VulnerabilityScanner
local successVulnerabilityScanner = pcall(function()
    return loadstring(readfile("TowerBattlesExtractor/VulnerabilityScanner.lua"))()
end)

if successVulnerabilityScanner then
    VulnerabilityScanner = successVulnerabilityScanner
    print("[SYSTEM] VulnerabilityScanner chargé ✓")
else
    print("[SYSTEM] VulnerabilityScanner non disponible")
    VulnerabilityScanner = {
        RunFullVulnerabilityScan = function()
            return {Available = false, Reason = "Module not loaded"}
        end
    }
end

-- Charger BackdoorScanner
local successBackdoorScanner = pcall(function()
    return loadstring(readfile("TowerBattlesExtractor/BackdoorScanner.lua"))()
end)

if successBackdoorScanner then
    BackdoorScanner = successBackdoorScanner
    print("[SYSTEM] BackdoorScanner chargé ✓")
else
    print("[SYSTEM] BackdoorScanner non disponible")
    BackdoorScanner = {
        RunFullBackdoorScan = function()
            return {Available = false, Reason = "Module not loaded"}
        end
    }
end

-- Charger ExploitScanner
local successExploitScanner = pcall(function()
    return loadstring(readfile("TowerBattlesExtractor/ExploitScanner.lua"))()
end)

if successExploitScanner then
    ExploitScanner = successExploitScanner
    print("[SYSTEM] ExploitScanner chargé ✓")
else
    print("[SYSTEM] ExploitScanner non disponible")
    ExploitScanner = {
        RunFullExploitScan = function()
            return {Available = false, Reason = "Module not loaded"}
        end
    }
end

-- Charger PrivilegeEscalation
local successPrivilegeEscalation = pcall(function()
    return loadstring(readfile("TowerBattlesExtractor/PrivilegeEscalation.lua"))()
end)

if successPrivilegeEscalation then
    PrivilegeEscalation = successPrivilegeEscalation
    print("[SYSTEM] PrivilegeEscalation chargé ✓")
else
    print("[SYSTEM] PrivilegeEscalation non disponible")
    PrivilegeEscalation = {
        RunFullPrivilegeEscalationScan = function()
            return {Available = false, Reason = "Module not loaded"}
        end
    }
end

-- Charger DirectCopy
local successDirectCopy = pcall(function()
    return loadstring(readfile("TowerBattlesExtractor/DirectCopy.lua"))()
end)

if successDirectCopy then
    DirectCopy = successDirectCopy
    print("[SYSTEM] DirectCopy chargé ✓")
else
    print("[SYSTEM] DirectCopy non disponible")
    DirectCopy = {
        AttemptDirectCopy = function()
            return {Available = false, Reason = "Module not loaded"}
        end
    }
end

-- Charger DiscordNotifier
local successDiscordNotifier = pcall(function()
    return loadstring(readfile("TowerBattlesExtractor/DiscordNotifier.lua"))()
end)

if successDiscordNotifier then
    DiscordNotifier = successDiscordNotifier
    print("[SYSTEM] DiscordNotifier chargé ✓")
else
    print("[SYSTEM] DiscordNotifier non disponible")
    DiscordNotifier = {
        Configure = function() end,
        AutoNotifier = {
            NotifyStart = function() return {Success = false} end,
            NotifyPhaseStart = function() return {Success = false} end,
            NotifyPhaseComplete = function() return {Success = false} end,
            NotifyError = function() return {Success = false} end,
            NotifySuccess = function() return {Success = false} end,
            NotifyBackdoors = function() return {Success = false} end,
            NotifyDirectCopy = function() return {Success = false} end,
            NotifyPrivileges = function() return {Success = false} end
        }
    }
end

-- ============================================================================
-- EXPORTATION DES DONNÉES
-- ============================================================================

local DataExporter = {
    ExportJSON = function(data, filename)
        if not writefile then
            print("[EXPORT] writefile non disponible")
            return false
        end
        
        local success, json = pcall(function()
            return HttpService:JSONEncode(data)
        end)
        
        if not success then
            print("[EXPORT] Erreur encodage JSON")
            return false
        end
        
        local filepath = _G.FullRecoveryState.Config.OutputPath .. "/" .. filename
        
        local writeSuccess = pcall(function()
            writefile(filepath, json)
        end)
        
        if writeSuccess then
            print(string.format("[EXPORT] Exporté: %s", filepath))
            return true
        else
            print(string.format("[EXPORT] Erreur écriture: %s", filepath))
            return false
        end
    end,
    
    ExportLuaTable = function(data, filename)
        if not writefile then
            print("[EXPORT] writefile non disponible")
            return false
        end
        
        local filepath = _G.FullRecoveryState.Config.OutputPath .. "/" .. filename
        
        local luaCode = "return " .. DataExporter.TableToString(data, 0)
        
        local writeSuccess = pcall(function()
            writefile(filepath, luaCode)
        end)
        
        if writeSuccess then
            print(string.format("[EXPORT] Exporté: %s", filepath))
            return true
        else
            print(string.format("[EXPORT] Erreur écriture: %s", filepath))
            return false
        end
    end,
    
    TableToString = function(tbl, indent)
        indent = indent or 0
        local str = "{\n"
        
        for k, v in pairs(tbl) do
            str = str .. string.rep("    ", indent + 1)
            
            if type(k) == "string" then
                str = str .. k .. " = "
            else
                str = str .. "[" .. tostring(k) .. "] = "
            end
            
            if type(v) == "table" then
                str = str .. DataExporter.TableToString(v, indent + 1) .. ",\n"
            elseif type(v) == "string" then
                str = str .. "\"" .. v .. "\",\n"
            elseif type(v) == "boolean" then
                str = str .. tostring(v) .. ",\n"
            else
                str = str .. tostring(v) .. ",\n"
            end
        end
        
        str = str .. string.rep("    ", indent) .. "}"
        return str
    end
}

-- ============================================================================
-- PHASE 1: DEEP SCAN
-- ============================================================================

local function RunDeepScan()
    print("==========================================")
    print("PHASE 1: DEEP SCAN")
    print("==========================================")
    
    _G.FullRecoveryState.CurrentPhase = "DEEP_SCAN"
    _G.FullRecoveryState.Progress = 10
    
    -- Notification Discord
    DiscordNotifier.AutoNotifier.NotifyPhaseStart("Deep Scan", 1, 14)
    
    local results = DeepScanner.RunFullScan()
    _G.FullRecoveryState.DeepScanResults = results
    
    -- Exporter les résultats
    DataExporter.ExportJSON(results, "DeepScan_Results.json")
    
    print(string.format("[DEEP_SCAN] Tables GC: %d", results.GCScan and results.GCScan.TotalTables or 0))
    print(string.format("[DEEP_SCAN] Scripts cachés: %d", results.HiddenScripts and #results.HiddenScripts.HiddenScripts or 0))
    print(string.format("[DEEP_SCAN] Assets cachés: %d", results.HiddenAssets and #results.HiddenAssets.HiddenAssets or 0))
    print(string.format("[DEEP_SCAN] Propriétés cachées: %d", results.HiddenProperties and results.HiddenProperties.TotalHiddenProperties or 0))
    
    _G.FullRecoveryState.Progress = 20
    
    -- Notification Discord
    DiscordNotifier.AutoNotifier.NotifyPhaseComplete("Deep Scan", 1, 14)
    
    return results
end

-- ============================================================================
-- PHASE 2: SCRIPT DECRYPTOR
-- ============================================================================

local function RunScriptDecryptor()
    print("==========================================")
    print("PHASE 2: SCRIPT DECRYPTOR")
    print("==========================================")
    
    _G.FullRecoveryState.CurrentPhase = "SCRIPT_DECRYPTOR"
    _G.FullRecoveryState.Progress = 25
    
    local results = ScriptDecryptor.ScanAllScripts()
    _G.FullRecoveryState.ScriptDecryptResults = results
    
    -- Exporter les résultats
    DataExporter.ExportJSON(results, "ScriptDecrypt_Results.json")
    
    print(string.format("[SCRIPT_DECRYPTOR] Scripts analysés: %d", results.Summary.TotalScripts))
    print(string.format("[SCRIPT_DECRYPTOR] Scripts encryptés: %d", results.Summary.EncryptedScripts))
    print(string.format("[SCRIPT_DECRYPTOR] Scripts décryptés: %d", results.Summary.DecryptedScripts))
    
    _G.FullRecoveryState.Progress = 35
    
    return results
end

-- ============================================================================
-- PHASE 3: SCRIPT ANALYZER
-- ============================================================================

local function RunScriptAnalyzer()
    print("==========================================")
    print("PHASE 3: SCRIPT ANALYZER")
    print("==========================================")
    
    _G.FullRecoveryState.CurrentPhase = "SCRIPT_ANALYZER"
    _G.FullRecoveryState.Progress = 40
    
    local results = ScriptAnalyzer.AnalyzeAllScripts()
    _G.FullRecoveryState.ScriptAnalysisResults = results
    
    -- Exporter les résultats
    DataExporter.ExportJSON(results, "ScriptAnalysis_Results.json")
    
    print(string.format("[SCRIPT_ANALYZER] Scripts analysés: %d", results.Summary.TotalScripts))
    print(string.format("[SCRIPT_ANALYZER] Catégories:"))
    for category, count in pairs(results.Summary.ByCategory) do
        print(string.format("  - %s: %d", category, count))
    end
    
    _G.FullRecoveryState.Progress = 50
    
    return results
end

-- ============================================================================
-- PHASE 4: SCRIPT RECONSTRUCTOR
-- ============================================================================

local function RunScriptReconstructor()
    print("==========================================")
    print("PHASE 4: SCRIPT RECONSTRUCTOR")
    print("==========================================")
    
    _G.FullRecoveryState.CurrentPhase = "SCRIPT_RECONSTRUCTOR"
    _G.FullRecoveryState.Progress = 55
    
    local results = ScriptReconstructor.ReconstructAllScripts()
    _G.FullRecoveryState.ScriptReconstructionResults = results
    
    -- Exporter les résultats
    DataExporter.ExportJSON(results, "ScriptReconstruction_Results.json")
    
    print(string.format("[SCRIPT_RECONSTRUCTOR] Scripts reconstruits: %d", results.Summary.ReconstructedScripts))
    print(string.format("[SCRIPT_RECONSTRUCTOR] Échoués: %d", results.Summary.FailedReconstructions))
    
    _G.FullRecoveryState.Progress = 65
    
    return results
end

-- ============================================================================
-- PHASE 5: SCRIPT REPAIRER
-- ============================================================================

local function RunScriptRepairer()
    print("==========================================")
    print("PHASE 5: SCRIPT REPAIRER")
    print("==========================================")
    
    _G.FullRecoveryState.CurrentPhase = "SCRIPT_REPAIRER"
    _G.FullRecoveryState.Progress = 70
    
    local results = ScriptRepairer.RepairAllScripts(_G.FullRecoveryState.ScriptReconstructionResults)
    _G.FullRecoveryState.ScriptRepairResults = results
    
    -- Exporter les résultats
    DataExporter.ExportJSON(results, "ScriptRepair_Results.json")
    
    print(string.format("[SCRIPT_REPAIRER] Scripts réparés: %d", results.Summary.RepairedScripts))
    print(string.format("[SCRIPT_REPAIRER] Échoués: %d", results.Summary.FailedRepairs))
    
    _G.FullRecoveryState.Progress = 75
    
    return results
end

-- ============================================================================
-- PHASE 6: MAP EXTRACTOR
-- ============================================================================

local function RunMapExtractor()
    print("==========================================")
    print("PHASE 6: MAP EXTRACTOR")
    print("==========================================")
    
    _G.FullRecoveryState.CurrentPhase = "MAP_EXTRACTOR"
    _G.FullRecoveryState.Progress = 80
    
    local results = MapExtractor.ExtractFullMap()
    _G.FullRecoveryState.MapExtractionResults = results
    
    -- Exporter les résultats
    DataExporter.ExportJSON(results, "MapExtraction_Results.json")
    
    print(string.format("[MAP_EXTRACTOR] Instances: %d", results.Summary.TotalInstances))
    print(string.format("[MAP_EXTRACTOR] Parts: %d", results.Summary.TotalParts))
    print(string.format("[MAP_EXTRACTOR] Models: %d", results.Summary.TotalModels))
    print(string.format("[MAP_EXTRACTOR] Spawn Locations: %d", results.Summary.SpawnLocations))
    print(string.format("[MAP_EXTRACTOR] Path Folders: %d", results.Summary.PathFolders))
    
    _G.FullRecoveryState.Progress = 85
    
    return results
end

-- ============================================================================
-- PHASE 7: ASSET RECOVERY
-- ============================================================================

local function RunAssetRecovery()
    print("==========================================")
    print("PHASE 7: ASSET RECOVERY")
    print("==========================================")
    
    _G.FullRecoveryState.CurrentPhase = "ASSET_RECOVERY"
    _G.FullRecoveryState.Progress = 90
    
    local results = AssetRecovery.RecoverAllAssets()
    _G.FullRecoveryState.AssetRecoveryResults = results
    
    -- Exporter les résultats
    DataExporter.ExportJSON(results, "AssetRecovery_Results.json")
    
    print(string.format("[ASSET_RECOVERY] Images visibles: %d", results.Summary.VisibleImages))
    print(string.format("[ASSET_RECOVERY] Sons visibles: %d", results.Summary.VisibleSounds))
    print(string.format("[ASSET_RECOVERY] Meshes visibles: %d", results.Summary.VisibleMeshes))
    print(string.format("[ASSET_RECOVERY] Animations visibles: %d", results.Summary.VisibleAnimations))
    print(string.format("[ASSET_RECOVERY] Images cachées: %d", results.Summary.HiddenImages))
    print(string.format("[ASSET_RECOVERY] Sons cachés: %d", results.Summary.HiddenSounds))
    print(string.format("[ASSET_RECOVERY] Meshes cachés: %d", results.Summary.HiddenMeshes))
    print(string.format("[ASSET_RECOVERY] Animations cachées: %d", results.Summary.HiddenAnimations))
    print(string.format("[ASSET_RECOVERY] Images uniques: %d", results.Summary.UniqueImages))
    print(string.format("[ASSET_RECOVERY] Sons uniques: %d", results.Summary.UniqueSounds))
    print(string.format("[ASSET_RECOVERY] Meshes uniques: %d", results.Summary.UniqueMeshes))
    print(string.format("[ASSET_RECOVERY] Animations uniques: %d", results.Summary.UniqueAnimations))
    
    _G.FullRecoveryState.Progress = 95
    
    return results
end

-- ============================================================================
-- PHASE 8: EXTERNAL API ANALYSIS (OPTIONAL)
-- ============================================================================

local function RunExternalAPIAnalysis()
    if not _G.FullRecoveryState.Config.UseExternalAPI then
        print("==========================================")
        print("PHASE 8: EXTERNAL API ANALYSIS (SKIP)")
        print("==========================================")
        print("[EXTERNAL API] Disabled in configuration")
        return nil
    end
    
    print("==========================================")
    print("PHASE 8: EXTERNAL API ANALYSIS")
    print("==========================================")
    
    _G.FullRecoveryState.CurrentPhase = "EXTERNAL_API_ANALYSIS"
    _G.FullRecoveryState.Progress = 96
    
    -- Prepare data for external API
    local scriptDataList = {}
    
    if _G.FullRecoveryState.ScriptAnalysisResults then
        for _, script in pairs(_G.FullRecoveryState.ScriptAnalysisResults.Scripts) do
            table.insert(scriptDataList, {
                Name = script.Structural.Name,
                ClassName = script.Structural.ClassName,
                Path = script.Structural.Path,
                Purpose = script.Semantic.Category,
                BytecodeAnalysis = script.Structural.BytecodeAnalysis,
                Upvalues = script.Structural.Variables
            })
        end
    end
    
    local results = ExternalAPIIntegration.BatchAnalyzer.AnalyzeBatch(scriptDataList)
    _G.FullRecoveryState.ExternalAPIAnalysisResults = results
    
    -- Export results
    DataExporter.ExportJSON(results, "ExternalAPIAnalysis_Results.json")
    
    print(string.format("[EXTERNAL API] Scripts analyzed: %d", results.Summary.Total))
    print(string.format("[EXTERNAL API] Success: %d", results.Summary.Successful))
    print(string.format("[EXTERNAL API] Failed: %d", results.Summary.Failed))
    
    _G.FullRecoveryState.Progress = 98
    
    return results
end

-- ============================================================================
-- PHASE 9: VULNERABILITY SCAN
-- ============================================================================

local function RunVulnerabilityScan()
    if not _G.FullRecoveryState.Config.UseVulnerabilityScanner then
        print("==========================================")
        print("PHASE 9: VULNERABILITY SCAN (SKIP)")
        print("==========================================")
        print("[VULNERABILITY] Désactivé dans la configuration")
        return nil
    end
    
    print("==========================================")
    print("PHASE 9: VULNERABILITY SCAN")
    print("==========================================")
    
    _G.FullRecoveryState.CurrentPhase = "VULNERABILITY_SCAN"
    _G.FullRecoveryState.Progress = 99
    
    local results = VulnerabilityScanner.RunFullVulnerabilityScan()
    _G.FullRecoveryState.VulnerabilityScanResults = results
    
    -- Exporter les résultats
    DataExporter.ExportJSON(results, "VulnerabilityScan_Results.json")
    
    print(string.format("[VULNERABILITY] Remotes non sécurisés: %d", results.Summary.UnsecuredRemotes))
    print(string.format("[VULNERABILITY] Scripts backdoor: %d", results.Summary.BackdoorScripts))
    
    return results
end

-- ============================================================================
-- PHASE 10: BACKDOOR SCAN
-- ============================================================================

local function RunBackdoorScan()
    if not _G.FullRecoveryState.Config.UseBackdoorScanner then
        print("==========================================")
        print("PHASE 10: BACKDOOR SCAN (SKIP)")
        print("==========================================")
        print("[BACKDOOR] Désactivé dans la configuration")
        return nil
    end
    
    print("==========================================")
    print("PHASE 10: BACKDOOR SCAN")
    print("==========================================")
    
    _G.FullRecoveryState.CurrentPhase = "BACKDOOR_SCAN"
    
    local results = BackdoorScanner.RunFullBackdoorScan()
    _G.FullRecoveryState.BackdoorScanResults = results
    
    -- Exporter les résultats
    DataExporter.ExportJSON(results, "BackdoorScan_Results.json")
    
    print(string.format("[BACKDOOR] Backdoors détectés: %d", results.Summary.Backdoors))
    print(string.format("[BACKDOOR] Backdoors potentiels: %d", results.Summary.PotentialBackdoors))
    
    return results
end

-- ============================================================================
-- PHASE 11: EXPLOIT SCAN
-- ============================================================================

local function RunExploitScan()
    if not _G.FullRecoveryState.Config.UseExploitScanner then
        print("==========================================")
        print("PHASE 11: EXPLOIT SCAN (SKIP)")
        print("==========================================")
        print("[EXPLOIT] Désactivé dans la configuration")
        return nil
    end
    
    print("==========================================")
    print("PHASE 11: EXPLOIT SCAN")
    print("==========================================")
    
    _G.FullRecoveryState.CurrentPhase = "EXPLOIT_SCAN"
    
    local results = ExploitScanner.RunFullExploitScan()
    _G.FullRecoveryState.ExploitScanResults = results
    
    -- Exporter les résultats
    DataExporter.ExportJSON(results, "ExploitScan_Results.json")
    
    print(string.format("[EXPLOIT] Remotes exploitables: %d", results.Summary.ExploitableRemotes))
    print(string.format("[EXPLOIT] Chaînes d'exploit: %d", results.Summary.ExploitChains))
    
    return results
end

-- ============================================================================
-- PHASE 12: PRIVILEGE ESCALATION SCAN
-- ============================================================================

local function RunPrivilegeEscalationScan()
    if not _G.FullRecoveryState.Config.UsePrivilegeEscalation then
        print("==========================================")
        print("PHASE 12: PRIVILEGE ESCALATION SCAN (SKIP)")
        print("==========================================")
        print("[PRIVILEGE] Désactivé dans la configuration")
        return nil
    end
    
    print("==========================================")
    print("PHASE 12: PRIVILEGE ESCALATION SCAN")
    print("==========================================")
    
    _G.FullRecoveryState.CurrentPhase = "PRIVILEGE_ESCALATION"
    
    local results = PrivilegeEscalation.RunFullPrivilegeEscalationScan()
    _G.FullRecoveryState.PrivilegeEscalationResults = results
    
    -- Exporter les résultats
    DataExporter.ExportJSON(results, "PrivilegeEscalation_Results.json")
    
    print(string.format("[PRIVILEGE] Admin access: %s", results.Summary.AdminAccess and "Yes" or "No"))
    print(string.format("[PRIVILEGE] Méthodes d'élévation: %d", results.Summary.EscalationMethods))
    
    return results
end

-- ============================================================================
-- PHASE 13: DIRECT COPY (DANGEREUX)
-- ============================================================================

local function RunDirectCopy()
    if not _G.FullRecoveryState.Config.UseDirectCopy then
        print("==========================================")
        print("PHASE 13: DIRECT COPY (SKIP)")
        print("==========================================")
        print("[DIRECT_COPY] Désactivé dans la configuration (DANGEREUX)")
        return nil
    end
    
    print("==========================================")
    print("PHASE 13: DIRECT COPY")
    print("==========================================")
    print("[DIRECT_COPY] ⚠️  ATTENTION: Cette méthode est dangereuse")
    print("[DIRECT_COPY] Utilisation à vos risques et périls")
    
    _G.FullRecoveryState.CurrentPhase = "DIRECT_COPY"
    
    local results = DirectCopy.AttemptDirectCopy()
    _G.FullRecoveryState.DirectCopyResults = results
    
    -- Exporter les résultats
    DataExporter.ExportJSON(results, "DirectCopy_Results.json")
    
    if results.Successful then
        print(string.format("[DIRECT_COPY] Copie réussie: %s", results.OutputFile))
    else
        print("[DIRECT_COPY] Copie échouée")
    end
    
    return results
end

-- ============================================================================
-- PHASE 14: FINAL REPORT
-- ============================================================================

local function GenerateFinalReport()
    print("==========================================")
    print("PHASE 14: FINAL REPORT")
    print("==========================================")
    
    _G.FullRecoveryState.CurrentPhase = "FINAL_REPORT"
    _G.FullRecoveryState.Progress = 100
    
    local report = {
        Timestamp = tick(),
        SessionDuration = tick() - _G.FullRecoveryState.StartTime,
        PlaceId = game.PlaceId,
        GameName = "Tower Battles",
        
        Phases = {
            DeepScan = _G.FullRecoveryState.DeepScanResults and {
                Available = true,
                Summary = {
                    GCTables = _G.FullRecoveryState.DeepScanResults.GCScan.TotalTables,
                    HiddenScripts = #_G.FullRecoveryState.DeepScanResults.HiddenScripts.HiddenScripts,
                    HiddenAssets = #_G.FullRecoveryState.DeepScanResults.HiddenAssets.HiddenAssets
                }
            } or {Available = false},
            
            ScriptDecryptor = _G.FullRecoveryState.ScriptDecryptResults and {
                Available = true,
                Summary = _G.FullRecoveryState.ScriptDecryptResults.Summary
            } or {Available = false},
            
            ScriptAnalyzer = _G.FullRecoveryState.ScriptAnalysisResults and {
                Available = true,
                Summary = _G.FullRecoveryState.ScriptAnalysisResults.Summary
            } or {Available = false},
            
            ScriptReconstructor = _G.FullRecoveryState.ScriptReconstructionResults and {
                Available = true,
                Summary = _G.FullRecoveryState.ScriptReconstructionResults.Summary
            } or {Available = false},
            
            ScriptRepairer = _G.FullRecoveryState.ScriptRepairResults and {
                Available = true,
                Summary = _G.FullRecoveryState.ScriptRepairResults.Summary
            } or {Available = false},
            
            MapExtractor = _G.FullRecoveryState.MapExtractionResults and {
                Available = true,
                Summary = _G.FullRecoveryState.MapExtractionResults.Summary
            } or {Available = false},
            
            AssetRecovery = _G.FullRecoveryState.AssetRecoveryResults and {
                Available = true,
                Summary = _G.FullRecoveryState.AssetRecoveryResults.Summary
            } or {Available = false},
            
            ExternalAPIAnalysis = _G.FullRecoveryState.ExternalAPIAnalysisResults and {
                Available = true,
                Summary = _G.FullRecoveryState.ExternalAPIAnalysisResults.Summary
            } or {Available = false},
            
            VulnerabilityScan = _G.FullRecoveryState.VulnerabilityScanResults and {
                Available = true,
                Summary = _G.FullRecoveryState.VulnerabilityScanResults.Summary
            } or {Available = false},
            
            BackdoorScan = _G.FullRecoveryState.BackdoorScanResults and {
                Available = true,
                Summary = _G.FullRecoveryState.BackdoorScanResults.Summary
            } or {Available = false},
            
            ExploitScan = _G.FullRecoveryState.ExploitScanResults and {
                Available = true,
                Summary = _G.FullRecoveryState.ExploitScanResults.Summary
            } or {Available = false},
            
            PrivilegeEscalation = _G.FullRecoveryState.PrivilegeEscalationResults and {
                Available = true,
                Summary = _G.FullRecoveryState.PrivilegeEscalationResults.Summary
            } or {Available = false},
            
            DirectCopy = _G.FullRecoveryState.DirectCopyResults and {
                Available = true,
                Successful = _G.FullRecoveryState.DirectCopyResults.Successful,
                MethodUsed = _G.FullRecoveryState.DirectCopyResults.MethodUsed,
                OutputFile = _G.FullRecoveryState.DirectCopyResults.OutputFile
            } or {Available = false}
        },
        
        Configuration = _G.FullRecoveryState.Config
    }
    
    -- Exporter le rapport final
    DataExporter.ExportJSON(report, "Final_Report.json")
    
    print(string.format("[FINAL_REPORT] Durée de la session: %.2f secondes", report.SessionDuration))
    print("[FINAL_REPORT] Rapport final exporté")
    
    return report
end

-- ============================================================================
-- EXÉCUTION PRINCIPALE
-- ============================================================================

local function RunFullRecovery()
    print("==========================================")
    print("DÉMARRAGE DE LA RÉCUPÉRATION COMPLÈTE")
    print("==========================================")
    
    -- Notification Discord de démarrage
    DiscordNotifier.AutoNotifier.NotifyStart()
    
    local startTime = tick()
    
    -- Phase 1: Deep Scan
    if _G.FullRecoveryState.Config.UseDeepScan then
        RunDeepScan()
    end
    
    -- Phase 2: Script Decryptor
    if _G.FullRecoveryState.Config.UseScriptDecryptor then
        RunScriptDecryptor()
    end
    
    -- Phase 3: Script Analyzer
    if _G.FullRecoveryState.Config.UseScriptAnalyzer then
        RunScriptAnalyzer()
    end
    
    -- Phase 4: Script Reconstructor
    if _G.FullRecoveryState.Config.UseScriptReconstructor then
        RunScriptReconstructor()
    end
    
    -- Phase 5: Script Repairer
    if _G.FullRecoveryState.Config.UseScriptRepairer then
        RunScriptRepairer()
    end
    
    -- Phase 6: Map Extractor
    if _G.FullRecoveryState.Config.UseMapExtractor then
        RunMapExtractor()
    end
    
    -- Phase 7: Asset Recovery
    if _G.FullRecoveryState.Config.UseAssetRecovery then
        RunAssetRecovery()
    end
    
    -- Phase 8: External API Analysis
    RunExternalAPIAnalysis()
    
    -- Phase 9: Vulnerability Scan
    RunVulnerabilityScan()
    
    -- Phase 10: Backdoor Scan
    RunBackdoorScan()
    
    -- Phase 11: Exploit Scan
    RunExploitScan()
    
    -- Phase 12: Privilege Escalation Scan
    RunPrivilegeEscalationScan()
    
    -- Phase 13: Direct Copy (DANGEREUX)
    RunDirectCopy()
    
    -- Phase 14: Final Report
    local finalReport = GenerateFinalReport()
    
    local duration = tick() - startTime
    
    print("==========================================")
    print("RÉCUPÉRATION COMPLÈTE TERMINÉE")
    print("==========================================")
    print(string.format("Durée totale: %.2f secondes", duration))
    print(string.format("Progression: %d%%", _G.FullRecoveryState.Progress))
    print(string.format("Dossier de sortie: %s", _G.FullRecoveryState.Config.OutputPath))
    print("==========================================")
    
    -- Notification Discord de succès
    DiscordNotifier.AutoNotifier.NotifySuccess(duration, _G.FullRecoveryState.Config.OutputPath)
    
    return finalReport
end

-- ============================================================================
-- CONFIGURATION
-- ============================================================================

function ConfigureFullRecovery(config)
    if config.UseDeepScan ~= nil then
        _G.FullRecoveryState.Config.UseDeepScan = config.UseDeepScan
    end
    if config.UseScriptDecryptor ~= nil then
        _G.FullRecoveryState.Config.UseScriptDecryptor = config.UseScriptDecryptor
    end
    if config.UseScriptAnalyzer ~= nil then
        _G.FullRecoveryState.Config.UseScriptAnalyzer = config.UseScriptAnalyzer
    end
    if config.UseScriptReconstructor ~= nil then
        _G.FullRecoveryState.Config.UseScriptReconstructor = config.UseScriptReconstructor
    end
    if config.UseScriptRepairer ~= nil then
        _G.FullRecoveryState.Config.UseScriptRepairer = config.UseScriptRepairer
    end
    if config.UseMapExtractor ~= nil then
        _G.FullRecoveryState.Config.UseMapExtractor = config.UseMapExtractor
    end
    if config.UseAssetRecovery ~= nil then
        _G.FullRecoveryState.Config.UseAssetRecovery = config.UseAssetRecovery
    end
    if config.UseExternalAPI ~= nil then
        _G.FullRecoveryState.Config.UseExternalAPI = config.UseExternalAPI
    end
    if config.UseVulnerabilityScanner ~= nil then
        _G.FullRecoveryState.Config.UseVulnerabilityScanner = config.UseVulnerabilityScanner
    end
    if config.UseBackdoorScanner ~= nil then
        _G.FullRecoveryState.Config.UseBackdoorScanner = config.UseBackdoorScanner
    end
    if config.UseExploitScanner ~= nil then
        _G.FullRecoveryState.Config.UseExploitScanner = config.UseExploitScanner
    end
    if config.UsePrivilegeEscalation ~= nil then
        _G.FullRecoveryState.Config.UsePrivilegeEscalation = config.UsePrivilegeEscalation
    end
    if config.UseDirectCopy ~= nil then
        _G.FullRecoveryState.Config.UseDirectCopy = config.UseDirectCopy
    end
    if config.UseDiscordNotifier ~= nil then
        _G.FullRecoveryState.Config.UseDiscordNotifier = config.UseDiscordNotifier
    end
    if config.DiscordWebhookURL then
        _G.FullRecoveryState.Config.DiscordWebhookURL = config.DiscordWebhookURL
    end
    if config.ExportFormat then
        _G.FullRecoveryState.Config.ExportFormat = config.ExportFormat
    end
    if config.OutputPath then
        _G.FullRecoveryState.Config.OutputPath = config.OutputPath
    end
    
    -- Configure External API if enabled
    if config.ExternalAPIConfig then
        ExternalAPIIntegration.Configure(config.ExternalAPIConfig)
    end
    
    -- Configurer DiscordNotifier si activé
    if config.UseDiscordNotifier and config.DiscordWebhookURL then
        DiscordNotifier.Configure({
            WebhookURL = config.DiscordWebhookURL,
            EnableNotifications = true
        })
    end
    
    print("[CONFIG] Configuration mise à jour")
end

-- ============================================================================
-- DÉMARRAGE AUTOMATIQUE
-- ============================================================================

print("==========================================")
print("SYSTÈME PRÊT")
print("==========================================")
print("Pour démarrer la récupération complète:")
print("  RunFullRecovery()")
print("")
print("Pour configurer:")
print("  ConfigureFullRecovery({UseExternalAPI = true, ExternalAPIConfig = {...}})")
print("")
print("Pour activer Discord:")
print("  ConfigureFullRecovery({UseDiscordNotifier = true, DiscordWebhookURL = \"YOUR_WEBHOOK_URL\"})")
print("==========================================")

-- Démarrage automatique (commenté pour permettre configuration manuelle)
-- RunFullRecovery()
