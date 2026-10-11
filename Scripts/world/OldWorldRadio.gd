extends Node3D
class_name OldWorldRadio

signal broadcast_started(track_title: String)
signal broadcast_stopped()

var is_playing: bool = false
var current_track_index: int = 0

var radio_tracks: Array[Dictionary] = [
	{ "title": "Acoustic Western - Dust of Mid-World", "lore": "Signal 104.2: The world has moved on, yet the Gunslinger's revolver remains true." },
	{ "title": "Gilead Memories - Acoustic Folk", "lore": "Audio Archive #19: Before the Beam cracked, Gilead stood proud as a beacon of honor." },
	{ "title": "Dark Tower Ambient Strings", "lore": "Radio Interference: Beware the Taheen near the waystations after midnight." }
]

func toggle_radio() -> void:
	is_playing = not is_playing
	if is_playing:
		var track: Dictionary = radio_tracks[current_track_index]
		broadcast_started.emit(track.title)
		GameLog.info("RADIO ON: Playing '%s' | Lore: %s" % [track.title, track.lore])
	else:
		broadcast_stopped.emit()
		GameLog.info("RADIO OFF")

func next_track() -> void:
	current_track_index = (current_track_index + 1) % radio_tracks.size()
	if is_playing:
		toggle_radio() # Restart with new track
		toggle_radio()
