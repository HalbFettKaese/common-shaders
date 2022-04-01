# Common Shaders
 Vanilla Minecraft shaders for various effects, merged into one pack.

# Original effects
* Particles with their tint having its red channel set to 254 and the blue channel set to 253 trigger an insanity effect. The level of sanity is proportional to the blue channel of the particle tint.

# Marker particle tints
* (254, 253, x): Effects from manic.

# Fabulous shader common.data buffer layout
* Row 0: Pixel 0 contains time since last shader reload, read as `time = dataTime.x + 255. * dataTime.y + 65025. * dataTime.z;` to get the value in seconds.
* Row 1: Effects from manic.

# Core shaders included from other repositories
* https://github.com/Ancientkingg/fancyPants
* https://github.com/ShockMicro/CorePerspectiveModels
* https://github.com/ShockMicro/VanillaDynamicEmissives
