local Path = require('@LuauPackages/.pesde/jiwonz+luau_path/0.1.4/luau_path/src/Path')
local types = require("@LuauPackages/.pesde/jiwonz+luau_path/0.1.4/luau_path/src/types")

export type Path = types.Path
export type AsPath = types.AsPath

return {
    Path = (Path :: any) :: {
		new: (path: string) -> types.Path,
		from: (path: types.AsPath) -> types.Path,
		is: (value: unknown) -> boolean,
	},
}
