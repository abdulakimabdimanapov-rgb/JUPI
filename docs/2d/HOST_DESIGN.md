# HOST DESIGN

This document explains how the parasite host system works.

## Host states

```
FREE   host = NONE   — plain bio-mass, standard body radius 5.0
HOSTED host = MOUSE / RAT / CAT
```

Absorption flow: `ANIMAL → ABSORB → BIO TRANSITION → HOST FORM`.
Each absorption replaces the previous host (one body — one host).

## Lethal damage while hosted

Two options were possible:

- A) HOST LOST → JUSUP FREE (survive without host)
- B) DEAD → RESPAWN (full death)

**Chosen: B — full death + respawn as FREE.**

Reasons:
1. There is exactly one player body with one HP pool; splitting "parasite HP"
   vs "host HP" would add a second damage pipeline for no gameplay gain yet.
2. The existing death/respawn loop already gives failure stakes; losing the host on top of it
   would be invisible during death anyway.
3. Losing the host on respawn keeps ability economy honest: abilities are
   body-based, the body is rebuilt clean at the safe point.

Result: `RESPAWN → host = NONE`, abilities reset, appearance back to FREE form.

## Body-based abilities (not numeric buffs)

| Host | Ability | Body mechanism |
|------|---------|----------------|
| MOUSE | SMALL BODY | collision radius shrinks to 3.5 px — fits the 8 px grove squeeze |
| RAT | VENT DASH | dash burst + only RAT fits the escape vent (Area gate) |
| CAT | SILENT PAWS | detection radius halved (scientist vision check) |

## Appearance

One art set per state:
`jusup` / `jusup_mouse_host` / `jusup_rat_host` / `jusup_cat_host`.
Rule: **host silhouette + host features + parasite mass + recognizable core +
tendrils** — never a plain animal.

Transformation on absorb: collapse → silhouette swap → overshoot settle;
core flashes but never disappears.

Per-host animation profiles differ by FPS multiplier:
mouse twitchy ×1.35, rat heavy ×0.85, cat smooth ×1.1.
Movement speed also differs per host.

## World

Hand-designed 80×80, modular zones painted in fixed order:
FOREST (NW) · MEADOW · LAKE (SE) · ROAD · LABORATORY (NE) · OUTSKIRTS ring.
Border = solid rock ring (collision) + dense treeline behind it + a hard
position clamp as a last resort. No invisible fence visuals.
