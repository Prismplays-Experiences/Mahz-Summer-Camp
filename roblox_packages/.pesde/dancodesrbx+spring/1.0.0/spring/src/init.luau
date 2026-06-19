--!nocheck

type ClockFunction = () -> number

type Spring<T> = {
	Impulse: (self: Spring<T>, velocity: T) -> (),
	TimeSkip: (self: Spring<T>, delta: number) -> (),
	SetTarget: (self: Spring<T>, target: T, doNotAnimate: boolean?) -> (),
	Clock: ClockFunction,
	Damper: number,
	Speed: number,
	Target: T,
	Velocity: T,
	Position: T,
}

local Spring = {}

--[=[
	Constructs a new Spring at the position and target specified, of type T.

	```lua
	-- Linear spring
	local linearSpring = Spring.new(0)

	-- Vector2 spring
	local vector2Spring = Spring.new(Vector2.zero)

	-- Vector3 spring
	local vector3Spring = Spring.new(Vector3.zero)
	```
]=]
function Spring.new<T>(initial: T, clock: ClockFunction?): Spring<T>
	local target = initial
	clock = clock or os.clock
	return setmetatable({
		_clock = clock;
		_time0 = clock();
		_position0 = target;
		_velocity0 = 0*target;
		_target = target;
		_damper = 1;
		_speed = 1;
	}, Spring)
end

--[=[
	Impulses the spring, increasing velocity by the amount given. This is useful to make something shake,
	like a Mac password box failing.
]=]
function Spring:Impulse(velocity)
	self.Velocity = self.Velocity + velocity
end

--[=[
	Instantly skips the spring forwards by that amount time
]=]
function Spring:TimeSkip(delta)
	local now = self._clock()
	local position, velocity = self:_positionVelocity(now+delta)
	self._position0 = position
	self._velocity0 = velocity
	self._time0 = now
end

--[=[
	Sets the actual target. If doNotAnimate is set, then animation will be skipped.
]=]
function Spring:SetTarget(value, doNotAnimate)
	if doNotAnimate then
		local now = self._clock()
		self._position0 = value
		self._velocity0 = 0*value
		self._target = value
		self._time0 = now
	else
		self.Target = value
	end
end

function Spring:__index(index)
	if Spring[index] then
		return Spring[index]
	elseif index == "Position" then
		local position, _ = self:_positionVelocity(self._clock())
		return position
	elseif index == "Velocity" then
		local _, velocity = self:_positionVelocity(self._clock())
		return velocity
	elseif index == "Target" then
		return self._target
	elseif index == "Damper" then
		return self._damper
	elseif index == "Speed" then
		return self._speed
	elseif index == "Clock" then
		return self._clock
	else
		error(string.format("%q is not a valid member of Spring", tostring(index)), 2)
	end
end

function Spring:__newindex(index, value)
	local now = self._clock()

	if index == "Position" then
		local _, velocity = self:_positionVelocity(now)
		self._position0 = value
		self._velocity0 = velocity
		self._time0 = now
	elseif index == "Velocity" then
		local position, _ = self:_positionVelocity(now)
		self._position0 = position
		self._velocity0 = value
		self._time0 = now
	elseif index == "Target" then
		local position, velocity = self:_positionVelocity(now)
		self._position0 = position
		self._velocity0 = velocity
		self._target = value
		self._time0 = now
	elseif index == "Damper" then
		local position, velocity = self:_positionVelocity(now)
		self._position0 = position
		self._velocity0 = velocity
		self._damper = value
		self._time0 = now
	elseif index == "Speed" then
		local position, velocity = self:_positionVelocity(now)
		self._position0 = position
		self._velocity0 = velocity
		self._speed = value < 0 and 0 or value
		self._time0 = now
	elseif index == "Clock" then
		local position, velocity = self:_positionVelocity(now)
		self._position0 = position
		self._velocity0 = velocity
		self._clock = value
		self._time0 = value()
	else
		error(string.format("%q is not a valid member of Spring", tostring(index)), 2)
	end
end

function Spring:_positionVelocity(now)
	local p0 = self._position0
	local v0 = self._velocity0
	local p1 = self._target
	local d = self._damper
	local s = self._speed

	local t = s*(now - self._time0)
	local d2 = d*d

	local h, si, co
	if d2 < 1 then
		h = math.sqrt(1 - d2)
		local ep = math.exp(-d*t)/h
		co, si = ep*math.cos(h*t), ep*math.sin(h*t)
	elseif d2 == 1 then
		h = 1
		local ep = math.exp(-d*t)/h
		co, si = ep, ep*t
	else
		h = math.sqrt(d2 - 1)
		local u = math.exp((-d + h)*t)/(2*h)
		local v = math.exp((-d - h)*t)/(2*h)
		co, si = u + v, u - v
	end

	local a0 = h*co + d*si
	local a1 = 1 - (h*co + d*si)
	local a2 = si/s

	local b0 = -s*si
	local b1 = s*si
	local b2 = h*co - d*si

	return
		a0*p0 + a1*p1 + a2*v0,
		b0*p0 + b1*p1 + b2*v0
end

return table.freeze({
	new = Spring.new
})