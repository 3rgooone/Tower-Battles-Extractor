-- ============================================================================
-- SCRIPT DECRYPTOR - Décryptage et analyse de bytecode
-- Tentative de décryptage des scripts encryptés et analyse du bytecode
-- ============================================================================

local ScriptDecryptor = {}

-- ============================================================================
-- ANALYSE DE BYTECODE
-- ============================================================================

ScriptDecryptor.BytecodeAnalyzer = {
    -- Analyser le bytecode d'un script
    AnalyzeBytecode = function(script)
        if not getscriptbytecode then
            return {Available = false, Reason = "getscriptbytecode not available"}
        end
        
        local success, bytecode = pcall(function()
            return getscriptbytecode(script)
        end)
        
        if not success then
            return {Available = false, Reason = "Failed to get bytecode"}
        end
        
        local analysis = {
            Length = #bytecode,
            Hash = ScriptDecryptor.BytecodeAnalyzer.HashBytecode(bytecode),
            IsEncrypted = ScriptDecryptor.BytecodeAnalyzer.IsEncrypted(bytecode),
            IsObfuscated = ScriptDecryptor.BytecodeAnalyzer.IsObfuscated(bytecode),
            Header = ScriptDecryptor.BytecodeAnalyzer.ExtractHeader(bytecode),
            Instructions = ScriptDecryptor.BytecodeAnalyzer.CountInstructions(bytecode),
            Constants = ScriptDecryptor.BytecodeAnalyzer.ExtractConstants(bytecode),
            Strings = ScriptDecryptor.BytecodeAnalyzer.ExtractStrings(bytecode),
            Patterns = ScriptDecryptor.BytecodeAnalyzer.FindPatterns(bytecode)
        }
        
        return analysis
    end,
    
    -- Hash du bytecode
    HashBytecode = function(bytecode)
        local hash = 0
        for i = 1, math.min(#bytecode, 1000) do
            hash = hash + string.byte(bytecode, i)
        end
        return string.format("%x", hash)
    end,
    
    -- Vérifier si encrypté
    IsEncrypted = function(bytecode)
        local header = bytecode:sub(1, 20)
        
        -- Signes d'encryption
        if header:find("\0") then
            return true
        end
        
        if #bytecode < 50 then
            return true
        end
        
        -- Vérifier si c'est du bytecode Luau valide
        local luauHeader = "\1\0\0\0" -- Header Luau typique
        if bytecode:sub(1, 4) ~= luauHeader and #bytecode > 100 then
            return true
        end
        
        return false
    end,
    
    -- Vérifier si obfusqué
    IsObfuscated = function(bytecode)
        -- Signes d'obfuscation
        local strings = ScriptDecryptor.BytecodeAnalyzer.ExtractStrings(bytecode)
        
        -- Beaucoup de chaînes courtes ou sans sens = obfuscation
        local shortStrings = 0
        for _, str in pairs(strings) do
            if #str < 5 then
                shortStrings = shortStrings + 1
            end
        end
        
        if shortStrings > #strings * 0.8 then
            return true
        end
        
        return false
    end,
    
    -- Extraire l'header
    ExtractHeader = function(bytecode)
        return bytecode:sub(1, 20)
    end,
    
    -- Compter les instructions (estimation)
    CountInstructions = function(bytecode)
        -- Estimation basée sur la longueur
        return math.floor(#bytecode / 4)
    end,
    
    -- Extraire les constantes (heuristic)
    ExtractConstants = function(bytecode)
        local constants = {}
        
        -- Chercher des patterns de nombres
        for number in bytecode:gmatch("[%d%.]+") do
            local num = tonumber(number)
            if num and num > -1000000 and num < 1000000 then
                table.insert(constants, {Type = "number", Value = num})
            end
        end
        
        return constants
    end,
    
    -- Extraire les strings
    ExtractStrings = function(bytecode)
        local strings = {}
        
        -- Chercher des chaînes de caractères lisibles
        for str in bytecode:gmatch("[\x20-\x7E]{4,}") do
            if #str > 3 and #str < 100 then
                table.insert(strings, str)
            end
        end
        
        return strings
    end,
    
    -- Trouver des patterns dans le bytecode
    FindPatterns = function(bytecode)
        local patterns = {
            RemoteCalls = 0,
            RequireCalls = 0,
            GetServiceCalls = 0,
            WaitForCalls = 0,
            InstanceCreation = 0
        }
        
        -- Chercher des patterns de texte
        local lowerBytecode = bytecode:lower()
        
        patterns.RemoteCalls = ScriptDecryptor.BytecodeAnalyzer.CountPattern(lowerBytecode, "fireserver") + 
                              ScriptDecryptor.BytecodeAnalyzer.CountPattern(lowerBytecode, "invokeserver")
        
        patterns.RequireCalls = ScriptDecryptor.BytecodeAnalyzer.CountPattern(lowerBytecode, "require")
        
        patterns.GetServiceCalls = ScriptDecryptor.BytecodeAnalyzer.CountPattern(lowerBytecode, "getservice")
        
        patterns.WaitForCalls = ScriptDecryptor.BytecodeAnalyzer.CountPattern(lowerBytecode, "waitfor")
        
        patterns.InstanceCreation = ScriptDecryptor.BytecodeAnalyzer.CountPattern(lowerBytecode, "instance.new")
        
        return patterns
    end,
    
    -- Compter un pattern
    CountPattern = function(text, pattern)
        local count = 0
        local startPos = 1
        while true do
            local found = text:find(pattern, startPos)
            if not found then break end
            count = count + 1
            startPos = found + 1
        end
        return count
    end
}

-- ============================================================================
-- TENTATIVE DE DÉCRYPTAGE
-- ============================================================================

ScriptDecryptor.Decrypter = {
    -- Tenter de décrypter un bytecode
    AttemptDecrypt = function(bytecode)
        if not ScriptDecryptor.BytecodeAnalyzer.IsEncrypted(bytecode) then
            return {Success = true, Decrypted = bytecode, Method = "Not Encrypted"}
        end
        
        local attempts = {
            ScriptDecryptor.Decrypter.TryXORDecrypt,
            ScriptDecryptor.Decrypter.TryBase64Decode,
            ScriptDecryptor.Decrypter.TryROT13,
            ScriptDecryptor.Decrypter.TryReverseBytes
        }
        
        for _, attempt in pairs(attempts) do
            local result = attempt(bytecode)
            if result.Success then
                return result
            end
        end
        
        return {Success = false, Reason = "All decryption attempts failed"}
    end,
    
    -- Tentative XOR (common encryption)
    TryXORDecrypt = function(bytecode)
        local keys = {0x42, 0x55, 0x47, 0x48, 0x49, 0x50, 0x51, 0x52}
        
        for _, key in pairs(keys) do
            local decrypted = ""
            for i = 1, #bytecode do
                decrypted = decrypted .. string.char(string.byte(bytecode, i) ~ key)
            end
            
            -- Vérifier si le résultat ressemble à du bytecode valide
            if ScriptDecryptor.BytecodeAnalyzer.IsValidBytecode(decrypted) then
                return {Success = true, Decrypted = decrypted, Method = "XOR", Key = key}
            end
        end
        
        return {Success = false}
    end,
    
    -- Tentative Base64
    TryBase64Decode = function(bytecode)
        local success, decoded = pcall(function()
            return game:GetService("HttpService"):JSONDecode(bytecode)
        end)
        
        if success then
            return {Success = true, Decrypted = decoded, Method = "Base64"}
        end
        
        return {Success = false}
    end,
    
    -- Tentative ROT13
    TryROT13 = function(bytecode)
        local decrypted = ""
        for i = 1, #bytecode do
            local char = string.byte(bytecode, i)
            if char >= 65 and char <= 90 then
                decrypted = decrypted .. string.char(((char - 65 + 13) % 26) + 65)
            elseif char >= 97 and char <= 122 then
                decrypted = decrypted .. string.char(((char - 97 + 13) % 26) + 97)
            else
                decrypted = decrypted .. string.char(char)
            end
        end
        
        if ScriptDecryptor.BytecodeAnalyzer.IsValidBytecode(decrypted) then
            return {Success = true, Decrypted = decrypted, Method = "ROT13"}
        end
        
        return {Success = false}
    end,
    
    -- Tentative reverse bytes
    TryReverseBytes = function(bytecode)
        local reversed = bytecode:reverse()
        
        if ScriptDecryptor.BytecodeAnalyzer.IsValidBytecode(reversed) then
            return {Success = true, Decrypted = reversed, Method = "Reverse"}
        end
        
        return {Success = false}
    end
}

-- ============================================================================
-- VALIDATION DE BYTECODE
-- ============================================================================

ScriptDecryptor.BytecodeAnalyzer.IsValidBytecode = function(bytecode)
    -- Vérifier si le bytecode ressemble à du bytecode Luau valide
    local header = bytecode:sub(1, 4)
    local luauHeader = "\1\0\0\0"
    
    if header == luauHeader then
        return true
    end
    
    -- Vérifier s'il y a des caractères imprimables (signe de texte)
    local printableCount = 0
    for i = 1, math.min(#bytecode, 100) do
        local char = string.byte(bytecode, i)
        if char >= 32 and char <= 126 then
            printableCount = printableCount + 1
        end
    end
    
    -- Si trop de caractères imprimables, ce n'est probablement pas du bytecode
    if printableCount > 50 then
        return false
    end
    
    return true
end

-- ============================================================================
-- DÉSOBFUSCATION
-- ============================================================================

ScriptDecryptor.Deobfuscator = {
    -- Tenter de désofuscater un script
    Deobfuscate = function(script)
        local analysis = ScriptDecryptor.BytecodeAnalyzer.AnalyzeBytecode(script)
        
        if not analysis.IsObfuscated then
            return {Success = true, Deobfuscated = script, Method = "Not Obfuscated"}
        end
        
        local attempts = {
            ScriptDecryptor.Deobfuscator.RenameVariables,
            ScriptDecryptor.Deobfuscator.RemoveDeadCode,
            ScriptDecryptor.Deobfuscator.SimplifyExpressions
        }
        
        local result = script
        for _, attempt in pairs(attempts) do
            result = attempt(result)
        end
        
        return {Success = true, Deobfuscated = result, Method = "Multiple"}
    end,
    
    -- Renommer les variables obfusquées
    RenameVariables = function(script)
        -- Placeholder pour le renommage
        -- Nécessiterait un vrai décompilateur Luau
        return script
    end,
    
    -- Supprimer le code mort
    RemoveDeadCode = function(script)
        -- Placeholder pour la suppression de code mort
        return script
    end,
    
    -- Simplifier les expressions
    SimplifyExpressions = function(script)
        -- Placeholder pour la simplification
        return script
    end
}

-- ============================================================================
-- DÉCOMPILATION (Tentative)
-- ============================================================================

ScriptDecryptor.Decompiler = {
    -- Tenter de décompiler le bytecode
    AttemptDecompile = function(script)
        local analysis = ScriptDecryptor.BytecodeAnalyzer.AnalyzeBytecode(script)
        
        if analysis.IsEncrypted then
            local decryptResult = ScriptDecryptor.Decrypter.AttemptDecrypt(script)
            if decryptResult.Success then
                script = decryptResult.Decrypted
            else
                return {Success = false, Reason = "Cannot decrypt bytecode"}
            end
        end
        
        -- Générer un pseudo-code basé sur l'analyse
        local pseudoCode = ScriptDecryptor.Decompiler.GeneratePseudoCode(analysis)
        
        return {
            Success = true,
            PseudoCode = pseudoCode,
            Analysis = analysis,
            Note = "Full decompilation requires Luau decompiler"
        }
    end,
    
    -- Générer du pseudo-code
    GeneratePseudoCode = function(analysis)
        local code = "-- Decompiled Pseudo-Code\n\n"
        
        code = code .. string.format("-- Bytecode Length: %d\n", analysis.Length)
        code = code .. string.format("-- Instructions: %d\n", analysis.Instructions)
        code = code .. string.format("-- Strings Found: %d\n", #analysis.Strings)
        code = code .. "\n"
        
        -- Ajouter les strings trouvées
        code = code .. "-- Strings found in bytecode:\n"
        for _, str in pairs(analysis.Strings) do
            code = code .. string.format("-- %s\n", str)
        end
        code = code .. "\n"
        
        -- Ajouter les patterns détectés
        code = code .. "-- Patterns detected:\n"
        code = code .. string.format("-- Remote Calls: %d\n", analysis.Patterns.RemoteCalls)
        code = code .. string.format("-- Require Calls: %d\n", analysis.Patterns.RequireCalls)
        code = code .. string.format("-- GetService Calls: %d\n", analysis.Patterns.GetServiceCalls)
        code = code .. "\n"
        
        -- Générer du code basé sur les patterns
        code = code .. "-- Inferred structure:\n"
        
        if analysis.Patterns.RequireCalls > 0 then
            code = code .. "local modules = {}\n"
            code = code .. "for i = 1, " .. analysis.Patterns.RequireCalls .. " do\n"
            code = code .. "    local module = require(...)\n"
            code = code .. "end\n\n"
        end
        
        if analysis.Patterns.GetServiceCalls > 0 then
            code = code .. "local services = {}\n"
            code = code .. "for i = 1, " .. analysis.Patterns.GetServiceCalls .. " do\n"
            code = code .. "    local service = game:GetService(...)\n"
            code = code .. "end\n\n"
        end
        
        return code
    end
}

-- ============================================================================
-- SCAN COMPLET DES SCRIPTS
-- ============================================================================

function ScriptDecryptor.ScanAllScripts()
    print("[SCRIPT_DECRYPTOR] Scan de tous les scripts...")
    
    local results = {
        Timestamp = tick(),
        Scripts = {},
        Summary = {
            TotalScripts = 0,
            EncryptedScripts = 0,
            ObfuscatedScripts = 0,
            DecryptedScripts = 0,
            DecompiledScripts = 0
        }
    end
    
    for _, script in pairs(game:GetDescendants()) do
        if script:IsA("Script") or script:IsA("LocalScript") or script:IsA("ModuleScript") then
            results.Summary.TotalScripts = results.Summary.TotalScripts + 1
            
            local scriptResult = {
                Name = script.Name,
                ClassName = script.ClassName,
                Path = script:GetFullName(),
                Disabled = script.Disabled,
                BytecodeAnalysis = nil,
                DecryptResult = nil,
                DecompileResult = nil
            }
            
            -- Analyser le bytecode
            local bytecodeAnalysis = ScriptDecryptor.BytecodeAnalyzer.AnalyzeBytecode(script)
            scriptResult.BytecodeAnalysis = bytecodeAnalysis
            
            if bytecodeAnalysis.IsEncrypted then
                results.Summary.EncryptedScripts = results.Summary.EncryptedScripts + 1
                
                -- Tenter de décrypter
                local decryptResult = ScriptDecryptor.Decrypter.AttemptDecrypt(script)
                scriptResult.DecryptResult = decryptResult
                
                if decryptResult.Success then
                    results.Summary.DecryptedScripts = results.Summary.DecryptedScripts + 1
                end
            end
            
            if bytecodeAnalysis.IsObfuscated then
                results.Summary.ObfuscatedScripts = results.Summary.ObfuscatedScripts + 1
            end
            
            -- Tenter de décompiler
            local decompileResult = ScriptDecryptor.Decompiler.AttemptDecompile(script)
            scriptResult.DecompileResult = decompileResult
            
            if decompileResult.Success then
                results.Summary.DecompiledScripts = results.Summary.DecompiledScripts + 1
            end
            
            table.insert(results.Scripts, scriptResult)
        end
    end
    
    print(string.format("[SCRIPT_DECRYPTOR] Scan terminé - %d scripts analysés", results.Summary.TotalScripts))
    print(string.format("[SCRIPT_DECRYPTOR] Scripts encryptés: %d", results.Summary.EncryptedScripts))
    print(string.format("[SCRIPT_DECRYPTOR] Scripts obfusqués: %d", results.Summary.ObfuscatedScripts))
    print(string.format("[SCRIPT_DECRYPTOR] Scripts décryptés: %d", results.Summary.DecryptedScripts))
    print(string.format("[SCRIPT_DECRYPTOR] Scripts décompilés: %d", results.Summary.DecompiledScripts))
    
    return results
end

return ScriptDecryptor
