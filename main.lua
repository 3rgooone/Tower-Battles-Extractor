--[[
    Tower Battles Extractor v4.0
    Complete Recovery System for Tower Battles
    License: MIT
    
    Single-file entry point - Loads all modules from GitHub
    Execute this file to start the extractor
]]

-- ============================================================================
-- CONFIGURATION (All settings here)
-- ============================================================================

local Config = {
    -- Mode: "FullRecovery", "DeepScan", "ScriptAnalysis", "AgentSystem"
    Mode = "FullRecovery",
    
    -- Recovery Modules
    UseDeepScan = true,
    UseScriptDecryptor = true,
    UseScriptAnalyzer = true,
    UseScriptReconstructor = true,
    UseScriptRepairer = true,
    UseMapExtractor = true,
    UseAssetRecovery = true,
    UseExternalAPI = false,
    
    -- Security Modules
    UseVulnerabilityScanner = true,
    UseBackdoorScanner = true,
    UseExploitScanner = true,
    UsePrivilegeEscalation = true,
    UseDirectCopy = false, -- DANGEROUS
    
    -- Notifications
    UseDiscordNotifier = false,
    DiscordWebhookURL = "",
    
    -- External API (Groq - Free)
    ExternalAPIConfig = {
        APIKey = "", -- Get free key at https://console.groq.com/
        Model = "llama-3.1-70b-versatile",
        MaxTokens = 4000,
        Temperature = 0.7
    },
    
    -- Export
    ExportFormat = "JSON",
    OutputPath = "TowerBattles_FullRecovery"
}

-- ============================================================================
-- GITHUB RAW URLS
-- ============================================================================

local GitHubBase = "https://raw.githubusercontent.com/3rgooone/Tower-Battles-Extractor/refs/heads/main"

local ModuleURLs = {
    FullRecovery = GitHubBase .. "/FullRecovery.lua",
    DeepScanner = GitHubBase .. "/DeepScanner.lua",
    ScriptDecryptor = GitHubBase .. "/ScriptDecryptor.lua",
    ScriptAnalyzer = GitHubBase .. "/ScriptAnalyzer.lua",
    ScriptReconstructor = GitHubBase .. "/ScriptReconstructor.lua",
    ScriptRepairer = GitHubBase .. "/ScriptRepairer.lua",
    MapExtractor = GitHubBase .. "/MapExtractor.lua",
    AssetRecovery = GitHubBase .. "/AssetRecovery.lua",
    LLMIntegration = GitHubBase .. "/LLMIntegration.lua",
    VulnerabilityScanner = GitHubBase .. "/VulnerabilityScanner.lua",
    BackdoorScanner = GitHubBase .. "/BackdoorScanner.lua",
    ExploitScanner = GitHubBase .. "/ExploitScanner.lua",
    PrivilegeEscalation = GitHubBase .. "/PrivilegeEscalation.lua",
    DirectCopy = GitHubBase .. "/DirectCopy.lua",
    DiscordNotifier = GitHubBase .. "/DiscordNotifier.lua",
    AgentSystem = GitHubBase .. "/AgentSystem.lua",
    AgentSystem_Main = GitHubBase .. "/AgentSystem_Main.lua"
}

-- ============================================================================
-- MODULE LOADER
-- ============================================================================

local function LoadModule(moduleName)
    local url = ModuleURLs[moduleName]
    if not url then
        warn("[ERROR] Unknown module: " .. moduleName)
        return nil
    end
    
    local success, module = pcall(function()
        return loadstring(game:HttpGet(url, true))()
    end)
    
    if success then
        print("[LOAD] " .. moduleName .. " loaded successfully")
        return module
    else
        warn("[ERROR] Failed to load " .. moduleName .. ": " .. tostring(module))
        return nil
    end
end

-- ============================================================================
-- MAIN EXECUTION
-- ============================================================================

print("==========================================")
print("TOWER BATTLES EXTRACTOR v4.0")
print("==========================================")
print("Mode: " .. Config.Mode)
print("==========================================")

-- Load and run based on mode
if Config.Mode == "FullRecovery" then
    local FullRecovery = LoadModule("FullRecovery")
    if FullRecovery then
        -- Configure
        FullRecovery.ConfigureFullRecovery(Config)
        -- Run
        FullRecovery.RunFullRecovery()
    end
    
elseif Config.Mode == "DeepScan" then
    local DeepScanner = LoadModule("DeepScanner")
    if DeepScanner then
        local results = DeepScanner.RunFullScan()
        print("[RESULTS] Deep scan completed")
    end
    
elseif Config.Mode == "ScriptAnalysis" then
    local ScriptAnalyzer = LoadModule("ScriptAnalyzer")
    if ScriptAnalyzer then
        local results = ScriptAnalyzer.AnalyzeAllScripts()
        print("[RESULTS] Script analysis completed")
    end
    
elseif Config.Mode == "AgentSystem" then
    local AgentSystem = LoadModule("AgentSystem_Main")
    if AgentSystem then
        print("[AGENT] Starting agent system...")
    end
    
else
    warn("[ERROR] Unknown mode: " .. Config.Mode)
    print("Available modes: FullRecovery, DeepScan, ScriptAnalysis, AgentSystem")
end

print("==========================================")
print("EXTRACTION COMPLETE")
print("==========================================")
