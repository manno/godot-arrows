extends Node2D
signal game_finished()

# Called when the node enters the scene tree for the first time.
func _ready():
    $Player.start($StartPosition.position)
    
func _process(delta):
    if Input.is_action_pressed("ui_quit"):
        emit_signal("game_finished")
