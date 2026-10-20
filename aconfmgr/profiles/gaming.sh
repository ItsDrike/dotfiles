###############################################################################
# Game clients / Launchers
###############################################################################

AddPackage steam

# Launcher and library manager for Epic Games Store, GOG, and Amazon Games.
# AddPackage heroic-games-launcher

# General game manager with runners and integrations for stores such as EA,
# Epic, GOG, Steam, and Ubisoft Connect.
# AddPackage lutris

# Lightweight launcher for standalone Windows and native games, using UMU and
# Proton with prefix management and optional Steam shortcuts.
# AddPackage faugus-launcher

###############################################################################
# Windows compatibility tools / resources
###############################################################################

# CachyOS's Steam Linux Runtime build of Proton. Based on Proton's
# bleeding-edge branch, and contains various extra CachyOS patches /
# modifications.
AddPackage proton-cachyos-slr

# Unified launcher for running Windows games with Proton and Protonfixes
# outside of Steam. It provides the `umu-run` CLI command, which other GUI
# launchers often use it without needing to bundle their own compatibility
# runtime.
AddPackage umu-launcher

# CachyOS's gaming-focused Wine build. The `-opt` package installs under a
# separate location, letting it coexist with the standard Wine required by
# Winetricks.
AddPackage wine-cachyos-opt

# Metric-compatible substitutes for common Microsoft fonts used by Windows
# games and launchers.
AddPackage ttf-liberation

# GUI tool to install various Proton versions easily, supports GE-Proton,
# Luxtorpeda & more for Steam, Lutris and Heroid
AddPackage protonup-qt

###############################################################################
# Debugging / Troubleshooting / Compatibility tools
###############################################################################

# Installs Windows redistributables, fonts, DLL overrides, and registry tweaks
# in a regular Wine prefix.
AddPackage winetricks

# Applies Winetricks verbs and other common fixes to a selected Steam Proton
# prefix. It depends on Winetricks, which is also declared above for direct use.
AddPackage protontricks

# Provides `vulkaninfo` and `vkcube` for validating installed Vulkan drivers.
AddPackage vulkan-tools

###############################################################################
# Audio compatibility
###############################################################################

# Extra ALSA plugins for native games and the 32-bit compatibility equivalent
# for older games and Windows compatibility layers.
AddPackage alsa-plugins
AddPackage lib32-alsa-plugins

# Cross-platform positional-audio implementation used by many native games.
AddPackage openal

###############################################################################
# Game presentation / performance
###############################################################################

# Optional per-game compositor for fullscreen, scaling, frame pacing, and
# resolution-related use cases. It is not configured globally.
AddPackage gamescope

# Temporarily applies game-oriented scheduling and performance settings when a
# game is launched through `gamemoderun`.
# AddPackage gamemode

###############################################################################
# Monitoring / Overlay configuration
###############################################################################

# Vulkan/OpenGL performance overlay. Keep the 32-bit library for older games.
AddPackage mangohud
AddPackage lib32-mangohud

# Graphical editor for MangoHud and other Vulkan/OpenGL overlay settings.
AddPackage goverlay
