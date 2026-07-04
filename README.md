# Tower Battles Extractor - Full Recovery System

<div align="center">

![Version](https://img.shields.io/badge/version-4.0-blue)
![License](https://img.shields.io/badge/license-MIT-green)
![Roblox](https://img.shields.io/badge/Roblox-Lua-red)

**Complete and Advanced Recovery System for Tower Battles**

[Documentation](#documentation) • [Installation](#installation) • [Usage](#usage) • [Modules](#modules)

</div>

---

## 📋 Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Modules](#modules)
- [Installation](#installation)
- [Usage](#usage)
- [Configuration](#configuration)
- [Exported Data](#exported-data)
- [Security and Legality](#security-and-legality)
- [FAQ](#faq)
- [Credits](#credits)
- [License](#license)

---

## Overview

Tower Battles Extractor is a complete reverse-engineering and data recovery system for the Tower Battles game on Roblox. This project allows you to recover **absolutely everything** from the game: scripts, map, assets, hidden parts, and even detect security vulnerabilities.

### 🎯 Goal

Reproduce Tower Battles at 100% by recovering all necessary data, including what is normally inaccessible or hidden. The system uses advanced memory analysis, network capture, and automatic reconstruction techniques.

### ✨ Main Features

#### Complete Recovery
- ✅ **Complete scripts** with decryption, analysis, reconstruction and repair
- ✅ **Complete map** with Workspace, Terrain, Lighting, SpawnPoints, Paths
- ✅ **Complete assets** (images, sounds, meshes, animations) including hidden ones
- ✅ **Hidden parts** via deep Garbage Collector scan
- ✅ **Hidden properties** via gethiddenproperty
- ✅ **System attributes and tags**

#### Security and Exploits
- 🔍 **VulnerabilityScanner** - Detection of security vulnerabilities
- 🚪 **BackdoorScanner** - Detection of hidden backdoors
- 💥 **ExploitScanner** - Scan of potential exploits
- 🔑 **PrivilegeEscalation** - Analysis of available privileges
- 📋 **DirectCopy** - Direct copy via exploits (optional)

#### External Integration
- 🤖 **ExternalAPIIntegration** - Automatic script understanding via external API (optional)

#### Notifications
- 📢 **DiscordNotifier** - Real-time notifications on Discord (optional)

#### Multi-Agent System
- 🤖 **AgentSystem** - Multi-agent architecture for automatic reverse-engineering
- 🔍 **AgentExplorer** - Advanced Dex-style exploration
- 🛠️ **AgentImplementer** - Implementation and reconstruction
- 🧪 **AgentTester** - Automatic testing

---

## Architecture

### Global Schema

```
┌─────────────────────────────────────────────────────────────────────────┐
│                     TOWER BATTLES EXTRACTOR                              │
│                              v4.0                                        │
└─────────────────────────────────────────────────────────────────────────┘
                                    │
        ┌───────────────────────────┼───────────────────────────┐
        │                           │                           │
        ▼                           ▼                           ▼
┌───────────────┐         ┌───────────────┐         ┌───────────────┐
│  REAL-TIME    │         │  FULL RECOVERY│         │  AGENT SYSTEM │
│  EXTRACTOR    │         │  SYSTEM       │         │               │
│  (main.lua)   │         │  (14 phases)  │         │  (5 agents)   │
└───────────────┘         └───────────────┘         └───────────────┘
        │                           │                           │
        ▼                           ▼                           ▼
┌───────────────┐         ┌───────────────┐         ┌───────────────┐
│ Network Spy   │         │ Deep Scanner  │         │ Orchestrator  │
│ RAM Scanner   │         │ Script Decrypt│         │ Explorer      │
│ Asset Preload │         │ Script Analyze│         │ Implementer   │
│ UI Capture    │         │ Script Recon  │         │ Tester        │
└───────────────┘         └───────────────┘         └───────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                        SECURITY MODULES                                 │
├───────────────┬───────────────┬───────────────┬───────────────────────┤
│ Vulnerability │   Backdoor    │    Exploit    │  Privilege           │
│   Scanner     │   Scanner     │   Scanner     │  Escalation          │
└───────────────┴───────────────┴───────────────┴───────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                        OUTPUT & NOTIFICATIONS                            │
├───────────────┬───────────────┬───────────────┬───────────────────────┤
│ JSON Export   │  Discord Notif│  Direct Copy  │  Final Report        │
└───────────────┴───────────────┴───────────────┴───────────────────────┘
```

### Data Flow

```
Tower Battles Game
        │
        ├─→ Network Packets ─→ Network Spy ─→ NetworkLogs
        │
        ├─→ RAM Memory ──────→ RAM Scanner ─→ RAMLogs
        │
        ├─→ Scripts ─────────→ Script Analyzer ─→ ScriptData
        │
        ├─→ Instances ───────→ Instance Capture ─→ InstanceProperties
        │
        ├─→ Assets ──────────→ Asset Recovery ─→ AssetRegistry
        │
        └─→ Events ──────────→ Event Logger ─→ GameEvents
```

---

## Modules

### 1. Real-Time Extractor (main.lua)

**Features:**
- **Network Packet Interceptor**: Bidirectional capture of client-server communications
- **RAM & GC Scanner**: Intelligent memory scan with gameplay filtering
- **Dynamic Asset Preloader**: Automatic asset preloading
- **Instance Properties Capture**: Detailed property capture
- **Script Data Capture**: Bytecode, upvalues and constants
- **Game Events Logger**: Real-time game events
- **Player Stats Tracker**: Player statistics

**Usage:**
```lua
loadstring(readfile("TowerBattlesExtractor/main.lua"))()
```

### 2. Full Recovery System (FullRecovery.lua)

**Features:**
- Integration of 14 recovery phases
- Automatic sequential execution
- Structured export of all results
- Complete final report

**Phases:**
1. Deep Scan - Deep GC and registry scan
2. Script Decryptor - Script decryption
3. Script Analyzer - Static analysis
4. Script Reconstructor - Logic reconstruction
5. Script Repairer - Automatic repair
6. Map Extractor - Map extraction
7. Asset Recovery - Asset recovery
8. External API Analysis - External API analysis (optional)
9. Vulnerability Scan - Vulnerability scan
10. Backdoor Scan - Backdoor detection
11. Exploit Scan - Exploit scan
12. Privilege Escalation - Privilege analysis
13. Direct Copy - Direct copy (optional)
14. Final Report - Final report

**Usage:**
```lua
loadstring(readfile("TowerBattlesExtractor/FullRecovery.lua"))()
RunFullRecovery()
```

### 3. Deep Scanner (DeepScanner.lua)

**Features:**
- Garbage Collector scan (getgc)
- Lua registry scan (getreg)
- Hidden script detection
- Hidden asset detection
- Hidden property detection (gethiddenproperty)
- Hidden attribute detection

### 4. Script Decryptor (ScriptDecryptor.lua)

**Features:**
- Bytecode analysis
- Encryption detection
- Decryption attempts (XOR, Base64, ROT13, Reverse)
- Obfuscation detection

### 5. Script Analyzer (ScriptAnalyzer.lua)

**Features:**
- Structural analysis (functions, variables, dependencies)
- Semantic analysis (script purpose, features)
- Control flow analysis

### 6. Script Reconstructor (ScriptReconstructor.lua)

**Features:**
- Code generation based on script purpose
- Logic block extraction
- Function, variable and event reconstruction
- Map serialization and reconstruction

### 7. Script Repairer (ScriptRepairer.lua)

**Features:**
- Error detection (syntax, dependencies, variables)
- Automatic repair
- Validation and optimization

### 8. Map Extractor (MapExtractor.lua)

**Features:**
- Complete Workspace extraction
- Terrain extraction
- Lighting extraction
- SpawnPoint extraction
- Path extraction
- Camera extraction

### 9. Asset Recovery (AssetRecovery.lua)

**Features:**
- Visible asset recovery
- Hidden asset recovery (via GC)
- Recovery via ContentProvider
- Recovery via ModuleScripts
- Asset deduplication

### 10. External API Integration (ExternalAPIIntegration.lua)

**Features:**
- Script analysis with external API
- Script reconstruction with external API
- Batch analysis
- Flexible configuration

### 11. Vulnerability Scanner (VulnerabilityScanner.lua)

**Features:**
- Scan of unsecured RemoteEvents/Functions
- Vulnerable script analysis
- Excessive permission detection
- Injection point identification

### 12. Backdoor Scanner (BackdoorScanner.lua)

**Features:**
- Classic backdoor detection
- Backdoor analysis in scripts
- Hidden backdoor scan (GC)
- Backdoor analysis via attributes

### 13. Exploit Scanner (ExploitScanner.lua)

**Features:**
- Remote exploit scan
- Client exploit scan
- Exploit chain analysis

### 14. Privilege Escalation (PrivilegeEscalation.lua)

**Features:**
- Current privilege detection
- Escalation method analysis
- Escalation simulation (test only)

### 15. Direct Copy (DirectCopy.lua)

**Features:**
- Copy via saveinstance (if available)
- Copy via detected backdoor
- Copy via Remote exploit
- Copy via privilege escalation
- Copy via script execution
- Copy via HTTP (if endpoint available)

### 16. Discord Notifier (DiscordNotifier.lua)

**Features:**
- Start notifications
- Phase notifications
- Error notifications
- Success notifications
- Vulnerability notifications
- Privilege notifications

### 17. Agent System (AgentSystem.lua)

**Features:**
- Orchestrator - Agent coordination
- Explorer - Exploration and analysis
- Implementer - Implementation and reconstruction
- Tester - Automatic testing
- Wiki - Automatic documentation

---

## Installation

### Prerequisites

**Required Exploit:**
- `writefile` - Data saving
- `readfile` - Module loading
- `makefolder` - Folder creation
- `isfile` - File verification

**Recommended Advanced Functions:**
- `getgc` - Garbage Collector scan
- `getreg` - Lua registry scan
- `getscriptbytecode` - Bytecode capture
- `getupvalues` - Upvalue capture
- `getconstants` - Constant capture
- `gethiddenproperty` - Hidden properties
- `getproperties` - Complete properties
- `hookmetamethod` - Metamethod hooks (stealth mode)

### Recommended Exploits

- **Synapse X**: Full support for all features (recommended)
- **Script-Ware**: Full support
- **Krnl**: Partial support (legacy mode)
- **Fluxus**: Partial support

### Installation Steps

1. **Download the complete folder** `TowerBattlesExtractor/`
2. **Place the folder** in your exploit workspace
3. **Join the game** Tower Battles
4. **Execute the script** (see Usage)

---

## Usage

### Mode 1: Auto Run (Recommended)

The `AutoRun.lua` script launches everything automatically:

```lua
loadstring(readfile("TowerBattlesExtractor/AutoRun.lua"))()
RunTowerBattlesExtractor()
```

**Customization without file modification:**

```lua
loadstring(readfile("TowerBattlesExtractor/AutoRun.lua"))()

-- Set your parameters
_G.TowerBattlesExtractorConfig.DiscordWebhookURL = "https://discord.com/api/webhooks/YOUR_WEBHOOK_URL"
_G.TowerBattlesExtractorConfig.UseDirectCopy = true

-- Launch
RunTowerBattlesExtractor()
```

**Or pass configuration directly:**

```lua
loadstring(readfile("TowerBattlesExtractor/AutoRun.lua"))()

RunTowerBattlesExtractor({
    DiscordWebhookURL = "https://discord.com/api/webhooks/YOUR_WEBHOOK_URL",
    UseDirectCopy = true,
    UseExternalAPI = true,
    ExternalAPIConfig = {
        APIKey = "your-api-key",
        Model = "gpt-4"
    }
})
```

### Mode 2: Manual Full Recovery

```lua
loadstring(readfile("TowerBattlesExtractor/FullRecovery.lua"))()
RunFullRecovery()
```

### Mode 3: Real-Time Extractor

```lua
loadstring(readfile("TowerBattlesExtractor/main.lua"))()
```

### Mode 4: Agent System

```lua
loadstring(readfile("TowerBattlesExtractor/AgentSystem_Main.lua"))()
```

### Mode 5: Custom Configuration

```lua
loadstring(readfile("TowerBattlesExtractor/FullRecovery.lua"))()

ConfigureFullRecovery({
    -- Recovery modules
    UseDeepScan = true,
    UseScriptDecryptor = true,
    UseScriptAnalyzer = true,
    UseScriptReconstructor = true,
    UseScriptRepairer = true,
    UseMapExtractor = true,
    UseAssetRecovery = true,
    
    -- Security modules
    UseVulnerabilityScanner = true,
    UseBackdoorScanner = true,
    UseExploitScanner = true,
    UsePrivilegeEscalation = true,
    UseDirectCopy = false, -- DANGEROUS
    
    -- Discord Webhook
    UseDiscordNotifier = true,
    DiscordWebhookURL = "https://discord.com/api/webhooks/YOUR_WEBHOOK_URL"
})

RunFullRecovery()
```

---

## Configuration

### Default Configuration

```lua
_G.TowerBattlesExtractorConfig = {
    -- Recovery modules
    UseDeepScan = true,
    UseScriptDecryptor = true,
    UseScriptAnalyzer = true,
    UseScriptReconstructor = true,
    UseScriptRepairer = true,
    UseMapExtractor = true,
    UseAssetRecovery = true,
    UseExternalAPI = false,
    
    -- Security modules
    UseVulnerabilityScanner = true,
    UseBackdoorScanner = true,
    UseExploitScanner = true,
    UsePrivilegeEscalation = true,
    UseDirectCopy = false, -- DANGEROUS
    
    -- Discord Webhook
    UseDiscordNotifier = false,
    DiscordWebhookURL = "",
    
    -- Export
    ExportFormat = "JSON",
    OutputPath = "TowerBattles_FullRecovery"
}
```

### External API Configuration

```lua
ExternalAPIConfig = {
    APIKey = "your-api-key",
    Model = "gpt-4",
    MaxTokens = 4000,
    Temperature = 0.7
}
```

---

## Exported Data

Results are exported in the `TowerBattles_FullRecovery/` folder:

```
TowerBattles_FullRecovery/
├── DeepScan_Results.json
├── ScriptDecrypt_Results.json
├── ScriptAnalysis_Results.json
├── ScriptReconstruction_Results.json
├── ScriptRepair_Results.json
├── MapExtraction_Results.json
├── AssetRecovery_Results.json
├── ExternalAPIAnalysis_Results.json
├── VulnerabilityScan_Results.json
├── BackdoorScan_Results.json
├── ExploitScan_Results.json
├── PrivilegeEscalation_Results.json
├── DirectCopy_Results.json
└── Final_Report.json
```

### Data Structure

#### NetworkLogs
```json
{
  "Type": "RemoteEvent",
  "Name": "ReplicatedStorage.Remotes.PlaceTower",
  "Direction": "Client->Server",
  "Timestamp": 1234567890.123,
  "Method": "FireServer",
  "Arguments": [...]
}
```

#### ScriptData
```json
{
  "Name": "TowerConfig",
  "ClassName": "ModuleScript",
  "Path": "ReplicatedStorage.Modules.TowerConfig",
  "Disabled": false,
  "HasBytecode": true,
  "BytecodeLength": 1234,
  "Upvalues": {...},
  "Constants": [...]
}
```

#### InstanceProperties
```json
{
  "ClassName": "Model",
  "Name": "Tower",
  "Properties": {
    "Anchored": {"Type": "boolean", "Value": true},
    "Position": {"Type": "Vector3", "Value": {"X": 10, "Y": 5, "Z": 20}}
  }
}
```

---

## Security and Legality

### ⚠️ Important Warning

This project is for research and analysis purposes only. Using these tools to exploit games without authorization is illegal and violates Roblox Terms of Service.

### Authorized Use

- ✅ Analysis of your own games
- ✅ Analysis with explicit permission from the owner
- ✅ Research and learning
- ✅ Educational reconstruction

### Prohibited Use

- ❌ Unauthorized game exploitation
- ❌ Cheating or unfair advantage
- ❌ Unauthorized monetization
- ❌ Distribution of modified versions

### Legal Notices

- This project is developed for educational purposes
- The goal is 100% non-profit
- Extracted data must not be used for malicious purposes
- The user is solely responsible for the use of these tools

### Risks

**DirectCopy:**
- ⚠️ **Very dangerous** - Can trigger anti-cheat
- ⚠️ Can lead to bans
- ⚠️ Disabled by default for this reason

**Security Modules:**
- ⚠️ Exploit scans can be detected
- ⚠️ Privilege escalation can be detected
- ⚠️ Use with caution

---

## FAQ

### Tool doesn't start

**Solution:**
- Check that your exploit supports `writefile`
- Ensure you have the necessary permissions
- Verify all files are in the `TowerBattlesExtractor/` folder

### No data extracted

**Solution:**
- Check that you are in the Tower Battles game
- Ensure you interact with the game (place towers, etc.)
- Check the console for error messages

### Export error

**Solution:**
- Check available disk space
- Ensure `writefile` works
- Try reducing the amount of captured data

### Stealth mode not activated

**Solution:**
- Check that your exploit supports `hookmetamethod`
- The tool will automatically switch to legacy mode if unavailable

### Discord notifications not working

**Solution:**
- Verify the webhook URL is correct
- Ensure `UseDiscordNotifier = true`
- Check that the webhook is active on Discord

### How to use External API Integration?

**Solution:**
- Get an API key
- Configure `ExternalAPIConfig` with your API key
- Enable `UseExternalAPI = true`

---

## Credits

### Source Projects

- **Dex Explorer** - https://github.com/Benotec/Dex
- **UniversalSynSaveInstance** - https://github.com/luau/UniversalSynSaveInstance
- **UniversalMethodFinder** - https://github.com/luau/SomeHub

### Development

- Developed for Tower Battles Reborn
- Multi-module architecture
- Multi-agent system
- External API integration

### Acknowledgments

- To the Roblox community for tools and resources
- To the creators of source projects
- To contributors and testers

---

## License

MIT License

This project is in accordance with the licenses of source projects.

---

## Additional Documentation

For more detailed information about specific modules, refer to the inline code documentation in each module file.

---

## Support

For any questions or issues:

- Consult documentation files
- Check the console for error messages
- Adjust configuration according to your needs
- Open an issue on GitHub (if available)

---

<div align="center">

**⚠️ Warning:** This project is for educational purposes only. Unauthorized use is prohibited.

**📧 Contact:** For legal questions or authorization, contact the project owner.

</div>
