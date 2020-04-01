--修饰器生效代表身上没旗
flag_status = flag_status or class({})

function flag_status:OnCreated(keys)
	self.flag_model = keys.flag_model
end

function flag_status:IsHidden() 			return true end
function flag_status:Isbuff() 				return false end
function flag_status:IsPurgable() 			return false end
