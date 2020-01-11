namespace FuncPayload
{
  class CTriggerPayloadMode : ScriptBaseEntity
  {
    float m_iMovementState;

    bool KeyValue(const string & in szKey, const string & in szValue)
    {
      if (szKey == "iMovementState")
      {
        m_iMovementState = atof(szValue);
        return true;
      }

      return BaseClass.KeyValue(szKey, szValue);
    }

    void Use(CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float value)
    {
      CBaseEntity@ pTargetPayload = g_EntityFuncs.FindEntityByTargetname(null, pev.target);
      if (pTargetPayload is null)
      {
        g_Game.AlertMessage(at_error, "Could not find target payload!\n");
        return;
      }

      pTargetPayload.Use(self, self, USE_SET, m_iMovementState);
    }
  }
}
