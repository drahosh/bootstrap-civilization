extends Node

#Node autoloaded as GlobalSignals

signal manual_resource_change  # resources changed by user click when buying something, not by tick
signal unlock_job(job: int)
signal unlock_resource(resource: int)
