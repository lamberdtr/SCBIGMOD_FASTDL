array<string> primaryWeapons(g_Engine.maxClients);
array<string> secondaryWeapons(g_Engine.maxClients);
array<bool> inPlanningPhase(g_Engine.maxClients);
CScheduledFunction@ RefreshHUDTimer;
void useMP5(CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue){
  CBasePlayer@ pPlayer = cast<CBasePlayer@>(pActivator);
  primaryWeapons[getPlayerIndex(pPlayer) - 1] = "weapon_9mmAR";
  updateWeaponHUD(pPlayer);
}
void useSPAS(CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue){
  CBasePlayer@ pPlayer = cast<CBasePlayer@>(pActivator);
  primaryWeapons[getPlayerIndex(pPlayer) - 1] = "weapon_shotgun";
  updateWeaponHUD(pPlayer);
}
void useCrossbow(CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue){
  CBasePlayer@ pPlayer = cast<CBasePlayer@>(pActivator);
  primaryWeapons[getPlayerIndex(pPlayer) - 1] = "weapon_crossbow";
  updateWeaponHUD(pPlayer);
}
void useM16(CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue){
  CBasePlayer@ pPlayer = cast<CBasePlayer@>(pActivator);
  primaryWeapons[getPlayerIndex(pPlayer) - 1] = "weapon_m16";
  updateWeaponHUD(pPlayer);
}
void useM40a1(CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue){
  CBasePlayer@ pPlayer = cast<CBasePlayer@>(pActivator);
  primaryWeapons[getPlayerIndex(pPlayer) - 1] = "weapon_sniperrifle";
  updateWeaponHUD(pPlayer);
}
void use9mm(CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue){
  CBasePlayer@ pPlayer = cast<CBasePlayer@>(pActivator);
  secondaryWeapons[getPlayerIndex(pPlayer) - 1] = "weapon_9mmhandgun";
  updateWeaponHUD(pPlayer);
}
void use357(CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue){
  CBasePlayer@ pPlayer = cast<CBasePlayer@>(pActivator);
  secondaryWeapons[getPlayerIndex(pPlayer) - 1] = "weapon_357";
  updateWeaponHUD(pPlayer);
}
void useDeagle(CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue){
  CBasePlayer@ pPlayer = cast<CBasePlayer@>(pActivator);  
  secondaryWeapons[getPlayerIndex(pPlayer) - 1] = "weapon_eagle";
  updateWeaponHUD(pPlayer);
}
void useUzi(CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue){
  CBasePlayer@ pPlayer = cast<CBasePlayer@>(pActivator);
  secondaryWeapons[getPlayerIndex(pPlayer) - 1] = "weapon_uzi";
  updateWeaponHUD(pPlayer);
}

int getPlayerIndex(CBasePlayer@ pPlayer){
  CBasePlayer@ cFindPlayerByName = null;
  int thisIndex;
  for(int i = 1; i <= g_Engine.maxClients; i++){
    @cFindPlayerByName = g_PlayerFuncs.FindPlayerByIndex(i);
    if(cFindPlayerByName is pPlayer){
      thisIndex = i;
      break;
    }
  }
  return thisIndex;
}

void updateWeaponHUD(CBasePlayer@ pPlayer){
  string primary = primaryWeapons[getPlayerIndex(pPlayer) - 1];
  string secondary = secondaryWeapons[getPlayerIndex(pPlayer) - 1];
  if(primary == ""){
    primary = "[N/A Primary]";
  }
  if(primary == "weapon_9mmAR"){
    primary = "MP5";
  }
  if(primary == "weapon_shotgun"){
    primary = "SPAS-12";
  }
  if(primary == "weapon_crossbow"){
    primary = "Crossbow";
  }
  if(primary == "weapon_m16"){
    primary = "M16";
  }
  if(primary == "weapon_sniperrifle"){
    primary = "M40a1";
  }
  if(secondary == ""){
    secondary = "[N/A Secondary]";
  }
  if(secondary == "weapon_9mmhandgun"){
    secondary = "Glock";
  }
  if(secondary == "weapon_357"){
    secondary = ".357 Revolver";
  }
  if(secondary == "weapon_eagle"){
    secondary = "Desert Eagle";
  }
  if(secondary == "weapon_uzi"){
    secondary = "Uzi";
  }
  g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCENTER, "Your build:\n" + primary + " + " + secondary);
}

void timer_refreshHUD(){
  for(int i=0; i<g_Engine.maxClients; i++){
    CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex(i + 1);
    if(pPlayer !is null && inPlanningPhase[i]){
      updateWeaponHUD(pPlayer);
    }
  }
}

void getInWarZone(CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue){
  CBasePlayer@ pPlayer = cast<CBasePlayer@>(pActivator);
  string primary = primaryWeapons[getPlayerIndex(pPlayer) - 1];
  string secondary = secondaryWeapons[getPlayerIndex(pPlayer) - 1];
  if(primary == "" || secondary == ""){
    g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCENTER, "Please choose both your weapons!");
    return;
  }
  for(int i=0; i<g_Engine.maxClients; i++){
    if(!inPlanningPhase[i]){
      CBasePlayer@ pEnt = g_PlayerFuncs.FindPlayerByIndex(i + 1);
      if(pEnt !is null){
        pPlayer.pev.origin = pEnt.pev.origin;
        pPlayer.pev.angles = pEnt.pev.angles;
        unstuckPlayer(pPlayer);
        inPlanningPhase[getPlayerIndex(pPlayer) - 1] = false;
        retrieveWeapon(pPlayer);
        break;
      }else{
        inPlanningPhase[i] = true;
        continue;
      }
    }
    if(i == g_Engine.maxClients-1){
      pPlayer.pev.origin = Vector(-2805, -3892, -3413);
      Vector vecTemp;
      vecTemp = pPlayer.pev.v_angle;
      vecTemp.y += 90;
      pPlayer.pev.angles = vecTemp;
      pPlayer.pev.fixangle = FAM_FORCEVIEWANGLES;
      unstuckPlayer(pPlayer);
      inPlanningPhase[getPlayerIndex(pPlayer) - 1] = false;
      retrieveWeapon(pPlayer);
    }
  }
}

void retrieveWeapon(CBasePlayer@ pPlayer){
  string primary = primaryWeapons[getPlayerIndex(pPlayer) - 1];
  string secondary = secondaryWeapons[getPlayerIndex(pPlayer) - 1];
  if(primary != "" && secondary != ""){
    pPlayer.GiveNamedItem(primary, 0, 0);
    pPlayer.GiveNamedItem(secondary, 0, 0);
    pPlayer.GiveNamedItem("weapon_medkit", 0, 0);
  }
}

void unstuckPlayer(CBasePlayer@ pPlayer){
  NetworkMessage msg(MSG_ONE, NetworkMessages::NetworkMessageType(9), pPlayer.edict());
  msg.WriteString("unstuck");
  msg.End();
}