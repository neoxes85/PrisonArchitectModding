local timeTot = 0
local myManager = {}

function Create()
	this.icMinSec = false
	this.icNormal = false
	this.icMaxSec = false
	this.icProtected = false
	this.icDeathRow = false
	this.ReceptionIntake = false
end

function Update(elapsedTime)
	if timePerUpdate == nil then
		timePerUpdate = 1439 + math.random()
		if this.Pos.y < 9.5 then this.Pos.y = 9.5 end
		CheckMyManager()
		myManager.newScan = true
		InterfaceUpdate(true)
	end
	timeTot = timeTot + elapsedTime
	if timeTot >= timePerUpdate then
		timeTot = 0
	end
end

function InterfaceUpdate(firstCall)
	if firstCall then
		this.AddInterfaceComponent("Divider1","Caption","tooltip_Divider")
		this.AddInterfaceComponent("IntakeCategories","Caption","tooltip_IntakeCategories")		
		this.AddInterfaceComponent("MinSecCat","Button","tooltip_MinSecCat","tooltip_"..tostring(this.icMinSec),"X")
		this.AddInterfaceComponent("NormalCat","Button","tooltip_NormalCat","tooltip_"..tostring(this.icNormal),"X")
		this.AddInterfaceComponent("MaxSecCat","Button","tooltip_MaxSecCat","tooltip_"..tostring(this.icMaxSec),"X")
		this.AddInterfaceComponent("ProtectedCat","Button","tooltip_ProtectedCat","tooltip_"..tostring(this.icProtected),"X")
		this.AddInterfaceComponent("DeathRowCat","Button","tooltip_DeathRowCat","tooltip_"..tostring(this.icDeathRow),"X")
		this.AddInterfaceComponent("Divider2","Caption","tooltip_Divider")
		this.AddInterfaceComponent("ReceptionIntake","Button","tooltip_ReceptionIntake","tooltip_"..tostring(this.ReceptionIntake),"X")
	else
		this.SetInterfaceCaption("MinSecCat","tooltip_MinSecCat","tooltip_"..tostring(this.icMinSec),"X")
		this.SetInterfaceCaption("NormalCat","tooltip_NormalCat","tooltip_"..tostring(this.icNormal),"X")
		this.SetInterfaceCaption("MaxSecCat","tooltip_MaxSecCat","tooltip_"..tostring(this.icMaxSec),"X")
		this.SetInterfaceCaption("ProtectedCat","tooltip_ProtectedCat","tooltip_"..tostring(this.icProtected),"X")
		this.SetInterfaceCaption("DeathRowCat","tooltip_DeathRowCat","tooltip_"..tostring(this.icDeathRow),"X")
		this.SetInterfaceCaption("ReceptionIntake","tooltip_ReceptionIntake","tooltip_"..tostring(this.ReceptionIntake),"X")
	end
	this.inUse = false
end

function MinSecCatClicked()
	if this.inUse then
	else
		this.inUse = true
		this.icMinSec = not this.icMinSec
		InterfaceUpdate(false)
	end
end

function NormalCatClicked()
	if this.inUse then
	else
		this.inUse = true
		this.icNormal = not this.icNormal
		InterfaceUpdate(false)
	end
end

function MaxSecCatClicked()
	if this.inUse then
	else
		this.inUse = true
		this.icMaxSec = not this.icMaxSec
		InterfaceUpdate(false)
	end
end

function ProtectedCatClicked()
	if this.inUse then
	else
		this.inUse = true
		this.icProtected = not this.icProtected
		InterfaceUpdate(false)
	end
end

function DeathRowCatClicked()
	if this.inUse then
	else
		this.inUse = true
		this.icDeathRow = not this.icDeathRow
		InterfaceUpdate(false)
	end
end

function ReceptionIntakeClicked()
	if this.inUse then
	else
		this.inUse = true
		this.ReceptionIntake = not this.ReceptionIntake
		InterfaceUpdate(false)
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