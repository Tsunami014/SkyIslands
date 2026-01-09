# Tag properties
The tag properties will be performed on the new item in order.

If one property sets something no other property will set it (unless stated). This means e.g. `all` followed by `set` will only `set` if `all` failed.

Properties are sorted by their place in this dict, and items will be sorted by their 'interest' tag.

Every tag also has the property where if there is only one item to be combined, use the properties of that first unless overridden.

## Display stuff
### Names
- `prefix`: The property value will be prefixed onto the name at order 1. Higher numbers appear first, and the regular name is at order 0.
- `prefix=<num>`: Prefixed at order `<num>`
- `displ`: This property value will be set to one that is more fancy (that being it Capitalises The String) (overrides previous)
### Pic
- `tint`: The property value index into the `colours` dict at the bottom will slightly tint the image
- `addTile`: The property value will be added onto the start of the tile name when looking for the tile name in the dict below
    - If no matching tile is found, it will recursively try to remove properties that added extra tile stuff until it reaches one that works.

## Transferring stuff
- `all`: The property will be set to the most used value if every combining thing has either that value or is unset, otherwise it will be unset.
- `interest`: The most interesting item's value will be used (recursively down if not set)
- `combine`: All the property values from each sorted by interest will be stacked on each other, separated by a space
- `set=<value>`: The property value when combined will be `"<value>"` (string) (if unset)
    - `setn=<value>`: Set, but set to this number (not string)

## Special tags
These are always present in every item
- `interest` is used to sort items
- `name` is the editor name (without attachments from other tags)
- `nameTags` are the name extensions given by other tags
- `tile` is the tile (again, without attachments)
- `tileTags` is the same as `nameTags` but for `tile`

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
