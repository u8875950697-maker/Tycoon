extends Node
class_name UIManager

var top_bar: TopBar
var tree_panel: Panel
var press_panel: Panel
var breeding_panel: Panel
var prestige_panel: Panel
var welcome_popup: AcceptDialog
var run_summary: AcceptDialog
var world_select: CanvasLayer

func register_top_bar(node: TopBar) -> void:
    top_bar = node

func register_tree_panel(node: Panel) -> void:
    tree_panel = node

func register_press_panel(node: Panel) -> void:
    press_panel = node

func register_breeding_panel(node: Panel) -> void:
    breeding_panel = node

func register_prestige_panel(node: Panel) -> void:
    prestige_panel = node

func register_welcome_popup(node: AcceptDialog) -> void:
    welcome_popup = node

func register_run_summary(node: AcceptDialog) -> void:
    run_summary = node

func register_world_select(node: CanvasLayer) -> void:
    world_select = node

func update_currencies(values: Dictionary) -> void:
    if top_bar:
        top_bar.set_currencies(values)

func update_world_status(name: String, hazard: Dictionary) -> void:
    if top_bar:
        top_bar.set_world_info(name, hazard)

func configure_world_buff(info: Dictionary, available: bool, status_text: String, tooltip: String) -> void:
    if top_bar:
        top_bar.set_world_buff(info, available, status_text)
        top_bar.set_buff_button_tooltip(tooltip)

func update_buff_badge(preview: Dictionary) -> void:
    if top_bar:
        top_bar.set_buff_badge(preview)

func show_tree_details(tree: TreeActor, info: Dictionary) -> void:
    if tree_panel and tree_panel is TreePanel:
        tree_panel.set_tree(tree, info)

func update_press_status(text: String) -> void:
    if press_panel and press_panel is PressPanel:
        press_panel.set_status(text)

func configure_dev_toggle(visible_flag: bool, enabled: bool) -> void:
    if press_panel and press_panel is PressPanel:
        press_panel.show_dev_toggle(visible_flag, enabled)

func configure_breeding(options: Dictionary) -> void:
    if breeding_panel and breeding_panel is BreedingPanel:
        var tree_ids: Array = options.get("tree_ids", [])
        breeding_panel.set_tree_options(tree_ids)
        breeding_panel.set_attempts_remaining(options.get("attempts", 0), options.get("cooldown_text", ""))
        breeding_panel.set_odds_text(options.get("odds", ""))
        breeding_panel.set_result(options.get("result", "Result:"))

func configure_prestige(leaves: int, purchased: Dictionary, bonuses: Dictionary) -> void:
    if prestige_panel and prestige_panel is PrestigePanel:
        prestige_panel.update_panel(leaves, purchased, bonuses)

func show_welcome_back(summary: String, resources: Dictionary, allow_ad: bool, allow_gem: bool) -> void:
    if welcome_popup:
        welcome_popup.configure(summary, resources, allow_ad, allow_gem)
        welcome_popup.popup_centered()

func show_run_summary(text: String) -> void:
    if run_summary:
        run_summary.show_summary(text)
        run_summary.popup_centered()

func show_world_select(worlds: Dictionary) -> void:
    if world_select and world_select is WorldSelect:
        world_select.populate_worlds(worlds)
        world_select.visible = true

func hide_world_select() -> void:
    if world_select:
        world_select.visible = false
