local timeTot = 0
local newSubType = 0
local objVariants = {
	[1] = {
		["Name"] = "object_SmallRoadGate",
		["SubType"] = 0,
	},
	[2] = {
		["Name"] = "object_SmallRoadGateNoSensor",
		["SubType"] = 1
	},
	[3] = {
		["Name"] = "object_SmallRoadBarrier",
		["SubType"] = 2
	},
	[4] = {
		["Name"] = "object_SmallRoadBarrierWall",
		["SubType"] = 3
	}
}
local entities = {"Workman","Janitor","Gardener","Sniper","Cook"}
local myManager = {}
local myGuardPost = {}

function Create()
end

function Update(elapsedTime)
	if timePerUpdate == nil then
		timePerUpdate = 5 + math.random()
		if this.Or.x == 1 or this.Or.x == -1 then
			this.Pos.x = this.Pos.x + 1.5
			this.Pos.y = this.Pos.y - 1.5
			this.Or.y = -this.Or.x
			this.Or.x = 0
			this.OpenDir.x = this.OpenDir.y
			this.OpenDir.y = 0
		end
		if this.Pos.y < 5.5 then this.Pos.y = 5.5 end
		if this.myGuardPostUID then
		else
			myGuardPost = Object.Spawn("SmallRoadGuardPost", this.Pos.x, this.Pos.y - 0.5)
			myGuardPost.SubType = this.SubType
			myGuardPost.Or.x = this.Or.x
			myGuardPost.Or.y = this.Or.y
			this.myGuardPostUID = myGuardPost.Id.u			
		end
		CheckMyManager()
		myManager.newScan = true		
		InterfaceUpdate(true)
	end
	timeTot = timeTot + elapsedTime
	if timeTot >= timePerUpdate then
		timeTot = 0
		if this.Mode == "Normal" and this.CloseTimer == 0 then
			for _, typ in pairs(entities) do
				local people = Object.GetNearbyObjects(typ, 1)
				if next(people) then
					for entity, _ in pairs(people) do
						if next(entity) then this.Open = 0.0000001 end
					end
				end
				people = nil
			end
		end
	end
end

function InterfaceUpdate(firstCall)
	if firstCall then
		this.AddInterfaceComponent("Divider1","Caption","tooltip_Divider")
		this.AddInterfaceComponent("ObjectVariants","Caption","tooltip_ObjectVariants")
		this.AddInterfaceComponent("CurrentVariant","Caption","tooltip_CurrentVariant",objVariants[this.SubType + 1].Name,"X")
		for i, obj in ipairs(objVariants) do
			this.AddInterfaceComponent("Variant"..i,"Button",obj.Name)
		end
		this.AddInterfaceComponent("Divider2","Caption","tooltip_Divider")
		this.AddInterfaceComponent("AddRoadGuardPost","Button","tooltip_AddRoadGuardPost")
	else
		this.SetInterfaceCaption("CurrentVariant","tooltip_CurrentVariant",objVariants[this.SubType + 1].Name,"X")
	end
	this.inUse = false
end

function Variant1Clicked()
	if not this.inUse and this.SubType ~= 0 then
		this.inUse = true
		newSubType = 0
		this.CreateJob("InstallObjectVariant")
	end
end

function Variant2Clicked()
	if not this.inUse and this.SubType ~= 1 then
		this.inUse = true
		newSubType = 1
		this.CreateJob("InstallObjectVariant")
	end
end

function Variant3Clicked()
	if not this.inUse and this.SubType ~= 2 then
		this.inUse = true
		newSubType = 2
		this.CreateJob("InstallObjectVariant")
	end
end

function Variant4Clicked()
	if not this.inUse and this.SubType ~= 3 then
		this.inUse = true
		newSubType = 3
		this.CreateJob("InstallObjectVariant")
	end
end

function JobComplete_InstallObjectVariant()
	this.SubType = newSubType
	CheckMyGuardPost()
	if this.myGuardPostUID ~= -1 then myGuardPost.SubType = newSubType end
	InterfaceUpdate(false)
end

function AddRoadGuardPostClicked()
	if this.inUse then
	else
		this.inUse = true
		CheckMyGuardPost()
		if this.myGuardPostUID == -1 then
			myGuardPost = Object.Spawn("SmallRoadGuardPost", this.Pos.x, this.Pos.y - 0.5)
			myGuardPost.SubType = this.SubType
			myGuardPost.Or.x = this.Or.x
			myGuardPost.Or.y = this.Or.y
			this.myGuardPostUID = myGuardPost.Id.u	
		end
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

function CheckMyGuardPost()
	myGuardPost = {}
	local guardposts = Object.GetNearbyObjects("SmallRoadGuardPost",0.5)
	for thatGuardPost, distance in pairs(guardposts) do
		if thatGuardPost.Id.u == this.myGuardPostUID then
			myGuardPost = thatGuardPost
		end
	end
	if next(myGuardPost) then
	else
		this.myGuardPostUID = -1
	end
	guardposts = nil
end