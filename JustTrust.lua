--[[
JustTrust - v0.1-- Trust name mappings for cases where cipher names don't match spell names
Prevents duplicate trust cipher purchases
]]

_addon.name = 'JustTrust'
_addon.author = 'Tilted_Tom with GitHub Copilot'
_addon.version = '0.3'
_addon.commands = {'justtrust', 'jt'}

local packets = require('packets')
local res = require('resources')

-- Simple JSON-like serialization for trust sets
local function serialize_trust_sets(sets)
    local lines = {}
    for set_name, trust_list in pairs(sets) do
        local trust_string = table.concat(trust_list, ',')
        table.insert(lines, set_name .. '=' .. trust_string)
    end
    return table.concat(lines, '\n')
end

local function deserialize_trust_sets(content)
    local sets = {}
    for line in content:gmatch('[^\r\n]+') do
        local set_name, trust_string = line:match('([^=]+)=(.+)')
        if set_name and trust_string then
            local trusts = {}
            for trust in trust_string:gmatch('[^,]+') do
                table.insert(trusts, trust:match('^%s*(.-)%s*$')) -- trim whitespace
            end
            sets[set_name] = trusts
        end
    end
    return sets
end

-- Disabled logging function (production)
local function log_to_file(message)
    -- No logging in production
end

-- Load trust cipher data from data file
local trust_cipher_module = require('data/trust_ciphers')
local trust_ciphers = trust_cipher_module.data

-- Trust name mappings f            windower.add_to_chat(167, '[JustTrust] Usage: //jt deleteset <name>')r cases where cipher names don't match spell names


-- Simple trust name matching function  
local function match_trust_name(trust_name, spell_name)
    -- Direct match
    if spell_name:lower() == trust_name:lower() then
        return true
    end
    
    -- Match first name only (handles "Abenzio" vs "Abenzio Rivelouze")
    local first_name = trust_name:lower():match("^(%S+)")
    if first_name and spell_name:lower() == first_name then
        return true
    end
    
    -- Match without spaces/hyphens/apostrophes (handles "Selh'teus" vs "Selhteus")
    if spell_name:lower():gsub("[%s%-'.]", "") == trust_name:lower():gsub("[%s%-'.]", "") then
        return true
    end
    
    -- Substring matching (either direction)
    if spell_name:lower():find(trust_name:lower(), 1, true) or 
       trust_name:lower():find(spell_name:lower(), 1, true) then
        return true
    end
    
    return false
end

-- Cooldown to prevent spam
local last_msg = 0

-- Store current shop trusts for purchase blocking
local current_owned_trusts = {}
local current_available_trusts = {}
local purchase_blocking_enabled = true  -- Default enabled, can be toggled

-- Menu context tracking for purchase blocking
local menu_context = {
    current_menu_id = nil,
    last_shop_scan = 0,
    shop_items = {},  -- Store items by slot position
    owned_cipher_slots = {},  -- Track which slots have owned trust ciphers
    selected_slot = nil,  -- Track which slot the player is selecting
    selected_trust = nil,  -- Track which trust was selected
    last_selection_time = 0,
    last_block_time = 0,  -- Track when we last blocked something
    known_purchase_contexts = {
        -- Map specific menu contexts that represent actual purchases
        -- Format: [menu_id] = {purchase_option = option_index}
        [806] = {purchase_option = 1}  -- Based on log analysis
    }
}

-- Trust set management with JSON file persistence
local trust_sets = {}
local settings_file = windower.addon_path .. 'data/trust_sets.json'

-- Function to load trust sets from JSON file
local function load_trust_sets_from_file()    local file = io.open(settings_file, 'r')
    if file then
        local content = file:read('*all')
        file:close()
        
        if content and content:trim() ~= '' then
            -- Parse content
            local success, parsed_data = pcall(function() return deserialize_trust_sets(content) end)
            if success and parsed_data then
                trust_sets = parsed_data
                local count = 0
                for _ in pairs(trust_sets) do count = count + 1 end
                windower.add_to_chat(207, '[JustTrust] Loaded ' .. count .. ' trust sets from trust_sets.json')
            else
                -- Silent fallback to empty sets for parsing errors
                trust_sets = {}
            end
        else
            -- Silent initialization for empty files
            trust_sets = {}
        end
    else
        -- Silent initialization when file doesn't exist
        trust_sets = {}
    end
end

-- Function to save trust sets to JSON file
local function save_trust_sets_to_file()
    -- Create data directory if it doesn't exist
    local data_dir = windower.addon_path .. 'data'
    windower.create_dir(data_dir)    local file = io.open(settings_file, 'w')
    if file then
        local content = serialize_trust_sets(trust_sets)
        file:write(content)
        file:close()
        return true
    else
        windower.add_to_chat(167, '[JustTrust] Error saving trust sets to trust_sets.json')
        return false
    end
end

-- Function to get currently summoned trusts
local function get_current_trusts()
    local party = windower.ffxi.get_party()
    local current_trusts = {}
    
    if party then
        -- Check party members p1-p5 for trusts
        for i = 1, 5 do
            local member = party['p' .. i]
            if member and member.name and member.name ~= '' then
                windower.add_to_chat(207, '[JustTrust Debug] Found party member: ' .. member.name)
                
                -- Check if this is a trust using our enhanced matching
                local spells = windower.ffxi.get_spells()
                if spells then
                    for spell_id, known in pairs(spells) do
                        if known and res.spells[spell_id] and res.spells[spell_id].type == 'Trust' then
                            local spell_name = res.spells[spell_id].name
                            
                            -- Use our enhanced trust name matching function
                            if match_trust_name(member.name, spell_name) then
                                windower.add_to_chat(158, '[JustTrust Debug] Matched: ' .. member.name .. ' -> ' .. spell_name)
                                table.insert(current_trusts, spell_name)
                                break
                            end
                        end
                    end
                end
            end
        end
    end
    
    return current_trusts
end

-- Function to save a trust set
local function save_trust_set(set_name, trusts)
    trust_sets[set_name] = trusts
    windower.add_to_chat(158, '[JustTrust] Saved trust set "' .. set_name .. '" with ' .. #trusts .. ' trusts: ' .. table.concat(trusts, ', '))
    save_trust_sets_to_file() -- Save to file
end

-- Function to load a trust set
local function load_trust_set(set_name)
    if not trust_sets[set_name] then
        windower.add_to_chat(167, '[JustTrust] Trust set "' .. set_name .. '" not found!')
        return
    end
    
    local trusts = trust_sets[set_name]
    windower.add_to_chat(158, '[JustTrust] Loading trust set "' .. set_name .. '": ' .. table.concat(trusts, ', '))
    
    -- Pre-check which trusts can be cast (not on cooldown)
    local castable_trusts = {}
    for i, trust_name in ipairs(trusts) do
        local spell_id = nil
        for id, spell in pairs(res.spells) do
            if spell.type == 'Trust' and spell.name:lower() == trust_name:lower() then
                spell_id = id
                break
            end
        end        if spell_id then
            local recast_info = windower.ffxi.get_spell_recasts()
            if recast_info and recast_info[spell_id] and recast_info[spell_id] > 0 then                local raw_time = recast_info[spell_id]                -- Convert using 60 as the divisor
                local seconds = math.floor(raw_time / 60)
                local minutes = math.floor(seconds / 60)
                local remaining_seconds = seconds % 60
                local time_str = minutes > 0 and (minutes .. 'm ' .. remaining_seconds .. 's') or (remaining_seconds .. 's')
                
                windower.add_to_chat(167, '[JustTrust] ' .. trust_name .. ' on cooldown (' .. time_str .. '), skipping...')
            else
                table.insert(castable_trusts, trust_name)
            end
        else
            table.insert(castable_trusts, trust_name) -- Cast even if we can't find spell ID
        end
    end
    
    -- Cast only the available trusts with proper delays
    for i, trust_name in ipairs(castable_trusts) do
        coroutine.schedule(function()
            windower.send_command('input /ma "' .. trust_name .. '" <me>')
        end, (i - 1) * 6) -- First trust immediately, then 6 seconds between each actual cast
    end
end

-- Function to list saved trust sets
local function list_trust_sets()
    if not next(trust_sets) then
        windower.add_to_chat(167, '[JustTrust] No saved trust sets found.')
        return
    end
    
    windower.add_to_chat(158, '[JustTrust] Saved trust sets:')
    for set_name, trusts in pairs(trust_sets) do
        windower.add_to_chat(158, '  ' .. set_name .. ': ' .. table.concat(trusts, ', '))
    end
end

-- Function to check if a trust name is owned
local function is_trust_owned(trust_name)
    local spells = windower.ffxi.get_spells()
    if not spells then return false end
    
    for spell_id, known in pairs(spells) do
        if known and res.spells[spell_id] and res.spells[spell_id].type == 'Trust' then
            local spell_name = res.spells[spell_id].name
            if match_trust_name(trust_name, spell_name) then
                return true
            end
        end
    end
    return false
end

-- Function to delete a trust set
local function delete_trust_set(set_name)
    if not trust_sets[set_name] then
        windower.add_to_chat(167, '[JustTrust] Trust set "' .. set_name .. '" not found!')
        return
    end
    
    trust_sets[set_name] = nil
    if save_trust_sets_to_file() then
        windower.add_to_chat(158, '[JustTrust] Deleted trust set "' .. set_name .. '"')
    else
        windower.add_to_chat(167, '[JustTrust] Trust set deleted from memory but failed to save to file')
    end
end

-- Function to clear all trust sets
local function clear_all_trust_sets()
    local count = 0
    for _ in pairs(trust_sets) do
        count = count + 1
    end
    
    if count == 0 then
        windower.add_to_chat(167, '[JustTrust] No trust sets to clear.')
        return
    end
    
    trust_sets = {}
    if save_trust_sets_to_file() then
        windower.add_to_chat(158, '[JustTrust] Cleared all ' .. count .. ' trust sets')
    else
        windower.add_to_chat(167, '[JustTrust] Trust sets cleared from memory but failed to save to file')
    end
end

-- Main detection
windower.register_event('incoming chunk', function(id, data)
    if id ~= 0x05C then return end
    
    -- Reduce spam after recent blocks
    local current_time = os.time()
    if current_time - menu_context.last_block_time < 3 then
        return -- Skip processing for 3 seconds after a block
    end
    
    local packet = packets.parse('incoming', data)
    if not packet or not packet['Menu Parameters'] then return end
    
    local menu = packet['Menu Parameters']
    if type(menu) ~= 'string' then return end
      -- Debug: Log raw menu info
    local debug_msg = 'SHOP MENU DETECTED: Length=' .. #menu .. ' bytes'
    log_to_file(debug_msg)  -- Only log to file, not chat
    
    -- Get ALL known trust spells 
    local spells = windower.ffxi.get_spells()
    if not spells then return end
    local owned_trusts = {}
    local available_trusts = {}  -- Trusts we don't have yet
    local seen_items = {}  -- Track duplicates
      -- Clear previous shop data only if this is a significantly different scan
    local previous_scan_time = menu_context.last_shop_scan
    local current_time = os.time()
    
    -- Don't clear slot data if this scan is very recent (might be a submenu change)
    if current_time - previous_scan_time > 3 then
        menu_context.shop_items = {}
        menu_context.owned_cipher_slots = {}
        log_to_file('CLEARING SHOP DATA - new scan after ' .. (current_time - previous_scan_time) .. ' seconds')
    else
        log_to_file('PRESERVING SHOP DATA - recent scan, keeping existing slot mappings')
    end
      -- Scan menu for trust ciphers and track slot positions
    local slot_index = 0
    for i = 1, #menu - 1, 2 do
        local item_id = string.byte(menu, i) + (string.byte(menu, i + 1) * 256)
        slot_index = slot_index + 1
        
        -- Store item by slot position
        menu_context.shop_items[slot_index] = item_id
        
        -- Debug: Log every item ID found with slot info
        if item_id > 0 then
            local item_debug = 'SLOT ' .. slot_index .. ': ID=' .. item_id
            if res.items[item_id] then
                item_debug = item_debug .. ' NAME=' .. res.items[item_id].name
            end
            log_to_file(item_debug)  -- Only log to file to avoid chat spam
        end
          if trust_ciphers[item_id] and not seen_items[item_id] then
            seen_items[item_id] = true  -- Prevent duplicates
            local item = res.items[item_id]
            if item then
                local msg = 'FOUND CIPHER: ID=' .. item_id .. ' NAME=' .. item.name .. ' SLOT=' .. slot_index                log_to_file(msg)  -- Only log to file, not chat
                
                -- Get cipher and trust names from our data
                local cipher_data = trust_cipher_module.get_cipher_data(item_id)
                if cipher_data then
                    local cipher_name = cipher_data[1]  -- cipher name
                    local trust_name = cipher_data[2]   -- trust name
                    
                    local extract_msg = 'CIPHER DATA: cipher=' .. cipher_name .. ' trust=' .. trust_name .. ' SLOT=' .. slot_index
                    log_to_file(extract_msg)  -- Only log to file, not chat                    -- Check if we own this trust using our cipher data
                    local found_match = false
                    
                    -- Get the trust name from our cipher data and check if we own it
                    for spell_id, known in pairs(spells) do
                        if known and res.spells[spell_id] and res.spells[spell_id].type == 'Trust' then
                            local spell_name = res.spells[spell_id].name
                            
                            -- Simple matching: check if this spell matches our trust
                            if match_trust_name(trust_name, spell_name) then
                                local match_msg = 'OWNED! Trust=' .. trust_name .. ' matches spell=' .. spell_name .. ' SLOT=' .. slot_index
                                log_to_file(match_msg)
                                table.insert(owned_trusts, trust_name)
                                found_match = true-- Mark this slot as containing an owned trust cipher
                                -- Don't overwrite if we already have this trust mapped to a different slot
                                local already_mapped = false
                                for existing_slot, existing_trust in pairs(menu_context.owned_cipher_slots) do
                                    if existing_trust == trust_name then
                                        already_mapped = true
                                        log_to_file('TRUST ALREADY MAPPED: ' .. trust_name .. ' in slot ' .. existing_slot .. ', also found in slot ' .. slot_index)
                                        break
                                    end
                                end
                                
                                if not already_mapped then
                                    menu_context.owned_cipher_slots[slot_index] = trust_name
                                    log_to_file('NEW MAPPING: Slot ' .. slot_index .. ' = ' .. trust_name)
                                end
                                found_match = true
                                break
                            end
                        end
                    end                      -- Log if no match found (for debugging)
                    if not found_match then
                        local no_match_msg = 'NO MATCH: Could not find trust spell for trust=' .. trust_name .. ' SLOT=' .. slot_index
                        log_to_file(no_match_msg)  -- Only log to file, not chat
                        table.insert(available_trusts, trust_name)  -- Add to available list
                    end
                else
                    local fail_msg = 'NO CIPHER DATA FOUND FOR ITEM ID: ' .. item_id .. ' (' .. item.name .. ') SLOT=' .. slot_index
                    log_to_file(fail_msg)  -- Only log to file, not chat
                end
            end
        end
    end    -- Show results and store for purchase blocking
    current_owned_trusts = owned_trusts
    current_available_trusts = available_trusts
    menu_context.last_shop_scan = os.time()  -- Track when we last scanned
    
    -- DETECT ITEM SELECTION: If a trust cipher appears in slot 1 and we previously saw it elsewhere,
    -- that means it was selected for purchase
    if slot_index >= 1 and menu_context.shop_items[1] then
        local item_in_slot_1 = menu_context.shop_items[1]        if trust_ciphers[item_in_slot_1] then
            local cipher_data = trust_cipher_module.get_cipher_data(item_in_slot_1)
            if cipher_data then
                local cipher_name = cipher_data[1]  -- cipher name  
                local trust_name = cipher_data[2]   -- trust name
                
                -- Check if this trust was previously in a different slot
                local was_in_different_slot = false
                for prev_slot, prev_trust in pairs(menu_context.owned_cipher_slots) do
                    if prev_trust == trust_name and prev_slot ~= 1 then
                        was_in_different_slot = true
                        log_to_file('SELECTION DETECTED: ' .. trust_name .. ' moved from slot ' .. prev_slot .. ' to slot 1 (SELECTED FOR PURCHASE)')
                        
                        -- This is a selection of an owned trust - set it for blocking
                        menu_context.selected_slot = 1
                        menu_context.selected_trust = trust_name
                        menu_context.last_selection_time = os.time()
                        break
                    end
                end
                
                if not was_in_different_slot then
                    log_to_file('SLOT 1 CIPHER: ' .. trust_name .. ' (no previous slot detected)')
                end
            end
        end
    end
    
    -- Log owned cipher slots for debugging
    if next(menu_context.owned_cipher_slots) then
        log_to_file('=== OWNED CIPHER SLOTS ===')
        for slot, trust_name in pairs(menu_context.owned_cipher_slots) do
            log_to_file('Slot ' .. slot .. ': ' .. trust_name .. ' (OWNED - WILL BLOCK)')
        end
    end
      if (#owned_trusts > 0 or #available_trusts > 0) and os.time() - last_msg > 5 then
        if #owned_trusts > 0 then
            windower.add_to_chat(167, '*** Shop contains ' .. #owned_trusts .. ' trust(s) you already own')
        end          if #available_trusts > 0 then
            if #available_trusts == 1 then
                windower.add_to_chat(158, '>>> Safe to buy: ' .. available_trusts[1])
            else
                windower.add_to_chat(158, '>>> Safe to buy: ' .. table.concat(available_trusts, ', '))
            end
        end
        
        last_msg = os.time()
    end
end)

-- Enhanced outgoing packet logging and precise blocking
windower.register_event('outgoing chunk', function(id, data, modified, injected, blocked)
    if id == 0x05B then
        local packet = packets.parse('outgoing', data)
        if not packet then return false end

        -- Log ALL fields and a hex dump for analysis
        local log_msg = '[OUTGOING 0x05B]'
        for k, v in pairs(packet) do
            log_msg = log_msg .. ' ' .. tostring(k) .. '=' .. tostring(v)
        end
        -- Hex dump
        local hex_data = ''
        for i = 1, math.min(#data, 32) do
            hex_data = hex_data .. string.format('%02X ', string.byte(data, i))
        end
        log_to_file(log_msg)
        log_to_file('RAW: ' .. hex_data)        -- --- BLOCKING LOGIC ---
        -- The option index in large values (like 2243) needs to be decoded to actual slot numbers
        -- Based on the log, option 2243 corresponds to slot 1 (Sakura)
        local menu_id = packet['Menu ID']
        local option_index = packet['Option Index']        if purchase_blocking_enabled and option_index then
            -- Check if we detected a trust selection recently
            local current_time = os.time()
            local should_block = false
            local block_reason = ""
            
            if menu_context.selected_trust and 
               (current_time - menu_context.last_selection_time) < 5 then
                
                log_to_file('CHECKING SELECTED TRUST: ' .. menu_context.selected_trust .. ' (selected ' .. (current_time - menu_context.last_selection_time) .. 's ago)')
                should_block = true
                block_reason = 'BLOCKING PURCHASE: Selected trust ' .. menu_context.selected_trust .. ' is owned'
                
            elseif option_index > 1000 and menu_context.owned_cipher_slots and next(menu_context.owned_cipher_slots) then
                -- Don't block multiple times in quick succession
                if (current_time - menu_context.last_block_time) < 2 then
                    log_to_file('IGNORING: Recent block, skipping option ' .. option_index)
                    return false
                end
                
                -- Fallback: High option values in shops with owned trusts
                should_block = true
                block_reason = 'FALLBACK BLOCKING: High option ' .. option_index .. ' in shop with owned trusts'
            end
            
            if should_block then
                -- Only show message once and update block time
                windower.add_to_chat(167, '*** PURCHASE BLOCKED! You already own this trust!')
                log_to_file(block_reason)
                menu_context.last_block_time = current_time
                
                -- Block by redirecting to option 0 (cancel)
                if #data >= 9 then
                    local cancel_option = 0
                    local modified_data = data:sub(1, 8) .. string.char(cancel_option) .. data:sub(10)
                    log_to_file('Redirected option ' .. option_index .. ' to ' .. cancel_option .. ' (Cancel)')
                    return modified_data
                end
                return true -- Block if modification fails
            else
                log_to_file('NO BLOCKING: Option=' .. option_index .. ', no recent selection detected')
            end
        end
    end
    return false
end)

local enabled = false

windower.register_event('addon command', function(command, ...)
    local args = {...}
    if not command then
        windower.add_to_chat(207, '[JustTrust] Available Commands:')
        windower.add_to_chat(207, '  //jt trustdupe - Toggle duplicate purchase protection on/off')
        windower.add_to_chat(207, '  //jt saveset <name> - Save current trust party as a named set')
        windower.add_to_chat(207, '  //jt loadset <name> - Load and cast a saved trust set')
        windower.add_to_chat(207, '  //jt setlist - List all saved trust sets')
        windower.add_to_chat(207, '  //jt deleteset <name> - Delete a specific trust set')
        windower.add_to_chat(207, '  //jt clearsets - Clear all saved trust sets')
        return
    end    command = command:lower()
    if command == 'help' then
        windower.add_to_chat(207, '[JustTrust] Available Commands:')
        windower.add_to_chat(207, '  //jt trustdupe - Toggle duplicate purchase protection on/off')
        windower.add_to_chat(207, '  //jt saveset <name> - Save current trust party as a named set')
        windower.add_to_chat(207, '  //jt loadset <name> - Load and cast a saved trust set')
        windower.add_to_chat(207, '  //jt setlist - List all saved trust sets')
        windower.add_to_chat(207, '  //jt deleteset <name> - Delete a specific trust set')
        windower.add_to_chat(207, '  //jt clearsets - Clear all saved trust sets')
        return
    elseif command == 'trustdupe' then
        purchase_blocking_enabled = not purchase_blocking_enabled
        windower.add_to_chat(207, '[JustTrust] Trust duplicate purchase protection: ' .. (purchase_blocking_enabled and 'ENABLED' or 'DISABLED'))
        return
    elseif command == 'saveset' then
        if not args[1] then
            windower.add_to_chat(167, '[JustTrust] Usage: //jt saveset <name>')
            return
        end
        local set_name = args[1]
        local current_trusts = get_current_trusts()
        if #current_trusts == 0 then
            windower.add_to_chat(167, '[JustTrust] No trusts currently summoned!')
            return
        end
        save_trust_set(set_name, current_trusts)
        return
    elseif command == 'loadset' then
        if not args[1] then
            windower.add_to_chat(167, '[JustTrust] Usage: //jt loadset <name>')
            return
        end
        load_trust_set(args[1])
        return
    elseif command == 'setlist' then
        list_trust_sets()
        return
    elseif command == 'deleteset' then
        if not args[1] then
            windower.add_to_chat(167, '[JustTrust] Usage: //jt deleteset <name>')
            return
        end
        delete_trust_set(args[1])
        return    elseif command == 'clearsets' then
        clear_all_trust_sets()        return
    end

    windower.add_to_chat(167, '[JustTrust] Unknown command: ' .. command)
end)

windower.register_event('load', function()
    windower.add_to_chat(207, '[JustTrust] Loaded! Use //jt help for a list of commands')
    load_trust_sets_from_file() -- Load trust sets from file on addon load
end)

-- Simple toggle function
function toggle()
    purchase_blocking_enabled = not purchase_blocking_enabled
    windower.add_to_chat(207, 'JustTrust: Purchase blocking ' .. (purchase_blocking_enabled and 'ENABLED' or 'DISABLED'))
end

-- Ensure log file is closed on unload
windower.register_event('unload', function()
    if debug_log_file then
        debug_log_file:close()
        debug_log_file = nil
    end
    -- Remove the alias when unloading
    windower.send_command('unalias jt')
end)
windower.register_event('unload', function()
    if debug_log_file then
        debug_log_file:close()
        debug_log_file = nil
    end
    -- Remove the alias when unloading
    windower.send_command('unalias jt')
end)
