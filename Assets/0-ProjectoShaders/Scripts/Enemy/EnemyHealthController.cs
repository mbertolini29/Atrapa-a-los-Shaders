using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EnemyHealthController : MonoBehaviour
{
    public int currentHealth = 2;

    public EnemyController theEC; //para saber si tiene un libreto de enemy controller

    public GameObject spiritPrefab;

    void Start()
    {
        
    }

    void Update()
    {
        
    }

    public void DamageEnemy(int damageAmount)
    {
        currentHealth -= damageAmount;

        //if(theEC != null)
        //{
        //    theEC.GetShot();
        //}

        if(currentHealth <= 0)
        {
            //instanciar espiritu
            if(spiritPrefab != null)
            {
                Instantiate(spiritPrefab, spiritPrefab.transform.position, spiritPrefab.transform.rotation);
            }

            //
            Destroy(gameObject);

            //AudioManager.instance.PlaySFX((int)fxSound.damageEnemy); //muerte
        }
    }
}
