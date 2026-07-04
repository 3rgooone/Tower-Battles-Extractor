-- ============================================================================
-- TOWER BATTLES AGENT SYSTEM - MAIN
-- Main entry point for the multi-agent system
-- ============================================================================

print("==========================================")
print("TOWER BATTLES AGENT SYSTEM")
print("Version 1.0 - Automatic Reverse-Engineering")
print("==========================================")

-- ============================================================================
-- CHARGEMENT DES MODULES
-- ============================================================================

local HttpService = game:GetService("HttpService")

-- État partagé global
_G.AgentSystemSharedState = _G.AgentSystemSharedState or {
    -- Explorer → Implementer
    DiscoveredFeatures = {},
    NetworkPatterns = {},
    ScriptAnalysis = {},
    GameMechanics = {},
    
    -- Implementer → Tester
    ImplementedFeatures = {},
    CodeChanges = {},
    
    -- Tester → Orchestrator
    TestResults = {},
    BugsFound = {},
    ValidationStatus = {},
    
    -- Wiki → Tous
    Documentation = {},
    FeatureSpecs = {},
    
    -- Orchestrateur
    CurrentPhase = "EXPLORATION",
    Progress = 0,
    TotalTasks = 100,
    CompletedTasks = 0,
    
    -- Checkpoints
    LastCheckpoint = 0,
    SessionStartTime = tick(),
    
    -- Logs
    ExplorerLogs = {},
    ImplementerLogs = {},
    TesterLogs = {},
    WikiLogs = {}
}

-- Configuration
_G.AgentSystemConfig = _G.AgentSystemConfig or {
    Mode = "FULL_AUTO",
    ExplorerInterval = 30,
    ImplementerInterval = 60,
    TesterInterval = 120,
    WikiInterval = 180,
    CheckpointInterval = 300,
    LogPath = "TowerBattles_AgentLogs",
    WikiPath = "TowerBattles_Wiki",
    OriginalGamePlaceId = game.PlaceId,
    NewGamePlaceId = 0
}

-- ============================================================================
-- ORCHESTRATEUR
-- ============================================================================

local Orchestrator = {}

function Orchestrator.Init()
    print("[ORCHESTRATOR] Initialisation...")
    
    Orchestrator.LoadCheckpoint()
    Orchestrator.PlanTasks()
    
    spawn(function()
        while true do
            Orchestrator.RunCycle()
            wait(10)
        end
    end)
end

function Orchestrator.LoadCheckpoint()
    local checkpointFile = _G.AgentSystemConfig.LogPath .. "/checkpoint.json"
    
    if isfile and isfile(checkpointFile) then
        local success, data = pcall(function()
            return HttpService:JSONDecode(readfile(checkpointFile))
        end)
        
        if success then
            _G.AgentSystemSharedState = data.SharedState or _G.AgentSystemSharedState
            print("[ORCHESTRATOR] Checkpoint chargé")
        end
    end
end

function Orchestrator.SaveCheckpoint()
    local checkpointFile = _G.AgentSystemConfig.LogPath .. "/checkpoint.json"
    
    if writefile then
        local data = {
            SharedState = _G.AgentSystemSharedState,
            Config = _G.AgentSystemConfig,
            Timestamp = tick(),
            SessionDuration = tick() - _G.AgentSystemSharedState.SessionStartTime
        }
        
        local success, json = pcall(function()
            return HttpService:JSONEncode(data)
        end)
        
        if success then
            writefile(checkpointFile, json)
            print("[ORCHESTRATOR] Checkpoint sauvegardé")
        end
    end
end

function Orchestrator.PlanTasks()
    print(string.format("[ORCHESTRATOR] Phase actuelle: %s", _G.AgentSystemSharedState.CurrentPhase))
end

function Orchestrator.RunCycle()
    local phase = _G.AgentSystemSharedState.CurrentPhase
    
    if phase == "EXPLORATION" then
        Orchestrator.CoordinateExploration()
    elseif phase == "IMPLEMENTATION" then
        Orchestrator.CoordinateImplementation()
    elseif phase == "TESTING" then
        Orchestrator.CoordinateTesting()
    end
    
    if tick() - _G.AgentSystemSharedState.LastCheckpoint > _G.AgentSystemConfig.CheckpointInterval then
        Orchestrator.SaveCheckpoint()
        _G.AgentSystemSharedState.LastCheckpoint = tick()
    end
end

function Orchestrator.CoordinateExploration()
    local featuresCount = #_G.AgentSystemSharedState.DiscoveredFeatures
    
    if featuresCount > 50 then
        print("[ORCHESTRATOR] Exploration suffisante, passage à l'implémentation")
        _G.AgentSystemSharedState.CurrentPhase = "IMPLEMENTATION"
    end
end

function Orchestrator.CoordinateImplementation()
    local implementedCount = #_G.AgentSystemSharedState.ImplementedFeatures
    
    if implementedCount >= #_G.AgentSystemSharedState.DiscoveredFeatures then
        print("[ORCHESTRATOR] Implémentation complète, passage aux tests")
        _G.AgentSystemSharedState.CurrentPhase = "TESTING"
    end
end

function Orchestrator.CoordinateTesting()
    local bugsCount = #_G.AgentSystemSharedState.BugsFound
    
    if bugsCount == 0 then
        print("[ORCHESTRATOR] Tous les tests passent, projet terminé!")
    else
        print("[ORCHESTRATOR] Bugs trouvés, retour à l'implémentation")
        _G.AgentSystemSharedState.CurrentPhase = "IMPLEMENTATION"
    end
end

-- ============================================================================
-- CHARGEMENT DES AGENTS AVANCÉS
-- ============================================================================

local AgentExplorer = nil
local AgentImplementer = nil
local AgentTester = nil

-- Créer les dossiers
if makefolder then
    makefolder(_G.AgentSystemConfig.LogPath)
    makefolder(_G.AgentSystemConfig.WikiPath)
end

-- Charger Agent Explorer
local successExplorer, errExplorer = pcall(function()
    return loadstring(readfile("TowerBattlesExtractor/AgentExplorer_Advanced.lua"))()
end)

if successExplorer then
    AgentExplorer = successExplorer
    print("[SYSTEM] Agent Explorer chargé")
else
    print(string.format("[SYSTEM] Erreur chargement Agent Explorer: %s", errExplorer or "fichier non trouvé"))
    -- Créer un agent Explorer basique
    AgentExplorer = {
        Init = function()
            spawn(function()
                while true do
                    print("[EXPLORER] Cycle d'exploration (mode basique)")
                    wait(_G.AgentSystemConfig.ExplorerInterval)
                end
            end)
        end
    }
end

-- Charger Agent Implementer
local successImplementer, errImplementer = pcall(function()
    return loadstring(readfile("TowerBattlesExtractor/AgentImplementer_Advanced.lua"))()
end)

if successImplementer then
    AgentImplementer = successImplementer
    print("[SYSTEM] Agent Implementer chargé")
else
    print(string.format("[SYSTEM] Erreur chargement Agent Implementer: %s", errImplementer or "fichier non trouvé"))
    -- Créer un agent Implementer basique
    AgentImplementer = {
        Init = function()
            spawn(function()
                while true do
                    if _G.AgentSystemSharedState.CurrentPhase == "IMPLEMENTATION" then
                        print("[IMPLEMENTER] Cycle d'implémentation (mode basique)")
                    end
                    wait(_G.AgentSystemConfig.ImplementerInterval)
                end
            end)
        end
    }
end

-- Charger Agent Tester
local successTester, errTester = pcall(function()
    return loadstring(readfile("TowerBattlesExtractor/AgentTester_Advanced.lua"))()
end)

if successTester then
    AgentTester = successTester
    print("[SYSTEM] Agent Tester chargé")
else
    print(string.format("[SYSTEM] Erreur chargement Agent Tester: %s", errTester or "fichier non trouvé"))
    -- Créer un agent Tester basique
    AgentTester = {
        Init = function()
            spawn(function()
                while true do
                    if _G.AgentSystemSharedState.CurrentPhase == "TESTING" then
                        print("[TESTER] Cycle de test (mode basique)")
                    end
                    wait(_G.AgentSystemConfig.TesterInterval)
                end
            end)
        end
    }
end

-- ============================================================================
-- AGENT WIKI (Intégré)
-- ============================================================================

local Wiki = {}

function Wiki.Init()
    print("[WIKI] Initialisation...")
    
    spawn(function()
        while true do
            Wiki.RunWikiCycle()
            wait(_G.AgentSystemConfig.WikiInterval)
        end
    end)
end

function Wiki.RunWikiCycle()
    print("[WIKI] Cycle de documentation...")
    
    local wikiContent = Wiki.BuildWikiContent()
    
    if writefile then
        local wikiFile = _G.AgentSystemConfig.WikiPath .. "/GameWiki.md"
        local success, err = pcall(function()
            writefile(wikiFile, wikiContent)
        end)
        
        if success then
            print("[WIKI] Wiki généré avec succès")
        else
            print(string.format("[WIKI] Erreur génération wiki: %s", err))
        end
    end
end

function Wiki.BuildWikiContent()
    local content = "# Tower Battles Game Wiki\n\n"
    content = content .. string.format("Generated: %s\n\n", os.date("%Y-%m-%d %H:%M:%S"))
    content = content .. string.format("Session Duration: %.2f hours\n\n", (tick() - _G.AgentSystemSharedState.SessionStartTime) / 3600)
    
    -- Phase actuelle
    content = content .. string.format("## Current Phase: %s\n\n", _G.AgentSystemSharedState.CurrentPhase)
    
    -- Progression
    content = content .. string.format("## Progress\n\n")
    content = content .. string.format("- Discovered Features: %d\n", #_G.AgentSystemSharedState.DiscoveredFeatures)
    content = content .. string.format("- Implemented Features: %d\n", #_G.AgentSystemSharedState.ImplementedFeatures)
    content = content .. string.format("- Network Patterns: %d\n", #_G.AgentSystemSharedState.NetworkPatterns)
    content = content .. string.format("- Script Analysis: %d\n", #_G.AgentSystemSharedState.ScriptAnalysis)
    content = content .. string.format("- Bugs Found: %d\n", #_G.AgentSystemSharedState.BugsFound)
    content = content .. "\n"
    
    -- Features découvertes
    content = content .. "## Discovered Features\n\n"
    for _, feature in pairs(_G.AgentSystemSharedState.DiscoveredFeatures) do
        content = content .. string.format("### %s\n", feature.Name or "Unknown")
        content = content .. string.format("- Type: %s\n", feature.Type or "Unknown")
        content = content .. string.format("- Path: %s\n", feature.Path or "Unknown")
        content = content .. "\n"
    end
    
    -- Patterns réseau
    content = content .. "## Network Patterns\n\n"
    for _, pattern in pairs(_G.AgentSystemSharedState.NetworkPatterns) do
        content = content .. string.format("### %s\n", pattern.Name or "Unknown")
        content = content .. string.format("- Type: %s\n", pattern.ClassName or "Unknown")
        content = content .. "\n"
    end
    
    -- Scripts analysés
    content = content .. "## Scripts Analysis\n\n"
    for _, script in pairs(_G.AgentSystemSharedState.ScriptAnalysis) do
        content = content .. string.format("### %s\n", script.Name or "Unknown")
        content = content .. string.format("- Type: %s\n", script.ClassName or "Unknown")
        content = content .. string.format("- Path: %s\n", script.Path or "Unknown")
        content = content .. "\n"
    end
    
    return content
end

-- ============================================================================
-- INITIALISATION DU SYSTÈME
-- ============================================================================

print("==========================================")
print("INITIALISATION DU SYSTÈME")
print("==========================================")

-- Orchestrator
Orchestrator.Init()
wait(1)

-- Agent Explorer
if AgentExplorer and AgentExplorer.Init then
    AgentExplorer.Init()
else
    print("[SYSTEM] Agent Explorer non disponible")
end
wait(1)

-- Agent Implementer
if AgentImplementer and AgentImplementer.Init then
    AgentImplementer.Init()
else
    print("[SYSTEM] Agent Implementer non disponible")
end
wait(1)

-- Agent Tester
if AgentTester and AgentTester.Init then
    AgentTester.Init()
else
    print("[SYSTEM] Agent Tester non disponible")
end
wait(1)

-- Agent Wiki
Wiki.Init()

print("==========================================")
print("SYSTÈME INITIALISÉ")
print(string.format("Mode: %s", _G.AgentSystemConfig.Mode))
print(string.format("Phase: %s", _G.AgentSystemSharedState.CurrentPhase))
print(string.format("PlaceId: %d", _G.AgentSystemConfig.OriginalGamePlaceId))
print("==========================================")
print("[INFO] Le système tourne en arrière-plan")
print("[INFO] Consultez le wiki pour les découvertes")
print("[INFO] Les checkpoints sont sauvegardés automatiquement")
print("==========================================")
