# Tower Battles Extractor

Complete recovery system for Tower Battles on Roblox.

## Execution

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/3rgooone/Tower-Battles-Extractor/refs/heads/main/main.lua"))()
```

## Configuration

Edit the `Config` table in `main.lua`:

```lua
local Config = {
    Mode = "FullRecovery",
    UseDeepScan = true,
    UseScriptAnalyzer = true,
    UseMapExtractor = true,
    UseAssetRecovery = true,
    UseExternalAPI = false,
    ExternalAPIConfig = {
        APIKey = "",
        Model = "llama-3.1-70b-versatile"
    },
    ExportFormat = "JSON",
    OutputPath = "TowerBattles_FullRecovery"
}
```

## Modes

- **FullRecovery**: Complete extraction with all modules
- **DeepScan**: Memory scanning only
- **ScriptAnalysis**: Script analysis only
- **AgentSystem**: Multi-agent reconstruction

## Modules

### Recovery
- DeepScanner
- ScriptDecryptor
- ScriptAnalyzer
- ScriptReconstructor
- ScriptRepairer
- MapExtractor
- AssetRecovery

### Security
- VulnerabilityScanner
- BackdoorScanner
- ExploitScanner
- PrivilegeEscalation
- DirectCopy

### Integration
- ExternalAPI (Groq)
- DiscordNotifier

## Output

Results saved to `TowerBattles_FullRecovery/` folder in JSON format.

## License

MIT
