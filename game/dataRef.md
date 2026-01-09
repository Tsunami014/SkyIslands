# Tag properties
The tag properties will be performed on the new item in order.

If one property sets something no other property will set it (unless stated). This means e.g. `all` followed by `set` will only `set` if `all` failed.

In general, items are sorted based on their `priority` tag.

## Display stuff
### Names
- `prefix`: The property value will be prefixed onto the name at order 1. Higher numbers appear first, and the regular name is at order 0.
- `prefix=<num>`: Prefixed at order `<num>`
### Pic
- `tint`: The property value index into the `colours` dict at the bottom will slightly tint the image
- `addTile`: The property value will be added onto the tile name when looking for images

## Transferring stuff
- `all`: The property will be set to the most used value if every combining thing has either that value or is unset, otherwise it will be unset.

# Recipes
Lists some unique combinations of things

# Items
Lists all the items that can be found in the world naturally.

If the item is type 'combined', it will be replaced with the combination of the listed items so as to not repeat myself when defining stuff.

# Tiles
Maps tile names to their coordinates on the item grid.

Tile names are separated by space and contain 

# Colours
Colours used for the various tags
