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
Text elements can be offset in proportions of the screen, controlled by the color that the text has. Setting the the red and green channel to `01f9` marks the character as being affected. The red channel is split into its two digits, with the first character representing the offset along the x axis and the second character representing that along the y axis. The following table shows the offsets that each input digit describes, with one unit corresponding to a full screen width:

| Digit | Offset | Direction |
|-------|--------|-----------|
| 0     | 1      | Down/Left |
| 1     | 0.75   | Down/Left |
| 2     | 0.5    | Down/Left |
| 3     | 0.25   | Down/Left |
| 4     | 0      | -         |
| 5     | 0.25   | Up/Right  |
| 6     | 0.5    | Up/Right  |
| 7     | 0.75   | Up/Right  |
| 8     | 1      | Up/Right  |

## Usage example
The pack has an included usage example. It can be called with the command
`/title @a actionbar [{"text":"SM","font":"manic:meter","color":"#2801f9"}]`
where `S` is the same width as `M` in order to make the latter be aligned to the left rather than being centered, and `M` has a character offset applied to it such that it would normally be *below* the screen, such that adding one full screen height brings it to the top of the screen.

More specifically, the first two characters in this are `0x28`, where the `2` means "half a screen width to the left" and the `8` means "A full screen height up".

# Core shaders included from other repositories
* https://github.com/Ancientkingg/fancyPants
* https://github.com/ShockMicro/CorePerspectiveModels
* https://github.com/ShockMicro/VanillaDynamicEmissives
* https://github.com/Godlander/objmc
