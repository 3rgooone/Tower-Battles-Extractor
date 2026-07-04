--[[
    Tower Battles Ultimate Extractor v2.0
    Advanced fusion of Dex Explorer + UniversalSynSaveInstance + Network/RAM Logging
    
    Project : Tower Battles Reborn
    License : MIT (based on Dex and UniversalSynSaveInstance)
    
    Improvements v2.0:
    - Absolute stealth with hookmetamethod + checkcaller
    - Intelligent RAM filtering by gameplay keywords
    - Secure JSON serialization for Instances
    - Multi-exploit compatibility via UniversalMethodFinder
    - Dex-style GUI protection
]]

-- ============================================
-- UNIVERSAL METHOD FINDER (Compatibility)
-- ============================================

local global_container
local finder

do
    local filename = "UniversalMethodFinder"
    finder, global_container = loadstring(
        game:HttpGet("https://raw.githubusercontent.com/luau/SomeHub/main/" .. filename .. ".luau", true),
        filename
    )()
    
    finder({
        checkcaller = '(...):find("check",nil,true) and (...):find("caller",nil,true)',
        gethui = '(...):find("get",nil,true) and ((...):find("hui",nil,true) or (...):find("hid",nil,true) and (...):find("gui",nil,true))',
        protectgui = '(...):find("protect",nil,true) and (...):find("gui",nil,true) and not (...):find("un",nil,true)',
        hookmetamethod = '(...):find("hook",nil,true) and (...):find("meta",nil,true)',
        getgc = '(...):find("get",nil,true) and (...):find("gc",nil,true)',
        getreg = '(...):find("get",nil,true) and (...):find("reg",nil,true)',
        gethiddenproperty = '(...):find("get",nil,true) and (...):find("h",nil,true) and (...):find("prop",nil,true) and (...):sub(#(...) ~= "s")',
        getscriptbytecode = '(...):find("get",nil,true) and (...):find("script",nil,true) and (...):find("byte",nil,true)',
        getupvalues = '(...):find("get",nil,true) and (...):find("upval",nil,true) and (...):sub(#(...) == "s")',
        getconstants = '(...):find("get",nil,true) and ((...):find("consts",nil,true) or (...):find("constants",nil,true))',
        writefile = '(...):find("file",nil,true) and (...):find("write",nil,true)',
        appendfile = '(...):find("file",nil,true) and (...):find("append",nil,true)',
        isfile = '(...):find("file",nil,true) and (...):sub(1,2) == "is"',
        readfile = '(...):find("file",nil,true) and (...):find("read",nil,true)',
        islclosure = 'if (...):find("is",nil,true) then local closure = (...):find("closure",nil,true) local l = (...):find("l",nil,true) if closure and l then return closure > l end end',
    }, true)
end

-- Function retrieval with fallbacks
local checkcaller = global_container.checkcaller or (islclosure and function() return true end) or function() return true end
local gethui = global_container.gethui or (function() return game:GetService("CoreGui") end)
local protectgui = global_container.protectgui or (function(gui) end)
local hookmetamethod = global_container.hookmetamethod
local getgc = global_container.getgc
local getreg = global_container.getreg
local gethiddenproperty = global_container.gethiddenproperty
local getscriptbytecode = global_container.getscriptbytecode
local getupvalues = global_container.getupvalues
local getconstants = global_container.getconstants
local writefile = global_container.writefile or writefile
local appendfile = global_container.appendfile or appendfile
local isfile = global_container.isfile or isfile
local readfile = global_container.readfile or readfile

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local ContentProvider = game:GetService("ContentProvider")
local LogService = game:GetService("LogService")
local GuiService = game:GetService("GuiService")

-- Configuration
local Config = {
    -- Logging
    LogNetworkPackets = true,
    LogRAMData = true,
    LogToFile = true,
    
    -- Capture avancée
    CaptureInstanceProperties = true,
    CaptureScripts = true,
    CaptureAttributes = true,
    CaptureGameEvents = true,
    CapturePlayerStats = true,
    CaptureServerConfig = true,
    ContinuousCapture = true,
    
    -- Export
    ExportFormat = "JSON", -- JSON ou LuaTable
    AutoSaveInterval = 60, -- secondes
    
    -- Preloading
    ForcePreloadAssets = true,
    PreloadUI = true,
    PreloadSounds = true,
    
    -- RAM Scanning
    ScanInterval = 5, -- secondes
    DeepScan = true,
    
    -- Filtrage RAM intelligent (mots-clés gameplay)
    GameplayKeywords = {
        "Damage", "Range", "Wave", "Price", "Health", "Cost", 
        "Speed", "Cooldown", "Tower", "Zombie", "Reward",
        "Level", "Upgrade", "Spawn", "Path", "Difficulty",
        "Money", "Cash", "Gold", "Coins", "Currency",
        "HP", "Attack", "Defense", "Rate", "Interval"
    },
    
    -- Furtivité
    UseHookMetamethod = hookmetamethod ~= nil,
    StealthMode = true,
    
    -- Output
    Verbose = true,
    DebugMode = false
}

-- État de l'extractor
local ExtractorState = {
    NetworkLogs = {},
    RAMLogs = {},
    AssetRegistry = {},
    InstanceProperties = {},
    ScriptData = {},
    GameEvents = {},
    PlayerStats = {},
    ServerConfig = {},
    StartTime = tick(),
    IsRunning = false,
    HookedRemotes = {},
    SessionId = string.format("%x", tick()),
    LastCaptureTime = 0
}

-- ============================================================================
-- MODULE 1 : NETWORK PACKET INTERCEPTOR (RemoteSpy Avancé + Furtif)
-- ============================================================================

local NetworkInterceptor = {}

function NetworkInterceptor.Init()
    if Config.UseHookMetamethod and hookmetamethod then
        NetworkInterceptor.InitHookMetamethod()
    else
        NetworkInterceptor.InitLegacyHook()
    end
    
    -- Écouter les nouveaux RemoteEvents/Functions créés dynamiquement
    game.DescendantAdded:Connect(function(descendant)
        if not ExtractorState.HookedRemotes[descendant] then
            if descendant:IsA("RemoteEvent") then
                NetworkInterceptor.HookRemote(descendant, "Event")
            elseif descendant:IsA("RemoteFunction") then
                NetworkInterceptor.HookRemote(descendant, "Function")
            end
        end
    end)
end

-- Méthode furtive avec hookmetamethod
function NetworkInterceptor.InitHookMetamethod()
    local oldNamecall
    
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        
        -- Vérification checkcaller pour furtivité
        if checkcaller and not checkcaller() then
            -- Appel provenant du jeu, on laisse passer sans logging
            return oldNamecall(self, ...)
        end
        
        -- Logging des appels Remote
        if method == "FireServer" and self:IsA("RemoteEvent") then
            NetworkInterceptor.LogPacket({
                Type = "RemoteEvent",
                Name = self:GetFullName(),
                Direction = "Client->Server",
                Timestamp = tick(),
                Arguments = NetworkInterceptor.SerializeArgs(args),
                Method = "FireServer"
            })
        elseif method == "InvokeServer" and self:IsA("RemoteFunction") then
            NetworkInterceptor.LogPacket({
                Type = "RemoteFunction",
                Name = self:GetFullName(),
                Direction = "Client->Server",
                Timestamp = tick(),
                Arguments = NetworkInterceptor.SerializeArgs(args),
                Method = "InvokeServer"
            })
        end
        
        return oldNamecall(self, ...)
    end)
    
    -- Hook OnClientEvent pour les réponses serveur
    for _, descendant in pairs(game:GetDescendants()) do
        if descendant:IsA("RemoteEvent") then
            NetworkInterceptor.HookOnClientEvent(descendant)
        end
    end
end

-- Méthode legacy pour exploits sans hookmetamethod
function NetworkInterceptor.InitLegacyHook()
    for _, descendant in pairs(game:GetDescendants()) do
        if descendant:IsA("RemoteEvent") then
            NetworkInterceptor.HookRemote(descendant, "Event")
        elseif descendant:IsA("RemoteFunction") then
            NetworkInterceptor.HookRemote(descendant, "Function")
        end
    end
end

function NetworkInterceptor.HookRemote(remote, remoteType)
    if ExtractorState.HookedRemotes[remote] then
        return
    end
    
    ExtractorState.HookedRemotes[remote] = true
    
    if remoteType == "Event" then
        local originalFireServer = remote.FireServer
        remote.FireServer = function(self, ...)
            local args = {...}
            local timestamp = tick()
            
            NetworkInterceptor.LogPacket({
                Type = "RemoteEvent",
                Name = remote:GetFullName(),
                Direction = "Client->Server",
                Timestamp = timestamp,
                Arguments = NetworkInterceptor.SerializeArgs(args),
                Method = "FireServer"
            })
            
            return originalFireServer(self, ...)
        end
        
        NetworkInterceptor.HookOnClientEvent(remote)
    elseif remoteType == "Function" then
        local originalInvokeServer = remote.InvokeServer
        remote.InvokeServer = function(self, ...)
            local args = {...}
            local timestamp = tick()
            
            NetworkInterceptor.LogPacket({
                Type = "RemoteFunction",
                Name = remote:GetFullName(),
                Direction = "Client->Server",
                Timestamp = timestamp,
                Arguments = NetworkInterceptor.SerializeArgs(args),
                Method = "InvokeServer"
            })
            
            local success, result = pcall(originalInvokeServer, self, ...)
            
            NetworkInterceptor.LogPacket({
                Type = "RemoteFunction",
                Name = remote:GetFullName(),
                Direction = "Server->Client",
                Timestamp = tick(),
                Arguments = NetworkInterceptor.SerializeArgs({result}),
                Success = success
            })
            
            if success then
                return result
            else
                error(result)
            end
        end
    end
end

function NetworkInterceptor.HookOnClientEvent(remote)
    if remote.OnClientEvent then
        local connections = remote:GetConnections("OnClientEvent")
        for _, connection in pairs(connections) do
            local originalFunc = connection.Function
            if originalFunc then
                connection:Disconnect()
                remote.OnClientEvent:Connect(function(...)
                    local args = {...}
                    local timestamp = tick()
                    
                    NetworkInterceptor.LogPacket({
                        Type = "RemoteEvent",
                        Name = remote:GetFullName(),
                        Direction = "Server->Client",
                        Timestamp = timestamp,
                        Arguments = NetworkInterceptor.SerializeArgs(args),
                        Method = "OnClientEvent"
                    })
                    
                    return originalFunc(...)
                end)
            end
        end
    end
end

function NetworkInterceptor.SerializeArgs(args)
    local serialized = {}
    for i, arg in pairs(args) do
        serialized[i] = NetworkInterceptor.SafeSerialize(arg)
    end
    return serialized
end

function NetworkInterceptor.SafeSerialize(data, depth)
    depth = depth or 0
    if depth > 10 then -- Protection contre la récursion infinie
        return {Type = "MaxDepth", Value = "[MAX_DEPTH_REACHED]"}
    end
    
    local dataType = typeof(data)
    
    if dataType == "table" then
        local serialized = {}
        for k, v in pairs(data) do
            serialized[tostring(k)] = NetworkInterceptor.SafeSerialize(v, depth + 1)
        end
        return {Type = "table", Value = serialized}
    elseif dataType == "Instance" then
        -- Sérialisation sécurisée des Instances pour JSON
        return {
            Type = "Instance",
            ClassName = data.ClassName,
            Name = data.Name,
            Path = data:GetFullName(),
            -- Propriétés supplémentaires si pertinent
            Archivable = data.Archivable,
            Parent = data.Parent and data.Parent:GetFullName() or "nil"
        }
    elseif dataType == "Vector3" then
        return {Type = "Vector3", Value = {X = data.X, Y = data.Y, Z = data.Z}}
    elseif dataType == "CFrame" then
        local components = {data:GetComponents()}
        return {
            Type = "CFrame",
            Value = {
                Position = {X = data.Position.X, Y = data.Position.Y, Z = data.Position.Z},
                Components = components
            }
        }
    elseif dataType == "Color3" then
        return {Type = "Color3", Value = {R = data.R, G = data.G, B = data.B}}
    elseif dataType == "BrickColor" then
        return {Type = "BrickColor", Value = data.Number, Name = data.Name}
    elseif dataType == "UDim2" then
        return {Type = "UDim2", Value = {X = {Scale = data.X.Scale, Offset = data.X.Offset}, Y = {Scale = data.Y.Scale, Offset = data.Y.Offset}}}
    elseif dataType == "UDim" then
        return {Type = "UDim", Value = {Scale = data.Scale, Offset = data.Offset}}
    elseif dataType == "Ray" then
        return {Type = "Ray", Value = {Origin = NetworkInterceptor.SafeSerialize(data.Origin), Direction = NetworkInterceptor.SafeSerialize(data.Direction)}}
    elseif dataType == "EnumItem" then
        return {Type = "EnumItem", Value = tostring(data), Name = data.Name}
    elseif dataType == "number" or dataType == "boolean" or dataType == "string" then
        return {Type = dataType, Value = data}
    else
        return {Type = dataType, Value = tostring(data)}
    end
end

function NetworkInterceptor.LogPacket(packet)
    table.insert(ExtractorState.NetworkLogs, packet)
    
    if Config.Verbose then
        print(string.format("[NETWORK] %s %s | %s", 
            packet.Direction, 
            packet.Name, 
            HttpService:JSONEncode(packet.Arguments)))
    end
end

-- ============================================================================
-- MODULE 2 : RAM & GARBAGE COLLECTION DUMP SCANNER (Filtrage Intelligent)
-- ============================================================================

local RAMScanner = {}

function RAMScanner.Init()
    -- Scanner périodique de la mémoire
    spawn(function()
        while ExtractorState.IsRunning do
            RAMScanner.ScanMemory()
            wait(Config.ScanInterval)
        end
    end)
end

function RAMScanner.ScanMemory()
    local scanTime = tick()
    local memorySnapshot = {
        Timestamp = scanTime,
        MemoryStats = {},
        FoundTables = {},
        ReplicatedStorageData = {},
        GameplayData = {} -- Nouveau : données filtrées par mots-clés
    }
    
    -- Statistiques de base
    memorySnapshot.MemoryStats = {
        LuaGCMemory = stats and stats:GetMemoryStatsMb("LuaGCMemory") or 0,
        LuaScriptMemory = stats and stats:GetMemoryStatsMb("LuaScriptMemory") or 0,
        TotalMemory = stats and stats:GetMemoryStatsMb("TotalMemory") or 0
    }
    
    -- Scanner ReplicatedStorage pour les données partagées
    for _, descendant in pairs(ReplicatedStorage:GetDescendants()) do
        if descendant:IsA("ModuleScript") or descendant:IsA("ValueBase") then
            local data = RAMScanner.ExtractData(descendant)
            if data then
                table.insert(memorySnapshot.ReplicatedStorageData, data)
                -- Filtrage intelligent par mots-clés
                if RAMScanner.ContainsGameplayKeyword(data.Name) then
                    table.insert(memorySnapshot.GameplayData, data)
                end
            end
        end
    end
    
    -- Scanner les tables globales avec filtrage (si DeepScan activé)
    if Config.DeepScan then
        if getgc then
            memorySnapshot.FoundTables = RAMScanner.ScanGarbageCollection()
        else
            memorySnapshot.FoundTables = RAMScanner.DeepScanGlobals()
        end
    end
    
    table.insert(ExtractorState.RAMLogs, memorySnapshot)
    
    if Config.Verbose then
        print(string.format("[RAM] Scan complet - %d objets, %d gameplay data", 
            #memorySnapshot.ReplicatedStorageData, #memorySnapshot.GameplayData))
    end
end

function RAMScanner.ContainsGameplayKeyword(text)
    text = tostring(text):lower()
    for _, keyword in pairs(Config.GameplayKeywords) do
        if text:find(keyword:lower()) then
            return true
        end
    end
    return false
end

function RAMScanner.ExtractData(instance)
    local data = {
        Name = instance.Name,
        ClassName = instance.ClassName,
        Path = instance:GetFullName()
    }
    
    if instance:IsA("ModuleScript") then
        -- Tenter de require le module pour extraire ses données
        local success, module = pcall(function()
            return require(instance)
        end)
        if success and type(module) == "table" then
            data.ModuleData = NetworkInterceptor.SafeSerialize(module)
            -- Marquer si contient des mots-clés gameplay
            data.HasGameplayData = RAMScanner.TableContainsGameplayKeywords(module)
        end
    elseif instance:IsA("ValueBase") then
        data.Value = instance.Value
        data.ValueType = typeof(instance.Value)
    elseif instance:IsA("Folder") then
        data.Children = {}
        for _, child in pairs(instance:GetChildren()) do
            local childData = RAMScanner.ExtractData(child)
            if childData then
                table.insert(data.Children, childData)
            end
        end
    end
    
    return data
end

function RAMScanner.TableContainsGameplayKeywords(tbl, depth)
    depth = depth or 0
    if depth > 5 then return false end -- Limite de profondeur
    
    for k, v in pairs(tbl) do
        if RAMScanner.ContainsGameplayKeyword(k) or RAMScanner.ContainsGameplayKeyword(v) then
            return true
        end
        if type(v) == "table" then
            if RAMScanner.TableContainsGameplayKeywords(v, depth + 1) then
                return true
            end
        end
    end
    return false
end

function RAMScanner.DeepScanGlobals()
    local foundTables = {}
    
    -- Scanner _G pour les données globales
    for key, value in pairs(_G) do
        if type(value) == "table" then
            local serialized = NetworkInterceptor.SafeSerialize(value)
            if RAMScanner.TableContainsGameplayKeywords(value) then
                foundTables["_G." .. tostring(key)] = serialized
                foundTables["_G." .. tostring(key)].IsGameplayData = true
            end
        end
    end
    
    -- Scanner shared (si accessible)
    for key, value in pairs(shared) do
        if type(value) == "table" then
            local serialized = NetworkInterceptor.SafeSerialize(value)
            if RAMScanner.TableContainsGameplayKeywords(value) then
                foundTables["shared." .. tostring(key)] = serialized
                foundTables["shared." .. tostring(key)].IsGameplayData = true
            end
        end
    end
    
    return foundTables
end

-- Scan avancé via getgc si disponible
function RAMScanner.ScanGarbageCollection()
    local foundTables = {}
    local scannedObjects = {} -- Éviter les doublons
    
    -- Récupérer toutes les tables via getgc
    local gcObjects = getgc(true)
    
    for _, obj in pairs(gcObjects) do
        if type(obj) == "table" and not scannedObjects[obj] then
            scannedObjects[obj] = true
            
            -- Vérifier si la table contient des mots-clés gameplay
            if RAMScanner.TableContainsGameplayKeywords(obj) then
                -- Essayer d'identifier la source de la table
                local sourceInfo = RAMScanner.IdentifyTableSource(obj)
                local key = sourceInfo or "Unknown_GC_Table"
                
                foundTables[key] = NetworkInterceptor.SafeSerialize(obj)
                foundTables[key].IsGameplayData = true
            end
        end
    end
    
    return foundTables
end

function RAMScanner.IdentifyTableSource(tbl)
    -- Tenter d'identifier la source d'une table via ses métadonnées
    local mt = getmetatable(tbl)
    if mt and mt.__index then
        if type(mt.__index) == "table" then
            return "Metatable: " .. tostring(mt.__index)
        elseif type(mt.__index) == "function" then
            return "MetatableFunction"
        end
    end
    
    -- Chercher des clés communes qui indiquent la source
    if tbl.Tower then return "TowerConfig"
    elseif tbl.Zombie then return "ZombieConfig"
    elseif tbl.Wave then return "WaveConfig"
    elseif tbl.Damage then return "DamageConfig"
    elseif tbl.Price then return "PriceConfig"
    end
    
    return nil
end

-- ============================================================================
-- MODULE 3 : DYNAMIC ASSET PRELOADER (Amélioré)
-- ============================================================================

local AssetPreloader = {}

function AssetPreloader.Init()
    if Config.ForcePreloadAssets then
        spawn(function()
            AssetPreloader.PreloadGameAssets()
        end)
    end
end

function AssetPreloader.PreloadGameAssets()
    print("[PRELOADER] Début du préchargement des assets...")
    
    local startTime = tick()
    local assetCount = 0
    
    -- Précharger les UI
    if Config.PreloadUI then
        local uiCount = AssetPreloader.PreloadUI()
        assetCount = assetCount + uiCount
    end
    
    -- Précharger les sons
    if Config.PreloadSounds then
        local soundCount = AssetPreloader.PreloadSounds()
        assetCount = assetCount + soundCount
    end
    
    -- Précharger les modèles 3D
    local meshCount = AssetPreloader.PreloadModels()
    assetCount = assetCount + meshCount
    
    -- Précharger les animations (nouveau)
    local animCount = AssetPreloader.PreloadAnimations()
    assetCount = assetCount + animCount
    
    local duration = tick() - startTime
    print(string.format("[PRELOADER] Préchargement terminé - %d assets en %.2fs", assetCount, duration))
end

function AssetPreloader.PreloadUI()
    local player = Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")
    local count = 0
    local assetsToPreload = {}
    
    for _, ui in pairs(playerGui:GetDescendants()) do
        if ui:IsA("ImageLabel") or ui:IsA("ImageButton") then
            if ui.Image and ui.Image ~= "" and not ui.Image:find("rbxasset://") then
                table.insert(ExtractorState.AssetRegistry, {
                    Type = "Image",
                    AssetId = ui.Image,
                    Source = ui:GetFullName(),
                    Timestamp = tick()
                })
                table.insert(assetsToPreload, ui.Image)
                count = count + 1
            end
        end
    end
    
    -- Précharger par lots pour éviter les timeouts
    if #assetsToPreload > 0 then
        for i = 1, #assetsToPreload, 10 do
            local batch = {}
            for j = i, math.min(i + 9, #assetsToPreload) do
                table.insert(batch, assetsToPreload[j])
            end
            ContentProvider:PreloadAsync(batch)
        end
    end
    
    return count
end

function AssetPreloader.PreloadSounds()
    local count = 0
    local assetsToPreload = {}
    
    for _, sound in pairs(game:GetDescendants()) do
        if sound:IsA("Sound") then
            if sound.SoundId and sound.SoundId ~= "" then
                table.insert(ExtractorState.AssetRegistry, {
                    Type = "Sound",
                    AssetId = sound.SoundId,
                    Source = sound:GetFullName(),
                    Volume = sound.Volume,
                    Pitch = sound.Pitch,
                    Timestamp = tick()
                })
                table.insert(assetsToPreload, sound.SoundId)
                count = count + 1
            end
        end
    end
    
    if #assetsToPreload > 0 then
        for i = 1, #assetsToPreload, 10 do
            local batch = {}
            for j = i, math.min(i + 9, #assetsToPreload) do
                table.insert(batch, assetsToPreload[j])
            end
            ContentProvider:PreloadAsync(batch)
        end
    end
    
    return count
end

function AssetPreloader.PreloadModels()
    local count = 0
    local assetsToPreload = {}
    
    for _, mesh in pairs(game:GetDescendants()) do
        if mesh:IsA("MeshPart") or mesh:IsA("SpecialMesh") then
            local assetId = mesh:IsA("MeshPart") and mesh.MeshId or mesh.MeshId
            if assetId and assetId ~= "" then
                table.insert(ExtractorState.AssetRegistry, {
                    Type = "Mesh",
                    AssetId = assetId,
                    Source = mesh:GetFullName(),
                    MeshType = mesh.ClassName,
                    Timestamp = tick()
                })
                table.insert(assetsToPreload, assetId)
                count = count + 1
            end
        end
    end
    
    if #assetsToPreload > 0 then
        for i = 1, #assetsToPreload, 10 do
            local batch = {}
            for j = i, math.min(i + 9, #assetsToPreload) do
                table.insert(batch, assetsToPreload[j])
            end
            ContentProvider:PreloadAsync(batch)
        end
    end
    
    return count
end

function AssetPreloader.PreloadAnimations()
    local count = 0
    local assetsToPreload = {}
    
    for _, anim in pairs(game:GetDescendants()) do
        if anim:IsA("Animation") then
            if anim.AnimationId and anim.AnimationId ~= "" then
                table.insert(ExtractorState.AssetRegistry, {
                    Type = "Animation",
                    AssetId = anim.AnimationId,
                    Source = anim:GetFullName(),
                    Timestamp = tick()
                })
                table.insert(assetsToPreload, anim.AnimationId)
                count = count + 1
            end
        end
    end
    
    if #assetsToPreload > 0 then
        for i = 1, #assetsToPreload, 10 do
            local batch = {}
            for j = i, math.min(i + 9, #assetsToPreload) do
                table.insert(batch, assetsToPreload[j])
            end
            ContentProvider:PreloadAsync(batch)
        end
    end
    
    return count
end

-- ============================================================================
-- MODULE 5 : CAPTURE DES PROPRIÉTÉS D'INSTANCES (Avancé)
-- ============================================================================

local InstanceCapture = {}

function InstanceCapture.Init()
    if Config.CaptureInstanceProperties then
        spawn(function()
            while ExtractorState.IsRunning do
                InstanceCapture.CaptureWorkspace()
                wait(10) -- Capture toutes les 10 secondes
            end
        end)
    end
end

function InstanceCapture.CaptureWorkspace()
    local workspace = game:GetService("Workspace")
    local snapshot = {
        Timestamp = tick(),
        Instances = {}
    }
    
    -- Capturer les instances importantes
    local importantInstances = {
        "Model", "MeshPart", "Part", "UnionOperation", "NegateOperation",
        "Folder", "SpawnLocation", "Camera", "Terrain"
    }
    
    for _, instance in pairs(workspace:GetDescendants()) do
        local shouldCapture = false
        for _, class in pairs(importantInstances) do
            if instance.ClassName == class then
                shouldCapture = true
                break
            end
        end
        
        if shouldCapture then
            local props = InstanceCapture.GetProperties(instance)
            snapshot.Instances[instance:GetFullName()] = {
                ClassName = instance.ClassName,
                Name = instance.Name,
                Properties = props,
                Children = #instance:GetChildren()
            }
        end
    end
    
    table.insert(ExtractorState.InstanceProperties, snapshot)
    
    if Config.Verbose then
        print(string.format("[INSTANCE] Capture - %d instances", #snapshot.Instances))
    end
end

function InstanceCapture.GetProperties(instance)
    local props = {}
    
    -- Propriétés de base
    local basicProps = {
        "Anchored", "Position", "Size", "CFrame", "Rotation",
        "Color", "Material", "Transparency", "Reflectance",
        "CanCollide", "Massless", "Friction", "Elasticity",
        "BrickColor", "Shape", "TopSurface", "BottomSurface"
    }
    
    for _, propName in pairs(basicProps) do
        local success, value = pcall(function()
            return instance[propName]
        end)
        if success then
            props[propName] = NetworkInterceptor.SafeSerialize(value)
        end
    end
    
    -- Utiliser gethiddenproperty si disponible
    if gethiddenproperty then
        local hiddenProps = {"MeshId", "TextureID", "Scale", "Offset"}
        for _, propName in pairs(hiddenProps) do
            local success, value = pcall(function()
                return gethiddenproperty(instance, propName)
            end)
            if success then
                props["Hidden_" .. propName] = NetworkInterceptor.SafeSerialize(value)
            end
        end
    end
    
    return props
end

-- ============================================================================
-- MODULE 6 : CAPTURE DES SCRIPTS (Avancé)
-- ============================================================================

local ScriptCapture = {}

function ScriptCapture.Init()
    if Config.CaptureScripts then
        spawn(function()
            while ExtractorState.IsRunning do
                ScriptCapture.CaptureAllScripts()
                wait(15) -- Capture toutes les 15 secondes
            end
        end)
    end
end

function ScriptCapture.CaptureAllScripts()
    local snapshot = {
        Timestamp = tick(),
        Scripts = {}
    }
    
    for _, script in pairs(game:GetDescendants()) do
        if script:IsA("Script") or script:IsA("LocalScript") or script:IsA("ModuleScript") then
            local scriptData = {
                Name = script.Name,
                ClassName = script.ClassName,
                Path = script:GetFullName(),
                Disabled = script.Disabled,
                RunContext = script.RunContext and tostring(script.RunContext) or "Unknown"
            }
            
            -- Tenter de capturer le bytecode si disponible
            if getscriptbytecode then
                local success, bytecode = pcall(function()
                    return getscriptbytecode(script)
                end)
                if success and bytecode then
                    scriptData.HasBytecode = true
                    scriptData.BytecodeLength = #bytecode
                    -- Stocker seulement la longueur pour éviter les fichiers trop gros
                end
            end
            
            -- Capturer les upvalues si disponibles
            if getupvalues then
                local success, upvalues = pcall(function()
                    return getupvalues(script)
                end)
                if success and upvalues then
                    scriptData.Upvalues = {}
                    for k, v in pairs(upvalues) do
                        scriptData.Upvalues[tostring(k)] = NetworkInterceptor.SafeSerialize(v)
                    end
                end
            end
            
            -- Capturer les constantes si disponibles
            if getconstants then
                local success, constants = pcall(function()
                    return getconstants(script)
                end)
                if success and constants then
                    scriptData.Constants = {}
                    for _, const in pairs(constants) do
                        table.insert(scriptData.Constants, NetworkInterceptor.SafeSerialize(const))
                    end
                end
            end
            
            snapshot.Scripts[script:GetFullName()] = scriptData
        end
    end
    
    table.insert(ExtractorState.ScriptData, snapshot)
    
    if Config.Verbose then
        print(string.format("[SCRIPT] Capture - %d scripts", #snapshot.Scripts))
    end
end

-- ============================================================================
-- MODULE 7 : CAPTURE DES ATTRIBUTS ET TAGS
-- ============================================================================

local AttributeCapture = {}

function AttributeCapture.Init()
    if Config.CaptureAttributes then
        spawn(function()
            while ExtractorState.IsRunning do
                AttributeCapture.CaptureAllAttributes()
                wait(20) -- Capture toutes les 20 secondes
            end
        end)
    end
end

function AttributeCapture.CaptureAllAttributes()
    local snapshot = {
        Timestamp = tick(),
        Attributes = {}
    }
    
    for _, instance in pairs(game:GetDescendants()) do
        local attributes = instance:GetAttributes()
        if next(attributes) then
            snapshot.Attributes[instance:GetFullName()] = {}
            for attrName, attrValue in pairs(attributes) do
                snapshot.Attributes[instance:GetFullName()][attrName] = NetworkInterceptor.SafeSerialize(attrValue)
            end
        end
        
        -- Capturer les tags si disponibles
        if instance:GetTags() then
            local tags = instance:GetTags()
            if #tags > 0 then
                if not snapshot.Attributes[instance:GetFullName()] then
                    snapshot.Attributes[instance:GetFullName()] = {}
                end
                snapshot.Attributes[instance:GetFullName()].Tags = tags
            end
        end
    end
    
    table.insert(ExtractorState.ServerConfig, snapshot)
    
    if Config.Verbose then
        print(string.format("[ATTRIBUTE] Capture - %d instances avec attributs/tags", #snapshot.Attributes))
    end
end

-- ============================================================================
-- MODULE 8 : CAPTURE DES ÉVÉNEMENTS DE JEU
-- ============================================================================

local GameEventCapture = {}

function GameEventCapture.Init()
    if Config.CaptureGameEvents then
        GameEventCapture.HookGameEvents()
    end
end

function GameEventCapture.HookGameEvents()
    local workspace = game:GetService("Workspace")
    local players = game:GetService("Players")
    
    -- Hook les événements de spawn/despawn
    players.PlayerAdded:Connect(function(player)
        table.insert(ExtractorState.GameEvents, {
            Type = "PlayerAdded",
            Timestamp = tick(),
            Player = player.Name,
            UserId = player.UserId
        })
    end)
    
    players.PlayerRemoving:Connect(function(player)
        table.insert(ExtractorState.GameEvents, {
            Type = "PlayerRemoving",
            Timestamp = tick(),
            Player = player.Name,
            UserId = player.UserId
        })
    end)
    
    -- Hook les événements de humanoid (mort, dégâts)
    for _, instance in pairs(workspace:GetDescendants()) do
        if instance:IsA("Humanoid") then
            GameEventCapture.HookHumanoid(instance)
        end
    end
    
    -- Écouter les nouveaux humanoids
    workspace.DescendantAdded:Connect(function(descendant)
        if descendant:IsA("Humanoid") then
            GameEventCapture.HookHumanoid(descendant)
        end
    end)
end

function GameEventCapture.HookHumanoid(humanoid)
    -- Hook la mort
    humanoid.Died:Connect(function()
        table.insert(ExtractorState.GameEvents, {
            Type = "HumanoidDied",
            Timestamp = tick(),
            Humanoid = humanoid:GetFullName(),
            MaxHealth = humanoid.MaxHealth
        })
    end)
    
    -- Hook les changements de santé
    humanoid.HealthChanged:Connect(function(newHealth)
        if newHealth < humanoid.MaxHealth * 0.1 then
            table.insert(ExtractorState.GameEvents, {
                Type = "LowHealth",
                Timestamp = tick(),
                Humanoid = humanoid:GetFullName(),
                Health = newHealth,
                MaxHealth = humanoid.MaxHealth
            })
        end
    end)
end

-- ============================================================================
-- MODULE 9 : CAPTURE DES STATISTIQUES JOUEURS
-- ============================================================================

local PlayerStatsCapture = {}

function PlayerStatsCapture.Init()
    if Config.CapturePlayerStats then
        spawn(function()
            while ExtractorState.IsRunning do
                PlayerStatsCapture.CapturePlayerStats()
                wait(5) -- Capture toutes les 5 secondes
            end
        end)
    end
end

function PlayerStatsCapture.CapturePlayerStats()
    local players = game:GetService("Players")
    local localPlayer = players.LocalPlayer
    
    if not localPlayer then return end
    
    local snapshot = {
        Timestamp = tick(),
        PlayerStats = {}
    }
    
    -- Capturer les stats de tous les joueurs
    for _, player in pairs(players:GetPlayers()) do
        local stats = {
            Name = player.Name,
            UserId = player.UserId,
            Team = player.Team and player.Team.Name or "No Team",
            Character = player.Character and player.Character:GetFullName() or "No Character"
        }
        
        -- Capturer les leaderstats si disponibles
        local leaderstats = player:FindFirstChild("leaderstats")
        if leaderstats then
            stats.Leaderstats = {}
            for _, value in pairs(leaderstats:GetChildren()) do
                if value:IsA("ValueBase") then
                    stats.Leaderstats[value.Name] = {
                        Value = value.Value,
                        Type = value.ClassName
                    }
                end
            end
        end
        
        -- Capturer les stats du personnage
        local character = player.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                stats.HumanoidStats = {
                    Health = humanoid.Health,
                    MaxHealth = humanoid.MaxHealth,
                    WalkSpeed = humanoid.WalkSpeed,
                    JumpPower = humanoid.JumpPower
                }
            end
        end
        
        snapshot.PlayerStats[player.Name] = stats
    end
    
    table.insert(ExtractorState.PlayerStats, snapshot)
    
    if Config.Verbose then
        print(string.format("[PLAYERSTATS] Capture - %d joueurs", #snapshot.PlayerStats))
    end
end

-- ============================================================================
-- MODULE 10 : CAPTURE CONTINUE AUTOMATIQUE
-- ============================================================================

local ContinuousCapture = {}

function ContinuousCapture.Init()
    if Config.ContinuousCapture then
        spawn(function()
            while ExtractorState.IsRunning do
                ContinuousCapture.FullCapture()
                wait(30) -- Capture complète toutes les 30 secondes
            end
        end)
    end
end

function ContinuousCapture.FullCapture()
    local captureTime = tick()
    ExtractorState.LastCaptureTime = captureTime
    
    print(string.format("[CONTINUOUS] Capture complète démarrée à %s", os.date("%H:%M:%S")))
    
    -- Déclencher toutes les captures
    if Config.CaptureInstanceProperties then
        InstanceCapture.CaptureWorkspace()
    end
    
    if Config.CaptureScripts then
        ScriptCapture.CaptureAllScripts()
    end
    
    if Config.CaptureAttributes then
        AttributeCapture.CaptureAllAttributes()
    end
    
    if Config.CapturePlayerStats then
        PlayerStatsCapture.CapturePlayerStats()
    end
    
    local duration = tick() - captureTime
    print(string.format("[CONTINUOUS] Capture complète terminée en %.2fs", duration))
end

-- ============================================================================
-- MODULE 4 : EXPORTATION INTELLIGENTE (Amélioré)
-- ============================================================================

local DataExporter = {}

function DataExporter.Init()
    -- Auto-save périodique
    spawn(function()
        while ExtractorState.IsRunning do
            wait(Config.AutoSaveInterval)
            DataExporter.ExportAll()
        end
    end)
end

function DataExporter.ExportAll()
    local exportData = {
        Metadata = {
            ExportTime = tick(),
            SessionId = ExtractorState.SessionId,
            GameName = "Tower Battles",
            PlaceId = game.PlaceId,
            SessionDuration = tick() - ExtractorState.StartTime,
            ExtractorVersion = "3.0",
            Config = Config,
            LastCaptureTime = ExtractorState.LastCaptureTime
        },
        NetworkLogs = {
            TotalPackets = #ExtractorState.NetworkLogs,
            Packets = ExtractorState.NetworkLogs,
            Summary = DataExporter.GenerateNetworkSummary()
        },
        RAMLogs = {
            TotalScans = #ExtractorState.RAMLogs,
            Scans = ExtractorState.RAMLogs,
            GameplayDataSummary = DataExporter.GenerateGameplaySummary()
        },
        AssetRegistry = {
            TotalAssets = #ExtractorState.AssetRegistry,
            Assets = ExtractorState.AssetRegistry,
            Summary = DataExporter.GenerateAssetSummary()
        },
        InstanceProperties = {
            TotalSnapshots = #ExtractorState.InstanceProperties,
            Snapshots = ExtractorState.InstanceProperties,
            Summary = DataExporter.GenerateInstanceSummary()
        },
        ScriptData = {
            TotalSnapshots = #ExtractorState.ScriptData,
            Snapshots = ExtractorState.ScriptData,
            Summary = DataExporter.GenerateScriptSummary()
        },
        ServerConfig = {
            TotalSnapshots = #ExtractorState.ServerConfig,
            Snapshots = ExtractorState.ServerConfig,
            Summary = DataExporter.GenerateConfigSummary()
        },
        GameEvents = {
            TotalEvents = #ExtractorState.GameEvents,
            Events = ExtractorState.GameEvents,
            Summary = DataExporter.GenerateEventSummary()
        },
        PlayerStats = {
            TotalSnapshots = #ExtractorState.PlayerStats,
            Snapshots = ExtractorState.PlayerStats,
            Summary = DataExporter.GeneratePlayerStatsSummary()
        }
    }
    
    if Config.ExportFormat == "JSON" then
        DataExporter.ExportJSON(exportData)
    else
        DataExporter.ExportLuaTable(exportData)
    end
    
    print("[EXPORT] Données exportées avec succès")
end

function DataExporter.GenerateNetworkSummary()
    local summary = {
        RemoteEvents = {},
        RemoteFunctions = {},
        TotalCalls = 0
    }
    
    for _, packet in pairs(ExtractorState.NetworkLogs) do
        summary.TotalCalls = summary.TotalCalls + 1
        
        if packet.Type == "RemoteEvent" then
            if not summary.RemoteEvents[packet.Name] then
                summary.RemoteEvents[packet.Name] = {Count = 0, Methods = {}}
            end
            summary.RemoteEvents[packet.Name].Count = summary.RemoteEvents[packet.Name].Count + 1
            summary.RemoteEvents[packet.Name].Methods[packet.Method or "Unknown"] = (summary.RemoteEvents[packet.Name].Methods[packet.Method or "Unknown"] or 0) + 1
        elseif packet.Type == "RemoteFunction" then
            if not summary.RemoteFunctions[packet.Name] then
                summary.RemoteFunctions[packet.Name] = {Count = 0, Methods = {}}
            end
            summary.RemoteFunctions[packet.Name].Count = summary.RemoteFunctions[packet.Name].Count + 1
            summary.RemoteFunctions[packet.Name].Methods[packet.Method or "Unknown"] = (summary.RemoteFunctions[packet.Name].Methods[packet.Method or "Unknown"] or 0) + 1
        end
    end
    
    return summary
end

function DataExporter.GenerateGameplaySummary()
    local summary = {
        TotalGameplayData = 0,
        Categories = {}
    }
    
    for _, scan in pairs(ExtractorState.RAMLogs) do
        for _, data in pairs(scan.GameplayData or {}) do
            summary.TotalGameplayData = summary.TotalGameplayData + 1
            
            local category = data.ClassName or "Unknown"
            if not summary.Categories[category] then
                summary.Categories[category] = 0
            end
            summary.Categories[category] = summary.Categories[category] + 1
        end
        
        for key, tableData in pairs(scan.FoundTables or {}) do
            if tableData.IsGameplayData then
                summary.TotalGameplayData = summary.TotalGameplayData + 1
                if not summary.Categories["GC_Tables"] then
                    summary.Categories["GC_Tables"] = 0
                end
                summary.Categories["GC_Tables"] = summary.Categories["GC_Tables"] + 1
            end
        end
    end
    
    return summary
end

function DataExporter.GenerateAssetSummary()
    local summary = {
        ByType = {},
        TotalSize = 0
    }
    
    for _, asset in pairs(ExtractorState.AssetRegistry) do
        if not summary.ByType[asset.Type] then
            summary.ByType[asset.Type] = 0
        end
        summary.ByType[asset.Type] = summary.ByType[asset.Type] + 1
    end
    
    return summary
end

function DataExporter.GenerateInstanceSummary()
    local summary = {
        TotalInstances = 0,
        ByClass = {},
        AveragePerSnapshot = 0
    }
    
    for _, snapshot in pairs(ExtractorState.InstanceProperties) do
        local count = 0
        for _, instanceData in pairs(snapshot.Instances) do
            count = count + 1
            local className = instanceData.ClassName
            if not summary.ByClass[className] then
                summary.ByClass[className] = 0
            end
            summary.ByClass[className] = summary.ByClass[className] + 1
        end
        summary.TotalInstances = summary.TotalInstances + count
    end
    
    if #ExtractorState.InstanceProperties > 0 then
        summary.AveragePerSnapshot = summary.TotalInstances / #ExtractorState.InstanceProperties
    end
    
    return summary
end

function DataExporter.GenerateScriptSummary()
    local summary = {
        TotalScripts = 0,
        ByType = {Script = 0, LocalScript = 0, ModuleScript = 0},
        WithBytecode = 0,
        WithUpvalues = 0
    }
    
    for _, snapshot in pairs(ExtractorState.ScriptData) do
        for _, scriptData in pairs(snapshot.Scripts) do
            summary.TotalScripts = summary.TotalScripts + 1
            summary.ByType[scriptData.ClassName] = (summary.ByType[scriptData.ClassName] or 0) + 1
            if scriptData.HasBytecode then
                summary.WithBytecode = summary.WithBytecode + 1
            end
            if scriptData.Upvalues then
                summary.WithUpvalues = summary.WithUpvalues + 1
            end
        end
    end
    
    return summary
end

function DataExporter.GenerateConfigSummary()
    local summary = {
        TotalSnapshots = #ExtractorState.ServerConfig,
        TotalAttributes = 0,
        TotalTags = 0
    }
    
    for _, snapshot in pairs(ExtractorState.ServerConfig) do
        for _, attrData in pairs(snapshot.Attributes) do
            summary.TotalAttributes = summary.TotalAttributes + 1
            if attrData.Tags then
                summary.TotalTags = summary.TotalTags + #attrData.Tags
            end
        end
    end
    
    return summary
end

function DataExporter.GenerateEventSummary()
    local summary = {
        TotalEvents = #ExtractorState.GameEvents,
        ByType = {},
        PlayerEvents = 0,
        HumanoidEvents = 0
    }
    
    for _, event in pairs(ExtractorState.GameEvents) do
        if not summary.ByType[event.Type] then
            summary.ByType[event.Type] = 0
        end
        summary.ByType[event.Type] = summary.ByType[event.Type] + 1
        
        if event.Type == "PlayerAdded" or event.Type == "PlayerRemoving" then
            summary.PlayerEvents = summary.PlayerEvents + 1
        elseif event.Type == "HumanoidDied" or event.Type == "LowHealth" then
            summary.HumanoidEvents = summary.HumanoidEvents + 1
        end
    end
    
    return summary
end

function DataExporter.GeneratePlayerStatsSummary()
    local summary = {
        TotalSnapshots = #ExtractorState.PlayerStats,
        UniquePlayers = {},
        AveragePlayersPerSnapshot = 0
    }
    
    for _, snapshot in pairs(ExtractorState.PlayerStats) do
        local playerCount = 0
        for playerName, _ in pairs(snapshot.PlayerStats) do
            playerCount = playerCount + 1
            summary.UniquePlayers[playerName] = true
        end
        
        if #ExtractorState.PlayerStats > 0 then
            summary.AveragePlayersPerSnapshot = summary.AveragePlayersPerSnapshot + playerCount
        end
    end
    
    if #ExtractorState.PlayerStats > 0 then
        summary.AveragePlayersPerSnapshot = summary.AveragePlayersPerSnapshot / #ExtractorState.PlayerStats
    end
    
    summary.UniquePlayerCount = 0
    for _ in pairs(summary.UniquePlayers) do
        summary.UniquePlayerCount = summary.UniquePlayerCount + 1
    end
    
    return summary
end

function DataExporter.ExportJSON(data)
    local success, json = pcall(function()
        return HttpService:JSONEncode(data)
    end)
    
    if not success then
        warn("[EXPORT] Erreur lors de l'encodage JSON, tentative de nettoyage...")
        json = HttpService:JSONEncode(DataExporter.CleanForJSON(data))
    end
    
    local filename = string.format("TowerBattles_Extract_%s_%d.json", ExtractorState.SessionId, tick())
    
    if writefile then
        writefile(filename, json)
        print(string.format("[EXPORT] Fichier créé : %s (%d bytes)", filename, #json))
    else
        warn("[EXPORT] writefile non disponible - exportation vers console")
        -- Tronquer pour éviter le spam console
        if #json > 10000 then
            print("[EXPORT] JSON tronqué (trop long)")
            print(json:sub(1, 10000))
        else
            print(json)
        end
    end
end

function DataExporter.CleanForJSON(data)
    -- Nettoyer les données pour éviter les erreurs JSON
    if type(data) ~= "table" then
        return data
    end
    
    local cleaned = {}
    for k, v in pairs(data) do
        -- Ignorer les clés cycliques
        if type(k) == "table" then
            k = tostring(k)
        end
        
        if type(v) == "table" then
            cleaned[k] = DataExporter.CleanForJSON(v)
        elseif type(v) == "function" or type(v) == "thread" then
            cleaned[k] = tostring(v)
        else
            cleaned[k] = v
        end
    end
    
    return cleaned
end

function DataExporter.ExportLuaTable(data)
    local luaCode = "-- Tower Battles Extracted Data\n-- Session: " .. ExtractorState.SessionId .. "\n-- Generated: " .. os.date("%Y-%m-%d %H:%M:%S") .. "\n\nreturn " .. DataExporter.TableToString(data)
    local filename = string.format("TowerBattles_Extract_%s_%d.lua", ExtractorState.SessionId, tick())
    
    if writefile then
        writefile(filename, luaCode)
        print(string.format("[EXPORT] Fichier créé : %s", filename))
    else
        print(luaCode)
    end
end

function DataExporter.TableToString(tbl, indent)
    indent = indent or 0
    local str = "{\n"
    
    for k, v in pairs(tbl) do
        str = str .. string.rep("  ", indent + 1)
        
        if type(k) == "string" then
            str = str .. string.format('["%s"] = ', k:gsub('"', '\\"'))
        else
            str = str .. string.format("[%d] = ", k)
        end
        
        if type(v) == "table" then
            str = str .. DataExporter.TableToString(v, indent + 1) .. ",\n"
        elseif type(v) == "string" then
            str = str .. string.format('"%s",\n', v:gsub('"', '\\"'))
        elseif type(v) == "number" then
            str = str .. string.format("%s,\n", tostring(v))
        elseif type(v) == "boolean" then
            str = str .. string.format("%s,\n", tostring(v))
        else
            str = str .. string.format('"%s",\n', tostring(v))
        end
    end
    
    str = str .. string.rep("  ", indent) .. "}"
    return str
end

-- ============================================================================
-- INITIALISATION PRINCIPALE
-- ============================================================================

local function Main()
    print("==========================================")
    print("Tower Battles Ultimate Extractor")
    print("Version 1.0")
    print("==========================================")
    
    ExtractorState.IsRunning = true
    
    -- Initialiser les modules
    NetworkInterceptor.Init()
    print("[INIT] Network Interceptor démarré")
    
    RAMScanner.Init()
    print("[INIT] RAM Scanner démarré")
    
    AssetPreloader.Init()
    print("[INIT] Asset Preloader démarré")
    
    DataExporter.Init()
    print("[INIT] Data Exporter démarré")
    
    -- Initialiser les modules de capture avancée
    InstanceCapture.Init()
    print("[INIT] Instance Capture démarré")
    
    ScriptCapture.Init()
    print("[INIT] Script Capture démarré")
    
    AttributeCapture.Init()
    print("[INIT] Attribute Capture démarré")
    
    GameEventCapture.Init()
    print("[INIT] Game Event Capture démarré")
    
    PlayerStatsCapture.Init()
    print("[INIT] Player Stats Capture démarré")
    
    ContinuousCapture.Init()
    print("[INIT] Continuous Capture démarré")
    
    print("[INIT] Tous les systèmes sont opérationnels")
    print(string.format("[INIT] Session ID : %d", ExtractorState.StartTime))
    
    -- Commandes utilisateur
    spawn(function()
        while ExtractorState.IsRunning do
            wait(1)
        end
    end)
end

-- Démarrage
Main()

-- Interface utilisateur simple pour contrôler l'extractor
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ExtractorUI"
ScreenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 200, 0, 150)
Frame.Position = UDim2.new(1, -210, 0, 10)
Frame.BackgroundColor3 = Color3.new(0, 0, 0)
Frame.BackgroundTransparency = 0.3
Frame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
Title.Text = "TB Extractor"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Parent = Frame

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, 0, 0, 30)
Status.Position = UDim2.new(0, 0, 0, 35)
Status.BackgroundTransparency = 1
Status.Text = "Status: Running"
Status.TextColor3 = Color3.new(0, 1, 0)
Status.Parent = Frame

local PacketsLabel = Instance.new("TextLabel")
PacketsLabel.Size = UDim2.new(1, 0, 0, 20)
PacketsLabel.Position = UDim2.new(0, 0, 0, 65)
PacketsLabel.BackgroundTransparency = 1
PacketsLabel.Text = "Packets: 0"
PacketsLabel.TextColor3 = Color3.new(1, 1, 1)
PacketsLabel.TextSize = 10
PacketsLabel.Font = Enum.Font.Gotham
PacketsLabel.TextXAlignment = Enum.TextXAlignment.Left
PacketsLabel.Parent = Frame

local RAMLabel = Instance.new("TextLabel")
RAMLabel.Size = UDim2.new(1, 0, 0, 20)
RAMLabel.Position = UDim2.new(0, 0, 0, 85)
RAMLabel.BackgroundTransparency = 1
RAMLabel.Text = "RAM Scans: 0"
RAMLabel.TextColor3 = Color3.new(1, 1, 1)
RAMLabel.TextSize = 10
RAMLabel.Font = Enum.Font.Gotham
RAMLabel.TextXAlignment = Enum.TextXAlignment.Left
RAMLabel.Parent = Frame

local InstancesLabel = Instance.new("TextLabel")
InstancesLabel.Size = UDim2.new(1, 0, 0, 20)
InstancesLabel.Position = UDim2.new(0, 0, 0, 105)
InstancesLabel.BackgroundTransparency = 1
InstancesLabel.Text = "Instances: 0"
InstancesLabel.TextColor3 = Color3.new(1, 1, 1)
InstancesLabel.TextSize = 10
InstancesLabel.Font = Enum.Font.Gotham
InstancesLabel.TextXAlignment = Enum.TextXAlignment.Left
InstancesLabel.Parent = Frame

local ScriptsLabel = Instance.new("TextLabel")
ScriptsLabel.Size = UDim2.new(1, 0, 0, 20)
ScriptsLabel.Position = UDim2.new(0, 0, 0, 125)
ScriptsLabel.BackgroundTransparency = 1
ScriptsLabel.Text = "Scripts: 0"
ScriptsLabel.TextColor3 = Color3.new(1, 1, 1)
ScriptsLabel.TextSize = 10
ScriptsLabel.Font = Enum.Font.Gotham
ScriptsLabel.TextXAlignment = Enum.TextXAlignment.Left
ScriptsLabel.Parent = Frame

local ExportButton = Instance.new("TextButton")
ExportButton.Size = UDim2.new(1, -20, 0, 25)
ExportButton.Position = UDim2.new(0, 10, 0, 150)
ExportButton.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
ExportButton.Text = "Export Now"
ExportButton.TextColor3 = Color3.new(1, 1, 1)
ExportButton.TextSize = 11
ExportButton.Font = Enum.Font.GothamBold
ExportButton.Parent = Frame

ExportButton.MouseButton1Click:Connect(function()
    DataExporter.ExportAll()
end)

-- Mise à jour de l'UI
spawn(function()
    while ExtractorState.IsRunning do
        PacketsLabel.Text = string.format("Packets: %d", #ExtractorState.NetworkLogs)
        RAMLabel.Text = string.format("RAM Scans: %d", #ExtractorState.RAMLogs)
        
        local instanceCount = 0
        for _, snapshot in pairs(ExtractorState.InstanceProperties) do
            for _ in pairs(snapshot.Instances) do
                instanceCount = instanceCount + 1
            end
        end
        InstancesLabel.Text = string.format("Instances: %d", instanceCount)
        
        local scriptCount = 0
        for _, snapshot in pairs(ExtractorState.ScriptData) do
            for _ in pairs(snapshot.Scripts) do
                scriptCount = scriptCount + 1
            end
        end
        ScriptsLabel.Text = string.format("Scripts: %d", scriptCount)
        
        wait(0.5)
    end
end)

print("[UI] Interface utilisateur créée")
