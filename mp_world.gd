extends Node2D
signal game_finished()

# Called when the node enters the scene tree for the first time.
func _ready():
    if (get_tree().is_network_server()):		
        #if in the server, get control of player 2 to the other peeer, this function is tree recursive by default
        get_node("Player2").set_network_master(get_tree().get_network_connected_peers()[0])
    else:
        #if in the client, give control of player 2 to itself, this function is tree recursive by default
        get_node("Player2").set_network_master(get_tree().get_network_unique_id())
    
    #let each player know which one is left, too
    get_node("Player1").hero=true
    get_node("Player2").hero=false
    get_node("Player1").mp_enabled=true
    get_node("Player2").mp_enabled=true
    print("unique id: ",get_tree().get_network_unique_id())

func _process(delta):
    if Input.is_action_pressed("ui_quit"):
        emit_signal("game_finished")