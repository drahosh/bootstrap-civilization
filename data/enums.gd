extends RefCounted

class_name Enums

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
static var MAX = "MAX"  # used when muying multiples
