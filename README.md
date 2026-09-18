# BINSEC Modpack

A Fabric modpack for Minecraft Java Edition 26.1.2, maintained by D5-Interactive. This document is a micro-wiki for pack / server maintainers.

## Table of Contents

1. [Pack Overview](#1-pack-overview)
2. [Repository Layout](#2-repository-layout)
3. [Installing and Running the Pack](#3-installing-and-running-the-pack)
4. [Memory Allocation](#4-memory-allocation)
5. [Where Configuration Lives](#5-where-configuration-lives)
6. [Mod Configuration Reference](#6-mod-configuration-reference)
7. [Minecraft and In-Game Settings](#7-minecraft-and-in-game-settings)
8. [Resource Packs and Shader Packs](#8-resource-packs-and-shader-packs)
9. [Updating Mods and Content](#9-updating-mods-and-content)
10. [Git and LFS Workflow](#10-git-and-lfs-workflow)
11. [Known Gaps and Notes](#11-known-gaps-and-notes)
12. [Troubleshooting](#12-troubleshooting)
13. [Full Mod List](#13-full-mod-list)

## 1. Pack Overview

| Item | Value |
| --- | --- |
| Minecraft | Java Edition 26.1.2 (released 9 April 2026) |
| Mod loader | Fabric Loader 0.19.5 |
| Java runtime | Java SE 25 minimum (Minecraft 26.1+ requirement) |
| Instance type | Prism Launcher OneSix instance |
| Mod count | 66 jars |
| Resource packs | 5 |
| Shader packs | 4 |
| Default memory | 8000 MiB (8 GB) max, set in `instance.cfg` |

Version facts worth remembering:

- Minecraft 26.1.2 uses data pack format 101, resource pack format 84, protocol 775.
- Minecraft 26.1 and newer are unobfuscated. Mods are built against the exact minor version, so a mod built for 26.1.2 may refuse to load on 26.2. Keep every mod pinned to the `+26.1.2` or `+26.1` build line.
- Fabric Loader and Fabric API are separate. This pack runs Fabric API `0.155.3+26.1.2`.

## 2. Repository Layout

The repository is a raw Prism instance folder, not a `.mrpack`. That means you can drop the cloned folder straight into a Prism `instances` directory.

```
binSEC/
  instance.cfg                 Prism instance settings (memory, name, uuid)
  mmc-pack.json                Component list: Minecraft, LWJGL, Fabric Loader
  .gitattributes               Git LFS tracking rules
  .gitignore                   Files never committed
  minecraft/
    config/                    All mod config files (tracked)
    mods/                      Mod jars (LFS) plus .index metadata
    resourcepacks/             Resource pack zips (LFS) plus .index metadata
    shaderpacks/               Shader pack zips (LFS) plus .pw.toml metadata
    icon.png                   Instance icon (LFS)
```

Tracked files: `instance.cfg`, `mmc-pack.json`, everything under `minecraft/config`, mod jars and their `.index`, resource packs and their `.index`, shader packs and their `.pw.toml`, and the icon.

Ignored files (see `.gitignore`): `saves/`, `logs/`, `crash-reports/`, `options.txt`, `servers.dat`, `.mixin.out/`, `debug/`, `downloads/`, `data/`, `dynamic-resource-pack-cache/`, `server-resources/`, `replay_recordings/`, `waylandcraft/`, and `hs_err_pid*.log`. These are runtime generated or user specific and should never be committed.

## 3. Installing and Running the Pack

### For maintainers and players using Prism

1. Install Git LFS once per machine: `git lfs install`.
2. Clone the repository into the Prism instances folder so the folder name matches the instance name:
   - Windows: `%APPDATA%\PrismLauncher\instances\binSEC`
   - Linux: `~/.local/share/PrismLauncher/instances/binSEC`
   - macOS: `~/Library/Application Support/PrismLauncher/instances/binSEC`
3. If the repo was cloned without LFS, run `git lfs pull` to download the real jars and zips. Otherwise the binary files will be small text pointer files and the game will fail to load.
4. Open Prism. The instance appears in the list. Launch it.

Prism reads `mmc-pack.json` to install the correct Minecraft version, LWJGL, and Fabric Loader automatically. Prism reads `instance.cfg` for memory and Java settings.

### Java

Minecraft 26.1.2 requires Java SE 25 or newer. With `AutomaticJava=true` Prism picks a suitable runtime automatically and can download one if needed (Settings, Java, Download Java). The machine specific Java path was removed from `instance.cfg` on purpose so every maintainer uses their own detected runtime.

## 4. Memory Allocation

Memory is controlled in `instance.cfg` under `[General]`:

| Key | Current value | Meaning |
| --- | --- | --- |
| `MaxMemAlloc` | 8000 | Maximum heap in MiB, passed to Java as `-Xmx` |
| `OverrideMemory` | true | Use this instance's memory values instead of the global Prism defaults |
| `MinMemAlloc` | not set | Minimum heap as `-Xms`, defaults to 512 MiB if omitted |

### Changing memory in the Prism GUI

1. Right click the instance, choose Edit, then Settings, then Java.
2. Under Memory enable the override and set the maximum allocation.
3. Alternatively set a global default under Settings, Java.

Changing memory here updates `MaxMemAlloc` in `instance.cfg`. Because `instance.cfg` is tracked, committing that change ships the new default to everyone. If a contributor needs a personal value they should override it locally and use `git update-index --skip-worktree instance.cfg`, or simply not commit their change.

### What value to use

- This pack uses about 4 to 6 GB under normal play with shaders. 8 GB is a comfortable default.
- A safe ceiling is 50 to 70 percent of total system RAM. On a 16 GB machine, do not exceed about 10 GB. On an 8 GB machine, use 4 to 5 GB.
- Do not set a very large heap. A huge `-Xmx` makes garbage collection pauses longer and can reduce performance. More RAM does not equal better performance.
- Set `MinMemAlloc` equal to `MaxMemAlloc` only if you see frequent stutter from heap resizing. Otherwise leave it low.

### JVM arguments

Prism generates `-Xms` and `-Xmx` from the memory fields and applies its default JVM arguments (G1GC tuning flags). This pack does not set `OverrideJavaArgs`, so Prism defaults are in effect. If a maintainer adds custom JVM arguments in instance settings, Prism writes `OverrideJavaArgs=true` and `JvmArgs=` into `instance.cfg`, which would then be committed. Only do that deliberately.

## 5. Where Configuration Lives

- `minecraft/config/` holds all mod configuration. There are 128 files here. These are tracked and shared.
- `minecraft/options.txt` holds vanilla video, audio, and control settings. It is user specific and ignored by Git.
- `minecraft/mods/.index/*.pw.toml` and `minecraft/resourcepacks/.index/*.pw.toml` and `minecraft/shaderpacks/*.pw.toml` are Prism metadata files used for update checks. They record the Modrinth project id, version id, and a SHA-512 hash. Do not hand edit them; let Prism manage them.
- Mod configs can usually be edited in game through Mod Menu, selecting a mod, then the config button. Several mods use Fzzy Config, YACL, Cloth Config, or Forge Config API Port for their screens.
- To reset a mod to defaults, close the game, delete its config file or folder from `minecraft/config`, and restart. The mod regenerates it.

Configs are per world in some cases and global in others. World specific configs live inside the save folder and are not tracked here.

## 6. Mod Configuration Reference

Each entry lists what the mod does, its config file, and the settings a maintainer is most likely to change.

### 6.1 Performance and Rendering

**Sodium** `sodium-fabric-0.9.2-beta.1+mc26.1.2.jar`
Modern chunk rendering engine. Config: `config/sodium-options.json` and `config/sodium-mixins.properties` (empty, meaning defaults).
- `quality.hidden_fluid_culling` and `quality.improved_fluid_shaping` control fluid rendering.
- `quality.pixel_filtering_mode` is `NEAREST` for crisp textures.
- `performance.chunk_builder_threads` 0 means auto. Set a fixed number if chunk loading causes stutter.
- `performance.chunk_build_defer_mode` is `ALWAYS`.
- `performance.use_entity_culling`, `use_fog_occlusion`, and `use_block_face_culling` are all enabled.
- `performance.quad_splitting_mode` is `SAFE`.
- `advanced.cpu_render_ahead_limit` is 3. Lower it for lower input latency, raise it for smoother frame pacing.

**Iris** not currently installed
Shader loader. Its config files exist (`config/iris.properties`, `config/iris-excluded.json`) but no Iris jar is present, so the shader packs will not load. See section 11. `iris.properties` keys: `shaderPack` (folder name of the active pack), `enableShaders`, `maxShadowRenderDistance`, `allowUnknownShaders`, `colorSpace`.

**EntityCulling** `entityculling-fabric-1.10.5-mc26.1.jar`
Skips rendering entities and block entities hidden behind blocks. Config: `config/entityculling.json`.
- `tracingDistance` 128 controls how far occlusion rays travel.
- `sleepDelay` 10 and `captureRate` 5 trade accuracy for CPU cost.
- `tickCulling` true skips ticks for entities that cannot be seen. `tickCullingWhitelist` protects entities that must always tick.
- `blockEntityWhitelist` and `entityWhitelist` list entities culling must never skip.

**ImmediatelyFast** `ImmediatelyFast-Fabric-1.15.3+26.1.jar`
Immediate mode rendering optimizations. Config: `config/immediatelyfast.json`.
- `enhanced_batching`, `font_atlas_resizing`, `map_atlas_generation`, `fast_text_lookup`, and `avoid_redundant_framebuffer_switching` are the main performance toggles.
- Experimental options such as `experimental_sign_text_buffering` can cause glitches. Leave them off unless testing.

**Dynamic FPS** `dynamic-fps-3.11.7+minecraft-26.1.0-fabric.jar`
Lowers FPS and pauses rendering when the window is unfocused. Config: `config/dynamic_fps.json`. The file is `{}` which means defaults. Use its Mod Menu screen for options such as idle FPS.

**BadOptimizations** `BadOptimizations-2.4.1-26.1-fabric.jar`
Micro optimizations for lighting, sky, and managers. Config: `config/badoptimizations.txt`.
- `enable_lightmap_caching`, `enable_sky_color_caching`, `enable_particle_manager_optimization`, `enable_toast_optimizations`, and the renderer caching options are enabled.
- If a new entity-adding mod crashes, disable `enable_entity_renderer_caching` first.
- `ignore_mod_incompatibilities` is false for safety.

**FerriteCore** `ferritecore-9.0.0-fabric.jar`
Reduces memory used by block states and models. Config: `config/ferritecore.mixin.properties`.
- `replaceNeighborLookup`, `replacePropertyMap`, `blockstateCacheDeduplication`, and `dataComponentPatch` are enabled.
- `useSmallThreadingDetector` and `compactFastMap` are off. Leave them off unless reproducing memory issues.

**Lithium** `lithium-fabric-0.24.7+mc26.1.2.jar`
General gameplay and server side performance. Config: `config/lithium.properties`. Empty means all defaults. Individual optimizations can be disabled with lines like `mixin.ai.poi=false` if a conflict appears.

**Particle Core** `particle_core-0.3.2+26.1.jar`
Particle culling and reduction. Config: `config/particle_core_config.toml`.
- `cullingBehavior` is `AGGRESSIVE`, `maxParticlesPerSheet` is 16384, `asynchronousTicking` is true.
- `disableParticles` turns all particles off but also hides meteor trails in Dungeons and Taverns.
- `particleRenderDistanceMultiplier` scales particle view distance.
- `config/particle_core_disabled_optimizations_v2.json` lists mixin groups a maintainer can turn off if a particle mod conflicts.

**Debugify** `debugify-26.1.2.2.jar`
Fixes many vanilla bugs. No dedicated config file; individual fixes are toggled in its mod config screen.

**Fast IP Ping** `fast-ip-ping-v1.0.11-mc26.1.2.jar`
Removes slow reverse DNS lookups for servers addressed by literal IP. Client side only, no config.

**Packet Fixer** `packetfixer-fabric-3.3.5-26.1.2.jar`
Raises network packet and NBT size limits. Config: `config/packetfixer.properties`.
- `allSizesUnlimited=true` in this pack. This helps with large custom payloads but means the client will send and accept large packets. Servers that do not run Packet Fixer with matching limits may disconnect this client. This is the most likely cause of "packet too big" style kicks.
- `nbtMaxSize`, `packetSize`, `decoderSize`, and `varInt21` can be lowered individually if needed.

### 6.2 HUD and Interface

**Jade** `Jade-mc26.1-Fabric-26.1.9.jar`
Look at block and entity tooltips. Configs: `config/jade/jade.json`, plus `hide-blocks.json`, `hide-entities.json`, `hide-mob-effects.json`, `sort-order.json`, and profile folders `config/jade/profiles/1..3`.
- The main file controls overlay theme, position, scale, and per-plugin features. `displayMode` is `TOGGLE`.
- `hide-blocks.json` currently hides `barrier`. `hide-entities.json` hides effect clouds, fireworks, interaction markers, text displays, and lightning.
- Profiles are disabled (`enableProfiles` false). Turn them on to keep multiple tooltip layouts.

**JEI (Just Enough Items)** `jei-26.1.2-fabric-29.37.0.98.jar`
Item and recipe viewer. Client config: `config/jei/` (`jei-client.ini`, colors, sorting, blacklist). Server config: `config/jei-server.properties`.
- `enableCheatModeForOp` and `enableCheatModeForCreative` are true. `enableCheatModeForGive` is false.
- `config/jei/blacklist.json` hides specific items from the list.

**AppleSkin** `appleskin-fabric-mc26.1.2-3.0.10.jar`
Hunger, saturation, and food value overlays. Config: `config/appleskin.json5`. All overlays are on by default.

**Dynamic Crosshair** `dynamiccrosshair-9.12+26.1-fabric.jar`
Crosshair changes shape based on target and held item. Config: `config/dynamiccrosshair.json5`. Defines a style per situation under `crosshairStyle` and per modifier under `crosshairModifiers`. Colors are signed 32 bit ARGB integers.

**Chat Heads** `chat_heads-1.2.8-fabric-26.1.jar`
Shows player heads in chat. Config: `config/chat_heads.json5`. `renderPosition` is `BEFORE_NAME`, `threeDeeNess` 0.0.

**Enchantment Descriptions** `EnchantmentDescriptions-fabric-MC26.1.2-26.1.2.6.jar`
Shows enchantment descriptions. Config: `config/enchdesc.json`. `require_keybind` false means descriptions always show. Text style and prefix and suffix are configurable.

**Mod Menu** `modmenu-18.0.0.jar`
In game mod list and config entry point. Config: `config/modmenu.json`. `quick_configure` opens config screens directly. `update_channel` is `release`.

**Controlling** and **Searchables** `Controlling-fabric-26.1.2-26.1.2.4.jar`, `Searchables-fabric-26.1.2-1.0.2.jar`
Adds search to the keybind screen. Searchables is its library. No user facing config files.

**Mouse Tweaks** `MouseTweaks-fabric-mc26.1-2.31.jar`
Inventory dragging and scrolling. Config: `config/MouseTweaks.cfg`. All tweaks set to 1 (enabled).

**More Chat History** `morechathistory-2.0.0.jar`
Increases chat scrollback. No config file.

**CreativeCore** `CreativeCore_FABRIC_v2.14.16_mc26.1.2.jar`
Library used by Immersive Paintings and others. Configs: `config/creativecore.json` and `config/creativecore-client.json` (`maxGuiScale` 10). Rarely needs editing.

### 6.3 Combat, Camera, and Animation

**Better Combat** `bettercombat-fabric-3.2.2+26.1.2.jar`
Attack animations and combat mechanics. Client config: `config/bettercombat/client.json5`. Server and world config: `config/bettercombat/server.json5`. Also `weapon_trails.json` and `fallback_compatibility.json`.
- Server side highlights: `upswing_multiplier` 0.5, `allow_fast_attacks` true, `allow_vanilla_sweeping` false, `allow_reworked_sweeping` true, `movement_speed_while_attacking` 0.5, `combo_reset_rate` 3.0.
- `player_relations` decides whether swings can hit players, villagers, and golems. Set a relation to `FRIENDLY` to make it un-hittable.
- Client side `isHoldToAttackEnabled` and `isMiningWithWeaponsEnabled` are true. `weapon_trails.json` styles trail particles.
- Because both client and server files ship here, singleplayer and hosted LAN worlds use these values.

**Player Animation Library** `PlayerAnimationLibMerged-1.2.6+mc.26.1.jar`
Library that supplies Better Combat's animations. No config.

**First Person Model** `firstperson-fabric-2.7.2-mc26.1.jar`
Renders a full player model in first person. Config: `config/firstperson.json`. `dynamicMode` true, `vanillaHandsMode` `OFF`, and a list of items that force vanilla hands (`autoVanillaHands`).

**Do a Barrel Roll** `do_a_barrel_roll-fabric-3.8.4+26.1.jar`
Flight style elytra rolling and banking. Config: `config/do_a_barrel_roll-client.json` and `config/do_a_barrel_roll-server.json`.
- `banking.enable_banking` true, `banking_strength` 20.0, `thrust.enable_thrust` false.
- Advanced formulas let maintainers reshape banking and control surface response.

**Not Enough Animations** `notenoughanimations-fabric-1.12.4-mc26.1.jar`
Third person player animations for actions like eating, rowing, and climbing. Config: `config/notenoughanimations.json`. This file also lists items that should always be held up or animated, such as lanterns and maps.

**Traveler's Backpack** `travelersbackpack-fabric-26.1.2-11.2.10.jar`
Backpacks with upgrades. Configs: `config/travelersbackpack-common.toml`, `travelersbackpack-client.toml`, and the large `travelersbackpack-server.toml`.
- Server file sets tier slot counts, upgrade availability, mob spawn chance with backpacks (`chance` 0.005), mob backpack ability effects and cooldowns, and slowness rules.
- Client file sets the tool belt and tank overlay position and opacity.

**Comforts** `comforts-fabric-15.0.0+26.1.2.jar`
Sleeping bags and hammocks. Configs: `config/comforts-common.toml` (recipes) and `config/comforts-server.toml` (behavior). Sleeping bags work only at night, hammocks only during the day by default. `sleepingBagBreakChance` is 0 so they do not break.

**Carry On** `carryon-fabric-26.1.2-2.10.0.jar`
Pick up and carry blocks and entities. Configs: `config/carryon-common.json` and `config/carryon-client.json`.
- The common file has large block and entity blacklists. Add registry names to `forbiddenTiles` or `forbiddenEntities` to prevent carrying them.
- Hostile mobs cannot be picked up in survival (`pickupHostileMobs` false), and players can be picked up (`pickupPlayers` true).

**dummmmmmy** `dummmmmmy-26.1.2-3.0.1-fabric.jar`
Training dummy, damage numbers, and a scarecrow. Configs: `config/dummmmmmy-common.json` and `config/dummmmmmy-client.json`.
- Common file sets the scarecrow radius (12), DPS mode `DYNAMIC`, and disables equipment damage.
- Client file sets damage number colors, crit display, and animation intensity.

**AttributeFix** `AttributeFix-fabric-MC26.1.2-26.1.2.3.jar`
Raises vanilla attribute caps. Config: `config/attributefix/minecraft/*.json`, one file per attribute (`max_health.json`, `attack_damage.json`, and so on). Each file sets the maximum allowed value. Only change these if another mod needs higher caps.

### 6.4 World Generation and Structures

**Biomes O' Plenty** `BiomesOPlenty-fabric-26.1.2-26.1.2.0.22.jar`
Adds many biomes. Configs: `config/biomesoplenty/biome_toggles.json` and `config/biomesoplenty/generation.toml`.
- `biome_toggles.json` enables or disables each biome by name.
- `generation.toml` sets region weights for overworld and nether biome placement.
- Changing toggles after a world exists only affects newly generated chunks. Removing the mod can damage existing worlds that use its biomes. Treat world generation changes as one way.

**TerraBlender** `TerraBlender-fabric-26.1.2-26.1.2.0.3.jar`
Controls how biome mods place their regions. Config: `config/terrablender.toml`. Sets overworld and nether region sizes and weights and end biome sizes. This works together with the Biomes O' Plenty weights.

**GlitchCore** `GlitchCore-fabric-26.1.2-26.1.2.0.2.jar`
Library used by Biomes O' Plenty. No user config.

**Dungeons and Taverns** `dungeons-and-taverns-5.2.0.jar`
Adds and overhauls many structures. It has no config file here; behavior is data driven. Because it changes structure placement, treat it as one way for existing worlds.

**Macaw's Mods** `mcw-bridges`, `mcw-doors`, `mcw-fences`, `mcw-furniture`, `mcw-paths`, `mcw-roofs`, `mcw-stairs`, `mcw-trapdoors`, `mcw-windows` (all `26.1fabric`)
Decorative building block sets. No config files; content is added through crafting.

### 6.5 Content and Gameplay

**CC: Tweaked** `cc-tweaked-26.1.2-fabric-1.120.0.jar`
ComputerCraft computers and turtles. Configs: `config/computercraft-server.toml` and `config/computercraft-client.toml`.
- Server file controls command computer permissions, disk space limits (`computer_space_limit` 1000000 bytes), turtle fuel, wireless modem range, monitor bandwidth, monitor and computer terminal sizes, and the HTTP API.
- HTTP is enabled. There is a deny rule for private addresses (`$private`) followed by an allow all rule with upload and download size caps. Editing these rules is the correct way to restrict the HTTP API.
- Client file sets `monitor_distance` 64 and the upload nag delay.

**Immersive Paintings** `immersive_paintings-fabric-26.1.2-0.7.8.jar`
Custom images on paintings. Configs: `config/immersive_paintings/common_config.toml` and `client_config.toml`.
- Common file sets max image dimensions (4096 by 4096), max user images (1000), painting resolution limits, and packet rate and size.
- Client file sets thumbnail size, LOD thresholds, and whether NSFWPaintings show.

**AmbientSounds** `AmbientSounds_FABRIC_v6.3.6_mc26.1.2.jar`
Adds ambient background sound. Config is managed through its in game screen. It depends on CreativeCore.

**Essential** `Essential_1-5-0-1_fabric_26-1-2.jar`
Friends list, cosmetics, and a hosting button. Config is through the mod screen and an online account. Maintainers should be aware it communicates with Essential's servers and provides cosmetic features.

### 6.6 Audio and Voice

**Sound Physics Remastered** `sound-physics-remastered-fabric-1.5.1+26.1.2.jar`
Realistic sound occlusion, reverb, and attenuation. Configs: `config/sound_physics_remastered/soundphysics.properties`, plus `occlusion.properties`, `reflectivity.properties`, and `sound_rates.properties`.
- `soundphysics.properties` is the main file. Important keys: `attenuation_factor` (1.0 is physically correct), `reverb_gain`, `block_absorption`, `max_occlusion_rays` (16), `environment_evaluation_ray_count` (32), and `environment_evaluation_ray_bounces` (4).
- Lower ray counts if sounds cause lag spikes. The ray count and bounce count are the main CPU cost.
- `simple_voice_chat_integration` true applies sound physics to voice chat. `occlusion.properties` and `reflectivity.properties` define per-block behavior and are advanced.

**Simple Voice Chat** `voicechat-fabric-2.6.23+26.1.2.jar`
Proximity voice chat. Client config: `config/voicechat/voicechat-client.properties`. Server config: `config/voicechat/voicechat-server.properties`. Also `category-volumes.properties` and `player-volumes.properties` for per-category and per-player volume.
- Server file: voice port `24454` UDP, `max_voice_distance` 48, `whisper_distance` 24, codec `VOIP`, `mtu_size` 1275, groups enabled.
- To host, forward or allow UDP port 24454. Do not set the voice port equal to the Minecraft TCP port.
- Client file: push to talk is the default (`microphone_activation_type` `PTT`), noise suppression on, `run_local_server` true so it works in singleplayer and LAN.

### 6.7 Multiplayer and Networking

**e4mc** `e4mc` (no separate jar name suffix, part of the pack)
Shares a LAN world over the internet through a relay. Config: `config/e4mc/e4mc.toml`.
- `hostEnabled` true enables sharing.
- `useBroker` true picks the best relay. `relayHost` defaults to `test.e4mc.link` and port 25575.
- `dialtoneHostEnabled` and `dialtonePlayerEnabled` enable peer to peer connections.
- `restoreDedicatedCommands` true restores commands like `/ban` and `/whitelist` in shared worlds.

**No Chat Reports** `NoChatReports-FABRIC-26.1-v2.19.0.jar`
Reduces chat signing and reporting. Configs: `config/NoChatReports/NCR-Client.json`, `NCR-Common.json`, and `NCR-ServerPreferences.json`.
- Client: `defaultSigningMode` is `PROMPT`, `disableTelemetry` and `removeTelemetryButton` are true.
- It can require the mod on clients when used on a server. This pack is client side, so conversions apply to chat locally.

**WaylandCraft** `waylandcraft-v2.0.3.jar`
Native Wayland window handling for Linux. The mod jar is kept but its user config folder `minecraft/waylandcraft/` is ignored because it is machine specific. This mod only matters on Linux Wayland compositors; on other platforms it does nothing useful.

### 6.8 Libraries and Support

These are dependencies and do not need editing in normal maintenance.

- Fabric API `fabric-api-0.155.3+26.1.2.jar`
- Fabric Language Kotlin `fabric-language-kotlin-1.14.1+kotlin.2.4.20.jar`
- Cloth Config `cloth-config-26.1.154.jar`
- Yet Another Config Lib (YACL) `yet_another_config_lib_v3-3.9.6+26.1-fabric.jar`, config `config/yacl.json5`
- Fzzy Config `fzzy_config-0.7.6+26.1.jar`, config `config/fzzy_config/keybinds.toml` for config screen navigation, copy, and paste keys
- Forge Config API Port `ForgeConfigAPIPort-v26.1.5-mc26.1.x-Fabric.jar`, config `config/forgeconfigapiport.toml`
- Moonlight Lib `moonlight-26.1.2-4.0.2-fabric.jar`, configs `config/moonlight-client.json` and `config/moonlight-common.json`
- Cicada Lib `cicada-lib-0.15.2+26.1.jar`
- Placeholder API `placeholder-api-3.0.0+26.1.jar`
- Cardinal Components API `cardinal-components-api.properties` at `config/cardinal-components-api.properties`
- Prickle `PrickleMC-fabric-MC26.1.2-26.1.2.6.jar`, a JSON config format library by Darkhax
- Transition (TRansition) `config/transition.json`, a library that eases migration between loader and game versions; it has `userConsentedToSendCrashReports` false and `disableRecipeBookCodes` false
- Trender (TRender) `config/trender.json`, a rendering utility library, `style` is `VANILLA_MODERN`

## 7. Minecraft and In-Game Settings

Vanilla gameplay and display settings are stored in `minecraft/options.txt`, which is ignored by Git. Each player keeps their own. Settings a maintainer should know about:

- Video settings: render distance, simulation distance, graphics quality, smooth lighting, entity shadows, VSync, and max framerate. With Sodium installed these screens are provided by Sodium.
- Keybinds: stored per player. Mod keybinds appear here, for example Zoomify zoom, voice chat push to talk, Traveler's Backpack, and Jade toggle.
- Audio: master, music, and the per mod volumes in the Simple Voice Chat config.
- Language and accessibility: per player.

If the pack should ship a specific set of default video settings or keybinds, do that by shipping a defaults mod or by documenting the values here, not by committing a personal `options.txt`.

Recommended baseline for this pack: graphics Fancy, smooth lighting maximum, entity shadows on, render distance 8 to 12, simulation distance 8 to 10, VSync off and a manual framerate cap, and mipmap levels 4.

## 8. Resource Packs and Shader Packs

### Resource packs (5)

- Bare Bones 1.21.11.zip
- Default-Dark-Mode-26.2-2026.6.0.zip
- Dramatic Skys Demo 1.5.3.36.5.zip
- Fancy Crops v1.3.zip
- FreshAnimations_v1.10.5.zip

Enable and order them in Options, Resource Packs. Order matters: a pack higher in the list overrides lower ones.

FreshAnimations requires Entity Model Features (EMF) and Entity Texture Features (ETF), or OptiFine. Neither EMF nor ETF is in the pack right now, so FreshAnimations will not animate. See section 11.

### Shader packs (4)

- BSL_v10.1.5.zip
- ComplementaryReimagined_r5.9.zip
- Ebin-Resurrected-v1.5.6.zip
- MakeUp-UltraFast-9.5e.zip

Shader packs require Iris. Iris is not in the pack right now, so shaders will not load. See section 11.

Each managed pack has a `.pw.toml` metadata file, for example `shaderpacks/complementary-reimagined.pw.toml`, that Prism uses to check Modrinth for updates. The shader selection itself is stored in `config/iris.properties` under `shaderPack` once Iris is installed.

Adding a pack manually: drop the zip into the matching folder and commit it. The `.zip` extension is tracked by Git LFS, so it uploads correctly. You can also use the resourcepacks and shaderpacks pages in Prism to add a file or download from Modrinth.

## 9. Updating Mods and Content

Prism tracks mod origin in `minecraft/mods/.index/*.pw.toml`. If a jar was installed from Modrinth, its `.pw.toml` records the project id, version id, and SHA-512 hash. Use the instance's Mods page and the update button to update; Prism downloads the new jar, replaces the old one, and rewrites the metadata.

Rules for maintainers:

1. Stay on Minecraft 26.1.2 and Fabric Loader 0.19.5. Do not jump to 26.2 unless every mod has a 26.2 build and the pack is retested end to end.
2. Keep mod versions consistent with the game minor version. A jar with a `+26.2` suffix will not load on 26.1.2.
3. When adding a mod, add the jar to `minecraft/mods/`, let Prism generate the `.index` entry by using the Mods page, then commit both.
4. When removing a mod, delete the jar and its `.index` entry, then check `config/` for leftover files and remove them if the pack should not keep defaults.
5. Fabric API, Sodium, Lithium, FerriteCore, and other performance mods should be updated together and retested. Sodium 0.9.x is a beta line and has had compatibility rough edges with Iris (see below).
6. After any update, launch a test world, check the mod list for missing dependencies, and read the log for warnings before committing.

Data pack and world version note: the pack does not ship a world or server. World generation mods (Biomes O' Plenty, TerraBlender, Dungeons and Taverns) affect new chunks only and should be treated as one way for existing worlds.

## 10. Git and LFS Workflow

This repository stores large binaries with Git LFS.

`.gitattributes`:

```
*.jar filter=lfs diff=lfs merge=lfs -text
*.zip filter=lfs diff=lfs merge=lfs -text
*.png filter=lfs diff=lfs merge=lfs -text
```

Set up once per machine:

```
git lfs install
```

Clone and fetch binaries:

```
git clone https://github.com/D5-Interactive/binSEC.git
git lfs pull
```

Confirm which files are LFS tracked:

```
git lfs ls-files
```

If you add a new binary type, for example `.mrpack` or `.ogg`, add a matching line to `.gitattributes` first with `git lfs track "*.ext"`, then add the file, then commit both `.gitattributes` and the file.

If any jar or zip appears as a small text file after cloning, LFS did not run. Fix it with `git lfs install` and `git lfs pull`.

Do not commit anything matched by `.gitignore`. If you need a personal change to a tracked file without shipping it, use `git update-index --skip-worktree <path>` and remember to undo it with `--no-skip-worktree` before pulling.

## 11. Known Gaps and Notes

- Iris is missing. The pack has four shader packs and an `iris.properties` file, but no `iris-fabric` jar, so no shader can be selected or loaded. The compatible line for 26.1.2 is Iris 1.11.x (`iris-fabric-1.11.3_mc26.1.2.jar` and similar). Be careful: Sodium 0.9.2-beta.1 and certain Iris 1.11.x builds had a known mixin compatibility conflict on 26.1.2 and 26.2. Add Iris, then test thoroughly, and if it fails, either downgrade Sodium to the 0.8.12 release line or use the Iris build that matches Sodium 0.9.2-beta.1.
- EMF and ETF are missing. FreshAnimations needs Entity Model Features and Entity Texture Features. Add both for the resource pack to animate.
- Packet Fixer is set to `allSizesUnlimited=true`. This can cause disconnects on servers that do not run Packet Fixer with comparable limits.
- WaylandCraft only does something on Linux Wayland. Its config folder is ignored by Git.
- Essential communicates with an external account service. If the pack should avoid that, remove it and retest.
- No server pack or `server.properties` is included. Server side options live in the `*-server` config files listed above.

## 12. Troubleshooting

Where to look:

- Crash reports and logs are under `minecraft/logs/` and `minecraft/crash-reports/`. Both are ignored by Git. Crash Assistant also produces readable summaries and can point at the offending mod.
- `minecraft/.mixin.out/` holds mixin output and is ignored.
- `hs_err_pid*.log` files appear on hard JVM crashes and are ignored.

Common problems:

- Game does not start, wrong Java: ensure Java 25 is available and `AutomaticJava=true`, or point Prism at a Java 25 install.
- Out of memory or stutter: adjust `MaxMemAlloc` as described in section 4. Do not set it higher than 50 to 70 percent of system RAM.
- Missing dependency at launch: a mod was removed or a required library is absent. Read the Fabric Loader error; it names the missing mod and version.
- Shaders will not enable: Iris is not installed (section 11).
- Resource pack animations do not work: EMF and ETF are not installed (section 11).
- Kicked for large packets on a server: Packet Fixer limits, see section 11.
- Voice chat does not connect: UDP port 24454 must be reachable. Check `max_voice_distance` and the server voice config.
- Config change had no effect: some configs are read only at startup. Close and relaunch the game.
- World generation changes only affect new chunks. Start a fresh world to test generation changes.

Reset a single mod: delete its file or folder under `minecraft/config`, relaunch, and let the game regenerate defaults.

## 13. Full Mod List

66 mod jars, grouped by role.

Performance and fixes:
Sodium, EntityCulling, ImmediatelyFast, Dynamic FPS, BadOptimizations, FerriteCore, Lithium, Particle Core, Debugify, Fast IP Ping, Packet Fixer.

Interface and HUD:
Jade, JEI, AppleSkin, Dynamic Crosshair, Chat Heads, Enchantment Descriptions, Mod Menu, Controlling, Searchables, Mouse Tweaks, More Chat History, Zoomify, CreativeCore.

Combat, camera, and animation:
Better Combat, Player Animation Library, First Person Model, Do a Barrel Roll, Not Enough Animations, Traveler's Backpack, Comforts, Carry On, dummmmmmy, AttributeFix.

World generation:
Biomes O' Plenty, TerraBlender, GlitchCore, Dungeons and Taverns, and the nine Macaw's mods.

Content:
CC: Tweaked, Immersive Paintings, AmbientSounds, Essential.

Audio and voice:
Sound Physics Remastered, Simple Voice Chat.

Networking:
e4mc, No Chat Reports, WaylandCraft.

Libraries:
Fabric API, Fabric Language Kotlin, Cloth Config, YACL, Fzzy Config, Forge Config API Port, Moonlight Lib, Cicada Lib, Placeholder API, Cardinal Components API, Prickle, Transition, Trender.

## License and Credits

This repository only packages third party mods and resource packs. Each mod and pack keeps its own license and belongs to its respective author. Do not redistribute paid or restricted content. When adding content, check its license allows inclusion in a public repository.
