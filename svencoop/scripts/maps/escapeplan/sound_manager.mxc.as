namespace FuncPayload
{
  enum eSoundState
  {
    PLAYING,
    STOPPED
  };

  const int INITIAL_PITCH = 60;
  const int MAX_PITCH = 200;
  const int APPROX_MAX_SPEED = 1000;

  /**
   * Sound Manager
   *  Responsible for caching, playing, stopping, and other operations involving sound.
   */
  mixin class MXCSoundManager
  {
    eSoundState currentSoundState = STOPPED;
    string szStopSound = "plats/ttrain_brake1.wav";

    void PrecacheSounds()
    {
      if (m_flVolume == 0.0)
        m_flVolume = 1.0;

      switch (m_sounds)
      {
        case 1: pev.noise = "plats/ttrain1.wav"; break;
        case 2: pev.noise = "plats/ttrain2.wav"; break;
        case 3: pev.noise = "plats/ttrain3.wav"; break;
        case 4: pev.noise = "plats/ttrain4.wav"; break;
        case 5: pev.noise = "plats/ttrain6.wav"; break;
        case 6: pev.noise = "plats/ttrain7.wav"; break;
        default: pev.noise = ""; break;
      }

      switch (m_iStopSound)
      {
        case 1: szStopSound = "plats/bigstop1.wav"; break;
        case 2: szStopSound = "plats/bigstop1.wav"; break;
        case 3: szStopSound = "plats/freightstop1.wav"; break;
        case 4: szStopSound = "plats/heavystop1.wav"; break;
        case 5: szStopSound = "plats/rackstop1.wav"; break;
        case 6: szStopSound = "plats/railstop1.wav"; break;
        case 7: szStopSound = "plats/squeekstop1.wav"; break;
        case 8: szStopSound = "plats/heavystop2.wav"; break;
        default: szStopSound = ""; break;
      }

      if (pev.noise != "")
        g_SoundSystem.PrecacheSound(pev.noise);

      if (szStopSound != "")
        g_SoundSystem.PrecacheSound(szStopSound);
    }

    void StopSound()
    {
      if (NoSound() || currentSoundState == STOPPED)
        return;

      g_SoundSystem.StopSound(self.edict(), CHAN_STATIC, pev.noise);

      if (szStopSound != "")
        g_SoundSystem.EmitSoundDyn(self.edict(), CHAN_STATIC, szStopSound, m_flVolume, ATTN_NORM, 0, GetAdjustedPitch());

      currentSoundState = STOPPED;
    }

    void PlaySound()
    {
      if (NoSound() || currentSoundState == PLAYING)
        return;

      g_SoundSystem.EmitSoundDyn(self.edict(), CHAN_STATIC, pev.noise, m_flVolume, ATTN_NORM, SND_CHANGE_PITCH, GetAdjustedPitch());
      currentSoundState = PLAYING;
    }

    private bool NoSound()
    {
      return string(pev.noise).IsEmpty();
    }

    // NOTE: This method depends on the Movement Manager
    private int GetAdjustedPitch()
    {
      return int(INITIAL_PITCH + (abs(int(GetCurrentAdjustedSpeed())) * (MAX_PITCH - INITIAL_PITCH) / APPROX_MAX_SPEED));
    }
  }
}
