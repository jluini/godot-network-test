extends Panel

export var colors = {
	Logger.Severity.Debug: Color("7f7fff"),
	Logger.Severity.Info: Color("7fff7f"),
	Logger.Severity.Warning: Color("ffff7f"),
	Logger.Severity.Error: Color("ff7f7f")
}

onready var console = $console

func emit_message(time, severity, message):
	console.push_color(_get_color(severity))
	console.add_text("[%s] %s" % [Logger.time_str(time), message])
	console.add_text("\n")
	console.pop()

# private

func _get_color(severity):
	return colors[severity]
