-- ============================================================================
-- EXTERNAL API INTEGRATION - Integration with external API for script understanding
-- Uses external API to understand and reconstruct script logic
-- ============================================================================

local ExternalAPIIntegration = {}

-- ============================================================================
-- EXTERNAL API CONFIGURATION
-- ============================================================================

ExternalAPIIntegration.Config = {
    -- API Endpoint (Groq - Free, Fast, High Quality)
    APIEndpoint = "https://api.groq.com/openai/v1/chat/completions",
    APIKey = "", -- To configure
    Model = "llama-3.1-70b-versatile",
    
    -- Parameters
    MaxTokens = 4000,
    Temperature = 0.7,
    
    -- Enable/Disable
    Enabled = false -- Disabled by default (requires API key)
}

-- ============================================================================
-- PROMPT PREPARATION
-- ============================================================================

ExternalAPIIntegration.PromptBuilder = {
    -- Build a prompt for script analysis
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
    
    -- Format upvalues
    FormatUpvalues = function(upvalues)
        local formatted = ""
        for name, value in pairs(upvalues) do
            formatted = formatted .. string.format("- %s: %s\n", name, tostring(value))
        end
        return formatted
    end,
    
    -- Build a prompt for script reconstruction
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
-- EXTERNAL API CALL
-- ============================================================================

ExternalAPIIntegration.ExternalAPI = {
    -- Call external API
    CallExternalAPI = function(prompt)
        if not ExternalAPIIntegration.Config.Enabled then
            return {Success = false, Reason = "External API integration disabled"}
        end
        
        if ExternalAPIIntegration.Config.APIKey == "" then
            return {Success = false, Reason = "API key not configured"}
        end
        
        local httpService = game:GetService("HttpService")
        
        local success, response = pcall(function()
            return httpService:RequestAsync({
                Url = ExternalAPIIntegration.Config.APIEndpoint,
                Method = "POST",
                Headers = {
                    ["Content-Type"] = "application/json",
                    ["Authorization"] = "Bearer " .. ExternalAPIIntegration.Config.APIKey
                },
                Body = httpService:JSONEncode({
                    model = ExternalAPIIntegration.Config.Model,
                    messages = {
                        {role = "system", content = "You are a Roblox game reverse-engineering expert."},
                        {role = "user", content = prompt}
                    },
                    max_tokens = ExternalAPIIntegration.Config.MaxTokens,
                    temperature = ExternalAPIIntegration.Config.Temperature
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
-- ANALYSIS WITH EXTERNAL API
-- ============================================================================

ExternalAPIIntegration.ScriptAnalyzer = {
    -- Analyze script with external API
    AnalyzeWithExternalAPI = function(scriptData)
        print(string.format("[EXTERNAL API] Analyzing script: %s", scriptData.Name))
        
        local prompt = ExternalAPIIntegration.PromptBuilder.BuildScriptAnalysisPrompt(scriptData)
        local apiResponse = ExternalAPIIntegration.ExternalAPI.CallExternalAPI(prompt)
        
        if not apiResponse.Success then
            print(string.format("[EXTERNAL API] Error: %s", apiResponse.Reason))
            return apiResponse
        end
        
        print("[EXTERNAL API] Analysis completed successfully")
        
        -- Parse JSON response
        local httpService = game:GetService("HttpService")
        local success, parsed = pcall(function()
            return httpService:JSONDecode(apiResponse.Response)
        end)
        
        if not success then
            print("[EXTERNAL API] Error parsing JSON")
            return {Success = false, Reason = "Failed to parse JSON response"}
        end
        
        return {
            Success = true,
            Analysis = parsed,
            RawResponse = apiResponse.Response
        }
    end
}

-- ============================================================================
-- RECONSTRUCTION WITH EXTERNAL API
-- ============================================================================

ExternalAPIIntegration.ScriptReconstructor = {
    -- Reconstruct script with external API
    ReconstructWithExternalAPI = function(scriptData, analysis)
        print(string.format("[EXTERNAL API] Reconstructing script: %s", scriptData.Name))
        
        local prompt = ExternalAPIIntegration.PromptBuilder.BuildScriptReconstructionPrompt(scriptData, analysis)
        local apiResponse = ExternalAPIIntegration.ExternalAPI.CallExternalAPI(prompt)
        
        if not apiResponse.Success then
            print(string.format("[EXTERNAL API] Error: %s", apiResponse.Reason))
            return apiResponse
        end
        
        print("[EXTERNAL API] Reconstruction completed successfully")
        
        -- Extract code from response
        local code = apiResponse.Response:match("```lua\n(.-)```") or apiResponse.Response:match("```\n(.-)```") or apiResponse.Response
        
        return {
            Success = true,
            ReconstructedCode = code,
            RawResponse = apiResponse.Response
        }
    end
}

-- ============================================================================
-- BATCH ANALYSIS
-- ============================================================================

ExternalAPIIntegration.BatchAnalyzer = {
    -- Analyze multiple scripts in batch
    AnalyzeBatch = function(scriptDataList)
        print(string.format("[EXTERNAL API] Batch analysis of %d scripts", #scriptDataList))
        
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
            local result = ExternalAPIIntegration.ScriptAnalyzer.AnalyzeWithExternalAPI(scriptData)
            
            result.ScriptName = scriptData.Name
            table.insert(results.Scripts, result)
            
            if result.Success then
                results.Summary.Successful = results.Summary.Successful + 1
            else
                results.Summary.Failed = results.Summary.Failed + 1
            end
            
            -- Delay to avoid rate limiting
            wait(1)
        end
        
        print(string.format("[EXTERNAL API] Batch analysis completed - %d successful, %d failed", results.Summary.Successful, results.Summary.Failed))
        
        return results
    end
}

-- ============================================================================
-- CONFIGURATION
-- ============================================================================

function ExternalAPIIntegration.Configure(config)
    if config.APIEndpoint then
        ExternalAPIIntegration.Config.APIEndpoint = config.APIEndpoint
    end
    if config.APIKey then
        ExternalAPIIntegration.Config.APIKey = config.APIKey
    end
    if config.Model then
        ExternalAPIIntegration.Config.Model = config.Model
    end
    if config.MaxTokens then
        ExternalAPIIntegration.Config.MaxTokens = config.MaxTokens
    end
    if config.Temperature then
        ExternalAPIIntegration.Config.Temperature = config.Temperature
    end
    if config.Enabled ~= nil then
        ExternalAPIIntegration.Config.Enabled = config.Enabled
    end
    
    print("[EXTERNAL API] Configuration updated")
    print(string.format("[EXTERNAL API] Enabled: %s", ExternalAPIIntegration.Config.Enabled))
end

return ExternalAPIIntegration
