extends CanvasLayer

@onready var panel: Panel = $Panel
@onready var speaker_label: Label = $Panel/MarginContainer/VBoxContainer/SpeakerLabel
@onready var dialogue_label: Label = $Panel/MarginContainer/VBoxContainer/DialogueLabel

# Tracks which system currently "owns" the displayed message,
# so one system can't accidentally hide another system's dialogue.
var current_owner: String = ""


func _ready() -> void:
	panel.visible = false


func show_dialogue(speaker: String, text: String, owner_id: String = "") -> void:
	speaker_label.text = speaker
	dialogue_label.text = text
	panel.visible = true
	current_owner = owner_id


func hide_dialogue(owner_id: String = "") -> void:
	# If this call comes from a specific owner, only hide if it's still
	# that owner's message currently showing. An empty owner_id always hides.
	if owner_id != "" and owner_id != current_owner:
		return

	panel.visible = false
	current_owner = ""
