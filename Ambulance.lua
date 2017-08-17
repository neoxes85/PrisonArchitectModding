local timeTot = 0
local myHeight = 5
local myMarker = {}
local myManager = {}
local myNeighbourMarker = {}
local MarkerFound = false

function Create()
	this.Hidden = true
	this.HomeUID = "Ambulance"..this.Id.u
	this.Speed = -0.2
	this.MarkerUID = -1
	this.gatesCount = 1
	this.myRoad = -1
end

function Update(elapsedTime)
	if timePerUpdate == nil then
		timePerUpdate = 0.2
		this.Speed = -0.2
		FindMyRoadLane()
	end
	timeTot = timeTot + elapsedTime
	if timeTot >= timePerUpdate then
		timeTot = 0
		this.Tooltip = "Vehicle "..this.HomeUID.." is "..this.State..". Speed: "..this.Speed
		if this.State == "Arriving" or this.State == "Leaving" then
			local smallRoadGates = Object.GetNearbyObjects("SmallRoadGate",myHeight)
			for srg, d in pairs(smallRoadGates) do
				if srg.Pos.x == this.Pos.x and (srg.Pos.y - this.Pos.y) <= (0.5*myHeight + 2.5) then
					if srg.Open <= 0.2 then
						timePerUpdate = 0
						this.Speed = -0.2
					else
						timePerUpdate = 0.2
					end
				end
			end	
			if next(myMarker) then
				if myMarker.TotalGates > 0 then				
					if myMarker.AutoGates then
						CloseGatesBehindMe()
						WaitForGateToOpen()
					end
					if this.gatesCount <= myMarker.TotalGates then
						this.Tooltip = "Vehicle "..this.HomeUID.." is "..this.State..". Speed: "..this.Speed.."\nDistance to Gate #"..this.gatesCount.." is "..(Object.GetProperty(myMarker,"GatePosY"..this.gatesCount) - this.Pos.y)
					else
						this.Tooltip = "Vehicle "..this.HomeUID.." is "..this.State..". Speed: "..this.Speed
					end
				end
			else
				if MarkerFound then CloseGatesBehindMe() end -- marker got replaced by a new one, close gates behind and go on
			end
		end
	end
end

function FindMyRoadLane()
    myMarker = {}
	myManager = {}
	local x = World.NumCellsX
	local y = World.NumCellsY
	local dmax = math.ceil(math.sqrt(x^2 + y^2))
	trafficManagers = Object.GetNearbyObjects("TrafficManager",dmax)
	for thatManager, dm in pairs(trafficManagers) do
		myManager = thatManager
	end
	myManager.IE = true
	local roadMarkers = Object.GetNearbyObjects("RoadMarker",dmax)
	if this.MarkerUID ~= -1 then
		for thatRoadMarker, dist in pairs(roadMarkers) do
			if thatRoadMarker.Id.u == this.MarkerUID then
				MarkerFound = true
				myMarker = thatRoadMarker
				this.Pos.x = thatRoadMarker.Pos.x
				this.Hidden = false
				-- also get my myNeighbourMarker if this marker is on a double lane
				myNeighbourMarker = {}
				for thatRoadMarker, d in pairs(roadMarkers) do
					if math.abs(thatRoadMarker.Pos.x - this.Pos.x) == 3 then
						myNeighbourMarker = thatRoadMarker
						break
					end
				end				
				return
			end
		end
	else
		if this.SubType == 0 then
		
		
		
		
--[[			for theManager, d in pairs(myManager) do
--				this.myRoad = theManager.EmergencyCount
--				local Ambulances = Object.GetNearbyObjects("Ambulance",3)
--				if next(Ambulances) and theManager.EmergencyCount > 0 then
--					for thatAmbulance, damb in pairs(Ambulances) do
--						while (thatAmbulance.myRoad == this.myRoad) do
--							this.myRoad = math.random(0,theManager.EmergencyCount)
--						end
--					end
--				end
				local roadToUse = theManager.EmergencyCount
				for thatRoadMarker, dist in pairs(roadMarkers) do
					if thatRoadMarker.EmergencyTraffic then
						if thatRoadMarker.EmergencyMarkerID == roadToUse then
							MarkerFound = true
							myMarker = thatRoadMarker
							this.MarkerUID = myMarker.Id.u
							this.Pos.x = thatRoadMarker.Pos.x
							this.Hidden = false
							-- also get my myNeighbourMarker if this marker is on a double lane
							myNeighbourMarker = {}
							for thatRoadMarker, d in pairs(roadMarkers) do
								if math.abs(thatRoadMarker.Pos.x - this.Pos.x) == 3 then
									myNeighbourMarker = thatRoadMarker
									break
								end
							end			
							return
						end
					end
				end
			end
]]		end
	end
end

function WaitForGateToOpen()
	if this.gatesCount <= myMarker.TotalGates then
		if Object.GetProperty(myMarker,"Authorized"..this.gatesCount) ~= this.HomeUID then
			if (Object.GetProperty(myMarker,"GatePosY"..this.gatesCount) - this.Pos.y) <= (0.5*myHeight + 2.5) then
				this.Speed = -0.2
				timePerUpdate = 0
				if Object.GetProperty(myMarker,"RequestFrom"..this.gatesCount) == "_" then
					Object.SetProperty(myMarker,"RequestFrom"..this.gatesCount,this.HomeUID)
					if Object.GetProperty(myMarker,"LargeGate"..this.gatesCount) then
						if math.abs(Object.GetProperty(myMarker,"GatePosX"..this.gatesCount) - this.Pos.x) == 1.5 and next(myNeighbourMarker) then
							for i = 1, myNeighbourMarker.TotalGates do
								 if Object.GetProperty(myNeighbourMarker,"GateUID"..i) == Object.GetProperty(myMarker,"GateUID"..this.gatesCount) then
									Object.SetProperty(myNeighbourMarker,"RequestFrom"..i,this.HomeUID)
								end
							end
						end
					end
				end
				if Object.GetProperty(myMarker,"LinkGate"..this.gatesCount) > 1 then
					for j = 1, myMarker.TotalGates do
						if Object.GetProperty(myMarker,"LinkGate"..j) == Object.GetProperty(myMarker,"LinkGate"..this.gatesCount) and Object.GetProperty(myMarker,"RequestFrom"..j) == "_" then
							Object.SetProperty(myMarker,"RequestFrom"..j,this.HomeUID)
							if Object.GetProperty(myMarker,"LargeGate"..j) then
								if math.abs(Object.GetProperty(myMarker,"GatePosX"..j) - this.Pos.x) == 1.5 and next(myNeighbourMarker) then
									for i = 1, myNeighbourMarker.TotalGates do
										if Object.GetProperty(myNeighbourMarker,"GateUID"..i) == Object.GetProperty(myMarker,"GateUID"..j) then
											Object.SetProperty(myNeighbourMarker,"RequestFrom"..i,this.HomeUID)
										end
									end
								end
							end
						end
					end
				end
			elseif (Object.GetProperty(myMarker,"GatePosY"..this.gatesCount) - this.Pos.y) <= (myHeight + 0.5) then
				if Object.GetProperty(myMarker,"LargeGate"..this.gatesCount) then
					this.Speed = (Object.GetProperty(myMarker,"GatePosY"..this.gatesCount) - this.Pos.y) - (0.5*myHeight + 1.8)
				else
					this.Speed = (Object.GetProperty(myMarker,"GatePosY"..this.gatesCount) - this.Pos.y) - (0.5*myHeight + 2.3)
				end
				timePerUpdate = 0
			end
		end
		if Object.GetProperty(myMarker,"LinkGate"..this.gatesCount) == 1 then
			if Object.GetProperty(myMarker,"Authorized"..this.gatesCount) == this.HomeUID and Object.GetProperty(myMarker,"GateOpen"..this.gatesCount) == 1 then
				this.gatesCount = this.gatesCount + 1
				timePerUpdate = 0.2
			end
		else
			if Object.GetProperty(myMarker,"GatePosY"..this.gatesCount) - this.Pos.y <= (0.5*myHeight + 2.5) then
				local openGatesCount = 0
				local linkedGatesCount = 0
				for j = 1, myMarker.TotalGates do
					if Object.GetProperty(myMarker,"LinkGate"..j) == Object.GetProperty(myMarker,"LinkGate"..this.gatesCount) then
						linkedGatesCount = linkedGatesCount + 1
						if (Object.GetProperty(myMarker,"Authorized"..j) == this.HomeUID and Object.GetProperty(myMarker,"GateOpen"..j) == 1) or
						(Object.GetProperty(myMarker,"LargeGate"..this.gatesCount) and Object.GetProperty(myMarker,"Authorized"..j) ~= "_" and Object.GetProperty(myMarker,"GateOpen"..j) == 1) then
							openGatesCount = openGatesCount + 1
						end
					end
				end
				if openGatesCount == linkedGatesCount then
					this.gatesCount = this.gatesCount + linkedGatesCount
					timePerUpdate = 0.2
				else
					this.Speed = -0.2
				end
			end
		end
	end
end

function CloseGatesBehindMe()
	for i = 1, this.gatesCount do
		if Object.GetProperty(myMarker,"Authorized"..i) == this.HomeUID then
			if (this.Pos.y - Object.GetProperty(myMarker,"GatePosY"..i)) > 0.5*myHeight or this.Pos.y > (World.NumCellsY - 1.5) then
				Object.SetProperty(myMarker,"CloseGate"..i,true)
				if Object.GetProperty(myMarker,"LargeGate"..i) then
					if math.abs(Object.GetProperty(myMarker,"GatePosX"..i) - this.Pos.x) == 1.5 and next(myNeighbourMarker) then
						for j = 1, myNeighbourMarker.TotalGates do
							if Object.GetProperty(myNeighbourMarker,"GateUID"..j) == Object.GetProperty(myMarker,"GateUID"..i) then
								Object.SetProperty(myNeighbourMarker,"CloseGate"..j,true)
							end
						end
					end
				end
			end
			if (this.Pos.y - Object.GetProperty(myMarker,"GatePosY"..i)) > myHeight or this.Pos.y > (World.NumCellsY - 1.5) then 
				for k = 1, this.gatesCount do
					if Object.GetProperty(myMarker,"LinkGate"..k) == Object.GetProperty(myMarker,"LinkGate"..i) then
						Object.SetProperty(myMarker,"Authorized"..i,"No")
						Object.SetProperty(myMarker,"CloseGate"..i,false)
						if Object.GetProperty(myMarker,"LargeGate"..i) then
							if math.abs(Object.GetProperty(myMarker,"GatePosX"..i) - this.Pos.x) == 1.5 and next(myNeighbourMarker) then
								for j = 1, myNeighbourMarker.TotalGates do
									if Object.GetProperty(myNeighbourMarker,"GateUID"..j) == Object.GetProperty(myMarker,"GateUID"..i) then
										Object.SetProperty(myNeighbourMarker,"Authorized"..j,"No")
										Object.SetProperty(myNeighbourMarker,"CloseGate"..j,false)
									end
								end
							end
						end
					end
				end
			end
		end
	end
end