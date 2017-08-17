local timeTot = 0
local myManager = {}
local linkableGates = 20
local gatesLinks = "NoL1L2L3L4L5L6L7L8L9"

function Create()
	this.SubType = 1
	this.CargoTraffic = false
	this.IntakeTraffic = false
	this.EmergencyTraffic = false
	this.GarageTraffic = false	
	this.CargoMarkerID = 0
	this.IntakeMarkerID = 0
	this.EmergencyMarkerID = 0	
	this.GarageMarkerID = 0
	this.AutoGates = false
	this.linkableGates = linkableGates
	for i = 1, this.linkableGates do
		Object.SetProperty("LinkGate"..i,1)
	end
	this.TotalGates = 0
	this.TotalBusStops = 0
	this.TotalGarages = 0
end

function Update(elapsedTime)
	if timePerUpdate == nil then
		timePerUpdate = 9 + math.random()
		if this.Pos.y ~= 1 then
			this.Pos.y = 1
			local cellA = World.GetCell(this.Pos.x - 2,0)
			local cellB = World.GetCell(this.Pos.x - 1,0)
			local cellC = World.GetCell(this.Pos.x,0)
			local cellD = World.GetCell(this.Pos.x + 1,0)
			if cellA.Mat == "RoadMarkingsRight" or cellB.Mat == "RoadMarkings" or cellC.Mat == "RoadMarkingsLeft" then this.Pos.x = this.Pos.x + 1 end
			if cellB.Mat == "RoadMarkingsRight" or cellC.Mat == "RoadMarkings" or cellD.Mat == "RoadMarkingsLeft" then this.Pos.x = this.Pos.x - 1 end
			local roadMarkers = Object.GetNearbyObjects("RoadMarker",2)
			for theMarker, distance in pairs(roadMarkers) do
				if theMarker.Id.u ~= this.Id.u then	this.Delete() end
			end
			roadMarkers = nil
		end
		CheckMyManager()
		myManager.newScan = true
		InterfaceUpdate(true)
	end
    timeTot = timeTot + elapsedTime
    if timeTot >= timePerUpdate then
        timeTot = 0
		if this.Pos.y ~= 1 then	this.Pos.y = 1 end
		CheckMyManager()
	end
end

function InterfaceUpdate(firstCall)
	if firstCall then
		this.AddInterfaceComponent("Divider1","Caption","tooltip_Divider")		
		this.AddInterfaceComponent("ResetRoadMarker","Button","tooltip_ResetRoadMarker")
		this.AddInterfaceComponent("BuildNewLane","Button","tooltip_BuildNewLane")
		this.AddInterfaceComponent("BuildNewRoad","Button","tooltip_BuildNewRoad")
		this.AddInterfaceComponent("Divider2","Caption","tooltip_Divider")			
		this.AddInterfaceComponent("AllowedTraffic","Caption","tooltip_AllowedTraffic")
		this.AddInterfaceComponent("CargoTrafficX","Button","tooltip_CargoX","tooltip_"..tostring(this.CargoTraffic),"X")
		this.AddInterfaceComponent("IntakeTrafficX","Button","tooltip_IntakeX","tooltip_"..tostring(this.IntakeTraffic),"X")
		this.AddInterfaceComponent("EmergencyTrafficX","Button","tooltip_EmergencyX","tooltip_"..tostring(this.EmergencyTraffic),"X")
		this.AddInterfaceComponent("GarageTrafficX","Button","tooltip_GarageX","tooltip_"..tostring(this.GarageTraffic),"X")
		this.AddInterfaceComponent("Divider3","Caption","tooltip_Divider")
		this.AddInterfaceComponent("RoadGates","Caption","tooltip_RoadGates")
		this.AddInterfaceComponent("AutomaticGates","Button","tooltip_AutomaticGates","tooltip_"..tostring(this.AutoGates),"X")
		this.AddInterfaceComponent("SetGatesLinks","Button","tooltip_SetGatesLinks")
	else
		this.SetInterfaceCaption("CargoTrafficX","tooltip_CargoX","tooltip_"..tostring(this.CargoTraffic),"X")
		this.SetInterfaceCaption("IntakeTrafficX","tooltip_IntakeX","tooltip_"..tostring(this.IntakeTraffic),"X")
		this.SetInterfaceCaption("EmergencyTrafficX","tooltip_EmergencyX","tooltip_"..tostring(this.EmergencyTraffic),"X")
		this.SetInterfaceCaption("GarageTrafficX","tooltip_GarageX","tooltip_"..tostring(this.GarageTraffic),"X")
		this.SetInterfaceCaption("AutomaticGates","tooltip_AutomaticGates","tooltip_"..tostring(this.AutoGates),"X")
	end
	this.inUse = false
end

function ResetRoadMarkerClicked()
	if this.inUse then
	else
		this.inUse = true
		local newMarker = Object.Spawn("RoadMarker",this.Pos.x,this.Pos.y)
		this.Delete()
	end
end

function BuildNewLaneClicked() 
	if this.inUse then
	else
		this.inUse = true
		local nlL = false
		local nlR = false
		local nlCellA = World.GetCell(this.Pos.x - 4,0)
		local nlCellB = World.GetCell(this.Pos.x - 3,0)
		local nlCellC = World.GetCell(this.Pos.x + 2,0)
		local nlCellD = World.GetCell(this.Pos.x + 3,0)
		if (nlCellA.Mat == "RoadMarkingsLeft" or nlCellA.Mat == "Road") and (nlCellB.Mat == "Road" or nlCellB.Mat == "RoadMarkingsRight") then nlL = true end
		if (nlCellC.Mat == "Road" or nlCellC.Mat == "RoadMarkingsLeft") and (nlCellD.Mat == "RoadMarkingsRight" or nlCellD.Mat == "Road") then nlR = true end
		if nlL or nlR then
			this.SetInterfaceCaption("BuildNewLane","tooltip_BuildNewLane")
			BuildRoad(true,nlL,nlR,false,false)
			CheckMyManager()
			myManager.Pos.x = FindLeftRoadSide() + 0.5
		else
			this.SetInterfaceCaption("BuildNewLane","tooltip_CantBuildLane")
		end
		InterfaceUpdate(false)
	end
end

function BuildNewRoadClicked()
	if this.inUse then
	else
		this.inUse = true		
		local nrL = false
		local nrR = false
		local nrCellA = World.GetCell(this.Pos.x - 3,0)
		local nrCellB = World.GetCell(this.Pos.x + 2,0)
		if nrCellA.Mat == "Road" then nrL = true end
		if nrCellB.Mat == "Road" then nrR = true end
		BuildRoad(false,false,false,nrL,nrR)
		CheckMyManager()
		myManager.Pos.x = FindLeftRoadSide() + 0.5
		InterfaceUpdate(false)
	end
end

function CargoTrafficXClicked()
	if this.inUse then
	else
		this.inUse = true
		this.CargoTraffic = not this.CargoTraffic
		if this.CargoTraffic then
			if this.SubType == 9 then
				this.GarageTraffic = false
				this.SubType = 1
			end
			this.SubType = this.SubType + 1
		else
			this.SubType = this.SubType - 1
		end
		InterfaceUpdate(false)
	end
end
	
function IntakeTrafficXClicked()
	if this.inUse then
	else
		this.inUse = true
		this.IntakeTraffic = not this.IntakeTraffic
		if this.IntakeTraffic then
			if this.SubType == 9 then
				this.GarageTraffic = false
				this.SubType = 1
			end
			this.SubType = this.SubType + 2
		else
			this.SubType = this.SubType - 2
		end
		InterfaceUpdate(false)
	end
end

function EmergencyTrafficXClicked()
	if this.inUse then
	else
		this.inUse = true
		this.EmergencyTraffic = not this.EmergencyTraffic
		if this.EmergencyTraffic then
			if this.SubType == 9 then
				this.GarageTraffic = false
				this.SubType = 1
			end
			this.SubType = this.SubType + 4
		else
			this.SubType = this.SubType - 4
		end
		InterfaceUpdate(false)
	end
end

function GarageTrafficXClicked()
	if this.inUse then
	else
		this.inUse = true
		this.GarageTraffic = not this.GarageTraffic
		this.CargoTraffic = false
		this.IntakeTraffic = false
		this.EmergencyTraffic = false
		if this.GarageTraffic then
			this.SubType = 9
		else
			this.SubType = 1
		end
		InterfaceUpdate(false)
	end
end

function AutomaticGatesClicked()
	if this.inUse then
	else
		this.inUse = true
		this.AutoGates = not this.AutoGates
		InterfaceUpdate(false)
	end
end

function SetGatesLinksClicked()
	if this.inUse then
	else
		this.inUse = true
		for i=1,this.TotalGates do
			this.RemoveInterfaceComponent("LinkGate"..i,"Button","tooltip_LinkGate",i,"N",string.sub(gatesLinks,Object.GetProperty("LinkGate"..i),Object.GetProperty("LinkGate"..i) + 1),"L")
		end
		for i=1,this.TotalGates do
			this.AddInterfaceComponent("LinkGate"..i,"Button","tooltip_LinkGate",i,"N",string.sub(gatesLinks,Object.GetProperty("LinkGate"..i),Object.GetProperty("LinkGate"..i) + 1),"L")
		end
		InterfaceUpdate(false)
	end
end

function LinkGate1Clicked()
	if this.inUse then
	else
		this.inUse = true
		this.LinkGate1 = this.LinkGate1 + 2
		if this.LinkGate1 > string.len(gatesLinks) then this.LinkGate1 = 1 end
		this.SetInterfaceCaption("LinkGate1","tooltip_LinkGate",1,"N",string.sub(gatesLinks,this.LinkGate1,this.LinkGate1 + 1),"L")
		InterfaceUpdate(false)
	end
end

function LinkGate2Clicked()
	if this.inUse then
	else
		this.inUse = true
		this.LinkGate2 = this.LinkGate2 + 2
		if this.LinkGate2 > string.len(gatesLinks) then this.LinkGate2 = 1 end
		this.SetInterfaceCaption("LinkGate2","tooltip_LinkGate",2,"N",string.sub(gatesLinks,this.LinkGate2,this.LinkGate2 + 1),"L")
		InterfaceUpdate(false)
	end
end

function LinkGate3Clicked()
	if this.inUse then
	else
		this.inUse = true
		this.LinkGate3 = this.LinkGate3 + 2
		if this.LinkGate3 > string.len(gatesLinks) then this.LinkGate3 = 1 end
		this.SetInterfaceCaption("LinkGate3","tooltip_LinkGate",3,"N",string.sub(gatesLinks,this.LinkGate3,this.LinkGate3 + 1),"L")
		InterfaceUpdate(false)
	end
end

function LinkGate4Clicked()
	if this.inUse then
	else
		this.inUse = true
		this.LinkGate4 = this.LinkGate4 + 2
		if this.LinkGate4 > string.len(gatesLinks) then this.LinkGate4 = 1 end
		this.SetInterfaceCaption("LinkGate4","tooltip_LinkGate",4,"N",string.sub(gatesLinks,this.LinkGate4,this.LinkGate4 + 1),"L")
		InterfaceUpdate(false)
	end
end

function LinkGate5Clicked()
	if this.inUse then
	else
		this.inUse = true
		this.LinkGate5 = this.LinkGate5 + 2
		if this.LinkGate5 > string.len(gatesLinks) then this.LinkGate5 = 1 end
		this.SetInterfaceCaption("LinkGate5","tooltip_LinkGate",5,"N",string.sub(gatesLinks,this.LinkGate5,this.LinkGate5 + 1),"L")
		InterfaceUpdate(false)
	end
end

function LinkGate6Clicked()
	if this.inUse then
	else
		this.inUse = true
		this.LinkGate6 = this.LinkGate6 + 2
		if this.LinkGate6 > string.len(gatesLinks) then this.LinkGate6 = 1 end
		this.SetInterfaceCaption("LinkGate6","tooltip_LinkGate",6,"N",string.sub(gatesLinks,this.LinkGate6,this.LinkGate6 + 1),"L")
		InterfaceUpdate(false)
	end
end

function LinkGate7Clicked()
	if this.inUse then
	else
		this.inUse = true
		this.LinkGate7 = this.LinkGate7 + 2
		if this.LinkGate7 > string.len(gatesLinks) then this.LinkGate7 = 1 end
		this.SetInterfaceCaption("LinkGate7","tooltip_LinkGate",7,"N",string.sub(gatesLinks,this.LinkGate7,this.LinkGate7 + 1),"L")
		InterfaceUpdate(false)
	end
end

function LinkGate8Clicked()
	if this.inUse then
	else
		this.inUse = true
		this.LinkGate8 = this.LinkGate8 + 2
		if this.LinkGate8 > string.len(gatesLinks) then this.LinkGate8 = 1 end
		this.SetInterfaceCaption("LinkGate8","tooltip_LinkGate",8,"N",string.sub(gatesLinks,this.LinkGate8,this.LinkGate8 + 1),"L")
		InterfaceUpdate(false)
	end
end

function LinkGate9Clicked()
	if this.inUse then
	else
		this.inUse = true
		this.LinkGate9 = this.LinkGate9 + 2
		if this.LinkGate9 > string.len(gatesLinks) then this.LinkGate9 = 1 end
		this.SetInterfaceCaption("LinkGate9","tooltip_LinkGate",9,"N",string.sub(gatesLinks,this.LinkGate9,this.LinkGate9 + 1),"L")
		InterfaceUpdate(false)
	end
end

function LinkGate10Clicked()
	if this.inUse then
	else
		this.inUse = true
		this.LinkGate10 = this.LinkGate10 + 2
		if this.LinkGate10 > string.len(gatesLinks) then this.LinkGate10 = 1 end
		this.SetInterfaceCaption("LinkGate10","tooltip_LinkGate",10,"N",string.sub(gatesLinks,this.LinkGate10,this.LinkGate10 + 1),"L")
		InterfaceUpdate(false)
	end
end

function LinkGate11Clicked()
	if this.inUse then
	else
		this.inUse = true
		this.LinkGate11 = this.LinkGate11 + 2
		if this.LinkGate11 > string.len(gatesLinks) then this.LinkGate11 = 1 end
		this.SetInterfaceCaption("LinkGate11","tooltip_LinkGate",11,"N",string.sub(gatesLinks,this.LinkGate11,this.LinkGate11 + 1),"L")
		InterfaceUpdate(false)
	end
end

function LinkGate12Clicked()
	if this.inUse then
	else
		this.inUse = true
		this.LinkGate12 = this.LinkGate12 + 2
		if this.LinkGate12 > string.len(gatesLinks) then this.LinkGate12 = 1 end
		this.SetInterfaceCaption("LinkGate12","tooltip_LinkGate",12,"N",string.sub(gatesLinks,this.LinkGate12,this.LinkGate12 + 1),"L")
		InterfaceUpdate(false)
	end
end

function LinkGate13Clicked()
	if this.inUse then
	else
		this.inUse = true
		this.LinkGate13 = this.LinkGate13 + 2
		if this.LinkGate13 > string.len(gatesLinks) then this.LinkGate13 = 1 end
		this.SetInterfaceCaption("LinkGate13","tooltip_LinkGate",13,"N",string.sub(gatesLinks,this.LinkGate13,this.LinkGate13 + 1),"L")
		InterfaceUpdate(false)
	end
end

function LinkGate14Clicked()
	if this.inUse then
	else
		this.inUse = true
		this.LinkGate14 = this.LinkGate14 + 2
		if this.LinkGate14 > string.len(gatesLinks) then this.LinkGate14 = 1 end
		this.SetInterfaceCaption("LinkGate14","tooltip_LinkGate",14,"N",string.sub(gatesLinks,this.LinkGate14,this.LinkGate14 + 1),"L")
		InterfaceUpdate(false)
	end
end

function LinkGate15Clicked()
	if this.inUse then
	else
		this.inUse = true
		this.LinkGate15 = this.LinkGate15 + 2
		if this.LinkGate15 > string.len(gatesLinks) then this.LinkGate15 = 1 end
		this.SetInterfaceCaption("LinkGate15","tooltip_LinkGate",15,"N",string.sub(gatesLinks,this.LinkGate15,this.LinkGate15 + 1),"L")
		InterfaceUpdate(false)
	end
end

function LinkGate16Clicked()
	if this.inUse then
	else
		this.inUse = true
		this.LinkGate16 = this.LinkGate16 + 2
		if this.LinkGate16 > string.len(gatesLinks) then this.LinkGate16 = 1 end
		this.SetInterfaceCaption("LinkGate16","tooltip_LinkGate",16,"N",string.sub(gatesLinks,this.LinkGate16,this.LinkGate16 + 1),"L")
		InterfaceUpdate(false)
	end
end

function LinkGate17Clicked()
	if this.inUse then
	else
		this.inUse = true
		this.LinkGate17 = this.LinkGate17 + 2
		if this.LinkGate17 > string.len(gatesLinks) then this.LinkGate17 = 1 end
		this.SetInterfaceCaption("LinkGate17","tooltip_LinkGate",17,"N",string.sub(gatesLinks,this.LinkGate17,this.LinkGate17 + 1),"L")
		InterfaceUpdate(false)
	end
end

function LinkGate18Clicked()
	if this.inUse then
	else
		this.inUse = true
		this.LinkGate18 = this.LinkGate18 + 2
		if this.LinkGate18 > string.len(gatesLinks) then this.LinkGate18 = 1 end
		this.SetInterfaceCaption("LinkGate18","tooltip_LinkGate",18,"N",string.sub(gatesLinks,this.LinkGate18,this.LinkGate18 + 1),"L")
		InterfaceUpdate(false)
	end
end

function LinkGate19Clicked()
	if this.inUse then
	else
		this.inUse = true
		this.LinkGate19 = this.LinkGate19 + 2
		if this.LinkGate19 > string.len(gatesLinks) then this.LinkGate19 = 1 end
		this.SetInterfaceCaption("LinkGate19","tooltip_LinkGate",19,"N",string.sub(gatesLinks,this.LinkGate19,this.LinkGate19 + 1),"L")
		InterfaceUpdate(false)
	end
end

function LinkGate20Clicked()
	if this.inUse then
	else
		this.inUse = true
		this.LinkGate20 = this.LinkGate20 + 2
		if this.LinkGate20 > string.len(gatesLinks) then this.LinkGate20 = 1 end
		this.SetInterfaceCaption("LinkGate20","tooltip_LinkGate",20,"N",string.sub(gatesLinks,this.LinkGate20,this.LinkGate20 + 1),"L")
		InterfaceUpdate(false)
	end
end

function CheckMyManager()
	myManager = {}
	local x = World.NumCellsX
	local managers = Object.GetNearbyObjects("TrafficManager",x)
	if next(managers) then
		for thatManager, distance in pairs(managers) do
			myManager = thatManager
		end
	else
		myManager = Object.Spawn("TrafficManager",FindLeftRoadSide() + 0.5, 1.5)
	end	
	managers = nil
end

function BuildRoad(newLane,attachOnL,attachOnR,laneOnL,laneOnR)	
	local endX = World.NumCellsX - 1
	local endY = World.NumCellsY - 1
	if newLane then		
		if attachOnL and not attachOnR then
			for i = 0, endY do
				local lane1CellR = World.GetCell(this.Pos.x - 3,i) 
				local centerCell = World.GetCell(this.Pos.x - 2,i)
				local lane2CellL = World.GetCell(this.Pos.x - 1,i)
				local lane2CellR = World.GetCell(this.Pos.x,i)
				local sideCellR = World.GetCell(this.Pos.x + 1,i)
				sideCellR.Mat = "ConcreteTiles"
				lane1CellR.Mat = "Road"
				if i%2 == 0 then
					centerCell.Mat = "RoadMarkings"
				else
					centerCell.Mat = "Road"
				end
				lane2CellL.Mat = "Road"
				lane2CellR.Mat = "RoadMarkingsRight"
			end
		elseif attachOnR and not attachOnL then
			for i = 0, endY do
				local sideCellL = World.GetCell(this.Pos.x - 2,i)
				local lane1CellL = World.GetCell(this.Pos.x - 1, i) 
				local lane1CellR = World.GetCell(this.Pos.x,i)
				local centerCell = World.GetCell(this.Pos.x + 1,i)
				local lane2CellL = World.GetCell(this.Pos.x + 2,i)
				sideCellL.Mat = "ConcreteTiles"
				lane1CellL.Mat = "RoadMarkingsLeft"
				lane1CellR.Mat = "Road"
				if i%2 == 0 then
					centerCell.Mat = "RoadMarkings"
				else
					centerCell.Mat = "Road"
				end
				lane2CellL.Mat = "Road"
			end
		elseif attachOnL and attachOnR then
			for i = 0, endY do
				local lane1CellR = World.GetCell(this.Pos.x - 3,i)
				local center1Cell = World.GetCell(this.Pos.x - 2,i)
				local lane2CellL = World.GetCell(this.Pos.x - 1,i)
				local lane2CellR = World.GetCell(this.Pos.x,i)
				local center2Cell = World.GetCell(this.Pos.x + 1,i)
				local lane3CellL = World.GetCell(this.Pos.x + 2,i)
				lane1CellR.Mat = "Road"
				if i%2 == 0 then
					center1Cell.Mat = "RoadMarkings"
				else
					center1Cell.Mat = "Road"
				end
				lane2CellL.Mat = "Road"
				lane2CellR.Mat = "Road"
				center2Cell.Mat = center1Cell.Mat
				lane3CellL.Mat = "Road"
			end		
		end
	else
		if laneOnL then
			for i = 0, endY do
				local lCell = World.GetCell(this.Pos.x - 3,i)
				lCell.Mat = "RoadMarkingsRight"
			end
		end
		if laneOnR then
			for i = 0, endY do
				local rCell = World.GetCell(this.Pos.x + 2,i)
				rCell.Mat = "RoadMarkingsLeft"
			end
		end
		for i = 0, endY do 
			local sideCellL = World.GetCell(this.Pos.x - 2,i)
			local laneCellL = World.GetCell(this.Pos.x - 1,i)
			local laneCellR = World.GetCell(this.Pos.x,i)
			local sideCellR = World.GetCell(this.Pos.x + 1,i)
			sideCellL.Mat = "ConcreteTiles"
			laneCellL.Mat = "RoadMarkingsLeft"
			laneCellR.Mat = "RoadMarkingsRight"
			sideCellR.Mat = "ConcreteTiles"
		end
	end
	local nearbyTrees = Object.GetNearbyObjects("Tree",endY)
	for thatTree, distance in pairs(nearbyTrees) do
		if math.abs(thatTree.Pos.x - this.Pos.x) <= 2.5 then thatTree.Delete() end
	end
	nearbyTrees = nil
	local nearbyLights = Object.GetNearbyObjects("Light",endY)
	for thatLight, distance in pairs(nearbyLights) do
		if math.abs(thatLight.Pos.x - this.Pos.x) <= 1.5 then thatLight.Delete() end
	end
	local sideCellL = World.GetCell(this.Pos.x - 2,0)
	local sideCellR = World.GetCell(this.Pos.x + 1,0)
	if sideCellL.Mat == "ConcreteTiles" then
		for i = 0, endY do
			if i%20 == 0 then Object.Spawn("Light",this.Pos.x - 1.5, i + 0.5) end		
		end	
	end
	if sideCellR.Mat == "ConcreteTiles" then
		for i = 0, endY do
			if (i-10)%20 == 0 then Object.Spawn("Light",this.Pos.x + 1.5, i + 0.5) end			
		end	
	end
	nearbyLights = nil
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