# HOLOCHIP

An ill-advised pure GDScript implementation of a CHIP-8 interpreter. Currently has full support for the base CHIP-8 spec, with support for the main quirks of the original COSMAC VIP CHIP-8 interpreter. Has support for all CHIP instructions and most SCHIP instructions, plus quirks toggles for all major quirks (including XO-CHIP, even though XO-CHIP-unique opcodes are still WIP).

There is currently a holographic display option that renders the standard CHIP-8 display to a voxel display in a 3D world. This is very barebones at the moment, but I'm looking to flesh it out. Hires ROMs can technically render in the 3D mode, but they simply scale off the edge of the screen instead of scaling in-place like they should. The 3D voxel display component is a lower priority, and will be worked on once I get the emulator working as I would like.

There is no UI available yet; I'm currently relying on the Godot editor UI to interact with the interpreter and change settings, but UI elements are planned. As the title of this repo suggests, the main goal of this repo is to create a holographic CHIP interpreter. This means most UI elements can be in-world 3D elements, but I intend to create a 2D workspace as well with more detailed access to the inner workings of the emulator.

Time permitting, I even intend to create an extension to the standard CHIP instruction set that allows full use of the 3D voxel display. Possibly 128x64x64. This will include various compatibility modes for legacy ROMs to make use of the extra voxel space.
