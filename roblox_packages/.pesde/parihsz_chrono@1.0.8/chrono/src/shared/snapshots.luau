export type SnapshotData<T> = {
	t: number,
	value: T,
}

export type CircularSnapshot<T> = {
	cache: { SnapshotData<T> },
	pivotIndex: number?, -- to make math easier, this is stored as 0 indexed, then 1 is added whenever it's used for indexing
	lerp: (T, T, number) -> T,

	Push: (self: CircularSnapshot<T>, t: number, value: T) -> (),
	GetLatest: (self: CircularSnapshot<T>) -> SnapshotData<T>?,
	GetAt: (self: CircularSnapshot<T>, t: number) -> T?,
	Clear: (self: CircularSnapshot<T>) -> (),
}

local MAX_LENGTH = 30
local MAX_T = 256
local HALF_T = MAX_T // 2
local SHOW_WARNINGS = false

local warn = SHOW_WARNINGS and warn or function() end

-- for lune test
local map: typeof(math.map) = math.map
	or function(x: any, inMin: any, inMax: any, outMin: any, outMax: any): any
		local alpha = (x - inMin) / (inMax - inMin)

		return outMin + ((outMax - outMin) * alpha)
	end

local function isGreater(t1: number, t2: number)
	local delta = (t2 - t1) % MAX_T

	-- 0 should be greater than 255, but 255 should be greater than 128
	return delta > 0 and delta <= HALF_T
end

local function Push<T>(self: CircularSnapshot<T>, t: number, value: T): ()
	local data = {
		t = t,
		value = value,
	}

	local cache = self.cache
	local pivotIndex = self.pivotIndex

	-- first entry in the cache
	if not pivotIndex then
		cache[1] = data
		self.pivotIndex = 0
		return
	end

	local pivotValue = self.cache[pivotIndex + 1].t

	if isGreater(pivotValue, t) then
		-- Given value is greater than everything else, so overwrite the oldest value with it
		local nextIndex = (pivotIndex + 1) % MAX_LENGTH
		cache[nextIndex + 1] = data

		self.pivotIndex = nextIndex
		return
	else
		-- Given value is lower than the greatest value - it is probably an out of order packet
		--  walk backwards through the snapshots until you find the correct insert position
		--  cascade movement backwards until the oldest entry is removed, or we encounter an empty spot
		--  could potentially be a binary search, but that gets somewhat complicated due to the circularity
		--  our length is very low so the perf difference does not matter
		local nextIndex = (pivotIndex - 1) % MAX_LENGTH
		local currentValue = data

		while nextIndex ~= pivotIndex and currentValue ~= nil do
			local snapshotEntry = cache[nextIndex + 1]
			if snapshotEntry == nil or isGreater(snapshotEntry.t, currentValue.t) then
				cache[nextIndex + 1] = currentValue
				currentValue = snapshotEntry
			end

			nextIndex = (nextIndex - 1) % MAX_LENGTH
		end
	end
end

local function GetLatest<T>(self: CircularSnapshot<T>): SnapshotData<T>?
	if self.pivotIndex then
		return self.cache[self.pivotIndex + 1]
	end

	return nil
end

local function GetBefore<T>(self: CircularSnapshot<T>, before: number): SnapshotData<T>?
	local currentIndex = self.pivotIndex
	if not currentIndex then
		return nil
	end

	-- Walk backwards from the pivot until we find something smaller than the input, or until we reach the end of the array
	repeat
		local value = self.cache[currentIndex + 1]
		if not value then
			return nil
		end

		if isGreater(value.t, before) then
			return value
		end
		currentIndex = (currentIndex - 1) % MAX_LENGTH
	until currentIndex == self.pivotIndex

	return nil
end

local function GetAfter<T>(self: CircularSnapshot<T>, after: number): SnapshotData<T>?
	if not self.pivotIndex then
		return nil
	end

	local currentIndex = (self.pivotIndex + 1) % MAX_LENGTH

	-- Walk forwards from the lowest snapshot until we find something bigger than the input, or we reach the pivot
	repeat
		local value = self.cache[currentIndex + 1]

		if value and isGreater(after, value.t) then
			return value
		end

		currentIndex = (currentIndex + 1) % MAX_LENGTH
	until currentIndex == (self.pivotIndex + 1) % MAX_LENGTH

	return nil
end

local function GetAt<T>(self: CircularSnapshot<T>, at: number): T?
	local cache = self.cache
	local pivotIndex = self.pivotIndex
	if not pivotIndex then
		return nil
	end

	if #cache == 1 then
		return cache[pivotIndex + 1].value
	end

	local before = GetBefore(self, at)
	local after = GetAfter(self, at)

	if before and after then
		if before == after then
			return before.value
		end

		local beforeTime = before.t
		local afterTime = after.t
		if beforeTime > afterTime then
			-- We're crossing a loop, e.g. before is 255, after is 1
			afterTime += 256
		end

		if beforeTime > at then
			at += 256
		end

		local alpha = map(at, beforeTime, afterTime, 0, 1)
		return self.lerp(before.value, after.value, alpha)
	elseif before then
		-- no after, i.e. we're returning the most recent cframe
		warn("Tried to fetch a time that was ahead of snapshot storage!")
		return before.value
	elseif after then
		-- no before, i.e. the time we're looking for doesn't exist in the snapshot
		warn("Tried to fetch a time that was behind  snapshot storage!")
		return after.value
	end

	return nil
end

local function Clear(self: CircularSnapshot<T>): ()
	self.cache = {}
	self.pivotIndex = nil
end

local function new<T>(lerp: (T, T, number) -> T): CircularSnapshot<T>
	return {
		cache = {},
		pivotIndex = nil,
		lerp = lerp,

		Push = Push,
		GetLatest = GetLatest,
		GetAt = GetAt,
		Clear = Clear,
	}
end

return new
