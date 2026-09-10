# Ashenlight: Echoes Below — Game Plan

## Direction

An entirely original Godot 4 2D action-platformer prototype. The title, characters, world, story direction, enemies, locations, art language, and gameplay content are independently created for this project and are not copied from another game or creator. The project focuses on atmospheric pixel-art presentation, character-driven exploration, responsive movement, and readable melee combat.

## Risk Tasks

### 1. Movement and combat state handoff
- **Why isolated:** Jumping, landing, turning, and the short attack window must feel responsive without allowing repeated hits every frame.
- **Approach:** Keep movement in `CharacterBody2D`, use acceleration/friction, coyote-free floor checks, and a single attack window with one hit gate.
- **Verify:** A/D changes facing and velocity, SPACE jumps from platforms, J starts exactly one swing, and a nearby enemy is damaged at most once per swing.

### 2. Camera-like parallax presentation
- **Why isolated:** The prototype draws a large world into one viewport, so background layers need to shift at different rates while the gameplay remains readable.
- **Approach:** Track the player with a smoothed offset and apply different offset multipliers to ruins, mountains, and the altar.
- **Verify:** Moving from left to right visibly changes the layered background position without moving the HUD or clipping the player.

## Main Build

- **Assets needed:** Procedurally drawn original pixel-inspired silhouettes, dusk background layers, ruins, platforms, a glowing altar, player, and enemy. This prototype intentionally avoids external art dependencies so it can run immediately after cloning.
- **Gameplay:** Explore a compact ruined chamber, defeat two wandering shades, collect soul sparks, and interact with the altar using E to restore health and reset soul energy.
- **Verify:**
  - Movement, jumping, collision, melee, enemy defeat, soul count, and altar interaction all work.
  - HUD remains readable and does not overlap the gameplay controls.
  - No missing textures or external asset paths.
  - The visual language is coherent: deep violet palette, warm soul-light accents, silhouettes, and ruin motifs.
  - No parser errors when opened in Godot 4.
