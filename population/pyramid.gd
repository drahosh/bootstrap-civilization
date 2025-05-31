# This script just controls the illustration of the population pyramid, has no effect on underlying mechanics

extends Panel
var population: Population  # parent, used for getting data
var middle_min_width = 20
var middle_min_width_ratio = 0.05
var margin = 0  # distance from middle bar to population bars
#var population_bar_width = 10
var population_label_frequency = 10


func set_population(population: Population):
	self.population = population


func _draw() -> void:
	var bottom = self.size.y
	var width = self.size.x
	var population_bar_width = floor(bottom / population.max_age)  # vertical width of a bar
	var middle_width = round(max(width * middle_min_width_ratio, middle_min_width))
	var left_midpoint = (width - middle_width) / 2
	var right_midpoint = (width + middle_width) / 2
	var current_bottom = bottom
	var maximum_age_group = max(population.population_male.max(), population.population_female.max())
	var max_bar_length = (width - middle_width) / 2 - margin * 2

	# draw horizontal label
	var magnitude = Utils.order_of_magnitude(maximum_age_group)
	var increment_population = max(pow(10, magnitude - 1), 1)
	var increments_number = maximum_age_group / increment_population
	var increment_width = float(max_bar_length) / increments_number
	for x in range(1, increments_number + 1):
		# draw female vertical line
		draw_line(
			Vector2(left_midpoint - margin - x * increment_width, 0),
			Vector2(left_midpoint - margin - x * increment_width, bottom),
			Color.BLACK,
			2 if x % 10 == 0 else 1
		)
		if x % 10 == 0:
			#draw female horizontal label
			draw_string(
				ThemeDB.fallback_font,
				Vector2(left_midpoint - margin - x * increment_width + 1, 0),
				str(int(x * increment_population)),
				HORIZONTAL_ALIGNMENT_LEFT,
				increment_width * 10 - 1,
				10
			)
		# draw male vertical line
		draw_line(
			Vector2(right_midpoint + margin + x * increment_width, 0),
			Vector2(right_midpoint + margin + x * increment_width, bottom),
			Color.BLACK,
			2 if x % 10 == 0 else 1
		)
		if x % 10 == 0:
			#draw male horizontal label
			draw_string(
				ThemeDB.fallback_font,
				Vector2(right_midpoint + margin + x * increment_width - (increment_width * 10 - 1), 0),
				str(int(x * increment_population)),
				HORIZONTAL_ALIGNMENT_RIGHT,
				increment_width * 10 - 1,
				10
			)
	for age in range(population.max_age + 1):
		# draw female bar
		var female_pop_percentage = float(population.population_female[age]) / maximum_age_group
		draw_line(
			Vector2(left_midpoint - margin, current_bottom - population_bar_width / 2),
			Vector2(
				left_midpoint - margin - max_bar_length * female_pop_percentage,
				current_bottom - population_bar_width / 2,
			),
			Color.DARK_RED,
			population_bar_width
		)

		# draw male bar
		var male_pop_percentage = float(population.population_male[age]) / maximum_age_group
		draw_line(
			Vector2(
				right_midpoint + margin,
				current_bottom - population_bar_width / 2,
			),
			Vector2(
				right_midpoint + margin + max_bar_length * male_pop_percentage,
				current_bottom - population_bar_width / 2,
			),
			Color.CORNFLOWER_BLUE,
			population_bar_width
		)
		# draw vertical label
		if age % population_label_frequency == 0:
			draw_line(
				Vector2(left_midpoint + margin, current_bottom - population_bar_width / 2),
				Vector2(right_midpoint - margin, current_bottom - population_bar_width / 2),
				Color.BLACK,
				population_bar_width
			)
			draw_string(
				ThemeDB.fallback_font,
				Vector2(left_midpoint + margin, current_bottom - population_bar_width),
				str(age),
				HORIZONTAL_ALIGNMENT_CENTER,
				middle_width - (margin * 2),
				10
			)
		current_bottom -= population_bar_width
