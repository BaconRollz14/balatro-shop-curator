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
- Green `On` and red `Off` buttons, so you can see at a glance what is allowed
- Three preset slots to save and load your favourite set-ups, plus four ready-made presets
- Hover tooltips with each card's real description, including its numbers

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

- `On` (green) means the item is allowed to appear.
- `Off` (red) means the item is filtered out of the shop or pack pool.
- Grey buttons mean that whole group (Shop cards, Vouchers or Boosters) is switched off at the top, so your choices are saved but not currently applied.

The `All On` and `All Off` buttons apply to the currently visible category, not every category at once.

### Presets

Use the `Preset` arrows to pick slot 1, 2 or 3, or one of the ready-made presets.

- `Save` stores every category's On/Off choices in that slot, replacing whatever was there.
- `Load` replaces your current choices with the ones saved in that slot.

The slot label shows how many items that preset turns off.

Ready-made presets can be loaded but not saved over:

- `Everything On`: turns every item back on.
- `No Commons`: turns off all Common Jokers.
- `Rare & Legendary`: turns off all Common and Uncommon Jokers.
- `Legendary Party`: turns off all Common, Uncommon and Rare Jokers, so only Legendaries (and any modded rarities) appear.

Loading a ready-made preset replaces your current choices in every category.

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

## Joker Odds

While the mod is enabled and `Shop cards` is `On`, shop and Buffoon pack Jokers are picked from one combined pool of every enabled Joker. Each enabled Joker has the same chance of appearing, whatever its rarity. For example, with 1 Uncommon and 99 Rare Jokers enabled, each one has a 1 in 100 chance.

This replaces Balatro's normal rarity odds (roughly 70% Common, 25% Uncommon, 5% Rare), so Rare Jokers turn up more often than usual. Legendary Jokers are included in the pool too, so they can appear in the shop and Buffoon packs. Turn them `Off` in the Legendary Jokers category to keep them out.

## Fallback Behavior

Balatro expects some generated pools to always produce a valid item. If every possible item for a required generated type is turned `Off`, the game may use a last-resort default instead of leaving the shop or pack empty.

For best results, leave at least one item enabled in each category you expect the game to generate.

## Version

Current version: `0.5.1`

## Author

BaconRollz
