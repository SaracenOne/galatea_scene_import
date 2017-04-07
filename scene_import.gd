tool
extends EditorScenePostImport

const utility_const = preload("utility.gd")

#const galatea_database_const = preload("res://addons/galatea_databases/databases/galatea_databases.gd")

var galatea_database_path = "res://assets/database"
var galatea_database_instance = null
	
func detect_material_type(p_what):
	if(utility_const.teststr(p_what, "materialtype_")):
		for record in galatea_database_instance.material_type_database.database_records:
			if(utility_const.teststr(p_what, "materialtype_" + record.name)):
				var fixed_string = utility_const.fixstr(p_what, "materialtype_" + record.name)
				return record.name
	
func process_node(p_node):
	var node_name = p_node.get_name()
	print("Processing node: " + str(node_name))
	if(p_node extends StaticBody):
		pass
	elif(p_node extends MeshInstance):
		var mesh = p_node.get_mesh()
		for i in range(0, mesh.get_surface_count()):
			var is_combined_surface = false
			var material = mesh.surface_get_material(i)
			if(material != null):
				print("processing material: " + material.get_name())
				var fixed_string = material.get_name()
				if(utility_const.teststr(fixed_string, "double_sided")):
					print("using double-sided")
					material.set_flag(Material.FLAG_DOUBLE_SIDED, true )
					fixed_string = utility_const.fixstr(fixed_string, "double_sided")
				if(utility_const.teststr(fixed_string, "no_shadow_cast")):
					print("using no_shadow_cast")
					material.set_flag(Material.FLAG_SKIP_SHADOW_CASTING, true )
					fixed_string = utility_const.fixstr(fixed_string, "no_shadow_cast")
				if(utility_const.teststr(fixed_string, "combine_material")):
					print("using combine_material")
					is_combined_surface = true
					fixed_string = utility_const.fixstr(fixed_string, "combine_material")
				material.set_name(fixed_string)
				if(is_combined_surface):
					mesh.surface_set_name(i, fixed_string)
				else:
					mesh.surface_set_name(i, "combine_surface")
		p_node.set_mesh(mesh)

func parse_node(p_node):
	process_node(p_node)
	for i in range(0, p_node.get_child_count()):
		parse_node(p_node.get_child(i))
	
func post_import(scene):
	#galatea_database_instance = galatea_database_const.new(galatea_database_path)
	#assert(galatea_database_instance)
	#galatea_database_instance.load_all_databases()
	
	parse_node(scene)
	
	return scene
