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
Text elements can be offset in proportions of the screen, controlled by the color that the text has. Setting the text color's blue channel to 253 (0xFD) marks a character as having the effect applied, and the text will be displayed as if the used tint was white instead.

The offset along the x/y axis is determined by the value of the red/green channels. Each channel's value corresponds to the following offsets, with one unit being the distance between the screen center and the edge of the screen.

| Color | Amount | Direction |
|-------|--------|-----------|
| 0     | 0      | -         |
| 1     | 1      | Down/Left |
| 2     | 1      | Up/Right  |
| 3     | 2      | Down/Left |
| 4     | 2      | Up/Right  |

# Core shaders included from other repositories
* https://github.com/Ancientkingg/fancyPants
* https://github.com/ShockMicro/CorePerspectiveModels
* https://github.com/ShockMicro/VanillaDynamicEmissives
