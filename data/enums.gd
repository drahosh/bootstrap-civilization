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
}
static var resource_names = {
	resource_types.FOOD: "Food",
	resource_types.MATERIALS: "Materials",
	resource_types.TEXTILES: "Textiles",
	resource_types.METALS: "Metals",
	resource_types.TOOLS: "Tools",
	resource_types.CULTURE: "Culture",
	resource_types.CLOTHES: "Clothes",
	resource_types.TERRITORY: "Territory"
}
enum jobs {
	GATHERING,
	HUNTING,
	TOOLMAKING,
	RECREATION,
	CLOTHMAKING,
}
static var job_names = {
	jobs.GATHERING: "Gathering",
	jobs.HUNTING: "Hunting",
	jobs.TOOLMAKING: "Toolmaking",
	jobs.RECREATION: "Recreation",
	jobs.CLOTHMAKING: "ClothMaking",
}
const MAX = "MAX"  # used when muying multiples
enum unlock_state {
	INVISIBLE,  # The revelation of unlock itself is not yet unlocked
	LOCKED,
	UNLOCKED,
}

static var unlock_name_to_class = {
	# used when loading for serialization
	"UnlockClothmaking": UnlockClothmaking,
	"UnlockRecreation": UnlockRecreation,
}
