local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ClassSystem = require(ReplicatedStorage.Library)
local People = ClassSystem.Create("People")

function People:constructor(name, age)
	self.Name = name
	self.Age = age
end

function People:Say()
	print(`{self.Name} {self.Age}`)
end

return People