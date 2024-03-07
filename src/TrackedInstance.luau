local TrackingInstanceController = require(script.Parent.TrackingInstanceController)
local TableLink = "__TableLink"

local function TrackedInstance(instance)
	local clone = table.clone(instance)
	local originalMetatable = getmetatable(instance)
	table.clear(instance)

	local mt = {
		__index = function(t, index)
			return clone[index]
		end,
		__newindex = function(t, index, value)
			local oldValue = clone[index]
			local data = TrackingInstanceController:Get(instance)
			if not data then
				clone[index] = value
			end
			if not data then
				return nil
			end
			local _exp = data:GetValidators()
			local _index = index
			if _exp[_index] ~= nil then
				local _exp_1 = data:GetValidators()
				local _index_1 = index
				if not _exp_1[_index_1](value, index) then
					return nil
				end
				clone[index] = value
			else
				clone[index] = value
			end
			if oldValue == nil and value ~= nil then
				data.OnAdded:Fire(index, value)
			end
			if oldValue ~= value then
				data.OnChanged:Fire(index, value, oldValue)
			end
			if oldValue ~= nil and value == nil then
				data.OnRemoved:Fire(index, oldValue)
			end
		end,
		__iter = function()
			return next, clone
		end,
		__metatable = originalMetatable,
	}

	instance[TableLink] = clone
	setmetatable(instance, mt)

	return instance
end

return TrackedInstance
