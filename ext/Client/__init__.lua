
Events:Subscribe('Extension:Loaded', function()
    WebUI:Init()
	WebUI:Show()
	WebUI:BringToFront()
end)
Events:Subscribe('Level:Destroy', function()
   WebUI:Hide()
   WebUI:DisableMouse()
end)
function RegisterVars()
STRIKE_AREA_RADIUS = math.random(15,30)
STRIKE_DURATION = math.random(10,30)
STRIKE_MISSILE_COUNT = math.random(15,30)
active = false
AS_active= false
killCounter = 0
killsneeded=7
m_LastUpdate = 0.0
m_InitialTimer = 5.0
m_Position = { 0.0, 0.0, 0.0 }
m_Objectives={}
m_LastUpdate = 0.0
rbp={0,0,0}
rba=0
misslesoundMaxRange=40
UPDATE_RATE=6
m_UpdateTimer=0
end
Events:Subscribe('Level:Loaded', function(levelName, gameMode)
RegisterVars()
end)
mapdata= {
{["map"] = "Levels/MP_001/UI/Minimap/MP01_",["WorldSize"]= 512,["WorldCenter"]={0,0}},
{["map"] = "Levels/MP_003/UI/Minimap/MP03_",["WorldSize"]= 2048,["WorldCenter"]={0,0}},
{["map"] = "Levels/MP_007/UI/Minimap/MP07_",["WorldSize"]= 2048,["WorldCenter"]={0,0}},
{["map"] = "Levels/MP_011/UI/Minimap/MP11_",["WorldSize"]= 512,["WorldCenter"]={0,88}},
{["map"] = "Levels/MP_012/UI/Minimap/MP12_",["WorldSize"]= 2048,["WorldCenter"]={0,0}},
{["map"] = "Levels/MP_013/UI/Minimap/MP13_",["WorldSize"]= 2048,["WorldCenter"]={0,0}},
{["map"] = "Levels/MP_017/UI/Minimap/MP17_",["WorldSize"]= 2048,["WorldCenter"]={0,0}},
{["map"] = "Levels/MP_018/UI/Minimap/MP18_",["WorldSize"]= 2048,["WorldCenter"]={0,0}},
{["map"] = "Levels/MP_Subway/UI/Minimap/MP15_",["WorldSize"]= 1024,["WorldCenter"]={0,-162}},
{["map"] = "Levels/XP1_001/UI/Minimap/XP1_001_",["WorldSize"]= 1024,["WorldCenter"]={0,0}},
{["map"] = "Levels/XP1_002/UI/Minimap/XP1_002_",["WorldSize"]= 2048,["WorldCenter"]={0,0}},
{["map"] = "Levels/XP1_003/UI/Minimap/XP1_003_",["WorldSize"]= 2048,["WorldCenter"]={0,0}},
{["map"] = "Levels/XP1_004/UI/Minimap/XP1_004_",["WorldSize"]= 2048,["WorldCenter"]={0,0}},
{["map"] = "Levels/XP2_Factory/UI/Minimap/XP2_Factory_",["WorldSize"]= 128,["WorldCenter"]={0,0}},
{["map"] = "Levels/XP2_Office/UI/Minimap/XP2_Office_",["WorldSize"]= 256,["WorldCenter"]={0,0}},
{["map"] = "Levels/XP2_Palace/UI/Minimap/XP2_Palace_",["WorldSize"]= 128,["WorldCenter"]={0,13}},
{["map"] = "Levels/XP2_Skybar/UI/Minimap/XP2_Skybar_",["WorldSize"]= 128,["WorldCenter"]={0,0}},
{["map"] = "Levels/XP3_Valley/UI/Minimap/XP3_Valley_",["WorldSize"]= 2048,["WorldCenter"]={0,0}},
{["map"] = "Levels/XP3_Shield/UI/Minimap/XP3_Shield_",["WorldSize"]= 2048,["WorldCenter"]={0,0}},
{["map"] = "Levels/XP3_Alborz/UI/Minimap/XP3_Alborz_",["WorldSize"]= 2048,["WorldCenter"]={600,250}},
{["map"] = "Levels/XP3_Desert/UI/Minimap/XP3_Desert_",["WorldSize"]= 2048,["WorldCenter"]={0,0}},
{["map"] = "Levels/XP4_Parl/UI/Minimap/XP4_Parliament_",["WorldSize"]= 1024,["WorldCenter"]={-150,50}},
{["map"] = "Levels/XP4_Rubble/UI/Minimap/XP4_Rubble_",["WorldSize"]= 512,["WorldCenter"]={40,0}},
{["map"] = "Levels/XP4_Quake/UI/Minimap/XP4_Earthquake_",["WorldSize"]= 512,["WorldCenter"]={-150,0}},
{["map"] = "Levels/XP4_FD/UI/Minimap/XP4_FinancialDistrict_",["WorldSize"]= 1024,["WorldCenter"]={75,-75}},
{["map"] = "Levels/XP5_001/UI/Minimap/XP5_001_",["WorldSize"]= 1024,["WorldCenter"]={79, 51}},
{["map"] = "Levels/XP5_002/UI/Minimap/XP5_002_",["WorldSize"]= 1024,["WorldCenter"]={-1800, 51}},
{["map"] = "Levels/XP5_003/UI/Minimap/XP5_003_",["WorldSize"]= 1024,["WorldCenter"]={60,-850}},
{["map"] = "Levels/XP5_004/UI/Minimap/XP5_004_",["WorldSize"]= 1024,["WorldCenter"]={-920,-900}}
}

function OnUpdate(p_Delta)
--[[m_LastUpdate = m_LastUpdate + p_Delta
if m_LastUpdate < (1.0 / 60.0) then
        return
    end
m_LastUpdate = 0.0--]]
 local s_ObjectiveIndex = 1
    local s_ObjectiveCounter = 1
  local s_Iterator = EntityManager:GetIterator('ClientCapturePointEntity')
   
	if s_Iterator ~= nil then
        local s_Entity = s_Iterator:Next()

	
        while s_Entity ~= nil do
            local s_CaptureEntity = CapturePointEntity(s_Entity)

            local s_Data = CapturePointEntityData(s_CaptureEntity.data)

            if s_Data.capturableType ~= CapturableType.CTUnableToChangeTeam then
                local s_Contested = s_CaptureEntity.location > 0.0 and s_CaptureEntity.location < 1.0
                local s_Team = s_CaptureEntity.team

                if not s_CaptureEntity.controlled then
                    s_Team = TeamId.TeamNeutral
                end
				
                
				local s_Label = s_CaptureEntity.name
				local s_attackingTeam = s_CaptureEntity.attackingTeam
                s_Label = s_Label:gsub('ID_H_US_', '')
                s_Label = s_Label:gsub('ID_H_RU_', '')
				
				-- Order the CapturePoints alphabetic
				if s_Label == "A" then
					s_ObjectiveIndex = 1
				elseif s_Label == "B" then
					s_ObjectiveIndex = 2
				elseif s_Label == "C" then
					s_ObjectiveIndex = 3
				elseif s_Label == "D" then
					s_ObjectiveIndex = 4
				elseif s_Label == "E" then
					s_ObjectiveIndex = 5
				elseif s_Label == "F" then
					s_ObjectiveIndex = 6
				elseif s_Label == "G" then
					s_ObjectiveIndex = 7
				elseif s_Label == "H" then
					s_ObjectiveIndex = 8
				elseif s_Label == "I" then
					s_ObjectiveIndex = 9
				elseif s_Label == "J" then
					s_ObjectiveIndex = 10
				elseif s_Label == "K" then
					s_ObjectiveIndex = 11
				elseif s_Label == "L" then
					s_ObjectiveIndex = 12
				end
				
                local s_Transform = s_CaptureEntity.transform.trans

                if m_Objectives[s_ObjectiveIndex] == nil then
					
					s_AddObjectives = true
					
                elseif m_Objectives[s_ObjectiveIndex]['label'] ~= s_Label or
                        m_Objectives[s_ObjectiveIndex]['currentTeam'] ~= s_Team or
                        m_Objectives[s_ObjectiveIndex]['contested'] ~= s_Contested then
						
                        m_Objectives[s_ObjectiveIndex] = {
                            label = s_Label,
                            currentTeam = s_Team,
							contested = s_Contested,
                            position = { s_Transform.x, s_Transform.y, s_Transform.z }
                        }
			
                    index = s_ObjectiveIndex - 1 
                end

                m_Objectives[s_ObjectiveIndex] = {
                    label = s_Label,
                    currentTeam = s_Team,
                    contested = s_Contested,
                    position = { s_Transform.x, s_Transform.y, s_Transform.z }
                }	  
            
        end
		s_Entity = s_Iterator:Next()
	
	end
		
	end
	end
local function has_value (tab, val)
    for index, value in ipairs(tab) do
       if value.label == val then
            return index
        end
    end

    return false
end

local FiringMode = {
	Disabled = 0,
	Target = 1,
	Area = 2
}

local configs = {
	[FiringMode.Target] = { {radius = 1, segments = 15, width = 0.5}, {radius = 2, segments = 20, width = 0.5}, {radius = 3, segments = 25, width = 0.5}},
	[FiringMode.Area] = { {radius = STRIKE_AREA_RADIUS, segments = 50, width = 2} }
} 

local pointOfAim = { 
	position = Vec3(), 
	points = {},
	mode = FiringMode.Disabled
}

local targets = {}
local pending = {}
local zones = {}

local drawHudEvent = nil
local updateEvent = nil

local MISSILE_AIRTIME = 3.3


NetEvents:Subscribe('Lattack', function(data)
NetEvents:Send('Airstrike:Launch', Vec3(tb[tostring(data)].x, tb[tostring(data)].y, tb[tostring(data)].z))
targets[#targets+1] = { position = pointOfAim.position:Clone(), points = {}, timer = MISSILE_AIRTIME }

end)

Events:Subscribe('LMattack', function(data)

WebUI:ExecuteJS(string.format("playCustomSound('ogg/target marked.ogg', 500, 1)"))

local rnd = math.random(1,7)
WebUI:ExecuteJS(string.format("playCustomSound('ogg/a"..rnd..".ogg', 2500, 1)"))

if (data=='RB') then
AreaStrike(Vec3(rbp[1], rbp[2], rbp[3]))
zones[#zones+1] = { position = pointOfAim.position, points = {}, timer = STRIKE_DURATION + MISSILE_AIRTIME}
rba=0
position = {rbp[1], rbp[2], rbp[3]}
else
nu=has_value(m_Objectives, data)
AreaStrike(Vec3(m_Objectives[nu].position[1], m_Objectives[nu].position[2], m_Objectives[nu].position[3]))
zones[#zones+1] = { position = pointOfAim.position, points = {}, timer = STRIKE_DURATION + MISSILE_AIRTIME}
position = {m_Objectives[nu].position[1], m_Objectives[nu].position[2], m_Objectives[nu].position[3]}
end
myPlayer=PlayerManager:GetLocalPlayer()
Pposition={myPlayer.soldier.worldTransform.trans.x,myPlayer.soldier.worldTransform.trans.y,myPlayer.soldier.worldTransform.trans.z}
volume=distanceFrom(Pposition,position)
NetEvents:Send('Airstrike:Sound', {'ogg/JetFlyBy.ogg',500,volume})
WebUI:DisableMouse()
active = false
AS_active = false
killCounter = 0
sleep(4)
end)

function AreaStrike(position)
	for i = 1, STRIKE_MISSILE_COUNT do

		local r = STRIKE_AREA_RADIUS * math.sqrt(MathUtils:GetRandom(0,1))

		local theta = 2 * math.pi * MathUtils:GetRandom(0,1)
		
		local x = r * math.sin(theta)
		local z = r * math.cos(theta)

		local position = Vec3(position.x + x, position.y, position.z + z)

		local fireAfter = MathUtils:GetRandom(0, STRIKE_DURATION)

		pending[#pending+1] = { position = position, points = {}, timer = fireAfter}
	end
	
end

Events:Subscribe('Engine:Update', function(dt)

    for i = #pending, 1, -1 do

    	pending[i].timer = pending[i].timer - dt

		if pending[i].timer < 0 then
		
			pending[i].timer = MISSILE_AIRTIME

			targets[#targets+1] = pending[i]

			NetEvents:Send('Airstrike:Launch', pending[i].position)
			

			table.remove(pending, i)
		end
	end

   	for i = #targets, 1, -1 do

    	targets[i].timer = targets[i].timer - dt

		if targets[i].timer < 0 then
		
			table.remove(targets, i)
		end
	end

	for i = #zones, 1, -1 do

    	zones[i].timer = zones[i].timer - dt

		if zones[i].timer < 0 then
		
			table.remove(zones, i)
		end
	end
	
end)
Events:Subscribe('Client:PostFrameUpdate', function(deltaTime)
	-- We make a simple timer so we only udpate UI every so often.
	m_UpdateTimer = m_UpdateTimer + deltaTime

	if m_UpdateTimer < UPDATE_RATE then
		return
	end
m_UpdateTimer = 0
myPlayer = PlayerManager:GetLocalPlayer()
end)

	
Events:Subscribe('Player:UpdateInput', function()
local Conquest=string.find(gm, "Conquest")
local myPlayer=PlayerManager:GetLocalPlayer()
if InputManager:WentKeyDown(InputDeviceKeys.IDK_F1) and not AS_active then

NetEvents:Send('Airstrike:Yell', {PlayerManager:GetLocalPlayer().name,10,killsneeded-killCounter..' more kill to get Ä Airstrike'})

end
if InputManager:WentKeyDown(InputDeviceKeys.IDK_F1) and AS_active and checkformap(mapdata,mapname) and myPlayer.soldier then

pti=myPlayer.teamId
	
	if active then

WebUI:ExecuteJS('hideimage();')
WebUI:DisableMouse()

active=false
else
WebUI:EnableMouse()
OnUpdate()

local t = {}
local t2 = {}
jsa='["'..mapdata[checkformap (mapdata, mapname)].map..'",'..rba..','
for i,v in ipairs(m_Objectives) do
    
    t[i+1] = v
	
	if pti==t[i+1].currentTeam then
	t[i+1].currentTeam=1
	elseif t[i+1].currentTeam~=0 then
	t[i+1].currentTeam=2
end
	
	 t2[i+1] = v
	 if t2[i+1].contested then
	 t2[i+1].contested=1
	 else
	 t2[i+1].contested=0
	 end

    jsa=jsa ..t[i+1].currentTeam..','
	jsa=jsa ..t2[i+1].contested..','
    
end
jsa=jsa..'0]'

WebUI:BringToFront()
WebUI:ExecuteJS(string.format('map('..jsa..', '..get2dflagcords()..', '..get2dplayer({myPlayer.soldier.worldTransform.trans.x,myPlayer.soldier.worldTransform.trans.z})..')'))


active=true
		end
	end

end)

NetEvents:Subscribe('pk',function (data)
myPlayer=PlayerManager:GetLocalPlayer()
if not checkformap(mapdata,mapname) then return end
	if myPlayer.name == data[1]  then
	killCounter =  killCounter + 1
if killCounter >= killsneeded and AS_active == false  then
OnUpdate()
WebUI:ExecuteJS(string.format("playCustomSound('ogg/mason.ogg', 0, 10)"))
NetEvents:Send('Airstrike:Yell', {PlayerManager:GetLocalPlayer().name,10,'💥 Artillery strike Now Avaliable, Press F1 to use.'})
AS_active= true
killCounter=0
end
end
if (data.killedID == myPlayer.name) then
killCounter=0
WebUI:Hide()
end
end)
Events:Subscribe('Level:Loaded', function(levelName, gameMode)
mapname = string.match(levelName, '/(%w+_%w+)')
gm=gameMode
mapdetails=mapdata[checkformap (mapdata, mapname)]
end)
--Hooks:Install('UI:CreateKillMessage', 1, function(hook)
    -- Do stuff here.
--end)
Hooks:Install('ClientChatManager:IncomingMessage', 1, function(hook, message, playerId, recipientMask, channelId, isSenderDead)
--print(message..'')
end)

NetEvents:Subscribe('Psound', function(data)
WebUI:ExecuteJS(string.format("playCustomSound('"..data[1].."', "..data[2]..", 1)"))
end)
NetEvents:Subscribe('radiobeacon',function (data)

rba=1
rbp ={data.position[1],data.position[2], data.position[3]}
end)
function getVolume(startPos, endPos)

	if (misslesoundMaxRange < 0) then
		return 1
	end
	if (misslesoundMaxRange == 0) then
		return 0
	end
	local distance = startPos:Distance(endPos)
	if (distance == 0) then
		return 1
	end
	return 1 - math.min(1, math.max(0, (distance / misslesoundMaxRange)))
end
function distanceFrom(p1,p2)
local soundDecPerStud = .5
local maxSound  = 1
   distance= math.sqrt((p2[1] - p1[1]) ^ 2 + (p2[2] - p1[2]) ^ 2 + (p2[3] - p1[3]) ^ 2)
   --return distance / misslesoundMaxRange
    return 001 *(maxSound - (distance) / 1000)
end
function sleep(s)
  local ntime = os.clock() + s/10
  repeat until os.clock() > ntime
end

function ptext(data)
   local Execute = 'setyell("'..data[1]..'");'
    WebUI:ExecuteJS(Execute)
    WebUI:ExecuteJS("show()")
    local timeDelayed = 0
    Events:Subscribe('Engine:Update', function(deltaTime) 
        timeDelayed = timeDelayed + deltaTime
        if timeDelayed >= data[2] then
            WebUI:ExecuteJS("fade()")
            timeDelayed = 0
            Events:Unsubscribe('Engine:Update')
        end
    end)
end
NetEvents:Subscribe('AStext', function(data)
local Execute = 'setyell("'..data[1]..'");'
    WebUI:ExecuteJS(Execute)
    WebUI:ExecuteJS("show()")
    local timeDelayed = 0
    Events:Subscribe('Engine:Update', function(deltaTime) 
        timeDelayed = timeDelayed + deltaTime
        if timeDelayed >= data[2] then
            WebUI:ExecuteJS("fade()")
            timeDelayed = 0
            Events:Unsubscribe('Engine:Update')
        end
    end)
end)


function capturepointcheck(tab, Team)
    found={}
    for index, value in ipairs(tab) do
        if tab[index].contested == true and tab[index].currentTeam==Team then
            table.insert( found, tab[index])
        end
    end

if #found ~= 0 then
    return found
	else
	return false
	end
end


function get2dflagcords()
s_WindowSize = ClientUtils:GetWindowSize()
origsize=mapdetails.WorldSize
newsize=1024
newsized=newsize/2
centreoffsetx=mapdetails.WorldCenter[1]*(newsize/origsize)
centreoffsety=mapdetails.WorldCenter[2]*(newsize/origsize)
data={}
for i = 1, #m_Objectives do
relativeX = m_Objectives[i].position[1] 
if(relativeX==0)
then
 --Number is zero
	relativeX=0
elseif(relativeX>0)
then 
    relativeX = -m_Objectives[i].position[1] / origsize
else
--Number is negative
	relativeX = math.abs(m_Objectives[i].position[1]) / origsize
end
relativeY = m_Objectives[i].position[3] / origsize
--Calculate the actual X,Y coordinates based on the percentage and new room size.
actualX =(relativeX * newsize)
actualY =(relativeY * newsize)
table.insert(data,(s_WindowSize.x/2)+actualX+centreoffsetx)
table.insert(data,(s_WindowSize.y/2)-actualY+centreoffsety)
end		
return json.encode(data)					
end
function checkformap (tab, val)
    for index, value in ipairs(tab) do
       if string.find(value.map,val) then
            return index
        end
    end

    return false
end
	
function get2dplayer(xy)

s_WindowSize = ClientUtils:GetWindowSize()
origsize=mapdetails.WorldSize
newsize=1024
newsized=newsize/2
centreoffsetx=mapdetails.WorldCenter[1]*(newsize/origsize)
centreoffsety=mapdetails.WorldCenter[2]*(newsize/origsize)
data={}

relativeX = xy[1]
if(relativeX==0)
then
 --Number is zero
	relativeX=0
elseif(relativeX>0)
then 
    relativeX = -xy[1] / origsize
else
--Number is negative
	relativeX = math.abs(xy[1]) / origsize
end
relativeY = xy[2] / origsize
--Calculate the actual X,Y coordinates based on the percentage and new room size.
actualX =(relativeX * newsize)
actualY =(relativeY * newsize)
table.insert(data,(s_WindowSize.x/2)+actualX+centreoffsetx)
table.insert(data,(s_WindowSize.y/2)-actualY+centreoffsety)
angle=GetYawfromForward(myPlayer.soldier.worldTransform.forward)
table.insert(data,angle)
return json.encode(data)	
			
end

function GetYawfromForward(forward)
		
 yaw=math.atan(forward.x,-forward.z) 
yaw_degrees = yaw * 180.0 / math.pi
	if( yaw_degrees < 0 ) then yaw_degrees = yaw_degrees + 360.0 end
	return yaw_degrees
end

function getplayerpotions()
local T1data={}
local T2data={}
	for _, player in pairs(PlayerManager:GetPlayersByTeam(TeamId.Team1)) do
		if player.soldier ~= nil then
	table.insert(T1data,{player.soldier.worldTransform.trans.x,player.soldier.worldTransform.trans.z})
	end
	end
	for _, player in pairs(PlayerManager:GetPlayersByTeam(TeamId.Team2)) do
		if player.soldier ~= nil then
	table.insert(T2data,{player.soldier.worldTransform.trans.x,player.soldier.worldTransform.trans.z})
	end
	end
	
	return {T1data,T2data}
end
