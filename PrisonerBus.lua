
--    Name                 PrisonerBus  
--    Height               8  
--    SpriteScale          1

local MyMarker={}
local NeighbourMarkerLeft={}
local NeighbourMarkerRight={}
local DesiredSecLevel = ""
local nextBusStopFound=false
local timeTot=0
local Get = Object.GetProperty
local Set = Object.SetProperty
local Find = Object.GetNearbyObjects
local prisonerUnloaded=false
local prisonerBusEmpty=false
local BottomOfMap=-1
local MarkerFound=false

function FindMyRoadMarker()
    local roadMarkers = Find(this,"RoadMarker",500)
    if roadMarkers~=nil then
		if Get(this,"MarkerUID")~=nil then
			for name,dist in pairs(roadMarkers) do
				if Get(name,"MarkerUID")==this.MarkerUID then
					MyMarker=name
					MarkerFound=true
					this.Pos.x = name.Pos.x
					for nameL,dist in pairs(roadMarkers) do		-- also get my neighbourmarker if this marker is on a double lane
						if nameL.Pos.x==this.Pos.x-3 then
							NeighbourMarkerLeft=nameL
							break
						end
					end
					for nameR,dist in pairs(roadMarkers) do		-- also get my neighbourmarker if this marker is on a double lane
						if nameR.Pos.x==this.Pos.x+3 then
							NeighbourMarkerRight=nameR
							break
						end
					end
					return
				end
			end
		else
			local trafficManager = Find(this,"TrafficManager",500)
			if trafficManager~=nil then
				for n,d in pairs(trafficManager) do
					local roadToUse = n.IntakeCount
					Set(n,"II",true)
					for name,dist in pairs(roadMarkers) do
						if name.IntakeTraffic==true then
							if name.TotalBusStops==0 then						-- use the normal way of handling multiple intake roads
								if name.IntakeMarkerID==roadToUse then
									MyMarker=name
									Set(this,"MarkerUID",MyMarker.MarkerUID)
									MarkerFound=true
									this.Pos.x = name.Pos.x
									for nameL,dist in pairs(roadMarkers) do		-- also get my neighbourmarker if this marker is on a double lane
										if nameL.Pos.x==this.Pos.x-3 then
											NeighbourMarkerLeft=nameL
											break
										end
									end
									for nameR,dist in pairs(roadMarkers) do		-- also get my neighbourmarker if this marker is on a double lane
										if nameR.Pos.x==this.Pos.x+3 then
											NeighbourMarkerRight=nameR
											break
										end
									end
									return
								end
							else												-- override MarkerID's and spawn on desired intake road only
								for i=1,name.TotalBusStops do
									local bsMinSec = false
									local bsNormal = false
									local bsMaxSec = false
									local bsProtected = false
									local bsDeathRow = false	
									if DesiredSecLevel == "MinSec" then bsMinSec = true end
									if DesiredSecLevel == "Normal" then bsNormal = true end
									if DesiredSecLevel == "MaxSec" then bsMaxSec = true end
									if DesiredSecLevel == "Protected" then bsProtected = true end
									if DesiredSecLevel == "DeathRow" then bsDeathRow = true end
									if (bsMinSec and Get(name,"icMinSec"..i)) or
									(bsNormal and Get(name,"icNormal"..i)) or
									(bsMaxSec and Get(name,"icMaxSec"..i)) or
									(bsProtected and Get(name,"icProtected"..i)) or
									(bsDeathRow and Get(name,"icDeathRow"..i)) then
										MyMarker=name
										Set(this,"MarkerUID",MyMarker.MarkerUID)
										MarkerFound=true
										this.Pos.x = name.Pos.x
										for nameL,dist in pairs(roadMarkers) do		-- also get my neighbourmarker if this marker is on a double lane
											if nameL.Pos.x==this.Pos.x-3 then
												NeighbourMarkerLeft=nameL
												break
											end
										end
										for nameR,dist in pairs(roadMarkers) do		-- also get my neighbourmarker if this marker is on a double lane
											if nameR.Pos.x==this.Pos.x+3 then
												NeighbourMarkerRight=nameR
												break
											end
										end
										return
									end
								end
							end
						end
					end				-- if we come here then probably there were n suitable BusStops found (mismatching SecLevels), so use the normal way of handling intake
					for name,dist in pairs(roadMarkers) do
						if name.IntakeTraffic==true then
							if name.IntakeMarkerID==roadToUse then
								MyMarker=name
								Set(this,"MarkerUID",MyMarker.MarkerUID)
								MarkerFound=true
								this.Pos.x = name.Pos.x
								for nameL,dist in pairs(roadMarkers) do		-- also get my neighbourmarker if this marker is on a double lane
									if nameL.Pos.x==this.Pos.x-3 then
										NeighbourMarkerLeft=nameL
										break
									end
								end
								for nameR,dist in pairs(roadMarkers) do		-- also get my neighbourmarker if this marker is on a double lane
									if nameR.Pos.x==this.Pos.x+3 then
										NeighbourMarkerRight=nameR
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

function CheckMyPrisonersSecLevel()
	prisonerBusEmpty=true
	local loadedPrisoners=Find(this,"Prisoner",5)
	for thatPrisoner, distance in pairs(loadedPrisoners) do
		if thatPrisoner.Loaded==true then
			if thatPrisoner.Category ~= nil then
				DesiredSecLevel = thatPrisoner.Category
				prisonerBusEmpty=false
				return
			end
		end
	end
end

function FindNextBusStop()
	Set(this,"BusStopCount",this.BusStopCount+1)
	nextBusStopFound=true
	prisonerUnloaded=false
end

function WaitForBusStop()
	if Get(this,"BusStopCount")<=Get(MyMarker,"TotalBusStops") then
		if Get(MyMarker,"BusStopPosY"..this.BusStopCount)-this.Pos.y<4.75 and prisonerUnloaded==true then
			nextBusStopFound=false
			timePerUpdate=0.2
		elseif Get(MyMarker,"BusStopPosY"..this.BusStopCount)-this.Pos.y<=4.75 and prisonerUnloaded==false then
			this.Speed=0
			timePerUpdate=0
			local loadedPrisoners=Find(this,"Prisoner",5)
			for thatPrisoner, distance in pairs(loadedPrisoners) do
				local bsMinSec = false
				local bsNormal = false
				local bsMaxSec = false
				local bsProtected = false
				local bsDeathRow = false	
				if thatPrisoner.Category == "MinSec" then bsMinSec = true end
				if thatPrisoner.Category == "Normal" then bsNormal = true end
				if thatPrisoner.Category == "MaxSec" then bsMaxSec = true end
				if thatPrisoner.Category == "Protected" then bsProtected = true end
				if thatPrisoner.Category == "DeathRow" then bsDeathRow = true end
				if (bsMinSec and Get(MyMarker,"icMinSec"..this.BusStopCount)) or
				(bsNormal and Get(MyMarker,"icNormal"..this.BusStopCount)) or
				(bsMaxSec and Get(MyMarker,"icMaxSec"..this.BusStopCount)) or
				(bsProtected and Get(MyMarker,"icProtected"..this.BusStopCount)) or
				(bsDeathRow and Get(MyMarker,"icDeathRow"..this.BusStopCount)) then
					if thatPrisoner.Loaded then
						thatPrisoner.Loaded=false
						thatPrisoner.Locked=false
						thatPrisoner.CarrierId.i=nil
						thatPrisoner.CarrierId.u=nil
						if thatPrisoner.Id.i==this.Slot0.i then this.Slot0.i=-1;	this.Slot0.u=-1
							elseif thatPrisoner.Id.i==this.Slot1.i then this.Slot1.i=-1;	this.Slot1.u=-1
							elseif thatPrisoner.Id.i==this.Slot2.i then this.Slot2.i=-1;	this.Slot2.u=-1
							elseif thatPrisoner.Id.i==this.Slot3.i then this.Slot3.i=-1;	this.Slot3.u=-1
							elseif thatPrisoner.Id.i==this.Slot4.i then this.Slot4.i=-1;	this.Slot4.u=-1
							elseif thatPrisoner.Id.i==this.Slot5.i then this.Slot5.i=-1;	this.Slot5.u=-1
							elseif thatPrisoner.Id.i==this.Slot6.i then this.Slot6.i=-1;	this.Slot6.u=-1
							elseif thatPrisoner.Id.i==this.Slot7.i then this.Slot7.i=-1;	this.Slot7.u=-1
						end
						if Get(MyMarker,"BusStopPosX"..this.BusStopCount)==Get(MyMarker,"Pos.x")-1.5000 then
							thatPrisoner.Pos.x=Get(MyMarker,"BusStopPosX"..this.BusStopCount)-1.5+math.random()
						else
							thatPrisoner.Pos.x=Get(MyMarker,"BusStopPosX"..this.BusStopCount)+1.5-math.random()
						end
						thatPrisoner.Pos.y=Get(MyMarker,"BusStopPosY"..this.BusStopCount)-2+math.random()
						if Get(MyMarker,"ReceptionIntake"..this.BusStopCount)==true then thatPrisoner.IsNewIntake=true	end	-- prisoners will be brought to reception when this is turned on
					end
				end
			end
			loadedPrisoners=nil
			prisonerUnloaded=true
		elseif (Get(MyMarker,"BusStopPosY"..this.BusStopCount)-this.Pos.y)<=7.50 and prisonerUnloaded==false then
			this.Speed=(Get(MyMarker,"BusStopPosY"..this.BusStopCount)-this.Pos.y)-4.75
			timePerUpdate=0
		end
	end
end

function WaitForGateToOpen()
	if Get(this,"GateCount")<=Get(MyMarker,"TotalGates") then
		if Get(MyMarker,"Authorized"..this.GateCount)~=this.HomeUID then
			if Get(MyMarker,"GatePosY"..this.GateCount)-this.Pos.y<=6 or (Get(MyMarker,"LargeGate"..this.GateCount)==true and Get(MyMarker,"GatePosY"..this.GateCount)-this.Pos.y<=6.5) then
				this.Speed=-0.2
				timePerUpdate=0
				if Get(MyMarker,"RequestFrom"..this.GateCount) == "_" then
					Set(MyMarker,"RequestFrom"..this.GateCount,this.HomeUID)
					if Get(MyMarker,"LargeGate"..this.GateCount)==true then
						if Get(MyMarker,"GatePosX"..this.GateCount)==this.Pos.x+1.5 and next(NeighbourMarkerRight) then
							Set(NeighbourMarkerRight,"RequestFrom"..this.GateCount,this.HomeUID)
						elseif Get(MyMarker,"GatePosX"..this.GateCount)==this.Pos.x-1.5 and next(NeighbourMarkerLeft) then
							Set(NeighbourMarkerLeft,"RequestFrom"..this.GateCount,this.HomeUID)
						end
					end
				end
				if Get(MyMarker,"LinkGate"..this.GateCount)>1 then
					for j=1,Get(MyMarker,"TotalGates") do
						if Get(MyMarker,"LinkGate"..j)==Get(MyMarker,"LinkGate"..this.GateCount) and Get(MyMarker,"RequestFrom"..j) == "_" then
							Set(MyMarker,"RequestFrom"..j,this.HomeUID)
							if Get(MyMarker,"LargeGate"..j)==true then
								if Get(MyMarker,"GatePosX"..j)==this.Pos.x+1.5 and next(NeighbourMarkerRight) then
									Set(NeighbourMarkerRight,"RequestFrom"..j,this.HomeUID)
								elseif Get(MyMarker,"GatePosX"..j)==this.Pos.x-1.5 and next(NeighbourMarkerLeft) then
									Set(NeighbourMarkerLeft,"RequestFrom"..j,this.HomeUID)
								end
							end
						end
					end
				end
			elseif (Get(MyMarker,"GatePosY"..this.GateCount)-this.Pos.y)<=8 then
				if Get(MyMarker,"LargeGate"..this.GateCount)==true then
					this.Speed=(Get(MyMarker,"GatePosY"..this.GateCount)-this.Pos.y)-6.4
				else
					this.Speed=(Get(MyMarker,"GatePosY"..this.GateCount)-this.Pos.y)-5.9
				end
				timePerUpdate=0
			end
		end
		if Get(MyMarker,"LinkGate"..this.GateCount)==1 then
			if Get(MyMarker,"Authorized"..this.GateCount)==this.HomeUID and Get(MyMarker,"GateOpen"..this.GateCount)==1 then
				Set(this,"GateCount",this.GateCount+1)
				timePerUpdate=0.2
			end
		else
			if Get(MyMarker,"GatePosY"..this.GateCount)-this.Pos.y<=6 then
				local gatesopencounter=0
				local linkedgatescounter=0
				for j=1,Get(MyMarker,"TotalGates") do
					if Get(MyMarker,"LinkGate"..j)==Get(MyMarker,"LinkGate"..this.GateCount) then
						linkedgatescounter=linkedgatescounter+1
						if (Get(MyMarker,"Authorized"..j)==this.HomeUID and Get(MyMarker,"GateOpen"..j)==1) or (Get(MyMarker,"Authorized"..j)~="_" and Get(MyMarker,"GateOpen"..j)==1 and Get(MyMarker,"LargeGate"..this.GateCount)==true) then
							gatesopencounter=gatesopencounter+1
						end
					end
				end
				if gatesopencounter==linkedgatescounter then
					Set(this,"GateCount",this.GateCount+linkedgatescounter)
					timePerUpdate=0.2
				else
					this.Speed=-0.2
				end
			end
		end
	end
end

function CloseGatesBehindMe()
	for i=1,this.GateCount do
		if Get(MyMarker,"Authorized"..i)==this.HomeUID then
			if this.Pos.y-Get(MyMarker,"GatePosY"..i)>4.5 then
				Set(MyMarker,"CloseGate"..i,true)
				if Get(MyMarker,"LargeGate"..i)==true then
					if Get(MyMarker,"GatePosX"..i)==this.Pos.x+1.5 and next(NeighbourMarkerRight) then
						Set(NeighbourMarkerRight,"CloseGate"..i,true)
					elseif Get(MyMarker,"GatePosX"..i)==this.Pos.x-1.5 and next(NeighbourMarkerLeft) then
						Set(NeighbourMarkerLeft,"CloseGate"..i,true)
					end
				end
			end
			if this.Pos.y-Get(MyMarker,"GatePosY"..i)>8 then
				for j=1,this.GateCount do
					if Get(MyMarker,"LinkGate"..j)==Get(MyMarker,"LinkGate"..i) then
						Set(MyMarker,"Authorized"..i,"No")
						Set(MyMarker,"CloseGate"..i,false)
						if Get(MyMarker,"LargeGate"..i)==true then
							if Get(MyMarker,"GatePosX"..i)==this.Pos.x+1.5 and next(NeighbourMarkerRight) then
								Set(NeighbourMarkerRight,"Authorized"..i,"No")
								Set(NeighbourMarkerRight,"CloseGate"..i,false)
							elseif Get(MyMarker,"GatePosX"..i)==this.Pos.x-1.5 and next(NeighbourMarkerLeft) then
								Set(NeighbourMarkerLeft,"Authorized"..i,"No")
								Set(NeighbourMarkerLeft,"CloseGate"..i,false)
							end
						end
					end
				end
			end
		end
	end
end

function FindChinookIntakeTerminal()
	local nearbyTowers = {}
	nearbyTowers = Find("ChinookIntakeTerminal",10000)
	if next(nearbyTowers) then
		for thatTower, distance in pairs(nearbyTowers) do
			MyIntakeTower = thatTower
			break
		end
		Interface.AddComponent(this,"TransferIntake", "Button", "tooltip_Chinook_TransferToTerminal")
		if Get(MyIntakeTower,"AutoIntake") == "AUTO" or Get(this,"TransferToTerminal") == true then
			for i = 0,7 do
				Set(this,"Slot"..i..".i",-1)
			end
			local loadedPrisoners=Find(this,"Prisoner",5)
			for thatPrisoner, distance in pairs(loadedPrisoners) do
				Set(thatPrisoner,"IntakeTowerID",MyIntakeTower.Id.i)
				Set(thatPrisoner,"Pos.x",MyIntakeTower.Pos.x)
				Set(thatPrisoner,"Pos.y",MyIntakeTower.Pos.y-0.3)
			end
			Set(MyIntakeTower,"FindNewPrisoners",true)
			Interface.RemoveComponent(this,"SeparatorBus")
			Interface.RemoveComponent(this,"DeleteBus")
			Interface.RemoveComponent(this,"TransferIntake")
			this.Delete()
		end
	end
	Set(this,"FindIntakeTerminal",false)
end

function Create()
	Set(this,"HomeUID","PrisonerBus_"..me["id-uniqueId"])
	Set(this,"GateCount",1)
	Set(this,"BusStopCount",0)
	this.Speed=-0.2
end

function TransferIntakeClicked()
	CloseGatesBehindMe()
	Set(this,"TransferToTerminal",true)
	FindChinookIntakeTerminal()
end

function DeleteBusClicked()
	CloseGatesBehindMe()
	Interface.RemoveComponent(this,"SeparatorBus")
	Interface.RemoveComponent(this,"DeleteVehicle")
	Interface.RemoveComponent(this,"TransferIntake")
	this.Delete()
end

function Update(timePassed)
	if timePerUpdate==nil then
		Interface.AddComponent(this,"SeparatorBus", "Caption", "tooltip_separatorline")
		Interface.AddComponent( this,"DeleteBus", "Button", "Delete")
		Set(this,"TransferToTerminal",false)
		FindChinookIntakeTerminal()
		this.Speed=-0.2
		CheckMyPrisonersSecLevel()
		this.Speed=-0.2
		FindMyRoadMarker()
		this.Speed=-0.2
		if Get(this,"HomeUID")==nil then this.Delete() end
		if Get(this,"BusStopCount")==nil then nextBusStopFound=true; Set(this,"BusStopCount",1)
		elseif Get(this,"BusStopCount")>1 then nextBusStopFound=true; --Set(this,"BusStopCount",1)
		end
		this.Speed=-0.2
		timePerUpdate=0.2
		this.Speed=-0.2
	end
	timeTot=timeTot+timePassed
	if timeTot>=timePerUpdate then
		timeTot=0
		if this.State=="Arriving" or this.State=="Leaving" then
			if Get(MyMarker,"TotalGates")~=nil then
				CloseGatesBehindMe()
				WaitForGateToOpen()
				this.Tooltip="\nVehicle ID: "..this.HomeUID.."\n\nDistance to gate "..this.GateCount..": "..Get(MyMarker,"GatePosY"..this.GateCount)-this.Pos.y.."  Speed: "..this.Speed
				if Get(MyMarker,"TotalBusStops")>0 and Get(this,"BusStopCount")>Get(MyMarker,"TotalBusStops") and prisonerBusEmpty==false then
					CheckMyPrisonersSecLevel()
					if prisonerBusEmpty==false then
						for i=1,this.GateCount do
							for j=1,this.GateCount do
								if Get(MyMarker,"LinkGate"..j)==Get(MyMarker,"LinkGate"..i) then
									Set(MyMarker,"Authorized"..i,"No")
									Set(MyMarker,"CloseGate"..i,false)
									if Get(MyMarker,"LargeGate"..i)==true then
										if Get(MyMarker,"GatePosX"..i)==this.Pos.x+1.5 and next(NeighbourMarkerRight) then
											Set(NeighbourMarkerRight,"Authorized"..i,"No")
											Set(NeighbourMarkerRight,"CloseGate"..i,false)
										elseif Get(MyMarker,"GatePosX"..i)==this.Pos.x-1.5 and next(NeighbourMarkerLeft) then
											Set(NeighbourMarkerLeft,"Authorized"..i,"No")
											Set(NeighbourMarkerLeft,"CloseGate"..i,false)
										end
									end
								end
							end
						end
						Set(this,"GateCount",1)
						Set(this,"BusStopCount",0)
						prisonerUnloaded=false
						nextBusStopFound=false
						this.Pos.y=0
						Set(this,"MarkerUID",nil)
						FindMyRoadMarker()
					end
				end
			else
				if MarkerFound==true then	-- marker got replaced by a new one, delete vehicle
					Interface.RemoveComponent(this,"SeparatorBus")
					Interface.RemoveComponent(this,"DeleteBus")
					this.Delete()
				else
					if this.Tooltip~=this.State then
						this.Tooltip=this.State
					end
				end							-- else there were n markers at all, so do nothing
			end
			if Get(MyMarker,"TotalBusStops")~=nil then
				if Get(MyMarker,"TotalBusStops")>0 then
					if nextBusStopFound==false then
						FindNextBusStop()
						if nextBusStopFound==true then
							WaitForBusStop()
						end
					else
						WaitForBusStop()
					end
				end
			end
		else
			if this.Tooltip~=this.State then
				this.Tooltip=this.State
			end
		end
		if Get(this,"FindIntakeTerminal") == true then	-- set by diveryterminal when delivery is set to auto after being disabled
			CloseGatesBehindMe()							-- it will clean up truck jams from the road when a terminal is build to enable delivery by chinooks
			FindChinookIntakeTerminal()
		end
	end
end
