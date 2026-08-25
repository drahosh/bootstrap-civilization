# Autoloaded as GlobalVariables
# Contains variables that can change during game (mostly by prestiging)
extends Node

# JOB
var job_expand_scale = 1.3

# JOB UPGRADE
var capacity_upgrade_size = 1.2  # increases by percentage
var capacity_upgrade_base_cost = {Enums.resource_types.CULTURE: 100}
var job_upgrade_scale = 1.5

# RESEARCH
var research_scale = 2
var research_delay_scale = 1.5
var research_input_ratio = 0.05
