extends Node3D
class_name WorldSceneController

const TREE_SCENE := preload("res://scenes/Tree.tscn")
const PLOT_SCENE := preload("res://scenes/Plot.tscn")

@onready var plots_root: Node3D = $GridRoot/Plots
@onready var top_bar: TopBar = $UI/TopBar
@onready var tree_panel: TreePanel = $UI/TreePanel
@onready var press_panel: PressPanel = $UI/PressPanel
@onready var breeding_panel: BreedingPanel = $UI/BreedingPanel
@onready var prestige_panel: PrestigePanel = $UI/PrestigePanel
@onready var welcome_popup: WelcomeBackPopup = $UI/WelcomeBack
@onready var run_summary: RunSummaryPopup = $UI/RunSummary
@onready var world_select: WorldSelect = $WorldSelect

var plots: Array = []
var selected_plot: PlotTile = null
var selected_tree: TreeActor = null
var plant_menu := PopupMenu.new()
var active_buffs := {
    "growth": {"time": 0.0, "mult": 1.0},
    "harvest": {"time": 0.0, "mult": 1.0},
    "drop": {"time": 0.0, "mult": 1.0}
}
var last_currency_update := 0.0
var rng := RandomNumberGenerator.new()

func _ready() -> void:
    GameState.initialize()
    rng.randomize()
    $UI.add_child(plant_menu)
    plant_menu.id_pressed.connect(_on_plant_selected)
    _register_ui()
    _build_grid()
    _restore_saved_trees()
    UIManager.show_tree_details(null, {})
    _refresh_top_bar()
    _refresh_press_panel()
    _refresh_breeding_panel()
    _refresh_prestige_panel()
    _refresh_world_info()
    if GameState.has_offline_rewards():
        UIManager.show_welcome_back(GameState.offline_result.get("summary", ""), GameState.offline_result, GameState.monetization.get("offline_double_ads", true) and GameState.can_use_ad(), GameState.monetization.get("offline_double_gems", true))
    UIManager.show_world_select(WorldController.get_worlds())
    world_select.world_chosen.connect(_on_world_chosen)
    welcome_popup.collect.connect(_on_welcome_collect)
    tree_panel.care_requested.connect(_on_care_requested)
    tree_panel.remove_requested.connect(_on_remove_requested)
    press_panel.craft_requested.connect(_on_craft_requested)
    press_panel.dev_cheats_toggled.connect(_on_dev_toggle)
    breeding_panel.breed_requested.connect(_on_breed_requested)
    prestige_panel.prestige_requested.connect(_on_prestige_requested)
    prestige_panel.upgrade_requested.connect(_on_upgrade_requested)
    run_summary.continue_requested.connect(_on_continue_requested)
    run_summary.prestige_requested.connect(_on_prestige_requested)
    set_process(true)

func _register_ui() -> void:
    UIManager.register_top_bar(top_bar)
    UIManager.register_tree_panel(tree_panel)
    UIManager.register_press_panel(press_panel)
    UIManager.register_breeding_panel(breeding_panel)
    UIManager.register_prestige_panel(prestige_panel)
    UIManager.register_welcome_popup(welcome_popup)
    UIManager.register_run_summary(run_summary)
    UIManager.register_world_select(world_select)
    UIManager.configure_dev_toggle(GameState.monetization.get("dev_cheats", false), false)
    world_select.visible = true

func _build_grid() -> void:
    for child in plots_root.get_children():
        child.queue_free()
    plots.clear()
    var grid := WorldController.get_grid_size()
    var spacing := 2.4
    var index := 0
    for y in range(grid.y):
        for x in range(grid.x):
            var plot: PlotTile = PLOT_SCENE.instantiate()
            plot.index = index
            plot.position = Vector3((x - (grid.x / 2.0) + 0.5) * spacing, 0, (y - (grid.y / 2.0) + 0.5) * spacing)
            plot.plot_selected.connect(_on_plot_selected)
            plot.unlock_requested.connect(_on_unlock_requested)
            plots_root.add_child(plot)
            plots.append(plot)
            index += 1

func _restore_saved_trees() -> void:
    for plot in plots:
        plot.remove_tree()
        var unlocked := GameState.is_slot_unlocked(GameState.current_world_id, plot.index)
        var base_slots := WorldController.get_base_slots(GameState.current_world_id)
        if plot.index < base_slots:
            unlocked = true
            GameState.unlock_slot(GameState.current_world_id, plot.index)
        plot.set_unlocked(unlocked)
        if unlocked:
            var tree_id := GameState.get_slot_tree(GameState.current_world_id, plot.index)
            if tree_id != "":
                _spawn_tree_on_plot(plot, tree_id)

func _spawn_tree_on_plot(plot: PlotTile, tree_id: String) -> void:
    var tree_data := GameState.get_tree_data(tree_id)
    if tree_data.is_empty():
        return
    plot.remove_tree()
    var tree: TreeActor = TREE_SCENE.instantiate()
    tree.setup(tree_id, tree_data, float(GameState.economy.get("fruit_spawn_interval", 12)))
    tree.harvested.connect(_on_tree_harvested)
    tree.selected.connect(_on_tree_selected)
    plot.attach_tree(tree)

func _refresh_top_bar() -> void:
    UIManager.update_currencies(GameState.currencies)

func _refresh_world_info() -> void:
    var world_info := GameState.get_world_data(GameState.current_world_id)
    var name := str(world_info.get("display_name", GameState.current_world_id.capitalize()))
    top_bar.set_world_name(name)

func _on_plot_selected(plot: PlotTile) -> void:
    _select_plot(plot)
    if plot.tree:
        var data := GameState.get_tree_data(plot.tree.tree_id)
        UIManager.show_tree_details(plot.tree, data)
    else:
        UIManager.show_tree_details(null, {})
        _open_plant_menu(plot)

func _on_tree_selected(tree: TreeActor) -> void:
    for plot in plots:
        if plot.tree:
            plot.tree.set_selected(plot.tree == tree)
            if plot.tree == tree:
                selected_plot = plot
    selected_tree = tree
    var data := GameState.get_tree_data(tree.tree_id)
    UIManager.show_tree_details(tree, data)

func _select_plot(plot: PlotTile) -> void:
    selected_plot = plot
    if plot.tree:
        selected_tree = plot.tree
        plot.tree.set_selected(true)
    for other in plots:
        if other != plot and other.tree:
            other.tree.set_selected(false)

func _open_plant_menu(plot: PlotTile) -> void:
    plant_menu.clear()
    var tree_ids := WorldController.get_available_tree_ids(GameState.current_world_id)
    var id := 0
    for tree_id in tree_ids:
        plant_menu.add_item(tree_id.capitalize(), id)
        plant_menu.set_item_metadata(id, tree_id)
        id += 1
    plant_menu.set_position(get_viewport().get_mouse_position())
    plant_menu.show()
    plant_menu.popup()

func _on_plant_selected(index: int) -> void:
    if selected_plot == null:
        return
    var tree_id := plant_menu.get_item_metadata(index)
    GameState.set_tree_in_slot(GameState.current_world_id, selected_plot.index, tree_id)
    _spawn_tree_on_plot(selected_plot, tree_id)
    _refresh_top_bar()
    GameState.save_state()

func _on_unlock_requested(plot: PlotTile) -> void:
    var cost := WorldController.get_slot_cost(plot.index)
    if GameState.spend_currency("coins", cost):
        GameState.unlock_slot(GameState.current_world_id, plot.index)
        plot.set_unlocked(true)
        _refresh_top_bar()
        GameState.save_state()
        return
    if GameState.monetization.get("slot_token_ads", true) and GameState.can_use_ad():
        GameState.consume_ad_view()
        GameState.unlock_slot(GameState.current_world_id, plot.index)
        plot.set_unlocked(true)
        _refresh_top_bar()
        GameState.save_state()

func _on_tree_harvested(fruit_id: String, tree: TreeActor) -> void:
    var fruit := GameState.record_harvest(fruit_id)
    if active_buffs["harvest"]["time"] > 0:
        GameState.add_currency("coins", int(fruit.get("coins", 0) * 0.5))
    if active_buffs["drop"]["time"] > 0 and rng.randf() < 0.15:
        GameState.record_harvest(fruit_id)
    _refresh_top_bar()

func _on_care_requested(care_type: String) -> void:
    if selected_tree == null:
        return
    var duration := float(GameState.economy.get("care", {}).get("boost_duration", 20))
    match care_type:
        "water":
            if GameState.spend_currency("coins", int(GameState.economy.get("care", {}).get("water_cost", 8))):
                selected_tree.apply_care("water", duration)
        "fertilize":
            if GameState.spend_currency("coins", int(GameState.economy.get("care", {}).get("fertilizer_cost", 12))):
                selected_tree.apply_care("fertilize", duration)
        "cure":
            if GameState.spend_currency("coins", int(GameState.economy.get("care", {}).get("cure_cost", 16))):
                selected_tree.apply_care("cure", duration)
    _refresh_top_bar()

func _on_remove_requested() -> void:
    if selected_plot == null:
        return
    GameState.remove_tree_from_slot(GameState.current_world_id, selected_plot.index)
    selected_plot.remove_tree()
    selected_tree = null
    UIManager.show_tree_details(null, {})
    GameState.save_state()

func _on_craft_requested(kind: String) -> void:
    match kind:
        "growth":
            if GameState.spend_currency("mana", 10):
                active_buffs["growth"]["time"] = 180
                active_buffs["growth"]["mult"] = 1.25
        "harvest":
            if GameState.spend_currency("essence", 6):
                active_buffs["harvest"]["time"] = 150
                active_buffs["harvest"]["mult"] = 1.4
        "drop":
            if GameState.spend_currency("mana", 8):
                active_buffs["drop"]["time"] = 120
                active_buffs["drop"]["mult"] = 1.3
    _refresh_top_bar()
    _refresh_press_panel()

func _refresh_press_panel() -> void:
    var parts: Array[String] = []
    for key in active_buffs.keys():
        var buff := active_buffs[key]
        if buff["time"] > 0:
            parts.append("%s %ds" % [key.capitalize(), int(buff["time"])])
    var text := "No active buffs" if parts.is_empty() else ", ".join(parts)
    UIManager.update_press_status(text)

func _on_dev_toggle(enabled: bool) -> void:
    if not GameState.monetization.get("dev_cheats", false):
        return
    if enabled:
        GameState.add_currency("coins", 500)
        GameState.add_currency("mana", 100)
        GameState.add_currency("essence", 50)
    _refresh_top_bar()

func _on_breed_requested(parent_a: String, parent_b: String) -> void:
    var result := GameState.perform_breeding(parent_a, parent_b, GameState.current_world_id)
    if result.has("error"):
        breeding_panel.set_result("Result: %s" % result.get("error"))
    else:
        breeding_panel.set_result("Seed: %s (Tier %d)%s" % [result.get("seed_id", "?"), result.get("rarity_tier", 0), "*" if result.get("mutation", false) else ""])
    _refresh_top_bar()
    _refresh_breeding_panel()

func _refresh_breeding_panel() -> void:
    GameState.reset_breeding_if_needed()
    var info := GameState.get_breeding_data()
    var tree_ids := WorldController.get_available_tree_ids(GameState.current_world_id)
    var odds_text := "Mutation 10%"
    breeding_panel.set_tree_options(tree_ids)
    breeding_panel.set_attempts_remaining(info.get("attempts", 0), info.get("cooldown_text", ""))
    breeding_panel.set_odds_text(odds_text)

func _refresh_prestige_panel() -> void:
    UIManager.configure_prestige(GameState.currencies.get("prestige_leaves", 0), GameState.prestige_upgrades, {})

func _on_prestige_requested() -> void:
    var total_value := GameState.currencies.get("coins", 0) + GameState.currencies.get("mana", 0) * 5 + GameState.currencies.get("essence", 0) * 12
    var earned := GameState.apply_prestige(total_value)
    run_summary.hide()
    _refresh_top_bar()
    _refresh_prestige_panel()
    GameState.start_session(GameState.current_world_id, GameState.current_session_length)

func _on_upgrade_requested(upgrade_id: String) -> void:
    if GameState.purchase_prestige_upgrade(upgrade_id):
        _refresh_prestige_panel()
        _refresh_top_bar()

func _on_welcome_collect(mode: String) -> void:
    GameState.collect_offline(mode)
    _refresh_top_bar()
    GameState.save_state()

func _on_world_chosen(world_id: String, duration: int) -> void:
    WorldController.load_world(world_id)
    GameState.start_session(world_id, duration)
    GameState.current_world_id = world_id
    _restore_saved_trees()
    UIManager.hide_world_select()
    selected_plot = null
    selected_tree = null
    UIManager.show_tree_details(null, {})
    _refresh_breeding_panel()
    _refresh_prestige_panel()
    _refresh_top_bar()
    _refresh_world_info()
    GameState.save_state()

func _on_continue_requested() -> void:
    GameState.start_session(GameState.current_world_id, GameState.current_session_length)
    GameState.save_state()
    _refresh_world_info()

func _process(delta: float) -> void:
    GameState.update_session(delta)
    last_currency_update += delta
    if last_currency_update > 0.5:
        _refresh_top_bar()
        last_currency_update = 0.0
    var remaining := max(0.0, GameState.current_session_length - GameState.session_elapsed)
    top_bar.set_timer(remaining)
    var growth_mult := 1.0
    if active_buffs["growth"]["time"] > 0:
        growth_mult = active_buffs["growth"]["mult"]
    for plot in plots:
        if plot.tree:
            plot.tree.set_external_growth(growth_mult)
    for key in active_buffs.keys():
        if active_buffs[key]["time"] > 0:
            active_buffs[key]["time"] = max(0.0, active_buffs[key]["time"] - delta)
    if GameState.should_end_session():
        if not run_summary.visible:
            _show_run_summary()
        return
    _refresh_press_panel()

func _show_run_summary() -> void:
    var summary := "Coins: %d\nMana: %d\nEssence: %d" % [GameState.currencies.get("coins", 0), GameState.currencies.get("mana", 0), GameState.currencies.get("essence", 0)]
    UIManager.show_run_summary(summary)
