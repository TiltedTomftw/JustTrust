-- Trust Cipher Data for JustTrust Addon
-- Contains item IDs, cipher names, and trust name mappings for ownership verification

local trust_ciphers = {
    -- Data structure: [item_id] = {cipher_name, trust_name, full_cipher_description}
    -- cipher_name: the short name from the cipher data
    -- trust_name: the actual trust spell name (for matching)
    -- full_cipher_description: the full cipher item name for reference
      [10112] = {"zeid", "Zeid", "Cipher of Zeid's Alter Ego"},
    [10113] = {"lion", "Lion", "Cipher of Lion's Alter Ego"},
    [10114] = {"tenzen", "Tenzen", "Cipher of Tenzen's Alter Ego"},
    [10115] = {"mihli", "Mihli Aliapoh", "Cipher of Mihli's Alter Ego"},
    [10116] = {"valaineral", "Valaineral", "Cipher of Valaineral's Alter Ego"},
    [10117] = {"joachim", "Joachim", "Cipher of Joachim's Alter Ego"},
    [10118] = {"naja", "Naja Salaheem", "Cipher of Naja's Alter Ego"},
    [10119] = {"rainemard", "Rainemard", "Cipher of Rainemard's Alter Ego"},
    [10120] = {"lehko", "Lehko Habhoka", "Cipher of Lehko's Alter Ego"},
    [10121] = {"ovjang", "Ovjang", "Cipher of Ovjang's Alter Ego"},
    [10122] = {"mnejing", "Mnejing", "Cipher of Mnejing's Alter Ego"},
    [10123] = {"sakura", "Sakura", "Cipher of Sakura's Alter Ego"},
    [10124] = {"luzaf", "Luzaf", "Cipher of Luzaf's Alter Ego"},
    [10125] = {"najelith", "Najelith", "Cipher of Najelith's Alter Ego"},
    [10126] = {"aldo", "Aldo", "Cipher of Aldo's Alter Ego"},
    [10127] = {"moogle", "Moogle", "Cipher of a Moogle's Alter Ego"},
    [10128] = {"fablinix", "Fablinix", "Cipher of Fablinix's Alter Ego"},
    [10129] = {"domina", "D. Shantotto", "Cipher of D. Shantotto's Alter Ego"},
    [10130] = {"elivira", "Elivira", "Cipher of Elivira's Alter Ego"},
    [10131] = {"noillurie", "Noillurie", "Cipher of Noillurie's Alter Ego"},
    [10132] = {"lhu", "Lhu Mhakaracca", "Cipher of Lhu's Alter Ego"},
    [10133] = {"f._coffin", "Ferreous Coffin", "Cipher of F. Coffin's Alter Ego"},
    [10134] = {"s._sibyl", "Star Sibyl", "Cipher of Star Sibyl's Alter Ego"},
    [10135] = {"mumor", "Mumor", "Cipher of Mumor's Alter Ego"},
    [10136] = {"uka", "Uka Totlihn", "Cipher of Uka's Alter Ego"},
    [10137] = {"lilisette", "Lilisette", "Cipher of Lilisette's Alter Ego"},
    [10138] = {"cid", "Cid", "Cipher of Cid's Alter Ego"},
    [10139] = {"rahal", "Rahal", "Cipher of Rahal's Alter Ego"},
    [10140] = {"koru-moru", "Koru-Moru", "Cipher of Koru-Moru's Alter Ego"},
    [10141] = {"kuyin", "Kuyin Hathdenna", "Cipher of Kuyin's Alter Ego"},
    [10142] = {"karaha", "Karaha-Baruha", "Cipher of Karaha's Alter Ego"},
    [10143] = {"babban", "Babban", "Cipher of Babban's Alter Ego"},
    [10144] = {"abenzio", "Abenzio", "Cipher of Abenzio's Alter Ego"},
    [10145] = {"rughadjeen", "Rughadjeen", "Cipher of Rughadjeen's Alter Ego"},
    [10146] = {"kukki", "Kukki-Chebukki", "Cipher of Kukki's Alter Ego"},
    [10147] = {"margret", "Margret", "Cipher of Margret's Alter Ego"},
    [10148] = {"gilgamesh", "Gilgamesh", "Cipher of Gilgamesh's Alter Ego"},
    [10149] = {"areuhat", "Areuhat", "Cipher of Areuhat's Alter Ego"},
    [10150] = {"lhe", "Lhe Lhangavo", "Cipher of Lhe's Alter Ego"},
    [10151] = {"mayakov", "Mayakov", "Cipher of Mayakov's Alter Ego"},
    [10152] = {"qultada", "Qultada", "Cipher of Qultada's Alter Ego"},
    [10153] = {"adelheid", "Adelheid", "Cipher of Adelheid's Alter Ego"},
    [10154] = {"amchuchu", "Amchuchu", "Cipher of Amchuchu's Alter Ego"},
    [10155] = {"brygid", "Brygid", "Cipher of Brygid's Alter Ego"},
    [10156] = {"mildaurion", "Mildaurion", "Cipher of Mildaurion's Alter Ego"},
    [10157] = {"semih", "Semih Lafihna", "Cipher of Semih's Alter Ego"},
    [10158] = {"halver", "Halver", "Cipher of Halver's Alter Ego"},
    [10159] = {"lion_ii", "Lion II", "Cipher of Lion's Alter Ego II"},
    [10160] = {"zeid_ii", "Zeid II", "Cipher of Zeid's Alter Ego II"},
    [10161] = {"rongelouts", "Rongelouts", "Cipher of Rongelouts's Alter Ego"},
    [10162] = {"kupofried", "Kupofried", "Cipher of Kupofried's Alter Ego"},
    [10163] = {"leonoyne", "Leonoyne", "Cipher of Leonoyne's Alter Ego"},
    [10164] = {"maximilian", "Maximilian", "Cipher of Maximilian's Alter Ego"},
    [10165] = {"kayeel", "Kayeel-Payeel", "Cipher of Kayeel's Alter Ego"},
    [10166] = {"robel-akbel", "Robel-Akbel", "Cipher of Robel-Akbel's Alter Ego"},
    [10167] = {"tenzen_ii", "Tenzen II", "Cipher of Tenzen's Alter Ego II"},
    [10168] = {"prishe_ii", "Prishe II", "Cipher of Prishe's Alter Ego II"},
    [10169] = {"abquhbah", "Abquhbah", "Cipher of Abquhbah's Alter Ego"},
    [10170] = {"nashmeira_ii", "Nashmeira II", "Cipher of Nashmeira's Alter Ego II"},
    [10171] = {"lilisette_ii", "Lilisette II", "Cipher of Lilisette's Alter Ego II"},
    [10172] = {"balamor", "Balamor", "Cipher of Balamor's Alter Ego"},
    [10173] = {"selhteus", "Selh'teus", "Cipher of Selhteus's Alter Ego"},
    [10174] = {"ingrid_ii", "Ingrid II", "Cipher of Ingrid's Alter Ego II"},
    [10175] = {"august", "August", "Cipher of August's Alter Ego"},
    [10176] = {"rosulatia", "Rosulatia", "Cipher of Rosulatia's Alter Ego"},
    [10177] = {"mumor_ii", "Mumor II", "Cipher of Mumor's Alter Ego II"},
    [10178] = {"ullegore", "Ullegore", "Cipher of Ullegore's Alter Ego"},
    [10179] = {"teodor", "Teodor", "Cipher of Teodor's Alter Ego"},
    [10180] = {"makki", "Makki-Chebukki", "Cipher of Makki's Alter Ego"},
    [10181] = {"king", "King of Hearts", "Cipher of King's Alter Ego"},
    [10182] = {"morimar", "Morimar", "Cipher of Morimar's Alter Ego"},
    [10183] = {"darrcuiln", "Darrcuiln", "Cipher of Darrcuiln's Alter Ego"},
    [10184] = {"arciela_ii", "Arciela II", "Cipher of Arciela's Alter Ego II"},
    [10185] = {"iroha", "Iroha", "Cipher of Iroha's Alter Ego"},
    [10186] = {"iroha_ii", "Iroha II", "Cipher of Iroha's Alter Ego II"},
    [10187] = {"shantotto_ii", "Shantotto II", "Cipher of Shantotto's Alter Ego II"},
    [10188] = {"ark_hm", "AAHM", "Cipher of AA HM's Alter Ego"},
    [10189] = {"ark_tt", "AATT", "Cipher of AA TT's Alter Ego"},
    [10190] = {"ark_mr", "AAMR", "Cipher of AA MR's Alter Ego"},
    [10191] = {"ark_ev", "AAEV", "Cipher of AA EV's Alter Ego"},
    [10192] = {"ark_gk", "AAGK", "Cipher of AA GK's Alter Ego"}
}

-- Helper function to check if an item ID is a trust cipher
local function is_trust_cipher(item_id)
    return trust_ciphers[item_id] ~= nil
end

-- Helper function to get cipher data by item ID
local function get_cipher_data(item_id)
    return trust_ciphers[item_id]
end

-- Helper function to get trust name by item ID
local function get_trust_name_by_id(item_id)
    local cipher_data = trust_ciphers[item_id]
    return cipher_data and cipher_data[2] or nil
end

-- Helper function to get cipher name by item ID
local function get_cipher_name_by_id(item_id)
    local cipher_data = trust_ciphers[item_id]
    return cipher_data and cipher_data[1] or nil
end

-- Helper function to find cipher by trust name (for reverse lookup)
local function find_cipher_by_trust_name(trust_name)
    for item_id, cipher_data in pairs(trust_ciphers) do
        if cipher_data[2]:lower() == trust_name:lower() then
            return item_id, cipher_data
        end
    end
    return nil, nil
end

-- Return the module with data and helper functions
return {
    data = trust_ciphers,
    is_trust_cipher = is_trust_cipher,
    get_cipher_data = get_cipher_data,
    get_trust_name_by_id = get_trust_name_by_id,
    get_cipher_name_by_id = get_cipher_name_by_id,
    find_cipher_by_trust_name = find_cipher_by_trust_name
}
