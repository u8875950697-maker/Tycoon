extends AcceptDialog
class_name WelcomeBackPopup

signal collect(mode: String)

@onready var summary_label: Label = $VBox/Summary
@onready var resources_label: RichTextLabel = $VBox/Resources
@onready var collect_button: Button = $VBox/Buttons/Collect
@onready var collect_ad_button: Button = $VBox/Buttons/CollectAd
@onready var collect_gem_button: Button = $VBox/Buttons/CollectGem
@onready var no_thanks_button: Button = $VBox/Buttons/NoThanks

func _ready() -> void:
    collect_button.pressed.connect(func(): _emit_collect("base"))
    collect_ad_button.pressed.connect(func(): _emit_collect("ad"))
    collect_gem_button.pressed.connect(func(): _emit_collect("gems"))
    no_thanks_button.pressed.connect(func(): _emit_collect("skip"))
    get_ok_button().visible = false

func configure(summary: String, resources: Dictionary, allow_ad: bool, allow_gem: bool) -> void:
    summary_label.text = summary
    resources_label.text = "Coins: %d\nMana: %d\nEssence: %d\nGems: %d" % [
        int(resources.get("coins", 0)),
        int(resources.get("mana", 0)),
        int(resources.get("essence", 0)),
        int(resources.get("gems", 0))
    ]
    collect_ad_button.disabled = not allow_ad
    collect_gem_button.disabled = not allow_gem

func _emit_collect(mode: String) -> void:
    hide()
    emit_signal("collect", mode)
