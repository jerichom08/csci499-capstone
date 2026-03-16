extends Node2D

func _ready() -> void:
	if has_node("/root/PuzzleManager"):
		print("✅ PuzzleManager found at /root/PuzzleManager")
	else:
		print("❌ PuzzleManager NOT found. Check Autoload tab.")
