extends Node

const SUFFIXES: Array[String] = ["", "K", "M", "B", "T", "Qa", "Qi", "Sx", "Sp", "Oc", "No", "Dec"]

func format(value: float) -> String:
	if is_inf(value):
		return "Inf"
	var sign: String = ""
	if value < 0.0:
		sign = "-"
		value = abs(value)
	if value < 1000.0:
		return sign + _trim_decimals(value, 0)
	if value < 10000.0:
		return sign + _format_integer_with_dots(int(round(value)))
	var tier: int = int(floor(log(value) / log(1000.0)))
	var suffix: String = _suffix_for_tier(tier)
	var scaled: float = value / pow(1000.0, tier)
	var decimals: int = 1 if scaled < 10.0 else 0
	return sign + _trim_decimals(scaled, decimals) + suffix

func format_time(seconds: float) -> String:
	var total: int = int(max(seconds, 0.0))
	var hours: int = total / 3600
	var minutes: int = (total % 3600) / 60
	var secs: int = total % 60
	if hours > 0:
		return "%dh %02dm %02ds" % [hours, minutes, secs]
	if minutes > 0:
		return "%dm %02ds" % [minutes, secs]
	return "%ds" % secs

func _suffix_for_tier(tier: int) -> String:
	if tier < SUFFIXES.size():
		return SUFFIXES[tier]
	return "e%d" % (tier * 3)

func _trim_decimals(value: float, decimals: int) -> String:
	var text: String = "%.*f" % [decimals, value]
	if decimals > 0:
		while text.ends_with("0"):
			text = text.left(text.length() - 1)
		if text.ends_with("."):
			text = text.left(text.length() - 1)
	return text

func _format_integer_with_dots(value: int) -> String:
	var text: String = str(value)
	var result: String = ""
	var count: int = 0
	for i in range(text.length() - 1, -1, -1):
		if count > 0 and count % 3 == 0:
			result = "." + result
		result = text.substr(i, 1) + result
		count += 1
	return result
