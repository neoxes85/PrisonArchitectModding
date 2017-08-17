local timeTot = 0

function Create()
end

function Update(elapsedTime)
	if timePerUpdate == nil then
		timePerUpdate = 0
	end
	timeTot = timeTot + elapsedTime
	if timeTot >= timePerUpdate then
		timeTot = 0
		local obj = Object.Spawn("SmallRoadGate", this.Pos.x, this.Pos.y)
		obj.SubType = 2
		obj.Or.x = this.Or.x
		obj.Or.y = this.Or.y
		obj.OpenDir.x = this.OpenDir.x 
		obj.OpenDir.y = this.OpenDir.y
		this.Delete()
	end	  
end