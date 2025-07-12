extends Node

#autoloaded as GlobalSignals

signal manual_resource_change  # resources changed by user click when buying something, not by tick
signal resources_recounted
signal unlock_job(job: int)
signal unlock_resource(resource: int)
signal unlock_section(hidden_section: int)
signal reveal_unlockable_section(hidden_section: int)
signal add_upgrade(upgrade: JobUpgrade)
