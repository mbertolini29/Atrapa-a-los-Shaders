using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class WeaponPickUp : MonoBehaviour
{
    public string theGun;

    bool collected;

    private void OnTriggerEnter(Collider other)
    {
        if (other.tag == "Player" && !collected)
        {
            //Dar municion
            PlayerController.instance.AddGun(theGun);

            Destroy(gameObject);

            collected = true;

            //AudioManager.instance.PlaySFX((int)fxSound.);

        }
    }
}
