# Pokémon Red and Blue - Enhancement Patches

This is a fork of the Pokémon Red and Blue disassembly which adds some optional
enhancement patches.

Current enhancements available:

* Increase walking speed (always, or only while holding B)
* Use Cut/Surf/Strength directly from the overworld
* Allow more precise control over text delay (0 to 7 frames per letter, with
  option to make 0 the default)
* Disable low health alarm, or make it beep only a few times and then stop
* Improvements to battle screen:
  * Show selected move's type, power, accuracy and PP
  * Show an indicator on the enemy HUD when you've already caught that species
  * Show status (PSN/SLP/etc) next to level instead of replacing it
* Allow checking your Pokémon's stats from the "choose a Pokémon" menu in battle
  at all times (normally this option isn't shown if choosing a Pokémon after
  yours or an opponent's has fainted)
* Press left/right to adjust quantity by 10 when buying, selling or tossing
  items
* When buying items, show how many you already have
* Debugging functions (debug menu, walk through walls, no random battles)
* Skip intro (boot directly to title screen)

Planned enhancements:

* Register items to Select button
* Notify when PC box is (nearly) full, and/or allow to change it from anywhere
* Show descriptions of items and moves
* Ability to sort items automatically
* Various menu improvements and bug fixes
* Who knows?

These patches can be toggled on/off by editing `hacks.asm`. With all patches
disabled, the ROM builds identical to the original.

# Screenshots

![enhanced-battle-screen.png](hacks/screenshots/enhanced-battle-screen.png?raw=true "Enhanced battle screen")
![debug-menu.png](hacks/screenshots/debug-menu.png?raw=true "New debug menu")
![enhanced-mart.png](hacks/screenshots/enhanced-mart.png?raw=true "Enhanced shop menu")
![options-text-speed.png](hacks/screenshots/options-text-speed.png?raw=true "Text speed options")

Original readme follows...


# Pokémon Red and Blue

This is a disassembly of Pokémon Red and Blue.

It builds the following roms:

* Pokemon Red (UE) [S][!].gb  `md5: 3d45c1ee9abd5738df46d2bdda8b57dc`
* Pokemon Blue (UE) [S][!].gb `md5: 50927e843568814f7ed45ec4f944bd8b`

To set up the repository, see [**INSTALL.md**](INSTALL.md).


## See also

* Disassembly of [**Pokémon Crystal**][pokecrystal]
* irc: **irc.freenode.net** [**#pret**][irc]

[pokecrystal]: https://github.com/kanzure/pokecrystal
[irc]: https://kiwiirc.com/client/irc.freenode.net/?#pret
