-- ============================================================================
-- SCRIPT REPAIRER - Réparation automatique des scripts
-- Détecte et répare les erreurs dans les scripts reconstruits
-- ============================================================================

local ScriptRepairer = {}

-- ============================================================================
-- DÉTECTION D'ERREURS
-- ============================================================================

ScriptRepairer.ErrorDetector = {
    -- Détecter les erreurs dans un script
    DetectErrors = function(scriptCode)
        local errors = {
            SyntaxErrors = {},
            LogicErrors = {},
            MissingDependencies = {},
            UndefinedVariables = {},
            TypeErrors = {}
        }
        
        -- Vérifier la syntaxe (basique)
        local syntaxErrors = ScriptRepairer.ErrorDetector.CheckSyntax(scriptCode)
        errors.SyntaxErrors = syntaxErrors
        
        -- Vérifier les dépendances manquantes
        local missingDeps = ScriptRepairer.ErrorDetector.CheckDependencies(scriptCode)
        errors.MissingDependencies = missingDeps
        
        -- Vérifier les variables non définies
        local undefinedVars = ScriptRepairer.ErrorDetector.CheckUndefinedVariables(scriptCode)
        errors.UndefinedVariables = undefinedVars
        
        -- Vérifier les erreurs de type
        local typeErrors = ScriptRepairer.ErrorDetector.CheckTypeErrors(scriptCode)
        errors.TypeErrors = typeErrors
        
        return errors
    end,
    
    -- Vérifier la syntaxe
    CheckSyntax = function(code)
        local errors = {}
        
        -- Vérifier les parenthèses non fermées
        local openParen = 0
        local closeParen = 0
        for char in code:gmatch("[%(%)]") do
            if char == "(" then openParen = openParen + 1 end
            if char == ")" then closeParen = closeParen + 1 end
        end
        
        if openParen ~= closeParen then
            table.insert(errors, {
                Type = "UnbalancedParentheses",
                Message = string.format("Unbalanced parentheses: %d open, %d close", openParen, closeParen)
            })
        end
        
        -- Vérifier les crochets non fermés
        local openBracket = 0
        local closeBracket = 0
        for char in code:gmatch("[%[%]]") do
            if char == "[" then openBracket = openBracket + 1 end
            if char == "]" then closeBracket = closeBracket + 1 end
        end
        
        if openBracket ~= closeBracket then
            table.insert(errors, {
                Type = "UnbalancedBrackets",
                Message = string.format("Unbalanced brackets: %d open, %d close", openBracket, closeBracket)
            })
        end
        
        -- Vérifier les end manquants
        local ifCount = 0
        local endCount = 0
        for word in code:gmatch("if") do ifCount = ifCount + 1 end
        for word in code:gmatch("end") do endCount = endCount + 1 end
        
        if ifCount > endCount then
            table.insert(errors, {
                Type = "MissingEnd",
                Message = string.format("Missing end statements: %d if, %d end", ifCount, endCount)
            })
        end
        
        -- Vérifier les then manquants
        local thenCount = 0
        for word in code:gmatch("then") do thenCount = thenCount + 1 end
        
        if ifCount > thenCount then
            table.insert(errors, {
                Type = "MissingThen",
                Message = string.format("Missing then statements: %d if, %d then", ifCount, thenCount)
            })
        end
        
        return errors
    end,
    
    -- Vérifier les dépendances
    CheckDependencies = function(code)
        local missing = {}
        
        -- Trouver tous les requires
        local requires = {}
        for match in code:gmatch('require%("([^"]+)"%)') do
            table.insert(requires, match)
        end
        
        -- Trouver tous les GetService
        local services = {}
        for match in code:gmatch('GetService%("([^"]+)"%)') do
            table.insert(services, match)
        end
        
        -- Vérifier si les services existent
        for _, service in pairs(services) do
            local success = pcall(function()
                return game:GetService(service)
            end)
            if not success then
                table.insert(missing, {
                    Type = "MissingService",
                    Name = service
                })
            end
        end
        
        return missing
    end,
    
    -- Vérifier les variables non définies
    CheckUndefinedVariables = function(code)
        local undefined = {}
        
        -- Extraire toutes les variables utilisées
        local usedVars = {}
        for match in code:gmatch("([%a_][%w_]*)") do
            if match ~= "local" and match ~= "function" and match ~= "end" and 
               match ~= "if" and match ~= "then" and match ~= "else" and match ~= "elseif" and
               match ~= "for" and match ~= "while" and match ~= "repeat" and match ~= "until" and
               match ~= "do" and match ~= "return" and match ~= "break" and match ~= "and" and
               match ~= "or" and match ~= "not" and match ~= "true" and match ~= "false" and
               match ~= "nil" and match ~= "game" and match ~= "workspace" and match ~= "print" then
                usedVars[match] = true
            end
        end
        
        -- Extraire toutes les variables définies
        local definedVars = {}
        for match in code:gmatch("local ([%a_][%w_]*)") do
            definedVars[match] = true
        end
        
        -- Trouver les variables utilisées mais non définies
        for var, _ in pairs(usedVars) do
            if not definedVars[var] then
                table.insert(undefined, {
                    Name = var,
                    Type = "UndefinedVariable"
                })
            end
        end
        
        return undefined
    end,
    
    -- Vérifier les erreurs de type
    CheckTypeErrors = function(code)
        local errors = {}
        
        -- Chercher des patterns d'erreurs de type courantes
        if code:find("%.Position") and code:find("%.Value") then
            -- Peut être une erreur si on essaie d'accéder à Position sur un Value
            table.insert(errors, {
                Type = "PotentialTypeError",
                Message = "Potential type error: accessing Position on Value object"
            })
        end
        
        return errors
    end
}

-- ============================================================================
-- RÉPARATION D'ERREURS
-- ============================================================================

ScriptRepairer.ErrorFixer = {
    -- Réparer les erreurs détectées
    FixErrors = function(scriptCode, errors)
        local fixedCode = scriptCode
        
        -- Réparer les erreurs de syntaxe
        for _, error in pairs(errors.SyntaxErrors) do
            fixedCode = ScriptRepairer.ErrorFixer.FixSyntaxError(fixedCode, error)
        end
        
        -- Réparer les dépendances manquantes
        for _, error in pairs(errors.MissingDependencies) do
            fixedCode = ScriptRepairer.ErrorFixer.FixMissingDependency(fixedCode, error)
        end
        
        -- Réparer les variables non définies
        for _, error in pairs(errors.UndefinedVariables) do
            fixedCode = ScriptRepairer.ErrorFixer.FixUndefinedVariable(fixedCode, error)
        end
        
        return fixedCode
    end,
    
    -- Réparer une erreur de syntaxe
    FixSyntaxError = function(code, error)
        if error.Type == "MissingEnd" then
            -- Ajouter les end manquants
            local missing = tonumber(error.Message:match("(%d+)")) or 1
            for i = 1, missing do
                code = code .. "\nend"
            end
        elseif error.Type == "MissingThen" then
            -- Ajouter les then manquants
            local missing = tonumber(error.Message:match("(%d+)")) or 1
            code = code:gsub("if%s*([^\n]+)", "if %1 then")
        elseif error.Type == "UnbalancedParentheses" then
            -- Ajouter les parenthèses manquantes
            local open, close = error.Message:match("(%d+).-(%d+)")
            local diff = tonumber(open) - tonumber(close)
            if diff > 0 then
                for i = 1, diff do
                    code = code .. ")"
                end
            elseif diff < 0 then
                for i = 1, -diff do
                    code = "(" .. code
                end
            end
        end
        
        return code
    end,
    
    -- Réparer une dépendance manquante
    FixMissingDependency = function(code, error)
        if error.Type == "MissingService" then
            -- Ajouter un fallback pour le service manquant
            local fallback = string.format([[
-- Service %s not found, using fallback
local %s = {
    -- Fallback implementation
}
]], error.Name, error.Name)
            
            code = fallback .. code
        end
        
        return code
    end,
    
    -- Réparer une variable non définie
    FixUndefinedVariable = function(code, error)
        -- Ajouter une déclaration locale pour la variable
        local declaration = string.format("local %s = nil -- Auto-fixed undefined variable\n", error.Name)
        
        -- Insérer au début du code
        code = declaration .. code
        
        return code
    end
}

-- ============================================================================
-- VALIDATION DE SCRIPT
-- ============================================================================

ScriptRepairer.ScriptValidator = {
    -- Valider un script
    ValidateScript = function(scriptCode)
        local validation = {
            IsValid = true,
            Errors = {},
            Warnings = {},
            Suggestions = []
        }
        
        -- Tenter de charger le script
        local success, result = pcall(function()
            return loadstring(scriptCode)
        end)
        
        if not success then
            validation.IsValid = false
            table.insert(validation.Errors, {
                Type = "LoadError",
                Message = result
            })
        end
        
        -- Vérifier la structure
        local structureErrors = ScriptRepairer.ErrorDetector.CheckSyntax(scriptCode)
        for _, error in pairs(structureErrors) do
            table.insert(validation.Warnings, error)
        end
        
        -- Suggestions d'amélioration
        if not code:find("--") then
            table.insert(validation.Suggestions, "Add comments for better documentation")
        end
        
        if code:find("print") then
            table.insert(validation.Suggestions, "Consider using a proper logging system instead of print")
        end
        
        return validation
    end
}

-- ============================================================================
-- OPTIMISATION DE SCRIPT
-- ============================================================================

ScriptRepairer.ScriptOptimizer = {
    -- Optimiser un script
    OptimizeScript = function(scriptCode)
        local optimized = scriptCode
        
        -- Supprimer les commentaires (optionnel)
        -- optimized = optimized:gsub("--[^\n]*\n", "\n")
        
        -- Supprimer les lignes vides multiples
        optimized = optimized:gsub("\n\n+", "\n\n")
        
        -- Optimiser les appels de service
        optimized = optimized:gsub("game:GetService%(([^)]+)%)", "game:GetService(%1)")
        
        return optimized
    end
}

-- ============================================================================
-- RÉPARATION COMPLÈTE
-- ============================================================================

function ScriptRepairer.RepairScript(scriptCode)
    print("[SCRIPT_REPAIRER] Réparation du script...")
    
    -- Détecter les erreurs
    local errors = ScriptRepairer.ErrorDetector.DetectErrors(scriptCode)
    
    print(string.format("[SCRIPT_REPAIRER] Erreurs de syntaxe: %d", #errors.SyntaxErrors))
    print(string.format("[SCRIPT_REPAIRER] Dépendances manquantes: %d", #errors.MissingDependencies))
    print(string.format("[SCRIPT_REPAIRER] Variables non définies: %d", #errors.UndefinedVariables))
    
    -- Réparer les erreurs
    local fixedCode = ScriptRepairer.ErrorFixer.FixErrors(scriptCode, errors)
    
    -- Valider le script réparé
    local validation = ScriptRepairer.ScriptValidator.ValidateScript(fixedCode)
    
    print(string.format("[SCRIPT_REPAIRER] Validation: %s", validation.IsValid and "OK" or "FAILED"))
    
    if not validation.IsValid then
        print("[SCRIPT_REPAIRER] Erreurs de validation:")
        for _, error in pairs(validation.Errors) do
            print(string.format("  - %s: %s", error.Type, error.Message))
        end
    end
    
    -- Optimiser le script
    local optimizedCode = ScriptRepairer.ScriptOptimizer.OptimizeScript(fixedCode)
    
    return {
        OriginalCode = scriptCode,
        FixedCode = fixedCode,
        OptimizedCode = optimizedCode,
        Errors = errors,
        Validation = validation
    }
end

function ScriptRepairer.RepairAllScripts(scriptReconstruction)
    print("[SCRIPT_REPAIRER] Réparation de tous les scripts...")
    
    local results = {
        Timestamp = tick(),
        Scripts = {},
        Summary = {
            TotalScripts = 0,
            RepairedScripts = 0,
            FailedRepairs = 0,
            OptimizedScripts = 0
        }
    }
    
    for _, scriptData in pairs(scriptReconstruction.Scripts) do
        results.Summary.TotalScripts = results.Summary.TotalScripts + 1
        
        if scriptData.ReconstructedCode then
            local repairResult = ScriptRepairer.RepairScript(scriptData.ReconstructedCode)
            
            repairResult.OriginalScript = scriptData.OriginalScript
            repairResult.Purpose = scriptData.Purpose
            
            table.insert(results.Scripts, repairResult)
            
            if repairResult.Validation.IsValid then
                results.Summary.RepairedScripts = results.Summary.RepairedScripts + 1
                results.Summary.OptimizedScripts = results.Summary.OptimizedScripts + 1
            else
                results.Summary.FailedRepairs = results.Summary.FailedRepairs + 1
            end
        end
    end
    
    print(string.format("[SCRIPT_REPAIRER] Réparation terminée - %d scripts", results.Summary.TotalScripts))
    print(string.format("[SCRIPT_REPAIRER] Réparés: %d", results.Summary.RepairedScripts))
    print(string.format("[SCRIPT_REPAIRER] Échoués: %d", results.Summary.FailedRepairs))
    
    return results
end

return ScriptRepairer
