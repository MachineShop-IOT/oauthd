
_check = (arg, format) ->
	if Array.isArray(format)
		for possibility in format
			return true if _check arg, possibility
		return false

	if typeof format == 'object'
		if arg? && typeof arg == 'object'
			for k,v of format
				return false if not _check arg[k], v
			return true
		return false

	if format instanceof RegExp
		return typeof arg == 'string' && arg.match(format)

	return !format ||
		format == 'any' && arg? ||
		format == 'none' && not arg? ||
		format == 'null' && arg == null ||
		format == 'string' && typeof arg == 'string' ||
		format == 'regexp' && arg instanceof RegExp ||
		format == 'object' && arg? && typeof arg == 'object' ||
		format == 'function' && typeof arg == 'function' ||
		format == 'array' && Array.isArray(arg) ||
		format == 'number' && (arg instanceof Number || typeof arg == 'number') ||
		format == 'int' && (parseFloat(arg) == parseInt(arg)) && !isNaN(arg) ||
		format == 'bool' && (arg instanceof Boolean || typeof arg == 'boolean') ||
		format == 'date' && (arg instanceof Date || arg instanceof Number || typeof arg == 'number')

_clone = (item) ->
	return item if not item?
	return Number item if item instanceof Number
	return String item if item instanceof String
	return Boolean item if item instanceof Boolean

	if Array.isArray(item)
		result = []
		for index, child of item
			result[index] = _clone child
		return result

	if typeof item == "object" && ! item.prototype
		result = {}
		for i of item
			result[i] = _clone item[i]
		return result

	return item

check = ->
	checked = Array.prototype.pop.call arguments, arguments
	format = arguments
	return =>
		args = Array.prototype.slice.call arguments
		callback = args.pop()
		if not _check args, format
			return callback new Error 'Bad parameters format'
		return checked.apply @, arguments

check.clone = (cloned) -> =>
	return cloned.apply @, _clone arguments

module.exports = check