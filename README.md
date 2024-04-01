# HOLOCHIP

An ill-advised pure GDScript implementation of a CHIP-8 interpreter. Currently has full support for the base CHIP-8 spec, with support for the main quirks of the original COSMAC VIP CHIP-8 interpreter. Has support for all CHIP instructions and most SCHIP instructions, plus quirks toggles for all major quirks (including XO-CHIP, even though XO-CHIP-unique opcodes are still WIP).

There is currently a holographic display option that renders the standard CHIP-8 display to a voxel display in a 3D world. This is very barebones at the moment, but I'm looking to flesh it out. Hires ROMs can technically render in the 3D mode, but they simply scale off the edge of the screen instead of scaling in-place like they should. The 3D voxel display component is a lower priority, and will be worked on once I get the emulator working as I would like.

There is a basic 2D UI that allows loading ROMs, pausing, inspecting registers, and disassembling code in real time. Eventually, once the voxel display is fleshed out, I intend to make much of this UI available in the 3D workspace as well, but for now it is only available in the default 2D workspace. The 3D workspace will potentially also feature in-world 3D UI elements, such as a 3D representation of the system's memory.

Time permitting, I even intend to create an extension to the standard CHIP instruction set that allows full use of the 3D voxel display. Possibly 128x64x64. This will include various compatibility modes for legacy ROMs to make use of the extra voxel space.
