# Tag properties
The tag properties will be performed on the new item in order.

If one property sets something no other property will set it (unless stated). This means e.g. `all` followed by `set` will only `set` if `all` failed.

Properties are sorted by their place in this dict, and items will be sorted by their 'interest' tag.

Every tag also has the property where if there is only one item to be combined, use the properties of that first unless overridden.

## Display stuff
### Names
- `prefix`: The property value at this point will be prefixed onto the start of the name if not blank
### Pic
- `tint`: The property value index into the `colours` dict at the bottom will slightly tint the image
- `addtile`: The property value will be added onto the start of the tile name when looking for the tile name in the dict below
    - If no matching tile is found, it will recursively try to remove properties that added extra tile stuff until it reaches one that works.

## Transferring stuff
- `all`: The property will be set to the most used value if every combining thing has either that value or is unset, otherwise it will be unset.
- `interest`: The most interesting item's value will be used (recursively down if not set)
- `combine`: All the property values from each sorted by interest will be stacked on each other, separated by a space
    - `combine=<args>`: Combine with some arguments separated by `,`, those being:
        - `override`: Override the existing name if not blank
        - `all`: Include the existing name (also applies `override`)
        - `dedup`: Remove duplicates
- `set=<value>`: The property value when combined will be `"<value>"` (string) (if unset)
    - `setn=<value>`: Set, but set to this number (not string)
- `add`: The property values will be converted to numbers and added together to get the final result (overrides existing) (only happens when more than 1 property value exists in the first place)

## Special tags
These are always present in every item
- `interest` is used to sort items
- `name` is the editor name (without attachments from other tags)
- `realname` is the full name to be shown - the name with any added prefixes and formatted nicely
- `tile` is the tile (again, without attachments)
- `realtile` is the full tile to be used - the tile with any added prefixes and checked that it works
- `size` is "" but the more duplicate items are added, the larger the text will say
- `tint` is the tint to colour with and is the average of all the tint colours

# Recipes
Lists some unique combinations of things

Inputs list tags and requirements in order for each tag in the format `<name>:<min>,<max>` (or `<name>`, which is equivalent to `<name>:1,`).
The min or max can be left blank to represent an infinite bound in that direction (no min or no max value).
Any value names not counted but present in the recipe will result in a faliure to craft it (can use `<name>:,` to allow specific names)

- `&` = all values (useful for finding total number of items being crafted)
- `%` = something unused so far that has a value
- `#` = something unused so far that has a value, and will 'use it' so it is no longer a faliure point (useful with max set)
- `>` = use up the rest of the values (by itself converts to `#:,`)
- `$` = all unique values
- `_` = empty values

# Items
Lists all the items that can be found in the world naturally.

If the item is type 'combined', it will be replaced with the combination of the listed items so as to not repeat myself when defining stuff.

# Tiles
Maps tile names to their coordinates on the item grid.

Tile names are separated by space and contain 

# Colours
Colours used for the various tags
