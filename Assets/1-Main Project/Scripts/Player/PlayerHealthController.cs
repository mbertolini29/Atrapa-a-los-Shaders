using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerHealthController : MonoBehaviour
{
    public static PlayerHealthController instance;

    public int maxHealth = 100;
    public int currentHealth = 0;
    float invincibleCounter = 0f;
    public float invincibleLength = 1f;

    void Awake()
    {
        instance = this;
    }

    private void Start()
    {
        currentHealth = maxHealth; //declaras la vida, ni bien arrancas 

        UIController.instance.healthSlider.maxValue = maxHealth;
        CurrentHealth(); //actualiza la vida
    }

    void Update()
    {
        if(invincibleCounter > 0 && !GameManager.instance.levelEnding)
        {
            invincibleCounter -= Time.deltaTime;
        }
    }

    public void DamagePlayer(int damageAmount)
    {
        if(invincibleCounter <= 0)
        {
            AudioManager.instance.PlaySFX((int)fxSound.damageTick2); //daño

            currentHealth -= damageAmount;

            UIController.instance.ShowDamage();

            if(currentHealth <= 0)
            {
                gameObject.SetActive(false);

                currentHealth = 0;

                GameManager.instance.PlayerDied(); //reinicia el juego.

                AudioManager.instance.StopBGM(); //para la musica
                //AudioManager.instance.PlaySFX((int)fxSound.damageTick); //muerte
                AudioManager.instance.StopSFX((int)fxSound.damageTick2); //daño
            }

            invincibleCounter = invincibleLength;

            CurrentHealth(); //actualiza la vida
        }
    }

    void CurrentHealth()
    {
        UIController.instance.healthSlider.value = currentHealth;
        UIController.instance.healthText.text = currentHealth + "/" + maxHealth;
    }

    public void HealthPlayer(int healthAmount)
    {
        currentHealth += healthAmount;

        if(currentHealth > maxHealth)
        {
            currentHealth = maxHealth;
        }

        CurrentHealth(); //actualiza la vida
    }
}
