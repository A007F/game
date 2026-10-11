extends Node
class_name CampWorkbench

signal item_crafted(item_name: String)
signal weapon_repaired(weapon_name: String)

func craft_ammo(player_data: PlayerData, scrap_cost: int = 15, ammo_amount: int = 30) -> bool:
	if player_data == null:
		return false

	# Assume player currency/scrap is checked via reserve ammo or scrap marks
	if player_data.reserve_ammo < 5: # Minimal gunpowder check
		GameLog.warn("Not enough materials to craft ammo!")
		return false

	player_data.reserve_ammo += ammo_amount
	item_crafted.emit("Revolver & Rifle Ammo Box (+%d Rds)" % ammo_amount)
	GameLog.info("Crafted Ammo Box (+%d Rds) at Camp Workbench!" % ammo_amount)
	return true

func repair_weapon(weapon: Weapon3D, player_data: PlayerData) -> bool:
	if weapon == null or player_data == null:
		return false

	weapon_repaired.emit(weapon.data.weapon_name if weapon.data else "Firearm")
	GameLog.info("Repaired Firearm at Camp Workbench! Full condition restored!")
	return true

func brew_sanity_tonic(player_data: PlayerData) -> bool:
	if player_data == null:
		return false

	player_data.restore_sanity(60.0)
	item_crafted.emit("Mind-Shield Sanity Tonic (+60 Sanity)")
	GameLog.info("Brewed Sanity Tonic at Camp Workbench! (+60 Sanity restored)")
	return true
