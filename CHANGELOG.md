# Kyoryokuna Plates - Changelog

Copyright (c) 2026 Pragas. All Rights Reserved.

Versions follow MAJOR.MINOR.PATCH:

- **PATCH**: bug fixes only;
- **MINOR**: new features or options;
- **MAJOR**: big changes, e.g. ones that need setting the addon up again.

## 1.15.1

- Fixed: the healer mana bar of a name-only ally, set to follow the name, was shorter than the name. The name is drawn at the nameplate's scale and the bar at its own (it keeps its size when the ally is selected); the name's width is now turned into the bar's scale, so both are just as wide on screen.

## 1.15.0

- Enemies page, Threat: "Threat glow height", the height of the game's orange threat glow above the health bar, from 20% to 100% of the game's own (100% by default, as before). The glow stays the game's (its art, animation and scale): the addon only sets the height of its three parts (the flare, its brighter copy and the mask), from the game's height seen first, so a reused nameplate is never lowered twice. Only enemies.
- Test mode: a new "Threat" example on the Enemies page, with the game's glow drawn like the game's, at the height asked; shown while the threat glow is on.

## 1.14.0

- New default color of casts that can be interrupted: the game's own (its classic cast bar yellow, R 1, G 0.7, B 0), was a green. Colors already saved don't change: the "Default" button beside the color gives the new one.

- Fixed: with the test mode open, closing the options first left the test mode on the screen, and it could fail to close. Closing the options now closes the test mode too, and the test mode's X simply hides it (the game's close button goes through the game's panel system, which can refuse).
- The test mode's X has the same look as the options window's.

## 1.13.0

- Options window: a button beside the X (a minus) shrinks the window to its title bar, so what's on the screen (e.g. the test mode's examples) can be seen and dragged; the same button (now a plus) brings it back as it was. The title bar stays where it is, and can still be dragged. The window always opens whole. It keeps its width: only its height shrinks.
- Options window: the X has the same new look as the minimize button beside it, a small dark square with a gold sign.

## 1.12.0

- Enemies page, My debuffs: "Time left color" and "Time left size", the color and size of the seconds left on each of your debuffs (red and 12 by default, as before; any color, e.g. white; size 6 to 24). They follow at once, in the test mode too.

## 1.11.2

- The message asking to restart the game after an update (1.11.1) didn't show: it was written at login, while the game was still making its interface, and got lost. It now shows 5 seconds after the world appears, like the update message.

## 1.11.1

- After an update that adds files, a /reload no longer gives errors. The game reads the addon's list of files only when it starts, so a /reload leaves the new ones out; the addon now notices it (the version the game read isn't the code's), stays off (no events, nothing runs, settings untouched) and says to close the game and open it again, in the chat and in a window, in the player's language. /kp and the addon's entry in the game's addon button say it too.

## 1.11.0

- New defaults, from the author's own setup, so a new install starts with that look (settings already saved never change; the "Default" buttons of colors now give the new colors):
  - Enemies: bar 150 x 20 (was 144 x 15), name and health percent 110%, level inside the bar on the left at 90% (was outside on the right at 100%), "My crowd control first" on, debuff icons 25 at 20 above the bar (was 26 at 18).
  - Cast bar: no spell icon; "Can't be interrupted" in a grey green (was a dark red).
  - Allies: name 120% (was 100%), 10 above the head (was 30).
  - Raid marks: on enemies on the right (was above the name); 35 for enemies and allies (was 20).
  - Target size 115% (was 125%).
  - The language (English) and the minimap button stay as they were: they're each player's own.

## 1.10.0

- Enemies page, new "Elites, rares and bosses" section:
  - Their border fades from black on the left to a color of their own: gold for elites, silver for rares and rare elites, white for bosses (world bosses and the game's boss mobs). Each color can be changed, and the fade can be turned off. Also on the cast bar joined to the health bar. Your target always keeps the target's border, whole; enemy players never fade. When the game hides what kind of mob it is, the border stays black.
  - "Show the elite and rare dragon": hidden, it takes no room (the raid mark no longer goes past it).
  - "Show the skull": the skull the game shows instead of the level of bosses and of mobs far above you; hidden, they show no level.
- Test mode: a rare example, with the silver dragon.
- Border thickness, from 1 (default, as before) to 5 screen pixels: "Border thickness" on the Enemies page and "Border thickness of the target" on the Target page, each its own. The cast bar joined to the health bar sits under the whole bottom border and has a border just as thick, and the name of the enemy's target keeps its distance below. Allies with a health bar keep one pixel.
- Fixed: in the test mode, the bottom line of the border could be missing on a whole row of examples (e.g. the boss). Its examples sat half way into a screen pixel, where the game may round a one-pixel line away; the rows, the scroll and the examples now sit on whole pixels. The health bar of real nameplates is also held on whole pixels from the nameplate's bottom.

## 1.9.0

- A welcome window over the options: the first time the addon is opened (what it is, how to start), and after each update (what's new and what was fixed in every version since the last one seen), with the known issues (limits of the game itself) under it. Its OK shows the General page, and it doesn't come back until the next version. The About page has a "See what's new" button to show it again.
- After an update, a message in the chat a few seconds after logging in says so and how to see what's new (on the first install, how to open the options).
- The notes for the window are short texts written for the player (Core\ReleaseNotes.lua), in English and Portuguese; a test checks that the version of the TOC has its notes.

## 1.8.0

- New "Import / Export" page:
  - Export: a code (one line of text) with all your settings, to copy (Ctrl+C) and share. Your language, the minimap button and the error messages stay out.
  - Import: paste a code (Ctrl+V) and confirm. The code is only read as text, never run: only settings that exist, of the right kind, are taken, and their limits still apply; settings it doesn't have keep their value.
  - Backups: a button to save a copy of all your settings, with a name of your own if you like, and the list of copies (date, name and version) with Edit (to name or rename it), Restore and Delete, the last two asking first. The last 10 are kept, and one is made by itself before an import or a restore, so those can be undone too.

- Enemies page, "My debuffs": a position for the row of icons over the health bar: from its left end (default, as before) or ending at its right end (growing left). The test mode shows it too. A centered row isn't possible: the game's row only grows from one end, and in combat the game hides from addons how many debuffs there are.
- Enemies page, "My debuffs":
  - Every icon now has a black border of 2 pixels (it was 1, and hardly showed on the nameplate).
  - "My crowd control first": your stuns, roots, fears, sleeps and other controls (what the game counts as crowd control) come first in the row.
  - With it, "Crowd control border in its own color" (on by default, green) and its color. The game hides from addons which aura an icon shows, so crowd control can only be told apart when it has a group of its own, first in the row.
- Cast Bar page, new "Spell" section:
  - Spell icon: shown or hidden, its position (inside the left end, as before, or the right end) and its size.
  - Spell name: shown or hidden (new), its position (left, middle as before, or right) and its size. On the side of the icon it starts after the icon; at an end, a long name is cut before the other end instead of overflowing.
- Target page: "Arrow position": on the top edge of the health bar (as before, pointing down), or on its left edge, its right edge or both, pointing at the bar; always half inside and half outside it. On the sides, "Left / right" moves the arrows away from the bar (or into it), each to its own side, and "Down / up" moves them up or down.
- Options: the pages in a new order: General, Allies, Enemies, Target, Cast Bar, Raid Marks, Import / Export, About.
- Options: a clearer layout on every page. Each section starts well apart from the one before (the headers were almost touching the option above them), and checks, colors, sliders and lists have even room between them.
- Options: the mouse wheel no longer changes the sliders. Over a slider it scrolls the page, so scrolling down the options never changes a setting by accident. Drag the slider, or right-click it to type the value.

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
