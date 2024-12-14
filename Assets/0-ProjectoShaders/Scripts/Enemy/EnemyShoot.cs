using System;
using UnityEngine;

public class EnemyShoot : MonoBehaviour
{
    public Material enemyMaterial;
    public GameObject projectilePrefab;
    public float shootForce = 10f;
    
    public Transform player;
    public Transform shootPoint;

    public float visionDistance = 15f;
    public float visionAngle = 45f;

    public LayerMask obstacleMask;
    public LayerMask playerMask;

    private float shootTimer = 0f;
    public float shootInterval = 2f;
    public float rotationSpeed = 5f;

    public bool canSeePlayer;

    void Start()
    {
        //if (enemyMaterial != null && GetComponent<Renderer>() != null)
        //{
        //    enemyMaterial = GetComponent<Renderer>().material;
        //}
    }

    public void Update()
    {
        CheckLineOfSight();

        if (canSeePlayer)
        {
            shootTimer += Time.deltaTime;
            
            RotateTowardsPlayer();

            if(shootTimer >= shootInterval)
            {
                Shoot();
                shootTimer = 0f;
            }
        }

    }

    private void RotateTowardsPlayer()
    {
        if (transform.parent != null)
        {
            // Calcula la dirección hacia el jugador
            Vector3 directionToPlayer = (player.position - transform.position).normalized;

            // Calcula la rotación necesaria para mirar al jugador
            Quaternion targetRotation = Quaternion.LookRotation(new Vector3             (directionToPlayer.x,
                                                    0f,
                                                    directionToPlayer.z));

            // Suaviza el giro del enemigo
            transform.parent.rotation = Quaternion.Slerp(transform.parent.rotation,
                                                         targetRotation,
                                                         Time.deltaTime * rotationSpeed);
        }   
    }

    private void CheckLineOfSight()
    {
        // Calcula la dirección hacia el jugador
        Vector3 directionToPlayer = (player.position - transform.position).normalized;

        // Distancia al jugador
        float distanceToPlayer = Vector3.Distance(transform.position, player.position);

        // Comprueba si el jugador está dentro del rango de visión
        float angleToPlayer = Vector3.Angle(transform.forward, directionToPlayer);

        // Levantar la posición del Raycast (opcional, para mayor precisión)
        Vector3 rayOrigin = transform.position + Vector3.up * 1.5f;

        // Dibuja el Raycast para depuración (lo verás en la vista de escena)
        Debug.DrawRay(rayOrigin, directionToPlayer * visionDistance, Color.red, 0.1f);

        // Condición: Dentro del rango de visión y el ángulo
        if (distanceToPlayer <= visionDistance && angleToPlayer <= visionAngle)
        {
            // Lanza un raycast hacia el jugador
            if (Physics.Raycast(rayOrigin, directionToPlayer, out RaycastHit hit, distanceToPlayer, obstacleMask | playerMask))
            {
                // Comprueba si el raycast golpea al jugador
                if (hit.collider.CompareTag("Player"))
                {
                    canSeePlayer = true; // Jugador visible
                    Debug.Log("Jugador detectado");
                    return; // Sale de la función porque ya lo ha detectado
                }
                else
                {
                    Debug.Log("Jugador bloqueado por: " + hit.collider.name);
                }
            }
        }

        // Si no cumple las condiciones o hay un obstáculo, no ve al jugador
        canSeePlayer = false;
    }

    public void Shoot()
    {
        if(projectilePrefab != null && shootPoint !=null)
        {
            GameObject projectile = Instantiate(projectilePrefab, shootPoint.position, shootPoint.rotation);

            //Renderer projectileRenderer = projectile.GetComponent<Renderer>();
            //if (projectileRenderer != null && enemyMaterial != null)
            //{
            //    projectileRenderer.material = new Material(enemyMaterial);
            //}

            // Aplicar fuerza al proyectil
            Rigidbody rb = projectile.GetComponent<Rigidbody>();
            if (rb != null)
            {
                rb.AddForce(shootPoint.forward * shootForce, ForceMode.Impulse);
            }
        }
    }


}
