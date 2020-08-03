extends Control


func switch_to_view(view_number):
	var num_children = get_child_count()
	if view_number >= num_children:
		Logger.warn("Switching to view %s but only %s children" % [view_number, num_children])
	
	for i in range(num_children):
		var child: Control = get_child(i)
		if i == view_number:
			child.show()
		else:
			child.hide()
