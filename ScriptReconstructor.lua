-- ============================================================================
-- SCRIPT RECONSTRUCTOR - Reconstruction de la logique des scripts
-- Reconstruction automatique de la logique à partir de l'analyse
-- ============================================================================

local ScriptReconstructor = {}

-- ============================================================================
-- RECONSTRUCTION DE LOGIQUE
-- ============================================================================

ScriptReconstructor.LogicReconstructor = {
    -- Reconstruire la logique d'un script
    ReconstructLogic = function(scriptAnalysis)
        local purpose = scriptAnalysis.Semantic
        local structure = scriptAnalysis.Structural
        local dependencies = scriptAnalysis.Dependencies
        
        local reconstruction = {
            OriginalScript = scriptAnalysis.Structural.Path,
            Purpose = purpose.Category,
            SubPurpose = purpose.SubCategory,
            ReconstructedCode = nil,
            LogicBlocks = {},
            Functions = {},
            Variables = {},
            Events = {}
        }
        
        -- Générer le code basé sur le but
        reconstruction.ReconstructedCode = ScriptReconstructor.LogicReconstructor.GenerateCode(purpose, structure, dependencies)
        
        -- Extraire les blocs de logique
        reconstruction.LogicBlocks = ScriptReconstructor.LogicReconstructor.ExtractLogicBlocks(purpose, structure)
        
        -- Reconstruire les fonctions
        reconstruction.Functions = ScriptReconstructor.LogicReconstructor.ReconstructFunctions(structure, purpose)
        
        -- Reconstruire les variables
        reconstruction.Variables = ScriptReconstructor.LogicReconstructor.ReconstructVariables(structure)
        
        -- Reconstruire les événements
        reconstruction.Events = ScriptReconstructor.LogicReconstructor.ReconstructEvents(structure, purpose)
        
        return reconstruction
    end,
    
    -- Générer le code reconstruit
    GenerateCode = function(purpose, structure, dependencies)
        local code = "-- Reconstructed Script\n"
        code = code .. string.format("-- Purpose: %s\n", purpose.Category)
        code = code .. string.format("-- Sub-Purpose: %s\n", purpose.SubCategory or "Unknown")
        code = code .. string.format("-- Original Path: %s\n\n", structure.Path)
        
        -- Ajouter les services
        code = code .. "-- Services\n"
        for _, service in pairs(dependencies.Services) do
            code = code .. string.format("local %s = game:GetService(\"%s\")\n", service, service)
        end
        code = code .. "\n"
        
        -- Ajouter les requires
        code = code .. "-- Modules\n"
        for _, requirePath in pairs(dependencies.Requires) do
            local moduleName = requirePath:match("([^/]+)$") or "Module"
            code = code .. string.format("local %s = require(\"%s\")\n", moduleName, requirePath)
        end
        code = code .. "\n"
        
        -- Générer la logique spécifique
        code = code .. ScriptReconstructor.LogicReconstructor.GenerateSpecificLogic(purpose, structure)
        
        return code
    end,
    
    -- Générer la logique spécifique
    GenerateSpecificLogic = function(purpose, structure)
        local category = purpose.Category
        local subCategory = purpose.SubCategory
        
        local code = ""
        
        if category == "Configuration" then
            code = ScriptReconstructor.LogicReconstructor.GenerateConfigLogic(structure)
        elseif category == "Gameplay" then
            if subCategory == "Tower" then
                code = ScriptReconstructor.LogicReconstructor.GenerateTowerLogic(structure)
            elseif subCategory == "Enemy" or subCategory == "Zombie" then
                code = ScriptReconstructor.LogicReconstructor.GenerateEnemyLogic(structure)
            elseif subCategory == "Wave Management" then
                code = ScriptReconstructor.LogicReconstructor.GenerateWaveLogic(structure)
            elseif subCategory == "Combat" then
                code = ScriptReconstructor.LogicReconstructor.GenerateCombatLogic(structure)
            else
                code = ScriptReconstructor.LogicReconstructor.GenerateGenericGameplayLogic(structure)
            end
        elseif category == "UI" then
            code = ScriptReconstructor.LogicReconstructor.GenerateUILogic(structure)
        elseif category == "Server" then
            code = ScriptReconstructor.LogicReconstructor.GenerateServerLogic(structure)
        elseif category == "Client" then
            code = ScriptReconstructor.LogicReconstructor.GenerateClientLogic(structure)
        else
            code = ScriptReconstructor.LogicReconstructor.GenerateGenericLogic(structure)
        end
        
        return code
    end,
    
    -- Générer la logique de configuration
    GenerateConfigLogic = function(structure)
        local code = "local Config = {}\n\n"
        
        -- Utiliser les upvalues pour générer la config
        for _, var in pairs(structure.Variables) do
            if var.IsGameplay then
                local value = var.Value
                if var.Type == "number" then
                    code = code .. string.format("Config.%s = %s\n", var.Name, value)
                elseif var.Type == "string" then
                    code = code .. string.format("Config.%s = \"%s\"\n", var.Name, value)
                elseif var.Type == "boolean" then
                    code = code .. string.format("Config.%s = %s\n", var.Name, value)
                elseif var.Type == "table" then
                    code = code .. string.format("Config.%s = {...}\n", var.Name)
                end
            end
        end
        
        code = code .. "\nreturn Config\n"
        return code
    end,
    
    -- Générer la logique de tour
    GenerateTowerLogic = function(structure)
        local code = "local Tower = {}\n\n"
        
        -- Variables gameplay trouvées
        local gameplayVars = {}
        for _, var in pairs(structure.Variables) do
            if var.IsGameplay then
                table.insert(gameplayVars, var)
            end
        end
        
        code = code .. "-- Tower Properties\n"
        for _, var in pairs(gameplayVars) do
            code = code .. string.format("Tower.%s = %s\n", var.Name, var.Value)
        end
        code = code .. "\n"
        
        code = code .. "-- Tower Functions\n"
        code = code .. "function Tower.Initialize(tower)\n"
        code = code .. "    -- Initialize tower instance\n"
        code = code .. "    tower.Damage = Tower.Damage or 10\n"
        code = code .. "    tower.Range = Tower.Range or 50\n"
        code = code .. "    tower.Cooldown = Tower.Cooldown or 1\n"
        code = code .. "end\n\n"
        
        code = code .. "function Tower.Attack(tower, target)\n"
        code = code .. "    -- Attack logic\n"
        code = code .. "    if tower.CooldownTimer <= 0 then\n"
        code = code .. "        target.Humanoid:TakeDamage(tower.Damage)\n"
        code = code .. "        tower.CooldownTimer = tower.Cooldown\n"
        code = code .. "    end\n"
        code = code .. "end\n\n"
        
        code = code .. "function Tower.Upgrade(tower)\n"
        code = code .. "    -- Upgrade logic\n"
        code = code .. "    tower.Damage = tower.Damage * 1.5\n"
        code = code .. "    tower.Range = tower.Range * 1.1\n"
        code = code .. "end\n\n"
        
        code = code .. "return Tower\n"
        return code
    end,
    
    -- Générer la logique d'ennemi
    GenerateEnemyLogic = function(structure)
        local code = "local Enemy = {}\n\n"
        
        code = code << "-- Enemy Properties\n"
        for _, var in pairs(structure.Variables) do
            if var.IsGameplay then
                code = code .. string.format("Enemy.%s = %s\n", var.Name, var.Value)
            end
        end
        code = code .. "\n"
        
        code = code << "-- Enemy Functions\n"
        code = code << "function Enemy.Initialize(enemy)\n"
        code = code << "    -- Initialize enemy instance\n"
        code = code << "    enemy.Health = Enemy.Health or 100\n"
        code = code << "    enemy.Speed = Enemy.Speed or 16\n"
        code = code << "    enemy.Reward = Enemy.Reward or 10\n"
        code = code << "end\n\n"
        
        code = code << "function Enemy.Move(enemy, path)\n"
        code = code << "    -- Movement logic\n"
        code = code << "    local humanoid = enemy.Humanoid\n"
        code = code << "    if humanoid and path then\n"
        code = code << "        humanoid:MoveTo(path[enemy.CurrentWaypoint].Position)\n"
        code = code << "    end\n"
        code = code << "end\n\n"
        
        code = code << "function Enemy.TakeDamage(enemy, damage)\n"
        code = code << "    -- Damage logic\n"
        code = code << "    enemy.Health = enemy.Health - damage\n"
        code = code << "    if enemy.Health <= 0 then\n"
        code = code << "        enemy:Destroy()\n"
        code = code << "    end\n"
        code = code << "end\n\n"
        
        code = code << "return Enemy\n"
        return code
    end,
    
    -- Générer la logique de vague
    GenerateWaveLogic = function(structure)
        local code = "local WaveManager = {}\n\n"
        
        code = code << "-- Wave Properties\n"
        for _, var in pairs(structure.Variables) do
            if var.IsGameplay then
                code = code << string.format("WaveManager.%s = %s\n", var.Name, var.Value)
            end
        end
        code = code << "\n"
        
        code = code << "-- Wave Functions\n"
        code = code << "function WaveManager.StartWave(waveNumber)\n"
        code = code << "    -- Start wave logic\n"
        code = code << "    local waveConfig = WaveManager.Waves[waveNumber]\n"
        code = code << "    if waveConfig then\n"
        code = code << "        for _, enemyType in pairs(waveConfig.Enemies) do\n"
        code = code << "            WaveManager.SpawnEnemy(enemyType)\n"
        code = code << "        end\n"
        code = code << "    end\n"
        code = code << "end\n\n"
        
        code = code << "function WaveManager.SpawnEnemy(enemyType, path)\n"
        code = code << "    -- Spawn enemy logic\n"
        code = code << "    local enemy = Instance.new(\"Model\")\n"
        code = code << "    enemy.Name = enemyType\n"
        code = code << "    -- Setup enemy\n"
        code = code << "    enemy.Parent = workspace.Enemies\n"
        code = code << "end\n\n"
        
        code = code << "return WaveManager\n"
        return code
    end,
    
    -- Générer la logique de combat
    GenerateCombatLogic = function(structure)
        local code = "local Combat = {}\n\n"
        
        code = code << "-- Combat Functions\n"
        code = code << "function Combat.CalculateDamage(attacker, defender)\n"
        code = code << "    -- Damage calculation logic\n"
        code = code << "    local baseDamage = attacker.Damage or 10\n"
        code = code << "    local defense = defender.Defense or 0\n"
        code = code << "    local damage = math.max(1, baseDamage - defense)\n"
        code = code << "    return damage\n"
        code = code << "end\n\n"
        
        code = code << "function Combat.ApplyDamage(target, damage)\n"
        code = code << "    -- Apply damage logic\n"
        code = code << "    local humanoid = target:FindFirstChild(\"Humanoid\")\n"
        code = code << "    if humanoid then\n"
        code = code << "        humanoid:TakeDamage(damage)\n"
        code = code << "    end\n"
        code = code << "end\n\n"
        
        code = code << "return Combat\n"
        return code
    end,
    
    -- Générer la logique UI
    GenerateUILogic = function(structure)
        local code = "local UI = {}\n\n"
        
        code = code << "-- UI Functions\n"
        code = code << "function UI.Initialize()\n"
        code = code << "    -- Initialize UI\n"
        code = code << "    local playerGui = Players.LocalPlayer:WaitForChild(\"PlayerGui\")\n"
        code = code << "    -- Setup UI elements\n"
        code = code << "end\n\n"
        
        code = code << "function UI.UpdateStats()\n"
        code = code << "    -- Update stats display\n"
        code = code << "    local leaderstats = Players.LocalPlayer:FindFirstChild(\"leaderstats\")\n"
        code = code << "    if leaderstats then\n"
        code = code << "        -- Update UI with stats\n"
        code = code << "    end\n"
        code = code << "end\n\n"
        
        code = code << "function UI.ShowNotification(message)\n"
        code = code << "    -- Show notification\n"
        code = code << "    -- Display message to player\n"
        code = code << "end\n\n"
        
        code = code << "return UI\n"
        return code
    end,
    
    -- Générer la logique serveur
    GenerateServerLogic = function(structure)
        local code = "-- Server Logic\n\n"
        code = code << "-- Initialize server\n"
        code = code << "game.Players.PlayerAdded:Connect(function(player)\n"
        code = code << "    -- Handle player join\n"
        code = code << "end)\n\n"
        
        code = code << "-- Initialize game\n"
        code = code << "local function InitializeGame()\n"
        code = code << "    -- Setup game state\n"
        code = code << "end\n\n"
        
        return code
    end,
    
    -- Générer la logique client
    GenerateClientLogic = function(structure)
        local code = "-- Client Logic\n\n"
        code = code << "-- Initialize client\n"
        code = code << "local function InitializeClient()\n"
        code = code << "    -- Setup client state\n"
        code = code << "end\n\n"
        
        code = code << "-- Handle remotes\n"
        code = code << "local function SetupRemotes()\n"
        code = code << "    -- Setup remote event handlers\n"
        code = code << "end\n\n"
        
        return code
    end,
    
    -- Générer la logique générique
    GenerateGenericLogic = function(structure)
        local code = "-- Generic Script Logic\n\n"
        code = code << "-- Initialize\n"
        code = code << "local function Initialize()\n"
        code = code << "    -- Setup\n"
        code = code << "end\n\n"
        
        return code
    end,
    
    -- Extraire les blocs de logique
    ExtractLogicBlocks = function(purpose, structure)
        local blocks = {}
        
        -- Analyser les strings pour identifier les blocs
        local strings = structure.BytecodeAnalysis and structure.BytecodeAnalysis.Strings or {}
        
        for _, str in pairs(strings) do
            local lower = str:lower()
            
            if lower:find("if") or lower:find("then") or lower:find("else") then
                table.insert(blocks, {Type = "Conditional", Content = str})
            elseif lower:find("for") or lower:find("while") or lower:find("repeat") then
                table.insert(blocks, {Type = "Loop", Content = str})
            elseif lower:find("function") then
                table.insert(blocks, {Type = "Function", Content = str})
            end
        end
        
        return blocks
    end,
    
    -- Reconstruire les fonctions
    ReconstructFunctions = function(structure, purpose)
        local functions = {}
        
        -- Analyser les constants pour trouver les fonctions
        for _, const in pairs(structure.Functions) do
            local funcInfo = {
                Name = "Unknown",
                Parameters = {},
                ReturnType = "Unknown",
                Purpose = ScriptReconstructor.LogicReconstructor.InferFunctionPurpose(const, purpose)
            }
            
            table.insert(functions, funcInfo)
        end
        
        return functions
    end,
    
    -- Inférer le but d'une fonction
    InferFunctionPurpose = function(func, scriptPurpose)
        local purpose = "Unknown"
        
        -- Basé sur le but du script
        if scriptPurpose.Category == "Gameplay" then
            if scriptPurpose.SubCategory == "Tower" then
                purpose = "Tower-related function"
            elseif scriptPurpose.SubCategory == "Enemy" then
                purpose = "Enemy-related function"
            end
        end
        
        return purpose
    end,
    
    -- Reconstruire les variables
    ReconstructVariables = function(structure)
        local variables = {}
        
        for _, var in pairs(structure.Variables) do
            local varInfo = {
                Name = var.Name,
                Type = var.Type,
                Value = var.Value,
                IsGameplay = var.IsGameplay,
                Scope = "Global"
            }
            
            table.insert(variables, varInfo)
        end
        
        return variables
    end,
    
    -- Reconstruire les événements
    ReconstructEvents = function(structure, purpose)
        local events = {}
        
        local patterns = structure.BytecodeAnalysis and structure.BytecodeAnalysis.Patterns or {}
        
        if patterns.Events then
            for _, event in pairs(patterns.Events) do
                local eventInfo = {
                    Name = event,
                    Handler = "Unknown",
                    Purpose = ScriptReconstructor.LogicReconstructor.InferEventPurpose(event, purpose)
                }
                
                table.insert(events, eventInfo)
            end
        end
        
        return events
    end,
    
    -- Inférer le but d'un événement
    InferEventPurpose = function(event, scriptPurpose)
        local purpose = "Unknown"
        
        if event == "Died" then
            purpose = "Handle death"
        elseif event == "Touched" then
            purpose = "Handle collision"
        elseif event == "Changed" then
            purpose = "Handle property change"
        elseif event == "ChildAdded" then
            purpose = "Handle child addition"
        end
        
        return purpose
    end
}

-- ============================================================================
-- RECONSTRUCTION DE MAP
-- ============================================================================

ScriptReconstructor.MapReconstructor = {
    -- Reconstruire la map à partir des instances
    ReconstructMap = function()
        local mapData = {
            Workspace = {},
            Terrain = {},
            Lighting = {},
            SpawnPoints = {},
            Paths = {}
        }
        
        local workspace = game:GetService("Workspace")
        
        -- Capturer le Workspace
        for _, instance in pairs(workspace:GetChildren()) do
            local instanceData = ScriptReconstructor.MapReconstructor.SerializeInstance(instance)
            table.insert(mapData.Workspace, instanceData)
        end
        
        -- Capturer le Terrain
        local terrain = workspace:FindFirstChild("Terrain")
        if terrain then
            mapData.Terrain = {
                MaterialColors = {},
                WaterColor = terrain.WaterColor3 and {
                    R = terrain.WaterColor3.R,
                    G = terrain.WaterColor3.G,
                    B = terrain.WaterColor3.B
                } or nil
            }
        end
        
        -- Capturer les SpawnPoints
        for _, instance in pairs(workspace:GetDescendants()) do
            if instance:IsA("SpawnLocation") then
                table.insert(mapData.SpawnPoints, {
                    Name = instance.Name,
                    Position = instance.Position,
                    Team = instance.Team and instance.Team.Name or "Neutral"
                })
            end
        end
        
        -- Capturer les chemins (heuristique)
        local pathFolders = workspace:FindFirstChild("Paths") or workspace:FindFirstChild("Path")
        if pathFolders then
            for _, path in pairs(pathFolders:GetChildren()) do
                local pathData = {
                    Name = path.Name,
                    Waypoints = {}
                }
                
                for _, waypoint in pairs(path:GetChildren()) do
                    if waypoint:IsA("BasePart") or waypoint:IsA("Attachment") then
                        table.insert(pathData.Waypoints, {
                            Name = waypoint.Name,
                            Position = waypoint:IsA("BasePart") and waypoint.Position or waypoint.Position,
                            Type = waypoint.ClassName
                        })
                    end
                end
                
                table.insert(mapData.Paths, pathData)
            end
        end
        
        return mapData
    end,
    
    -- Sérialiser une instance
    SerializeInstance = function(instance)
        local data = {
            ClassName = instance.ClassName,
            Name = instance.Name,
            Properties = {},
            Children = {}
        }
        
        -- Propriétés de base
        local basicProps = {"Anchored", "Position", "Size", "CFrame", "Color", "Material", "Transparency", "CanCollide"}
        for _, propName in pairs(basicProps) do
            local success, value = pcall(function()
                return instance[propName]
            end)
            if success then
                data.Properties[propName] = value
            end
        end
        
        -- Enfants
        for _, child in pairs(instance:GetChildren()) do
            table.insert(data.Children, ScriptReconstructor.MapReconstructor.SerializeInstance(child))
        end
        
        return data
    end
}

-- ============================================================================
-- RECONSTRUCTION COMPLÈTE
-- ============================================================================

function ScriptReconstructor.ReconstructAllScripts()
    print("[SCRIPT_RECONSTRUCTOR] Reconstruction de tous les scripts...")
    
    local results = {
        Timestamp = tick(),
        Scripts = {},
        Map = nil,
        Summary = {
            TotalScripts = 0,
            ReconstructedScripts = 0,
            FailedReconstructions = 0
        }
    }
    
    -- Reconstruire la map
    results.Map = ScriptReconstructor.MapReconstructor.ReconstructMap()
    
    -- Reconstruire les scripts
    for _, script in pairs(game:GetDescendants()) do
        if script:IsA("Script") or script:IsA("LocalScript") or script:IsA("ModuleScript") then
            results.Summary.TotalScripts = results.Summary.TotalScripts + 1
            
            local analysis = ScriptAnalyzer.AnalyzeScript(script)
            local reconstruction = ScriptReconstructor.LogicReconstructor.ReconstructLogic(analysis)
            
            table.insert(results.Scripts, reconstruction)
            
            if reconstruction.ReconstructedCode then
                results.Summary.ReconstructedScripts = results.Summary.ReconstructedScripts + 1
            else
                results.Summary.FailedReconstructions = results.Summary.FailedReconstructions + 1
            end
        end
    end
    
    print(string.format("[SCRIPT_RECONSTRUCTOR] Reconstruction terminée - %d scripts", results.Summary.TotalScripts))
    print(string.format("[SCRIPT_RECONSTRUCTOR] Reconstruits: %d", results.Summary.ReconstructedScripts))
    print(string.format("[SCRIPT_RECONSTRUCTOR] Échoués: %d", results.Summary.FailedReconstructions))
    
    return results
end

return ScriptReconstructor
