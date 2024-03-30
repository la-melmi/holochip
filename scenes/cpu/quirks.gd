class_name QuirkHandler
extends Node


enum System {
	CHIP_8,
	SUPER_CHIP,
	XO_CHIP,
	CUSTOM,
}

@export var legacy: bool
@export var system: System

## The overrides only take effect if [member system] is set to [member System.Custom]
@export_group("Custom")

## AND, OR, and XOR opcodes reset the flags register to 0.
@export var vf_reset: bool:
	get:
		match system:
			System.CHIP_8:
				return true
			System.CUSTOM:
				return vf_reset
			_:
				return false

## The save and load opcodes increment the index register.
@export var memory: bool:
	get:
		match system:
			System.SUPER_CHIP:
				return false
			System.CUSTOM:
				return memory
			_:
				return true

## Drawing sprites to the display waits for the vertical blank interrupt.
@export var display_wait: bool:
	get:
		match system:
			System.CHIP_8:
				return true
			System.SUPER_CHIP:
				if not legacy: return false
				return display.height != 64
			System.XO_CHIP:
				return false
			_:
				return display_wait

## Sprites drawn at the bottom edge of the screen get clipped instead of wrapping around.
@export var clipping: bool:
	get:
		match system:
			System.XO_CHIP:
				return false
			System.CUSTOM:
				return clipping
			_:
				return true

## The shift opcodes only operate on Vx instead of storing the shifted version of Vy in Vx
@export var shifting: bool:
	get:
		match system:
			System.SUPER_CHIP:
				return true
			System.CUSTOM:
				return shifting
			_:
				return false

## The "jump to some address plus V0" instruction (Bnnn) uses Vx instead
@export var jumping: bool:
	get:
		match system:
			System.SUPER_CHIP:
				return true
			System.CUSTOM:
				return jumping
			_:
				return false

@export_group("Connected Nodes")
@export var display: CHIPDisplay
