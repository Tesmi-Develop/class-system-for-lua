local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Signal = require(ReplicatedStorage.Packages.signal)

local CreateGeneratorId = function(isString)
	if isString == nil then
		isString = true
	end
	local obj
	obj = {
		freeId = 0,
		Next = function()
			local id = obj.freeId
			obj.freeId += 1
			return if isString then tostring(id) else id
		end,
	}
	return obj
end

local TrackingInstanceController
do
	TrackingInstanceController = setmetatable({}, {
		__tostring = function()
			return "TrackingInstanceController"
		end,
	})
	TrackingInstanceController.__index = TrackingInstanceController
	function TrackingInstanceController.new(...)
		local self = setmetatable({}, TrackingInstanceController)
		return self:constructor(...) or self
	end
	function TrackingInstanceController:constructor(trackedInstance)
		self.trackedInstance = trackedInstance
		self.OnAdded = Signal.new()
		self.OnChanged = Signal.new()
		self.OnRemoved = Signal.new()
		self.validators = {}
		self.decorators = {}
	end
	function TrackingInstanceController:Get(instance)
		local _trackedInstances = TrackingInstanceController.trackedInstances
		if _trackedInstances[instance] ~= nil then
			local _trackedInstances_1 = TrackingInstanceController.trackedInstances
			return _trackedInstances_1[instance]
		end

		local data = TrackingInstanceController.new(instance)
		local _trackedInstances_1 = TrackingInstanceController.trackedInstances
		_trackedInstances_1[instance] = data

		return data
	end
	function TrackingInstanceController:Has(instance)
		local _trackedInstances = TrackingInstanceController.trackedInstances
		return _trackedInstances[instance] ~= nil
	end
	function TrackingInstanceController:Create(instance)
		local _trackedInstances = TrackingInstanceController.trackedInstances

		if _trackedInstances[instance] ~= nil then
			local _trackedInstances_1 = TrackingInstanceController.trackedInstances
			return _trackedInstances_1[instance]
		end
		local data = TrackingInstanceController.new(instance)
		local _trackedInstances_1 = TrackingInstanceController.trackedInstances
		_trackedInstances_1[instance] = data

		return data
	end
	function TrackingInstanceController:GetValidators()
		return self.validators
	end
	function TrackingInstanceController:GetDecorators()
		return self.decorators
	end
	function TrackingInstanceController:Destroy()
		local _trackedInstances = TrackingInstanceController.trackedInstances
		local _trackedInstance = self.trackedInstance
		_trackedInstances[_trackedInstance] = nil
		setmetatable(self, nil)
	end
	function TrackingInstanceController:SetValidator(fieldName, validator)
		self.validators[fieldName] = validator
	end
	function TrackingInstanceController:RemoveValidator(fieldName)
		self.validators[fieldName] = nil
	end
	function TrackingInstanceController:AddDecorator(decorator)
		local newId = TrackingInstanceController.idGenerator.Next()
		self.decorators[newId] = decorator

		return newId
	end
	function TrackingInstanceController:RemoveDecorator(id)
		self.decorators[id] = nil
	end
	function TrackingInstanceController:RemoveDecorators()
		table.clear(self.decorators)
	end
	TrackingInstanceController.trackedInstances = {}
	TrackingInstanceController.idGenerator = CreateGeneratorId()
end
return TrackingInstanceController
