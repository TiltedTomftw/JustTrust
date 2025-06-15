# JustTrust

A trust management addon for FFXI that prevents duplicate purchases and manages trust sets.

## Features

### Duplicate Purchase Protection
- Detects which trusts you already own in shops
- Shows which trusts are safe to buy  
- Blocks duplicate purchases automatically
- Can be toggled on/off as needed with //jt trustdupe

### Trust Set Management
- Save your current trust party as named sets
- Load saved trust sets with automatic casting
- Cooldown detection - skips trusts on cooldown with accurate time display
- Persistent storage - sets saved between sessions
- Smart casting delays to prevent overlap

## Commands

- `//jt trustdupe` - Toggle duplicate purchase protection on/off
- `//jt saveset <name>` - Save your current trust party as a named set
- `//jt loadset <name>` - Load and automatically cast a saved trust set
- `//jt setlist` - List all your saved trust sets
- `//jt deleteset <name>` - Delete a specific trust set
- `//jt clearsets` - Clear all saved trust sets

## Installation

1. Copy to your `Windower/addons/` directory
2. In-game: `//lua load JustTrust`

## Usage Examples

```
//jt saveset solo        - Save current trusts as "solo" set
//jt loadset solo        - Load and cast the "solo" trust set
//jt setlist            - See all your saved sets
//jt trustdupe          - Toggle duplicate purchase protection
```



Created by **Tilted_Tom** with **GitHub Copilot**
