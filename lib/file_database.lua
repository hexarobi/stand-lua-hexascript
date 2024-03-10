-- File Database

local BASE_DIR = filesystem.store_dir().."/database/"
local db = {
    name="default"
}
filesystem.mkdirs(BASE_DIR)

db.save_data = function(key, data)
    if key == nil or key == "" then
        error("Cannot save data: Invalid Key")
    end
    local file_path = db.build_file_path_from_key(key)
    local file = io.open(file_path, "wb")
    if file == nil then util.toast("Error opening database file for writing: "..file_path, TOAST_ALL) return end
    file:write(soup.json.encode({data=data}))
    file:close()
end

db.load_data = function(key)
    local file_path = db.build_file_path_from_key(key)
    local file = io.open(file_path)
    if file == nil then return nil end
    local data = soup.json.decode(file:read())
    file:close()
    if data == nil then return nil end
    return data["data"]
end

db.get_database_path = function()
    return BASE_DIR..db.name.."/"
end

db.build_file_path_from_key = function(key)
    local file_path = db.get_database_path()..key..".json"
    return file_path
end

db.set_name = function(name)
    db.name = name
    filesystem.mkdirs(db.get_database_path())
end

return db