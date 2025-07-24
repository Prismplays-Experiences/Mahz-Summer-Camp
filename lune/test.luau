local task = require("@lune/task")

local ProgressBar = require("@LunePackages/ProgressBar")

local bar = ProgressBar.new()
local bar2 = ProgressBar.new()

bar:withStage("test", "hello")
bar:withStage("test", "hello2")
bar:withStage("test2", "hello3")
bar:withStage("test2", "hello4")
bar2:withStage("a", "HELLO FROM BAR 2")

bar:start()
bar2:start()

while true do
	task.wait(1)

	if not bar.finished then
		bar:nextStage()
    else
        break
	end
end

bar:stop()

task.wait(2)

bar2:stop()
