extends Resource
class_name WeaponAttachmentData

@export var attachment_name: String = "Telescopic Scope"
@export var attachment_type: String = "SCOPE" ## SCOPE, BARREL, GRIP, MAGAZINE
@export var damage_multiplier: float = 1.0
@export var recoil_multiplier: float = 0.7 ## 30% recoil reduction
@export var range_multiplier: float = 1.5  ## 50% range increase
@export var spread_multiplier: float = 0.5 ## 50% tighter spread
@export var zoom_fov_bonus: float = 15.0   ## Extra FOV zoom when aiming
