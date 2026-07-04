-- ============================================================================
-- AGENT TESTER AVANCÉ
-- Capacités: Tests automatiques gameplay, validation features, debugging
-- ============================================================================

local AdvancedTester = {}

-- ============================================================================
-- FRAMEWORK DE TEST
-- ============================================================================

AdvancedTester.TestFramework = {
    -- Suite de tests
    TestSuites = {},
    
    -- Résultats des tests
    TestResults = {},
    
    -- Ajouter une suite de tests
    AddTestSuite = function(name, tests)
        AdvancedTester.TestFramework.TestSuites[name] = tests
    end,
    
    -- Exécuter une suite de tests
    RunTestSuite = function(suiteName)
        local suite = AdvancedTester.TestFramework.TestSuites[suiteName]
        if not suite then
            print(string.format("[TESTER] Suite de tests non trouvée: %s", suiteName))
            return nil
        end
        
        local results = {
            SuiteName = suiteName,
            StartTime = tick(),
            Tests = {},
            Passed = 0,
            Failed = 0,
            Skipped = 0
        }
        
        for testName, testFunc in pairs(suite) do
            local testResult = AdvancedTester.TestFramework.RunTest(testName, testFunc)
            table.insert(results.Tests, testResult)
            
            if testResult.Status == "PASS" then
                results.Passed = results.Passed + 1
            elseif testResult.Status == "FAIL" then
                results.Failed = results.Failed + 1
            else
                results.Skipped = results.Skipped + 1
            end
        end
        
        results.EndTime = tick()
        results.Duration = results.EndTime - results.StartTime
        
        table.insert(AdvancedTester.TestFramework.TestResults, results)
        
        return results
    end,
    
    -- Exécuter un test individuel
    RunTest = function(testName, testFunc)
        local result = {
            Name = testName,
            Status = "UNKNOWN",
            StartTime = tick(),
            Error = nil,
            Output = nil
        }
        
        local success, output = pcall(function()
            return testFunc()
        end)
        
        if success then
            if output == true or output == nil then
                result.Status = "PASS"
            else
                result.Status = "FAIL"
                result.Error = output or "Test returned false"
            end
        else
            result.Status = "FAIL"
            result.Error = output
        end
        
        result.EndTime = tick()
        result.Duration = result.EndTime - result.StartTime
        
        return result
    end,
    
    -- Générer un rapport de test
    GenerateReport = function()
        local report = {
            TotalSuites = #AdvancedTester.TestFramework.TestResults,
            TotalTests = 0,
            TotalPassed = 0,
            TotalFailed = 0,
            TotalSkipped = 0,
            Suites = AdvancedTester.TestFramework.TestResults
        }
        
        for _, suite in pairs(AdvancedTester.TestFramework.TestResults) do
            report.TotalTests = report.TotalTests + #suite.Tests
            report.TotalPassed = report.TotalPassed + suite.Passed
            report.TotalFailed = report.TotalFailed + suite.Failed
            report.TotalSkipped = report.TotalSkipped + suite.Skipped
        end
        
        return report
    end
}

-- ============================================================================
-- TESTS DE GAMEPLAY
-- ============================================================================

AdvancedTester.GameplayTests = {
    -- Test: Placement d'une tour
    TestTowerPlacement = function()
        local player = game:GetService("Players").LocalPlayer
        local replicatedStorage = game:GetService("ReplicatedStorage")
        
        -- Trouver le RemoteEvent de placement
        local placeTowerEvent = replicatedStorage:FindFirstChild("PlaceTower")
        if not placeTowerEvent then
            return false, "PlaceTower RemoteEvent not found"
        end
        
        -- Simuler un placement
        local success, err = pcall(function()
            placeTowerEvent:FireServer("Scout", Vector3.new(0, 0, 0))
        end)
        
        if not success then
            return false, err
        end
        
        return true
    end,
    
    -- Test: Achat d'une tour
    TestTowerPurchase = function()
        local player = game:GetService("Players").LocalPlayer
        local replicatedStorage = game:GetService("ReplicatedStorage")
        
        -- Trouver le RemoteEvent d'achat
        local buyTowerEvent = replicatedStorage:FindFirstChild("BuyTower")
        if not buyTowerEvent then
            return false, "BuyTower RemoteEvent not found"
        end
        
        -- Simuler un achat
        local success, err = pcall(function()
            buyTowerEvent:FireServer("Scout")
        end)
        
        if not success then
            return false, err
        end
        
        return true
    end,
    
    -- Test: Upgrade d'une tour
    TestTowerUpgrade = function()
        local player = game:GetService("Players").LocalPlayer
        local replicatedStorage = game:GetService("ReplicatedStorage")
        
        -- Trouver le RemoteEvent d'upgrade
        local upgradeTowerEvent = replicatedStorage:FindFirstChild("UpgradeTower")
        if not upgradeTowerEvent then
            return false, "UpgradeTower RemoteEvent not found"
        end
        
        -- Simuler un upgrade
        local success, err = pcall(function()
            upgradeTowerEvent:FireServer("Tower1", 1)
        end)
        
        if not success then
            return false, err
        end
        
        return true
    end,
    
    -- Test: Vente d'une tour
    TestTowerSell = function()
        local player = game:GetService("Players").LocalPlayer
        local replicatedStorage = game:GetService("ReplicatedStorage")
        
        -- Trouver le RemoteEvent de vente
        local sellTowerEvent = replicatedStorage:FindFirstChild("SellTower")
        if not sellTowerEvent then
            return false, "SellTower RemoteEvent not found"
        end
        
        -- Simuler une vente
        local success, err = pcall(function()
            sellTowerEvent:FireServer("Tower1")
        end)
        
        if not success then
            return false, err
        end
        
        return true
    end,
    
    -- Test: Démarrage d'une vague
    TestWaveStart = function()
        local player = game:GetService("Players").LocalPlayer
        local replicatedStorage = game:GetService("ReplicatedStorage")
        
        -- Trouver le RemoteEvent de démarrage de vague
        local startWaveEvent = replicatedStorage:FindFirstChild("StartWave")
        if not startWaveEvent then
            return false, "StartWave RemoteEvent not found"
        end
        
        -- Simuler le démarrage
        local success, err = pcall(function()
            startWaveEvent:FireServer()
        end)
        
        if not success then
            return false, err
        end
        
        return true
    end,
    
    -- Test: Skip d'une vague
    TestWaveSkip = function()
        local player = game:GetService("Players").LocalPlayer
        local replicatedStorage = game:GetService("ReplicatedStorage")
        
        -- Trouver le RemoteEvent de skip
        local skipWaveEvent = replicatedStorage:FindFirstChild("SkipWave")
        if not skipWaveEvent then
            return false, "SkipWave RemoteEvent not found"
        end
        
        -- Simuler le skip
        local success, err = pcall(function()
            skipWaveEvent:FireServer()
        end)
        
        if not success then
            return false, err
        end
        
        return true
    end
}

-- ============================================================================
-- TESTS DE VALIDATION D'INSTANCES
-- ============================================================================

AdvancedTester.ValidationTests = {
    -- Valider qu'une instance existe
    ValidateInstanceExists = function(path)
        local instance = game
        for _, part in pairs(string.split(path, ".")) do
            instance = instance:FindFirstChild(part)
            if not instance then
                return false, string.format("Instance not found at %s", part)
            end
        end
        return true
    end,
    
    -- Valider les propriétés d'une instance
    ValidateInstanceProperties = function(path, expectedProperties)
        local instance = game
        for _, part in pairs(string.split(path, ".")) do
            instance = instance:FindFirstChild(part)
            if not instance then
                return false, "Instance not found"
            end
        end
        
        for propName, expectedValue in pairs(expectedProperties) do
            local success, actualValue = pcall(function()
                return instance[propName]
            end)
            
            if not success then
                return false, string.format("Property %s not accessible", propName)
            end
            
            if actualValue ~= expectedValue then
                return false, string.format("Property %s mismatch: expected %s, got %s", propName, tostring(expectedValue), tostring(actualValue))
            end
        end
        
        return true
    end,
    
    -- Valider qu'un RemoteEvent existe
    ValidateRemoteEvent = function(name)
        local replicatedStorage = game:GetService("ReplicatedStorage")
        local remote = replicatedStorage:FindFirstChild(name)
        
        if not remote then
            return false, string.format("RemoteEvent %s not found", name)
        end
        
        if not remote:IsA("RemoteEvent") then
            return false, string.format("%s is not a RemoteEvent", name)
        end
        
        return true
    end,
    
    -- Valider qu'un RemoteFunction existe
    ValidateRemoteFunction = function(name)
        local replicatedStorage = game:GetService("ReplicatedStorage")
        local remote = replicatedStorage:FindFirstChild(name)
        
        if not remote then
            return false, string.format("RemoteFunction %s not found", name)
        end
        
        if not remote:IsA("RemoteFunction") then
            return false, string.format("%s is not a RemoteFunction", name)
        end
        
        return true
    end,
    
    -- Valider qu'un ModuleScript existe
    ValidateModuleScript = function(path)
        local instance = game
        for _, part in pairs(string.split(path, ".")) do
            instance = instance:FindFirstChild(part)
            if not instance then
                return false, "Instance not found"
            end
        end
        
        if not instance:IsA("ModuleScript") then
            return false, "Not a ModuleScript"
        end
        
        -- Tenter de require
        local success, module = pcall(function()
            return require(instance)
        end)
        
        if not success then
            return false, string.format("Failed to require: %s", module)
        end
        
        return true
    end
}

-- ============================================================================
-- TESTS DE PERFORMANCE
-- ============================================================================

AdvancedTester.PerformanceTests = {
    -- Mesurer le FPS
    MeasureFPS = function(duration)
        local runService = game:GetService("RunService")
        local frames = 0
        local startTime = tick()
        
        local connection
        connection = runService.RenderStepped:Connect(function()
            frames = frames + 1
        end)
        
        wait(duration)
        
        connection:Disconnect()
        
        local fps = frames / duration
        return true, fps
    end,
    
    -- Mesurer la latence réseau
    MeasureNetworkLatency = function()
        local replicatedStorage = game:GetService("ReplicatedStorage")
        
        -- Créer un RemoteEvent de test
        local testEvent = Instance.new("RemoteEvent")
        testEvent.Name = "LatencyTest"
        testEvent.Parent = replicatedStorage
        
        local startTime = tick()
        local received = false
        
        local connection
        connection = testEvent.OnClientEvent:Connect(function()
            received = true
            connection:Disconnect()
            testEvent:Destroy()
        end)
        
        testEvent:FireServer()
        
        wait(5) -- Timeout
        
        if not received then
            connection:Disconnect()
            testEvent:Destroy()
            return false, "No response"
        end
        
        local latency = (tick() - startTime) * 1000 -- en ms
        return true, latency
    end,
    
    -- Mesurer l'utilisation de la mémoire
    MeasureMemoryUsage = function()
        local stats = game:GetService("Stats")
        
        local memory = {
            LuaGCMemory = stats:GetMemoryUsageMbForTag("LuaGCMemory"),
            LuaScriptMemory = stats:GetMemoryUsageMbForTag("LuaScriptMemory"),
            TotalMemory = stats:GetTotalMemoryUsageMb()
        }
        
        return true, memory
    end
}

-- ============================================================================
-- TESTS DE RÉGRESSION
-- ============================================================================

AdvancedTester.RegressionTests = {
    -- Comparer deux états du jeu
    CompareGameStates = function(state1, state2)
        local differences = {}
        
        -- Comparer les stats joueur
        for stat, value1 in pairs(state1.PlayerStats) do
            local value2 = state2.PlayerStats[stat]
            if value1 ~= value2 then
                table.insert(differences, {
                    Type = "PlayerStat",
                    Name = stat,
                    From = value1,
                    To = value2
                })
            end
        end
        
        -- Comparer les instances
        for path, instance1 in pairs(state1.Instances) do
            local instance2 = state2.Instances[path]
            if not instance2 then
                table.insert(differences, {
                    Type = "Instance",
                    Name = path,
                    Change = "Removed"
                })
            end
        end
        
        return differences
    end,
    
    -- Capturer l'état du jeu
    CaptureGameState = function()
        local state = {
            Timestamp = tick(),
            PlayerStats = AdvancedTester.RegressionTests.CapturePlayerStats(),
            Instances = AdvancedTester.RegressionTests.CaptureInstances(),
            Network = AdvancedTester.RegressionTests.CaptureNetworkState()
        }
        
        return state
    end,
    
    -- Capturer les stats joueur
    CapturePlayerStats = function()
        local player = game:GetService("Players").LocalPlayer
        local stats = {}
        
        local leaderstats = player:FindFirstChild("leaderstats")
        if leaderstats then
            for _, value in pairs(leaderstats:GetChildren()) do
                stats[value.Name] = value.Value
            end
        end
        
        return stats
    end,
    
    -- Capturer les instances importantes
    CaptureInstances = function()
        local instances = {}
        local workspace = game:GetService("Workspace")
        
        local importantPaths = {
            "Workspace.Map",
            "Workspace.Towers",
            "Workspace.Enemies",
            "Workspace.Spawns"
        }
        
        for _, path in pairs(importantPaths) do
            local instance = workspace
            for _, part in pairs(string.split(path, ".")) do
                instance = instance:FindFirstChild(part)
                if not instance then
                    break
                end
            end
            
            if instance then
                instances[path] = {
                    Exists = true,
                    ChildrenCount = #instance:GetChildren()
                }
            else
                instances[path] = {
                    Exists = false
                }
            end
        end
        
        return instances
    end,
    
    -- Capturer l'état réseau
    CaptureNetworkState = function()
        -- Placeholder pour capturer l'état réseau
        return {
            ActiveConnections = 0,
            RecentPackets = 0
        }
    end
}

-- ============================================================================
-- DÉTECTION AUTOMATIQUE DE BUGS
-- ============================================================================

AdvancedTester.BugDetector = {
    -- Scanner les erreurs dans la console
    ScanConsoleErrors = function()
        local logService = game:GetService("LogService")
        local logs = logService:GetLogHistory()
        
        local errors = {}
        
        for _, log in pairs(logs) do
            if log.messageType == Enum.MessageType.MessageError then
                table.insert(errors, {
                    Message = log.message,
                    Timestamp = log.timestamp,
                    Type = "Error"
                })
            elseif log.messageType == Enum.MessageType.MessageWarning then
                table.insert(errors, {
                    Message = log.message,
                    Timestamp = log.timestamp,
                    Type = "Warning"
                })
            end
        end
        
        return errors
    end,
    
    -- Détecter les instances orphelines
    DetectOrphanedInstances = function()
        local workspace = game:GetService("Workspace")
        local orphans = {}
        
        for _, instance in pairs(workspace:GetDescendants()) do
            if instance.Parent == nil then
                table.insert(orphans, instance:GetFullName())
            end
        end
        
        return orphans
    end,
    
    -- Détecter les scripts désactivés inattendus
    DetectDisabledScripts = function()
        local disabled = {}
        
        for _, script in pairs(game:GetDescendants()) do
            if script:IsA("Script") or script:IsA("LocalScript") then
                if script.Disabled then
                    table.insert(disabled, script:GetFullName())
                end
            end
        end
        
        return disabled
    end,
    
    -- Détecter les RemoteEvents non utilisés
    DetectUnusedRemotes = function()
        local replicatedStorage = game:GetService("ReplicatedStorage")
        local unused = {}
        
        for _, instance in pairs(replicatedStorage:GetDescendants()) do
            if instance:IsA("RemoteEvent") or instance:IsA("RemoteFunction") then
                -- Vérifier si utilisé (heuristic)
                local lastUsed = instance:GetAttribute("LastUsed")
                if not lastUsed or (tick() - lastUsed > 300) then
                    table.insert(unused, instance:GetFullName())
                end
            end
        end
        
        return unused
    end,
    
    -- Analyser les bugs et générer un rapport
    AnalyzeBugs = function()
        local report = {
            Timestamp = tick(),
            ConsoleErrors = AdvancedTester.BugDetector.ScanConsoleErrors(),
            OrphanedInstances = AdvancedTester.BugDetector.DetectOrphanedInstances(),
            DisabledScripts = AdvancedTester.BugDetector.DetectDisabledScripts(),
            UnusedRemotes = AdvancedTester.BugDetector.DetectUnusedRemotes()
        }
        
        return report
    end
}

-- ============================================================================
-- AUTOMATION DES TESTS
-- ============================================================================

AdvancedTester.Automation = {
    -- Exécuter tous les tests automatiquement
    RunAllTests = function()
        print("[TESTER] Exécution de tous les tests...")
        
        -- Tests de gameplay
        local gameplaySuite = {
            TowerPlacement = AdvancedTester.GameplayTests.TestTowerPlacement,
            TowerPurchase = AdvancedTester.GameplayTests.TestTowerPurchase,
            TowerUpgrade = AdvancedTester.GameplayTests.TestTowerUpgrade,
            TowerSell = AdvancedTester.GameplayTests.TestTowerSell,
            WaveStart = AdvancedTester.GameplayTests.TestWaveStart,
            WaveSkip = AdvancedTester.GameplayTests.TestWaveSkip
        }
        
        AdvancedTester.TestFramework.AddTestSuite("Gameplay", gameplaySuite)
        local gameplayResults = AdvancedTester.TestFramework.RunTestSuite("Gameplay")
        
        -- Tests de validation
        local validationSuite = {
            RemoteEvents = function()
                local remotes = {"PlaceTower", "BuyTower", "UpgradeTower", "SellTower", "StartWave"}
                for _, remote in pairs(remotes) do
                    local success = AdvancedTester.ValidationTests.ValidateRemoteEvent(remote)
                    if not success then
                        return false, string.format("Remote %s validation failed", remote)
                    end
                end
                return true
            end
        }
        
        AdvancedTester.TestFramework.AddTestSuite("Validation", validationSuite)
        local validationResults = AdvancedTester.TestFramework.RunTestSuite("Validation")
        
        -- Tests de performance
        local performanceSuite = {
            FPS = function()
                return AdvancedTester.PerformanceTests.MeasureFPS(5)
            end,
            Memory = function()
                return AdvancedTester.PerformanceTests.MeasureMemoryUsage()
            end
        }
        
        AdvancedTester.TestFramework.AddTestSuite("Performance", performanceSuite)
        local performanceResults = AdvancedTester.TestFramework.RunTestSuite("Performance")
        
        -- Rapport de bugs
        local bugReport = AdvancedTester.BugDetector.AnalyzeBugs()
        
        -- Rapport final
        local finalReport = {
            Gameplay = gameplayResults,
            Validation = validationResults,
            Performance = performanceResults,
            Bugs = bugReport,
            Summary = AdvancedTester.TestFramework.GenerateReport()
        }
        
        return finalReport
    end,
    
    -- Exécuter des tests en boucle
    RunContinuousTests = function(interval)
        interval = interval or 300 -- 5 minutes par défaut
        
        spawn(function()
            while true do
                local report = AdvancedTester.Automation.RunAllTests()
                
                -- Sauvegarder le rapport
                if writefile then
                    local filename = string.format("TestReport_%s.json", os.date("%Y%m%d_%H%M%S"))
                    local success, json = pcall(function()
                        return HttpService:JSONEncode(report)
                    end)
                    
                    if success then
                        writefile(filename, json)
                        print(string.format("[TESTER] Rapport sauvegardé: %s", filename))
                    end
                end
                
                wait(interval)
            end
        end)
    end
}

-- ============================================================================
-- INITIALISATION
-- ============================================================================

function AdvancedTester.Init()
    print("[ADVANCED_TESTER] Initialisation...")
    
    -- Démarrer les tests continus
    AdvancedTester.Automation.RunContinuousTests(300)
    
    print("[ADVANCED_TESTER] Tests continus démarrés (toutes les 5 minutes)")
end

return AdvancedTester
