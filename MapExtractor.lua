-- ============================================================================
-- MAP EXTRACTOR - Extraction complète de la map
-- Extraction détaillée de la map, terrain, lighting, spawns, paths
-- ============================================================================

local MapExtractor = {}

-- ============================================================================
-- EXTRACTION DU WORKSPACE
-- ============================================================================

MapExtractor.WorkspaceExtractor = {
    -- Extraire le Workspace complet
    ExtractWorkspace = function()
        local workspace = game:GetService("Workspace")
        
        local extraction = {
            Name = workspace.Name,
            ClassName = workspace.ClassName,
            Children = {},
            Summary = {
                TotalInstances = 0,
                ByClass = {},
                TotalParts = 0,
                TotalModels = 0,
                TotalMeshes = 0
            }
        }
        
        -- Extraire chaque enfant du Workspace
        for _, child in pairs(workspace:GetChildren()) do
            local childData = MapExtractor.WorkspaceExtractor.ExtractInstance(child, true)
            table.insert(extraction.Children, childData)
            
            -- Mettre à jour le résumé
            extraction.Summary.TotalInstances = extraction.Summary.TotalInstances + 1
            extraction.Summary.ByClass[child.ClassName] = (extraction.Summary.ByClass[child.ClassName] or 0) + 1
            
            if child.ClassName == "Part" or child.ClassName == "MeshPart" then
                extraction.Summary.TotalParts = extraction.Summary.TotalParts + 1
            elseif child.ClassName == "Model" then
                extraction.Summary.TotalModels = extraction.Summary.TotalModels + 1
            end
            
            if child:IsA("MeshPart") or child:FindFirstChild("Mesh") then
                extraction.Summary.TotalMeshes = extraction.Summary.TotalMeshes + 1
            end
        end
        
        return extraction
    end,
    
    -- Extraire une instance avec tous ses détails
    ExtractInstance = function(instance, recursive)
        recursive = recursive or false
        
        local data = {
            ClassName = instance.ClassName,
            Name = instance.Name,
            Properties = MapExtractor.WorkspaceExtractor.ExtractProperties(instance),
            Attributes = MapExtractor.WorkspaceExtractor.ExtractAttributes(instance),
            Tags = MapExtractor.WorkspaceExtractor.ExtractTags(instance),
            Children = {}
        }
        
        -- Propriétés spéciales selon la classe
        if instance:IsA("BasePart") then
            data.SpecialProperties = MapExtractor.WorkspaceExtractor.ExtractBasePartProperties(instance)
        elseif instance:IsA("Model") then
            data.SpecialProperties = MapExtractor.WorkspaceExtractor.ExtractModelProperties(instance)
        elseif instance:IsA("Humanoid") then
            data.SpecialProperties = MapExtractor.WorkspaceExtractor.ExtractHumanoidProperties(instance)
        elseif instance:IsA("MeshPart") then
            data.SpecialProperties = MapExtractor.WorkspaceExtractor.ExtractMeshPartProperties(instance)
        end
        
        -- Extraire les enfants récursivement
        if recursive then
            for _, child in pairs(instance:GetChildren()) do
                table.insert(data.Children, MapExtractor.WorkspaceExtractor.ExtractInstance(child, true))
            end
        end
        
        return data
    end,
    
    -- Extraire les propriétés
    ExtractProperties = function(instance)
        local props = {}
        
        -- Propriétés communes
        local commonProps = {
            "Name", "ClassName", "Archivable", "Parent",
            "Anchored", "Position", "Size", "CFrame", "Rotation",
            "Color", "Material", "Transparency", "Reflectance",
            "CanCollide", "CanTouch", "CanQuery", "Massless",
            "BrickColor", "Color3"
        }
        
        for _, propName in pairs(commonProps) do
            local success, value = pcall(function()
                return instance[propName]
            end)
            if success then
                props[propName] = MapExtractor.WorkspaceExtractor.SerializeValue(value)
            end
        end
        
        -- Propriétés cachées si disponibles
        if gethiddenproperty then
            local hiddenProps = {"MeshId", "TextureID", "Scale", "Offset", "VertexColor"}
            for _, propName in pairs(hiddenProps) do
                local success, value = pcall(function()
                    return gethiddenproperty(instance, propName)
                end)
                if success then
                    props[propName] = MapExtractor.WorkspaceExtractor.SerializeValue(value)
                end
            end
        end
        
        return props
    end,
    
    -- Extraire les attributs
    ExtractAttributes = function(instance)
        local attrs = {}
        
        if instance.GetAttributes then
            local success, attributes = pcall(function()
                return instance:GetAttributes()
            end)
            if success then
                for attrName, attrValue in pairs(attributes) do
                    attrs[attrName] = MapExtractor.WorkspaceExtractor.SerializeValue(attrValue)
                end
            end
        end
        
        return attrs
    end,
    
    -- Extraire les tags
    ExtractTags = function(instance)
        local tags = {}
        
        if instance.GetTags then
            local success, tagList = pcall(function()
                return instance:GetTags()
            end)
            if success then
                tags = tagList
            end
        end
        
        return tags
    end,
    
    -- Sérialiser une valeur
    SerializeValue = function(value)
        local valueType = type(value)
        
        if valueType == "string" then
            return value
        elseif valueType == "number" then
            return value
        elseif valueType == "boolean" then
            return value
        elseif valueType == "userdata" then
            local robloxType = typeof(value)
            
            if robloxType == "Vector3" then
                return {Type = "Vector3", X = value.X, Y = value.Y, Z = value.Z}
            elseif robloxType == "CFrame" then
                return {
                    Type = "CFrame",
                    Position = {X = value.Position.X, Y = value.Position.Y, Z = value.Position.Z},
                    Rotation = {X = value:ToEulerAnglesXYZ()}
                }
            elseif robloxType == "Color3" then
                return {Type = "Color3", R = value.R, G = value.G, B = value.B}
            elseif robloxType == "BrickColor" then
                return {Type = "BrickColor", Number = value.Number}
            elseif robloxType == "UDim2" then
                return {Type = "UDim2", X = {Scale = value.X.Scale, Offset = value.X.Offset}, Y = {Scale = value.Y.Scale, Offset = value.Y.Offset}}
            elseif robloxType == "EnumItem" then
                return {Type = "Enum", Name = value.Name, Value = value.Value}
            elseif robloxType == "Instance" then
                return {Type = "Instance", Path = value:GetFullName()}
            else
                return {Type = robloxType, Value = tostring(value)}
            end
        elseif valueType == "table" then
            local serialized = {}
            for k, v in pairs(value) do
                serialized[tostring(k)] = MapExtractor.WorkspaceExtractor.SerializeValue(v)
            end
            return {Type = "Table", Value = serialized}
        else
            return {Type = valueType, Value = tostring(value)}
        end
    end,
    
    -- Propriétés spéciales BasePart
    ExtractBasePartProperties = function(instance)
        return {
            Shape = instance.Shape,
            Material = instance.Material,
            Size = instance.Size,
            Position = instance.Position,
            Orientation = instance.Orientation,
            Velocity = instance.Velocity,
            RotVelocity = instance.RotVelocity,
            CustomPhysicalProperties = instance.CustomPhysicalProperties,
            PhysicalProperties = instance:GetPhysicalProperties()
        }
    end,
    
    -- Propriétés spéciales Model
    ExtractModelProperties = function(instance)
        return {
            PrimaryPart = instance.PrimaryPart and instance.PrimaryPart:GetFullName() or nil,
            WorldPivot = instance.WorldPivot,
            ExtentsSize = instance.ExtentsSize,
            ExtentsMinSize = instance:GetExtentsSize(),
            Scale = instance.Scale
        }
    end,
    
    -- Propriétés spéciales Humanoid
    ExtractHumanoidProperties = function(instance)
        return {
            Health = instance.Health,
            MaxHealth = instance.MaxHealth,
            WalkSpeed = instance.WalkSpeed,
            JumpPower = instance.JumpPower,
            AutoJumpEnabled = instance.AutoJumpEnabled,
            UseJumpPower = instance.UseJumpPower,
            DisplayName = instance.DisplayName,
            PlatformStand = instance.PlatformStand,
            Sit = instance.Sit
        }
    end,
    
    -- Propriétés spéciales MeshPart
    ExtractMeshPartProperties = function(instance)
        return {
            MeshId = instance.MeshId,
            TextureID = instance.TextureID,
            MeshSize = instance.MeshSize,
            DetailSize = instance.DetailSize,
            RenderFidelity = instance.RenderFidelity,
            Complexity = instance.Complexity
        }
    end
}

-- ============================================================================
-- EXTRACTION DU TERRAIN
-- ============================================================================

MapExtractor.TerrainExtractor = {
    -- Extraire le terrain
    ExtractTerrain = function()
        local workspace = game:GetService("Workspace")
        local terrain = workspace:FindFirstChild("Terrain")
        
        if not terrain then
            return {Available = false, Reason = "No terrain found"}
        end
        
        local extraction = {
            Available = true,
            MaterialColors = {},
            WaterColor = nil,
            WaterWaveSize = terrain.WaterWaveSize,
            WaterWaveSpeed = terrain.WaterWaveSpeed,
            Decoration = {},
            Regions = {}
        }
        
        -- Couleurs des matériaux
        local materials = {"Grass", "Slate", "Concrete", "Brick", "Sand", "Fabric", "SmoothPlastic", "Neon"}
        for _, material in pairs(materials) do
            local success, color = pcall(function()
                return terrain:GetMaterialColor(Enum.Material[material])
            end)
            if success then
                extraction.MaterialColors[material] = {
                    R = color.R,
                    G = color.G,
                    B = color.B
                }
            end
        end
        
        -- Couleur de l'eau
        extraction.WaterColor = {
            R = terrain.WaterColor.R,
            G = terrain.WaterColor.G,
            B = terrain.WaterColor.B
        }
        
        -- Régions du terrain (échantillonnage)
        local regionSize = 64
        local samplePoints = {
            {0, 0, 0},
            {regionSize, 0, 0},
            {0, 0, regionSize},
            {regionSize, 0, regionSize},
            {-regionSize, 0, 0},
            {0, 0, -regionSize}
        }
        
        for _, point in pairs(samplePoints) do
            local region = terrain:ReadVoxels(
                Region3.new(
                    Vector3.new(point[1], 0, point[3]),
                    Vector3.new(point[1] + 4, 4, point[3] + 4)
                ),
                4
            )
            
            if region then
                table.insert(extraction.Regions, {
                    Position = point,
                    VoxelData = region
                })
            end
        end
        
        return extraction
    end
}

-- ============================================================================
-- EXTRACTION DU LIGHTING
-- ============================================================================

MapExtractor.LightingExtractor = {
    -- Extraire les paramètres d'éclairage
    ExtractLighting = function()
        local lighting = game:GetService("Lighting")
        
        local extraction = {
            Brightness = lighting.Brightness,
            Contrast = lighting.Contrast,
            Saturation = lighting.Saturation,
            Ambient = {
                R = lighting.Ambient.R,
                G = lighting.Ambient.G,
                B = lighting.Ambient.B
            },
            OutdoorAmbient = {
                R = lighting.OutdoorAmbient.R,
                G = lighting.OutdoorAmbient.G,
                B = lighting.OutdoorAmbient.B
            },
            ColorShift_Bottom = {
                R = lighting.ColorShift_Bottom.R,
                G = lighting.ColorShift_Bottom.G,
                B = lighting.ColorShift_Bottom.B
            },
            ColorShift_Top = {
                R = lighting.ColorShift_Top.R,
                G = lighting.ColorShift_Top.G,
                B = lighting.ColorShift_Top.B
            },
            EnvironmentDiffuseScale = lighting.EnvironmentDiffuseScale,
            EnvironmentSpecularScale = lighting.EnvironmentSpecularScale,
            ExposureCompensation = lighting.ExposureCompensation,
            FogColor = {
                R = lighting.FogColor.R,
                G = lighting.FogColor.G,
                B = lighting.FogColor.B
            },
            FogEnd = lighting.FogEnd,
            FogStart = lighting.FogStart,
            GeographicLatitude = lighting.GeographicLatitude,
            GlobalShadows = lighting.GlobalShadows,
            ShadowSoftness = lighting.ShadowSoftness,
            ClockTime = lighting.ClockTime,
            TimeOfDay = lighting.TimeOfDay
        }
        
        -- Sky
        local sky = lighting:FindFirstChild("Sky")
        if sky then
            extraction.Sky = {
                SkyboxBk = sky.SkyboxBk,
                SkyboxDn = sky.SkyboxDn,
                SkyboxFt = sky.SkyboxFt,
                SkyboxLf = sky.SkyboxLf,
                SkyboxRt = sky.SkyboxRt,
                SkyboxUp = sky.SkyboxUp,
                StarCount = sky.StarCount,
                SunAngularSize = sky.SunAngularSize,
                MoonAngularSize = sky.MoonAngularSize
            }
        end
        
        -- Atmosphere
        local atmosphere = lighting:FindFirstChild("Atmosphere")
        if atmosphere then
            extraction.Atmosphere = {
                Density = atmosphere.Density,
                Offset = atmosphere.Offset,
                Color = {
                    R = atmosphere.Color.R,
                    G = atmosphere.Color.G,
                    B = atmosphere.Color.B
                },
                Decay = {
                    R = atmosphere.Decay.R,
                    G = atmosphere.Decay.G,
                    B = atmosphere.Decay.B
                },
                Glare = atmosphere.Glare,
                Haze = atmosphere.Haze
            }
        end
        
        -- Bloom
        local bloom = lighting:FindFirstChild("Bloom")
        if bloom then
            extraction.Bloom = {
                Intensity = bloom.Intensity,
                Size = bloom.Size,
                Threshold = bloom.Threshold
            }
        end
        
        -- ColorCorrection
        local colorCorrection = lighting:FindFirstChild("ColorCorrection")
        if colorCorrection then
            extraction.ColorCorrection = {
                Brightness = colorCorrection.Brightness,
                Contrast = colorCorrection.Contrast,
                Saturation = colorCorrection.Saturation,
                TintColor = {
                    R = colorCorrection.TintColor.R,
                    G = colorCorrection.TintColor.G,
                    B = colorCorrection.TintColor.B
                }
            }
        end
        
        return extraction
    end
}

-- ============================================================================
-- EXTRACTION DES SPAWN POINTS
-- ============================================================================

MapExtractor.SpawnPointExtractor = {
    -- Extraire tous les spawn points
    ExtractSpawnPoints = function()
        local workspace = game:GetService("Workspace")
        local spawns = {
            SpawnLocations = {},
            Teams = {}
        }
        
        -- Trouver tous les SpawnLocations
        for _, instance in pairs(workspace:GetDescendants()) do
            if instance:IsA("SpawnLocation") then
                local spawnData = {
                    Name = instance.Name,
                    Position = instance.Position,
                    Size = instance.Size,
                    Team = instance.Team and instance.Team.Name or "Neutral",
                    AllowTeamChangeOnTouch = instance.AllowTeamChangeOnTouch,
                    Duration = instance.Duration,
                    Neutral = instance.Neutral
                }
                
                table.insert(spawns.SpawnLocations, spawnData)
            end
        end
        
        -- Trouver les équipes
        local teams = game:GetService("Teams")
        for _, team in pairs(teams:GetChildren()) do
            if team:IsA("Team") then
                table.insert(spawns.Teams, {
                    Name = team.Name,
                    TeamColor = {
                        R = team.TeamColor.R,
                        G = team.TeamColor.G,
                        B = team.TeamColor.B
                    },
                    AutoAssignable = team.AutoAssignable
                })
            end
        end
        
        return spawns
    end
}

-- ============================================================================
-- EXTRACTION DES PATHS (CHEMINS)
-- ============================================================================

MapExtractor.PathExtractor = {
    -- Extraire tous les chemins
    ExtractPaths = function()
        local workspace = game:GetService("Workspace")
        local paths = {
            PathFolders = {},
            Waypoints = {}
        }
        
        -- Chercher les dossiers de chemins
        local pathFolderNames = {"Paths", "Path", "Route", "Routes", "Waypoints"}
        
        for _, folderName in pairs(pathFolderNames) do
            local folder = workspace:FindFirstChild(folderName)
            if folder then
                local pathData = MapExtractor.PathExtractor.ExtractPathFolder(folder)
                table.insert(paths.PathFolders, pathData)
            end
        end
        
        -- Chercher les waypoints individuels
        for _, instance in pairs(workspace:GetDescendants()) do
            if instance.Name:lower():find("waypoint") or instance.Name:lower():find("path") then
                if instance:IsA("BasePart") or instance:IsA("Attachment") then
                    local waypointData = {
                        Name = instance.Name,
                        ClassName = instance.ClassName,
                        Position = instance:IsA("BasePart") and instance.Position or instance.Position,
                        Parent = instance.Parent:GetFullName()
                    }
                    table.insert(paths.Waypoints, waypointData)
                end
            end
        end
        
        return paths
    end,
    
    -- Extraire un dossier de chemin
    ExtractPathFolder = function(folder)
        local pathData = {
            Name = folder.Name,
            Path = folder:GetFullName(),
            Waypoints = {}
        }
        
        -- Trier les waypoints par nom ou position
        local waypoints = {}
        for _, child in pairs(folder:GetChildren()) do
            if child:IsA("BasePart") or child:IsA("Attachment") then
                table.insert(waypoints, {
                    Name = child.Name,
                    ClassName = child.ClassName,
                    Position = child:IsA("BasePart") and child.Position or child.Position,
                    Order = tonumber(child.Name) or 0
                })
            end
        end
        
        -- Trier par ordre
        table.sort(waypoints, function(a, b)
            return a.Order < b.Order
        end)
        
        pathData.Waypoints = waypoints
        
        return pathData
    end
}

-- ============================================================================
-- EXTRACTION DES CAMÉRAS
-- ============================================================================

MapExtractor.CameraExtractor = {
    -- Extraire les caméras
    ExtractCameras = function()
        local workspace = game:GetService("Workspace")
        local cameras = {
            CurrentCamera = nil,
            ScriptableCameras = {}
        }
        
        -- Caméra actuelle
        local currentCamera = workspace.CurrentCamera
        cameras.CurrentCamera = {
            CFrame = currentCamera.CFrame,
            FieldOfView = currentCamera.FieldOfView,
            CameraType = tostring(currentCamera.CameraType)
        }
        
        -- Caméras scriptables
        for _, instance in pairs(workspace:GetDescendants()) do
            if instance:IsA("Camera") then
                table.insert(cameras.ScriptableCameras, {
                    Name = instance.Name,
                    Path = instance:GetFullName(),
                    CFrame = instance.CFrame,
                    FieldOfView = instance.FieldOfView
                })
            end
        end
        
        return cameras
    end
}

-- ============================================================================
-- EXTRACTION COMPLÈTE
-- ============================================================================

function MapExtractor.ExtractFullMap()
    print("[MAP_EXTRACTOR] Extraction complète de la map...")
    
    local startTime = tick()
    local extraction = {
        Timestamp = tick(),
        Duration = 0,
        Workspace = nil,
        Terrain = nil,
        Lighting = nil,
        SpawnPoints = nil,
        Paths = nil,
        Cameras = nil,
        Summary = {}
    }
    
    -- 1. Workspace
    print("[MAP_EXTRACTOR] Extraction du Workspace...")
    extraction.Workspace = MapExtractor.WorkspaceExtractor.ExtractWorkspace()
    
    -- 2. Terrain
    print("[MAP_EXTRACTOR] Extraction du Terrain...")
    extraction.Terrain = MapExtractor.TerrainExtractor.ExtractTerrain()
    
    -- 3. Lighting
    print("[MAP_EXTRACTOR] Extraction du Lighting...")
    extraction.Lighting = MapExtractor.LightingExtractor.ExtractLighting()
    
    -- 4. Spawn Points
    print("[MAP_EXTRACTOR] Extraction des Spawn Points...")
    extraction.SpawnPoints = MapExtractor.SpawnPointExtractor.ExtractSpawnPoints()
    
    -- 5. Paths
    print("[MAP_EXTRACTOR] Extraction des Paths...")
    extraction.Paths = MapExtractor.PathExtractor.ExtractPaths()
    
    -- 6. Cameras
    print("[MAP_EXTRACTOR] Extraction des Caméras...")
    extraction.Cameras = MapExtractor.CameraExtractor.ExtractCameras()
    
    extraction.Duration = tick() - startTime
    
    -- Résumé
    extraction.Summary = {
        TotalInstances = extraction.Workspace.Summary.TotalInstances,
        TotalParts = extraction.Workspace.Summary.TotalParts,
        TotalModels = extraction.Workspace.Summary.TotalModels,
        TotalMeshes = extraction.Workspace.Summary.TotalMeshes,
        SpawnLocations = #extraction.SpawnPoints.SpawnLocations,
        PathFolders = #extraction.Paths.PathFolders,
        Waypoints = #extraction.Paths.Waypoints
    }
    
    print(string.format("[MAP_EXTRACTOR] Extraction terminée en %.2fs", extraction.Duration))
    print(string.format("[MAP_EXTRACTOR] Instances: %d", extraction.Summary.TotalInstances))
    print(string.format("[MAP_EXTRACTOR] Parts: %d", extraction.Summary.TotalParts))
    print(string.format("[MAP_EXTRACTOR] Models: %d", extraction.Summary.TotalModels))
    print(string.format("[MAP_EXTRACTOR] Meshes: %d", extraction.Summary.TotalMeshes))
    print(string.format("[MAP_EXTRACTOR] Spawn Locations: %d", extraction.Summary.SpawnLocations))
    print(string.format("[MAP_EXTRACTOR] Path Folders: %d", extraction.Summary.PathFolders))
    
    return extraction
end

return MapExtractor
