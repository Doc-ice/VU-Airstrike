local data = {}
cumulateTime = 0
playerUpdate = 1
admin={'Doc-Ice-Elm'}
airstrike= true
cf={}
m_InitialTimer = 5.0
m_Position = { 0.0, 0.0, 0.0 }
m_Objectives={}
m_LastUpdate = 0.0
botkillsneeded=6
local STRIKE_AREA_RADIUS = math.random(15,30)
local STRIKE_DURATION = math.random(10,30)
local STRIKE_MISSILE_COUNT = math.random(15,30)
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
local weaponTable = {
	["U_M16A4_M320_HE"] = "[M320]",
	["U_M16A4_M320_LVG"] = "[M320 LVG]",
	["U_M16A4_M320_SMK"] = "[M320 SMOKE]",
	["U_M16A4_M26_Flechette"] = "[M26 DART]",
	["U_M16A4_M26_Slug"] = "[M26 SLUG]",
	["U_M16A4_M26_Buck"] = "[M26 MASS]",
	["U_M16A4_M320_SHG"] = "[M320 BUCK]",
	["U_M416_M26_Slug"] = "[M26 SLUG]",
	["U_M416_M26_Frag"] = "[M26 FRAG]",
	["U_M416_M320_SHG"] = "[M320 BUCK]",
	["U_M416_M320_SMK"] = "[M320 SMOKE]",
	["U_M416_M26_Buck"] = "[M26 MASS]",
	["U_M416_M26_Flechette"] = "[M26 DART]",
	["U_M416_M320_LVG"] = "[M320 LVG]",
	["U_M416_M320_HE"] = "[M320]",
	["U_AEK971_M320_SHG"] = "[GP-30 DART]",
	["U_AEK971_M320_HE"] = "[GP-30]",
	["U_AEK971_M320_SMK"] = "[GP-30 SMOKE]",
	["U_AEK971_M320_LVG"] = "[GP-30 LVG]",
	["U_AN94_M320_HE"] = "[GP-30]",
	["U_AN94_M320_SMK"] = "[GP-30 SMOKE]",
	["U_AN94_M320_LVG"] = "[GP-30 LVG]",
	["U_AN94_M320_SHG"] = "[GP-30 BUCK]",
	["U_G3A3_M26_Frag"] = "[M26 FRAG]",
	["U_G3A3_M26_Buck"] = "[M26 MASS]",
	["U_G3A3_M26_Flechette"] = "[M26 DART]",
	["U_G3A3_M26_Slug"] = "[M26 SLUG]",
	["U_AK74M_M26Mass_Frag"] = "[M26 FRAG]",
	["U_AK74M_M26Mass"] = "[M26 MASS]",
	["U_AK74M_M26Mass_Slug"] = "[M26 SLUG]",
	["U_AK74M_M26Mass_Flechette"] = "[M26 DART]",
	["U_AK74M_M320_HE"] = "[GP-30]",
	["U_AK74M_M320_SHG"] = "[GP-30 DART]",
	["U_AK74M_M320_SMK"] = "[GP-30 SMOKE]",
	["U_AK74M_M320_LVG"] = "[GP-30 LVG]",
	["U_SCAR-L_M320_LVG"] = "[M320 LVG]",
	["U_SCAR-L_M26_Frag"] = "[M26 FRAG]",
	["U_SCAR-L_M26_Buck"] = "[M26 MASS]",
	["U_SCAR-L_M320_SHG"] = "[M320 BUCK]",
	["U_SCAR-L_M320_HE"] = "[M320]",
	["U_SCAR-L_M26_Slug"] = "[M26 SLUG]",
	["U_SCAR-L_M26_Flechette"] = "[M26 DART]",
	["U_SteyrAug_M26_Buck"] = "[M26 MASS]",
	["U_SteyrAug_M320_SMK"] = "[M320 SMOKE]",
	["U_SteyrAug_M26_Flechette"] = "[M26 DART]",
	["U_SteyrAug_M320_HE"] = "[M320]",
	["U_SteyrAug_M320_LVG"] = "[M320 LVG]",
	["U_SteyrAug_M26_Frag"] = "[M26 FRAG]",
	["U_SteyrAug_M26_Slug"] = "[M26 SLUG]",
	["U_SteyrAug_M320_SHG"] = "[M320 BUCK]",
	["U_M26Mass_Flechette"] = "[M26 DART]",
	["U_M26Mass_Slug"] = "[M26 SLUG]",
	["U_M26Mass"] = "[M26 MASS]",
	["U_M16A4_M26_Frag"] = "[M26 FRAG]",
	["U_M320_SMK"] = "[M320 SMOKE]",
	["U_M320_HE"] = "[M320]",
	["U_M26Mass_Frag"] = "[M26 FRAG]",
	["U_M320_SHG"] = "[M320 BUCK]",
	["U_M320_LVG"] = "[M320 LVG]",
	["U_Glock18"] = "[G18]",
	["U_Glock18_Silenced"] = "[G18 SUPP.]",
	["U_M15"] = "[M15 AT MINE]",
	["U_Knife"] = "[KNIFE]",
	["U_M4A1_RU"] = "[M4A1]",
	["U_M9_Silenced"] = "[M9 SUPP.]",
	["U_SG553LB"] = "[SG553]",
	["U_M39EBR"] = "[M39 EMR]",
	["U_L96"] = "[L96]",
	["U_MP5K"] = "[M5K]",
	["U_EODBot"] = "[EOD BOT]",
	["U_UGS"] = "[T-UGS]",
	["U_M1911_Tactical"] = "[M1911 S-TAC]",
	["U_SKS"] = "[SKS]",
	["U_ASVal"] = "[AS VAL]",
	["U_Ammobag"] = "[AMMO BOX]",
	["U_M240"] = "[M240B]",
	["U_870"] = "[870MCS]",
	["U_Pecheneg"] = "[PKP PECHENEG]",
	["U_QBU-88_Sniper"] = "[QBU-88]",
	["U_MP443"] = "[MP443]",
	["U_Jackhammer"] = "[MK3A1]",
	["U_M40A5"] = "[M40A5]",
	["U_RPG7"] = "[RPG-7V2]",
	["U_M27IAR_RU"] = "[M27 IAR]",
	["U_RPK-74M"] = "[RPK-74M]",
	["U_Claymore"] = "[M18 CLAYMORE]",
	["U_MK11"] = "[MK11 MOD 0]",
	["U_M9"] = "[M9]",
	["U_QBZ-95B"] = "[QBZ-95B]",
	["U_Taurus44"] = "[.44 MAGNUM]",
	["U_PP-19"] = "[PP-19]",
	["U_HK417"] = "[M417]",
	["U_M1911_Silenced"] = "[M1911 SUPP.]",
	["U_M93R_Laser"] = "[93R]",
	["U_SVD_US"] = "[SVD]",
	["U_C4"] = "[C4 EXPLOSIVES]",
	["U_M249"] = "[M249]",
	["U_SPAS12"] = "[SPAS-12]",
	["U_A91"] = "[A-91]",
	["U_MP443_Silenced"] = "[MP443 SUPP.]",
	["U_M67"] = "[M67 GRENADE]",
	["U_MK11_RU"] = "[MK11 MOD 0]",
	["U_M9_RU"] = "[M9]",
	["U_MP443_US"] = "[MP443]",
	["U_UMP45"] = "[UMP-45]",
	["U_FGM148"] = "[FGM-148 JAVELIN]",
	["U_Glock17_Silenced"] = "[G17C SUPP.]",
	["U_RadioBeacon"] = "[RADIO BEACON]",
	["U_P90"] = "[P90]",
	["U_MG36"] = "[MG36]",
	["U_LSAT"] = "[LSAT]",
	["U_SAIGA_20K"] = "[SAIGA 12K]",
	["U_PP2000"] = "[PP-2000]",
	["U_M98B"] = "[M98B]",
	["U_SOFLAM"] = "[SOFLAM]",
	["U_Taurus44_Silenced"] = "[.44 MAGNUM]",
	["U_AK74M"] = "[AK-74M]",
	["U_Medkit"] = "[MEDIC KIT]",
	["U_FAMAS"] = "[FAMAS]",
	["U_SteyrAug"] = "[AUG A3]",
	["U_M416"] = "[M416]",
	["U_Defib"] = "[DEFIBRILLATOR]",
	["U_KH2002"] = "[KH2002]",
	["U_L85A2"] = "[L85A2]",
	["U_AEK971"] = "[AEK-971]",
	["U_SCAR-L"] = "[SCAR-L]",
	["U_M4A1"] = "[M4A1]",
	["U_AKS74u_US"] = "[AKS-74u]",
	["U_SMAW"] = "[SMAW]",
	["U_HK53"] = "[G53]",
	["U_Glock17"] = "[G17C]",
	["U_L86"] = "[L86A2]",
	["U_M16A4"] = "[M16A3]",
	["U_Repairtool"] = "[REPAIR TOOL]",
	["U_SV98"] = "[SV98]",
	["U_MP443_TacticalLight"] = "[MP443 TACT.]",
	["U_SVD"] = "[SVD]",
	["U_Taurus44_Scoped"] = "[.44 SCOPED]",
	["U_Knife_Razor"] = "[ACB-90]",
	["U_FIM92"] = "[FIM-92 STINGER]",
	["U_F2000"] = "[F2000]",
	["U_M16_Burst"] = "[M16A4]",
	["U_M39EBR_Posh"] = "[M39 EMR]",
	["U_MagpulPDR"] = "[PDW-R]",
	["U_MP412Rex"] = "[MP412 REX]",
	["U_M1911"] = "[M1911]",
	["U_M1911_Lit"] = "[M1911 TACT.]",
	["U_AN94"] = "[AN-94]",
	["U_M60"] = "[M60E4]",
	["U_QBB-95"] = "[QBB-95]",
	["U_M4"] = "[M4]",
	["U_M27IAR"] = "[M27 IAR]",
	["U_Sa18IGLA"] = "[SA-18 IGLA]",
	["U_SCAR-H"] = "[SCAR-H]",
	["U_AKS74u"] = "[AKS-74u]",
	["U_RPK-74M_US"] = "[RPK-74M]",
	["U_M1014"] = "[M1014]",
	["U_USAS-12"] = "[USAS-12]",
	["U_M93R"] = "[93R]",
	["U_MAV"] = "[MAV]",
	["U_AK74M_US"] = "[AK-74M]",
	["U_M16A4_RU"] = "[M16A3]",
	["U_M9_TacticalLight"] = "[M9 TACT.]",
	["U_M224"] = "[M224 MORTAR]",
	["U_G36C"] = "[G36C]",
	["U_DAO-12"] = "[DAO-12]",
	["U_MP7"] = "[MP7]",
	["U_JNG90"] = "[JNG-90]",
	["U_Taurus44_GM"] = "[.44 MAGNUM]",
	["U_MP443_GM"] = "[MP443]",
	["U_M93R_GM"] = "[93R]",
	["U_P90_GM"] = "[P90]",
	["U_Type88"] = "[TYPE 88 LMG]",
	["U_MTAR"] = "[MTAR-21]",
	["U_ACR"] = "[ACW-R]",
	["U_Crossbow_Scoped_RifleScope"] = "[XBOW]",
	["U_G3A3"] = "[G3A3]",
	["U_Crossbow_Scoped_Cobra"] = "[XBOW]",
	["U_M9_GM"] = "[M9]",
}
local vehicleTable = {
	["LAV25"] = "[LAV-25]",
	["BMP2"] = "[BMP-2M]",
	["GAZ-3937_Vodnik"] = "[GAZ-3937 VODNIK]",
	["HumveeArmored"] = "[M1114 HMMWV]",
	["TOW2"] = "[M220 TOW LAUNCHER]",
	["Kornet"] = "[9M133 KORNET LAUNCHER]",
	["EODBot"] = "[EOD BOT]",
	["MAV"] = "[MAV]",
	["SOFLAM_Projectile"] = "[SOFLAM]",
	["RadioBeacon_Projectile"] = "[RADIO BEACON]",
	["T-UGS_Vehicle"] = "[T-UGS]",
	["9K22_Tunguska_M"] = "[9K22 TUNGUSKA-M]",
	["9K22_Tunguska_M_AI"] = "[9K22 TUNGUSKA-M]",
	["Humvee"] = "[M1114 HMMWV]",
	["A10_THUNDERBOLT"] = "[A-10 THUNDERBOLT]",
	["A10_THUNDERBOLT_spjet"] = "[A-10 THUNDERBOLT]",
	["AAV-7A1"] = "[AAV-7A1 AMTRAC]",
	["AH1Z"] = "[AH-1Z VIPER]",
	["AH1Z_coop"] = "[AH-1Z VIPER]",
	["AH6_Littlebird"] = "[AH-6J LITTLE BIRD]",
	["AH6_Littlebird_EQ"] = "[AH-6J LITTLE BIRD]",
	["BMP2_SP007"] = "[BMP-2M]",
	["Centurion_C-RAM"] = "[CENTURION C-RAM]",
	["Centurion_C-RAM_Carrier"] = "[CENTURION C-RAM]",
	["CivilianCar_03_Vehicle"] = "[CIVILIAN CAR]",
	["CivilianCar_03_Vehicle_SPJet"] = "[CIVILIAN CAR]",
	["AGM-144_Hellfire_TV"] = "[TV MISSILE]",
	["DeliveryVan_Vehicle"] = "[DELIVERY VAN]",
	["Dummy_AK74"] = "[AK-74M]",
	["Dummy_Flashbang"] = "[FLASHBANG]",
	["Dummy_HeliEngine"] = "[HELIENGINE]",
	["Dummy_HGrenade"] = "[M67 GRENADE]",
	["Dummy_RPG7"] = "[RPG-7V2]",
	["Dummy_SHG"] = "[M320 BUCK]",
	["Dummy_SVD"] = "[SVD]",
	["F16"] = "[F/A-18E SUPER HORNET]",
	["F18_Wingman"] = "[F/A-18E SUPER HORNET]",
	["GrowlerITV"] = "[GROWLER ITV]",
	["GrowlerITV_Valley"] = "[GROWLER ITV]",
	["HumveeArmored_hmg"] = "[M1114 HMMWV]",
	["Ka-60"] = "[KA-60 KASATKA]",
	["LAV_AD"] = "[LAV-AD]",
	["LAV25_AI"] = "[LAV-25]",
	["M1Abrams"] = "[M1 ABRAMS]",
	["M1Abrams_AI_SP007"] = "[M1 ABRAMS]",
	["M1Abrams_SP007"] = "[M1 ABRAMS]",
	["M1Abrams_SP_Rail"] = "[M1 ABRAMS]",
	["Mi28"] = "[MI-28 HAVOC]",
	["Pantsir-S1"] = "[PANTSIR-S1]",
	["Paris_SUV"] = "[SUV]",
	["Paris_SUV_Coop"] = "[SUV]",
	["Sniper_SUV"] = "[SUV]",
	["PoliceVan_Vehicle"] = "[POLICE VAN]",
	["RHIB"] = "[RHIB BOAT]",
	["Su-25TM"] = "[SU-25TM FROGFOOT]",
	["Su-35BM Flanker-E"] = "[SU-35BM FLANKER-E]",
	["Su37"] = "[SU-37]",
	["T90"] = "[T-90A]",
	["T90_SP007"] = "[T-90A]",
	["T90_T55_SP007"] = "[T-90A]",
	["TechnicalTruck"] = "[TECHNICAL TRUCK]",
	["TechnicalTruck_Restricted"] = "[TECHNICAL TRUCK]",
	["VDV Buggy"] = "[VDV Buggy]",
	["Venom"] = "[UH-1Y VENOM]",
	["Venom_coop"] = "[UH-1Y VENOM]",
	["Villa_SUV"] = "[SUV]",
	["Wz11_SP_Paris"] = "[Z-11W]",
	["2S25_SPRUT-SD"] = "[SPRUT-SD]",
	["AC130"] = "[GUNSHIP]",
	["HIMARS"] = "[M142]",
	["M1128-Stryker"] = "[M1128]",
	["QuadBike"] = "[QUAD BIKE]",
	["STAR_1466"] = "[BM-23]",
	["HumveeModified"] = "[PHOENIX]",
	["VanModified"] = "[RHINO]",
	["VodnikModified_V2"] = "[BARSUK]",
	["C130"] = "[GUNSHIP]",
	["Humvee_ASRAD"] = "[HMMWV ASRAD]",
	["KLR650"] = "[DIRTBIKE]",
	["LAV25_Paradrop"] = "[LAV-25]",
	["VodnikPhoenix"] = "[VODNIK AA]",
	["BTR90"] = "[BTR-90]",
	["DPV"] = "[DPV]",
	["F35B"] = "[F-35]",
	["SkidLoader"] = "[SKID LOADER]",
	["Z-11w"] = "[Z-11W]",
	    
}

Events:Subscribe('Player:Chat', function(player, recipientMask, message)
command, arg = message:match("%s*/(.-)%s+(.*)%s*$")
if command == 'AT'  then
if contains(admin,'Doc-Ice-Elm') then
airstrike =true
NetEvents:SendTo('LMattack',player,arg)

--NetEvents:Broadcast('AdminYell',{arg,10})
else
RCON:SendCommand("admin.say", {"ERROR: You are not an Admin 😜", player.name})
end
end
if message == '/pt' then
pwleftx = player.soldier.worldTransform.trans.x
pwupy = player.soldier.worldTransform.trans.y
pwforwardz = player.soldier.worldTransform.trans.z

ChatManager:Yell('check server console for cords', 2.5)
end
end)
NetEvents:Subscribe('Airstrike:Yell', function(player,args)
local playername=args[1]
local delay=math.floor(args[2])
local message=args[3]
RCON:SendCommand("VUyell",{playername,tostring(delay),message})
end)

NetEvents:Subscribe('Airstrike:print', function(player, args)
print(args[1])
end)
NetEvents:Subscribe('Airstrike:Sound', function(player,sound,volume)
NetEvents:Broadcast('Psound',sound,volume)
end)
local mortarPartitionGuid = Guid('5350B268-18C9-11E0-B820-CD6C272E4FCC')
local customBlueprintGuid = Guid('D407033B-49AE-DF14-FE19-FC776AE04E2C')
NetEvents:Subscribe('Airstrike:Launch', function(player, position)
	position.y = position.y + 200

	local launchTransform = LinearTransform(
		Vec3(0,  0, -1),
		Vec3(1,  0,  0),
		Vec3(0, -1,  0),
		position
	)

	local params = EntityCreationParams()
	params.transform = launchTransform
	params.networked = true

	local projectileBlueprint = ResourceManager:FindInstanceByGuid(mortarPartitionGuid, customBlueprintGuid)

	local projectileEntityBus = EntityManager:CreateEntitiesFromBlueprint(projectileBlueprint, params)

	for _,entity in pairs(projectileEntityBus.entities) do

		entity:Init(Realm.Realm_ClientAndServer, true)
	end
end)
function contains(tbl, val)
   for i=1,#tbl do
      if tbl[i] == val then 
         return true
      end
   end
   return false
end
Events:Subscribe('Player:Killed', function(player, inflictor, position, weapon, isRoadKill, isHeadShot, wasVictimInReviveState, info)
if inflictor ~= nil and inflictor.controlledControllable ~= nil and inflictor.controlledControllable.data:Is("VehicleEntityData") then
kt=vehicleTable[VehicleEntityData(inflictor.controlledControllable.data).controllableType:gsub(".+/.+/","")]

end


if info.weaponUnlock ~= nil then
kv=weaponTable[_G[info.weaponUnlock.typeInfo.name](info.weaponUnlock).debugUnlockId]
end
if player ~= nil then
Player_Id=player_exists(data, player.name)
if Player_Id then
data:AddPlayerKill(Player_Id)
data[Player_Id].kills=0
else
data:AddNewPlayer(player.name)
end
end

if inflictor ~= nil then
inflictor_Id=player_exists(data, inflictor.name)
if inflictor_Id then
data:AddPlayerKill(inflictor_Id)
if isBot(inflictor.name) and data:GetPlayerKills(inflictor_Id)>botkillsneeded then
OnUpdate()
local rnd = math.random(1,#m_Objectives-1)
xp=(m_Objectives[rnd].position[1])
yp=(m_Objectives[rnd].position[3])
NetEvents:Broadcast('Psound',{'ogg/JetFlyBy.ogg',500})
AreaStrike( Vec3(m_Objectives[rnd].position[1],m_Objectives[rnd].position[2],m_Objectives[rnd].position[3]))
zones[#zones+1] = { position = pointOfAim.position, points = {}, timer = STRIKE_DURATION + MISSILE_AIRTIME}
data[inflictor_Id].kills=0
end
else
data:AddNewPlayer(inflictor.name)
data:AddPlayerKill(inflictor)
end
if not isBot(inflictor.name) then
NetEvents:Broadcast('pk',{inflictor.name})
end
end


end)
function isBot(p_Player)
	if type(p_Player) == 'string' then
		p_Player = PlayerManager:GetPlayerByName(p_Player)
	end

	if type(p_Player) == 'number' then
		p_Player = PlayerManager:GetPlayerById(p_Player)

		if p_Player == nil then
			p_Player = PlayerManager:GetPlayerByOnlineId(p_Player)
		end
	end

	return p_Player ~= nil and p_Player.onlineId == 0
end


Events:Subscribe('CapturePoint:Captured', function(capturePoint)
 CapturePoint = CapturePointEntity(capturePoint)
end)
---VEXT Server CapturePoint:Captured Event
---@param p_CapturePoint CapturePointEntity|Entity
function OnCapturePointCaptured(p_CapturePoint)
	p_CapturePoint = CapturePointEntity(p_CapturePoint)
	    Flagtrans= p_CapturePoint.transform.trans
	    Flag = p_CapturePoint.name
		team = p_CapturePoint.team
		isAttacked = p_CapturePoint.isAttacked
		
end

---VEXT Server CapturePoint:Lost Event
---@param p_CapturePoint CapturePointEntity|Entity
function OnCapturePointLost(p_CapturePoint)
	p_CapturePoint = CapturePointEntity(p_CapturePoint)
	local s_ObjectiveName = self:_TranslateObjective(p_CapturePoint.transform.trans, p_CapturePoint.name)
	local s_IsAttacked = p_CapturePoint.flagLocation < 100.0 and p_CapturePoint.isControlled
	self:_UpdateObjective(s_ObjectiveName, {
		team = TeamId.TeamNeutral, --p_CapturePoint.team
		isAttacked = s_IsAttacked
	})
end

function player_exists(tbl, str)
records=#tbl
for i = 1,records,1 do
    
            if tbl[i].name == tostring(str) then
                return i
        end
 end
return false
end
function data:AddNewPlayer(n)
  data[#data+1] = {
      name = n,
    weapon = 'ak',
    kills = 0,
    deaths = 0
  }
  return #data -- returns player id
end
function data:AddPlayerKill(playerId)
  if playerId and type(playerId)=="number" then
    if data[playerId] then
      self[playerId].kills = self[playerId].kills + 1 -- self is data table and self[playerId] is data[given id], So we add 1 new kill.
      return true
    end
    return false
  end
  return false
end

function data:GetPlayerKills(playerId)
  if playerId and type(playerId)=="number" then
    if data[playerId] then
      return data[playerId].kills
    end
    return false
  end
  return false
end


function data:AddPlayerDeath(playerId)
  if playerId and type(playerId)=="number" then
    if data[playerId] then
      self[playerId].deaths = self[playerId].deaths + 1 -- self is data table and self[playerId] is data[given id], So we add 1 new death.
      return true
    end
    return false
  end
  return false
end

function data:GetPlayerDeaths(playerId)
  if playerId and type(playerId)=="number" then
    if data[playerId] then
      return data[playerId].deaths
    end
    return false
  end
  return false
end


function data:SetPlayerWeapon(playerId,newWeapon)
  if playerId and type(playerId)=="number" then
    if data[playerId] then
      if newWeapon and type(newWeapon)=="string" then
        data[playerId].weapon = newWeapon
        return true
      end
      return false
    end
    return false
  end
  return false
end

function data:GetPlayerWeapon(playerId)
  if playerId and type(playerId)=="number" then
    if data[playerId] then
      return data[playerId].weapon
    end
    return false
  end
  return false
end
function inside()
local s_Iterator = EntityManager:GetIterator('ServerCapturePointEntity')
if s_Iterator.name == 'A' then
print(s_Iterator.playersInside)
end
end

function OnUpdate()

 local s_ObjectiveIndex = 1
    local s_ObjectiveCounter = 1
  local s_Iterator = EntityManager:GetIterator('ServerCapturePointEntity')
   
	if s_Iterator ~= nil then
        local s_Entity = s_Iterator:Next()

	
        while s_Entity ~= nil do
            local s_CaptureEntity = CapturePointEntity(s_Entity)

            local s_Data = CapturePointEntityData(s_CaptureEntity.data)

            if s_Data.capturableType ~= CapturableType.CTUnableToChangeTeam then
                local s_Contested = s_CaptureEntity.attackingTeam > 0
                local s_Team = s_CaptureEntity.team

                if not s_CaptureEntity.controlled then
                    s_Team = TeamId.TeamNeutral
                end
				
                
				local s_Label = s_CaptureEntity.name
				local p_inside = s_CaptureEntity.playersInside
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
							psinside = p_inside,
                            currentTeam = s_Team,
							contested = s_Contested,
                            position = { s_Transform.x, s_Transform.y, s_Transform.z }
                        }
			
                    index = s_ObjectiveIndex - 1 
                end

                m_Objectives[s_ObjectiveIndex] = {
                    label = s_Label,
					psinside = p_inside,
                    currentTeam = s_Team,
                    contested = s_Contested,
                    position = { s_Transform.x, s_Transform.y, s_Transform.z }
                }	  
            
        end
		s_Entity = s_Iterator:Next()
	end
		
	end
	end
	
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
Events:Subscribe('Player:Update', function(player, deltaTime)
cumulateTime = cumulateTime + deltaTime
	if cumulateTime >= playerUpdate then
		cumulateTime = 0
OnUpdate()
ptid=0
if player ~= nil then
if player.teamId ==1 then ptid=2 elseif player.teamId ==2 then ptid=1 end
--g=capturepointcheck(m_Objectives, ptid)
if g then
--print(player..','..g)
end
end
end

end)

function AirstrikeLaunch(position)

	position.y = position.y + 200

	local launchTransform = LinearTransform(
		Vec3(0,  0, -1),
		Vec3(1,  0,  0),
		Vec3(0, -1,  0),
		position
	)

	local params = EntityCreationParams()
	params.transform = launchTransform
	params.networked = true

	local projectileBlueprint = ResourceManager:FindInstanceByGuid(mortarPartitionGuid, customBlueprintGuid)

	local projectileEntityBus = EntityManager:CreateEntitiesFromBlueprint(projectileBlueprint, params)

	for _,entity in pairs(projectileEntityBus.entities) do

		entity:Init(Realm.Realm_ClientAndServer, true)
	end
end
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

			AirstrikeLaunch(pending[i].position)
			

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