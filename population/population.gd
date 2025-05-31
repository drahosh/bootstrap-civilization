extends VBoxContainer

class_name Population

const Enums = preload("res://data/enums.gd")
#maximum age of living population, extends graph
var max_age = 60
# Called when the node enters the scene tree for the first time.
var death_rates: Array
var birth_rates: Array
var work_rates: Array
var population_male: Array
var population_female: Array
var workforce_total: int
var population_change: int = 0
var workforce_change: int = 0
# Death rate stats
var zero_death_rate = 0.3
var juvenile_death_rate = 0.03
var adult_death_rate = 0.01
var elder_cutoff = 40  #also counts as birth rate stat
var age_death_rate_exponential = 1.5

# birth rate stats
var adult_birth_rate = 0.1
var age_birth_rate_exponential = 0.5
var female_birth_influence = 0.9  # this * female pop + (1-this) * male pop is base for reproduction

# workforce rate stats

var adult_work_rate = 1.0
var female_work_multiplier = 0.9
var male_work_multiplier = 1.1
var old_work_exponential = 0.95
var young_work_exponential = 0.9
var start_working_age = 8


func _get_population_total():
	return Utils.sum_array(population_male) + Utils.sum_array(population_female)


func add_death_rate():
	# when max age is extended, adds new death rate exponential from oldest existing death rate
	death_rates.append(death_rates[-1] * age_death_rate_exponential)


func recalculate_death_rates():
	# called after upgrade changing death rate stats
	death_rates = []
	death_rates.append(0.3)
	for i in range(1, 18):
		death_rates.append(0.03)
	for i in range(18, elder_cutoff):
		death_rates.append(0.01)
	for i in range(elder_cutoff, max_age + 1):
		add_death_rate()


func add_birth_rate():
	# same as add_death_rate but  for birth rate
	birth_rates.append(death_rates[-1] * age_death_rate_exponential)


func recalculate_birth_rates():
	# same as recalculate_death_rates but for birth rate
	birth_rates = []
	for i in range(18):
		birth_rates.append(0)
	for i in range(18, elder_cutoff):
		birth_rates.append(adult_birth_rate)
	for i in range(elder_cutoff, max_age + 1):
		add_birth_rate()


func add_work_rate():
	# same as add_death_rate but for work rate
	work_rates.append(work_rates[-1] * old_work_exponential)


func recalculate_work_rates():
	# same as recalculate_death_rates but for work rate
	work_rates.resize(19)
	work_rates.fill(0)
	work_rates[18] = adult_work_rate
	for i in range(17, start_working_age - 1, -1):
		work_rates[i] = work_rates[i + 1] * young_work_exponential
	for i in range(19, elder_cutoff):
		work_rates.append(adult_work_rate)
	for i in range(elder_cutoff, max_age + 1):
		add_work_rate()


func _setup_population():
	population_male.resize(max_age + 1)
	population_female.resize(max_age + 1)
	population_male.fill(0)
	population_female.fill(0)
	for i in range(30):
		population_female[i] = 10
		population_male[i] = 10


func _increase_age():
	# Makes everyone one year older
	# could mix with death and birth into one function to reduce performance cost of push_front,
	# but i don't think it will be needed
	if population_female[max_age] > 0 or population_male[max_age] > 0:
		print("increasing max age")
		max_age += 1
		add_birth_rate()
		add_death_rate()
		add_work_rate()
	else:
		population_female.pop_back()
		population_male.pop_back()
	population_female.push_front(0)
	population_male.push_front(0)


func _eat_food():
	# eats food (decreases the static resource), returns proportion of desired consumption that was sated
	var desired_consumption = _get_population_total()
	var food = Resources.resources[Enums.resource_types.FOOD]
	if food > desired_consumption:
		Resources.resources[Enums.resource_types.FOOD] -= desired_consumption
		Resources.resource_changes[Enums.resource_types.FOOD] -= desired_consumption
		return 1
	else:
		Resources.resource_changes[Enums.resource_types.FOOD] -= food

		var satiety = float(food) / desired_consumption
		Resources.resources[Enums.resource_types.FOOD] = 0
		return satiety


func _calculate_work(satiety):
	# Get total workforce for population
	var satiety_factor  # no food gets you only 10% of work
	if satiety >= 0.7:
		satiety_factor = 1
	else:
		satiety_factor = 0.3 + satiety
	var new_workforce = 0.0
	for i in range(start_working_age, max_age):
		new_workforce += population_female[i] * work_rates[i] * female_work_multiplier
		new_workforce += population_male[i] * work_rates[i] * male_work_multiplier
	new_workforce = floor(new_workforce * satiety_factor)
	workforce_change = new_workforce - workforce_total
	workforce_total = new_workforce


func _calculate_births(satiety):
	# adds new 0 year old people
	var births_female = 0
	var births_male = 0
	for i in range(18, max_age):
		var potential = (
			satiety
			* (population_female[i] * female_birth_influence + population_male[i] * (1 - female_birth_influence))
		)
		births_female += Utils.simulate_random_events(round(potential / 2), birth_rates[i])
		births_male += Utils.simulate_random_events(round(potential / 2), birth_rates[i])
	population_female[0] = births_female
	population_male[0] = births_male


func _calculate_deaths(satiety):
	# remove people. each person has death rate chance to die each turn
	var satiety_multiplier
	if satiety >= 0.7:
		satiety_multiplier = 1
	else:
		satiety_multiplier = 1 + (0.7 - satiety) * 9
	for i in range(max_age):
		population_female[i] -= Utils.simulate_random_events(population_female[i], death_rates[i] * satiety_multiplier)
		population_male[i] -= Utils.simulate_random_events(population_male[i], death_rates[i] * satiety_multiplier)


func _redraw_ui():
	get_node("Pyramid").queue_redraw()
	get_node("Label").text = "Population:%s\nBase workforce:%s" % [_get_population_total(), workforce_total]


func tick():
	var old_population = _get_population_total()
	_increase_age()
	var satiety = _eat_food()  # 1 means everyone has more than enough food, 0 means total starvation
	_calculate_work(satiety)
	_calculate_births(satiety)
	_calculate_deaths(satiety)
	population_change = _get_population_total() - old_population
	_redraw_ui()


func _ready():
	_setup_population()
	get_node("Pyramid").set_population(self)
	recalculate_death_rates()
	recalculate_birth_rates()
	recalculate_work_rates()
	_redraw_ui()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
