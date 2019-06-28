extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
    $Player.start($StartPosition.position)
    
    
func _process(delta):
    if Input.is_action_pressed("ui_cancel"):
        get_tree().quit()