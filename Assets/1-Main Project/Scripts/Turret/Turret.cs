using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Turret : MonoBehaviour
{
    public GameObject bullet;

    public float rangeToTargetPlayer = 5f;
    public float timeBetweenShots = .5f;
    
    float shotCounter;

    public Transform gun;
    public Transform firePoint;

    public float rotateSpeed = 1f;

    void Start()
    {
        shotCounter = timeBetweenShots;
    }

    void Update()
    {
        if(!GameManager.instance.levelEnding)
        {
            if (Vector3.Distance(transform.position, PlayerController.instance.transform.position) < rangeToTargetPlayer)
            {
                gun.LookAt(PlayerController.instance.transform.position + new Vector3(0f, 0.5f, 0f));

                shotCounter -= Time.deltaTime;

                if (shotCounter <= 0)
                {
                    Instantiate(bullet, firePoint.position, firePoint.rotation);
                    shotCounter = timeBetweenShots;
                }
            }
            else
            {
                shotCounter = timeBetweenShots;

                gun.rotation = Quaternion.Lerp(gun.rotation, Quaternion.Euler(0f, gun.rotation.eulerAngles.y + 10f, 0f), rotateSpeed * Time.deltaTime);
            }
        }  
    }
}