-- ============================================================================
-- BACKDOOR SCANNER - Détection des backdoors cachés
-- Scan pour détecter les backdoors qui pourraient permettre l'accès au jeu
-- ============================================================================

local BackdoorScanner = {}

-- ============================================================================
-- SCAN DES BACKDOORS CLASSIQUES
-- ============================================================================

BackdoorScanner.ClassicBackdoorScanner = {
    -- Scanner les backdoors classiques
    ScanClassicBackdoors = function()
        local results = {
            Backdoors = {},
            PotentialBackdoors = {},
            SuspiciousInstances = {}
        }
        
        -- Scanner les RemoteEvents avec noms suspects
        local replicatedStorage = game:GetService("ReplicatedStorage")
        
        for _, instance in pairs(replicatedStorage:GetDescendants()) do
            if instance:IsA("RemoteEvent") or instance:IsA("RemoteFunction") then
                local analysis = BackdoorScanner.ClassicBackdoorScanner.AnalyzeForBackdoor(instance)
                
                if analysis.IsBackdoor then
                    table.insert(results.Backdoors, analysis)
                elseif analysis.IsPotentialBackdoor then
                    table.insert(results.PotentialBackdoors, analysis)
                elseif analysis.IsSuspicious then
                    table.insert(results.SuspiciousInstances, analysis)
                end
            end
        end
        
        return results
    end,
    
    -- Analyser si c'est un backdoor
    AnalyzeForBackdoor = function(instance)
        local analysis = {
            Name = instance.Name,
            Path = instance:GetFullName(),
            ClassName = instance.ClassName,
            IsBackdoor = false,
            IsPotentialBackdoor = false,
            IsSuspicious = false,
            Indicators = {}
        }
        
        -- Indicateurs de backdoor
        local backdoorIndicators = {
            {Pattern = "admin", Weight = 3, Description = "Admin-related"},
            {Pattern = "kick", Weight = 3, Description = "Kick capability"},
            {Pattern = "ban", Weight = 3, Description = "Ban capability"},
            {Pattern = "execute", Weight = 4, Description = "Code execution"},
            {Pattern = "eval", Weight = 4, Description = "Code evaluation"},
            {Pattern = "run", Weight = 3, Description = "Code running"},
            {Pattern = "cmd", Weight = 2, Description = "Command execution"},
            {Pattern = "command", Weight = 2, Description = "Command execution"},
            {Pattern = "owner", Weight = 3, Description = "Ownership check"},
            {Pattern = "whitelist", Weight = 2, Description = "Whitelist check"},
            {Pattern = "blacklist", Weight = 2, Description = "Blacklist check"},
            {Pattern = "mod", Weight = 2, Description = "Moderator check"},
            {Pattern = "remote", Weight = 1, Description = "Generic remote name"},
            {Pattern = "event", Weight = 1, Description = "Generic event name"},
            {Pattern = "function", Weight = 1, Description = "Generic function name"},
            {Pattern = "fire", Weight = 1, Description = "Generic fire name"},
            {Pattern = "invoke", Weight = 1, Description = "Generic invoke name"},
            {Pattern = "send", Weight = 1, Description = "Generic send name"},
            {Pattern = "receive", Weight = 1, Description = "Generic receive name"},
            {Pattern = "data", Weight = 1, Description = "Generic data name"},
            {Pattern = "info", Weight = 1, Description = "Generic info name"},
            {Pattern = "get", Weight = 1, Description = "Generic get name"},
            {Pattern = "set", Weight = 1, Description = "Generic set name"},
            {Pattern = "update", Weight = 1, Description = "Generic update name"},
            {Pattern = "change", Weight = 1, Description = "Generic change name"},
            {Pattern = "modify", Weight = 1, Description = "Generic modify name"},
            {Pattern = "adjust", Weight = 1, Description = "Generic adjust name"},
            {Pattern = "control", Weight = 2, Description = "Control capability"},
            {Pattern = "manage", Weight = 2, Description = "Management capability"},
            {Pattern = "access", Weight = 2, Description = "Access capability"}
        }
        
        local totalWeight = 0
        local lowerName = instance.Name:lower()
        
        for _, indicator in pairs(backdoorIndicators) do
            if lowerName:find(indicator.Pattern) then
                totalWeight = totalWeight + indicator.Weight
                table.insert(analysis.Indicators, indicator)
            end
        end
        
        -- Nom obscurci = très suspect
        if instance.Name:match("^[%d_]+$") or (instance.Name:match("^[%a%d]+$") and #instance.Name < 4) then
            totalWeight = totalWeight + 5
            table.insert(analysis.Indicators, {Pattern = "Obfuscated", Weight = 5, Description = "Obfuscated name"})
        end
        
        -- Déterminer le niveau de menace
        if totalWeight >= 5 then
            analysis.IsBackdoor = true
        elseif totalWeight >= 3 then
            analysis.IsPotentialBackdoor = true
        elseif totalWeight >= 1 then
            analysis.IsSuspicious = true
        end
        
        analysis.TotalWeight = totalWeight
        
        return analysis
    end
}

-- ============================================================================
-- SCAN DES BACKDOORS DANS LES SCRIPTS
-- ============================================================================

BackdoorScanner.ScriptBackdoorScanner = {
    -- Scanner les backdoors dans les scripts
    ScanScriptBackdoors = function()
        local results = {
            BackdoorScripts = {},
            PotentialBackdoorScripts = {},
            SuspiciousScripts = {}
        }
        
        for _, script in pairs(game:GetDescendants()) do
            if script:IsA("Script") or script:IsA("LocalScript") or script:IsA("ModuleScript") then
                local analysis = BackdoorScanner.ScriptBackdoorScanner.AnalyzeScriptForBackdoor(script)
                
                if analysis.IsBackdoor then
                    table.insert(results.BackdoorScripts, analysis)
                elseif analysis.IsPotentialBackdoor then
                    table.insert(results.PotentialBackdoorScripts, analysis)
                elseif analysis.IsSuspicious then
                    table.insert(results.SuspiciousScripts, analysis)
                end
            end
        end
        
        return results
    end,
    
    -- Analyser si un script contient un backdoor
    AnalyzeScriptForBackdoor = function(script)
        local analysis = {
            Name = script.Name,
            Path = script:GetFullName(),
            ClassName = script.ClassName,
            IsBackdoor = false,
            IsPotentialBackdoor = false,
            IsSuspicious = false,
            BackdoorFunctions = {},
            Indicators = {}
        }
        
        -- Analyser le bytecode
        if getscriptbytecode then
            local success, bytecode = pcall(function()
                return getscriptbytecode(script)
            end)
            if success then
                local backdoorFunctions = BackdoorScanner.ScriptBackdoorScanner.FindBackdoorFunctions(bytecode)
                analysis.BackdoorFunctions = backdoorFunctions
                
                -- Catégoriser
                for _, func in pairs(backdoorFunctions) do
                    if func.Category == "Critical" then
                        analysis.IsBackdoor = true
                    elseif func.Category == "High" then
                        if not analysis.IsBackdoor then
                            analysis.IsPotentialBackdoor = true
                        end
                    elseif func.Category == "Medium" then
                        if not analysis.IsBackdoor and not analysis.IsPotentialBackdoor then
                            analysis.IsSuspicious = true
                        end
                    end
                end
            end
        end
        
        -- Vérifier le nom
        if script.Name:match("^[%d_]+$") or (script.Name:match("^[%a%d]+$") and #script.Name < 4) then
            if not analysis.IsBackdoor then
                analysis.IsPotentialBackdoor = true
            end
            table.insert(analysis.Indicators, "Obfuscated name")
        end
        
        -- Script désactivé = suspect
        if script.Disabled then
            if not analysis.IsBackdoor and not analysis.IsPotentialBackdoor then
                analysis.IsSuspicious = true
            end
            table.insert(analysis.Indicators, "Disabled script")
        end
        
        return analysis
    end,
    
    -- Trouver les fonctions de backdoor
    FindBackdoorFunctions = function(bytecode)
        local functions = {}
        local lower = bytecode:lower()
        
        -- Fonctions critiques (backdoor certain)
        local criticalFunctions = {
            {Pattern = "loadstring", Category = "Critical", Description = "loadstring - code execution"},
            {Pattern = "getfenv", Category = "Critical", Description = "getfenv - environment access"},
            {Pattern = "setfenv", Category = "Critical", Description = "setfenv - environment manipulation"},
            {Pattern = "debug.getregistry", Category = "Critical", Description = "debug.getregistry - registry access"},
            {Pattern = "debug.setmetatable", Category = "Critical", Description = "debug.setmetatable - metatable manipulation"},
            {Pattern = "clonefunction", Category = "Critical", Description = "clonefunction - function cloning"},
            {Pattern = "hookfunction", Category = "Critical", Description = "hookfunction - function hooking"},
            {Pattern = "newcclosure", Category = "Critical", Description = "newcclosure - closure creation"},
            {Pattern = "getrawmetatable", Category = "Critical", Description = "getrawmetatable - metatable access"},
            {Pattern = "setrawmetatable", Category = "Critical", Description = "setrawmetatable - metatable manipulation"},
            {Pattern = "getnilinstances", Category = "Critical", Description = "getnilinstances - nil instance access"},
            {Pattern = "getinstances", Category = "Critical", Description = "getinstances - instance enumeration"},
            {Pattern = "getconnections", Category = "Critical", Description = "getconnections - signal connections"},
            {Pattern = "setclipboard", Category = "Critical", Description = "setclipboard - clipboard manipulation"},
            {Pattern = "rconsolename", Category = "Critical", Description = "rconsolename - console manipulation"},
            {Pattern = "rconsoleprint", Category = "Critical", Description = "rconsoleprint - console manipulation"},
            {Pattern = "rconsoleclear", Category = "Critical", Description = "rconsoleclear - console manipulation"},
            {Pattern = "rconsoleinfo", Category = "Critical", Description = "rconsoleinfo - console manipulation"},
            {Pattern = "queue_on_teleport", Category = "Critical", Description = "queue_on_teleport - teleport queue"},
            {Pattern = "queueonteleport", Category = "Critical", Description = "queueonteleport - teleport queue"},
            {Pattern = "httpget", Category = "Critical", Description = "httpget - HTTP requests"},
            {Pattern = "httprequest", Category = "Critical", Description = "httprequest - HTTP requests"},
            {Pattern = "http.request", Category = "Critical", Description = "http.request - HTTP requests"},
            {Pattern = "syn.request", Category = "Critical", Description = "syn.request - HTTP requests"},
            {Pattern = "game:HttpGet", Category = "Critical", Description = "game:HttpGet - HTTP requests"},
            {Pattern = "game:HttpGetAsync", Category = "Critical", Description = "game:HttpGetAsync - HTTP requests"},
            {Pattern = "require(game:HttpGet", Category = "Critical", Description = "Remote require via HTTP"}
        }
        
        for _, func in pairs(criticalFunctions) do
            if lower:find(func.Pattern:lower()) then
                table.insert(functions, func)
            end
        end
        
        -- Fonctions de haute priorité
        local highFunctions = {
            {Pattern = "kick", Category = "High", Description = "kick - player kick"},
            {Pattern = "ban", Category = "High", Description = "ban - player ban"},
            {Pattern = "admin", Category = "High", Description = "admin - admin commands"},
            {Pattern = "owner", Category = "High", Description = "owner - ownership check"},
            {Pattern = "whitelist", Category = "High", Description = "whitelist - whitelist check"},
            {Pattern = "blacklist", Category = "High", Description = "blacklist - blacklist check"},
            {Pattern = "execute", Category = "High", Description = "execute - code execution"},
            {Pattern = "eval", Category = "High", Description = "eval - code evaluation"},
            {Pattern = "run", Category = "High", Description = "run - code running"},
            {Pattern = "command", Category = "High", Description = "command - command execution"},
            {Pattern = "cmd", Category = "High", Description = "cmd - command execution"}
        }
        
        for _, func in pairs(highFunctions) do
            if lower:find(func.Pattern:lower()) then
                table.insert(functions, func)
            end
        end
        
        -- Fonctions de moyenne priorité
        local mediumFunctions = {
            {Pattern = "destroy", Category = "Medium", Description = "destroy - destruction"},
            {Pattern = "remove", Category = "Medium", Description = "remove - removal"},
            {Pattern = "delete", Category = "Medium", Description = "delete - deletion"},
            {Pattern = "clear", Category = "Medium", Description = "clear - clearing"},
            {Pattern = "reset", Category = "Medium", Description = "reset - resetting"},
            {Pattern = "set", Category = "Medium", Description = "set - setting"},
            {Pattern = "get", Category = "Medium", Description = "get - getting"},
            {Pattern = "change", Category = "Medium", Description = "change - changing"},
            {Pattern = "modify", Category = "Medium", Description = "modify - modifying"},
            {Pattern = "adjust", Category = "Medium", Description = "adjust - adjusting"},
            {Pattern = "control", Category = "Medium", Description = "control - controlling"},
            {Pattern = "manage", Category = "Medium", Description = "manage - managing"},
            {Pattern = "access", Category = "Medium", Description = "access - accessing"}
        }
        
        for _, func in pairs(mediumFunctions) do
            if lower:find(func.Pattern:lower()) then
                table.insert(functions, func)
            end
        end
        
        return functions
    end
}

-- ============================================================================
-- SCAN DES BACKDOORS CACHÉS (GC)
-- ============================================================================

BackdoorScanner.HiddenBackdoorScanner = {
    -- Scanner les backdoors cachés dans le GC
    ScanHiddenBackdoors = function()
        if not getgc then
            return {Available = false, Reason = "getgc not available"}
        end
        
        local results = {
            HiddenBackdoors = {},
            SuspiciousTables = {}
        }
        
        local allTables = getgc(true)
        
        for _, tbl in pairs(allTables) do
            local analysis = BackdoorScanner.HiddenBackdoorScanner.AnalyzeTableForBackdoor(tbl)
            
            if analysis.IsBackdoor then
                table.insert(results.HiddenBackdoors, analysis)
            elseif analysis.IsSuspicious then
                table.insert(results.SuspiciousTables, analysis)
            end
        end
        
        return results
    end,
    
    -- Analyser une table pour backdoor
    AnalyzeTableForBackdoor = function(tbl)
        local analysis = {
            Address = tostring(tbl),
            IsBackdoor = false,
            IsSuspicious = false,
            Indicators = {}
        }
        
        -- Vérifier si la table contient des fonctions de backdoor
        for k, v in pairs(tbl) do
            local keyStr = tostring(k):lower()
            local valueStr = tostring(v):lower()
            
            -- Clés suspects
            local suspiciousKeys = {"admin", "kick", "ban", "execute", "eval", "run", "cmd", "command", "owner", "whitelist", "blacklist", "mod", "backdoor", "remote", "event", "function"}
            
            for _, key in pairs(suspiciousKeys) do
                if keyStr:find(key) then
                    analysis.IsSuspicious = true
                    table.insert(analysis.Indicators, string.format("Suspicious key: %s", key))
                    break
                end
            end
            
            -- Valeurs suspects
            if type(v) == "function" then
                local funcName = tostring(k)
                local suspiciousFuncs = {"loadstring", "getfenv", "setfenv", "debug", "clonefunction", "hookfunction", "newcclosure", "getrawmetatable", "setrawmetatable", "getnilinstances", "getinstances", "getconnections", "setclipboard"}
                
                for _, func in pairs(suspiciousFuncs) do
                    if funcName:find(func) then
                        analysis.IsBackdoor = true
                        table.insert(analysis.Indicators, string.format("Backdoor function: %s", func))
                        break
                    end
                end
            end
        end
        
        return analysis
    end
}

-- ============================================================================
-- SCAN DES BACKDOORS VIA ATTRIBUTS
-- ============================================================================

BackdoorScanner.AttributeBackdoorScanner = {
    -- Scanner les backdoors via attributs
    ScanAttributeBackdoors = function()
        local results = {
            BackdoorAttributes = {},
            SuspiciousAttributes = {}
        }
        
        for _, instance in pairs(game:GetDescendants()) do
            if instance.GetAttributes then
                local success, attrs = pcall(function()
                    return instance:GetAttributes()
                end)
                if success then
                    for attrName, attrValue in pairs(attrs) do
                        local analysis = BackdoorScanner.AttributeBackdoorScanner.AnalyzeAttribute(attrName, attrValue, instance)
                        
                        if analysis.IsBackdoor then
                            table.insert(results.BackdoorAttributes, analysis)
                        elseif analysis.IsSuspicious then
                            table.insert(results.SuspiciousAttributes, analysis)
                        end
                    end
                end
            end
        end
        
        return results
    end,
    
    -- Analyser un attribut
    AnalyzeAttribute = function(attrName, attrValue, instance)
        local analysis = {
            Name = attrName,
            Value = tostring(attrValue),
            Instance = instance:GetFullName(),
            IsBackdoor = false,
            IsSuspicious = false
        }
        
        local lowerName = attrName:lower()
        local suspiciousNames = {"admin", "kick", "ban", "execute", "eval", "run", "cmd", "command", "owner", "whitelist", "blacklist", "mod", "backdoor", "remote", "event", "function", "key", "token", "password", "secret"}
        
        for _, name in pairs(suspiciousNames) do
            if lowerName:find(name) then
                analysis.IsSuspicious = true
                if name == "admin" or name == "kick" or name == "ban" or name == "execute" or name == "eval" or name == "run" or name == "backdoor" then
                    analysis.IsBackdoor = true
                end
                break
            end
        end
        
        return analysis
    end
}

-- ============================================================================
-- SCAN COMPLET DES BACKDOORS
-- ============================================================================

function BackdoorScanner.RunFullBackdoorScan()
    print("[BACKDOOR_SCANNER] Scan des backdoors...")
    
    local startTime = tick()
    local results = {
        Timestamp = tick(),
        Duration = 0,
        ClassicBackdoors = nil,
        ScriptBackdoors = nil,
        HiddenBackdoors = nil,
        AttributeBackdoors = nil,
        Summary = {}
    }
    
    -- 1. Scan des backdoors classiques
    print("[BACKDOOR_SCANNER] Scan des backdoors classiques...")
    results.ClassicBackdoors = BackdoorScanner.ClassicBackdoorScanner.ScanClassicBackdoors()
    
    -- 2. Scan des backdoors dans les scripts
    print("[BACKDOOR_SCANNER] Scan des backdoors dans les scripts...")
    results.ScriptBackdoors = BackdoorScanner.ScriptBackdoorScanner.ScanScriptBackdoors()
    
    -- 3. Scan des backdoors cachés
    print("[BACKDOOR_SCANNER] Scan des backdoors cachés...")
    results.HiddenBackdoors = BackdoorScanner.HiddenBackdoorScanner.ScanHiddenBackdoors()
    
    -- 4. Scan des backdoors via attributs
    print("[BACKDOOR_SCANNER] Scan des backdoors via attributs...")
    results.AttributeBackdoors = BackdoorScanner.AttributeBackdoorScanner.ScanAttributeBackdoors()
    
    results.Duration = tick() - startTime
    
    -- Résumé
    results.Summary = {
        Backdoors = #results.ClassicBackdoors.Backdoors,
        PotentialBackdoors = #results.ClassicBackdoors.PotentialBackdoors,
        SuspiciousRemotes = #results.ClassicBackdoors.SuspiciousInstances,
        BackdoorScripts = #results.ScriptBackdoors.BackdoorScripts,
        PotentialBackdoorScripts = #results.ScriptBackdoors.PotentialBackdoorScripts,
        SuspiciousScripts = #results.ScriptBackdoors.SuspiciousScripts,
        HiddenBackdoors = results.HiddenBackdoors.Available and #results.HiddenBackdoors.HiddenBackdoors or 0,
        BackdoorAttributes = #results.AttributeBackdoors.BackdoorAttributes
    }
    
    print(string.format("[BACKDOOR_SCANNER] Scan terminé en %.2fs", results.Duration))
    print(string.format("[BACKDOOR_SCANNER] Backdoors détectés: %d", results.Summary.Backdoors))
    print(string.format("[BACKDOOR_SCANNER] Backdoors potentiels: %d", results.Summary.PotentialBackdoors))
    print(string.format("[BACKDOOR_SCANNER] Scripts backdoor: %d", results.Summary.BackdoorScripts))
    print(string.format("[BACKDOOR_SCANNER] Backdoors cachés: %d", results.Summary.HiddenBackdoors))
    print(string.format("[BACKDOOR_SCANNER] Attributs backdoor: %d", results.Summary.BackdoorAttributes))
    
    return results
end

return BackdoorScanner
