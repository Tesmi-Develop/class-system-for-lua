local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ClassSystem = require(ReplicatedStorage["Class-system"])

type Interface = {
    lock: (self: LockType) -> (),
    unlock: (self: LockType) -> ()
}

type Props = {
    locked: boolean,
    __event: BindableEvent
}

export type LockType = ClassSystem.Class<Interface, Props>

local MyClass = ClassSystem.Create("MyClass")

function MyClass:constructor(a: string, b: string)
	self.A = a
	self.B = b
	self.C = "Hi"
end
