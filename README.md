# HOLOCHIP

An ill-advised pure GDScript implementation of a CHIP-8 interpreter. Currently has full support for the base CHIP-8 spec, with support for the main quirks of the original COSMAC VIP CHIP-8 interpreter. Has support for SCHIP instructions, with SCHIP quirks toggles WIP.

There is currently a holographic display option that renders the standard CHIP-8 display to a voxel display in a 3D world. This is very barebones at the moment, but I'm looking to flesh it out. It currently only supports lores (64x32) mode ROMs.

There is no UI available yet; I'm currently relying on the Godot editor UI to interact with the interpreter and change settings. UI is low priority. As the title of this repo suggests, the main goal of this repo is to create a holographic CHIP interpreter. This means most UI elements can be in-world 3D elements.

Time permitting, I even intend to create an extension to the standard CHIP instruction set that allows full use of the 3D voxel display. Options include 64x64, or 128x64x64. This will include various compatibility modes for legacy ROMs to make use of the extra voxel space.
