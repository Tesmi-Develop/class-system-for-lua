local ReplicatedStorage = game:GetService("ReplicatedStorage")
local People = require(ReplicatedStorage.Shared.People)
local BClass = require(ReplicatedStorage.Shared.B)
local ClassSystem = require(ReplicatedStorage.Library)

local instance = People.new("Bob", 29);
instance:Say();

local ser = ClassSystem.Serialize(instance);
local des = ClassSystem.Deserialize(ser)
des:Say();

local B = BClass.new("Da", 10)
print(B)