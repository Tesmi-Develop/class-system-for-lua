local TrackedInstance = require(script.TrackedInstance)
local TrackingInstanceController = require(script.TrackingInstanceController)
local metadatas = {}
local classesByMetadata = {}

type OptionsWithoutIsAbstract = {
	isTrackedClass: boolean | nil;
}

type Options = {
	isAbstract: boolean | nil;
} & OptionsWithoutIsAbstract

export type Seriliazed<T> = {
	data: T;
	metadata: string;
}

export type Class<Methods, Implementation, StaticProps, InitArguments...> = {
	constructor: (self: Implementation & Methods, InitArguments...) -> (),
	new: (InitArguments...) -> Implementation & Methods,
} & Methods & StaticProps;

export type ExtendedClass<Superior, Methods, Implementation, StaticProps, InitArguments...> = 
Class<Methods, Implementation & {super: Superior}, StaticProps, InitArguments...>

local GlobalTemplateSettings = {
	IsEnableTracking = false;
}

local GlobalSettings = table.clone(GlobalTemplateSettings)

local function validateSettings(settings)
	for key, value in GlobalTemplateSettings do
		local valueType = typeof(value)

		if typeof(settings[key]) ~= valueType then
			error(`Invalid global settings: ${key}, "expected:", ${valueType}, "actual:", ${typeof(settings[key])}`)
		end
	end
end

local function SetGlobalSettings(settings: typeof(GlobalSettings))
	validateSettings(settings)
	GlobalSettings = table.clone(settings)
end

local function GetGlobalSettings()
	return table.clone(GlobalSettings)
end

local function Create(name: string, options: Options?)
	options = options or {}
	local isAbstract = options.isAbstract or false
	local isTrackedClass = options.isTrackedClass or GlobalSettings.IsEnableTracking

	assert(typeof(name) == "string", "Invalid name")

	local file = getfenv(0).script :: Instance
	local metadata = `{file:GetFullName()}@{name}`

	assert(metadatas[metadata] == nil, "This class with the same metadata exists")

	local newClass = setmetatable({}, {
		__tostring = function()
			return name
		end,

		__call = function(t, ...)
			return t.constructor(...)
		end,

		__index = function(t, index)
			assert(index ~= "new", "Abstract class cannot create instances")
			if t.super then
				return t.super[index]
			end
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

			return rawget(newClass, "constructor")(self, ...) or self
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

	function newClass.extends(parent)
		assert(parent ~= newClass, "Cannot inherit from self")
		assert(rawget(newClass, "super") == nil, "Attempt to inherit a class twice")
		newClass.super = parent

		return newClass
	end

	function newClass:constructor(...)
		if newClass.super then
			newClass.super(self, ...)
		end
	end

	return newClass
end

local function CreateAbstract(name: string, options: OptionsWithoutIsAbstract?)
	options = options or {}
	options.isAbstract = true
	return Create(name, options)
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

local function Serialize<T>(instance: T): Seriliazed<T>
	local data = if instance['__TableLink'] ~= nil then table.clone(instance['__TableLink']) else table.clone(instance);
	setmetatable(data, nil);

	return {
		data = data;
		metadata = getMetadata(instance.constructor);
	}
end

local function Deserialize<T>(serialized: Seriliazed<T>): T
	local class = getClassByMetadata(serialized.metadata);
	assert(class ~= nil, "Class not found");
	assert(class.new ~= nil, "Class is abstract");

	return class._fromData(serialized.data);
end

-- API
return {
	SetGlobalSettings = SetGlobalSettings;
	GetGlobalSettings = GetGlobalSettings;

	Create = Create;
	CreateAbstract = CreateAbstract;

	instanceof = instanceof;
	GetMetadata = getMetadata;
	GetClassByMetadata = getClassByMetadata;
	GetCopyMetadatas = getCopyMetadatas;
	Serialize = Serialize;
	Deserialize = Deserialize;
	TrackedInstance = TrackedInstance;
	TrackingInstanceController = TrackingInstanceController;
}
