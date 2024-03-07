local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ClassSystem = require(ReplicatedStorage.Library)
local People = require(ReplicatedStorage.Shared.People)

local B = ClassSystem.Create("B"):extends(People)

function B:constructor(...)
	self:super(...)
	self.NewData = "123"
end

return B