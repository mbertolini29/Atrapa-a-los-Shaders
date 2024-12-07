using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public enum fxSound { pickupHealth, pickupWeaponM, pickupWeaponSmall, jump, land, 
                      damageEnemy, damageTick, damageTick2, checkpoint, launcher }

public class AudioManager : MonoBehaviour
{
    public static AudioManager instance;

    public AudioSource bgm; //background music
    public AudioSource victory; // music

    public AudioSource[] soundEffects;

    private void Awake()
    {
        instance = this;
    }

    void Start()
    {
        
    }

    void Update()
    {
        
    }

    public void StopBGM()
    {
        bgm.Stop();
    }

    public void PlayLevelVictory()
    {
        StopBGM();
        victory.Play();
    }

    public void PlaySFX(int sfxNumber)
    {
        soundEffects[sfxNumber].Stop();
        soundEffects[sfxNumber].Play();
    }

    public void StopSFX(int sfxNumber)
    {
        soundEffects[sfxNumber].Stop();
    }
}
