#include "func_payload"
#include "WeaponSwitch"
EHandle lastSpawnSpot = null;
float lastSpawn;
array<Vector> respawnSlots = {Vector(-1022, 2947, 2894), Vector(-970, 2876, 2894), Vector(-901, 2937, 2894), Vector(-810, 2867, 2894), Vector(-747, 2932, 2893), Vector(-681, 2867, 2893)};
string musicToPlay = "";
bool isStarted = false;
void MapInit(){
  FuncPayload::Register();
  g_Hooks.RegisterHook(Hooks::Player::PlayerSpawn, @PlayerSpawn);
  for(int i=0; i<g_Engine.maxClients; i++){
    primaryWeapons[i] = "";
    secondaryWeapons[i] = "";
    inPlanningPhase[i] = true;
  }
  @RefreshHUDTimer = g_Scheduler.SetInterval("timer_refreshHUD", 1, g_Scheduler.REPEAT_INFINITE_TIMES);
}

void MapActivate(){
  CBaseEntity@ pWeapon = null;
  while((@pWeapon = g_EntityFuncs.FindEntityByClassname(pWeapon, "weapon_*")) !is null){
    pWeapon.pev.rendermode = kRenderNormal;
    pWeapon.pev.renderfx = kRenderFxGlowShell;
    pWeapon.pev.renderamt = 8;
    pWeapon.pev.rendercolor = Vector(255, 255, 0);
  }
}

HookReturnCode PlayerSpawn(CBasePlayer@ pPlayer){
  for(int i = 0; i < 20; i++){
    if(i != g_PlayerFuncs.GetAmmoIndex("ARgrenades")){
      pPlayer.SetMaxAmmo(i, 30000);
      pPlayer.m_rgAmmo(i, 30000);
    }
  }
  inPlanningPhase[getPlayerIndex(pPlayer) - 1] = true;
  return HOOK_HANDLED;
}

void TriggerEnding(bool success){
  CBaseEntity@ pEndingCam;
  if(success){
    @pEndingCam = g_EntityFuncs.FindEntityByTargetname(null, "game_endgame");
  }else{
    @pEndingCam = g_EntityFuncs.FindEntityByTargetname(null, "cam_endgame");
  }
  CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex(1);
  if(pPlayer !is null){
    transferPlayers();
    pEndingCam.Use(pPlayer, pPlayer, USE_ON, 0);
  }
}

void transferPlayers(){
  int indexToUse = 0;
  for(int i = 1; i <= g_Engine.maxClients; i++){
    CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex(i);
    if(pPlayer !is null && pPlayer.IsAlive() && pPlayer.pev.deadflag != DEAD_DYING && indexToUse <= (int(respawnSlots.length()) - 1)){
      pPlayer.pev.origin = respawnSlots[indexToUse];
      indexToUse += 1;
    }
  }
}

void spawnEnemy(){
  int spawnFactor;
  int playerCount = int(g_PlayerFuncs.GetNumPlayers());
  if(playerCount <= 4){
    spawnFactor = int(Math.Ceil(1 + (playerCount/2)));
  }else{
    spawnFactor = int(Math.Ceil(2 + (playerCount/4)));
  }
  if((g_Engine.time - lastSpawn) >= 1.6){
    for(int i = 1; i <= spawnFactor; i++){
      CBaseEntity@ spawnSpot = lastSpawnSpot;
      CBaseEntity@ pPushCar = g_EntityFuncs.FindEntityByClassname(null, "func_payload");
      @spawnSpot = g_EntityFuncs.FindEntityInSphere(spawnSpot, pPushCar.pev.origin, 1500, "env_xenmaker", "classname");
      if(spawnSpot is null){
        @spawnSpot = g_EntityFuncs.FindEntityInSphere(spawnSpot, pPushCar.pev.origin, 800, "env_xenmaker", "classname");
      }
      lastSpawnSpot = spawnSpot;
      CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex(1);
      if(spawnSpot !is null && pPlayer !is null){
        spawnSpot.Use(pPlayer, pPlayer, USE_ON, 0);
      }
      lastSpawn = g_Engine.time;
    }
  }
}
