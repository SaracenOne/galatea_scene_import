tool

static func string_ends_with(p_main_string, p_end_string):
	var pos = p_main_string.find_last(p_end_string)
	if (pos==-1):
		return false;
	return pos+p_end_string.length() == p_main_string.length();

static func teststr(p_what, p_str):
	if(p_what.findn("$"+p_str)!=-1):
		return true
	if(string_ends_with(p_what.to_lower(), "-" + p_str)):
		return true
	if (string_ends_with(p_what.to_lower(), "_" + p_str)):
		return true
	return false

static func fixstr(p_what, p_str):
	if(p_what.findn("$" + p_str) != -1):
		return p_what.replace("$" + p_str, "")
	if(p_what.to_lower().ends_with("-" + p_str)):
		return p_what.substr(0,p_what.length()-(p_str.length() + 1))
	if(p_what.to_lower().ends_with("_" + p_str)):
		return p_what.substr(0,p_what.length()-(p_str.length() + 1))
	return p_what

static func decode_mesh_surface_names(p_node):
	if(p_node != null and p_node extends MeshInstance):
		var mesh = p_node.get_mesh()
		for i in range(0, mesh.get_surface_count()):
			var material = mesh.surface_get_material(i)
			if(material != null):
				if(teststr(material.get_name(), "combine_material")):
					mesh.surface_set_name(i, "combine_material")
		p_node.set_mesh(mesh)
	return p_node

static func decode_mesh_instance_tags(p_node):
	if(p_node != null and p_node extends MeshInstance):
		var mesh = p_node.get_mesh()
		for i in range(0, mesh.get_surface_count()):
			var material = mesh.surface_get_material(i)
			if(material != null):
				print("processing material: " + material.get_name())
				var fixed_string = material.get_name()
				if(teststr(fixed_string, "double_sided")):
					print("using double-sided")
					material.set_flag(Material.FLAG_DOUBLE_SIDED, true )
					fixed_string = fixstr(fixed_string, "double_sided")
				if(teststr(fixed_string, "no_shadow_cast")):
					print("using no_shadow_cast")
					material.set_flag(Material.FLAG_SKIP_SHADOW_CASTING, true )
					fixed_string = fixstr(fixed_string, "no_shadow_cast")
				if(teststr(fixed_string, "combine_material")):
					print("using combine_material")
					fixed_string = fixstr(fixed_string, "combine_material")
				material.set_name(fixed_string)
		p_node.set_mesh(mesh)
	return p_node