using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EnemyHealthController : MonoBehaviour
{
    public int currentHealth = 5;

    public EnemyController theEC; //para saber si tiene un libreto de enemy controller

    void Start()
    {
        
    }

    void Update()
    {
        
    }

    public void DamageEnemy(int damageAmount)
    {
        currentHealth -= damageAmount;

        if(theEC != null)
        {
            theEC.GetShot();
        }

        if(currentHealth <= 0)
        {
            Destroy(gameObject);

            AudioManager.instance.PlaySFX((int)fxSound.damageEnemy); //muerte
        }
    }
}
