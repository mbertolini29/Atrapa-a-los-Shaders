using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Explosion : MonoBehaviour
{
    [Header("Damage")]
    public int damageBullet = 10;
    public bool damageEnemy;
    public bool damagePlayer;

    private void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.tag == "Enemy" && damageEnemy)
        {
            other.gameObject.GetComponent<EnemyHealthController>().DamageEnemy(damageBullet);
        }

        if (other.gameObject.tag == "Player" && damagePlayer)
        {
            PlayerHealthController.instance.DamagePlayer(damageBullet);
            //Debug.Log("hit player: " + transform.position);
        }
    }
}
