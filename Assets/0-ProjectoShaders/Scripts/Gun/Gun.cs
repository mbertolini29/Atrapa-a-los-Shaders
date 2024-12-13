using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Gun : MonoBehaviour
{
    [Header("Bullet")]
    public GameObject bullet;
    public Transform firePoint;

    [Header("Zoom")]
    public float zoomAmount;

    [Header("Shot")]
    public bool canAutoFire; 
    public float fireRate; //tiempo de disparo..
    [HideInInspector]
    public float fireCounter; //cuantos disparos por segundo..

    [Header("Ammunition")]
    public int maxAmmo;
    public int currentAmmo;
    public int pickupAmount; //cant recogida

    [Header("GunName")]
    public string gunName;

    void Start()
    {
        
    }

    void Update()
    {
        if(fireCounter > 0)
        {
            fireCounter -= Time.deltaTime;
        }
    }

    public void GetAmmo()
    {
        currentAmmo += pickupAmount;

        if (currentAmmo >= maxAmmo)
        {
            currentAmmo = maxAmmo;
        }

        //UIController.instance.ammoText.text = currentAmmo + "/" + maxAmmo;
    }
}
