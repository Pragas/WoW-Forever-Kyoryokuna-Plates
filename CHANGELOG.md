# Kyoryokuna Plates - Changelog

Copyright (c) 2026 Pragas. All Rights Reserved.

Versions follow MAJOR.MINOR.PATCH:

- **PATCH**: bug fixes only;
- **MINOR**: new features or options;
- **MAJOR**: big changes, e.g. ones that need setting the addon up again.

## 1.7.0

- Raid Marks page: a size for the raid mark, for enemies and allies apart (default 20, as before). Like the nameplate, the mark is bigger on your target. Inside dungeons and raids the allies' marks keep the game's size.
- Removed: the size of the allies' names inside dungeons, raids and scenarios (1.6.0). It changed the game's shared fonts of nameplate names, which didn't size the allies' names there and also reached other protected nameplates (huge NPC and totem names, players' names drawn as dots). Inside, the allies' names have the game's size again.
- Fixed: a mob's name could be much smaller than the others. The game reuses nameplates, and when it gave the name another font while the nameplate had no unit, the addon missed it: the next unit (e.g. a mob) kept the font of the last one (e.g. the smaller one of a friendly NPC). The addon now also checks, on every update, whether the name still has the font it gave it, and reads the game's again when it doesn't.

## 1.6.0

- New "Raid Marks" page: where the raid mark shows, for enemies and allies apart: left of the health bar, above the name (as before) or right of the health bar. Left and right go past whatever else is shown on that side (the level or the health percent outside the bar, the quest "!", the elite dragon, the role icon), and beside the name when only the name shows. The test mode has examples for it. Inside dungeons and raids the game keeps the allies' marks where it puts them.
- Enemies: "Show the health percent", to hide the health percent like the level (on by default).
- Allies inside dungeons, raids and scenarios: their names now have the same size as outside (the "Name size" of the Allies page). The game protects those nameplates from addons, so their names kept the game's size, shrunk with the nameplate's scale. The addon now sets the size of the game's shared font of nameplate names while inside, and puts the game's own back when leaving.
- Fixed: the options window opened in combat couldn't be closed with its X. The X used the game's panel system, which the game blocks for addons in combat; it now simply hides the window.

## 1.5.2

- The width and height of the health bar and the cast bar are now rounded to whole screen pixels (measured again when a nameplate becomes the bigger target). Their top and bottom edges then always move together, so a moving bar can't grow or shrink by a pixel. The look stays the same, at most one pixel larger or smaller.

## 1.5.1

- Fixed: some names (e.g. an ally with a health bar) could be much smaller than the others. The addon kept the game's font of the first time it saw a nameplate; it now reads it again whenever the game changes it (a nameplate going from name only to a health bar, or reused for another unit).

## 1.5.0

- General page: "Stack enemy nameplates". Off (default), the nameplates of mobs close together overlap and the game keeps swapping which one is in front, so a bar can seem to jump up and down; on, the game pushes them apart so they never overlap.

## 1.4.3

- Fixed: the name of the enemy's target, under its health bar (or cast bar), could touch the bar's border and seem to jump while the nameplate moved. It now keeps a small gap below the border.

## 1.4.2

- Fixed: errors ("Attempt to access forbidden object") when changing the size of the debuff icons, as the game protects the icons it already made. The new size is applied by the game's own layout of the icons.

## 1.4.1

- General page: a "Delete recorded errors" button, which asks for confirmation first.
- Each recorded error now shows the version of the addon it happened in.

## 1.4.0

- Enemies: the game's threat glow above the health bar (a mob attacking you, or about to be pulled) and its flash when gaining or losing aggro are now turned on, with an option for each. The game has them off unless an addon turns them on.
- Fixed: an error ("Attempt to access forbidden object") when the raid mark checked an enemy's debuff icons, which the game protects.

## 1.3.4

- Enemies: the raid mark is now over the name too (above your debuffs when the enemy shows some), instead of left of the health bar.

## 1.3.3

- Fixed: allies with a health bar (name only off) had the healer mana bar over the health bar and the role icon beside the name. Now the mana bar sits right under the health bar and just as wide, and the role icon goes left or right of the health bar (or above the name).
- Allies: the raid mark is always over the name, also with a health bar (the game put it left of the bar).

## 1.3.2

- Fixed: in the test mode, the names of enemies could look much smaller than on real nameplates (they took the smaller font the game gives to allies).

## 1.3.1

- Color options: a "Default" button next to each color puts it back to its default.
- The default color of casts that can't be interrupted is now a dark red.

## 1.3.0

- Cast bar can be joined to the health bar (default: right under it, sharing its border) or kept apart with its own width, distance and horizontal position.
- Cast bar colors simplified to three: can be interrupted, my interrupt on cooldown, can't be interrupted. The "ready in time" color was removed: the game hides the cast and cooldown times from addons in combat.
- Option to hide the spell icon of the cast bar; the icon now fits inside the bar and the border is always whole.
- Level size option. The level now has the font and size of the name and, like the name, doesn't grow on the target.
- Health percent size option, separate from the name size; inside the bar it's never taller than the bar.
- Allies: name height option, to bring the name closer to the player's head.
- Target size moved to the Target page.
- Test mode: shows only the examples of the open options page, as cards with a title and a short description, and uses the real nameplate fonts.
- New logo.
- Fixed: the cast bar looked narrower than the target's health bar (it now has the same border).
- Fixed: the name of the enemy's target moved to the center while it cast.
- Fixed: the countdown of debuffs could be moved off center by cooldown text addons.

## 1.2.0

- Enemies: health bar width option.
- Enemies: health percent and level positions (inside the bar left, center or right, or outside left or right).
- Sliders: right-click to type a value.

## 1.1.0

- Test mode with example nameplates for every case (/kp test).
- Languages: English and Portuguese (Portugal).
- Minimap button and addon compartment entry.
- Error log (/kp errors) and diagnostics (/kp diag).

## 1.0.0

- First version: classic-style health bars with a pixel border, cast bars colored by your interrupt, the name of each enemy's target, your debuffs above the name, quest, elite and raid mark icons, name-only allies with role icons and healer mana bars, click-through allies, and options in the style of the game.
