-- ============================================================================
-- LLM INTEGRATION - Intégration avec LLM pour compréhension des scripts
-- Utilisation d'un LLM pour comprendre et reconstruire la logique des scripts
-- ============================================================================

local LLMIntegration = {}

-- ============================================================================
-- CONFIGURATION LLM
-- ============================================================================

LLMIntegration.Config = {
    -- API Endpoint (à configurer)
    APIEndpoint = "https://api.openai.com/v1/chat/completions",
    APIKey = "", -- À configurer
    Model = "gpt-4",
    
    -- Paramètres
    MaxTokens = 4000,
    Temperature = 0.7,
    
    -- Activer/Désactiver
    Enabled = false -- Désactivé par défaut (nécessite API key)
}

-- ============================================================================
-- PRÉPARATION DES PROMPTS
-- ============================================================================

LLMIntegration.PromptBuilder = {
    -- Construire un prompt pour l'analyse de script
    BuildScriptAnalysisPrompt = function(scriptData)
        local prompt = [[
You are a Roblox game reverse-engineering expert. Analyze the following script data and provide detailed insights.

Script Information:
- Name: ]] .. scriptData.Name .. [[
- ClassName: ]] .. scriptData.ClassName .. [[
- Path: ]] .. scriptData.Path .. [[
- Purpose: ]] .. (scriptData.Purpose or "Unknown") [[

Bytecode Analysis:
- Length: ]] .. (scriptData.BytecodeAnalysis and scriptData.BytecodeAnalysis.Length or "N/A") .. [[
- Instructions: ]] .. (scriptData.BytecodeAnalysis and scriptData.BytecodeAnalysis.Instructions or "N/A") .. [[
- Strings Found: ]] .. (scriptData.BytecodeAnalysis and #scriptData.BytecodeAnalysis.Strings or 0) .. [[

Strings Found:
]] .. table.concat(scriptData.BytecodeAnalysis and scriptData.BytecodeAnalysis.Strings or {}, "\n") .. [[

Patterns Detected:
- Remote Calls: ]] .. (scriptData.BytecodeAnalysis and scriptData.BytecodeAnalysis.Patterns.RemoteCalls or 0) .. [[
- Require Calls: ]] .. (scriptData.BytecodeAnalysis and scriptData.BytecodeAnalysis.Patterns.RequireCalls or 0) .. [[
- GetService Calls: ]] .. (scriptData.BytecodeAnalysis and scriptData.BytecodeAnalysis.Patterns.GetServiceCalls or 0) .. [[

Upvalues:
]] .. LLMIntegration.PromptBuilder.FormatUpvalues(scriptData.Upvalues or {}) .. [[

Please provide:
1. A detailed analysis of what this script does
2. The likely game mechanics it implements
3. Key functions and their purposes
4. Dependencies on other scripts/modules
5. Suggestions for reconstruction

Format your response as JSON with the following structure:
{
    "analysis": "Detailed analysis",
    "purpose": "Main purpose",
    "mechanics": ["mechanic1", "mechanic2"],
    "functions": [{"name": "function_name", "purpose": "purpose"}],
    "dependencies": ["dependency1", "dependency2"],
    "reconstruction_suggestions": ["suggestion1", "suggestion2"]
}
]]
        
        return prompt
    end,
    
    -- Formater les upvalues
    FormatUpvalues = function(upvalues)
        local formatted = ""
        for name, value in pairs(upvalues) do
            formatted = formatted .. string.format("- %s: %s\n", name, tostring(value))
        end
        return formatted
    end,
    
    -- Construire un prompt pour la reconstruction de script
    BuildScriptReconstructionPrompt = function(scriptData, analysis)
        local prompt = [[
You are a Roblox game reconstruction expert. Based on the following analysis, reconstruct the script code.

Original Script:
- Name: ]] .. scriptData.Name .. [[
- ClassName: ]] .. scriptData.ClassName .. [[
- Path: ]] .. scriptData.Path .. [[

Analysis:
]] .. analysis .. [[

Please reconstruct the script code with:
1. Proper service initialization
2. All necessary functions
3. Correct logic flow
4. Error handling
5. Comments explaining the code

Provide the reconstructed code in a code block.
]]
        
        return prompt
    end
}

-- ============================================================================
-- APPEL API LLM
-- ============================================================================

LLMIntegration.LLMAPI = {
    -- Appeler l'API LLM
    CallLLM = function(prompt)
        if not LLMIntegration.Config.Enabled then
            return {Success = false, Reason = "LLM integration disabled"}
        end
        
        if LLMIntegration.Config.APIKey == "" then
            return {Success = false, Reason = "API key not configured"}
        end
        
        local httpService = game:GetService("HttpService")
        
        local success, response = pcall(function()
            return httpService:RequestAsync({
                Url = LLMIntegration.Config.APIEndpoint,
                Method = "POST",
                Headers = {
                    ["Content-Type"] = "application/json",
                    ["Authorization"] = "Bearer " .. LLMIntegration.Config.APIKey
                },
                Body = httpService:JSONEncode({
                    model = LLMIntegration.Config.Model,
                    messages = {
                        {role = "system", content = "You are a Roblox game reverse-engineering expert."},
                        {role = "user", content = prompt}
                    },
                    max_tokens = LLMIntegration.Config.MaxTokens,
                    temperature = LLMIntegration.Config.Temperature
                })
            })
        end)
        
        if not success then
            return {Success = false, Reason = response}
        end
        
        if response.StatusCode ~= 200 then
            return {Success = false, Reason = "API returned status " .. response.StatusCode}
        end
        
        local body = httpService:JSONDecode(response.Body)
        
        return {
            Success = true,
            Response = body.choices[1].message.content
        }
    end
}

-- ============================================================================
-- ANALYSE AVEC LLM
-- ============================================================================

LLMIntegration.ScriptAnalyzer = {
    -- Analyser un script avec le LLM
    AnalyzeWithLLM = function(scriptData)
        print(string.format("[LLM] Analyse du script: %s", scriptData.Name))
        
        local prompt = LLMIntegration.PromptBuilder.BuildScriptAnalysisPrompt(scriptData)
        local llmResponse = LLMIntegration.LLMAPI.CallLLM(prompt)
        
        if not llmResponse.Success then
            print(string.format("[LLM] Erreur: %s", llmResponse.Reason))
            return llmResponse
        end
        
        print("[LLM] Analyse terminée avec succès")
        
        -- Parser la réponse JSON
        local httpService = game:GetService("HttpService")
        local success, parsed = pcall(function()
            return httpService:JSONDecode(llmResponse.Response)
        end)
        
        if not success then
            print("[LLM] Erreur parsing JSON")
            return {Success = false, Reason = "Failed to parse JSON response"}
        end
        
        return {
            Success = true,
            Analysis = parsed,
            RawResponse = llmResponse.Response
        }
    end
}

-- ============================================================================
-- RECONSTRUCTION AVEC LLM
-- ============================================================================

LLMIntegration.ScriptReconstructor = {
    -- Reconstruire un script avec le LLM
    ReconstructWithLLM = function(scriptData, analysis)
        print(string.format("[LLM] Reconstruction du script: %s", scriptData.Name))
        
        local prompt = LLMIntegration.PromptBuilder.BuildScriptReconstructionPrompt(scriptData, analysis)
        local llmResponse = LLMIntegration.LLMAPI.CallLLM(prompt)
        
        if not llmResponse.Success then
            print(string.format("[LLM] Erreur: %s", llmResponse.Reason))
            return llmResponse
        end
        
        print("[LLM] Reconstruction terminée avec succès")
        
        -- Extraire le code de la réponse
        local code = llmResponse.Response:match("```lua\n(.-)```") or llmResponse.Response:match("```\n(.-)```") or llmResponse.Response
        
        return {
            Success = true,
            ReconstructedCode = code,
            RawResponse = llmResponse.Response
        }
    end
}

-- ============================================================================
-- ANALYSE EN LOT
-- ============================================================================

LLMIntegration.BatchAnalyzer = {
    -- Analyser plusieurs scripts en lot
    AnalyzeBatch = function(scriptDataList)
        print(string.format("[LLM] Analyse en lot de %d scripts", #scriptDataList))
        
        local results = {
            Timestamp = tick(),
            Scripts = {},
            Summary = {
                Total = #scriptDataList,
                Successful = 0,
                Failed = 0
            }
        }
        
        for _, scriptData in pairs(scriptDataList) do
            local result = LLMIntegration.ScriptAnalyzer.AnalyzeWithLLM(scriptData)
            
            result.ScriptName = scriptData.Name
            table.insert(results.Scripts, result)
            
            if result.Success then
                results.Summary.Successful = results.Summary.Successful + 1
            else
                results.Summary.Failed = results.Summary.Failed + 1
            end
            
            -- Délai pour éviter rate limiting
            wait(1)
        end
        
        print(string.format("[LLM] Analyse en lot terminée - %d succès, %d échecs", results.Summary.Successful, results.Summary.Failed))
        
        return results
    end
}

-- ============================================================================
-- CONFIGURATION
-- ============================================================================

function LLMIntegration.Configure(config)
    if config.APIEndpoint then
        LLMIntegration.Config.APIEndpoint = config.APIEndpoint
    end
    if config.APIKey then
        LLMIntegration.Config.APIKey = config.APIKey
    end
    if config.Model then
        LLMIntegration.Config.Model = config.Model
    end
    if config.MaxTokens then
        LLMIntegration.Config.MaxTokens = config.MaxTokens
    end
    if config.Temperature then
        LLMIntegration.Config.Temperature = config.Temperature
    end
    if config.Enabled ~= nil then
        LLMIntegration.Config.Enabled = config.Enabled
    end
    
    print("[LLM] Configuration mise à jour")
    print(string.format("[LLM] Enabled: %s", LLMIntegration.Config.Enabled))
end

return LLMIntegration
