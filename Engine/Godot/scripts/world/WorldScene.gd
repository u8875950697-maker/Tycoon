extends Node3D
class_name WorldScene

@export var grid_dimensions: Vector2i = Vector2i(4, 4)
@export var plot_scene: PackedScene = preload("res://scenes/Plot.tscn")
@export var tree_scene: PackedScene = preload("res://scenes/Tree.tscn")
@export var top_bar_scene: PackedScene = preload("res://scenes/ui/TopBar.tscn")
@export var tree_panel_scene: PackedScene = preload("res://scenes/ui/TreePanel.tscn")
@export var press_panel_scene: PackedScene = preload("res://scenes/ui/PressPanel.tscn")
@export var breeding_panel_scene: PackedScene = preload("res://scenes/ui/BreedingPanel.tscn")
@export var prestige_panel_scene: PackedScene = preload("res://scenes/ui/PrestigePanel.tscn")
@export var welcome_popup_scene: PackedScene = preload("res://scenes/ui/WelcomeBackPopup.tscn")
@export var run_summary_scene: PackedScene = preload("res://scenes/ui/RunSummary.tscn")
@export var world_select_scene: PackedScene = preload("res://scenes/ui/WorldSelect.tscn")

@onready var world_root: Node3D = $World

var plots: Array[Plot] = []
var tree_lookup := {} # Plot -> TreeActor
var plot_lookup := {} # TreeActor -> Plot

var top_bar: TopBar
var tree_panel: TreePanel
var press_panel: PressPanel
var breeding_panel: BreedingPanel
var prestige_panel: PrestigePanel
var welcome_popup: WelcomeBackPopup
var run_summary: RunSummaryPopup
var world_select: WorldSelect

var current_world_id := ""
var current_world_data := {}
var session_length := 600.0
var session_elapsed := 0.0
var hazard_summary := ""
var fruit_inventory := {}
var active_buff := {}
var world_buff_state := {}
var world_buff_used := false
var growth_multiplier := 1.0
var drop_bonus := 0.0
var reduce_motion := false
var breeding_attempts_remaining := 0
var breeding_cooldown := 0.0
var monetization_flags := {}
var offline_reward := {}
var dev_cheats_active := false

var rng := RandomNumberGenerator.new()
var selected_plot: Plot = null
var selected_tree: TreeActor = null

const DAILY_SECONDS := 86400

func _ready() -> void:
    rng.randomize()
    WorldController.load_all()
    monetization_flags = WorldController.get_monetization_flags()
    _create_ui()
    UIManager.register_world_scene(self)
    GameState.currencies_changed.connect(_on_currencies_changed)
    GameState.settings_changed.connect(_on_settings_changed)
    GameState.record_session_start("")
    _apply_saved_settings()
    _check_offline_rewards()
    _show_world_select()

func _exit_tree() -> void:
    UIManager.unregister_world_scene(self)
    if top_bar:
        UIManager.unregister_top_bar(top_bar)

func _create_ui() -> void:
    if top_bar_scene:
        top_bar = top_bar_scene.instantiate()
        add_child(top_bar)
        top_bar.world_buff_requested.connect(_on_world_buff_requested)
        top_bar.set_currencies(GameState.get_currencies())
        UIManager.register_top_bar(top_bar)
    if tree_panel_scene:
        tree_panel = tree_panel_scene.instantiate()
        add_child(tree_panel)
        tree_panel.visible = false
        tree_panel.care_requested.connect(_on_care_requested)
        tree_panel.remove_requested.connect(_on_remove_requested)
    if press_panel_scene:
        press_panel = press_panel_scene.instantiate()
        add_child(press_panel)
        press_panel.craft_requested.connect(_on_press_craft_requested)
        press_panel.dev_cheats_toggled.connect(_on_dev_cheats_toggled)
        press_panel.configure_recipes(WorldController.get_press_recipes())
    if breeding_panel_scene:
        breeding_panel = breeding_panel_scene.instantiate()
        add_child(breeding_panel)
        breeding_panel.breed_requested.connect(_on_breed_requested)
        breeding_panel.set_locked(true, "Select a world to begin")
    if prestige_panel_scene:
        prestige_panel = prestige_panel_scene.instantiate()
        add_child(prestige_panel)
        prestige_panel.prestige_requested.connect(_on_prestige_requested)
        prestige_panel.upgrade_requested.connect(_on_prestige_upgrade_requested)
        _refresh_prestige_panel()
    if welcome_popup_scene:
        welcome_popup = welcome_popup_scene.instantiate()
        add_child(welcome_popup)
        welcome_popup.collect.connect(_on_welcome_collect)
    if run_summary_scene:
        run_summary = run_summary_scene.instantiate()
        add_child(run_summary)
        run_summary.continue_requested.connect(_on_run_continue)
        run_summary.prestige_requested.connect(_on_run_prestige)

func _show_world_select() -> void:
    if world_select and is_instance_valid(world_select):
        world_select.queue_free()
    if world_select_scene:
        world_select = world_select_scene.instantiate()
        add_child(world_select)
        world_select.world_chosen.connect(_on_world_chosen)
        world_select.populate_worlds(WorldController.get_world_list())

func _on_world_chosen(world_id: String, session_seconds: int) -> void:
    if world_select:
        world_select.queue_free()
        world_select = null
    _start_session(world_id, session_seconds)

func _start_session(world_id: String, session_seconds: int) -> void:
    _clear_world()
    current_world_id = world_id
    current_world_data = WorldController.get_world_data(world_id)
    session_length = max(180.0, float(session_seconds))
    session_elapsed = 0.0
    GameState.record_session_start(world_id)
    hazard_summary = str(current_world_data.get("hazard", {}).get("description", ""))
    world_buff_used = false
    world_buff_state = {}
    active_buff = {}
    growth_multiplier = 1.0
    drop_bonus = float(current_world_data.get("effects", {}).get("rare_drop_bonus", 0.0))
    breeding_attempts_remaining = int(WorldController.get_breeding_config().get("free_attempts", 3))
    breeding_cooldown = 0.0
    fruit_inventory.clear()
    monetization_flags = WorldController.get_monetization_flags()
    dev_cheats_active = GameState.dev_cheats_enabled()
    if press_panel:
        press_panel.show_dev_toggle(bool(monetization_flags.get("dev_cheats", false)), dev_cheats_active)
        press_panel.set_status("Ready")
    _configure_top_bar()
    _build_grid()
    _populate_initial_trees()
    _refresh_breeding_panel()
    _refresh_prestige_panel()

func _configure_top_bar() -> void:
    if not top_bar:
        return
    var world_name := str(current_world_data.get("display_name", current_world_id.capitalize()))
    var hazard := WorldController.get_world_hazard(current_world_id)
    top_bar.set_world_info(world_name, hazard)
    top_bar.set_currencies(GameState.get_currencies())
    top_bar.set_hazard_summary(hazard_summary)
    var buff_info := WorldController.get_world_buff(current_world_id)
    var buff_status := "Once per run"
    var available := not world_buff_used and not buff_info.is_empty()
    if buff_info.is_empty():
        buff_status = "Unavailable"
    top_bar.set_world_buff(buff_info, available, buff_status)
    top_bar.set_buff_badge({})
    top_bar.set_timer(session_length)

func _build_grid() -> void:
    for plot in plots:
        if is_instance_valid(plot):
            plot.queue_free()
    plots.clear()
    tree_lookup.clear()
    plot_lookup.clear()
    var total_slots := GameState.get_world_slots(current_world_id, WorldController.get_world_base_slots(current_world_id))
    total_slots = clamp(total_slots, 0, grid_dimensions.x * grid_dimensions.y)
    GameState.ensure_world_slots(current_world_id, total_slots)
    var reduce_flag := bool(UIManager.is_reduce_motion_enabled())
    var slot_index := 0
    for y in range(grid_dimensions.y):
        for x in range(grid_dimensions.x):
            if not plot_scene:
                continue
            var plot: Plot = plot_scene.instantiate()
            world_root.add_child(plot)
            plot.position = WorldController.get_plot_position(x, y)
            var slot_cost := WorldController.get_slot_cost(slot_index)
            var unlocked := slot_index < total_slots
            plot.configure(slot_index, slot_cost, unlocked, reduce_flag)
            plot.plot_selected.connect(func(p := plot): _on_plot_selected(p))
            plot.unlock_requested.connect(func(p := plot): _on_plot_unlock_requested(p))
            plots.append(plot)
            slot_index += 1

func _populate_initial_trees() -> void:
    if not tree_scene:
        return
    var base_slots := GameState.get_world_slots(current_world_id, WorldController.get_world_base_slots(current_world_id))
    var natives: Array = current_world_data.get("native_trees", [])
    if natives.is_empty():
        natives.append(WorldController.get_default_tree_for_world(current_world_id))
    var spawn_count := min(base_slots, plots.size())
    for i in range(spawn_count):
        var tree_id := str(natives[i % natives.size()])
        _spawn_tree_on_plot(plots[i], tree_id)

func _spawn_tree_on_plot(plot: Plot, tree_id: String) -> void:
    if not plot or not tree_scene:
        return
    if plot.has_tree:
        return
    var tree_data := WorldController.get_tree_data(tree_id)
    if tree_data.is_empty():
        return
    var actor: TreeActor = tree_scene.instantiate()
    plot.place_tree(actor)
    tree_lookup[plot] = actor
    plot_lookup[actor] = plot
    var spawn_interval := Economy.get_fruit_spawn_interval()
    var modifiers := WorldController.get_world_effects(current_world_id)
    actor.setup(tree_id, tree_data, spawn_interval, modifiers)
    actor.selected.connect(_on_tree_selected)
    actor.harvested.connect(_on_tree_harvested)
    _apply_growth_multiplier_to_tree(actor)

func _clear_world() -> void:
    for plot in plots:
        if is_instance_valid(plot):
            plot.queue_free()
    plots.clear()
    tree_lookup.clear()
    plot_lookup.clear()
    selected_plot = null
    selected_tree = null
    if tree_panel:
        tree_panel.set_tree(null, {})

func _process(delta: float) -> void:
    if current_world_id == "":
        return
    session_elapsed += delta
    if top_bar:
        top_bar.set_timer(max(0.0, session_length - session_elapsed))
    if session_elapsed >= session_length:
        _show_run_summary()
        return
    if selected_tree and tree_panel:
        var status := selected_tree.get_care_status(Economy.get_care_duration())
        tree_panel.update_timers(status)
    if not active_buff.is_empty():
        active_buff["time_left"] = max(0.0, float(active_buff.get("time_left", 0.0)) - delta)
        if active_buff["time_left"] <= 0.0:
            active_buff = {}
            _update_active_buff_ui()
            _recalculate_growth_multiplier()
    if not world_buff_state.is_empty():
        world_buff_state["time_left"] = max(0.0, float(world_buff_state.get("time_left", 0.0)) - delta)
        if world_buff_state["time_left"] <= 0.0:
            world_buff_state = {}
            _recalculate_growth_multiplier()
            _configure_top_bar()
    if breeding_cooldown > 0.0:
        breeding_cooldown = max(0.0, breeding_cooldown - delta)
        _refresh_breeding_panel()

func _on_plot_selected(plot: Plot) -> void:
    if not plot or not plot.has_tree:
        return
    if selected_plot and selected_plot != plot:
        selected_plot.highlight(false)
    selected_plot = plot
    selected_plot.highlight(true)
    selected_tree = tree_lookup.get(plot, null)
    if tree_panel:
        var tree_info := {}
        if selected_tree:
            tree_info = WorldController.get_tree_data(selected_tree.tree_id)
        tree_panel.visible = true
        tree_panel.set_tree(selected_tree, tree_info)

func _on_plot_unlock_requested(plot: Plot) -> void:
    if not plot:
        return
    var slot_cost := WorldController.get_slot_cost(plot.index)
    if not GameState.spend_currency("coins", slot_cost):
        if press_panel:
            press_panel.set_status("Need %d coins" % slot_cost)
        return
    plot.set_locked(false)
    GameState.ensure_world_slots(current_world_id, plot.index + 1)
    _spawn_tree_on_plot(plot, WorldController.get_random_tree_for_world(current_world_id, rng))
    _configure_top_bar()

func _on_tree_selected(tree: TreeActor) -> void:
    if not tree:
        return
    var plot: Plot = plot_lookup.get(tree, null)
    if plot:
        _on_plot_selected(plot)

func _on_remove_requested() -> void:
    if not selected_plot:
        return
    var tree: TreeActor = tree_lookup.get(selected_plot, null)
    if tree and is_instance_valid(tree):
        tree.queue_free()
    tree_lookup.erase(selected_plot)
    selected_plot.clear_tree()
    selected_plot = null
    selected_tree = null
    if tree_panel:
        tree_panel.set_tree(null, {})

func _on_care_requested(care_type: String) -> void:
    if not selected_tree or not selected_plot:
        return
    var duration := Economy.get_care_duration()
    var cost := Economy.get_care_cost(care_type)
    if not GameState.spend_currency("coins", cost):
        if press_panel:
            press_panel.set_status("Need %d coins" % cost)
        return
    selected_tree.apply_care(care_type, duration)
    if tree_panel:
        tree_panel.update_timers(selected_tree.get_care_status(duration))

func _on_tree_harvested(fruit_id: String, tree: TreeActor) -> void:
    var fruit_data := WorldController.get_fruit_data(fruit_id)
    if fruit_data.is_empty():
        return
    var coins := int(fruit_data.get("coins", 0))
    var mana := int(fruit_data.get("mana", 0))
    var essence := int(fruit_data.get("essence", 0))
    var gems := int(fruit_data.get("gems", 0))
    if not active_buff.is_empty() and active_buff.get("kind", "") == "harvest":
        var mult := float(active_buff.get("multiplier", 1.0))
        coins = int(round(coins * mult))
    GameState.add_coins(coins)
    GameState.add_mana(mana)
    GameState.add_essence(essence)
    if gems > 0:
        GameState.add_gems(gems)
    if rng.randf() < 0.05 + drop_bonus:
        GameState.add_seeds(1)
    var count := int(fruit_inventory.get(fruit_id, 0)) + 1
    fruit_inventory[fruit_id] = count
    if press_panel:
        press_panel.set_status("Harvested %s (+%d coins)" % [fruit_id, coins])
    _update_active_buff_ui()

func _on_press_craft_requested(kind: String) -> void:
    var recipe := Economy.get_press_recipe(kind)
    if recipe.is_empty():
        return
    var currency := str(recipe.get("currency", "mana"))
    var cost := int(recipe.get("cost", 0))
    if not GameState.spend_currency(currency, cost):
        if press_panel:
            press_panel.set_status("Need %d %s" % [cost, currency])
        return
    var fruit_id := str(recipe.get("fruit", "-"))
    if fruit_id != "-":
        var have := int(fruit_inventory.get(fruit_id, 0))
        if have <= 0:
            GameState.add_currency(currency, cost)
            if press_panel:
                press_panel.set_status("Need %s" % fruit_id)
            return
        fruit_inventory[fruit_id] = have - 1
    var duration := float(recipe.get("duration", 0.0))
    var multiplier := float(recipe.get("multiplier", 1.0))
    active_buff = {
        "kind": kind,
        "multiplier": multiplier,
        "time_left": duration,
        "label": str(recipe.get("label", kind.capitalize())),
        "source": "Press"
    }
    _recalculate_growth_multiplier()
    _update_active_buff_ui()
    if press_panel:
        press_panel.set_status("Applied %s" % active_buff.get("label", kind))

func _update_active_buff_ui() -> void:
    if not top_bar:
        return
    if active_buff.is_empty():
        top_bar.set_buff_badge({})
    else:
        top_bar.set_buff_badge({
            "label": active_buff.get("label", "Buff"),
            "mult": float(active_buff.get("multiplier", 1.0)),
            "time": float(active_buff.get("time_left", 0.0)),
            "source": active_buff.get("source", "Press")
        })

func _recalculate_growth_multiplier() -> void:
    growth_multiplier = 1.0
    if not active_buff.is_empty() and active_buff.get("kind", "") == "growth":
        growth_multiplier *= float(active_buff.get("multiplier", 1.0))
    if not world_buff_state.is_empty() and world_buff_state.get("kind", "") == "growth":
        growth_multiplier *= float(world_buff_state.get("multiplier", 1.0))
    _apply_growth_multiplier_to_all()

func _apply_growth_multiplier_to_all() -> void:
    for tree in plot_lookup.keys():
        _apply_growth_multiplier_to_tree(tree)

func _apply_growth_multiplier_to_tree(tree: TreeActor) -> void:
    if tree and is_instance_valid(tree):
        tree.set_external_growth(growth_multiplier)

func _on_world_buff_requested() -> void:
    if world_buff_used:
        return
    var buff_info := WorldController.get_world_buff(current_world_id)
    if buff_info.is_empty():
        return
    world_buff_used = true
    world_buff_state = {
        "kind": buff_info.get("type", "growth"),
        "multiplier": float(buff_info.get("multiplier", 1.0)),
        "time_left": float(buff_info.get("duration", 90.0)),
        "label": buff_info.get("name", "World Buff"),
    }
    if top_bar:
        top_bar.set_world_buff(buff_info, false, "Cooling down")
    _recalculate_growth_multiplier()

func _on_dev_cheats_toggled(enabled: bool) -> void:
    dev_cheats_active = enabled
    GameState.set_dev_cheats(enabled)
    if enabled:
        GameState.add_coins(500)
        GameState.add_mana(250)
        GameState.add_essence(120)

func _check_offline_rewards() -> void:
    var last_ts := GameState.get_last_play_timestamp()
    if last_ts <= 0:
        return
    var now := Time.get_unix_time_from_system()
    var last_world := GameState.get_last_world_id()
    if last_world == "":
        last_world = "meadow"
    var world_info := WorldController.get_world_data(last_world)
    var offline_config := WorldController.get_offline_config()
    var cap_hours := Offline.get_cap_hours(world_info, GameState.is_upgrade_purchased("offline"))
    var params := {
        "now": now,
        "last_timestamp": last_ts,
        "cap_hours": cap_hours,
        "multiplier": Economy.get_offline_multiplier(),
        "base_coin_rate": Economy.get_base_coin_rate(),
        "mana_ratio": Economy.get_offline_mana_ratio(),
        "essence_ratio": Economy.get_offline_essence_ratio(),
        "clock_guard_seconds": Economy.get_clock_guard_seconds(),
        "prestige_multiplier": 1.0 + Economy.get_prestige_bonus("growth"),
        "catch_up_bonus": GameState.meta.get("last_session_seconds", 0) < 600,
    }
    var result := Offline.calculate(params)
    if result.get("ready", false):
        offline_reward = result.get("result", {})
        if welcome_popup:
            var allow_ad := bool(monetization_flags.get("offline_double_ads", true)) and GameState.can_use_offline_double(now, DAILY_SECONDS)
            var allow_gem := bool(monetization_flags.get("offline_double_gems", true))
            welcome_popup.configure(str(offline_reward.get("summary", "Welcome back!")), offline_reward, allow_ad, allow_gem)
            UIManager.show_popup(welcome_popup)
    GameState.reset_offline_double(now, DAILY_SECONDS)

func _on_welcome_collect(mode: String) -> void:
    if offline_reward.is_empty():
        return
    var now := Time.get_unix_time_from_system()
    var coins := int(offline_reward.get("coins", 0))
    var mana := int(offline_reward.get("mana", 0))
    var essence := int(offline_reward.get("essence", 0))
    match mode:
        "ad":
            if GameState.can_use_offline_double(now, DAILY_SECONDS):
                coins *= 2
                GameState.set_offline_double_used(now)
        "gems":
            if GameState.spend_currency("gems", 1):
                coins *= 2
        _:
            pass
    GameState.add_coins(coins)
    GameState.add_mana(mana)
    GameState.add_essence(essence)
    offline_reward = {}
    GameState.update_last_play_timestamp(now)

func _on_currencies_changed(values: Dictionary) -> void:
    if top_bar:
        top_bar.set_currencies(values)

func _on_settings_changed(key: String, value) -> void:
    match key:
        "high_contrast":
            if top_bar:
                top_bar.apply_high_contrast(bool(value))
        "reduce_motion":
            apply_reduce_motion(bool(value))
        _:
            pass

func apply_reduce_motion(enabled: bool) -> void:
    reduce_motion = enabled
    for plot in plots:
        if is_instance_valid(plot):
            plot.apply_reduce_motion(enabled)

func _refresh_breeding_panel() -> void:
    if not breeding_panel:
        return
    var unlocked := bool(current_world_data.get("breeding_unlocked", false))
    if not unlocked:
        breeding_panel.set_locked(true, "Unlocks in later worlds")
        return
    breeding_panel.set_locked(false)
    var tree_ids: Array[String] = []
    for tree in tree_lookup.values():
        if tree and tree.tree_id != "":
            tree_ids.append(tree.tree_id)
    tree_ids = tree_ids.duplicate()
    tree_ids.sort()
    breeding_panel.set_tree_options(tree_ids)
    var cooldown_text := ""
    if breeding_cooldown > 0.0:
        cooldown_text = "(cooldown %.0fs)" % breeding_cooldown
    breeding_panel.set_attempts_remaining(breeding_attempts_remaining, cooldown_text)
    breeding_panel.set_odds_text("Hybrids inherit average rarity. Mutation chance +5% if biome aligned.")

func _on_breed_requested(parent_a: String, parent_b: String) -> void:
    if breeding_attempts_remaining <= 0:
        if breeding_cooldown > 0.0:
            breeding_panel.set_result("Breeding cooling down")
        return
    var config := WorldController.get_breeding_config()
    var coin_cost := int(config.get("coins", 0))
    var essence_cost := int(config.get("essence", 0))
    if not GameState.spend_currency("coins", coin_cost):
        breeding_panel.set_result("Need %d coins" % coin_cost)
        return
    if not GameState.spend_currency("essence", essence_cost):
        GameState.add_currency("coins", coin_cost)
        breeding_panel.set_result("Need %d essence" % essence_cost)
        return
    breeding_attempts_remaining -= 1
    if breeding_attempts_remaining <= 0:
        breeding_cooldown = float(config.get("cooldown_seconds", 120))
    var result := _calculate_breeding_result(parent_a, parent_b)
    breeding_panel.set_result(result.get("text", "Hybrid ready"))
    GameState.add_seeds(1)
    _refresh_breeding_panel()

func _calculate_breeding_result(parent_a: String, parent_b: String) -> Dictionary:
    var rarity_rank := {
        "basic": 0,
        "uncommon": 1,
        "rare": 2,
        "epic": 3,
        "legendary": 4,
        "mythic": 5,
    }
    var rank_lookup := ["basic", "uncommon", "rare", "epic", "legendary", "mythic"]
    var data_a := WorldController.get_tree_data(parent_a)
    var data_b := WorldController.get_tree_data(parent_b)
    var rank_a := rarity_rank.get(str(data_a.get("rarity", "basic")), 0)
    var rank_b := rarity_rank.get(str(data_b.get("rarity", "basic")), 0)
    var base_rank := int(round((rank_a + rank_b) * 0.5))
    base_rank = clamp(base_rank, 0, rank_lookup.size() - 1)
    var mutation_chance := 0.1
    var natives: Array = current_world_data.get("native_trees", [])
    if natives.has(parent_a) and natives.has(parent_b):
        mutation_chance += 0.05
    if rng.randf() < mutation_chance and base_rank < rank_lookup.size() - 1:
        base_rank += 1
    var rarity_name := rank_lookup[base_rank]
    var candidates: Array[String] = []
    for key in WorldController.trees.keys():
        var tree := WorldController.get_tree_data(str(key))
        if tree.get("rarity", "basic") == rarity_name:
            candidates.append(str(key))
    var hybrid_id := "hybrid_seed"
    if candidates.size() > 0:
        hybrid_id = candidates[rng.randi_range(0, candidates.size() - 1)]
    return {
        "rarity": rarity_name,
        "tree": hybrid_id,
        "text": "Created %s seed (%s)" % [hybrid_id, rarity_name.capitalize()],
    }

func _refresh_prestige_panel() -> void:
    if not prestige_panel:
        return
    prestige_panel.update_panel(GameState.get_prestige_leaves(), GameState.get_purchased_upgrades(), Economy.data.get("prestige", {}))

func _on_prestige_requested() -> void:
    var conversion := Economy.get_prestige_conversion_rate()
    var coins := GameState.get_currency("coins")
    var leaves := int(floor(coins * conversion))
    if leaves <= 0:
        return
    GameState.spend_currency("coins", coins)
    GameState.set_currency("mana", 0)
    GameState.set_currency("essence", 0)
    GameState.set_currency("gems", 0)
    GameState.set_currency("seeds", 0)
    GameState.add_prestige_leaves(leaves)
    GameState.record_session_end(session_elapsed)
    _refresh_prestige_panel()
    if press_panel:
        press_panel.set_status("Prestiged for %d leaves" % leaves)

func _on_prestige_upgrade_requested(upgrade_id: String) -> void:
    var upgrades := [
        {"id": "growth", "cost": 5},
        {"id": "fruit", "cost": 5},
        {"id": "mana", "cost": 5},
        {"id": "slots", "cost": 8},
        {"id": "offline", "cost": 6},
        {"id": "crit", "cost": 7},
    ]
    for entry in upgrades:
        if entry.get("id") == upgrade_id:
            var cost := int(entry.get("cost", 0))
            if GameState.spend_prestige_leaves(cost):
                GameState.set_upgrade_purchased(upgrade_id)
                if upgrade_id == "slots":
                    GameState.adjust_world_slots(current_world_id, 1)
                _refresh_prestige_panel()
            return

func _show_run_summary() -> void:
    GameState.record_session_end(session_elapsed)
    if run_summary:
        var text := "Session %.1f min\nCoins: %d\nMana: %d\nEssence: %d" % [session_elapsed / 60.0, GameState.get_currency("coins"), GameState.get_currency("mana"), GameState.get_currency("essence")]
        run_summary.show_summary(text)
        UIManager.show_popup(run_summary)

func _on_run_continue() -> void:
    _show_world_select()

func _on_run_prestige() -> void:
    _on_prestige_requested()

func _apply_saved_settings() -> void:
    var saved := GameState.get_all_settings()
    var high_contrast := bool(saved.get("high_contrast", false))
    var reduce := bool(saved.get("reduce_motion", false))
    if top_bar:
        top_bar.apply_high_contrast(high_contrast)
    apply_reduce_motion(reduce)
