extends KinematicBody2D
signal hit

const GRAVITY = 500.0 # pixels/second/second

# Angle in degrees towards either side that the player can consider "floor"
const FLOOR_ANGLE_TOLERANCE = 40
const WALK_FORCE = 600
const WALK_MIN_SPEED = 10
const WALK_MAX_SPEED = 200
const STOP_FORCE = 1300
const JUMP_SPEED = 300
const JUMP_MAX_AIRBORNE_TIME = 0.5

const SLIDE_STOP_VELOCITY = 1.0 # one pixel/second
const SLIDE_STOP_MIN_TRAVEL = 1.0 # one pixel
const BULLET_VELOCITY = 1000

var velocity = Vector2()
var on_air_time = 100
var jumping = false
var prev_jump_pressed = false
var screensize
var jump

var arrow_scene = preload("res://arrow.tscn")
onready var sprite = $Sprite

func hit_by_arrow():
    print_debug("hit")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    # Create forces
    var force = Vector2(0, GRAVITY)
    
    var walk_left = Input.is_action_pressed("ui_left")
    var walk_right = Input.is_action_pressed("ui_right")
    jump = Input.is_action_pressed("ui_up")
    
    var stop = true
    
    # Shooting
    if Input.is_action_just_pressed("shoot"):
        var arrow = arrow_scene.instance()
        arrow.position = $Sprite/arrow_start.global_position #use node for shoot position
        #arrow.get_node("./Sprite").scale(Vector2(0.5,0.5))
        arrow.linear_velocity = Vector2(sprite.scale.x * BULLET_VELOCITY, 0)
        #arrow.add_collision_exception_with(self) # don't want player to collide with bullet
        get_parent().add_child(arrow) #don't want bullet to move with me, so add it as child of parent
    
    if walk_left:
        if velocity.x <= WALK_MIN_SPEED and velocity.x > -WALK_MAX_SPEED:
            force.x -= WALK_FORCE
            stop = false
            sprite.scale.x = -1
        
    elif walk_right:
        if velocity.x >= -WALK_MIN_SPEED and velocity.x < WALK_MAX_SPEED:
            force.x += WALK_FORCE
            stop = false
            sprite.scale.x = 1
    
    if stop:
        var vsign = sign(velocity.x)
        var vlen = abs(velocity.x)
        
        vlen -= STOP_FORCE * delta
        if vlen < 0:
            vlen = 0
        
        velocity.x = vlen * vsign

        $AnimationPlayer.stop()
        
    else:        
        $AnimationPlayer.play("Walking")
            
    # Integrate forces to velocity
    velocity += force * delta

func _physics_process(delta):
    # Integrate velocity into motion and move
    velocity = move_and_slide(velocity, Vector2(0, -1))
    
    if is_on_floor():
        on_air_time = 0
        
    if jumping and velocity.y > 0:
        # If falling, no longer jumping
        jumping = false
    
    if on_air_time < JUMP_MAX_AIRBORNE_TIME and jump and not prev_jump_pressed and not jumping:
        # Jump must also be allowed to happen if the character left the floor a little bit ago.
        # Makes controls more snappy.
        velocity.y = -JUMP_SPEED
        jumping = true
    
    on_air_time += delta
    prev_jump_pressed = jump

# Called when the node enters the scene tree for the first time.
func _ready():
    #hide()
    screensize = get_viewport_rect().size    

func start(pos):
    position = pos
    show()
    $CollisionShape2D.disabled = false

func _on_RigidBody2D_body_entered():
    emit_signal("hit")
