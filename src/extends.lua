local LuauClass = require(script.Parent)

type AccountImpl = {
	deposit: (self: Account, credit: number) -> (),
	withdraw: (self: Account, debit: number) -> (),
}

type Props = { name: string, balance: number }
type Account = Props & AccountImpl

local Account = LuauClass.Create("Lock") :: LuauClass.Class<AccountImpl, Props, { Players: {Player} }, string, number>

function Account:constructor(name, balance)
	self.name = name
	self.balance = balance
end

function Account:deposit(credit)
	self.balance += credit
end


function Account:withdraw(debit)
	self.balance -= debit
end

local ExtendAccount = LuauClass.Create("Lock") :: LuauClass.ExtendedClass<typeof(Account), {}, {}, {}>

function ExtendAccount:constructor(name, balance)
	self:super(name, balance)
	self.name = name
	self.balance = balance
end

return ExtendAccount