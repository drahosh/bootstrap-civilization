extends Node
# Autoloaded as PrestigeData
var prestige_upgrades = {}  # dict of prestige data
var prestige_points = 0
var upgrade_points = 0
const base_upgrade_point_cost = 200
const upgrade_point_cost_multiplier = 1.2


func _ready():
	# create each prestige upgrade
	# When modifying after release, make sure to make changes in a way compatible with old saves
	prestige_upgrades = {
		Enums.prestige_upgrades.REMOVE_RECREATION:
		PrestigeUpgrade.new(
			Enums.prestige_upgrades.REMOVE_RECREATION,
			"Wait, is recreation supposed to be a job?",
			"Remove recreation. Instead, get 0.1 culture for each workforce unused or ungained due to persons age",
			Enums.prestige_upgrade_type.UNLOCK,
			2,
			func(): GlobalSignals.unlock_resource.emit(Enums.resource_types.CULTURE)
		),
		Enums.prestige_upgrades.REDUCE_EXPANSION_SCALING:
		PrestigeUpgrade.new(
			Enums.prestige_upgrades.REDUCE_EXPANSION_SCALING,
			"Expansion efficiency",
			"Organise better, reducing cost scaling of job expansions by 0.05 (default is 1.3)",
			Enums.prestige_upgrade_type.UPGRADE,
			10,
			func(): GlobalVariables.job_expand_scale -= 0.05
		),
		Enums.prestige_upgrades.UNLOCK_ARTMAKING:
		PrestigeUpgrade.new(
			Enums.prestige_upgrades.UNLOCK_ARTMAKING,
			"Unlock Artmaking",
			"Unlock a new job that produces culture and luxury",
			Enums.prestige_upgrade_type.UNLOCK,
			5,
			func():
				GlobalSignals.unlock_job.emit(Enums.jobs.ARTMAKING)
				GlobalSignals.unlock_resource.emit(Enums.resource_types.CULTURE)
				GlobalSignals.unlock_resource.emit(Enums.resource_types.LUXURY),
		)
	}


func is_upgrade_enabled(upgrade: int):
	return prestige_upgrades[upgrade].enabled


func load_game(data):
	prestige_points = int(data["prestige_points"])
	upgrade_points = calculate_upgrade_ponts(prestige_points)["upgrade_points"]
	for key in data["upgrades"]:
		prestige_upgrades[int(key)].load_game(data["upgrades"][key])


func save_game():
	var data = {"prestige_points": prestige_points, "upgrades": {}}
	for id in prestige_upgrades:
		data["upgrades"][id] = prestige_upgrades[id].save_game()

	return data


func calculate_prestige_points(max_total_population, final_age):
	return max_total_population * pow(2, final_age)


func calculate_upgrade_ponts(prestige_points) -> Dictionary:
	# returns dict of 3 values:
	# - upgrade_points - number of total upgrade points unlocked
	# - next - number of prestige points required for next upgrade point
	var next_cost = base_upgrade_point_cost
	var upgrade_points = 0
	while true:
		prestige_points -= next_cost
		if prestige_points >= 0:
			upgrade_points += 1
			next_cost = floor(next_cost * upgrade_point_cost_multiplier)
		else:
			break
	return {"upgrade_points": upgrade_points, "next": -prestige_points}


func apply_prestige_upgrades():
	# ran after prestiging and on game load
	for upgrade in prestige_upgrades.values():
		upgrade.apply_if_enabled()


func calculate_next_prestige(max_population, age):
	# used in UI when deciding whether to prestige
	# returns Dictionary:
	# - upgrade_points_added - number of upgrade points player would get if they prestige now
	# - next - number of prestige points needed for next upgrade point

	var added_presige_points = calculate_prestige_points(max_population, age)
	var next = calculate_upgrade_ponts(prestige_points + added_presige_points)
	var current = calculate_upgrade_ponts(prestige_points)
	return {"upgrade_points": next["upgrade_points"] - current["upgrade_points"], "next": next["next"]}


func prestige(max_population, age):
	prestige_points += calculate_prestige_points(max_population, age)
	upgrade_points = calculate_upgrade_ponts(prestige_points)["upgrade_points"]
