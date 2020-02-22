function Timer(delay, callback)
	if callback == nil then
		callback = delay
		delay = 0 
	end
	GameRules:GetGameModeEntity():SetContextThink(DoUniqueString('timer'), function()
		return callback() 
	end, delay)
end


--[[哪里调用写在哪
fuction 调用的类名：xx函数（）
.
.
.
.
.
Timer(function()
	self.OnTimer()
	return x --@x:计时间隔
end)
.
.
.
.
.
.
end



--具体定义ontimer，
function 调用的类名：Ontimer（）

每次计时间隔做什么事情

end
]]