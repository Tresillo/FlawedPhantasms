extends Area3D

class_name Collectible

signal pickup_collected

func _on_body_entered(body):
	if body is Player:
		$CollectionSound.play()
		pickup_collected.emit()
		$CollectibleModel.visible = false
		await $CollectionSound.finished
		call_deferred("queue_free")
