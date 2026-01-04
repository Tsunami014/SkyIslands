# Recipes
Lists some unique combinations of things

# Items
Lists all the items that can be found in the world naturally
## Tags
| Name     | Type | Desc | Transformation when combined | Effects |
|----------|:----:|:----:|-----------------------------:|--------:|
| name     | str  | Extra name prefixes | Combines the prefixes | none |
| food     | bool | Is it edible? | If anything is not a food, the output isn't | none |
| colour   | str  | The object's colour | Tag is set to the value of the last item with this tag | Name is prefixed with this tag, and object is tinted slightly with this colour |
| shape    | str  | The object's shape | Same as colour (set to last) | Name is prefixed with this tag and image is warped, cropped or something |
| material | str  | What material is it made of? | If is made of multiple materials, do not have this tag - else use the one they all use (ones without material don't count) | Same as colour (name prefix and slight recolour) |

# Colours
Colours used for the various tags
