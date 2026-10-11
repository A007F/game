extends Node
class_name CompanionLoyaltySystem

signal bond_level_up(new_level: int)

var bond_level: int = 1
var loyalty_xp: int = 0
var xp_to_next_bond: int = 100

func add_loyalty_xp(amount: int) -> void:
	loyalty_xp += amount
	GameLog.info("Companion gained %d Loyalty XP (Total: %d/%d)" % [amount, loyalty_xp, xp_to_next_bond])

	while loyalty_xp >= xp_to_next_bond and bond_level < 5:
		loyalty_xp -= xp_to_next_bond
		bond_level += 1
		xp_to_next_bond = int(xp_to_next_bond * 1.6)
		bond_level_up.emit(bond_level)
		GameLog.info("KA-TET BOND LEVEL UP! Reached Bond Level %d!" % bond_level)

func is_triage_unlocked() -> bool:
	return bond_level >= 3

func is_master_synergy_unlocked() -> bool:
	return bond_level >= 5
