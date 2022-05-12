# Common Shaders
 Vanilla Minecraft shaders for various effects, merged into one pack.

# Marker particle tints
Preferably, setting the red channel to be 254 or 253 sets it to be a marker, and the green channel identifies which effect you choose.
* (254, 253, x): Manic
* (254, 252, x): Sanguine

# Marker pixel screen positions
To ensure that all packs can receive their inputs simultaneously, marker particles are transformed to fill different screen positions. They should form a gridlike pattern to make it possible to reconstruct every pixel from its surroundings.
* (0, 0): Manic
* (0, 2): Sanguine

# Fabulous shader common.data buffer layout
* Row 0: Pixel 0 contains time since last shader reload, read as `time = dataTime.x + 255. * dataTime.y + 65025. * dataTime.z;` to get the value in seconds.
* Row 1: Manic
* Row 2: Sanguine

# Text offsets through color
Text elements can be offset in proportions of the screen, controlled by the color that the text has. Setting the last character of the hex string to `D` marks the character as being affected. The remaining digits are split up in the middle, with the left half going from -1 screen width to 1 screen width horizontally, and the right half going from -1 screen height to 1 screen height vertically. A conversion with inputs ranging from 0 to 1023 in each axis can look like `hex = (x_offset << 14) | (y_offset << 4) | 13`

## Usage example
The pack has an included usage example. It can be called with the command
`/title @a actionbar [{"text":"SM","font":"manic:meter","color":"#403ffd"}]`
where `S` is the same width as `M` in order to make the latter be aligned to the left rather than being centered, and `M` has a character offset applied to it such that it would normally be *below* the screen, such that adding one full screen height brings it to the top of the screen.

More specifically, the left half in this is `0x100`, and the right half is `0x3ff`, which combine into `(0x100 << 10) | 0x3ff = 0x403ff`.

# Core shaders included from other repositories
* https://github.com/Ancientkingg/fancyPants
* https://github.com/ShockMicro/CorePerspectiveModels
* https://github.com/ShockMicro/VanillaDynamicEmissives
