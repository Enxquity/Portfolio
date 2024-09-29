local UserInputService = game:GetService("UserInputService")
local Input = {}

function Input:CreateInput(Keys, StartFunction, EndFunction)
	UserInputService.InputBegan:Connect(function(Input, IsTyping)
		if IsTyping then return end
		
		for Index, Key in pairs(Keys) do
			if Input.KeyCode == Key or Input.UserInputType == Key then
				pcall(StartFunction)
				if EndFunction then
					repeat 
						task.wait()
					until not UserInputService:IsKeyDown(Key)
					pcall(EndFunction)
				end
				return
			end
		end
	end)
end

return Input