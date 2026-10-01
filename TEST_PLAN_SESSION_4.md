# Test Plan: Session 4 - Gameplay Verification

**Date:** 2026-10-01  
**Objective:** Verify all core gameplay systems work together: movement, audio, spike hazards, and level transitions.

---

## Critical Fix Applied
✅ **HurtboxComponent now adds itself to "hurtbox" group** — this enables spike collision detection to work properly.

---

## Test Sequence

### Phase 1: Level 1 Gameplay (5-10 min)

#### Setup
1. Open `scenes/level_1.tscn` in Godot editor
2. Click **Play Scene** (F6) or **Play** button
3. Player should spawn at position **(80, 300)** on the ground

#### Movement & Jump
- [ ] **Press A/D** — player moves left/right
- [ ] **Press SPACE** — player jumps
  - **Audio Check:** Jump sound plays (Jump1.wav)
  - **Physics Check:** Player lands smoothly back on ground
- [ ] **Press SPACE + A/D mid-air** — directional air movement works
- [ ] **Try moving to spike at x=300** — should be reachable

#### Spike Interaction (CRITICAL)
1. **Move player into Spike1 at position (300, 290)**
   - [ ] **Audio:** Damage sound plays (Hit_Hurt.wav)
   - [ ] **Visual:** Player sprite plays hurt animation (flashes briefly)
   - [ ] **Physics:** Player gets knocked backward (knockback applied)
   - [ ] **Health:** HUD health bar decreases by 50 HP
   
2. **Move into Spike2 at position (500, 290)**
   - [ ] Same as Spike1 (damage, audio, knockback, health decrease)

3. **Let player health reach 0**
   - [ ] Player plays death animation
   - [ ] Player respawns OR level resets (verify current behavior)

#### Attack
- [ ] **Press E** — player attacks
  - **Audio Check:** Attack sound plays (Laser_Shoot.wav)
  - **Visual Check:** Attack animation plays

#### Level Transition
- [ ] **Move player to goal zone** (rightmost area, look for visual marker)
  - **Expected:** Level transitions to level_2, player appears at new spawn
  - **Audio:** No sound should cut off abruptly

---

### Phase 2: Level 2 Verification (3-5 min)

#### Setup
1. After transitioning from level_1, player should be in level_2
2. Player spawn position should be **(64, 300)**

#### Spike Count Check
- [ ] Level_2 has **3 spike instances** (visible in scene)
- [ ] All spikes are wooden spike texture (same asset as level_1)

#### Quick Damage Test
1. **Move to one spike** — verify damage/audio/knockback works (same as level_1)
2. **Can attack enemies** (if any present)

---

### Phase 3: Audio Timing Check (All Phases)

For each audio event, verify:
- [ ] Sound starts at the right moment (no delay, not cut off mid-sound)
- [ ] Sound volume is appropriate (not too loud, not too quiet)
- [ ] Sound doesn't overlap or conflict with other sounds

| Event | File | Check |
|-------|------|-------|
| Jump | Jump1.wav | Plays on successful jump |
| Attack | Laser_Shoot.wav | Plays when E pressed |
| Spike Hit | Hit_Hurt.wav | Plays on spike contact + player damage |

---

## Expected Results

### ✅ Pass Criteria
- Player can move, jump, attack without crashes
- All three audio files play at appropriate times
- Spike contact triggers damage (50 HP), knockback, and audio
- Health decreases and HUD updates
- Level transitions work smoothly
- No console errors or warnings

### ⚠️ Known Limitations (Not Test Failures)
- No particle effects on spike hit yet
- No screen shake on impact
- No spike respawn logic (player dies at fall_death_y=560)
- Enemy hurt sounds not implemented
- TileSet physics bypassed (using StaticBody2D workaround)

---

## Debugging Notes

If a test fails, check:

1. **Spike damage not triggering?**
   - Verify collision layers: Player hurtbox = layer 1, Spike = layer 4 with mask 1
   - Check wooden_spike.gd is attached to spike instances
   - Verify hurtbox group assignment (should be in "hurtbox" group now)

2. **Audio not playing?**
   - Check AudioStreamPlayer nodes exist in player.tscn
   - Verify audio file paths in inspector
   - Check Master audio bus isn't muted

3. **Level transition stuck?**
   - Check TransitionManager exists and is properly configured
   - Verify goal zone collision is set up

4. **Player falls through ground?**
   - Verify StaticBody2D GroundCollider exists in level
   - Check collision_layer=2, collision_mask set correctly

---

## Post-Test Actions

After verification:
1. **If all pass:** Update handoff.md and proceed to visual tile layout polish
2. **If failures:** Document issue, fix root cause, re-test affected system
3. **Commit verification:** Add a commit note confirming all systems tested

