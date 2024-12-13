using UnityEngine;

public class SpiritController : MonoBehaviour
{
    public int spritValue = 1;

    private void OnTriggerEnter(Collider other)
    {
        // 
        if(other.CompareTag("Player"))
        {
            // Incrementar puntaje. 
            PlayerController player = other.GetComponent<PlayerController>();
            if (player != null)
            {
                player.CollectSpirit(spritValue);

                // Reproducir un efecto visual
                //Instantiate(collectEffect, transform.position, Quaternion.identity);

                // Reproducir un sonido
                //AudioManager.instance.PlaySFX((int)fxSound.spiritCollected);

            }

            //
            Destroy(gameObject);

            // AudioManager.instance.PlaySFX((int)fxSound.spiritCollected);
        }

    }

}
