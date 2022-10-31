# Common Shaders
 Vanilla Minecraft shaders for various effects, merged into one pack.

# Marker particle setup
## Tints
Preferably, setting the red channel to be 254 or 253 sets it to be a marker, and the green channel identifies which effect you choose.
## Marker pixel screen positions
To ensure that all packs can receive their inputs simultaneously, marker particles are transformed to fill different screen positions. They should form a gridlike pattern to make it possible to reconstruct every pixel from its surroundings.

# Fabulous shader common.data buffer layout
* Row 0: Pixel 0 contains time since last shader reload, read as `time = dataTime.x + 255. * dataTime.y + 65025. * dataTime.z;` to get the value in seconds.
* Row 1-4: Manic
* Row 5: Sanguine

# Full layout
| Tint          | Pixel Position | Data buffer row | Description                                                     |
|---------------|----------------|-----------------|-----------------------------------------------------------------|
| (254, 253, x) | (0, 0)         | 1               | Manic effect intensity, by default only controlling screen warp |
| (254, 251, x) | (1, 1)         | 2               | Manic luma contrast toggle                                      |
| (254, 250, x) | (2, 0)         | 3               | Manic vignette and tentacles toggle                             |
| (254, 249, x) | (0, 4)         | 4               | Manic desaturation toggle                                       |
| (254, 248, x) | (1, 3)         | 5               | Manic wobble toggle                                             |
| (254, 252, x) | (0, 2)         | 6               | Sanguine                                                        |

# Text offsets through color
Text elements can be offset in proportions of the screen, controlled by the color that the text has. Setting the the green and blue channel, i.e. the last 4 characters of the color's hex code, to `04f9` marks the character as being affected. The red channel, which occupies the first two characters, is split into its two digits, with the first character representing the offset along the x axis and the second character representing that along the y axis. The following table shows the offsets that each input digit describes, with one unit corresponding to a full screen width:

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
`/title @a actionbar [{"text":"SM","font":"manic:meter","color":"#2804f9"}]`
where `S` is the same width as `M` in order to make the latter be aligned to the left rather than being centered, and `M` has a character offset applied to it such that it would normally be *below* the screen, such that adding one full screen height brings it to the top of the screen.

More specifically, the first two characters in this are `0x28`, where the `2` means "half a screen width to the left" and the `8` means "A full screen height up".

# Core shaders included from other repositories
* https://github.com/Ancientkingg/fancyPants
* https://github.com/ShockMicro/CorePerspectiveModels
* https://github.com/ShockMicro/VanillaDynamicEmissives
* https://github.com/Godlander/objmc
