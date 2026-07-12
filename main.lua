local MOD = SMODS.current_mod
local config = MOD.config or {}
MOD.config = config

config.enabled = config.enabled ~= false
config.force_shop_cards = config.force_shop_cards ~= false
config.force_vouchers = config.force_vouchers ~= false
config.force_boosters = config.force_boosters ~= false
config.card_blocklist = config.card_blocklist or {}
config.voucher_blocklist = config.voucher_blocklist or {}
config.booster_blocklist = config.booster_blocklist or {}

local ShopCurator = {
    categories = {
        "joker_common",
        "joker_uncommon",
        "joker_rare",
        "joker_legendary",
        "joker_other",
        "tarot",
        "planet",
        "spectral",
        "vouchers",
        "boosters"
    },
    category_index = 1,
    page = {
        joker_common = 1,
        joker_uncommon = 1,
        joker_rare = 1,
        joker_legendary = 1,
        joker_other = 1,
        tarot = 1,
        planet = 1,
        spectral = 1,
        vouchers = 1,
        boosters = 1
    },
    rows_per_column = 8,
    columns = 2,
    filter_depth = 0,
    pools = {},
    rows = {},
    labels = {},
    pool_defs = {
        joker_common = {
            label = "Common Jokers",
            blocklist = "card_blocklist",
            enabled_key = "force_shop_cards",
            sets = { Joker = true },
            rarity = 1
        },
        joker_uncommon = {
            label = "Uncommon Jokers",
            blocklist = "card_blocklist",
            enabled_key = "force_shop_cards",
            sets = { Joker = true },
            rarity = 2
        },
        joker_rare = {
            label = "Rare Jokers",
            blocklist = "card_blocklist",
            enabled_key = "force_shop_cards",
            sets = { Joker = true },
            rarity = 3
        },
        joker_legendary = {
            label = "Legendary Jokers",
            blocklist = "card_blocklist",
            enabled_key = "force_shop_cards",
            sets = { Joker = true },
            rarity = 4
        },
        joker_other = {
            label = "Other Jokers",
            blocklist = "card_blocklist",
            enabled_key = "force_shop_cards",
            sets = { Joker = true },
            other_rarity = true
        },
        tarot = {
            label = "Tarot Cards",
            blocklist = "card_blocklist",
            enabled_key = "force_shop_cards",
            sets = { Tarot = true }
        },
        planet = {
            label = "Planet Cards",
            blocklist = "card_blocklist",
            enabled_key = "force_shop_cards",
            sets = { Planet = true }
        },
        spectral = {
            label = "Spectral Cards",
            blocklist = "card_blocklist",
            enabled_key = "force_shop_cards",
            sets = { Spectral = true }
        },
        vouchers = {
            label = "Vouchers",
            blocklist = "voucher_blocklist",
            enabled_key = "force_vouchers",
            sets = { Voucher = true }
        },
        boosters = {
            label = "Boosters",
            blocklist = "booster_blocklist",
            enabled_key = "force_boosters",
            sets = { Booster = true }
        }
    }
}

for i = 1, ShopCurator.rows_per_column * ShopCurator.columns do
    local tooltip_lines = {
        line1 = "No card in this slot.",
        line2 = "",
        line3 = "",
        line4 = ""
    }
    ShopCurator.rows[i] = {
        key = "",
        name = "",
        set = "",
        selected = "",
        tooltip_lines = tooltip_lines,
        tooltip = {
            title = "Empty",
            text = {
                { ref_table = tooltip_lines, ref_value = "line1" },
                { ref_table = tooltip_lines, ref_value = "line2" },
                { ref_table = tooltip_lines, ref_value = "line3" },
                { ref_table = tooltip_lines, ref_value = "line4" }
            }
        }
    }
end

local function save_config()
    if SMODS and SMODS.save_mod_config then
        SMODS.save_mod_config(MOD)
    end
end

local function safe_name(center)
    if not center then
        return ""
    end

    if localize then
        local ok, localized = pcall(localize, {
            type = "name_text",
            key = center.key,
            set = center.set
        })
        if ok and localized and localized ~= "ERROR" then
            return localized
        end
    end

    return center.name or center.key or "Unknown"
end

local function truncate(str, max_len)
    str = tostring(str or "")
    if #str <= max_len then
        return str
    end
    return str:sub(1, max_len - 3) .. "..."
end

local function clean_loc_line(line)
    line = tostring(line or "")
    line = line:gsub("{.-}", "")
    line = line:gsub("#%d+#", "?")
    line = line:gsub("^%s+", ""):gsub("%s+$", "")
    return line
end

local function description_lines(center)
    local loc
    if G and G.localization and G.localization.descriptions and center then
        loc = G.localization.descriptions[center.set] and G.localization.descriptions[center.set][center.key]
    end
    loc = loc or center.loc_txt

    local text = loc and loc.text
    local lines = {}
    if type(text) == "table" then
        for _, line in ipairs(text) do
            local cleaned = clean_loc_line(line)
            if cleaned ~= "" then
                lines[#lines + 1] = cleaned
            end
            if #lines >= 4 then
                break
            end
        end
    elseif type(text) == "string" then
        local cleaned = clean_loc_line(text)
        if cleaned ~= "" then
            lines[1] = cleaned
        end
    end

    if #lines == 0 then
        lines[1] = center.key or "No description available."
    end

    return lines
end

local function set_tooltip(row, title, lines)
    row.tooltip.title = title and title ~= "" and title or "Card"
    for i = 1, 4 do
        row.tooltip_lines["line" .. i] = lines and lines[i] or ""
    end
end

local function rarity_name(rarity)
    if rarity == 1 then
        return "Common"
    elseif rarity == 2 then
        return "Uncommon"
    elseif rarity == 3 then
        return "Rare"
    elseif rarity == 4 then
        return "Legendary"
    end
    return tostring(rarity or "")
end

local function center_matches_pool(center, def)
    if not center or not center.key or not def.sets[center.set] then
        return false
    end
    if def.rarity and center.rarity ~= def.rarity then
        return false
    end
    if def.other_rarity and (center.rarity == 1 or center.rarity == 2 or center.rarity == 3 or center.rarity == 4) then
        return false
    end
    return true
end

local function add_center(pool, seen, center, def)
    if not center_matches_pool(center, def) or seen[center.key] then
        return
    end
    seen[center.key] = true
    pool[#pool + 1] = center
end

local function build_pool(pool_name)
    if not G or not G.P_CENTERS then
        return {}
    end

    local def = ShopCurator.pool_defs[pool_name]
    local pool, seen = {}, {}

    for set in pairs(def.sets) do
        if G.P_CENTER_POOLS and G.P_CENTER_POOLS[set] then
            for _, center in ipairs(G.P_CENTER_POOLS[set]) do
                add_center(pool, seen, center, def)
            end
        end
    end

    for _, center in pairs(G.P_CENTERS) do
        add_center(pool, seen, center, def)
    end

    table.sort(pool, function(a, b)
        local a_set = a.set or ""
        local b_set = b.set or ""
        if a_set ~= b_set then
            return a_set < b_set
        end
        return (a.order or 9999) < (b.order or 9999)
    end)

    return pool
end

local function ensure_pool(pool_name)
    if not ShopCurator.pools[pool_name] then
        ShopCurator.pools[pool_name] = build_pool(pool_name)
    end
    return ShopCurator.pools[pool_name]
end

local function get_blocklist(pool_name)
    local def = ShopCurator.pool_defs[pool_name]
    config[def.blocklist] = config[def.blocklist] or {}
    return config[def.blocklist]
end

local function migrate_old_slots()
    local changed = false
    local obsolete = {
        "card_slots",
        "voucher_slots",
        "booster_slots",
        "card_allowlist",
        "voucher_allowlist",
        "booster_allowlist"
    }

    for _, key in ipairs(obsolete) do
        if config[key] ~= nil then
            config[key] = nil
            changed = true
        end
    end

    if changed then
        save_config()
    end
end

local function current_pool_name()
    return ShopCurator.categories[ShopCurator.category_index] or "joker_common"
end

local function max_page(pool_name)
    local pool = ensure_pool(pool_name)
    return math.max(1, math.ceil(#pool / (ShopCurator.rows_per_column * ShopCurator.columns)))
end

local function blocked_count(pool_name)
    local pool = ensure_pool(pool_name)
    local blocklist = get_blocklist(pool_name)
    local count = 0
    for _, center in ipairs(pool) do
        if blocklist[center.key] then
            count = count + 1
        end
    end
    return count
end

local function available_count(pool_name)
    local pool = ensure_pool(pool_name)
    return math.max(0, #pool - blocked_count(pool_name))
end

local function with_blocked_keys_banned(blocklist_key, callback)
    if not config.enabled or not G or not G.GAME then
        return callback()
    end

    G.GAME.banned_keys = G.GAME.banned_keys or {}
    local blocklist = config[blocklist_key] or {}
    local previous = {}
    ShopCurator.filter_depth = ShopCurator.filter_depth + 1

    for key, blocked in pairs(blocklist) do
        if blocked then
            previous[#previous + 1] = { key = key, value = G.GAME.banned_keys[key] }
            G.GAME.banned_keys[key] = true
        end
    end

    local results = { callback() }

    for _, entry in ipairs(previous) do
        G.GAME.banned_keys[entry.key] = entry.value
    end

    ShopCurator.filter_depth = math.max(0, ShopCurator.filter_depth - 1)
    return unpack(results)
end

local function center_blocklist(center)
    if not center then
        return nil
    end
    if center.set == "Joker" or center.set == "Tarot" or center.set == "Planet" or center.set == "Spectral" then
        if not config.force_shop_cards then
            return nil
        end
        return config.card_blocklist
    elseif center.set == "Voucher" then
        if not config.force_vouchers then
            return nil
        end
        return config.voucher_blocklist
    elseif center.set == "Booster" then
        if not config.force_boosters then
            return nil
        end
        return config.booster_blocklist
    end
    return nil
end

local function is_center_blocked(center)
    local blocklist = center_blocklist(center)
    return not not (blocklist and center and blocklist[center.key])
end

local function type_uses_curator_pool(_type)
    if _type == "Joker"
        or _type == "Tarot"
        or _type == "Planet"
        or _type == "Spectral"
        or _type == "Tarot_Planet"
        or _type == "Consumeables" then
        return config.force_shop_cards
    end
    if _type == "Voucher" then
        return config.force_vouchers
    end
    if _type == "Booster" then
        return config.force_boosters
    end
    return false
end

local function center_matches_create_type(center, _type)
    if not center or not center.key then
        return false
    end
    if _type == "Tarot_Planet" then
        return center.set == "Tarot" or center.set == "Planet"
    elseif _type == "Consumeables" then
        return center.set == "Tarot" or center.set == "Planet" or center.set == "Spectral"
    end
    return center.set == _type
end

local old_get_current_pool
local VANILLA_JOKER_RARITIES = {
    Common = 1,
    Uncommon = 2,
    Rare = 3,
    Legendary = 4
}

local function joker_rarity_options()
    local options, seen = {}, {}
    local rarity_defs = SMODS
        and SMODS.ObjectTypes
        and SMODS.ObjectTypes.Joker
        and SMODS.ObjectTypes.Joker.rarities

    if type(rarity_defs) == "table" then
        for _, rarity in ipairs(rarity_defs) do
            local key = rarity.key
            local value = VANILLA_JOKER_RARITIES[key] or key
            local seen_key = tostring(value)
            if value and not seen[seen_key] then
                seen[seen_key] = true
                options[#options + 1] = value
            end
        end
    end

    if #options == 0 then
        options = { 1, 2, 3, 4 }
    end

    return options
end

local function unblocked_pool_entries(pool)
    local available = {}
    for _, key in ipairs(pool or {}) do
        local center = G and G.P_CENTERS and G.P_CENTERS[key]
        if key ~= "UNAVAILABLE" and center and not is_center_blocked(center) then
            available[#available + 1] = key
        end
    end
    return available
end

local function available_joker_rarity_options(_append)
    local available = {}
    for _, rarity in ipairs(joker_rarity_options()) do
        local pool = old_get_current_pool("Joker", rarity, false, _append)
        if #unblocked_pool_entries(pool) > 0 then
            available[#available + 1] = rarity
        end
    end
    return available
end

local function balanced_joker_rarity(_append)
    local available = available_joker_rarity_options(_append)
    if #available == 0 then
        return nil
    end

    local ante = G and G.GAME and G.GAME.round_resets and G.GAME.round_resets.ante or 0
    local seed = "shopcurator_joker_rarity_" .. tostring(ante) .. "_" .. tostring(_append or "")
    local rarity = pseudorandom_element(available, pseudoseed(seed))
    return rarity
end

local function build_available_fallback_pool(_type)
    local fallback = {}
    if not G or not G.P_CENTERS then
        return fallback
    end

    local seen = {}
    if _type == "Joker" then
        for _, rarity in ipairs(joker_rarity_options()) do
            local pool = old_get_current_pool("Joker", rarity, rarity == 4, "shopcurator_fallback")
            for _, key in ipairs(pool) do
                local center = G.P_CENTERS[key]
                if key ~= "UNAVAILABLE" and center and not seen[key] and not is_center_blocked(center) then
                    seen[key] = true
                    fallback[#fallback + 1] = key
                end
            end
        end
    else
        local pool = old_get_current_pool(_type, nil, nil, "shopcurator_fallback")
        for _, key in ipairs(pool) do
            local center = G.P_CENTERS[key]
            if key ~= "UNAVAILABLE" and center and not seen[key] and not is_center_blocked(center) then
                seen[key] = true
                fallback[#fallback + 1] = key
            end
        end
    end

    return fallback
end

old_get_current_pool = get_current_pool
function get_current_pool(_type, _rarity, _legendary, _append)
    if config.enabled
        and ShopCurator.filter_depth > 0
        and config.force_shop_cards
        and _type == "Joker"
        and not _rarity
        and not _legendary then
        _rarity = balanced_joker_rarity(_append)
    end

    local pool, pool_key = old_get_current_pool(_type, _rarity, _legendary, _append)
    if not config.enabled or ShopCurator.filter_depth == 0 or not type_uses_curator_pool(_type) then
        return pool, pool_key
    end

    local available, unfiltered_available = 0, {}
    for i, key in ipairs(pool) do
        if key ~= "UNAVAILABLE" then
            unfiltered_available[#unfiltered_available + 1] = key
        end
        local center = G.P_CENTERS[key]
        if center and is_center_blocked(center) then
            pool[i] = "UNAVAILABLE"
        elseif key ~= "UNAVAILABLE" then
            available = available + 1
        end
    end

    if available > 0 then
        return pool, pool_key
    end

    local fallback = build_available_fallback_pool(_type)
    if #fallback > 0 then
        return fallback, pool_key .. "_shopcurator"
    end

    if #unfiltered_available > 0 then
        return unfiltered_available, pool_key .. "_shopcurator_last_resort"
    end

    return pool, pool_key
end

local function sync_toggles()
    ShopCurator.labels.enabled = config.enabled and "Enabled" or "Disabled"
    ShopCurator.labels.force_shop_cards = config.force_shop_cards and "On" or "Off"
    ShopCurator.labels.force_vouchers = config.force_vouchers and "On" or "Off"
    ShopCurator.labels.force_boosters = config.force_boosters and "On" or "Off"
end

local function refresh_rows()
    local pool_name = current_pool_name()
    local def = ShopCurator.pool_defs[pool_name]
    local pool = ensure_pool(pool_name)
    local page = math.min(ShopCurator.page[pool_name] or 1, max_page(pool_name))
    ShopCurator.page[pool_name] = page

    ShopCurator.labels.category = def.label
    ShopCurator.labels.page = "Page " .. page .. "/" .. max_page(pool_name)
    ShopCurator.labels.selected = tostring(available_count(pool_name)) .. "/" .. tostring(#pool) .. " available"

    local start_index = (page - 1) * ShopCurator.rows_per_column * ShopCurator.columns
    for i = 1, ShopCurator.rows_per_column * ShopCurator.columns do
        local center = pool[start_index + i]
        local row = ShopCurator.rows[i]
        if center then
            row.key = center.key
            row.name = truncate(safe_name(center), 28)
            row.set = center.set == "Joker" and rarity_name(center.rarity) or (center.set or "")
            local blocklist = get_blocklist(pool_name)
            row.selected = blocklist[center.key] and "Off" or "On"
            set_tooltip(row, safe_name(center), description_lines(center))
        else
            row.key = ""
            row.name = ""
            row.set = ""
            row.selected = ""
            set_tooltip(row, "Empty", { "No card in this slot." })
        end
    end

    sync_toggles()
end

G.FUNCS.shopcurator_toggle = function(e)
    local key = e.config.config_key
    config[key] = not config[key]
    refresh_rows()
    save_config()
end

G.FUNCS.shopcurator_category = function(e)
    ShopCurator.category_index = ((ShopCurator.category_index + e.config.step - 1) % #ShopCurator.categories) + 1
    refresh_rows()
end

G.FUNCS.shopcurator_page = function(e)
    local pool_name = current_pool_name()
    local pages = max_page(pool_name)
    ShopCurator.page[pool_name] = ((ShopCurator.page[pool_name] + e.config.step - 1) % pages) + 1
    refresh_rows()
end

G.FUNCS.shopcurator_toggle_item = function(e)
    local row = ShopCurator.rows[e.config.row]
    if not row or row.key == "" then
        return
    end

    local pool_name = current_pool_name()
    local blocklist = get_blocklist(pool_name)
    blocklist[row.key] = not blocklist[row.key] or nil
    refresh_rows()
    save_config()
end

G.FUNCS.shopcurator_bulk = function(e)
    local pool_name = current_pool_name()
    local pool = ensure_pool(pool_name)
    local blocklist = get_blocklist(pool_name)

    for _, center in ipairs(pool) do
        if e.config.available then
            blocklist[center.key] = nil
        else
            blocklist[center.key] = true
        end
    end

    refresh_rows()
    save_config()
end

local function text_node(text, scale, colour)
    return {
        n = G.UIT.T,
        config = {
            text = text,
            scale = scale or 0.32,
            colour = colour or G.C.UI.TEXT_LIGHT
        }
    }
end

local function ref_text_node(ref_table, ref_value, scale, colour)
    return {
        n = G.UIT.T,
        config = {
            ref_table = ref_table,
            ref_value = ref_value,
            scale = scale or 0.32,
            colour = colour or G.C.UI.TEXT_LIGHT
        }
    }
end

local function button_node(label, button, extra, width)
    local cfg = {
        align = "cm",
        padding = 0.035,
        minw = width or 0.8,
        minh = 0.3,
        r = 0.08,
        hover = true,
        shadow = true,
        colour = G.C.RED,
        button = button
    }
    for k, v in pairs(extra or {}) do
        cfg[k] = v
    end

    return {
        n = G.UIT.C,
        config = cfg,
        nodes = { text_node(label, 0.24) }
    }
end

local function toggle_row(label, key)
    return {
        n = G.UIT.R,
        config = { align = "cm", padding = 0.012 },
        nodes = {
            {
                n = G.UIT.C,
                config = { align = "cl", minw = 2.6 },
                nodes = { text_node(label, 0.26) }
            },
            {
                n = G.UIT.C,
                config = {
                    align = "cm",
                    minw = 0.95,
                    minh = 0.29,
                    padding = 0.03,
                    r = 0.08,
                    hover = true,
                    shadow = true,
                    colour = G.C.BLUE,
                    button = "shopcurator_toggle",
                    config_key = key
                },
                nodes = { ref_text_node(ShopCurator.labels, key, 0.24) }
            }
        }
    }
end

local function item_row(i)
    local row = ShopCurator.rows[i]
    return {
        n = G.UIT.R,
        config = { align = "cm", padding = 0.015 },
        nodes = {
            {
                n = G.UIT.C,
                config = { align = "cr", minw = 0.28 },
                nodes = { text_node(tostring(i), 0.24, G.C.UI.TEXT_INACTIVE) }
            },
            {
                n = G.UIT.C,
                config = {
                    align = "cm",
                    minw = 0.75,
                    minh = 0.29,
                    padding = 0.03,
                    r = 0.08,
                    hover = true,
                    shadow = true,
                    colour = G.C.BLUE,
                    button = "shopcurator_toggle_item",
                    row = i,
                    tooltip = row.tooltip
                },
                nodes = { ref_text_node(row, "selected", 0.23) }
            },
            {
                n = G.UIT.C,
                config = {
                    align = "cm",
                    minw = 0.85,
                    minh = 0.29,
                    padding = 0.03,
                    r = 0.05,
                    colour = G.C.UI.BACKGROUND_INACTIVE,
                    tooltip = row.tooltip
                },
                nodes = { ref_text_node(row, "set", 0.21, G.C.UI.TEXT_LIGHT) }
            },
            {
                n = G.UIT.C,
                config = {
                    align = "cl",
                    minw = 3.45,
                    minh = 0.29,
                    padding = 0.03,
                    r = 0.05,
                    colour = G.C.WHITE,
                    tooltip = row.tooltip
                },
                nodes = { ref_text_node(row, "name", 0.24, G.C.UI.TEXT_DARK) }
            }
        }
    }
end

local function list_column(column)
    local rows = {}
    local start_index = (column - 1) * ShopCurator.rows_per_column
    for i = 1, ShopCurator.rows_per_column do
        rows[#rows + 1] = item_row(start_index + i)
    end
    return {
        n = G.UIT.C,
        config = { align = "tm", padding = 0.035, minw = 5.45 },
        nodes = rows
    }
end

local function list_columns()
    return {
        n = G.UIT.R,
        config = { align = "tm", padding = 0.04 },
        nodes = {
            list_column(1),
            list_column(2)
        }
    }
end

local function curated_card_type(_type)
    return _type == "Joker"
        or _type == "Tarot"
        or _type == "Planet"
        or _type == "Spectral"
        or _type == "Tarot_Planet"
        or _type == "Consumeables"
end

local function curated_card_area(area)
    return area and (area == G.shop_jokers or area == G.pack_cards)
end

MOD.config_tab = function()
    migrate_old_slots()
    ShopCurator.pools = {}
    for _, pool_name in ipairs(ShopCurator.categories) do
        ensure_pool(pool_name)
    end
    refresh_rows()

    return {
        n = G.UIT.ROOT,
        config = {
            align = "cm",
            padding = 0.1,
            r = 0.1,
            colour = G.C.BLACK,
            minw = 11.5,
            minh = 7.4
        },
        nodes = {
            {
                n = G.UIT.C,
                config = { align = "tm", padding = 0.05, minw = 11.1, minh = 6.8 },
                nodes = {
                    text_node("Shop Curator", 0.42, G.C.ORANGE),
                    {
                        n = G.UIT.R,
                        config = { align = "tm", padding = 0.02 },
                        nodes = {
                            {
                                n = G.UIT.C,
                                config = { align = "tm", padding = 0.02, minw = 4.8 },
                                nodes = {
                                    toggle_row("Mod status", "enabled"),
                                    toggle_row("Shop cards", "force_shop_cards")
                                }
                            },
                            {
                                n = G.UIT.C,
                                config = { align = "tm", padding = 0.02, minw = 4.8 },
                                nodes = {
                                    toggle_row("Vouchers", "force_vouchers"),
                                    toggle_row("Boosters", "force_boosters")
                                }
                            }
                        }
                    },
                    {
                        n = G.UIT.R,
                        config = { align = "cm", padding = 0.03 },
                        nodes = {
                            button_node("<", "shopcurator_category", { step = -1 }, 0.45),
                            {
                                n = G.UIT.C,
                                config = { align = "cm", minw = 3.2 },
                                nodes = { ref_text_node(ShopCurator.labels, "category", 0.32, G.C.ORANGE) }
                            },
                            button_node(">", "shopcurator_category", { step = 1 }, 0.45),
                            { n = G.UIT.B, config = { w = 0.2, h = 0.1 } },
                            button_node("<", "shopcurator_page", { step = -1 }, 0.45),
                            {
                                n = G.UIT.C,
                                config = { align = "cm", minw = 1.5 },
                                nodes = { ref_text_node(ShopCurator.labels, "page", 0.28) }
                            },
                            button_node(">", "shopcurator_page", { step = 1 }, 0.45),
                            {
                                n = G.UIT.C,
                                config = { align = "cm", minw = 2.0 },
                                nodes = { ref_text_node(ShopCurator.labels, "selected", 0.24, G.C.UI.TEXT_INACTIVE) }
                            }
                        }
                    },
                    {
                        n = G.UIT.R,
                        config = { align = "cm", padding = 0.03 },
                        nodes = {
                            button_node("All On", "shopcurator_bulk", { available = true }, 1.05),
                            { n = G.UIT.B, config = { w = 0.12, h = 0.1 } },
                            button_node("All Off", "shopcurator_bulk", { available = false }, 1.05)
                        }
                    },
                    {
                        n = G.UIT.C,
                        config = { align = "tm", padding = 0.04, minw = 11.0 },
                        nodes = { list_columns() }
                    }
                }
            }
        }
    }
end

if SMODS and SMODS.create_shop_card then
    local old_smods_create_shop_card = SMODS.create_shop_card
    function SMODS.create_shop_card(area)
        if config.force_shop_cards and curated_card_area(area) then
            return with_blocked_keys_banned("card_blocklist", function()
                return old_smods_create_shop_card(area)
            end)
        end
        return old_smods_create_shop_card(area)
    end
end

local old_create_card = create_card
function create_card(_type, area, legendary, _rarity, skip_materialize, soulable, forced_key, key_append)
    if config.force_shop_cards and curated_card_type(_type) and curated_card_area(area) then
        return with_blocked_keys_banned("card_blocklist", function()
            return old_create_card(_type, area, legendary, _rarity, skip_materialize, soulable, forced_key, key_append)
        end)
    end
    return old_create_card(_type, area, legendary, _rarity, skip_materialize, soulable, forced_key, key_append)
end

local old_get_next_voucher_key = get_next_voucher_key
function get_next_voucher_key(...)
    local args = { ... }
    if config.force_vouchers then
        return with_blocked_keys_banned("voucher_blocklist", function()
            return old_get_next_voucher_key(unpack(args))
        end)
    end
    return old_get_next_voucher_key(unpack(args))
end

local old_get_pack = get_pack
function get_pack(_key, ...)
    local args = { ... }
    if config.force_boosters and _key == "shop_pack" then
        return with_blocked_keys_banned("booster_blocklist", function()
            return old_get_pack(_key, unpack(args))
        end)
    end
    return old_get_pack(_key, unpack(args))
end
