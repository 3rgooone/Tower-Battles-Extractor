-- ============================================================================
-- SCRIPT ANALYZER - Analyse statique des scripts
-- Analyse approfondie pour comprendre la logique et la structure des scripts
-- ============================================================================

local ScriptAnalyzer = {}

-- ============================================================================
-- ANALYSE STRUCTURELLE
-- ============================================================================

ScriptAnalyzer.StructuralAnalysis = {
    -- Analyser la structure d'un script
    AnalyzeStructure = function(script)
        local analysis = {
            Name = script.Name,
            ClassName = script.ClassName,
            Path = script:GetFullName(),
            Disabled = script.Disabled,
            
            -- Structure
            Functions = {},
            Variables = {},
            Tables = {},
            Loops = {},
            Conditionals = {},
            
            -- Dépendances
            Requires = {},
            Services = {},
            Events = {},
            
            -- Métriques
            Complexity = 0,
            LinesOfCode = 0,
            CyclomaticComplexity = 0
        }
        
        -- Récupérer le bytecode si disponible
        if getscriptbytecode then
            local success, bytecode = pcall(function()
                return getscriptbytecode(script)
            end)
            if success then
                analysis.BytecodeAnalysis = ScriptAnalyzer.StructuralAnalysis.AnalyzeBytecodeStructure(bytecode)
            end
        end
        
        -- Récupérer les upvalues
        if getupvalues then
            local success, upvalues = pcall(function()
                return getupvalues(script)
            end)
            if success then
                for name, value in pairs(upvalues) do
                    local varInfo = ScriptAnalyzer.StructuralAnalysis.AnalyzeVariable(name, value)
                    table.insert(analysis.Variables, varInfo)
                end
            end
        end
        
        -- Récupérer les constants
        if getconstants then
            local success, constants = pcall(function()
                return getconstants(script)
            end)
            if success then
                for _, const in pairs(constants) do
                    local constInfo = ScriptAnalyzer.StructuralAnalysis.AnalyzeConstant(const)
                    if constInfo.Type == "function" then
                        table.insert(analysis.Functions, constInfo)
                    elseif constInfo.Type == "table" then
                        table.insert(analysis.Tables, constInfo)
                    end
                end
            end
        end
        
        return analysis
    end,
    
    -- Analyser la structure du bytecode
    AnalyzeBytecodeStructure = function(bytecode)
        local structure = {
            Header = bytecode:sub(1, 20),
            Strings = ScriptAnalyzer.StructuralAnalysis.ExtractStrings(bytecode),
            Numbers = ScriptAnalyzer.StructuralAnalysis.ExtractNumbers(bytecode),
            Patterns = ScriptAnalyzer.StructuralAnalysis.ExtractPatterns(bytecode)
        }
        
        return structure
    end,
    
    -- Extraire les strings
    ExtractStrings = function(bytecode)
        local strings = {}
        for str in bytecode:gmatch("[\x20-\x7E]{3,}") do
            if #str > 2 and #str < 200 then
                table.insert(strings, str)
            end
        end
        return strings
    end,
    
    -- Extraire les nombres
    ExtractNumbers = function(bytecode)
        local numbers = {}
        for num in bytecode:gmatch("[%d%.%-]+") do
            local n = tonumber(num)
            if n and n > -1e9 and n < 1e9 then
                table.insert(numbers, n)
            end
        end
        return numbers
    end,
    
    -- Extraire les patterns
    ExtractPatterns = function(bytecode)
        local patterns = {
            Functions = {},
            Events = {},
            Methods = {}
        }
        
        local lower = bytecode:lower()
        
        -- Patterns de fonctions Roblox
        local robloxFunctions = {
            "FireServer", "InvokeServer", "OnClientEvent", "OnServerEvent",
            "Destroy", "Clone", "WaitForChild", "FindFirstChild",
            "GetChildren", "GetDescendants", "IsA", "IsA",
            "Connect", "Disconnect", "Wait", "Spawn",
            "Tweens", "Create", "Play", "Stop", "Pause"
        }
        
        for _, func in pairs(robloxFunctions) do
            if lower:find(func:lower()) then
                table.insert(patterns.Functions, func)
            end
        end
        
        -- Patterns d'événements
        local events = {
            "Changed", "ChildAdded", "ChildRemoved", "DescendantAdded",
            "DescendantRemoving", "Died", "Touched", "Hit"
        }
        
        for _, event in pairs(events) do
            if lower:find(event:lower()) then
                table.insert(patterns.Events, event)
            end
        end
        
        return patterns
    end,
    
    -- Analyser une variable
    AnalyzeVariable = function(name, value)
        local valueType = type(value)
        
        return {
            Name = tostring(name),
            Type = valueType,
            Value = valueType == "table" and "table" or tostring(value),
            IsGameplay = ScriptAnalyzer.StructuralAnalysis.IsGameplayValue(name, value)
        }
    end,
    
    -- Analyser une constante
    AnalyzeConstant = function(const)
        local constType = type(const)
        
        return {
            Type = constType,
            Value = constType == "table" and "table" or tostring(const),
            IsGameplay = ScriptAnalyzer.StructuralAnalysis.IsGameplayValue("constant", const)
        }
    end,
    
    -- Vérifier si c'est une valeur gameplay
    IsGameplayValue = function(name, value)
        local keywords = {"Damage", "Range", "Wave", "Price", "Health", "Cost", "Speed", "Cooldown", "Tower", "Zombie", "Reward", "Level", "Upgrade", "Spawn", "Path", "Difficulty", "Money", "Cash", "Gold", "Coins", "Currency", "HP", "Attack", "Defense", "Rate", "Interval"}
        
        local nameStr = tostring(name):lower()
        local valueStr = tostring(value):lower()
        
        for _, keyword in pairs(keywords) do
            if nameStr:find(keyword:lower()) or valueStr:find(keyword:lower()) then
                return true
            end
        end
        
        return false
    end
}

-- ============================================================================
-- ANALYSE SÉMANTIQUE
-- ============================================================================

ScriptAnalyzer.SemanticAnalysis = {
    -- Analyser le sens/purpose d'un script
    AnalyzePurpose = function(script)
        local analysis = ScriptAnalyzer.StructuralAnalysis.AnalyzeStructure(script)
        
        local purpose = {
            Category = "Unknown",
            SubCategory = "Unknown",
            Confidence = 0,
            Reasoning = {},
            LikelyFunctionality = {}
        }
        
        local name = script.Name:lower()
        local path = script:GetFullName():lower()
        local strings = analysis.BytecodeAnalysis and analysis.BytecodeAnalysis.Strings or {}
        
        -- Catégorisation basée sur le nom
        if name:find("config") or name:find("settings") or name:find("data") then
            purpose.Category = "Configuration"
            purpose.Confidence = 0.9
            table.insert(purpose.Reasoning, "Name suggests configuration")
        elseif name:find("tower") then
            purpose.Category = "Gameplay"
            purpose.SubCategory = "Tower"
            purpose.Confidence = 0.85
            table.insert(purpose.Reasoning, "Name suggests tower-related")
        elseif name:find("zombie") or name:find("enemy") or name:find("mob") then
            purpose.Category = "Gameplay"
            purpose.SubCategory = "Enemy"
            purpose.Confidence = 0.85
            table.insert(purpose.Reasoning, "Name suggests enemy-related")
        elseif name:find("wave") then
            purpose.Category = "Gameplay"
            purpose.SubCategory = "Wave Management"
            purpose.Confidence = 0.85
            table.insert(purpose.Reasoning, "Name suggests wave management")
        elseif name:find("damage") or name:find("attack") or name:find("combat") then
            purpose.Category = "Gameplay"
            purpose.SubCategory = "Combat"
            purpose.Confidence = 0.8
            table.insert(purpose.Reasoning, "Name suggests combat")
        elseif name:find("ui") or name:find("gui") or name:find("interface") then
            purpose.Category = "UI"
            purpose.Confidence = 0.9
            table.insert(purpose.Reasoning, "Name suggests UI")
        elseif name:find("server") then
            purpose.Category = "Server"
            purpose.Confidence = 0.8
            table.insert(purpose.Reasoning, "Name suggests server-side")
        elseif name:find("client") then
            purpose.Category = "Client"
            purpose.Confidence = 0.8
            table.insert(purpose.Reasoning, "Name suggests client-side")
        elseif name:find("main") or name:find("init") or name:find("start") then
            purpose.Category = "Initialization"
            purpose.Confidence = 0.7
            table.insert(purpose.Reasoning, "Name suggests initialization")
        end
        
        -- Catégorisation basée sur le chemin
        if path:find("replicatedstorage") then
            if purpose.Category == "Unknown" then
                purpose.Category = "Shared"
                purpose.Confidence = 0.6
                table.insert(purpose.Reasoning, "Located in ReplicatedStorage")
            end
        elseif path:find("serverscriptservice") then
            if purpose.Category == "Unknown" then
                purpose.Category = "Server"
                purpose.Confidence = 0.8
                table.insert(purpose.Reasoning, "Located in ServerScriptService")
            end
        elseif path:find("startergui") or path:find("playergui") then
            if purpose.Category == "Unknown" then
                purpose.Category = "UI"
                purpose.Confidence = 0.8
                table.insert(purpose.Reasoning, "Located in GUI")
            end
        elseif path:find("starterplayer") then
            if purpose.Category == "Unknown" then
                purpose.Category = "Initialization"
                purpose.Confidence = 0.7
                table.insert(purpose.Reasoning, "Located in StarterPlayer")
            end
        end
        
        -- Catégorisation basée sur les strings
        local gameplayKeywords = {"damage", "range", "wave", "price", "health", "cost", "speed", "cooldown", "tower", "zombie", "reward", "level", "upgrade", "spawn", "path", "difficulty"}
        local gameplayCount = 0
        
        for _, str in pairs(strings) do
            local lowerStr = str:lower()
            for _, keyword in pairs(gameplayKeywords) do
                if lowerStr:find(keyword) then
                    gameplayCount = gameplayCount + 1
                    break
                end
            end
        end
        
        if gameplayCount > 5 then
            if purpose.Category == "Unknown" then
                purpose.Category = "Gameplay"
                purpose.Confidence = 0.7
                table.insert(purpose.Reasoning, "Contains many gameplay keywords")
            end
        end
        
        -- Inférer la fonctionnalité
        purpose.LikelyFunctionality = ScriptAnalyzer.SemanticAnalysis.InferFunctionality(analysis)
        
        return purpose
    end,
    
    -- Inférer la fonctionnalité
    InferFunctionality = function(analysis)
        local functionality = {}
        
        local strings = analysis.BytecodeAnalysis and analysis.BytecodeAnalysis.Strings or {}
        local patterns = analysis.BytecodeAnalysis and analysis.BytecodeAnalysis.Patterns or {}
        
        -- Détection des fonctionnalités basées sur les strings
        for _, str in pairs(strings) do
            local lower = str:lower()
            
            if lower:find("place") or lower:find("spawn") then
                table.insert(functionality, "Object Placement/Spawning")
            elseif lower:find("damage") or lower:find("attack") then
                table.insert(functionality, "Damage Calculation")
            elseif lower:find("buy") or lower:find("purchase") or lower:find("cost") then
                table.insert(functionality, "Purchase System")
            elseif lower:find("upgrade") then
                table.insert(functionality, "Upgrade System")
            elseif lower:find("sell") then
                table.insert(functionality, "Sell System")
            elseif lower:find("wave") then
                table.insert(functionality, "Wave Management")
            elseif lower:find("reward") or lower:find("money") or lower:find("cash") then
                table.insert(functionality, "Currency/Reward System")
            elseif lower:find("health") or lower:find("hp") then
                table.insert(functionality, "Health Management")
            elseif lower:find("speed") or lower:find("cooldown") then
                table.insert(functionality, "Speed/Cooldown Management")
            end
        end
        
        -- Détection basée sur les patterns
        if patterns.Functions then
            for _, func in pairs(patterns.Functions) do
                if func == "FireServer" or func == "InvokeServer" then
                    table.insert(functionality, "Network Communication")
                elseif func == "Connect" then
                    table.insert(functionality, "Event Handling")
                elseif func == "WaitForChild" then
                    table.insert(functionality, "Instance Access")
                end
            end
        end
        
        return functionality
    end
}

-- ============================================================================
-- ANALYSE DE DÉPENDANCES
-- ============================================================================

ScriptAnalyzer.DependencyAnalysis = {
    -- Analyser les dépendances d'un script
    AnalyzeDependencies = function(script)
        local dependencies = {
            Requires = {},
            Services = {},
            Instances = {},
            Modules = {},
            ExternalAssets = {}
        }
        
        -- Récupérer les constants pour trouver les requires
        if getconstants then
            local success, constants = pcall(function()
                return getconstants(script)
            end)
            if success then
                for _, const in pairs(constants) do
                    if type(const) == "string" then
                        local lower = const:lower()
                        
                        -- Detect requires
                        if lower:find("game/") or lower:find("replicatedstorage/") or lower:find("workspace/") then
                            table.insert(dependencies.Requires, const)
                        end
                        
                        -- Detect services
                        local knownServices = {"Players", "ReplicatedStorage", "Workspace", "Lighting", "TweenService", "HttpService", "RunService", "Debris", "SoundService", "MarketplaceService"}
                        for _, service in pairs(knownServices) do
                            if lower:find(service:lower()) then
                                table.insert(dependencies.Services, service)
                            end
                        end
                        
                        -- Detect asset IDs
                        if const:find("rbxassetid://") then
                            table.insert(dependencies.ExternalAssets, const)
                        end
                    end
                end
            end
        end
        
        -- Analyser les upvalues pour trouver les instances
        if getupvalues then
            local success, upvalues = pcall(function()
                return getupvalues(script)
            end)
            if success then
                for _, value in pairs(upvalues) do
                    if type(value) == "userdata" and typeof(value) == "Instance" then
                        table.insert(dependencies.Instances, {
                            ClassName = value.ClassName,
                            Name = value.Name,
                            Path = value:GetFullName()
                        })
                    end
                end
            end
        end
        
        return dependencies
    end
}

-- ============================================================================
-- ANALYSE DE FLUX DE CONTRÔLE
-- ============================================================================

ScriptAnalyzer.ControlFlowAnalysis = {
    -- Analyser le flux de contrôle
    AnalyzeControlFlow = function(script)
        local flow = {
            HasLoops = false,
            HasConditionals = false,
            HasRecursion = false,
            HasAsyncOperations = false,
            LoopTypes = {},
            ConditionalTypes = {}
        }
        
        -- Analyser le bytecode pour détecter les patterns de flux
        if getscriptbytecode then
            local success, bytecode = pcall(function()
                return getscriptbytecode(script)
            end)
            if success then
                local lower = bytecode:lower()
                
                -- Détecter les boucles
                if lower:find("for") or lower:find("while") or lower:find("repeat") then
                    flow.HasLoops = true
                end
                
                -- Détecter les conditionnels
                if lower:find("if") or lower:find("else") or lower:find("elseif") then
                    flow.HasConditionals = true
                end
                
                -- Détecter les opérations async
                if lower:find("wait") or lower:find("spawn") or lower:find("delay") or lower:find("task.wait") then
                    flow.HasAsyncOperations = true
                end
                
                -- Détecter la récursion (heuristic)
                local functionCount = 0
                for func in lower:gmatch("function") do
                    functionCount = functionCount + 1
                end
                if functionCount > 3 then
                    flow.HasRecursion = true
                end
            end
        end
        
        return flow
    end
}

-- ============================================================================
-- ANALYSE COMPLÈTE
-- ============================================================================

function ScriptAnalyzer.AnalyzeScript(script)
    print(string.format("[SCRIPT_ANALYZER] Analyse du script: %s", script.Name))
    
    local analysis = {
        Structural = ScriptAnalyzer.StructuralAnalysis.AnalyzeStructure(script),
        Semantic = ScriptAnalyzer.SemanticAnalysis.AnalyzePurpose(script),
        Dependencies = ScriptAnalyzer.DependencyAnalysis.AnalyzeDependencies(script),
        ControlFlow = ScriptAnalyzer.ControlFlowAnalysis.AnalyzeControlFlow(script),
        Timestamp = tick()
    }
    
    return analysis
end

function ScriptAnalyzer.AnalyzeAllScripts()
    print("[SCRIPT_ANALYZER] Analyse de tous les scripts...")
    
    local results = {
        Timestamp = tick(),
        Scripts = {},
        Summary = {
            TotalScripts = 0,
            ByCategory = {},
            ByPurpose = {}
        }
    }
    
    for _, script in pairs(game:GetDescendants()) do
        if script:IsA("Script") or script:IsA("LocalScript") or script:IsA("ModuleScript") then
            results.Summary.TotalScripts = results.Summary.TotalScripts + 1
            
            local analysis = ScriptAnalyzer.AnalyzeScript(script)
            table.insert(results.Scripts, analysis)
            
            -- Catégoriser
            local category = analysis.Semantic.Category
            results.Summary.ByCategory[category] = (results.Summary.ByCategory[category] or 0) + 1
            
            local subCategory = analysis.Semantic.SubCategory
            if subCategory ~= "Unknown" then
                results.Summary.ByPurpose[subCategory] = (results.Summary.ByPurpose[subCategory] or 0) + 1
            end
        end
    end
    
    print(string.format("[SCRIPT_ANALYZER] Analyse terminée - %d scripts analysés", results.Summary.TotalScripts))
    
    return results
end

return ScriptAnalyzer
