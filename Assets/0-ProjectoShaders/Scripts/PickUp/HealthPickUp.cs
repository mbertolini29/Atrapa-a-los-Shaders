using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class HealthPickUp : MonoBehaviour
{
    public int healthAmount; //10
    bool isCollected;

    private void OnTriggerEnter(Collider other)
    {
        if(other.tag == "Player" && !isCollected)
        {
            PlayerHealthController.instance.HealthPlayer(healthAmount);

            Destroy(gameObject);

            isCollected = true;

            AudioManager.instance.PlaySFX((int)fxSound.pickupHealth);
        }
    }
}
