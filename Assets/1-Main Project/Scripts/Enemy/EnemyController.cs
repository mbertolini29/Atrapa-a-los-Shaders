using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;

public class EnemyController : MonoBehaviour
{
    [Header("Chase")]
    public float distanceToChase = 10f; //distancia para perserguir
    public float distanceToLose = 15f; //distancia donde lo pierde de vista
    public float distanceToStop = 5f; //distancia que para.
    bool chasing; //si esta persiguiendo o no..

    Vector3 targetPoint;
    Vector3 startPoint;
    
    [Header("AI")]
    public NavMeshAgent agent;
    //tiempo que el enemigo te va a perseguir antes de regresar a su sitio
    public float keepChasingTime = 5f;
    float chaseCounter; //contador-tiempo que el enemigo te persigue

    [Header("Enemy Bullet")]
    public GameObject enemyBullet;
    public Transform enemyFirePoint;
    public float fireRate; //velocidad del disparo
    public float waitBetweenShots = 2f; //tiempo entre disparo
    public float timeToShoot = 1f; //tiempo para disparar del enemigo

    float fireCount; //cuantas veces disparamos
    float shotWaitCounter; //cuanto tiempo vamos a esperar para el proximo disparo
    float shotTimeCounter; //tiempo disparamos.

    [Header("Animation")]
    public Animator anim;

    //si fue disparador
    bool wasShot;

    void Start()
    {
        startPoint = transform.position;

        shotTimeCounter = timeToShoot; //tiempo que tiene el enemigo para disparar
        shotWaitCounter = waitBetweenShots; //le pasas el tiempo que tiene que esperar
    }

    void Update()
    {
        targetPoint = PlayerController.instance.transform.position;
        targetPoint.y = transform.position.y;

        if(!chasing) //persiguiendo.
        {
            if (Vector3.Distance(transform.position, targetPoint) < distanceToChase)
            {
                chasing = true;

                shotTimeCounter = timeToShoot; //tiempo que tiene el enemigo para disparar
                shotWaitCounter = waitBetweenShots; //le pasas el tiempo que tiene que esperar
            }

            if (chaseCounter > 0)
            {
                chaseCounter -= Time.deltaTime;

                if(chaseCounter <= 0)
                {
                    agent.destination = startPoint;
                }
            }

            if(agent.remainingDistance < .25f)
            {
                anim.SetBool("isWalking", false);
            }
            else
            {
                anim.SetBool("isWalking", true);
            }
        }
        else
        {
            //transform.LookAt(targetPoint);
            //theRB.velocity = transform.forward * moveSpeed;

            //para que mire al jugador
            agent.destination = targetPoint;

            if (Vector3.Distance(transform.position, targetPoint) > distanceToLose)
            {
                if(!wasShot) //si no le dispararon el enemigo, no te persigue..
                {
                    chasing = false;
                }

                //cuando te alejas lo suficiente, el enemigo vuelve a su lugar.
                chaseCounter = keepChasingTime; 
            }
            else
            {
                wasShot = false;
            }

            if (shotWaitCounter > 0) //tiempo de espera del disparo
            {
                shotWaitCounter -= Time.deltaTime;

                if (shotWaitCounter <= 0)
                {
                    shotTimeCounter = timeToShoot; //esto indicaria que podes disparar..
                }

                anim.SetBool("isWalking", true);
            }
            else //tiempo de disparo
            {
                if (PlayerController.instance.gameObject.activeInHierarchy) 
                {
                    shotTimeCounter -= Time.deltaTime;

                    if (shotTimeCounter > 0)
                    {
                        fireCount -= Time.deltaTime; //conteo

                        if (fireCount <= 0) //seria que llego al tiempo para disparar.
                        {
                            fireCount = fireRate; //tiempo entre disparo (reinicia el tiempo / el conteo)

                            //antes de instanciar las balas, encontramos la posicion del personaje, para q sea mas real el disparo.
                            enemyFirePoint.LookAt(PlayerController.instance.transform.position + new Vector3(0f, 1.5f, 0f));

                            //chequeamos el angulo del jugador..
                            Vector3 targetDir = PlayerController.instance.transform.position - transform.position;
                            float angle = Vector3.SignedAngle(targetDir, transform.forward, Vector3.up);

                            if (Mathf.Abs(angle) < 30f)
                            {
                                Instantiate(enemyBullet, enemyFirePoint.position, enemyFirePoint.rotation);

                                anim.SetTrigger("fireShot");
                            }
                            else
                            {
                                shotWaitCounter = waitBetweenShots;
                            }
                        }

                        agent.destination = transform.position;
                    }
                    else
                    {
                        shotWaitCounter = waitBetweenShots;
                    }

                    anim.SetBool("isWalking", false);
                }                 
            }
        }
    }

    public void GetShot()
    {
        wasShot = true;
        chasing = true; //para que lo persiga
    }
}

