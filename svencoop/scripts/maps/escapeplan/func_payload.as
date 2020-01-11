#include "keyvals.mxc"
#include "in_range_manager.mxc"
#include "movement_manager.mxc"
#include "sound_manager.mxc"
#include "trigger_payload_mode"

namespace FuncPayload
{
  const float THINK_TIME = 0.1;
  enum ePayloadState
  {
    NORMAL,
    FORCE_MOVE,
    FORCE_WAIT
  };

  class CFuncPayload : ScriptBaseEntity, MXCFuncPayloadKeyVals, MXCInRangeManager, MXCMovementManager, MXCSoundManager
  {
    ePayloadState currentPayloadState = NORMAL;

    void Spawn()
    {
      pev.velocity = g_vecZero;
      pev.avelocity = g_vecZero;
      pev.solid = SOLID_BSP;
      pev.movetype = MOVETYPE_PUSH;

      g_EntityFuncs.SetModel(self, pev.model);
      g_EntityFuncs.SetSize(pev, pev.mins, pev.maxs);
      g_EntityFuncs.SetOrigin(self, pev.origin);

      Precache();
      MovePayloadToFirstTarget();
      SetMaxSpeed(m_flMaxSpeed);
      SetSpeed(m_flStartSpeed);
      SetThink(ThinkFunction(this.Find));
      NextThink(pev.ltime + THINK_TIME, false);
    }

    void Precache()
    {
      PrecacheSounds();
    }

    void Use(CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float value)
    {
      currentPayloadState = ePayloadState(int(value));
    }

    void Find()
    {
      bool isContested = false;
      bool isAssisted = false;
      uint uiNumberAssisting = 0;

      CBaseEntity@ pEnt = null;
      while((@pEnt = g_EntityFuncs.FindEntityInSphere(pEnt, pev.origin, m_iDetectionRadius, "*", "classname")) !is null) {
        if (pEnt is null || !pEnt.IsAlive())
          continue;

        CBaseMonster@ pMonster = cast<CBaseMonster@>(pEnt);
        const int relationship = self.IRelationship(pMonster);

        if (IsAlly(relationship))
        {
          HandleEntityInRange(pMonster, true);
          isAssisted = true;
          uiNumberAssisting += 1;
          continue;
        }

        if (IsEnemy(relationship))
        {
          HandleEntityInRange(pMonster, false);
          isContested = true;
          continue;
        }
      }

      // NOTE: This must happen before calling Next()
      UpdateSpeedMultiplier(uiNumberAssisting);

      if (ShouldMove(isContested, isAssisted))
      {
        Next();
        PlaySound();
      }
      else
      {
        StopMoving();
        StopSound();
      }

      CleanUp();
      NextThink(pev.ltime + THINK_TIME, false);
    }

    private bool ShouldMove(bool isContested, bool isAssisted)
    {
      return currentPayloadState != FORCE_WAIT && (currentPayloadState == FORCE_MOVE || (!isContested && isAssisted));
    }

    private void UpdateSpeedMultiplier(uint uiNumberAssisting)
    {
      if (uiNumberAssisting <= 1)
      {
        SetSpeedMultiplier(1);
        return;
      }

      uint uiAdjustBy = (uiNumberAssisting >= m_uiSpeedMultiplierMax) ?
        m_uiSpeedMultiplierMax : uiNumberAssisting;

      float flNewMultiplier = (m_flSpeedMultiplier * uiAdjustBy) + 1;
      SetSpeedMultiplier(flNewMultiplier);
    }

    private bool IsAlly(int relationship)
    {
      return relationship == R_AL;
    }

    private bool IsEnemy(int relationship)
    {
      return relationship > 0;
    }

    private void NextThink(float thinkTime, const bool alwaysThink)
    {
      alwaysThink ? pev.flags |= FL_ALWAYSTHINK : pev.flags &= ~FL_ALWAYSTHINK;
      pev.nextthink = thinkTime;
    }
  }

  void Register()
  {
    g_CustomEntityFuncs.RegisterCustomEntity("FuncPayload::CFuncPayload", "func_payload");
    g_CustomEntityFuncs.RegisterCustomEntity("FuncPayload::CTriggerPayloadMode", "trigger_payload_mode");
  }
}
