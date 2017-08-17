local timeTot = 0
local myManager = {}

function Create()
end

function Update(elapsedTime)
	if timePerUpdate == nil then
		timePerUpdate = 1439 + math.random()
		if this.Or.x == 1 or this.Or.x == -1 then
			this.Pos.x = this.Pos.x + 3
			this.Pos.y = this.Pos.y - 3
			this.Or.y = -this.Or.x
			this.Or.x = 0
			this.OpenDir.x = this.OpenDir.y
			this.OpenDir.y = 0
		end
		if this.Pos.y < 5.5 then this.Pos.y = 5.5 end
		CheckMyManager()
		myManager.newScan = true
	end
    timeTot = timeTot + elapsedTime
    if timeTot >= timePerUpdate then
        timeTot = 0
	end
end

function CheckMyManager()
	myManager = {}
	local x = World.NumCellsX
	local y = World.NumCellsY
	local d = math.ceil(math.sqrt(x^2 + y^2))
	local managers = Object.GetNearbyObjects("TrafficManager",d)
	if next(managers) then
		for thatManager, distance in pairs(managers) do
			myManager = thatManager
		end
	else
		myManager = Object.Spawn("TrafficManager",FindLeftRoadSide() + 0.5, 1.5)
	end	
	managers = nil
end

function FindLeftRoadSide()
	local endX = World.NumCellsX - 1
	for i = 0, endX do
		local cell = World.GetCell(i,0)
		if cell.Mat == "RoadMarkingsLeft" then
			return (i - 1)
		end
	end
	return 0
end