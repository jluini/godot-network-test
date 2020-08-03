extends Node

enum Severity {
	Debug,
	Info,
	Warning,
	Error
}

var _log_to_console = true
var _logger_output = null

func set_output(new_output, log_to_console):
	_log_to_console = log_to_console
	_logger_output = new_output

func log_message(severity, message):
	emit_message(OS.get_time(), severity, message)

func debug(message):
	log_message(Severity.Debug, message)

func info(message):
	log_message(Severity.Info, message)

func warn(message):
	log_message(Severity.Warning, message)

func error(message):
	log_message(Severity.Error, message)

# private

func emit_message(time, severity, message):
	if _logger_output:
		_logger_output.emit_message(time, severity, message)
	if _log_to_console:
		print(formatted_message(time, severity, message))

func severity_str(severity):
	return Severity.keys()[severity].to_upper()

func time_str(time):
	return "%s:%s:%s" % [time.hour, time.minute, time.second]

func formatted_message(time, severity, message):
	return "[%s] %7s %s" % [time_str(time), severity_str(severity), message]
