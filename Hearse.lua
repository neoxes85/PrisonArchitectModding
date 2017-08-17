local timeTot = 0
local myMarker = {}
local neighbourMarkerLeft = {}
local neighbourMarkerRight = {}
local MarkerFound = false

function Create()
	this.HomeUID = "Hearse"..this.Id.u
	this.gatesCount = 1
	this.Speed = -0.2
end

function Update(elapsedTime)
	if timePerUpdate == nil then
		timePerUpdate = 0.2
		this.Speed = -0.2
		FindGraves()
		FindMyRoadMarker()
	end
	timeTot = timeTot + elapsedTime
	if timeTot >= timePerUpdate then
		timeTot = 0
		if this.State == "Arriving" or this.State == "Leaving" then
			if myMarker.TotalGates then
				this.Tooltip="\nVehicle ID: "..this.HomeUID.."\n\nDistance to gate #"..this.gatesCount..": "..(Object.GetProperty(myMarker,"GatePosY"..this.gatesCount) - this.Pos.y).."  Speed: "..this.Speed
				CloseGatesBehindMe()
				WaitForGateToOpen()
			else
				if MarkerFound then
					this.Delete()
				else
					if this.Tooltip ~= this.State then this.Tooltip = this.State end
				end
			end
		else
			if this.Tooltip ~= this.State then this.Tooltip = this.State end
		end
	end
end

function FindMyRoadMarker()
    myMarker = {}
	local x = World.NumCellsX
	local y = World.NumCellsY
	local dmax = math.ceil(math.sqrt(x^2 + y^2))
	local roadMarkers = Object.GetNearbyObjects("RoadMarker",dmax)
    if next(roadMarkers) then
		if this.MarkerUID then
			for thatRoadMarker, dist in pairs(roadMarkers) do
				if thatRoadMarker.Id.u == this.MarkerUID then
					MarkerFound = true
					myMarker = thatRoadMarker
					this.Pos.x = thatRoadMarker.Pos.x
					-- also get my neighbourmarker if this marker is on a double lane
					for thatRoadMarkerLeft, dLeft in pairs(roadMarkers) do
						if thatRoadMarkerLeft.Pos.x == this.Pos.x - 3 then
							neighbourMarkerLeft = thatRoadMarkerLeft
							break
						end
					end
					for thatRoadMarkerRight, dRight in pairs(roadMarkers) do		
						if thatRoadMarkerRight.Pos.x == this.Pos.x + 3 then
							neighbourMarkerRight = thatRoadMarkerRight
							break
						end
					end
					return
				end
			end
		else
			local trafficManagers = Object.GetNearbyObjects("TrafficManager",dmax)
			if next(trafficManagers) then
				for n, d in pairs(trafficManagers) do
					local roadToUse = math.random(0,n.EmergencyCount)
					n.IE = true
					for thatRoadMarker, dist in pairs(roadMarkers) do
						if thatRoadMarker.EmergencyTraffic then
							if thatRoadMarker.EmergencyMarkerID == roadToUse then
								MarkerFound = true
								myMarker = thatRoadMarker
								this.MarkerUID = myMarker.Id.u
								this.Pos.x = thatRoadMarker.Pos.x
								-- also get my neighbourmarker if this marker is on a double lane
								for thatRoadMarkerLeft, dLeft in pairs(roadMarkers) do
									if thatRoadMarkerLeft.Pos.x == this.Pos.x - 3 then
										neighbourMarkerLeft = thatRoadMarkerLeft
										break
									end
								end
								for thatRoadMarkerRight, dRight in pairs(roadMarkers) do		
									if thatRoadMarkerRight.Pos.x == this.Pos.x + 3 then
										neighbourMarkerRight = thatRoadMarkerRight
										break
									end
								end
								return
							end
						end
					end
				end
			end
		end
	end
end

function WaitForGateToOpen()
	if this.gatesCount <= myMarker.TotalGates then
		if Object.GetProperty(myMarker,"Authorized"..this.gatesCount) ~= this.HomeUID then
			if Object.GetProperty(myMarker,"GatePosY"..this.gatesCount) - this.Pos.y <= 5 then
				this.Speed = -0.2
				timePerUpdate = 0
				if Object.GetProperty(myMarker,"RequestFrom"..this.gatesCount) == "_" then
					Object.SetProperty(myMarker,"RequestFrom"..this.gatesCount,this.HomeUID)
					if Object.GetProperty(myMarker,"LargeGate"..this.gatesCount) then
						if Object.GetProperty(myMarker,"GatePosX"..this.gatesCount) == this.Pos.x + 1.5 and next(neighbourMarkerRight) then
							Object.SetProperty(neighbourMarkerRight,"RequestFrom"..this.gatesCount,this.HomeUID)
						elseif Object.GetProperty(myMarker,"GatePosX"..this.gatesCount) == this.Pos.x - 1.5 and next(neighbourMarkerLeft) then
							Object.SetProperty(neighbourMarkerLeft,"RequestFrom"..this.gatesCount,this.HomeUID)
						end
					end
				end
				if Object.GetProperty(myMarker,"LinkGate"..this.gatesCount) > 1 then
					for j = 1, myMarker.TotalGates do
						if Object.GetProperty(myMarker,"LinkGate"..j) == Object.GetProperty(myMarker,"LinkGate"..this.gatesCount) and Object.GetProperty(myMarker,"RequestFrom"..j) == "_" then
							Object.SetProperty(myMarker,"RequestFrom"..j,this.HomeUID)
							if Object.GetProperty(myMarker,"LargeGate"..j) then
								if Object.GetProperty(myMarker,"GatePosX"..j) == this.Pos.x + 1.5 and next(neighbourMarkerRight) then
									Object.SetProperty(neighbourMarkerRight,"RequestFrom"..j,this.HomeUID)
								elseif Object.GetProperty(myMarker,"GatePosX"..j) == this.Pos.x - 1.5 and next(neighbourMarkerLeft) then
									Object.SetProperty(neighbourMarkerLeft,"RequestFrom"..j,this.HomeUID)
								end
							end
						end
					end
				end
			elseif (Object.GetProperty(myMarker,"GatePosY"..this.gatesCount) - this.Pos.y) <= 9 then
				if Object.GetProperty(myMarker,"LargeGate"..this.gatesCount) then
					this.Speed = (Object.GetProperty(myMarker,"GatePosY"..this.gatesCount) - this.Pos.y) - 4.4
				else
					this.Speed = (Object.GetProperty(myMarker,"GatePosY"..this.gatesCount) - this.Pos.y) - 4.9
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
			if Object.GetProperty(myMarker,"GatePosY"..this.gatesCount) - this.Pos.y <= 5 then
				local gatesOpenCount = 0
				local linkedGatesCount = 0
				for j =1, myMarker.TotalGates do
					if Object.GetProperty(myMarker,"LinkGate"..j) == Object.GetProperty(myMarker,"LinkGate"..this.gatesCount) then
						linkedGatesCount = linkedGatesCount + 1
						if (Object.GetProperty(myMarker,"Authorized"..j) == this.HomeUID and Object.GetProperty(myMarker,"GateOpen"..j) == 1) or (Object.GetProperty(myMarker,"Authorized"..j) ~= "_" and Object.GetProperty(myMarker,"GateOpen"..j) == 1 and Object.GetProperty(myMarker,"LargeGate"..this.gatesCount)) then
							gatesOpenCount = gatesOpenCount + 1
						end
					end
				end
				if gatesOpenCount == linkedGatesCount then
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
	for i = 1,this.gatesCount do
		if Object.GetProperty(myMarker,"Authorized"..i) == this.HomeUID then
			if this.Pos.y - Object.GetProperty(myMarker,"GatePosY"..i) > 1.5 then
				Object.SetProperty(myMarker,"CloseGate"..i,true)
				if Object.GetProperty(myMarker,"LargeGate"..i) then
					if Object.GetProperty(myMarker,"GatePosX"..i) == this.Pos.x + 1.5 and next(neighbourMarkerRight) then
						Object.SetProperty(neighbourMarkerRight,"CloseGate"..i,true)
					elseif Object.GetProperty(myMarker,"GatePosX"..i) ==this.Pos.x - 1.5 and next(neighbourMarkerLeft) then
						Object.SetProperty(neighbourMarkerLeft,"CloseGate"..i,true)
					end
				end
			end
			if this.Pos.y - Object.GetProperty(myMarker,"GatePosY"..i) > 10 then 
				for j = 1,this.gatesCount do
					if Object.GetProperty(myMarker,"LinkGate"..j) == Object.GetProperty(myMarker,"LinkGate"..i) then
						Object.SetProperty(myMarker,"Authorized"..i,"No")
						Object.SetProperty(myMarker,"CloseGate"..i,false)
						if Object.GetProperty(myMarker,"LargeGate"..i) then
							if Object.GetProperty(myMarker,"GatePosX"..i) == this.Pos.x + 1.5 and next(neighbourMarkerRight) then
								Object.SetProperty(neighbourMarkerRight,"Authorized"..i,"No")
								Object.SetProperty(neighbourMarkerRight,"CloseGate"..i,false)
							elseif Object.GetProperty(myMarker,"GatePosX"..i) == this.Pos.x - 1.5 and next(neighbourMarkerLeft) then
								Object.SetProperty(neighbourMarkerLeft,"Authorized"..i,"No")
								Object.SetProperty(neighbourMarkerLeft,"CloseGate"..i,false)
							end
						end
					end
				end
			end
		end
	end
end

function FindGraves()
	local x = World.NumCellsX
	local y = World.NumCellsY
	local dmax = math.ceil(math.sqrt(x^2 + y^2))	
	local nearbyGraves = Object.GetNearbyObjects("Grave",dmax)
	for thatGrave, dist in pairs(nearbyGraves) do
		if thatGrave.Slot0.i == -1 then
			this.Delete()
		end
	end
end