extends RefCounted

class_name Utils

signal active_resource_change  # calledd when something the player does (so not tick) changes resource amounts


static func simulate_random_events(number, probability):
	# if event can happen number times with probability chance, this function returns how many times it happens
	# approximates binomial distribution using gaussian distribution if number>=100, otherwise jut brute forces
	if number < 100:
		var summary = 0
		for _i in range(number):
			if randf() <= probability:
				summary += 1
		return summary
	return clamp(round(randfn(number * probability, sqrt(number * (1 - probability)))), 0, number)


static func sum_array(array):
	var accumulator = 0
	for number in array:
		accumulator += number
	return accumulator


static func get_scaled_cost(base_costs: Dictionary, scaling_factor: float, number: int):
	# return cost of repeatable upgrade with exponential scaling
	var next_costs = {}
	for key in base_costs:
		next_costs[key] = ceil(base_costs[key] * pow(scaling_factor, number))
	return next_costs


static func order_of_magnitude(number):
	return floor(log(number) / log(10))


static func resources_to_string(dict: Dictionary):
	var result = ""
	var firstline = true
	for key in dict:
		if not firstline:
			result += "\n"
		firstline = false
		result += "%s: %s" % [Enums.resource_names[key], dict[key]]
	return result


static func float_array_to_int(array: Array):
	# converts array of floats into array of ints
	# useful for deserialization from json
	var new_array = []
	for i in range(len(array)):
		new_array.append(int(array[i]))
	return new_array
