local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ClassSystem = require(ReplicatedStorage.Library)

local MyClass = ClassSystem.Create("MyClass") 

function MyClass:constructor(a, b)
	self.A = a
	self.B = b
end

local MyClass2 = ClassSystem.Create("MyClass2"):extends(MyClass)

function MyClass2:constructor(c, a, b)
	self.C = c
end

--[[local MyClass = ClassSystem.Create("MyClass") 

function MyClass:constructor(a, b)
	self.A = a
	self.B = b

	ClassSystem.TrackingInstanceController:Get(self).OnChanged:Connect(function(fieldName, newValue, oldValue)
		print(fieldName, oldValue, newValue)
	end)
end

local instance = MyClass.new(5, 5)
instance.B = 10]]--

--[[local MyClass = ClassSystem.Create("MyClass")

function MyClass:constructor(a, b)
	self.A = a
	self.B = b
end

function MyClass:Print()
	print(self.A, self.B)
end

local instance = MyClass.new(5, 5)
local serializedInstance = ClassSystem.Serialize(instance) -- Сериализуем экземпляр instance
local instance2 = ClassSystem.Deserialize(serializedInstance) -- Десериализуем экземпляр instance
instance2:Print() -- 5, 5
]]--