extends VehicleWheel3D

func _ready():
	# Wait a frame for everything to load
	await get_tree().process_frame
	
	# Find the WheelPivot
	var pivot = $WheelPivot
	if pivot:
		# Move the pivot DOWN by half the suspension travel
		# This centers the wheel in the yellow box
		pivot.position.y = -suspension_travel / 2
		
		print("Setup complete for: ", name)
		print("  - Suspension Travel: ", suspension_travel)
		print("  - Pivot Y position: ", pivot.position.y)
