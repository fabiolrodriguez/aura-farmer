# Aura Farmer 6 7 - Steam Build Prep

## Branch

Work branch: `codex/steam-build-prep`

## Data Needed From Steamworks

- Steam AppID for Aura Farmer 6 7: `1259394`.
- Exact public app name as it should appear on Steam: `Aura Farmer 67`.
- Steamworks SDK version to target.
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
- `export_presets.cfg`: Godot export settings are local and currently ignored.
- Steamworks SDK binaries: keep platform binaries in the local export/build environment unless we decide to vendor a redistributable wrapper.

## Current Project State

- Game name is configured in `project.godot`.
- Main scene is `res://Scenes/MainMenu/MainMenu.tscn`.
- Game icon is configured as `res://Assets/UI/Icon/aura_farmer_icon_1024.png`.
- Steam achievement IDs already exist in `Resources/achievements_data.gd`.
- Steam achievement bridge exists at `Scripts/Integrations/SteamAchievementBridge.gd`.
- Optional GodotSteam provider exists at `Scripts/Managers/SteamManager.gd`.
- `SteamManager` registers the bridge only when the `Steam` singleton is available.
- No committed export preset exists yet.

## Build Prep Tasks

- Create local Godot export preset for Windows Desktop.
- Export a Steam candidate build.
- Add Steam API initialization path. Done for achievements through `SteamManager`.
- Wire achievement unlocks to the Steam bridge only when Steam API is available. Done.
- Test startup without Steam running.
- Test startup with Steam running and `steam_appid.txt`.
- Verify fullscreen/windowed setting after export.
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
