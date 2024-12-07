using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BulletController : MonoBehaviour
{
    [Header("Bullet")]
    public Rigidbody theRB;
    public float moveSpeed;
    public float lifeTime;

    [Header("Damage")]
    public int damageBullet = 10;
    public bool damageEnemy;
    public bool damagePlayer;

    [Header("Particles")]
    public GameObject impactEffect;

    void Start()
    {
        
    }

    void Update()
    {
        theRB.linearVelocity = transform.forward * moveSpeed;

        lifeTime -= Time.deltaTime;

        if(lifeTime <= 0)
        {
            Destroy(gameObject);
        }
    }

    private void OnTriggerEnter(Collider other)
    {
        if(other.gameObject.tag == "Enemy" && damageEnemy)
        {
            other.gameObject.GetComponent<EnemyHealthController>().DamageEnemy(damageBullet);
        }
        
        if(other.gameObject.tag == "HeadShot" && damageEnemy)
        {
            other.transform.parent.GetComponent<EnemyHealthController>().DamageEnemy(damageBullet * 2);
            //Debug.Log("Headshot");
        }

        if (other.gameObject.tag == "Player" && damagePlayer)
        {
            PlayerHealthController.instance.DamagePlayer(damageBullet);
            //Debug.Log("hit player: " + transform.position);
        }

        Destroy(gameObject);

        Instantiate(impactEffect, transform.position + (transform.forward * (-moveSpeed * Time.deltaTime)), transform.rotation);
    }
}
