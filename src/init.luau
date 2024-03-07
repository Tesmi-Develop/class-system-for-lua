local TrackedInstance = require(script.TrackedInstance)
local TrackingInstanceController = require(script.TrackingInstanceController)
local types = require(script.types);
local metadatas = {}
local classesByMetadata = {}

type Options = {
	isAbstract: boolean | nil;
	isTrackedClass: boolean | nil;
}

local validateLabel = "__validateLabel"

local function Create(name: string, options: Options?)
	options = options or {}
	local isAbstract = options.isAbstract or false
	local isTrackedClass = options.isTrackedClass or true

	assert(typeof(name) == "string", "Invalid name")

	local file = getfenv(0).script :: Instance
	local metadata = `{file:GetFullName()}@{name}`

	assert(metadatas[metadata] == nil, "This class with the same metadata exists")

	local newClass = setmetatable({}, {
		__tostring = function()
			return name
		end,

		__index = function(_, index)
			assert(index ~= "new", "Abstract class cannot create instances")
		end,
	})

	metadatas[newClass] = metadata
	classesByMetadata[metadata] = newClass

	if not isAbstract then
		function newClass.new(...)
			local self = setmetatable({}, {
				__index = function(_, index)
					assert(index ~= "new", "Attempting to use new from instance")
					if index == "constructor" then
						return newClass
					end

					return newClass[index]
				end,
			});

			if isTrackedClass then 
				TrackedInstance(self)
			end

			return self:__constructor(false, ...) or self
		end

		function newClass._fromData(data, ...)
			local self = setmetatable(data, {
				__index = function(_, index)
					assert(index ~= "new", "Attempting to use new from instance")
					if index == "constructor" then
						return newClass
					end

					return newClass[index]
				end,
			})

			return self
		end
	end

	local function CreateSuper(parent)
		return setmetatable({}, {
			__index = parent;
			__newindex = function (t, index, value)
				parent[index] = value
			end;
			__call = function (t, ...)
				local args = {...}
				parent.__constructor(args[1], true, table.unpack(args, 2))
			end;
			__tostring = function()
				return tostring(parent)
			end;
		})
	end

	function newClass:extends(parent)
		assert(self == newClass, "This method is available only from class")
		assert(rawget(newClass, "super") == nil, "Attempt to inherit a class twice")

		local mt = getmetatable(newClass)
		newClass.super = CreateSuper(parent)

		local originalIndexCallback = mt.__index
		mt.__index = function(class, index)
			originalIndexCallback(class, index)

			return parent[index]
		end

		return newClass
	end

	function newClass:__constructor(isSendValidateLabel: boolean, ...)
		newClass.constructor(self, ...)

		if newClass.super then
			assert(self[validateLabel], `{newClass} extends {newClass.super}, but the parent's constructor was not invoked`)
		end

		self[validateLabel] = nil

		if isSendValidateLabel then
			self[validateLabel] = true
		end
	end

	function newClass:constructor(...)
		if newClass.super then
			newClass.super.constructor(self, ...)
		end
	end

	return newClass
end

local function instanceof(obj, class)
	-- custom Class.instanceof() check
	if type(class) == "table" and type(class.instanceof) == "function" then
		return class.instanceof(obj)
	end

	if type(obj) == "table" then
		obj = obj.constructor
		while obj ~= nil do
			if obj == class then
				return true
			end

			if obj.super then
				obj = obj.super
				continue
			end

			break
		end
	end

	return false
end

local function getMetadata(obj)
	return metadatas[obj]
end

local function getCopyMetadatas()
	return table.clone(metadatas)
end

local function getClassByMetadata(metadata)
	return classesByMetadata[metadata]
end

local function Serialize<T>(instance: T): types.Seriliazed<T>
	local data = if instance['__TableLink'] ~= nil then table.clone(instance['__TableLink']) else table.clone(instance);
	setmetatable(data, nil);

	return {
		data = data;
		metadata = getMetadata(instance.constructor);
	}
end

local function Deserialize<T>(serialized: types.Seriliazed<T>): T
	local class = getClassByMetadata(serialized.metadata);
	assert(class ~= nil, "Class not found");
	assert(class.new ~= nil, "Class is abstract");

	return class._fromData(serialized.data);
end

-- API
return {
	Create = Create;
	instanceof = instanceof;
	GetMetadata = getMetadata;
	GetClassByMetadata = getClassByMetadata;
	GetCopyMetadatas = getCopyMetadatas;
	Serialize = Serialize;
	Deserialize = Deserialize;
	TrackedInstance = TrackedInstance;
	TrackingInstanceController = TrackingInstanceController;
}
