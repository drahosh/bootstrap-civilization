extends RefCounted

class_name Enums

# contains global enums and constants (static var dicts are technically mutable in code but i don't intend to change them anywhere)
enum resource_types {
	FOOD,
	MATERIALS,
	TEXTILES,
	METALS,
	TOOLS,
	CULTURE,
	CLOTHES,
	TERRITORY,
	KNOWLEDGE,
	LUXURY,
}
static var resource_names = {
	resource_types.FOOD: "Food",
	resource_types.MATERIALS: "Materials",
	resource_types.TEXTILES: "Fabrics",
	resource_types.METALS: "Metals",
	resource_types.TOOLS: "Tools",
	resource_types.CULTURE: "Culture",
	resource_types.CLOTHES: "Clothes",
	resource_types.TERRITORY: "Territory",
	resource_types.KNOWLEDGE: "Knowledge",
	resource_types.LUXURY: "Luxury",
}
static var perishable_resources = {
	resource_types.CULTURE: 0.01,
	resource_types.FOOD: 0.1,
	resource_types.KNOWLEDGE: 0.05,
}
enum jobs {
	GATHERING,  # TODO also works as farming
	HUNTING,
	TOOLMAKING,
	RECREATION,
	CLOTHESMAKING,
	WOODCUTTING,
	ARTMAKING,
	FARMING,
}
static var land_based_jobs = [jobs.GATHERING, jobs.HUNTING, jobs.WOODCUTTING, jobs.FARMING]
static var job_names = {
	jobs.GATHERING: "Gathering",
	jobs.HUNTING: "Hunting",
	jobs.TOOLMAKING: "Toolmaking",
	jobs.RECREATION: "Recreation",
	jobs.CLOTHESMAKING: "ClothesMaking",
	jobs.WOODCUTTING: "Woodcutting",
	jobs.ARTMAKING: "Artmaking",
	jobs.FARMING: "Farming",
}
enum unlock_state {
	INVISIBLE,  # The revelation of unlock itself is not yet unlocked
	LOCKED,
	UNLOCKED,
	RESOLVED,  # used for disasters
}

static var unlock_name_to_class = {
	# used when loading for serialization
	"UnlockClothesmaking": UnlockClothesmaking,
	"UnlockRecreation": UnlockRecreation,
	"UnlockUpgrades": UnlockUpgrades,
	"UnlockResearch": UnlockResearch,
	"DisasterCompetition": DisasterCompetition,
}

# sections of UI that are not visible at the beginning
enum UnlockableSections {
	UPGRADES,
	RESEARCH,
	PRESTIGE,
}

enum job_upgrade_types {
	CAPACITY,
	THROUGHPUT,
	EFFICIENCY,
	OUTPUT,
}

enum research_type {
	# need to keep them with stable ids, so using multiples of 10 to make room in between
	# Also keeping them in order from lowest to highest (otherwise would have to sort in research list)
	# Posive are voluntary, negative are tempting
	WARRIORS = -20,
	RELIGION = -10,
	WOODCUTTING = 10,
	FIBERS = 20,
	BONES = 30,
	DOGS = 40,
	BIRDS = 50,
	FARMING = 60,
	CATS = 70,
	GRANARY = 80,
}
static var research_type_to_class = {
	research_type.WOODCUTTING: ResearchWoodcutting,
	research_type.FIBERS: ResearchFibers,
	research_type.BONES: ResearchBones,
	research_type.DOGS: ResearchDogs,
	research_type.BIRDS: ResearchBirds,
	research_type.FARMING: ResearchFarming,
	research_type.CATS: ResearchCats,
	research_type.GRANARY: ResearchGranary,
	research_type.RELIGION: CResearchReligion,
	research_type.WARRIORS: CResearchWarriors,
}
enum research_job_changes {
	CHANGE_OUTPUT,
	OUTPUT_MULTIPLIER,
	CAPACITY_MULTIPLIER,
	NEW_JOB_TYPE,
}

enum crises {
	COMPETITION,
}
static var crisis_to_class = {
	crises.COMPETITION: CrisisCompetition,
}
enum ages {
	# numbers are used for exponent prestige calculation
	NOMADIC = 0,
	SETTLED = 1,
}
static var age_names = {
	ages.NOMADIC: "Nomadic",
	ages.SETTLED: "Settled",
}
enum prestige_upgrade_type {
	UPGRADE,
	UNLOCK,
	BOOTSTRAP,
}
enum prestige_upgrades {
	REMOVE_RECREATION,
	REDUCE_EXPANSION_SCALING,
	UNLOCK_ARTMAKING,
}
