-- ============================================================================
-- ASSET RECOVERY - Récupération complète des assets
-- Récupération de tous les assets (images, sons, meshes, animations) y compris cachés
-- ============================================================================

local AssetRecovery = {}

-- ============================================================================
-- RÉCUPÉRATION DES ASSETS VISIBLES
-- ============================================================================

AssetRecovery.VisibleAssetRecovery = {
    -- Récupérer tous les assets visibles
    RecoverVisibleAssets = function()
        local assets = {
            Images = {},
            Sounds = {},
            Meshes = {},
            Animations = {},
            Summary = {
                TotalImages = 0,
                TotalSounds = 0,
                TotalMeshes = 0,
                TotalAnimations = 0
            }
        }
        
        -- Scanner toutes les instances
        for _, instance in pairs(game:GetDescendants()) do
            -- Images
            if instance:IsA("ImageLabel") or instance:IsA("ImageButton") or instance:IsA("Decal") or instance:IsA("Texture") then
                local assetId = instance.Image or instance.Texture
                if assetId and assetId ~= "" then
                    local assetData = AssetRecovery.VisibleAssetRecovery.ExtractImageAsset(instance, assetId)
                    table.insert(assets.Images, assetData)
                    assets.Summary.TotalImages = assets.Summary.TotalImages + 1
                end
            end
            
            -- Sons
            if instance:IsA("Sound") then
                local assetId = instance.SoundId
                if assetId and assetId ~= "" then
                    local assetData = AssetRecovery.VisibleAssetRecovery.ExtractSoundAsset(instance, assetId)
                    table.insert(assets.Sounds, assetData)
                    assets.Summary.TotalSounds = assets.Summary.TotalSounds + 1
                end
            end
            
            -- Meshes
            if instance:IsA("MeshPart") then
                local assetId = instance.MeshId
                if assetId and assetId ~= "" then
                    local assetData = AssetRecovery.VisibleAssetRecovery.ExtractMeshAsset(instance, assetId)
                    table.insert(assets.Meshes, assetData)
                    assets.Summary.TotalMeshes = assets.Summary.TotalMeshes + 1
                end
            elseif instance:IsA("SpecialMesh") then
                local assetId = instance.MeshId
                if assetId and assetId ~= "" then
                    local assetData = AssetRecovery.VisibleAssetRecovery.ExtractMeshAsset(instance, assetId)
                    table.insert(assets.Meshes, assetData)
                    assets.Summary.TotalMeshes = assets.Summary.TotalMeshes + 1
                end
            end
            
            -- Animations
            if instance:IsA("Animation") then
                local assetId = instance.AnimationId
                if assetId and assetId ~= "" then
                    local assetData = AssetRecovery.VisibleAssetRecovery.ExtractAnimationAsset(instance, assetId)
                    table.insert(assets.Animations, assetData)
                    assets.Summary.TotalAnimations = assets.Summary.TotalAnimations + 1
                end
            end
        end
        
        return assets
    end,
    
    -- Extraire un asset image
    ExtractImageAsset = function(instance, assetId)
        return {
            AssetId = assetId,
            AssetType = "Image",
            Source = instance:GetFullName(),
            ClassName = instance.ClassName,
            Properties = {
                ImageRectOffset = instance.ImageRectOffset,
                ImageRectSize = instance.ImageRectSize,
                ImageTransparency = instance.ImageTransparency,
                ScaleType = tostring(instance.ScaleType),
                TileSize = instance.TileSize,
                ResampleMode = tostring(instance.ResampleMode)
            }
        }
    end,
    
    -- Extraire un asset son
    ExtractSoundAsset = function(instance, assetId)
        return {
            AssetId = assetId,
            AssetType = "Sound",
            Source = instance:GetFullName(),
            ClassName = instance.ClassName,
            Properties = {
                Volume = instance.Volume,
                Pitch = instance.Pitch,
                PlaybackSpeed = instance.PlaybackSpeed,
                Looped = instance.Looped,
                RollOffMode = tostring(instance.RollOffMode),
                RollOffMinDistance = instance.RollOffMinDistance,
                RollOffMaxDistance = instance.RollOffMaxDistance,
                SoundGroup = instance.SoundGroup and instance.SoundGroup.Name or nil
            }
        }
    end,
    
    -- Extraire un asset mesh
    ExtractMeshAsset = function(instance, assetId)
        local data = {
            AssetId = assetId,
            AssetType = "Mesh",
            Source = instance:GetFullName(),
            ClassName = instance.ClassName,
            Properties = {}
        }
        
        if instance:IsA("MeshPart") then
            data.Properties = {
                MeshSize = instance.MeshSize,
                DetailSize = instance.DetailSize,
                RenderFidelity = tostring(instance.RenderFidelity),
                Complexity = instance.Complexity,
                TextureID = instance.TextureID
            }
        elseif instance:IsA("SpecialMesh") then
            data.Properties = {
                MeshType = tostring(instance.MeshType),
                Scale = instance.Scale,
                VertexColor = instance.VertexColor,
                TextureID = instance.TextureID
            }
        end
        
        return data
    end,
    
    -- Extraire un asset animation
    ExtractAnimationAsset = function(instance, assetId)
        return {
            AssetId = assetId,
            AssetType = "Animation",
            Source = instance:GetFullName(),
            ClassName = instance.ClassName,
            Properties = {
                Priority = tostring(instance.Priority)
            }
        }
    end
}

-- ============================================================================
-- RÉCUPÉRATION DES ASSETS CACHÉS (via GC)
-- ============================================================================

AssetRecovery.HiddenAssetRecovery = {
    -- Récupérer les assets cachés dans le GC
    RecoverHiddenAssets = function()
        if not getgc then
            return {Available = false, Reason = "getgc not available"}
        end
        
        local assets = {
            HiddenImages = {},
            HiddenSounds = {},
            HiddenMeshes = {},
            HiddenAnimations = {},
            Summary = {
                TotalHiddenImages = 0,
                TotalHiddenSounds = 0,
                TotalHiddenMeshes = 0,
                TotalHiddenAnimations = 0
            }
        }
        
        local allTables = getgc(true)
        
        for _, tbl in pairs(allTables) do
            -- Chercher des asset IDs dans les tables
            for k, v in pairs(tbl) do
                if type(v) == "string" then
                    local assetId = v
                    
                    -- Images
                    if assetId:find("rbxassetid://") and (assetId:find("png") or assetId:find("jpg") or assetId:find("jpeg")) then
                        table.insert(assets.HiddenImages, {
                            AssetId = assetId,
                            Source = tostring(tbl),
                            Key = tostring(k)
                        })
                        assets.Summary.TotalHiddenImages = assets.Summary.TotalHiddenImages + 1
                    end
                    
                    -- Sons
                    if assetId:find("rbxassetid://") and (assetId:find("ogg") or assetId:find("mp3") or assetId:find("wav")) then
                        table.insert(assets.HiddenSounds, {
                            AssetId = assetId,
                            Source = tostring(tbl),
                            Key = tostring(k)
                        })
                        assets.Summary.TotalHiddenSounds = assets.Summary.TotalHiddenSounds + 1
                    end
                    
                    -- Meshes
                    if assetId:find("rbxassetid://") and (assetId:find("mesh") or assetId:find("obj")) then
                        table.insert(assets.HiddenMeshes, {
                            AssetId = assetId,
                            Source = tostring(tbl),
                            Key = tostring(k)
                        })
                        assets.Summary.TotalHiddenMeshes = assets.Summary.TotalHiddenMeshes + 1
                    end
                    
                    -- Animations
                    if assetId:find("rbxassetid://") and assetId:find("anim") then
                        table.insert(assets.HiddenAnimations, {
                            AssetId = assetId,
                            Source = tostring(tbl),
                            Key = tostring(k)
                        })
                        assets.Summary.TotalHiddenAnimations = assets.Summary.TotalHiddenAnimations + 1
                    end
                end
            end
        end
        
        return assets
    end
}

-- ============================================================================
-- RÉCUPÉRATION DES ASSETS VIA CONTENTPROVIDER
-- ============================================================================

AssetRecovery.ContentProviderRecovery = {
    -- Récupérer les assets via ContentProvider
    RecoverContentProviderAssets = function()
        local contentProvider = game:GetService("ContentProvider")
        
        local assets = {
            PreloadedAssets = {},
            QueuedAssets = {}
        }
        
        -- Tenter d'accéder aux assets préchargés
        if gethiddenproperty then
            local success, preloaded = pcall(function()
                return gethiddenproperty(contentProvider, "Preloaded")
            end)
            if success and preloaded then
                for assetId, _ in pairs(preloaded) do
                    table.insert(assets.PreloadedAssets, assetId)
                end
            end
        end
        
        -- Tenter d'accéder aux assets en queue
        if gethiddenproperty then
            local success, queued = pcall(function()
                return gethiddenproperty(contentProvider, "Queue")
            end)
            if success and queued then
                for assetId, _ in pairs(queued) do
                    table.insert(assets.QueuedAssets, assetId)
                end
            end
        end
        
        return assets
    end
}

-- ============================================================================
-- RÉCUPÉRATION DES ASSETS VIA MODULESCRIPTS
-- ============================================================================

AssetRecovery.ModuleAssetRecovery = {
    -- Récupérer les assets référencés dans les ModuleScripts
    RecoverModuleAssets = function()
        local assets = {
            ModuleAssets = {},
            Summary = {
                TotalModules = 0,
                TotalAssetsFound = 0
            }
        }
        
        for _, script in pairs(game:GetDescendants()) do
            if script:IsA("ModuleScript") then
                assets.Summary.TotalModules = assets.Summary.TotalModules + 1
                
                local success, module = pcall(function()
                    return require(script)
                end)
                
                if success and type(module) == "table" then
                    local moduleAssets = AssetRecovery.ModuleAssetRecovery.ExtractAssetsFromTable(module, script:GetFullName())
                    
                    for _, asset in pairs(moduleAssets) do
                        table.insert(assets.ModuleAssets, asset)
                        assets.Summary.TotalAssetsFound = assets.Summary.TotalAssetsFound + 1
                    end
                end
            end
        end
        
        return assets
    end,
    
    -- Extraire les assets d'une table
    ExtractAssetsFromTable = function(tbl, source)
        local assets = {}
        
        for k, v in pairs(tbl) do
            if type(v) == "string" and v:find("rbxassetid://") then
                table.insert(assets, {
                    AssetId = v,
                    Source = source,
                    Key = tostring(k)
                })
            elseif type(v) == "table" then
                local nestedAssets = AssetRecovery.ModuleAssetRecovery.ExtractAssetsFromTable(v, source)
                for _, asset in pairs(nestedAssets) do
                    table.insert(assets, asset)
                end
            end
        end
        
        return assets
    end
}

-- ============================================================================
-- RÉCUPÉRATION DES ASSETS VIA STRINGS DANS SCRIPTS
-- ============================================================================

AssetRecovery.ScriptStringRecovery = {
    -- Récupérer les assets référencés dans les scripts
    RecoverScriptStringAssets = function()
        local assets = {
            ScriptAssets = {},
            Summary = {
                TotalScripts = 0,
                TotalAssetsFound = 0
            }
        }
        
        for _, script in pairs(game:GetDescendants()) do
            if script:IsA("Script") or script:IsA("LocalScript") or script:IsA("ModuleScript") then
                assets.Summary.TotalScripts = assets.Summary.TotalScripts + 1
                
                if getscriptbytecode then
                    local success, bytecode = pcall(function()
                        return getscriptbytecode(script)
                    end)
                    
                    if success then
                        local scriptAssets = AssetRecovery.ScriptStringRecovery.ExtractAssetsFromBytecode(bytecode, script:GetFullName())
                        
                        for _, asset in pairs(scriptAssets) do
                            table.insert(assets.ScriptAssets, asset)
                            assets.Summary.TotalAssetsFound = assets.Summary.TotalAssetsFound + 1
                        end
                    end
                end
            end
        end
        
        return assets
    end,
    
    -- Extraire les assets du bytecode
    ExtractAssetsFromBytecode = function(bytecode, source)
        local assets = {}
        
        -- Chercher des patterns rbxassetid
        for assetId in bytecode:gmatch("rbxassetid://[%d]+") do
            table.insert(assets, {
                AssetId = assetId,
                Source = source
            })
        end
        
        return assets
    end
}

-- ============================================================================
-- DÉTECTION D'ASSETS EN DOUBLE
-- ============================================================================

AssetRecovery.AssetDeduplicator = {
    -- Dédupliquer les assets
    DeduplicateAssets = function(assetLists)
        local uniqueAssets = {
            Images = {},
            Sounds = {},
            Meshes = {},
            Animations = {}
        }
        
        local seenAssets = {}
        
        for _, assetList in pairs(assetLists) do
            for _, asset in pairs(assetList) do
                local assetId = asset.AssetId
                
                if not seenAssets[assetId] then
                    seenAssets[assetId] = true
                    
                    if asset.AssetType == "Image" then
                        table.insert(uniqueAssets.Images, asset)
                    elseif asset.AssetType == "Sound" then
                        table.insert(uniqueAssets.Sounds, asset)
                    elseif asset.AssetType == "Mesh" then
                        table.insert(uniqueAssets.Meshes, asset)
                    elseif asset.AssetType == "Animation" then
                        table.insert(uniqueAssets.Animations, asset)
                    end
                end
            end
        end
        
        return uniqueAssets
    end
}

-- ============================================================================
-- TÉLÉCHARGEMENT D'ASSETS
-- ============================================================================

AssetRecovery.AssetDownloader = {
    -- Télécharger un asset
    DownloadAsset = function(assetId)
        local httpService = game:GetService("HttpService")
        
        -- Extraire l'ID numérique
        local numericId = assetId:match("%d+")
        if not numericId then
            return {Success = false, Reason = "Invalid asset ID"}
        end
        
        -- URL de l'asset
        local assetUrl = string.format("https://www.roblox.com/asset/?id=%s", numericId)
        
        local success, response = pcall(function()
            return httpService:RequestAsync({
                Url = assetUrl,
                Method = "GET"
            })
        end)
        
        if not success then
            return {Success = false, Reason = response}
        end
        
        return {
            Success = true,
            AssetId = assetId,
            Response = response
        }
    end,
    
    -- Télécharger tous les assets
    DownloadAllAssets = function(assetList)
        local results = {
            Successful = {},
            Failed = {},
            Summary = {
                Total = 0,
                Successful = 0,
                Failed = 0
            }
        }
        
        for _, asset in pairs(assetList) do
            results.Summary.Total = results.Summary.Total + 1
            
            local downloadResult = AssetRecovery.AssetDownloader.DownloadAsset(asset.AssetId)
            
            if downloadResult.Success then
                table.insert(results.Successful, {
                    Asset = asset,
                    Response = downloadResult.Response
                })
                results.Summary.Successful = results.Summary.Successful + 1
            else
                table.insert(results.Failed, {
                    Asset = asset,
                    Reason = downloadResult.Reason
                })
                results.Summary.Failed = results.Summary.Failed + 1
            end
        end
        
        return results
    end
}

-- ============================================================================
-- RÉCUPÉRATION COMPLÈTE
-- ============================================================================

function AssetRecovery.RecoverAllAssets()
    print("[ASSET_RECOVERY] Récupération complète des assets...")
    
    local startTime = tick()
    local recovery = {
        Timestamp = tick(),
        Duration = 0,
        VisibleAssets = nil,
        HiddenAssets = nil,
        ContentProviderAssets = nil,
        ModuleAssets = nil,
        ScriptStringAssets = nil,
        UniqueAssets = nil,
        DownloadResults = nil,
        Summary = {}
    }
    
    -- 1. Assets visibles
    print("[ASSET_RECOVERY] Récupération des assets visibles...")
    recovery.VisibleAssets = AssetRecovery.VisibleAssetRecovery.RecoverVisibleAssets()
    
    -- 2. Assets cachés
    print("[ASSET_RECOVERY] Récupération des assets cachés...")
    recovery.HiddenAssets = AssetRecovery.HiddenAssetRecovery.RecoverHiddenAssets()
    
    -- 3. Assets ContentProvider
    print("[ASSET_RECOVERY] Récupération via ContentProvider...")
    recovery.ContentProviderAssets = AssetRecovery.ContentProviderRecovery.RecoverContentProviderAssets()
    
    -- 4. Assets ModuleScripts
    print("[ASSET_RECOVERY] Récupération via ModuleScripts...")
    recovery.ModuleAssets = AssetRecovery.ModuleAssetRecovery.RecoverModuleAssets()
    
    -- 5. Assets strings scripts
    print("[ASSET_RECOVERY] Récupération via strings scripts...")
    recovery.ScriptStringAssets = AssetRecovery.ScriptStringRecovery.RecoverScriptStringAssets()
    
    -- 6. Déduplication
    print("[ASSET_RECOVERY] Déduplication des assets...")
    local allAssetLists = {
        recovery.VisibleAssets.Images,
        recovery.VisibleAssets.Sounds,
        recovery.VisibleAssets.Meshes,
        recovery.VisibleAssets.Animations,
        recovery.HiddenAssets.HiddenImages,
        recovery.HiddenAssets.HiddenSounds,
        recovery.HiddenAssets.HiddenMeshes,
        recovery.HiddenAssets.HiddenAnimations
    }
    
    recovery.UniqueAssets = AssetRecovery.AssetDeduplicator.DeduplicateAssets(allAssetLists)
    
    -- 7. Téléchargement (optionnel)
    print("[ASSET_RECOVERY] Téléchargement des assets...")
    local allAssets = {}
    for _, asset in pairs(recovery.UniqueAssets.Images) do table.insert(allAssets, asset) end
    for _, asset in pairs(recovery.UniqueAssets.Sounds) do table.insert(allAssets, asset) end
    for _, asset in pairs(recovery.UniqueAssets.Meshes) do table.insert(allAssets, asset) end
    for _, asset in pairs(recovery.UniqueAssets.Animations) do table.insert(allAssets, asset) end
    
    recovery.DownloadResults = AssetRecovery.AssetDownloader.DownloadAllAssets(allAssets)
    
    recovery.Duration = tick() - startTime
    
    -- Résumé
    recovery.Summary = {
        VisibleImages = recovery.VisibleAssets.Summary.TotalImages,
        VisibleSounds = recovery.VisibleAssets.Summary.TotalSounds,
        VisibleMeshes = recovery.VisibleAssets.Summary.TotalMeshes,
        VisibleAnimations = recovery.VisibleAssets.Summary.TotalAnimations,
        HiddenImages = recovery.HiddenAssets.Summary.TotalHiddenImages,
        HiddenSounds = recovery.HiddenAssets.Summary.TotalHiddenSounds,
        HiddenMeshes = recovery.HiddenAssets.Summary.TotalHiddenMeshes,
        HiddenAnimations = recovery.HiddenAssets.Summary.TotalHiddenAnimations,
        UniqueImages = #recovery.UniqueAssets.Images,
        UniqueSounds = #recovery.UniqueAssets.Sounds,
        UniqueMeshes = #recovery.UniqueAssets.Meshes,
        UniqueAnimations = #recovery.UniqueAssets.Animations,
        DownloadSuccessful = recovery.DownloadResults.Summary.Successful,
        DownloadFailed = recovery.DownloadResults.Summary.Failed
    }
    
    print(string.format("[ASSET_RECOVERY] Récupération terminée en %.2fs", recovery.Duration))
    print(string.format("[ASSET_RECOVERY] Images visibles: %d", recovery.Summary.VisibleImages))
    print(string.format("[ASSET_RECOVERY] Sons visibles: %d", recovery.Summary.VisibleSounds))
    print(string.format("[ASSET_RECOVERY] Meshes visibles: %d", recovery.Summary.VisibleMeshes))
    print(string.format("[ASSET_RECOVERY] Animations visibles: %d", recovery.Summary.VisibleAnimations))
    print(string.format("[ASSET_RECOVERY] Images cachées: %d", recovery.Summary.HiddenImages))
    print(string.format("[ASSET_RECOVERY] Sons cachés: %d", recovery.Summary.HiddenSounds))
    print(string.format("[ASSET_RECOVERY] Meshes cachés: %d", recovery.Summary.HiddenMeshes))
    print(string.format("[ASSET_RECOVERY] Animations cachées: %d", recovery.Summary.HiddenAnimations))
    print(string.format("[ASSET_RECOVERY] Images uniques: %d", recovery.Summary.UniqueImages))
    print(string.format("[ASSET_RECOVERY] Sons uniques: %d", recovery.Summary.UniqueSounds))
    print(string.format("[ASSET_RECOVERY] Meshes uniques: %d", recovery.Summary.UniqueMeshes))
    print(string.format("[ASSET_RECOVERY] Animations uniques: %d", recovery.Summary.UniqueAnimations))
    print(string.format("[ASSET_RECOVERY] Téléchargés avec succès: %d", recovery.Summary.DownloadSuccessful))
    print(string.format("[ASSET_RECOVERY] Téléchargements échoués: %d", recovery.Summary.DownloadFailed))
    
    return recovery
end

return AssetRecovery
