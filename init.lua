local metadatas = {}
local classesByMetadata = {}

local function Create(name: string, isAbstract: boolean?)
	isAbstract = isAbstract or false
	assert(typeof(name) == "string", "Invalid name")
	
	local file = getfenv(0).script :: Instance
	local metadata = `{file:GetFullName()}@{name}`
	
	assert(metadatas[metadata] == nil, "This class with the same metadata exists")
	
	local newClass = setmetatable({}, {
		__tostring = function()
			return name
		end,
		
		__index = function(class, index)
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
			})
			
			return self:__constructor(...) or self
		end
	end
	
	function newClass:extends(parent)
		assert(self == newClass, "This method is available only from class")
		assert(rawget(newClass, "super") == nil, "Attempt to inherit a class twice")
		
		local mt = getmetatable(newClass)
		newClass.super = parent
			
		local originalIndexCallback = mt.__index
		mt.__index = function(class, index)
			originalIndexCallback(class, index)
			
			return parent[index]
		end
		
		return newClass
	end
	
	function newClass:__constructor(...)
		if newClass.super then
			newClass.super.__constructor(self, ...)
		end
		
		return newClass.constructor(self, ...)
	end
	
	function newClass:constructor()
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

-- API
return {
	Create = Create;
	instanceof = instanceof;
	GetMetadata = getMetadata;
	GetClassByMetadata = getClassByMetadata;
	GetCopyMetadatas = getCopyMetadatas;
}
