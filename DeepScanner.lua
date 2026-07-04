-- ============================================================================
-- DEEP SCANNER - Récupération des fichiers/parties cachés
-- Scan profond pour découvrir tout ce qui est caché ou inaccessible normalement
-- ============================================================================

local DeepScanner = {}

-- ============================================================================
-- SCAN DU GARBAGE COLLECTOR AVANCÉ
-- ============================================================================

DeepScanner.GCScanner = {
    -- Scanner toutes les tables du GC
    ScanAllGC = function()
        if not getgc then
            return {Available = false, Reason = "getgc not available"}
        end
        
        local results = {
            TotalTables = 0,
            GameplayTables = {},
            HiddenTables = {},
            ScriptEnvironments = {},
            RemoteReferences = {},
            ModuleCaches = {}
        }
        
        -- Scanner toutes les tables
        local allTables = getgc(true)
        results.TotalTables = #allTables
        
        for _, tbl in pairs(allTables) do
            local tableInfo = DeepScanner.GCScanner.AnalyzeTable(tbl)
            
            -- Catégoriser
            if tableInfo.IsGameplay then
                table.insert(results.GameplayTables, tableInfo)
            elseif tableInfo.IsHidden then
                table.insert(results.HiddenTables, tableInfo)
            elseif tableInfo.IsScriptEnv then
                table.insert(results.ScriptEnvironments, tableInfo)
            elseif tableInfo.IsRemoteRef then
                table.insert(results.RemoteReferences, tableInfo)
            elseif tableInfo.IsModuleCache then
                table.insert(results.ModuleCaches, tableInfo)
            end
        end
        
        return results
    end,
    
    -- Analyser une table du GC
    AnalyzeTable = function(tbl)
        local info = {
            Address = tostring(tbl),
            Keys = {},
            Values = {},
            IsGameplay = false,
            IsHidden = false,
            IsScriptEnv = false,
            IsRemoteRef = false,
            IsModuleCache = false
        }
        
        -- Analyser les clés et valeurs
        for k, v in pairs(tbl) do
            local keyInfo = DeepScanner.GCScanner.AnalyzeValue(k)
            local valueInfo = DeepScanner.GCScanner.AnalyzeValue(v)
            
            table.insert(info.Keys, keyInfo)
            table.insert(info.Values, valueInfo)
            
            -- Détection gameplay
            if keyInfo.IsGameplayKeyword or valueInfo.IsGameplayKeyword then
                info.IsGameplay = true
            end
            
            -- Détection environnement de script
            if keyInfo.Type == "string" and (keyInfo.Value == "script" or keyInfo.Value == "_ENV") then
                info.IsScriptEnv = true
            end
            
            -- Détection référence Remote
            if valueInfo.Type == "Instance" and (valueInfo.ClassName == "RemoteEvent" or valueInfo.ClassName == "RemoteFunction") then
                info.IsRemoteRef = true
            end
        end
        
        -- Détection tables cachées (noms obscurs)
        if #info.Keys > 0 and #info.Keys < 5 then
            local hasObscureKeys = false
            for _, key in pairs(info.Keys) do
                if key.Type == "string" and key.Value:match("^[%d_]+$") then
                    hasObscureKeys = true
                    break
                end
            end
            if hasObscureKeys then
                info.IsHidden = true
            end
        end
        
        -- Détection cache de module
        if #info.Keys > 0 then
            for _, key in pairs(info.Keys) do
                if key.Type == "string" and key.Value:lower():find("cache") then
                    info.IsModuleCache = true
                    break
                end
            end
        end
        
        return info
    end,
    
    -- Analyser une valeur
    AnalyzeValue = function(value)
        local valueType = type(value)
        local info = {
            Type = valueType,
            Value = nil,
            ClassName = nil,
            IsGameplayKeyword = false
        }
        
        if valueType == "string" then
            info.Value = value
            -- Vérifier si c'est un mot-clé gameplay
            local keywords = {"Damage", "Range", "Wave", "Price", "Health", "Cost", "Speed", "Cooldown", "Tower", "Zombie", "Reward", "Level", "Upgrade", "Spawn", "Path", "Difficulty", "Money", "Cash", "Gold", "Coins", "Currency", "HP", "Attack", "Defense", "Rate", "Interval"}
            for _, keyword in pairs(keywords) do
                if value:find(keyword) then
                    info.IsGameplayKeyword = true
                    break
                end
            end
        elseif valueType == "number" then
            info.Value = value
        elseif valueType == "boolean" then
            info.Value = value
        elseif valueType == "table" then
            info.Value = "table"
        elseif valueType == "function" then
            info.Value = "function"
        elseif valueType == "userdata" then
            local robloxType = typeof(value)
            info.ClassName = robloxType
            if robloxType == "Instance" then
                info.Value = value:GetFullName()
            else
                info.Value = robloxType
            end
        end
        
        return info
    end
}

-- ============================================================================
-- SCAN DU REGISTRE (getreg)
-- ============================================================================

DeepScanner.RegistryScanner = {
    -- Scanner le registre Lua
    ScanRegistry = function()
        if not getreg then
            return {Available = false, Reason = "getreg not available"}
        end
        
        local results = {
            TotalEntries = 0,
            Functions = {},
            Upvalues = {},
            Constants = {},
            HiddenFunctions = {}
        }
        
        local registry = getreg()
        results.TotalEntries = #registry
        
        for i, value in pairs(registry) do
            local valueType = type(value)
            
            if valueType == "function" then
                local funcInfo = DeepScanner.RegistryScanner.AnalyzeFunction(value)
                table.insert(results.Functions, funcInfo)
                
                if funcInfo.IsHidden then
                    table.insert(results.HiddenFunctions, funcInfo)
                end
            elseif valueType == "table" then
                local tableInfo = DeepScanner.GCScanner.AnalyzeTable(value)
                table.insert(results.Upvalues, tableInfo)
            end
        end
        
        return results
    end,
    
    -- Analyser une fonction
    AnalyzeFunction = function(func)
        local info = {
            Address = tostring(func),
            Name = "Unknown",
            Upvalues = {},
            Constants = {},
            IsHidden = false,
            IsGameplay = false
        }
        
        -- Récupérer les upvalues
        if getupvalues then
            local success, upvalues = pcall(function()
                return getupvalues(func)
            end)
            if success then
                for k, v in pairs(upvalues) do
                    table.insert(info.Upvalues, {
                        Name = tostring(k),
                        Value = DeepScanner.GCScanner.AnalyzeValue(v)
                    })
                end
            end
        end
        
        -- Récupérer les constants
        if getconstants then
            local success, constants = pcall(function()
                return getconstants(func)
            end)
            if success then
                for _, const in pairs(constants) do
                    table.insert(info.Constants, DeepScanner.GCScanner.AnalyzeValue(const))
                end
            end
        end
        
        -- Détection fonctions cachées
        local infoSuccess, funcInfo = pcall(function()
            return debug.getinfo(func)
        end)
        
        if infoSuccess then
            info.Name = funcInfo.name or "Unknown"
            
            -- Fonctions sans nom ou avec nom obscurci
            if not funcInfo.name or funcInfo.name:match("^[%d_]+$") then
                info.IsHidden = true
            end
        end
        
        -- Détection gameplay
        for _, upvalue in pairs(info.Upvalues) do
            if upvalue.Value.IsGameplayKeyword then
                info.IsGameplay = true
                break
            end
        end
        
        return info
    end
}

-- ============================================================================
-- SCAN DES SCRIPTS CACHÉS
-- ============================================================================

DeepScanner.HiddenScriptScanner = {
    -- Trouver les scripts qui ne sont pas dans l'arbre visible
    FindHiddenScripts = function()
        local results = {
            VisibleScripts = {},
            HiddenScripts = {},
            DisabledScripts = {},
            EncryptedScripts = {}
        }
        
        -- Scripts visibles
        for _, script in pairs(game:GetDescendants()) do
            if script:IsA("Script") or script:IsA("LocalScript") or script:IsA("ModuleScript") then
                table.insert(results.VisibleScripts, script:GetFullName())
                
                if script.Disabled then
                    table.insert(results.DisabledScripts, script:GetFullName())
                end
            end
        end
        
        -- Scripts dans le GC (cachés)
        if getgc then
            local allTables = getgc(true)
            for _, tbl in pairs(allTables) do
                -- Chercher des références à des scripts
                for k, v in pairs(tbl) do
                    if type(v) == "userdata" and typeof(v) == "Instance" then
                        if v:IsA("Script") or v:IsA("LocalScript") or v:IsA("ModuleScript") then
                            local path = v:GetFullName()
                            local isVisible = false
                            
                            for _, visiblePath in pairs(results.VisibleScripts) do
                                if visiblePath == path then
                                    isVisible = true
                                    break
                                end
                            end
                            
                            if not isVisible then
                                table.insert(results.HiddenScripts, {
                                    Path = path,
                                    Source = tostring(tbl)
                                })
                            end
                        end
                    end
                end
            end
        end
        
        -- Scripts encryptés (bytecode anormal)
        for _, script in pairs(game:GetDescendants()) do
            if script:IsA("Script") or script:IsA("LocalScript") or script:IsA("ModuleScript") then
                if getscriptbytecode then
                    local success, bytecode = pcall(function()
                        return getscriptbytecode(script)
                    end)
                    if success then
                        if DeepScanner.HiddenScriptScanner.IsEncrypted(bytecode) then
                            table.insert(results.EncryptedScripts, script:GetFullName())
                        end
                    end
                end
            end
        end
        
        return results
    end,
    
    -- Vérifier si le bytecode est encrypté
    IsEncrypted = function(bytecode)
        -- Heuristiques pour détecter l'encryption
        local header = bytecode:sub(1, 20)
        
        -- Bytecode Luau normal commence par des patterns spécifiques
        -- Bytecode encrypté a souvent des caractères nuls ou est très court
        if header:find("\0") or #bytecode < 50 then
            return true
        end
        
        return false
    end
}

-- ============================================================================
-- SCAN DES ASSETS CACHÉS
-- ============================================================================

DeepScanner.HiddenAssetScanner = {
    -- Trouver les assets qui ne sont pas référencés visiblement
    FindHiddenAssets = function()
        local results = {
            VisibleAssets = {},
            HiddenAssets = {},
            UnreferencedAssets = {}
        }
        
        -- Assets visibles (référencés dans les instances)
        for _, instance in pairs(game:GetDescendants()) do
            if instance:IsA("ImageLabel") or instance:IsA("ImageButton") then
                if instance.Image and instance.Image ~= "" then
                    table.insert(results.VisibleAssets, {
                        Type = "Image",
                        AssetId = instance.Image,
                        Source = instance:GetFullName()
                    })
                end
            elseif instance:IsA("Sound") then
                if instance.SoundId and instance.SoundId ~= "" then
                    table.insert(results.VisibleAssets, {
                        Type = "Sound",
                        AssetId = instance.SoundId,
                        Source = instance:GetFullName()
                    })
                end
            elseif instance:IsA("MeshPart") or instance:IsA("SpecialMesh") then
                local assetId = instance:IsA("MeshPart") and instance.MeshId or instance.MeshId
                if assetId and assetId ~= "" then
                    table.insert(results.VisibleAssets, {
                        Type = "Mesh",
                        AssetId = assetId,
                        Source = instance:GetFullName()
                    })
                end
            elseif instance:IsA("Animation") then
                if instance.AnimationId and instance.AnimationId ~= "" then
                    table.insert(results.VisibleAssets, {
                        Type = "Animation",
                        AssetId = instance.AnimationId,
                        Source = instance:GetFullName()
                    })
                end
            end
        end
        
        -- Assets dans le GC (référencés mais pas visibles)
        if getgc then
            local allTables = getgc(true)
            for _, tbl in pairs(allTables) do
                for k, v in pairs(tbl) do
                    if type(v) == "string" and v:find("rbxassetid://") then
                        local isReferenced = false
                        for _, asset in pairs(results.VisibleAssets) do
                            if asset.AssetId == v then
                                isReferenced = true
                                break
                            end
                        end
                        
                        if not isReferenced then
                            table.insert(results.HiddenAssets, {
                                AssetId = v,
                                Source = tostring(tbl)
                            })
                        end
                    end
                end
            end
        end
        
        return results
    end,
    
    -- Scanner les ContentProvider pour les assets préchargés
    ScanContentProvider = function()
        local contentProvider = game:GetService("ContentProvider")
        local results = {
            PreloadedAssets = {},
            QueuedAssets = {}
        }
        
        -- Tenter d'accéder aux assets préchargés
        if gethiddenproperty then
            local success, preloaded = pcall(function()
                return gethiddenproperty(contentProvider, "Preloaded")
            end)
            if success then
                results.PreloadedAssets = preloaded
            end
        end
        
        return results
    end
}

-- ============================================================================
-- SCAN DES PROPRIÉTÉS CACHÉES
-- ============================================================================

DeepScanner.HiddenPropertyScanner = {
    -- Scanner les propriétés cachées de toutes les instances
    ScanHiddenProperties = function()
        local results = {
            Instances = {},
            TotalHiddenProperties = 0
        }
        
        for _, instance in pairs(game:GetDescendants()) do
            local hiddenProps = DeepScanner.HiddenPropertyScanner.GetHiddenProperties(instance)
            
            if #hiddenProps > 0 then
                table.insert(results.Instances, {
                    Path = instance:GetFullName(),
                    ClassName = instance.ClassName,
                    HiddenProperties = hiddenProps
                })
                results.TotalHiddenProperties = results.TotalHiddenProperties + #hiddenProps
            end
        end
        
        return results
    end,
    
    -- Récupérer les propriétés cachées d'une instance
    GetHiddenProperties = function(instance)
        local hiddenProps = {}
        
        if not gethiddenproperty then
            return hiddenProps
        end
        
        -- Liste de propriétés potentiellement cachées
        local potentialHiddenProps = {
            "MeshId", "TextureID", "Scale", "Offset", "VertexColor",
            "MeshSize", "Complexity", "LOD", "RenderFidelity",
            "StreamingMode", "TargetSize", "DetailSize"
        }
        
        for _, propName in pairs(potentialHiddenProps) do
            local success, value = pcall(function()
                return gethiddenproperty(instance, propName)
            end)
            
            if success then
                table.insert(hiddenProps, {
                    Name = propName,
                    Value = DeepScanner.GCScanner.AnalyzeValue(value)
                })
            end
        end
        
        return hiddenProps
    end
}

-- ============================================================================
-- SCAN DES ATTRIBUTS CACHÉS
-- ============================================================================

DeepScanner.HiddenAttributeScanner = {
    -- Scanner les attributs qui ne sont pas visibles normalement
    ScanHiddenAttributes = function()
        local results = {
            Instances = {},
            TotalHiddenAttributes = 0
        }
        
        for _, instance in pairs(game:GetDescendants()) do
            local hiddenAttrs = DeepScanner.HiddenAttributeScanner.GetHiddenAttributes(instance)
            
            if #hiddenAttrs > 0 then
                table.insert(results.Instances, {
                    Path = instance:GetFullName(),
                    ClassName = instance.ClassName,
                    HiddenAttributes = hiddenAttrs
                })
                results.TotalHiddenAttributes = results.TotalHiddenAttributes + #hiddenAttrs
            end
        end
        
        return results
    end,
    
    -- Récupérer les attributs cachés
    GetHiddenAttributes = function(instance)
        local hiddenAttrs = {}
        
        -- Tenter d'accéder aux attributs via des méthodes internes
        if gethiddenproperty then
            -- Certains attributs sont stockés comme propriétés cachées
            local internalAttrs = {"InternalAttributes", "AttributeData"}
            
            for _, attrName in pairs(internalAttrs) do
                local success, value = pcall(function()
                    return gethiddenproperty(instance, attrName)
                end)
                
                if success then
                    table.insert(hiddenAttrs, {
                        Name = attrName,
                        Value = DeepScanner.GCScanner.AnalyzeValue(value)
                    })
                end
            end
        end
        
        return hiddenAttrs
    end
}

-- ============================================================================
-- SCAN DES FICHIERS CACHÉS (via HttpService)
-- ============================================================================

DeepScanner.HiddenFileScanner = {
    -- Scanner les fichiers qui pourraient être cachés dans le jeu
    ScanHiddenFiles = function()
        local results = {
            PotentialFiles = {},
            EncodedData = {}
        }
        
        -- Scanner les ModuleScripts qui pourraient contenir des données encodées
        for _, script in pairs(game:GetDescendants()) do
            if script:IsA("ModuleScript") then
                local success, module = pcall(function()
                    return require(script)
                end)
                
                if success and type(module) == "table" then
                    -- Chercher des patterns de données encodées
                    for k, v in pairs(module) do
                        if type(v) == "string" and v:len() > 100 then
                            -- Pourrait être des données encodées
                            table.insert(results.EncodedData, {
                                Source = script:GetFullName(),
                                Key = k,
                                Data = v:sub(1, 100) .. "...",
                                Length = v:len()
                            })
                        end
                    end
                end
            end
        end
        
        return results
    end
}

-- ============================================================================
-- SCAN COMPLET
-- ============================================================================

function DeepScanner.RunFullScan()
    print("[DEEP_SCANNER] Démarrage du scan profond...")
    
    local startTime = tick()
    local results = {
        Timestamp = tick(),
        Duration = 0,
        GCScan = nil,
        RegistryScan = nil,
        HiddenScripts = nil,
        HiddenAssets = nil,
        HiddenProperties = nil,
        HiddenAttributes = nil,
        HiddenFiles = nil
    }
    
    -- 1. Scan GC
    print("[DEEP_SCANNER] Scan du Garbage Collector...")
    results.GCScan = DeepScanner.GCScanner.ScanAllGC()
    
    -- 2. Scan Registre
    print("[DEEP_SCANNER] Scan du registre...")
    results.RegistryScan = DeepScanner.RegistryScanner.ScanRegistry()
    
    -- 3. Scripts cachés
    print("[DEEP_SCANNER] Recherche des scripts cachés...")
    results.HiddenScripts = DeepScanner.HiddenScriptScanner.FindHiddenScripts()
    
    -- 4. Assets cachés
    print("[DEEP_SCANNER] Recherche des assets cachés...")
    results.HiddenAssets = DeepScanner.HiddenAssetScanner.FindHiddenAssets()
    
    -- 5. Propriétés cachées
    print("[DEEP_SCANNER] Recherche des propriétés cachées...")
    results.HiddenProperties = DeepScanner.HiddenPropertyScanner.ScanHiddenProperties()
    
    -- 6. Attributs cachés
    print("[DEEP_SCANNER] Recherche des attributs cachés...")
    results.HiddenAttributes = DeepScanner.HiddenAttributeScanner.ScanHiddenAttributes()
    
    -- 7. Fichiers cachés
    print("[DEEP_SCANNER] Recherche des fichiers cachés...")
    results.HiddenFiles = DeepScanner.HiddenFileScanner.ScanHiddenFiles()
    
    results.Duration = tick() - startTime
    
    print(string.format("[DEEP_SCANNER] Scan terminé en %.2fs", results.Duration))
    print(string.format("[DEEP_SCANNER] Tables GC: %d", results.GCScan.TotalTables or 0))
    print(string.format("[DEEP_SCANNER] Scripts cachés: %d", #results.HiddenScripts.HiddenScripts))
    print(string.format("[DEEP_SCANNER] Assets cachés: %d", #results.HiddenAssets.HiddenAssets))
    print(string.format("[DEEP_SCANNER] Propriétés cachées: %d", results.HiddenProperties.TotalHiddenProperties))
    
    return results
end

return DeepScanner
