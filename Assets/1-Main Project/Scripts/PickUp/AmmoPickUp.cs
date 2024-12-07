using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AmmoPickUp : MonoBehaviour
{
    bool collected;

    private void OnTriggerEnter(Collider other)
    {
        if(other.tag == "Player" && !collected)
        {
            //Dar municion
            PlayerController.instance.activeGun.GetAmmo();

            Destroy(gameObject);

            collected = true;

            AudioManager.instance.PlaySFX((int)fxSound.pickupWeaponM);
        }
    }
}
