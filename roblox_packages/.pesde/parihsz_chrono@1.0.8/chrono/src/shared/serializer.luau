--@noDoc
--!optimize 2
--!native



--[=[
	A simple serializer that can serialize and deserialize data
	@class SerializerClass
	@fileName Serializer
	@path Shared.Libs.Serializer
	@alias Serializer
]=]
local SerializerFast = {}

local SER_TYPES = {}
SER_TYPES.U8 = 1
SER_TYPES.I8 = 2
SER_TYPES.U16 = 3
SER_TYPES.I16 = 4
SER_TYPES.U24 = 5
SER_TYPES.I24 = 6
SER_TYPES.U32 = 7
SER_TYPES.I32 = 8
SER_TYPES.F32 = 9
SER_TYPES.F64 = 10
SER_TYPES.UINT = 11
SER_TYPES.VECTOR3 = 12
SER_TYPES.VECTOR2 = 13
SER_TYPES.STRING = 14
SER_TYPES.CFRAME = 15
SER_TYPES.BUFFER = 16
SER_TYPES.BOOL = 17
SER_TYPES.ANY = 18
SER_TYPES.COLOR3 = 19

do
    local enums = {}
    for i,v in SER_TYPES do
        enums[v] = i
    end
    SER_TYPES.enums = enums
end

local iWriter, iReader = {}, {}
local typeToEnum = {
	number = SER_TYPES.F64, 
	string = SER_TYPES.STRING,
	Vector3 = SER_TYPES.VECTOR3,
	Vector2 = SER_TYPES.VECTOR2,
	CFrame = SER_TYPES.CFRAME,
	buffer = SER_TYPES.BUFFER,
	boolean = SER_TYPES.BOOL,
    Color3 = SER_TYPES.COLOR3,

	["nil"] = 254,
}


local EnumOrder = SER_TYPES.enums

local NameLookUp = {}
for i, v in EnumOrder do
	NameLookUp[v] = i
end


local GROWTH_FACTOR = 1.5

local buffer_object = buffer.create(0)
local cursor:number = 0

local tempWriter = {
	buffer = buffer_object,
	cursor = cursor,
}
local tempReader = {
	buffer = buffer_object,
	cursor = 0,
}

local bufferCopy = buffer.copy


local function wrapWriter(func)
	return function(value: any, ...)
		tempWriter.buffer = buffer_object
		tempWriter.cursor = cursor
		func(tempWriter, value)
		cursor = tempWriter.cursor
		buffer_object = tempWriter.buffer
	end
end

local function wrapReader(func)
	return function(): any
		tempReader.buffer = buffer_object
		tempReader.cursor = cursor
		local value = func(tempReader)
		cursor = tempReader.cursor
		return value
	end
end

export type SerializerAny = number|string|buffer|Vector3|Vector2|CFrame|nil|boolean

export type Schema<T> = {
    writer: (s:Serializer, value:T) -> (),
    reader: (s:Serializer) -> (T)
}
export type option = number&Schema<any>


--https://github.com/Data-Oriented-House/Cursor/blob/152efed23b696e1e7bca1e9beed79c931c5f1ac0/src/init.luau#L7
local function realloc(bytes: number)
	local b = buffer_object
	local p = cursor
	local len = buffer.len(b)

	if len < (p + bytes) then
		if len == 0 then
			len = 1
		end
		local exponent = math.ceil(math.log((bytes + p) / len, GROWTH_FACTOR))
		local new = buffer.create(len * GROWTH_FACTOR ^ exponent)
		bufferCopy(new, 0, b, 0)
		buffer_object = new
	end
end

local customType = typeof

export type Serializer = {
    buffer: buffer,
    cursor: number,
}

function SerializerFast.new(input: (number | buffer)?): Serializer
	local self = {}
	if type(input) == "number" then
		self.buffer = buffer.create(input)
	else
		self.buffer = input or buffer.create(1024)
	end
	self.cursor = 0
	return self
end

function SerializerFast.load(ser:Serializer|buffer, cursorLoc:number?)
	if type(ser) == "table" and ser.buffer then
		buffer_object = ser.buffer
		cursor = cursorLoc or ser.cursor or 0
	elseif type(ser) == "buffer" then
		buffer_object = ser :: buffer
		cursor = cursorLoc or 0
	else
		error("Invalid serializer | must be a Serializer or a buffer "..customType(ser))
	end
end

function SerializerFast.save(ser:Serializer)
	ser.buffer = buffer_object
	ser.cursor = cursor
end


function SerializerFast.get(): (buffer, number)
	return buffer_object, cursor
end


--[=[
	Get the reader function from the option
	@type function
	@param option option
	@return (s:Serializer, ...any) -> any
	@parent SerializerClass
]=]
local function getReaderFrom(option: option): ((...any) -> any)?
	local func = iReader[option]
	if not func then
		if type(option) == "table" and option.reader then
			return wrapReader(option.reader)
		end
	end
	return func
end

SerializerFast.getReaderFrom = getReaderFrom


local function getWriterFrom(option: option): (( value: any, ...any) -> ())?
	local func = iWriter[option]
	if not func then
		if type(option) == "table" and option.writer then
			return wrapWriter(option.writer)
		end
	end
	return func
end

local function GetVlqSize(value: number): number
	value += 1
	if value == 0 then
		return 1
	end
	return math.log(value) // math.log(128) + 1
end

local function WriteVlqRaw(b: buffer, index: number, value: number)
	value += 1
	repeat
		local byte = bit32.band(value, 0x7F)
		value = bit32.rshift(value, 7)

		if value > 0 then
			byte = bit32.bor(byte, 0x80)
		end

		buffer.writeu8(b, index, byte)
		index += 1
	until value == 0
end

local function WriteVlq(value: number)
	local size = GetVlqSize(value)
		realloc(size)
		local b = buffer_object
		local p = cursor
		cursor = p + size
		WriteVlqRaw(b, p, value)
end



local function ReadVlqRaw(b: buffer, index: number): (number, number)
	local value = 0
	local shift = 0
	local byte: number

	repeat
		byte = buffer.readu8(b, index)
		value += bit32.lshift(bit32.band(byte, 0x7F), shift)
		shift += 7
		index += 1
	until byte < 0x80
	return value-1, index
end

local function ReadVlq(): number
	local b = buffer_object
	local c = cursor
	local value,idx = ReadVlqRaw(b, c)
	cursor = idx
	return value
end

--[=[
	Gets the size of a vlq

	@type function
	@param value number
	@return number -- The size of the vlq in bytes
]=]
SerializerFast.uIntSize = GetVlqSize

--[=[
	Get the writer function from the option
	@type function
	@param option option
	@return (s:Serializer, value:any, ...any) -> any
	@parent SerializerClass
]=]
SerializerFast.getWriterFrom = getWriterFrom

local function writeu24(b: buffer, i: number, v: number)
	buffer.writeu8(b, i, v)
	buffer.writeu16(b, i + 1, v // 256)
end

local function readu24(b: buffer, index: number): (number)
	local v = buffer.readu8(b, index)
	v += buffer.readu16(b, index + 1) * 256
	return v
end


local function readi24(b: buffer, index: number): (number, number)
	local v = buffer.readi8(b, index)
	v += buffer.readi16(b, index + 1) * 256
	return v, index + 3
end

do
	function SerializerFast.toBuffer():buffer
		local b = buffer.create(cursor)
		bufferCopy(b, 0, buffer_object, 0, cursor)
		return b
	end

	--[=[
		Writes a u8 to the buffer
		@param value number
	]=]
	function SerializerFast.writeu8(value: number)
		realloc(1)
		buffer.writeu8(buffer_object, cursor, value)
		cursor += 1
	end

	--[=[
		Writes a u16 to the buffer
		@param value number
	]=]
	function SerializerFast.writeu16(value: number)
		realloc(2)
		buffer.writeu16(buffer_object, cursor, value)
		cursor += 2
	end

	--[=[
		Writes a u24 to the buffer
		@param value number
	]=]
	function SerializerFast.writeu24(value: number)
		realloc(3)
		buffer.writeu8(buffer_object, cursor, value)
		buffer.writeu16(buffer_object, cursor + 1, value // 256)
		cursor += 3
	end


	--[=[
		Writes a VLQ to the buffer. MAXIMUM VALUE IS 2^32-2

		@param value number
	]=]
	function SerializerFast.writeuInt(value: number)
		WriteVlq(value)
	end

	--[=[
		Writes a i8 to the buffer
		@param value number
	]=]
	function SerializerFast.writeu32(value: number)
		realloc(4)
		buffer.writeu32(buffer_object, cursor, value)
		cursor += 4
	end

	--[=[
		Writes a i8 to the buffer
		@param value number
	]=]
	function SerializerFast.writei8(value: number)
		realloc(1)

		buffer.writei8(buffer_object, cursor, value)
		cursor += 1
	end

	--[=[
		Writes a i16 to the buffer
		@param value number
	]=]
	function SerializerFast.writei16(value: number)
		realloc(2)
		buffer.writei16(buffer_object, cursor, value)
		cursor += 2
	end

	--[=[
		Writes a i24 to the buffer
		@param value number
	]=]
	function SerializerFast.writei24(value: number)
		realloc(3)
		buffer.writei8(buffer_object, cursor, value)
		buffer.writei16(buffer_object, cursor + 1, value // 256)
		cursor += 3
	end

	--[=[
		Writes a i32 to the buffer

		@param value number
	]=]
	function SerializerFast.writei32(value: number)
		realloc(4)
		buffer.writei32(buffer_object, cursor, value)
		cursor += 4
	end


	--[=[
		Writes a f32 to the buffer
	
		@param value number
	]=]
	function SerializerFast.writef32(value: number)
		realloc(4)
		buffer.writef32(buffer_object, cursor, value)
		cursor += 4
	end

	--[=[
		Writes a f64 to the buffer
	
		@param value number
	]=]
	function SerializerFast.writef64(value: number)
		realloc(8)
		buffer.writef64(buffer_object, cursor, value)
		cursor += 8
	end

	--[=[
		Writes a Vector3 to the buffer

		@param value Vector3
	]=]
	function SerializerFast.writeVector3(value: Vector3)
		realloc(12)
		buffer.writef32(buffer_object, cursor, value.X)
		buffer.writef32(buffer_object, cursor + 4, value.Y)
		buffer.writef32(buffer_object, cursor + 8, value.Z)
		cursor += 12
	end

	--[=[
		Writes a Vector2 to the buffer

		@param value Vector2
	]=]
	function SerializerFast.writeVector2(value: Vector2)
		realloc(8)
		buffer.writef32(buffer_object, cursor, value.X)
		buffer.writef32(buffer_object, cursor + 4, value.Y)
		cursor += 8
	end

	--[=[
		Writes a Color3 to the buffer

		@param value Color3
	]=]
	function SerializerFast.writeColor3(value: Color3)
		realloc(3)
		buffer.writeu8(buffer_object, cursor, value.R * 255)
		buffer.writeu8(buffer_object, cursor + 1, value.G * 255)
		buffer.writeu8(buffer_object, cursor + 2, value.B * 255)
		cursor += 3
	end

	--[=[
		Writes a string to the buffer
	
		@param value string
	]=]
	function SerializerFast.writeString(value: string)
		local len = #value
		WriteVlq(len)
		realloc(len)
		local b = buffer_object
		local p = cursor
		buffer.writestring(b, p, value)
		cursor += len
	end

	--[=[
		Writes a CFrame to the buffer

		@param value CFrame
	]=]
	function SerializerFast.writeCFrame(value: CFrame)
		realloc(18)
		local b = buffer_object
		local p = cursor
		local pos = value.Position
		local axis,t = value:ToAxisAngle()
        axis*=math.sin(t/2)

		cursor = p + 18

		buffer.writef32(b, p, pos.X)
		buffer.writef32(b, p + 4, pos.Y)
		buffer.writef32(b, p + 8, pos.Z)

		buffer.writei16(b, p + 12, (axis.X ) * 32767)
		buffer.writei16(b, p + 14, (axis.Y ) * 32767)
		buffer.writei16(b, p + 16, (axis.Z ) * 32767)
	end

	--[=[
		Writes a buffer to the buffer

		@param value buffer
		@param start number? -- The start index of the buffer use 0 if not provided
		@param finish number? -- The end index of the buffer use len(buffer) if not provided
	]=]
	function SerializerFast.writeBuffer(value: buffer, start: number?, finish: number?)
		local target = finish or buffer.len(value)
		local init = start or 0

		local len = target - init

		WriteVlq(len)
		realloc(len)
		local b = buffer_object
		local p = cursor

		bufferCopy(b, p, value, init, len)
		cursor = p + len
	end

	--[=[
		Writes a buffer to the buffer without the length

		@param value buffer
		@param start number? -- The start index of the buffer use 0 if not provided
		@param finish number? -- The end index of the buffer use len(buffer) if not provided
	]=]
	function SerializerFast.writeBufferRaw(value: buffer, start: number?, finish: number?)
		local target = finish or buffer.len(value)
		local init = start or 0

		local len = target - init
		realloc(len)
		local b = buffer_object
		local p = cursor
		cursor = p + len
		bufferCopy(b, p, value, init, len)
	end

	--[=[
		Writes an option to the buffer
		@param option option
		@param value any
		@param ... any -- Additional arguments for the writer 
	]=]
	function SerializerFast.writeOption(option: option, value: any, ...: any)
		local writer = getWriterFrom(option)
		if not writer then
			error("Invalid option | must be a valid enum or custom type")
		end
		writer(value, ...)
	end

	--[=[
		Writes a boolean to the buffer
		
		@param value boolean
	]=]
	function SerializerFast.writeBool(value: boolean)
		realloc(1)
		local b = buffer_object
		local p = cursor
		cursor = p + 1
		buffer.writeu8(b, p, value and 1 or 0)
	end

	--[=[
		Writes an any to the buffer

		@param value SerializerAny
	]=]
	function SerializerFast.writeAny( value: SerializerAny)
		local idx = typeToEnum[customType(value)]

		realloc(1) 
		local b = buffer_object
		local p = cursor
		cursor = p + 1
		buffer.writeu8(b, p, idx or 254)

		local writer = iWriter[idx]
		if writer then
			writer(value)
		elseif not idx then
			warn("Invalid type for writeAny: " .. customType(value))
		end
	end

	--[=[
		Checks if the buffer can hold the bytes and reallocates if needed
		@type function
		@param bytes number -- The number of bytes to check
	]=]
	SerializerFast.tryRealloc = realloc
end

local function readVector3(b: buffer, index: number): (Vector3, number)
	local x = buffer.readf32(b, index)
	local y = buffer.readf32(b, index + 4)
	local z = buffer.readf32(b, index + 8)
	return Vector3.new(x, y, z), index + 12
end

local function readVector2(b: buffer, index: number): (Vector2, number)
	local x = buffer.readf32(b, index)
	local y = buffer.readf32(b, index + 4)
	return Vector2.new(x, y), index + 8
end

local function readColor3(b: buffer, index: number): (Color3, number)
	local r = buffer.readu8(b, index) / 255
	local g = buffer.readu8(b, index + 1) / 255
	local bValue = buffer.readu8(b, index + 2) / 255
	return Color3.new(r, g, bValue), index + 3
end




local function readString(b: buffer, index: number): (string, number)
	local len, newIndex = ReadVlqRaw(b, index)

	local str = buffer.readstring(b, newIndex, len)
	return str, newIndex + len
end


local function readCFrame(b: buffer, index: number): (CFrame, number)
	local x, y, z = buffer.readf32(b, index), buffer.readf32(b, index + 4), buffer.readf32(b, index + 8)
	local axisX =buffer.readi16(b, index+12) /32767
	local axisY =buffer.readi16(b, index+14) /32767
	local axisZ =buffer.readi16(b, index+16) /32767
	local w = math.sqrt(1 - axisX^2 - axisY^2 - axisZ^2)
	
	return CFrame.new(x, y, z, axisX, axisY, axisZ, w), index + 18
end


local function readBuffer(b: buffer, index: number): (buffer, number)
	local len, newIndex = ReadVlqRaw(b, index)

	local newBuffer = buffer.create(len)
	bufferCopy(newBuffer, 0, b, newIndex, len)
	return newBuffer, newIndex + len
end

------------------------------------------------------------------------------------------
do


	--[=[
		Reads a u8 from the buffer 

		@return number
	]=]
	function SerializerFast.readu8(): number
		local value = buffer.readu8(buffer_object, cursor)
		cursor += 1
		return value
	end

	--[=[
		Reads a u16 from the buffer 

		@return number
	]=]
	function SerializerFast.readu16(): number
		local value = buffer.readu16(buffer_object, cursor)
		cursor += 2
		return value
	end

	--[=[
		Reads a u24 from the buffer 

		@return number
	]=]
	function SerializerFast.readu24(): number
		local value = readu24(buffer_object, cursor)
		cursor += 3
		return value
	end

	--[=[
		Reads a u32 from the buffer 

		@return number
	]=]
	function SerializerFast.readu32(): number
		local value = buffer.readu32(buffer_object, cursor)
		cursor += 4
		return value
	end

	--[=[
		Reads a vlq from the buffer. MAXIMUM VALUE IS 2^32-2

		@return number
	]=]
	function SerializerFast.readuInt(): number
		return ReadVlq()
	end

	--[=[
		Reads a i8 from the buffer 

		@return number
	]=]
	function SerializerFast.readi8(): number
		local value = buffer.readi8(buffer_object, cursor)
		cursor += 1
		return value
	end

	--[=[
		Reads a i16 from the buffer 

		@return number
	]=]
	function SerializerFast.readi16(): number
		local value = buffer.readi16(buffer_object, cursor)
		cursor += 2
		return value
	end


	--[=[
		Reads a i24 from the buffer 

		@return number
	]=]
	function SerializerFast.readi24(): number
		local value = readi24(buffer_object, cursor)
		cursor += 3
		return value
	end

	--[=[
		Reads a i32 from the buffer 

		@return number
	]=]
	function SerializerFast.readi32(): number
		local value = buffer.readi32(buffer_object, cursor)
		cursor += 4
		return value
	end


	--[=[
		Reads a f32 from the buffer 

		@return number
	]=]
	function SerializerFast.readf32(): number
		local value = buffer.readf32(buffer_object, cursor)
		cursor += 4
		return value
	end

	--[=[
		Reads a f64 from the buffer 

		@return number
	]=]
	function SerializerFast.readf64(): number
		local value = buffer.readf64(buffer_object, cursor)
		cursor += 8
		return value
	end

	--[=[
		Reads a Vector3 from the buffer 

		@return Vector3
	]=]
	function SerializerFast.readVector3(): Vector3
		local v, index = readVector3(buffer_object, cursor)
		cursor = index
		return v
	end

	--[=[
		Reads a Vector2 from the buffer 

		@return Vector2
	]=]
	function SerializerFast.readVector2(): Vector2
		local v, index = readVector2(buffer_object, cursor)
		cursor = index
		return v
	end

	--[=[
		Reads a string from the buffer 

		@return string
	]=]
	function SerializerFast.readString(): string
		local value, index = readString(buffer_object, cursor)
		cursor = index
		return value
	end

	--[=[
		Reads a CFrame from the buffer 

		@return CFrame
	]=]
	function SerializerFast.readCFrame(): CFrame
		local value, index = readCFrame(buffer_object, cursor)
		cursor = index
		return value
	end

	--[=[
		Read an option from the buffer 
		@param option option
		@return any
	]=]
	function SerializerFast.readOption(option: option, ...: any): any
		local reader = getReaderFrom(option)
		if not reader then
			error("Invalid option | must be a valid enum or custom type")
		end
		return reader(...)
	end

	--[=[
		Reads a buffer from the buffer 
		@return buffer
	]=]
	function SerializerFast.readBuffer(): buffer
		local value, index = readBuffer(buffer_object, cursor)
		cursor = index
		return value
	end

	--[=[
		Reads a bool

		@return boolean
	]=]
	function SerializerFast.readBool(): boolean
		local value = buffer.readu8(buffer_object, cursor) == 1
		cursor += 1
		return value
	end

	--[=[
		Reads an any from the buffer
		@return SerializerAny
	]=]
	function SerializerFast.readAny(): SerializerAny
		local idx = buffer.readu8(buffer_object, cursor)
		cursor += 1
		local reader = iReader[idx]
		if reader then
			return reader() 
		end
		return nil
	end

	--[=[
		Reads color3 from the buffer

		@return Color3
	]=]
	function SerializerFast.readColor3(): Color3
		local value, index = readColor3(buffer_object, cursor)
		cursor = index
		return value
	end
	--[=[
		Check if buffer is out of bounds or next element is contains 0.
		If the next element is 0, it increments the cursor by 1

		@return boolean -- If the buffer is out of bounds or the next element is 0
	]=] 
	function SerializerFast.isNull(): boolean
		if cursor >= buffer.len(buffer_object) then
			return true
		end
		if buffer.readu8(buffer_object, cursor) == 0 then
			cursor += 1
			return true
		end
		return false
	end
end

for k: string, f in SerializerFast :: any do
	if not k:find("write") then
		continue
	end
	local name = k:gsub("write", ""):upper()
	local str = NameLookUp[name]
	if not str then
		continue
	end
	iWriter[str] = f
end
for k: string, f in SerializerFast :: any do
	if not k:find("read") then
		continue
	end
	local name = k:gsub("read", ""):upper()
	local str = NameLookUp[name]
	if not str then
		continue
	end
	iReader[str] = f
end



return table.freeze(SerializerFast)
