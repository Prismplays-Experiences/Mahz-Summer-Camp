local fs = require("@lune/fs")

local PATH_TO_TAG_STORE = "lune/modules/Tag/TagStore.txt"

export type Tag = {
	Set: (newTag: string) -> (),
	Get: () -> string?,
}

local Tag = {}

function Tag.Set(newTag: string): ()
	fs.writeFile(PATH_TO_TAG_STORE, `{newTag}`)
end

function Tag.Get(): string?
	local tag

	if fs.isFile(PATH_TO_TAG_STORE) == false then
		return "nil"
	else
		tag = fs.readFile(PATH_TO_TAG_STORE)
		tag = tag:sub(1, -1)
	end

	return tag
end

return Tag
