# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

"Crash Cab" is a 2D arcade-style taxi game built with **Godot 4.4**. The player controls a taxi to pick up passengers and deliver them to drop-off zones within a time limit.

## Architecture

### Core Game Systems

- **Main Scene** (`Scenes/main.tscn` + `Scripts/main.gd`): Main game loop with 60-second countdown timer and score tracking
- **Player Car** (`Scenes/car.tscn` + `Scripts/car.gd`): RigidBody2D-based car with realistic physics, passenger pickup/dropoff mechanics
- **Score Management** (`Scripts/ScoreManager.gd`): Autoloaded singleton for global score tracking across scenes
- **Passenger System** (`Scripts/passenger.gd`): CharacterBody2D entities that can be picked up by the car
- **AI Cars** (`Scripts/AICar.gd`): Simple path-following AI vehicles for traffic simulation

### Input Controls
- **Movement**: WASD or Arrow Keys
- **Pickup**: Key "1" to pick up passengers when nearby

### Scene Structure
- `Scenes/` - All .tscn scene files
- `Scripts/` - All .gd GDScript files  
- `Assets/` - Game sprites and images
- `People/` - Character sprite assets
- `Fonts/` - Font files

## Development Commands

### Running the Game
- Open project in Godot Editor and press F5 to run
- Main scene is configured as `Scenes/main.tscn`

### Export/Build
- Web export configured in `export_presets.cfg` for HTML5 builds
- Export path: `../../Builds/Nico/index.html`

## Key Implementation Details

### Car Physics (`Scripts/car.gd`)
- Uses RigidBody2D with custom physics simulation
- Implements drift mechanics via `drift_factor` parameter
- Sprite direction updates based on velocity vector
- Passenger state tracking with `has_passenger` boolean

### Timer System (`Scripts/main.gd`)
- 60-second countdown using Godot Timer node
- Game ends by transitioning to `DeathScreen.tscn` when time expires
- Timer updates every second via `_on_timer_timeout()`

### Score System (`Scripts/ScoreManager.gd`)
- Singleton autoload for persistent score tracking
- Emits `score_changed` signal for UI updates
- Score resets are handled explicitly in main scene

### Passenger Mechanics
- Area2D detection for pickup range
- Car proximity tracked via `can_pickup_passenger` flag
- Passengers are `queue_free()`d after pickup

## Scene Dependencies
- Main menu transitions to main game scene
- Death screen shows after timer expires
- All scenes use the global ScoreManager singleton