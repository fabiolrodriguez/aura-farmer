# Aura Farmer 6 7 - Steam Build Prep

## Branch

Work branch: `codex/steam-build-prep`

## Data Needed From Steamworks

- Steam AppID for Aura Farmer 6 7: `1259394`.
- Exact public app name as it should appear on Steam: `Aura Farmer 67`.
- Steamworks SDK version bundled with GodotSteam 4.20.1.
- Whether the first build should be Windows-only or include macOS/Linux too.
- Steam depot IDs for each platform that will ship.
- Developer Comp package ID: `1735362`.
- Beta Testing package ID: `1735363`.
- Store package ID: `1735364`.
- Beta branch names, if any, such as `internal`, `qa`, or `demo`.
- List of Steam achievement API names created in Steamworks.
- Store page release target date and desired Coming Soon date.
- Minimum and recommended system requirements.

## Local Files Not Committed

- `steam_appid.txt`: useful for local Steam API testing. Keep it out of source control.
- Steamworks SDK binaries are provided by the versioned GodotSteam GDExtension.

## Current Project State

- Game name is configured in `project.godot`.
- Main scene is `res://Scenes/MainMenu/MainMenu.tscn`.
- Game icon is configured as `res://Assets/UI/Icon/aura_farmer_icon_1024.png`.
- Steam achievement IDs already exist in `Resources/achievements_data.gd`.
- Steam achievement bridge exists at `Scripts/Integrations/SteamAchievementBridge.gd`.
- Optional GodotSteam provider exists at `Scripts/Managers/SteamManager.gd`.
- `SteamManager` registers the bridge only when the `Steam` singleton is available.
- GodotSteam GDExtension 4.20.1 is installed for Godot 4.7.1.
- A reproducible Windows Desktop export preset exists at `export_presets.cfg`.

## Build Prep Tasks

- Create Godot export preset for Windows Desktop. Done.
- Export a Steam candidate build. Done for Windows x86_64.
- Add Steam API initialization path. Done for achievements through `SteamManager`.
- Wire achievement unlocks to the Steam bridge only when Steam API is available. Done.
- Test startup without Steam running. Done.
- Test startup through an installed Steam depot and entitled package.
- Verify fullscreen/windowed setting after export. Pending manual QA.
- Verify save location and offline progress after relaunch.
- Verify achievements unlock in-game and in Steam backend.
- Review IP/trademark-sensitive names and visuals before store review.

## Achievement API Names

Create these API names in Steamworks exactly as written:

- `AF_FIRST_CLICK`
- `AF_TEN_CLICKS`
- `AF_HUNDRED_CLICKS`
- `AF_THOUSAND_CLICKS`
- `AF_FIRST_AURA`
- `AF_AURA_100`
- `AF_AURA_1K`
- `AF_AURA_10K`
- `AF_AURA_100K`
- `AF_AURA_1M`
- `AF_AURA_10M`
- `AF_AURA_100M`
- `AF_AURA_1B`
- `AF_AURA_1T`
- `AF_FIRST_UPGRADE`
- `AF_FIVE_UPGRADES`
- `AF_TWENTY_UPGRADES`
- `AF_UPGRADE_LEVEL_10`
- `AF_UPGRADE_LEVEL_50`
- `AF_CLICK_BUILD`
- `AF_AUTO_FARM`
- `AF_AUTO_ENGINE`
- `AF_MULTIPLIER_BUILD`
- `AF_DRIP_DARK_GLASSES`
- `AF_LEGENDARY_SKIN`
- `AF_ANCIENT_CHAMPION`
- `AF_FIRST_REBIRTH`
- `AF_ESSENCE_25`
- `AF_COSMIC_FORM`
- `AF_PLATINUM`
