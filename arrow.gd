extends RigidBody2D


func _on_arrow_body_entered(body):
    if body.has_method("hit_by_arrow"):
        body.call("hit_by_arrow")