local timeTot = 0
local gatesLinks = "NoL1L2L3L4L5L6L7L8L9"
local myMarkers = {}
local allSmallRoadGates = {}
local allRoadGates = {}
local gatesSorted = {}
local allBusStops = {}
local busStopsSorted = {}
local allGarages = {}
local garagesSorted = {}

function Create()
	this.newScan = false
    this.CargoCount = 0
	this.IntakeCount = 0
	this.EmergencyCount = 0
	this.GarageCount = 0
	this.CargoTotal = 0
	this.IntakeTotal = 0
	this.EmergencyTotal = 0
	this.GarageTotal = 0
    this.IC = false
	this.II = false
	this.IE = false
	this.IG = false
end

function Update(elapsedTime)
	if timePerUpdate == nil then
		timePerUpdate = 1 + math.random()
		CheckRoadStuff()
		InterfaceUpdate(true)		
	end
    timeTot = timeTot + elapsedTime
    if timeTot >= timePerUpdate then
		timeTot = 0
		TooltipUpdate()
		if this.Pos.y ~= 1.5 then this.Pos.y = 1.5 end
		if this.newScan then
			this.newScan = false
			CheckRoadStuff()
		else
			UpdateGates()
			UpdateBusStops()
			UpdateGarages()			
		end
		if this.IC then
			this.IC = false
			this.CargoCount = tonumber(this.CargoCount) + 1
			if this.CargoCount >= this.CargoTotal then this.CargoCount = 0 end
			local currCargoID = 0
			for n,d in pairs(myMarkers) do
				if n.CargoTraffic then
					n.CargoMarkerID = currCargoID
					currCargoID = currCargoID + 1
				end
			end
			this.CargoTotal = currCargoID
		end
		if this.II then
			this.II = false
			this.IntakeCount = tonumber(this.IntakeCount) + 1
			if this.IntakeCount >= this.IntakeTotal then this.IntakeCount = 0 end
			local currIntakeID = 0
			for n,d in pairs(myMarkers) do
				if n.IntakeTraffic then
					n.IntakeMarkerID = currIntakeID
					currIntakeID = currIntakeID + 1
				end
			end
			this.IntakeTotal = currIntakeID
		end
		if this.IE then
			this.IE = false
			local currEmergencyID = 0
			for n,d in pairs(myMarkers) do
				if n.EmergencyTraffic then
					n.EmergencyMarkerID = currEmergencyID
					currEmergencyID = currEmergencyID + 1
				end
			end
			this.EmergencyTotal = currEmergencyID
			this.EmergencyCount = tonumber(this.EmergencyCount) + 1
			if this.EmergencyCount >= this.EmergencyTotal then this.EmergencyCount = 0 end			
		end
		if this.IG then
			this.IG = false
			this.GarageCount = tonumber(this.GarageCount) + 1
			if this.GarageCount >= this.GarageTotal then this.GarageCount = 0 end			
			local currGarageID = 0
			for n,d in pairs(myMarkers) do
				if n.GarageTraffic then
					n.GarageMarkerID = currGarageID
					currGarageID = currGarageID + 1
				end
			end
			this.GarageTotal = currGarageID
		end
	end
end

function InterfaceUpdate(firstCall)
	if firstCall then
		this.AddInterfaceComponent("Divider1","Caption","tooltip_Divider")
		this.AddInterfaceComponent("ScanMap","Button","tooltip_ScanMap")
	else
	end
	this.inUse = false
end

function ScanMapClicked()
	if this.inUse then
	else
		this.inUse = true
		CheckRoadStuff()
		InterfaceUpdate(false)
	end
end

function TooltipUpdate()
	local totRoadMarkers = 0
	local totCargoTraffic = 0
	local totIntakeTraffic = 0
	local totEmergencyTraffic = 0
	local totGarageTraffic = 0
	local totSmallRoadGates = 0
	local totRoadGates = 0
	local totBusStops = 0
	local totGarages = 0
	for theMarker, d in pairs(myMarkers) do
		totRoadMarkers = totRoadMarkers + 1
		if theMarker.CargoTraffic then totCargoTraffic = totCargoTraffic + 1 end
		if theMarker.IntakeTraffic then totIntakeTraffic = totIntakeTraffic + 1 end
		if theMarker.EmergencyTraffic then totEmergencyTraffic = totEmergencyTraffic + 1 end
		if theMarker.GarageTraffic then totGarageTraffic = totGarageTraffic + 1 end
	end
	for theSmallRoadGate, d in pairs(allSmallRoadGates) do totSmallRoadGates = totSmallRoadGates + 1 end		
	for theRoadGate, d in pairs(allRoadGates) do totRoadGates = totRoadGates + 1 end			
	for theBusStop, d in pairs(allBusStops) do totBusStops = totBusStops + 1 end			
	for theGarage, d in pairs(allGarages) do totGarages = totGarages + 1 end			
	if totCargoTraffic == 0 then totCargoTraffic = 1 end
	if totIntakeTraffic == 0 then totIntakeTraffic = 1 end
	if totEmergencyTraffic == 0 then totEmergencyTraffic = 1 end
	this.Tooltip = "=[Totals]=".."\n Road Markers:   "..totRoadMarkers.."\n Small Road Gates:   "..totSmallRoadGates.."\n Road Gates:   "..totRoadGates.."\n Prisoner Bus Stops:   "..totBusStops.."\n Garages:   "..totGarages
	this.Tooltip = this.Tooltip.."\n\n=[Road Lanes]=".."\n Cargo:   "..totCargoTraffic.."\n Intake:   "..totIntakeTraffic.."\n Emergency:   "..totEmergencyTraffic.."\n Garage:   "..totGarageTraffic
end

function CheckRoadStuff()
	local x = World.NumCellsX
	local y = World.NumCellsY
	local dmax = math.ceil(math.sqrt(x^2 + y^2))
	myMarkers = {}
	allSmallRoadGates = {}
	allRoadGates = {}
	allBusStops = {}
	allGarages={}
	myMarkers = Object.GetNearbyObjects("RoadMarker",x)
	allSmallRoadGates = Object.GetNearbyObjects("SmallRoadGate",dmax)
	allRoadGates = Object.GetNearbyObjects("RoadGate",dmax)
	allBusStops = Object.GetNearbyObjects("BusStopSign",dmax)
	allGarages = Object.GetNearbyObjects("GantryCraneHook",dmax)
	if next(myMarkers) then
		CacheMyGates()
		CacheMyBusStops()
		CacheMyGarages()
		UpdateGates()
		UpdateBusStops()
		UpdateGarages()
	else
		myMarkers = {}
		allSmallRoadGates = {}
		allRoadGates = {}
		gatesSorted = {}
		allBusStops = {}
		busStopsSorted = {}
		allGarages = {}
		garagesSorted = {}
	end
end

function CacheMyGates()
	gatesSorted = {}
	local gatesUnsorted = {}
	for thatMarker, d in pairs(myMarkers) do
		gatesSorted[thatMarker] = {}
		local gatesCount = 0
		for thatGate, distance in pairs(allSmallRoadGates) do
			if thatGate.Pos.x == thatMarker.Pos.x then
				gatesCount = gatesCount + 1
				gatesUnsorted[gatesCount] = thatGate.Pos.y
			end	
		end
		for thatGate, distance in pairs(allRoadGates) do
			if math.abs(thatGate.Pos.x - thatMarker.Pos.x) == 1.5 then
				gatesCount = gatesCount + 1
				gatesUnsorted[gatesCount] = thatGate.Pos.y
			end	
		end
		table.sort(gatesUnsorted)
		local j = 0
		for i, n in ipairs(gatesUnsorted) do
			for thatGate, distance in pairs(allSmallRoadGates) do
				if thatGate.Pos.x == thatMarker.Pos.x and thatGate.Pos.y == gatesUnsorted[i] and thatGate.Pos.y ~= gatesUnsorted[i-1] then
					j = j + 1
					gatesSorted[thatMarker][j] = thatGate
				end
			end
			for thatGate, distance in pairs(allRoadGates) do
				if math.abs(thatGate.Pos.x - thatMarker.Pos.x) == 1.5 and thatGate.Pos.y == gatesUnsorted[i] and thatGate.Pos.y ~= gatesUnsorted[i-1] then
					j = j + 1
					gatesSorted[thatMarker][j] = thatGate
				end
			end
		end
	end
	for thatMarker, d in pairs(gatesSorted) do
		for i, theGate in pairs(gatesSorted[thatMarker]) do
			Object.SetProperty(thatMarker,"GateUID"..i,theGate.Id.u)
			Object.SetProperty(thatMarker,"GatePosX"..i,theGate.Pos.x)
			Object.SetProperty(thatMarker,"GatePosY"..i,theGate.Pos.y)
			Object.SetProperty(thatMarker,"GateOpen"..i,theGate.Open)
			if math.abs(theGate.Pos.x - thatMarker.Pos.x) == 1.5 then Object.SetProperty(thatMarker,"LargeGate"..i,true) else Object.SetProperty(thatMarker,"LargeGate"..i,false) end
			if Object.GetProperty(thatMarker,"CloseGate"..i) == nil then Object.SetProperty(thatMarker,"CloseGate"..i,false) end
			if Object.GetProperty(thatMarker,"Authorized"..i) == nil then Object.SetProperty(thatMarker,"Authorized"..i,"No") end
			if Object.GetProperty(thatMarker,"RequestFrom"..i) == nil then Object.SetProperty(thatMarker,"RequestFrom"..i,"_") end
		end
	end
end

function CacheMyBusStops()
	busStopsSorted = {}
	local busStopsUnsorted = {}
	for thatMarker,d in pairs(myMarkers) do
		busStopsSorted[thatMarker] = {}
		local busStopsCount = 0
		for thatBusStop, distance in pairs(allBusStops) do
			if math.abs(thatBusStop.Pos.x - thatMarker.Pos.x) == 1.5 then
				busStopsCount = busStopsCount + 1
				busStopsUnsorted[busStopsCount] = thatBusStop.Pos.y
			end	
		end
		table.sort(busStopsUnsorted)
		local j = 0
		for i, n in ipairs(busStopsUnsorted) do 
			for thatBusStop, distance in pairs(allBusStops) do
				if  math.abs(thatBusStop.Pos.x - thatMarker.Pos.x) == 1.5 and thatBusStop.Pos.y == busStopsUnsorted[i]  and thatBusStop.Pos.y ~= busStopsUnsorted[i-1] then
					j = j + 1
					busStopsSorted[thatMarker][j] = thatBusStop
				end
			end
		end
	end
	for thatMarker, d in pairs(busStopsSorted) do
		for i, theBusStop in pairs(busStopsSorted[thatMarker]) do
			Object.SetProperty(thatMarker,"BusStopUID"..i,theBusStop.Id.u)
			Object.SetProperty(thatMarker,"BusStopPosX"..i,theBusStop.Pos.x)
			Object.SetProperty(thatMarker,"BusStopPosY"..i,theBusStop.Pos.y)
			Object.SetProperty(thatMarker,"icMinSec"..i,theBusStop.icMinSec)
			Object.SetProperty(thatMarker,"icNormal"..i,theBusStop.icNormal)
			Object.SetProperty(thatMarker,"icMaxSec"..i,theBusStop.icMaxSec)
			Object.SetProperty(thatMarker,"icProtected"..i,theBusStop.icProtected)
			Object.SetProperty(thatMarker,"icDeathRow"..i,theBusStop.icDeathRow)
			Object.SetProperty(thatMarker,"ReceptionIntake"..i,theBusStop.ReceptionIntake)
		end
	end
end

function CacheMyGarages()
	garagesSorted = {}
	local garagesUnsorted = {}
	for thatMarker, d in pairs(myMarkers) do
		garagesSorted[thatMarker] = {}
		local garagesCount = 0
		for thatGarage, distance in pairs(allGarages) do
			if thatGarage.ParkX == thatMarker.Pos.x then
				garagesCount = garagesCount + 1
				garagesUnsorted[garagesCount] = thatGarage.ParkY
			end	
		end
		table.sort(garagesUnsorted)
		local j = 0
		for i, n in ipairs(garagesUnsorted) do
			for thatGarage, distance in pairs(allGarages) do
				if thatGarage.ParkX == thatMarker.Pos.x and thatGarage.ParkY == garagesUnsorted[i] and thatGarage.ParkX ~= garagesUnsorted[i-1] then
					j = j + 1
					garagesSorted[thatMarker][j] = thatGarage
				end
			end
		end
	end
	for thatMarker, d in pairs(garagesSorted) do
		for i, theGarage in pairs(garagesSorted[thatMarker]) do
			Object.SetProperty(thatMarker,"GaragePosX"..i,theGarage.Pos.x)
			Object.SetProperty(thatMarker,"GaragePosY"..i,theGarage.Pos.y)
			theGarage.MarkerUID = thatMarker.Id.u
		end
	end
end

function UpdateGates()
	for thatMarker, d in pairs(gatesSorted) do
		if thatMarker.Pos.y then
			local tmpMarkerTooltip = ""
			if next(gatesSorted[thatMarker]) then
				tmpMarkerTooltip = tmpMarkerTooltip.."\n=[Road Gates]=\n"
				for i, theGate in pairs(gatesSorted[thatMarker]) do
					if theGate.Pos.y then
						if thatMarker.AutoGates then
							if Object.GetProperty(thatMarker,"RequestFrom"..i) == "_" and Object.GetProperty(thatMarker,"Authorized"..i) == "No" and (theGate.Mode == "LockedOpen" and theGate.Open == 1) or (theGate.Mode == "LockedShut" and theGate.Open == 0) then
							-- no traffic, closing gate
								theGate.Mode = 0
							end
							if Object.GetProperty(thatMarker,"Authorized"..i) ~= "No" and Object.GetProperty(thatMarker,"CloseGate"..i) then
							-- authorized, setting gate to lockedshut
								theGate.Mode = 1
							end
							if Object.GetProperty(thatMarker,"RequestFrom"..i) ~= "_" and Object.GetProperty(thatMarker,"Authorized"..i) == "No" and theGate.Mode ~= "LockedShut" then
							-- request from i authorized
								Object.SetProperty(thatMarker,"Authorized"..i,Object.GetProperty(thatMarker,"RequestFrom"..i))
								Object.SetProperty(thatMarker,"RequestFrom"..i,"_")
							end
							if Object.GetProperty(thatMarker,"Authorized"..i) ~= "No" and not Object.GetProperty(thatMarker,"CloseGate"..i) then
							-- authorized, setting gate to lockedopen
								theGate.Mode = 2
							end
						else
							Object.SetProperty(thatMarker,"CloseGate"..i,false)
							Object.SetProperty(thatMarker,"Authorized"..i,"No")
							Object.SetProperty(thatMarker,"RequestFrom"..i,"_")
						end
						Object.SetProperty(thatMarker,"GateOpen"..i,theGate.Open)
						thatMarker.TotalGates = i
						local gateType = "Small Road Gate."
						if Object.GetProperty(thatMarker,"LargeGate"..i) then gateType = "Road Gate." end
						tmpMarkerTooltip = tmpMarkerTooltip.."Gate #"..i.." at x "..theGate.Pos.x.." and y "..theGate.Pos.y.." is a "..gateType
						tmpMarkerTooltip = tmpMarkerTooltip.."\n   Link: "..string.sub(gatesLinks,Object.GetProperty(thatMarker,"LinkGate"..i),Object.GetProperty(thatMarker,"LinkGate"..i) + 1).."   ReqFrom: "..Object.GetProperty(thatMarker,"RequestFrom"..i).."   Auth: "..Object.GetProperty(thatMarker,"Authorized"..i).."\n"						
						tmpMarkerTooltip = tmpMarkerTooltip.."CloseGate: "..tostring(Object.GetProperty(thatMarker,"CloseGate"..i)).."\n"
					else
						-- gate got removed, reset
						CheckRoadStuff()
						return
					end
				end
			end
			thatMarker.Tooltip = tmpMarkerTooltip
		else
			-- marker got removed or replaced, reset
			CheckRoadStuff()
			return
		end
	end
end

function UpdateBusStops()
	for thatMarker, d in pairs(busStopsSorted) do
		if thatMarker.Pos.y then
			local tmpMarkerTooltip = (thatMarker.Tooltip or "")
			if next(busStopsSorted[thatMarker]) then
				tmpMarkerTooltip = tmpMarkerTooltip.."\n=[Prisoner Bus Stops]=\n"
				for i, theBusStop in pairs(busStopsSorted[thatMarker]) do
					if theBusStop.Pos.y then
						Object.SetProperty(thatMarker,"icMinSec"..i,theBusStop.icMinSec)
						Object.SetProperty(thatMarker,"icNormal"..i,theBusStop.icNormal)
						Object.SetProperty(thatMarker,"icMaxSec"..i,theBusStop.icMaxSec)
						Object.SetProperty(thatMarker,"icProtected"..i,theBusStop.icProtected)
						Object.SetProperty(thatMarker,"icDeathRow"..i,theBusStop.icDeathRow)
						Object.SetProperty(thatMarker,"ReceptionIntake"..i,theBusStop.ReceptionIntake)
						thatMarker.TotalBusStops = i
						local bsMinSec = "No"
						local bsNormal = "No"
						local bsMaxSec = "No" 
						local bsProtected = "No"
						local bsDeathRow = "No"
						local bsReceptionIntake = "No"
						if theBusStop.icMinSec then bsMinSec = "Yes" end
						if theBusStop.icNormal then bsNormal = "Yes" end
						if theBusStop.icMaxSec then bsMaxSec = "Yes" end
						if theBusStop.icProtected then bsProtected = "Yes" end
						if theBusStop.icDeathRow then bsDeathRow = "Yes" end
						if theBusStop.ReceptionIntake then bsReceptionIntake = "Yes" end
						if theBusStop.Pos.x == thatMarker.Pos.x - 1.5 then
							tmpMarkerTooltip = tmpMarkerTooltip.."Prisoners Bus Stop #"..i.." at x "..theBusStop.Pos.x.." and y "..theBusStop.Pos.y.." unloads to the left."
						elseif theBusStop.Pos.x == thatMarker.Pos.x + 1.5 then
							tmpMarkerTooltip = tmpMarkerTooltip.."Prisoners Bus Stop #"..i.." at x "..theBusStop.Pos.x.." and y "..theBusStop.Pos.y.." unloads to the right."
						end
						tmpMarkerTooltip = tmpMarkerTooltip.."\n   MinSec: "..bsMinSec.."   NormalSec: "..bsNormal.."   MaxSec: "..bsMaxSec
						tmpMarkerTooltip = tmpMarkerTooltip.."\n   ProCustody: "..bsProtected.."   DeathRow: "..bsDeathRow.."   Reception: "..bsReceptionIntake.."\n"
					else
						-- busstop got removed, reset
						CheckRoadStuff()
						return
					end
				end
			end
			thatMarker.Tooltip = tmpMarkerTooltip
		else
			-- marker got removed or replaced, reset
			CheckRoadStuff()
			return
		end
	end
end

function UpdateGarages()
	for thatMarker, d in pairs(garagesSorted) do
		if thatMarker.Pos.y then
			local tmpMarkerTooltip = (thatMarker.Tooltip or "")
			if next(garagesSorted[thatMarker]) then
				tmpMarkerTooltip = tmpMarkerTooltip.."\n=[Garages]=\n"
				for i, theGarage in pairs(garagesSorted[thatMarker]) do
					if theGarage.ParkY then
						thatMarker.TotalGarages = i
						tmpMarkerTooltip = tmpMarkerTooltip.."Garage #"..i.." is at x "..theGarage.ParkX" and y "..theGarage.ParkY.."\n"
					else
						-- garage got removed, reset
						CheckRoadStuff()
						return
					end
				end
			end
			thatMarker.Tooltip = tmpMarkerTooltip
		else
			-- marker got removed or replaced, reset
			CheckRoadStuff()
			return
		end
	end
end