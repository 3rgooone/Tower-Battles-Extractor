# Tower Battles Extractor - Full Recovery System

<div align="center">

![Version](https://img.shields.io/badge/version-4.0-blue)
![License](https://img.shields.io/badge/license-MIT-green)
![Roblox](https://img.shields.io/badge/Roblox-Lua-red)

**Complete and Advanced Recovery System for Tower Battles**

[Installation](#installation) • [Usage](#usage) • [Configuration](#configuration)

</div>

---

## 📋 Table of Contents

- [Overview](#overview)
- [Installation](#installation)
- [Usage](#usage)
- [Complete Configuration Guide](#complete-configuration-guide)
- [Available Modes](#available-modes)
- [Module Configuration](#module-configuration)
- [External API Setup](#external-api-setup)
- [Discord Notifications](#discord-notifications)
- [Output](#output)
- [Security and Legality](#security-and-legality)
- [FAQ](#faq)
- [License](#license)

---

## Overview

Tower Battles Extractor is a complete reverse-engineering and data recovery system for the Tower Battles game on Roblox. This project allows you to recover **absolutely everything** from the game: scripts, map, assets, hidden parts, and even detect security vulnerabilities.

### 🎯 Goal

Reproduce Tower Battles at 100% by recovering all necessary data, including what is normally inaccessible or hidden. The system uses advanced memory analysis, network capture, and automatic reconstruction techniques.

### ✨ Main Features

- **Single File Execution** - Only need to execute `main.lua`, everything loads from GitHub
- **Multi-Mode Operation** - Choose between FullRecovery, DeepScan, ScriptAnalysis, or AgentSystem
- **Complete Recovery** - Scripts, Map, Assets, Hidden parts
- **Security Scanning** - Vulnerability, Backdoor, Exploit detection
- **External API Integration** - Optional Groq API for advanced script analysis
- **Discord Notifications** - Real-time alerts via webhook
- **Simple Configuration** - All settings in one place at the top of main.lua

---

## Installation

### Step 1: Copy the Execution URL

Copy this URL:
```
https://raw.githubusercontent.com/3rgooone/Tower-Battles-Extractor/refs/heads/main/main.lua
```

### Step 2: Execute in Your Exploit

In your Roblox exploit (Synapse X, Script-Ware, KRNL, etc.):

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/3rgooone/Tower-Battles-Extractor/refs/heads/main/main.lua"))()
```

### Step 3: Configure (Optional)

Edit the configuration in `main.lua` before executing, or use the default settings.

---

## Usage

### Quick Start (Default Configuration)

Just execute the script with default settings:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/3rgooone/Tower-Battles-Extractor/refs/heads/main/main.lua"))()
```

### Custom Configuration

Copy the script locally, edit the `Config` table at the top, then execute:

```lua
-- Edit the Config table in main.lua, then:
loadstring(readfile("TowerBattlesExtractor/main.lua"))()
```

---

## Complete Configuration Guide

All settings are in the `Config` table at the top of `main.lua`. Here's every option explained:

### Basic Settings

```lua
local Config = {
    -- Mode: Choose what to run
    Mode = "FullRecovery",  -- Options: "FullRecovery", "DeepScan", "ScriptAnalysis", "AgentSystem"
}
```

**Mode Options:**
- `FullRecovery` - Complete recovery with all modules (recommended)
- `DeepScan` - Only deep memory scanning
- `ScriptAnalysis` - Only script analysis
- `AgentSystem` - Multi-agent automatic reconstruction

---

### Recovery Module Configuration

```lua
    -- Recovery Modules (true = enabled, false = disabled)
    UseDeepScan = true,           -- Deep memory scanning
    UseScriptDecryptor = true,    -- Script decryption
    UseScriptAnalyzer = true,     -- Static script analysis
    UseScriptReconstructor = true, -- Logic reconstruction
    UseScriptRepairer = true,     -- Automatic script repair
    UseMapExtractor = true,       -- Map extraction
    UseAssetRecovery = true,      -- Asset recovery
    UseExternalAPI = false,       -- External API analysis (requires API key)
```

**Recommendations:**
- Enable all for complete recovery
- Disable `UseExternalAPI` if you don't have an API key
- Disable `UseScriptReconstructor` and `UseScriptRepairer` for faster scans

---

### Security Module Configuration

```lua
    -- Security Modules
    UseVulnerabilityScanner = true,  -- Detect security vulnerabilities
    UseBackdoorScanner = true,       -- Detect hidden backdoors
    UseExploitScanner = true,        -- Scan for potential exploits
    UsePrivilegeEscalation = true,   -- Analyze available privileges
    UseDirectCopy = false,           -- Direct copy via exploits (DANGEROUS)
```

**Recommendations:**
- Enable all security scanners for analysis
- **NEVER** enable `UseDirectCopy` unless you know what you're doing
- This can trigger anti-cheat systems

---

### Notification Configuration

```lua
    -- Notifications
    UseDiscordNotifier = false,      -- Enable Discord notifications
    DiscordWebhookURL = "",          -- Your Discord webhook URL
```

**To set up Discord notifications:**
1. Create a Discord server
2. Go to Server Settings → Integrations → Webhooks
3. Create a new webhook
4. Copy the webhook URL
5. Set `UseDiscordNotifier = true`
6. Paste the URL in `DiscordWebhookURL`

---

### External API Configuration (Groq - Free)

```lua
    -- External API (Groq - Free)
    ExternalAPIConfig = {
        APIKey = "",                  -- Get free key at https://console.groq.com/
        Model = "llama-3.1-70b-versatile",
        MaxTokens = 4000,
        Temperature = 0.7
    },
```

**To set up Groq API (Free):**
1. Go to https://console.groq.com/
2. Create a free account
3. Go to API Keys
4. Create a new API key
5. Set `UseExternalAPI = true`
6. Paste the key in `APIKey`

**Available Groq Models (Free):**
- `llama-3.1-70b-versatile` - Best for code analysis (recommended)
- `llama-3.1-8b-instant` - Faster, smaller model
- `mixtral-8x7b-32768` - Good alternative

---

### Export Configuration

```lua
    -- Export
    ExportFormat = "JSON",           -- Options: "JSON", "LuaTable"
    OutputPath = "TowerBattles_FullRecovery"  -- Output folder name
```

**Recommendations:**
- Use `JSON` for easy viewing and parsing
- Use `LuaTable` for direct Lua usage
- Change `OutputPath` to organize different extractions

---

## Available Modes

### Mode 1: FullRecovery (Recommended)

Complete recovery with all enabled modules:

```lua
Config = {
    Mode = "FullRecovery",
    -- All recovery modules enabled
    -- All security modules enabled
}
```

**What it does:**
1. Deep memory scan
2. Script decryption and analysis
3. Script reconstruction and repair
4. Map extraction
5. Asset recovery
6. External API analysis (if enabled)
7. Security scanning
8. Final report generation

**Output:** Complete recovery in `TowerBattles_FullRecovery/` folder

---

### Mode 2: DeepScan

Only memory scanning:

```lua
Config = {
    Mode = "DeepScan"
}
```

**What it does:**
- Deep GC memory scan
- ReplicatedStorage scan
- Hidden table detection
- Gameplay data filtering

**Output:** `DeepScan_Results.json`

---

### Mode 3: ScriptAnalysis

Only script analysis:

```lua
Config = {
    Mode = "ScriptAnalysis"
}
```

**What it does:**
- Static script analysis
- Bytecode extraction
- Upvalue extraction
- Dependency mapping

**Output:** `ScriptAnalysis_Results.json`

---

### Mode 4: AgentSystem

Multi-agent automatic reconstruction:

```lua
Config = {
    Mode = "AgentSystem"
}
```

**What it does:**
- Automatic exploration
- Logic implementation
- Testing and validation
- Progressive reconstruction

**Output:** Agent system logs and reconstructed files

---

## Module Configuration

### Enable/Disable Specific Modules

You can mix and match modules:

```lua
Config = {
    Mode = "FullRecovery",
    
    -- Only enable what you need
    UseDeepScan = true,
    UseScriptAnalyzer = true,
    UseMapExtractor = true,
    
    -- Disable others for speed
    UseScriptDecryptor = false,
    UseScriptReconstructor = false,
    UseScriptRepairer = false,
    UseAssetRecovery = false,
    UseExternalAPI = false,
    
    -- Security modules
    UseVulnerabilityScanner = true,
    UseBackdoorScanner = false,
    UseExploitScanner = false,
    UsePrivilegeEscalation = false,
    UseDirectCopy = false
}
```

---

## External API Setup

### Step-by-Step Groq Setup

1. **Create Account**
   - Go to https://console.groq.com/
   - Sign up (free)

2. **Get API Key**
   - Go to API Keys section
   - Click "Create API Key"
   - Copy the key

3. **Configure in main.lua**
   ```lua
   Config = {
       UseExternalAPI = true,
       ExternalAPIConfig = {
           APIKey = "gsk_your-key-here",
           Model = "llama-3.1-70b-versatile"
       }
   }
   ```

4. **Benefits of External API**
   - Better script understanding
   - Automatic logic reconstruction
   - Detailed analysis reports
   - Dependency detection

---

## Discord Notifications

### Setup Instructions

1. **Create Webhook**
   - Discord Server → Settings → Integrations → Webhooks
   - Create Webhook → Copy URL

2. **Configure**
   ```lua
   Config = {
       UseDiscordNotifier = true,
       DiscordWebhookURL = "https://discord.com/api/webhooks/YOUR_WEBHOOK_URL"
   }
   ```

3. **What You'll Receive**
   - Recovery start notifications
   - Phase completion alerts
   - Error notifications
   - Final summary reports
   - Security alerts (backdoors, vulnerabilities)

---

## Output

All results are saved to the `OutputPath` folder (default: `TowerBattles_FullRecovery/`):

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

---

## Security and Legality

### ⚠️ Legal Disclaimer

This tool is for **educational purposes only**. Use it responsibly:

- **DO NOT** use on games you don't own
- **DO NOT** use for unauthorized exploitation
- **DO NOT** distribute recovered content without permission
- **DO** use for learning and understanding game mechanics
- **DO** use to secure your own games

### Security Risks

- **DirectCopy module** is dangerous and can trigger anti-cheat
- Always test in a safe environment first
- Some modules may be detected by advanced anti-cheat systems
- Use at your own risk

---

## FAQ

### Q: Do I need to download all files?
**A:** No! Only execute `main.lua`. All modules load automatically from GitHub.

### Q: How do I change the mode?
**A:** Edit the `Mode` field in the `Config` table at the top of `main.lua`.

### Q: Is the external API free?
**A:** Yes! Groq offers a generous free tier. Get your key at https://console.groq.com/

### Q: Can I disable specific modules?
**A:** Yes! Set any `UseXXX` field to `false` in the Config table.

### Q: Where are the results saved?
**A:** In the folder specified by `OutputPath` (default: `TowerBattles_FullRecovery/`).

### Q: How do I set up Discord notifications?
**A:** Create a webhook in Discord, then set `UseDiscordNotifier = true` and paste the URL.

### Q: What mode should I use?
**A:** `FullRecovery` is recommended for complete extraction. Use other modes for specific tasks.

### Q: Is this safe to use?
**A:** Most modules are safe. Avoid `UseDirectCopy = true` as it can trigger anti-cheat.

---

## License

MIT License - See LICENSE file for details.

---

## Support

For issues or questions, check the GitHub repository:
https://github.com/3rgooone/Tower-Battles-Extractor
