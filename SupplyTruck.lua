local timeTot = 0
local myHeight = 8
local myMarker = {}
local neighbourMarker = {}
local MarkerFound = false
local ThisIsMyGarage = false
local NewEngine1 = {}
local NewEngine2 = {}
local NewLimo1 = {}
local NewLimo2 = {}
local nearbyObject = {}

function Create()
	this.HomeUID = "SupplyTruck"..this.Id.u
	this.Speed = -0.2
	this.FindDeliveryTerminal = true
	this.MarkerUID = -1
	this.gatesCount = 0
	this.nextGateFound = false
	this.CraneUID = 0
	this.garagesCount = 0
	this.nextGarageFound = false
	this.LimoSpawned = false
	this.PartsSpawned = false
	this.OrderAmount = 0
end

function Update(elapsedTime)
	if this.SubType < 2 then
		if timePerUpdate == nil then
			timePerUpdate = 0.2
			this.TransferToTerminal = false
			FindChinookDeliveryTerminal()
			if this.SubType == 1 and this.Carparts and not this.PartsSpawned then
				if this.OrderAmount > 0 then
					NewEngine1 = Object.Spawn("LimoEngine",this.Pos.x,0)
					NewEngine1.CraneUID = this.CraneUID
					local rndNum = math.random(0,10)
					if rndNum >= 6 then NewEngine1.SubType = 1 end
					this.Slot0.i = NewEngine1.Id.i
					this.Slot0.u = NewEngine1.Id.u
					NewEngine1.CarrierId.i = this.Id.i
					NewEngine1.CarrierId.u = this.Id.u
					NewEngine1.Loaded = true
					NewEngine1.UnloadEngineSlot0 = true
					NewEngine1.UnloadEngineSlot1 = false
					this.PartsSpawned = true
				end
				if this.OrderAmount > 1 then
					NewEngine2 = Object.Spawn("LimoEngine",this.Pos.x,0)
					NewEngine2.CraneUID = this.CraneUID
					local rndNum = math.random(0,10)
					if rndNum >= 6 then NewEngine2.SubType = 1 end
					this.Slot1.i = NewEngine2.Id.i
					this.Slot1.u = NewEngine2.Id.u
					NewEngine2.CarrierId.i = this.Id.i
					NewEngine2.CarrierId.u = this.Id.u
					NewEngine2.Loaded = true
					NewEngine2.UnloadEngineSlot0 = false
					NewEngine2.UnloadEngineSlot1 = true
					this.PartsSpawned = true					
				end
				FillSlotsWithLimoPapers()
			elseif this.SubType == 1 and not this.Carparts and not this.PartsSpawned and not this.LimoSpawned then
				if this.OrderAmount > 0 then
					NewLimo1 = Object.Spawn("LimoBroken",this.Pos.x,0)
					NewLimo1.CraneUID = this.CraneUID
					NewLimo1.SubType = math.random(0,2)
					this.Slot0.i = NewLimo1.Id.i
					this.Slot0.u = NewLimo1.Id.u
					NewLimo1.CarrierId.i = this.Id.i
					NewLimo1.CarrierId.u = this.Id.u
					NewLimo1.Loaded = true
					NewLimo1.UnloadTruckSlot0 = true
					NewLimo1.UnloadTruckSlot1 = false
					this.LimoSpawned = true					
				end
				if this.OrderAmount > 1 then
					NewLimo2 = Object.Spawn("LimoBroken",this.Pos.x,0)
					NewLimo2.CraneUID = this.CraneUID
					NewLimo2.SubType = math.random(0,2)
					this.Slot1.i = NewLimo2.Id.i
					this.Slot1.u = NewLimo2.Id.u
					NewLimo2.CarrierId.i = this.Id.i
					NewLimo2.CarrierId.u = this.Id.u
					NewLimo2.Loaded = true
					NewLimo2.UnloadTruckSlot0 = false
					NewLimo2.UnloadTruckSlot1 = true
					this.LimoSpawned = true		
				end
				FillSlotsWithLimoPapers()
			end
			this.Speed = -0.2
			FindMyRoadMarker()
		end
		timeTot = timeTot + elapsedTime
		if timeTot >= timePerUpdate then
			timeTot = 0
			this.Tooltip = "Vehicle "..this.HomeUID.." is "..this.State..". Speed: "..this.Speed
			if this.State == "Arriving" or this.State == "Leaving" then
				local smallGates = Object.GetNearbyObjects("SmallRoadGate",myHeight)
				for g, d in pairs(smallGates) do
					if g.Pos.x == this.Pos.x and (g.Pos.y - this.Pos.y) <= 0.5*(myHeight + 5) then
						if g.Open <= 0.2 then
							timePerUpdate = 0
							this.Speed = -0.2
						else
							timePerUpdate = 0.2
						end
					end
				end	
				if next(myMarker) then
					if myMarker.TotalGates > 0 then
						if this.nextGateFound then
						else
							this.gatesCount = this.gatesCount + 1
							this.nextGateFound = true
						end						
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
					if myMarker.TotalGarages > 0 then
						if this.nextGarageFound then
						else
							this.garagesCount = this.garagesCount + 1
							this.nextGarageFound = true
						end
						WaitForGarage()
						this.Tooltip = "\nVehicle ID: "..this.HomeUID.."   Speed: "..this.Speed.."\nDistance to Gate #"..this.gatesCount..": "..(Object.GetProperty(myMarker,"GatePosY"..this.gatesCount) - this.Pos.y).."\nGarage ID: "..this.CraneUID.."\n"
					end
				else
					if MarkerFound then CloseGatesBehindMe() end -- marker got replaced by a new one, close gates behind and go on
				end
			end
			if this.FindDeliveryTerminal then
				CloseGatesBehindMe()
				FindChinookDeliveryTerminal()
			end
		end
	end
end

function FindMyRoadMarker()
    myMarker = {}
	local x = World.NumCellsX
	local y = World.NumCellsY
	local dmax = math.ceil(math.sqrt(x^2 + y^2))
	local roadMarkers = Object.GetNearbyObjects("RoadMarker",dmax)
	if this.MarkerUID ~= -1 then
		for thatRoadMarker, dist in pairs(roadMarkers) do
			if thatRoadMarker.Id.u == this.MarkerUID then
				MarkerFound = true
				myMarker = thatRoadMarker
				this.Pos.x = thatRoadMarker.Pos.x
				-- also get my neighbourmarker if this marker is on a double lane
				neighbourMarker = {}
				for thatRoadMarker, d in pairs(roadMarkers) do
					if math.abs(thatRoadMarker.Pos.x - this.Pos.x) == 3 then
						neighbourMarker = thatRoadMarker
						break
					end
				end				
				return
			end
		end
	else
		if this.SubType == 0 then
			local trafficManagers = Object.GetNearbyObjects("TrafficManager",dmax)
			for n, d in pairs(trafficManagers) do
				local roadToUse = n.CargoCount
				n.IC = true
				for thatRoadMarker, dist in pairs(roadMarkers) do
					if thatRoadMarker.CargoTraffic then
						if thatRoadMarker.CargoMarkerID == roadToUse then
							MarkerFound = true
							myMarker = thatRoadMarker
							this.MarkerUID = myMarker.Id.u
							this.Pos.x = thatRoadMarker.Pos.x
							-- also get my neighbourmarker if this marker is on a double lane
							neighbourMarker = {}
							for thatRoadMarker, d in pairs(roadMarkers) do
								if math.abs(thatRoadMarker.Pos.x - this.Pos.x) == 3 then
									neighbourMarker = thatRoadMarker
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

function WaitForGateToOpen()
	if this.gatesCount <= myMarker.TotalGates then
		if Object.GetProperty(myMarker,"Authorized"..this.gatesCount) ~= this.HomeUID then
			if (Object.GetProperty(myMarker,"GatePosY"..this.gatesCount) - this.Pos.y) <= (0.5*myHeight + 2.5) then
				this.nextGateFound = false
				this.Speed = -0.2
				timePerUpdate = 0
				if Object.GetProperty(myMarker,"RequestFrom"..this.gatesCount) == "_" then
					Object.SetProperty(myMarker,"RequestFrom"..this.gatesCount,this.HomeUID)
					if Object.GetProperty(myMarker,"LargeGate"..this.gatesCount) then
						if math.abs(Object.GetProperty(myMarker,"GatePosX"..this.gatesCount) - this.Pos.x) == 1.5 and next(neighbourMarker) then
							for i = 1, neighbourMarker.TotalGates do
								 if Object.GetProperty(neighbourMarker,"GateUID"..i) == Object.GetProperty(myMarker,"GateUID"..this.gatesCount) then
									Object.SetProperty(neighbourMarker,"RequestFrom"..i,this.HomeUID)
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
								if math.abs(Object.GetProperty(myMarker,"GatePosX"..j) - this.Pos.x) == 1.5 and next(neighbourMarker) then
									for i = 1, neighbourMarker.TotalGates do
										if Object.GetProperty(neighbourMarker,"GateUID"..i) == Object.GetProperty(myMarker,"GateUID"..j) then
											Object.SetProperty(neighbourMarker,"RequestFrom"..i,this.HomeUID)
										end
									end
								end
							end
						end
					end
				end
			elseif (Object.GetProperty(myMarker,"GatePosY"..this.gatesCount) - this.Pos.y) <= (myHeight + 0.5) then
				this.Speed = (Object.GetProperty(myMarker,"GatePosY"..this.gatesCount) - this.Pos.y) - (0.5*myHeight + 2.3)
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
						if (Object.GetProperty(myMarker,"Authorized"..j) == this.HomeUID and Object.GetProperty(myMarker,"GateOpen"..j) == 1) or (Object.GetProperty(myMarker,"LargeGate"..this.gatesCount) and Object.GetProperty(myMarker,"Authorized"..j) ~= "_" and Object.GetProperty(myMarker,"GateOpen"..j) == 1) then
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
--	if this.gatesCount <= myMarker.TotalGates then
		for i = 1, this.gatesCount do
			if Object.GetProperty(myMarker,"Authorized"..i) == this.HomeUID then
				if (this.Pos.y - Object.GetProperty(myMarker,"GatePosY"..i)) > (0.5*myHeight + 0.5) or this.Pos.y > (World.NumCellsY - 0.5*myHeight + 2.5) then
					Object.SetProperty(myMarker,"CloseGate"..i,true)
					if Object.GetProperty(myMarker,"LargeGate"..i) then
						if math.abs(Object.GetProperty(myMarker,"GatePosX"..i) - this.Pos.x) == 1.5 and next(neighbourMarker) then
							for j = 1, neighbourMarker.TotalGates do
								if Object.GetProperty(neighbourMarker,"GateUID"..j) == Object.GetProperty(myMarker,"GateUID"..i) then
									Object.SetProperty(neighbourMarker,"CloseGate"..j,true)
								end
							end
						end
					end
				end
				if (this.Pos.y - Object.GetProperty(myMarker,"GatePosY"..i)) > (myHeight + 0.5) or this.Pos.y > (World.NumCellsY - 0.5*myHeight + 2.5) then 
					for k = 1, this.gatesCount do
						if Object.GetProperty(myMarker,"LinkGate"..k) == Object.GetProperty(myMarker,"LinkGate"..i) then
							Object.SetProperty(myMarker,"Authorized"..i,"No")
							Object.SetProperty(myMarker,"CloseGate"..i,false)
							if Object.GetProperty(myMarker,"LargeGate"..i) then
								if math.abs(Object.GetProperty(myMarker,"GatePosX"..i) - this.Pos.x) == 1.5 and next(neighbourMarker) then
									for j = 1, neighbourMarker.TotalGates do
										if Object.GetProperty(neighbourMarker,"GateUID"..j) == Object.GetProperty(myMarker,"GateUID"..i) then
											Object.SetProperty(neighbourMarker,"Authorized"..j,"No")
											Object.SetProperty(neighbourMarker,"CloseGate"..j,false)
										end
									end
								end
							end
						end
					end
				end
			end
		end
--	end
end

function FindMyCrane()
	ThisIsMyGarage = false
	nearbyObject = Object.GetNearbyObjects("GantryCraneRailLeft",12)
	if next(nearbyObject) then
		for thatRail, distance in pairs(nearbyObject) do
			if Object.GetProperty(thatRail,"HomeUID") == Object.GetProperty(this,"CraneUID") then
				MyCraneRailLeft=thatRail
				ThisIsMyGarage = true
			end
		end
	end
	nearbyObject = nil
end

function FindMyCargo()
	nearbyObject = Object.GetNearbyObjects("LimoEngine",5)
	if next(nearbyObject) then
		for thatEngine, distance in pairs(nearbyObject) do
			if Object.GetProperty(thatEngine,"Id.i") == Object.GetProperty(this,"Slot0.i") then
				NewEngine1 = thatEngine
			elseif Object.GetProperty(thatEngine,"Id.i") == Object.GetProperty(this,"Slot1.i") then
				NewEngine2 = thatEngine
			end
		end
	end
	nearbyObject = Object.GetNearbyObjects("LimoBroken",5)
	if next(nearbyObject) then
		for thatCar, distance in pairs(nearbyObject) do
			if Object.GetProperty(thatCar,"Id.i") == Object.GetProperty(this,"Slot0.i") then
				NewLimo1 = thatCar
			elseif Object.GetProperty(thatCar,"Id.i") == Object.GetProperty(this,"Slot1.i") then
				NewLimo2 = thatCar
			end
		end
	end
	nearbyObject = nil
end

function DeleteLimoPapers()
	nearbyObject = Object.GetNearbyObjects("LimoPapers",5)
	if next(nearbyObject) then
		for thatPaper, distance in pairs(nearbyObject) do
			if Object.GetProperty(thatPaper,"CarrierId.i") == Object.GetProperty(this,"Id.i") then
				thatPaper.Delete()
			end
		end
	end
	nearbyObject = nil
end

function WaitForGarage()
	if Object.GetProperty(this,"garagesCount")<=Object.GetProperty(myMarker,"TotalGarages") then
		this.Tooltip="\nVehicle ID: "..this.HomeUID.."\nCrane ID: "..this.CraneUID.."\n\nHeading for garage"..this.garagesCount.." at "..Object.GetProperty(myMarker,"GaragePosY"..this.garagesCount).."\nDistance to next gate "..this.gatesCount..": "..Object.GetProperty(myMarker,"GatePosY"..this.gatesCount)-this.Pos.y.."  Speed: "..this.Speed
		if Object.GetProperty(myMarker,"GaragePosY"..this.garagesCount)-this.Pos.y<=0.15 then
			this.Speed=-0.2
			Object.SetProperty(this,"nextGarageFound",false)
			FindMyCrane()
			if ThisIsMyGarage == true then
				if Object.GetProperty(this,"PartsSpawned") == true then		-- car engines on truck
					if Object.GetProperty(MyCraneRailLeft,"PartsRackIsFull") == false then
						if NewEngine1.Loaded == nil and NewEngine2.Loaded == nil then FindMyCargo() end	-- find them after loadgame
						if NewEngine1.Loaded == nil and NewEngine2.Loaded == nil then Object.SetProperty(this,"PartsOnTruck",false) else Object.SetProperty(this,"PartsOnTruck",true) end
					end
						
					if Object.GetProperty(this,"PartsOnTruck") == true and Object.GetProperty(MyCraneRailLeft,"PartsRackIsFull") == false then
						dummyTruck = Object.Spawn("TowTruckWithCarParts",this.Pos.x,this.Pos.y)
						dummyTruck.HomeUID = this.HomeUID
						dummyTruck.CraneUID = this.CraneUID
						dummyTruck.MarkerUID = myMarker.Id.u
						dummyTruck.gatesCount = this.gatesCount
						dummyTruck.garagesCount = this.garagesCount
						dummyTruck.Tooltip = "Processing"
						
						if NewEngine1 ~= nil then
							Object.SetProperty(this,"Slot0.i",-1)
							Object.SetProperty(this,"Slot0.u",-1)
							NewEngine1.Loaded = false
						end
						if NewEngine2 ~= nil then
							Object.SetProperty(this,"Slot1.i",-1)
							Object.SetProperty(this,"Slot1.u",-1)
							NewEngine2.Loaded = false
						end
						
						DeleteLimoPapers()
						this.Delete()
					end
				
				elseif Object.GetProperty(this,"LimoSpawned") == true then										-- limos on truck
					if Object.GetProperty(MyCraneRailLeft,"GarageIsFull") == false then
						if NewLimo1.Loaded == nil and NewLimo2.Loaded == nil then FindMyCargo() end		-- find them after loadgame
						if NewLimo1.Loaded == nil and NewLimo2.Loaded == nil then Object.SetProperty(this,"CarOnTruck",false) else Object.SetProperty(this,"CarOnTruck",true) end
					end
						
					if Object.GetProperty(this,"CarOnTruck") == true and Object.GetProperty(MyCraneRailLeft,"GarageIsFull") == false then
						dummyTruck = Object.Spawn("TowTruckWithLimo",this.Pos.x,this.Pos.y)
						dummyTruck.HomeUID = this.HomeUID
						dummyTruck.CraneUID = this.CraneUID
						dummyTruck.MarkerUID = myMarker.Id.u
						dummyTruck.gatesCount = this.gatesCount
						dummyTruck.garagesCount = this.garagesCount
						dummyTruck.Tooltip = "Processing"
						
						if NewLimo1 ~= nil then
							Object.SetProperty(this,"Slot0.i",-1)
							Object.SetProperty(this,"Slot0.u",-1)
							NewLimo1.Loaded = false
							Object.SetProperty(NewLimo1,"gatesCount",Object.GetProperty(this,"gatesCount"))
						end
						if NewLimo2 ~= nil then
							Object.SetProperty(this,"Slot1.i",-1)
							Object.SetProperty(this,"Slot1.u",-1)
							NewLimo2.Loaded = false
							Object.SetProperty(NewLimo2,"gatesCount",Object.GetProperty(this,"gatesCount"))
						end
						
						DeleteLimoPapers()
						this.Delete()
					end
				end
			end
		end
	end
end

function FillSlotsWithLimoPapers()		-- fill all slots on tow truck with sellable stuff to prevent loading cargo from Exports/Garbage area
	for i=0,7 do
		if tonumber(Object.GetProperty(this,"Slot"..i..".i")) == -1 then
			NewPapers = Object.Spawn("LimoPapers",this.Pos.x,this.Pos.y)
			Object.SetProperty(this,"Slot"..i..".i",Object.GetProperty(NewPapers,"Id.i"))
			Object.SetProperty(this,"Slot"..i..".u",Object.GetProperty(NewPapers,"Id.u"))
			Object.SetProperty(NewPapers,"CarrierId.i",Object.GetProperty(this,"Id.i"))
			Object.SetProperty(NewPapers,"CarrierId.u",Object.GetProperty(this,"Id.u"))
			Object.SetProperty(NewPapers,"Loaded",true)
			Object.SetProperty(NewPapers,"CraneUID",this.CraneUID)
		end
		this.Speed=-0.2
	end
end

function FindChinookDeliveryTerminal()
	local nearbyTowers = {}
	nearbyTowers = Object.GetNearbyObjects("ChinookDeliveryTerminal",10000)
	if next(nearbyTowers) then
		for thatTower, distance in pairs(nearbyTowers) do
			MyDeliveryTower = thatTower
			break
		end
		Interface.AddComponent(this,"TransferDelivery", "Button", "tooltip_Chinook_TransferToTerminal")
		if Object.GetProperty(MyDeliveryTower,"AutoDelivery") == "AUTO" or Object.GetProperty(MyDeliveryTower,"AutoDelivery") == "MANUAL-TRUCKS" or Object.GetProperty(this,"TransferToTerminal") == true then
			local loadedStack=Object.GetNearbyObjects(this,"Stack",5)
			for thatStack, distance in pairs(loadedStack) do
				if thatStack.CarrierId.i == this.Id.i then
					Object.SetProperty(thatStack,"CarrierId.i",-1)
					Object.SetProperty(thatStack,"CarrierId.u",-1)
					Object.SetProperty(thatStack,"Loaded",false)
					Object.SetProperty(thatStack,"DeliveryTowerID",MyDeliveryTower.Id.i)
					Object.SetProperty(thatStack,"Pos.x",MyDeliveryTower.Pos.x-0.5)
					Object.SetProperty(thatStack,"Pos.y",MyDeliveryTower.Pos.y)
				end
			end
			local loadedBox=Object.GetNearbyObjects(this,"Box",5)
			for thatBox, distance in pairs(loadedBox) do
				if thatBox.CarrierId.i == this.Id.i then
					Object.SetProperty(thatBox,"CarrierId.i",-1)
					Object.SetProperty(thatBox,"CarrierId.u",-1)
					Object.SetProperty(thatBox,"Loaded",false)
					Object.SetProperty(thatBox,"DeliveryTowerID",MyDeliveryTower.Id.i)
					Object.SetProperty(thatBox,"Pos.x",MyDeliveryTower.Pos.x-0.5)
					Object.SetProperty(thatBox,"Pos.y",MyDeliveryTower.Pos.y)
				end
			end
			local loadedStack=Object.GetNearbyObjects(this,"MailSatchel",5)
			for thatStack, distance in pairs(loadedStack) do
				if thatStack.CarrierId.i == this.Id.i then
					Object.SetProperty(thatStack,"CarrierId.i",-1)
					Object.SetProperty(thatStack,"CarrierId.u",-1)
					Object.SetProperty(thatStack,"Loaded",false)
					Object.SetProperty(thatStack,"DeliveryTowerID",MyDeliveryTower.Id.i)
					Object.SetProperty(thatStack,"Pos.x",MyDeliveryTower.Pos.x-0.5)
					Object.SetProperty(thatStack,"Pos.y",MyDeliveryTower.Pos.y)
				end
			end
			for i=0,7 do
				Object.SetProperty(this,"Slot"..i..".i",-1)
				Object.SetProperty(this,"Slot"..i..".u",-1)
			end
			Object.SetProperty(MyDeliveryTower,"FindNewStack",true)
			Interface.RemoveComponent(this,"SeparatorTruck")
			Interface.RemoveComponent(this,"DeleteVehicle")
			Interface.RemoveComponent(this,"TransferDelivery")
			this.Delete()
		end
	end
	Object.SetProperty(this,"FindDeliveryTerminal",false)
end

function TransferDeliveryClicked()
	CloseGatesBehindMe()
	Object.SetProperty(this,"TransferToTerminal",true)
	FindChinookDeliveryTerminal()
end