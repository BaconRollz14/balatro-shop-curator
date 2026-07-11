# Shop Curator

Shop Curator is a Balatro mod for Steamodded that adds an in-game config menu for choosing which shop cards, vouchers, and booster packs are allowed to appear during a run.

The mod keeps Balatro's normal shop randomness, but filters out anything you have turned off.

## Features

- In-game config menu through the Steamodded Mods screen
- Toggle individual shop cards on or off
- Toggle vouchers and booster packs on or off
- Bulk controls for the visible category with `All On` and `All Off`
- Joker categories split by rarity:
  - Common Jokers
  - Uncommon Jokers
  - Rare Jokers
  - Legendary Jokers
  - Other Jokers
- Separate categories for Tarot, Planet, Spectral, Vouchers, and Boosters
- Two-column paged list for easier browsing
- Hover tooltips for card descriptions when localization data is available

## Requirements

- Balatro
- Lovely
- Steamodded

## Installation

1. Install Lovely and Steamodded for Balatro. https://github.com/Steamodded/smods/wiki/Installing-Steamodded-windows
2. Download this repository.
3. Copy the `ShopCurator` folder into your Balatro Mods folder:

```text
%AppData%/Balatro/Mods
```

Your final folder should look like:

```text
%AppData%/Balatro/Mods/ShopCurator/ShopCurator.json
%AppData%/Balatro/Mods/ShopCurator/main.lua
%AppData%/Balatro/Mods/ShopCurator/config.lua
```

4. Launch Balatro.
5. Open `Mods`.
6. Select `Shop Curator`.
7. Open the `Config` tab.

## Usage

Use the category arrows to switch between item groups.

Use the page arrows to browse through each group.

Each item has an `On` or `Off` button:

- `On` means the item is allowed to appear.
- `Off` means the item is filtered out of the shop or pack pool.

The `All On` and `All Off` buttons apply to the currently visible category, not every category at once.

## What It Affects

Shop Curator can filter:

- Normal shop Joker, Tarot, Planet, and Spectral card generation
- Buffoon pack Joker generation
- Arcana pack Tarot generation
- Celestial pack Planet generation
- Spectral pack generation
- Voucher selection
- Booster pack selection

The mod is designed to affect shop and booster-pack availability, not every card-generating effect in the game.

## Fallback Behavior

Balatro expects some generated pools to always produce a valid item. If every possible item for a required generated type is turned `Off`, the game may use a last-resort default instead of leaving the shop or pack empty.

For best results, leave at least one item enabled in each category you expect the game to generate.

## Version

Current version: `0.4.0`

## Author

BaconRollz
