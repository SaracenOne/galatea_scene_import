tool
extends EditorScenePostImport

const animation_directory_path = "res://assets/animations/character"
const material_directory_path = "res://assets/materials/character"
const mesh_directory_path = "res://assets/models/character"
const skeleton_directory_path = "res://assets/skeletons"

const utility_const = preload("utility.gd")
const mesh_combiner_const = preload("res://addons/mesh_combiner/mesh_combiner.gd")
const blend_shape_extractor_const = preload("res://addons/mesh_combiner/blend_shape_extractor.gd")
const blend_shape_data_collection_const = preload("res://addons/mesh_combiner/blend_shape_data_collection.gd")

func post_import(p_scene):
	print("Importing character...")

	var directory = Directory.new()
	directory.make_dir_recursive(animation_directory_path)
	directory.make_dir_recursive(material_directory_path)
	directory.make_dir_recursive(mesh_directory_path)
	directory.make_dir_recursive(skeleton_directory_path)
	directory = null

	var animation_player = p_scene.get_node("AnimationPlayer")
	for animation_name in animation_player.get_animation_list():
		var animation = animation_player.get_animation(animation_name)
		animation = utility_const.clear_animation_morph_tracks(animation)
		print("Saving animation '" + animation_name + "'...")
		ResourceSaver.save(animation_directory_path + "/" + animation_name + ".tres", animation)

	if(p_scene.has_node("Armature")):
		var armature = p_scene.get_node("Armature")
		if(armature.has_node("Skeleton")):
			var skeleton = armature.get_node("Skeleton")
			for mesh_instance in skeleton.get_children():
				if(mesh_instance extends MeshInstance):
					print("!!!decoding mesh surfaces for  " + str(mesh_instance.get_name()))
					utility_const.decode_mesh_surface_names(mesh_instance)
			for mesh_instance in skeleton.get_children():
				if(mesh_instance extends MeshInstance):
					var new_mesh_instance = mesh_instance
					new_mesh_instance = utility_const.decode_mesh_instance_tags(new_mesh_instance)
					var mesh = new_mesh_instance.get_mesh()
					if(mesh):
						for i in range(0, mesh.get_surface_count()):
							var material = mesh.surface_get_material(i)

							print("Saving material '" + material.get_name() + "'...")
							ResourceSaver.save(material_directory_path + "/" + material.get_name() + ".tres", material)

						print("Saving mesh '" + mesh.get_name() + "'...")
						ResourceSaver.save(mesh_directory_path + "/" + mesh.get_name() + ".msh", mesh)

						# Extract morphs
						var mesh_combiner = mesh_combiner_const.new()
						mesh_combiner.append_mesh(mesh)

						var blend_shape_collection = blend_shape_data_collection_const.new()

						print("blend shape count = " + str(mesh_combiner.blend_shape_names.size()))
						for i in range(0, mesh_combiner.blend_shape_names.size()):
							print("blend shape: " + mesh_combiner.blend_shape_names[i])
							if utility_const.teststr(mesh_combiner.blend_shape_names[i], "gen_morph"):
								var blend_shape_data = blend_shape_extractor_const.extract_blend_shape_from_mesh_combiner(mesh_combiner, mesh_combiner.blend_shape_names[i])
								blend_shape_collection.blend_shape_data.append(blend_shape_data)

						if(blend_shape_collection.blend_shape_data.size() > 0):
							print("Saving blend shape '" + mesh.get_name() + "_blend_shapes" + "'...")
							ResourceSaver.save(mesh_directory_path + "/" + mesh.get_name() + "_blend_shapes" + ".tres", blend_shape_collection)
						else:
							print("No blend shape...")

			var export_armature = Spatial.new()
			export_armature.set_transform(armature.get_transform())
			export_armature.set_name("Armature")

			var export_skeleton = skeleton.duplicate()
			for child in export_skeleton.get_children():
				export_skeleton.remove_child(child)

			export_armature.add_child(export_skeleton)
			export_skeleton.set_owner(export_armature)

			var packed_armature = PackedScene.new()
			packed_armature.pack(export_armature)

			ResourceSaver.save(skeleton_directory_path + "/skeleton.tscn", packed_armature)
			export_armature.queue_free() #Cleanup

	return p_scene