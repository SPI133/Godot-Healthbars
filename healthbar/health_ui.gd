## Health User Interface.
##
## This class is part of a tutorial on healthbars in Godot made by SPI133.
## @tutorial(Making some healthbars in the Godot Engine): https://www.youtube.com/watch?v=dVIj3norXeU

class_name HealthUI
extends Control


## Used in combination with [method Color.clamp] to avoid too bright colors for the 
## health bar.
const MAX_COLOR_VALUE : float = 0.8


## Duration for [member tween] and [member tween2].
const TWEEN_DURATION : float = 1.0


## Maximum amount of times [member bar_3_damage] flashes after taking damage.
const MAX_FLASH : int = 8


## Dictionary of [Texture]s used for the Kingdom Hearts healthbar.
const TEXTURES : Dictionary[String, Texture] = {
	"happy" : preload("res://godot.png"),
	"sad" : preload("res://godot sad.png"),
	"dead" : preload("res://godot dead.png"),
	"damaged" : preload("res://godot_damage.png")
}


## The sad texture will be displayed if [member health] is below this value.
const SAD_HEALTH_THRESHOLD : int = 30


const KH_CIRCULAR_BAR_MAX : int = 60


## Width of the heart. Used for the hearts healthbar.
const HEART_WIDTH : int = 76


#region Horizontal healthbar
## Simple horizontal healthbar.
@onready var bar_1 : ProgressBar = $Bar1

## Damage indicator for [member bar_1]. Uses a [member tween] to update its value to health.
@onready var bar_1_damage : ProgressBar = $Bar1/Bar1Damage


## Shows the amount of health on [member bar_1].
@onready var label : Label = $Bar1/Label


## Used for [member bar_1_damage].
var tween : Tween
#endregion

## Horizontal shield bar. It's starting x position is at the end of
## the current health.
@onready var shield_bar : ProgressBar = $ShieldBar


## Simple horizontal [TextureProgressBar] to display health.
@onready var bar_2 : TextureProgressBar = $Bar2

#region Health segments
## Horizontal [TextureProgressBar] with health segments. 
## Each segment corresponds to 10% of the maximum health.
@onready var bar_3 : TextureProgressBar = $Bar3


## Damage indicator for [member bar_3]. It's length is one segment ahead when of the 
## health when taking damage. Else, it's on the same segment as health. 
## Uses [member timer] to flash [member max_flash] / 2 times.
@onready var bar_3_damage : TextureProgressBar = $Bar3/Bar3Damage


## Used for [member bar_3_damage].
@onready var timer : Timer = $Timer


## Amount of health that corresponds to 10% of the [member max_health].
var segment_step : int


## Keeps track of how many times [member bar_3_damage] after taking damage.
var flash_count : int = 0
#endregion


## Circular healthbar.
@onready var bar_4 : TextureProgressBar = $Bar4


#region Kingdom Hearts style healthbar
## Circular part of the Kingdom Hearts style healthbar.
@onready var bar_5 : TextureProgressBar = $Bar5


## Damage indicator for [member bar_5]. Uses [member tween2] to update its value to health.
@onready var bar_5_damage : TextureProgressBar = $Bar5/Bar5Damage


## Horizontal part of the Kingdom Hearts style healthbar.
@onready var bar_6 : TextureProgressBar = $Bar6


## Damage indicator for [member bar_6]. Uses [member tween2] to update its value to health.
@onready var bar_6_damage : TextureProgressBar = $Bar6/Bar6Damage


## Used for [member bar_5_damage] and [member bar_6_damage].
var tween2 : Tween


## Displays the Godot mascot in the Kingdom Hearts style healthbar.
@onready var texture_rect : TextureRect = $TextureRect


## Displays the Godot mascot in the Kingdom Hearts style healthbar taking damage.
@onready var texture_rect_2 : TextureRect = $TextureRect2


## Used to hide [member texture_rect_2] after taking damage. 
@onready var timer_2 : Timer = $Timer2
#endregion


#region Hearts healthbar
## Empty hearts for the hearts healthbar. They show the maximum health.
@onready var empty_hearts : TextureRect = $EmptyHearts


## Full hearts for the hearts healthbar. They show the current health.
@onready var full_hearts : TextureRect = $FullHearts


## Shield hearts for the hearts healthbar. They show the current shield.
@onready var shield_hearts : TextureRect = $ShieldHearts


## The amount of hearts in Hearts healthbar.
## This can be set to const if maximum health cannot be upgraded.
var max_heart_amount : int = 5


## The part of the heart that takes 1 health.
var heart_step : float
#endregion


## Maximum health. This can also be set to const if maximum health cannot be upgraded.
var max_health : int = 100


## Current health. The setter calls the methods [method update_bar1], [method update_bar2], 
## [method update_bar4], [method update_bar5_6] and [method update_hearts].
var health : int :
	set(val):
		var healing : bool = val >= health
		health = clampi(val, 0, max_health)
		var ratio : float = health / float(max_health)
		update_bar1(healing, ratio)
		update_bar2(ratio)
		update_bar3(healing)
		update_bar4(ratio)
		update_bar5_6(healing, ratio)
		update_hearts()


## Maximum shield. This can also be set to const if maximum shield cannot be upgraded.
var max_shield : int = 40


## Currrent shield. The setter calls the methods [method update_shield_bar] and 
## [method update_shield_hearts].
var shield : int :
	set(val):
		shield = clampi(val, 0, max_shield)
		update_shield_bar()
		update_shield_hearts()


func _ready() -> void:
	# Bar1 Horizontal healthbar
	bar_1.max_value = max_health
	bar_1_damage.max_value = max_health
	
	#Shield
	shield_bar.max_value = max_health 
	shield_bar.position.x = bar_1.position.x + bar_1.value / max_health * bar_1.size.x
	
	# Bar2 Horizontal texture
	bar_2.max_value = max_health
	
	# Bar3 Segments
	bar_3.max_value = max_health
	bar_3_damage.max_value = max_health
	segment_step = int(max_health * 0.1)
	
	# Bar4 Circular
	bar_4.max_value = max_health
	
	# Bar5_6 Kingdom Hearts style healthbar
	bar_5.max_value = KH_CIRCULAR_BAR_MAX
	bar_5_damage.max_value = bar_5.max_value
	bar_6.min_value = bar_5.max_value
	bar_6_damage.min_value = bar_5.max_value
	bar_6.max_value = max_health
	bar_6_damage.max_value = max_health
	
	# Hearts
	heart_step = HEART_WIDTH / float(max_health) * max_heart_amount
	empty_hearts.size.x =  max_health * heart_step
	full_hearts.size.x = empty_hearts.size.x
	shield_hearts.position.x = empty_hearts.position.x + empty_hearts.size.x
	
	health = max_health
	shield = 0


## To test changes in health and shield. 
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		heal(10)
	if Input.is_action_just_pressed("ui_cancel"):
		take_damage(10)
	if Input.is_action_just_pressed("ui_focus_next"):
		gain_shield(10)


## Increases [member health] by [param amount].
func heal(amount : int) -> void:
	health += amount


## Decreases [member shield] by [param amount] if it's positive.
## If [param amount] is greater than shield, their difference will 
## be subtracted from [param health].
func take_damage(amount : int) -> void:
	if shield: # Same as shield != 0
		var remain : int = amount - shield
		shield -= amount
		amount = remain
	if amount > 0:
		health -= amount


## Increases [member shield] by [param amount].
func gain_shield(amount : int) -> void:
	shield += amount


## Returns a [Color] where [member Color.r] is [code]1-ratio[/code], 
## [member Color.g] is [code]ratio[/code],
## [member Color.b] is [code]0[/code] and
## [member Color.a] is [code]1[/code].
## Maximum value for [member Color.r] and [member Color.g] is [constant MAX_COLOR_VALUE].
func get_color(ratio : float) -> Color:
	return Color(1 - ratio, ratio, 0).clamp(Color.BLACK, Color(MAX_COLOR_VALUE, MAX_COLOR_VALUE, 0))


## Updates [member bar_1]. If health decreased, [param healing] is [code]false[/code] 
## and [param ratio] is the health ratio.
func update_bar1(healing : bool, ratio : float) -> void:
	label.text = str(health)
	bar_1.value = health
	var stylebox : StyleBox = bar_1.get_theme_stylebox("fill")
	stylebox.bg_color = get_color(ratio)
	if healing:
		if health > bar_1_damage.value and tween: 
			tween.kill()
		bar_1_damage.value = health
	else:
		if tween:
			tween.kill()
		tween = get_tree().create_tween()
		tween.tween_property(bar_1_damage, "value", health, TWEEN_DURATION)
	shield_bar.position.x = bar_1.position.x + ratio * bar_1.size.x 


## Updates [shield_bar].
func update_shield_bar() -> void:
	shield_bar.value = shield


## Updates [member bar_2].
func update_bar2(ratio : float) -> void:
	bar_2.value = health
	bar_2.tint_progress = get_color(ratio)


## Updates [member bar_3].
func update_bar3(healing : bool) -> void:
	bar_3.value = health
	if healing:
		bar_3_damage.value = health
		timer.stop()
		bar_3_damage.visible = false
	else:
		bar_3_damage.value = health + segment_step
		flash_count = 0
		timer.start()


## Updates [member bar_4].
func update_bar4(ratio : float) -> void:
	bar_4.value = health
	bar_4.tint_progress = get_color(ratio)


## Updates [member bar_5].
func update_bar5_6(healing : bool, ratio : float) -> void:
	bar_5.value = health
	bar_6.value = health
	bar_5.tint_progress = get_color(ratio)
	bar_6.tint_progress = get_color(ratio)
	if healing:
		if bar_6.value > bar_6_damage.value:
			if tween2:
				tween2.kill()
			bar_5_damage.value = health
			bar_6_damage.value = health
		elif bar_5.value > bar_5_damage.value:
			if tween2:
				tween2.kill()
			tween2 = get_tree().create_tween()
			tween2.tween_property(bar_6_damage, "value", health, TWEEN_DURATION)
			bar_5_damage.value = health
		
		var key : String = "dead" if health == 0 else "sad" if health < SAD_HEALTH_THRESHOLD else "happy"
		texture_rect.texture = TEXTURES[key]
		texture_rect.modulate = Color.WHITE
	else:
		if tween2: 
			tween2.kill()
		var bar6_time : float = TWEEN_DURATION * (bar_6_damage.value - bar_6.value) / (bar_6_damage.value - health)
		var bar5_time : float = TWEEN_DURATION - bar6_time
		if is_nan(bar6_time): # Sometimes bar6_time could be set to NAN.
			bar6_time = 0
			bar5_time = 0
		tween2 = get_tree().create_tween()
		tween2.tween_property(bar_6_damage, "value", health, bar6_time)
		tween2.tween_property(bar_5_damage, "value", health, bar5_time)
		
		# The alternative: Two TextureRects. One for taking damage and the default.
		#texture_rect.hide()
		#texture_rect_2.show()
		#timer_2.start()
		
		texture_rect.texture = TEXTURES["damaged"]
		texture_rect.modulate = Color.RED
		timer_2.start()


## Updates [member full_hearts].
func update_hearts() -> void:
	full_hearts.size.x = heart_step * health


## Updates [member shield_hearts].
func update_shield_hearts() -> void:
	shield_hearts.size.x = heart_step * shield


## Increases [member flash_count] by [code]1[/code], changes the visibility of 
## [member bar_3_damage] and if [member flash_count] is less than 
## [constant flash_count], it starts the timer again.
func _on_timer_timeout() -> void:
	flash_count = flash_count + 1
	bar_3_damage.visible = flash_count % 2
	if flash_count < MAX_FLASH:
		timer.start()


## Changes the [member Texture.texture] of [member texture_rect] based on the 
## current health and resets modulate to [constant Color.WHITE].
func _on_timer_2_timeout() -> void:
	# The alternative: Two TextureRects. One for taking damage and the default.
	#texture_rect_2.hide()
	#texture_rect.show()
	
	var key : String = "dead" if health == 0 else "sad" if health < SAD_HEALTH_THRESHOLD else "happy" 
	texture_rect.texture = TEXTURES[key]
	texture_rect.modulate = Color.WHITE
