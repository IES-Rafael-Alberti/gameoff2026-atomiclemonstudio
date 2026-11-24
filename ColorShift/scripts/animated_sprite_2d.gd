@tool
extends AnimationPlayer

@export var animated_sprite: AnimatedSprite2D

@export_tool_button("Sync SpriteFrames", "SpriteFrames") var sync := func() -> void:
	var animation_library := get_animation_library("")
	var sprite_frames := animated_sprite.sprite_frames
	var sprite_frame_animation_names := sprite_frames.get_animation_names()

	# Las rutas de las pistas son relativas al root_node del AnimationPlayer,
	# no al nombre del sprite. Si el sprite es el propio root_node, sale ".".
	var sprite_path := str(get_node(root_node).get_path_to(animated_sprite))

	for animation_name in sprite_frame_animation_names:
		# Get or create the animation
		var animation: Animation
		if animation_library.has_animation(animation_name):
			animation = animation_library.get_animation(animation_name)
		else:
			animation = Animation.new()
			animation_library.add_animation(animation_name, animation)

		# Reset the animation and frame tracks
		var animation_track_path := NodePath(sprite_path + ":animation")
		var animation_track_index := animation.find_track(animation_track_path, Animation.TrackType.TYPE_VALUE)
		if animation_track_index >= 0:
			animation.remove_track(animation_track_index)

		var frame_track_path := NodePath(sprite_path + ":frame")
		var frame_track_index := animation.find_track(frame_track_path, Animation.TrackType.TYPE_VALUE)
		if frame_track_index >= 0:
			animation.remove_track(frame_track_index)

		animation_track_index = animation.add_track(Animation.TrackType.TYPE_VALUE, 0)
		frame_track_index = animation.add_track(Animation.TrackType.TYPE_VALUE, 1)
		animation.track_set_path(animation_track_index, animation_track_path)
		animation.track_set_path(frame_track_index, frame_track_path)

		# Fill the tracks from the sprite frames
		animation.track_insert_key(animation_track_index, 0, animation_name)

		var animation_length := 0.0
		var frame_fps := sprite_frames.get_animation_speed(animation_name)
		for i in sprite_frames.get_frame_count(animation_name):
			var frame_duration := sprite_frames.get_frame_duration(animation_name, i)
			animation.track_insert_key(frame_track_index, animation_length, i)
			animation_length += frame_duration / frame_fps

		animation.length = animation_length
		animation.loop_mode = Animation.LOOP_LINEAR if sprite_frames.get_animation_loop(animation_name) else Animation.LOOP_NONE
		animation.value_track_set_update_mode(animation_track_index, Animation.UPDATE_DISCRETE)
		animation.value_track_set_update_mode(frame_track_index, Animation.UPDATE_DISCRETE)

	EditorInterface.get_editor_toaster().push_toast("Animations have been synced!")
