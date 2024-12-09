using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerController : MonoBehaviour
{
    public static PlayerController instance;

    CharacterController charControl;
    Animator anim;

    [Header("Movement Controller")]
    public Vector3 moveInput;
    public float moveSpeed = 10f;
    public float runSpeed = 12f;
    bool isRunning;
    public float jumpPower = 10f;
    bool canJump, canDoubleJump;
    public Transform groundCheckPoint;
    public LayerMask whatIsGround;

    [Header("Gravity")]
    public float gravityModifier = 2;

    [Header("Camera Controller")]
    public Transform camTransform;
    public float mouseSensitivity = 1f;
    public bool invertX;
    public bool invertY;

    [Header("Gun")]
    public Gun activeGun;
    public int currentGun = 1;
    public List<Gun> allGuns = new List<Gun>();
    public List<Gun> unlockableGuns = new List<Gun>();

    [Header("Sight")] //mira
    public Transform adsPoint;
    public Transform gunHolder;
    Transform initialPosGunHolder;
    Vector3 gunStartPos;
    Vector3 gunStartRot;
    public float adsSpeed = 2f;

    public GameObject muzzleFlash;

    //public AudioSource footstepFast;
    public AudioSource footstepSlow;

    //para lanzar al aire al jugador
    float bounceAmount;
    bool bounce;

    //angulo maximo para mover la camara hacia arriba
    public float maxViewAngle = 60f;

    private void Awake()
    {
        instance = this;
    }

    void Start()
    {
        //camTransform = GetComponentInChildren<Camera>().transform;
        charControl = GetComponent<CharacterController>();
        anim = GetComponent<Animator>();

        //change weapon
        currentGun--;
        SwitchGun();

        gunStartPos = gunHolder.localPosition; //punto inicial del arma
        initialPosGunHolder = gunHolder; //para no perder la rotacion del arma
    }

    void Update()
    {
        if (!UIController.instance.pauseScreen.activeInHierarchy && !GameManager.instance.levelEnding)
        {
            //moveInput.x = Input.GetAxis("Horizontal") * moveSpeed * Time.deltaTime;
            //moveInput.z = Input.GetAxis("Vertical") * moveSpeed * Time.deltaTime;

            //guardar Y velocity
            float yStore = moveInput.y;

            //para que el movimiento y la camara se mueva en base al jugador,
            Vector3 verMove = transform.forward * Input.GetAxis("Vertical");
            Vector3 horiMove = transform.right * Input.GetAxis("Horizontal");

            MovePlayer(verMove, horiMove);
            RunPlayer();

            moveInput.y = yStore;

            //gravedad
            moveInput.y += Physics.gravity.y * gravityModifier * Time.deltaTime;
            if (charControl.isGrounded)
            {
                moveInput.y = Physics.gravity.y * gravityModifier * Time.deltaTime;
            }

            //esto indica q si el jugador esta tocando el piso puede saltar
            //este sirve para determinar en que capa podes saltar
            //pero depende mucho de la compu en la que jueges, y los fps
            //canJump = Physics.OverlapSphere(groundCheckPoint.position, .25f, whatIsGround).Length > 0;

            JumpPlayer();            

            //lanza al jugador para arriba
            if (bounce)
            {
                bounce = false;
                moveInput.y = bounceAmount;

                canDoubleJump = true;
            }

            charControl.Move(moveInput * Time.deltaTime);

            RotationPlayer();          

            //efecto estrella
            muzzleFlash.SetActive(false);

            Shooting();

            //cambiar de arma
            if (Input.GetButtonDown("Switch Gun"))
            {
                SwitchGun();
            }

            GunSight();           

            //magnitud de nuestro input, cuando agarramos fuerza en el eje
            anim.SetFloat("moveSpeed", moveInput.magnitude);
            anim.SetBool("onGround", canJump); //si puede saltar, esta en el piso..
        }        
    }

    void MovePlayer(Vector3 verMove, Vector3 horiMove)
    {
        moveInput = horiMove + verMove;
        moveInput.Normalize(); //para normalizar el movimiento, sino cuando apretas hacia delante y al costado, va en diagonal mas rapido que yendo de frente
    }

    void RunPlayer()
    {
        if (Input.GetButton("Run"))
        {
            moveInput *= runSpeed;
            isRunning = true;
            anim.SetBool("isRunning", isRunning); //esta corriendo..
        }
        else
        {
            moveInput *= moveSpeed;
            isRunning = false;
            anim.SetBool("isRunning", isRunning); //No esta corriendo..
        }
    }

    void JumpPlayer()
    {
        canJump = charControl.isGrounded;

        if (canJump) //si puede saltar, no puede hacer un doble salto
        {
            canDoubleJump = false;
        }

        //salto del jugador
        if (Input.GetButtonDown("Jump") && canJump) //KeyCode.Space
        {
            moveInput.y = jumpPower;

            //si salto, puede realizar otro salto
            canDoubleJump = true;

            AudioManager.instance.PlaySFX((int)fxSound.jump);
        }
        else if (canDoubleJump && (Input.GetButtonDown("Jump")))
        {
            moveInput.y = jumpPower;

            canDoubleJump = false;
        }
    }

    void RotationPlayer()
    {
        //control rotacion camara
        Vector2 mouseInput = new Vector2(Input.GetAxisRaw("Mouse X"), Input.GetAxisRaw("Mouse Y")) * mouseSensitivity;

        if (invertX)
        {
            mouseInput.x = -mouseInput.x;
        }
        if (invertY)
        {
            mouseInput.y = -mouseInput.y;
        }

        //quaternion ayuda a que la rotacion sea suave..
        transform.rotation = Quaternion.Euler(transform.rotation.eulerAngles.x,
                                              transform.rotation.eulerAngles.y + mouseInput.x,
                                              transform.rotation.eulerAngles.z);

        camTransform.rotation = Quaternion.Euler(camTransform.rotation.eulerAngles + new Vector3(-mouseInput.y, 0f, 0f));

        //bloquear que el jugador mire cierta cantidad para arriba
        if (camTransform.rotation.eulerAngles.x > maxViewAngle &&
           camTransform.rotation.eulerAngles.x < 180f)
        {
            camTransform.rotation = Quaternion.Euler(maxViewAngle,
                                                     camTransform.rotation.eulerAngles.y,
                                                     camTransform.rotation.eulerAngles.z);
        }
        else if (camTransform.rotation.eulerAngles.x > 180f &&
                camTransform.rotation.eulerAngles.x < 360f - maxViewAngle)
        {
            camTransform.rotation = Quaternion.Euler(-maxViewAngle,
                                                      camTransform.rotation.eulerAngles.y,
                                                      camTransform.rotation.eulerAngles.z);
        }
    }

    void Shooting()
    {
        //disparo singular
        if (Input.GetMouseButtonDown(0) && activeGun.fireCounter <= 0)
        {
            RaycastHit hit;
            if (Physics.Raycast(camTransform.position, camTransform.forward, out hit, 50f))
            {
                if (Vector3.Distance(camTransform.position, hit.point) > 2f)
                {
                    activeGun.firePoint.LookAt(hit.point);
                }
            }
            else
            {
                activeGun.firePoint.LookAt(camTransform.position + (camTransform.forward * 30f));
            }

            FireShot();
        }

        //disparo automatico/metralleta!
        if (Input.GetMouseButton(0) && activeGun.canAutoFire)
        {
            if (activeGun.fireCounter <= 0)
            {
                FireShot();
            }
        }
    }

    void GunSight()
    {
        if (Input.GetMouseButtonDown(1))
        {
            CameraController.instance.ZoomIn(activeGun.zoomAmount);
        }

        if (Input.GetMouseButton(1))
        {
            gunHolder.position = Vector3.MoveTowards(gunHolder.position, adsPoint.position, adsSpeed * Time.deltaTime);
            gunHolder.rotation = adsPoint.rotation;
        }
        else
        {
            gunHolder.localPosition = Vector3.MoveTowards(gunHolder.localPosition, gunStartPos, adsSpeed * Time.deltaTime);
            gunHolder.rotation = initialPosGunHolder.rotation;
        }

        if (Input.GetMouseButtonUp(1))
        {
            CameraController.instance.ZoomOut();
        }
    }

    public void FireShot()
    {
        if(activeGun.currentAmmo > 0) //si tenes municion, podes disparar
        {
            activeGun.currentAmmo--;

            Instantiate(activeGun.bullet, activeGun.firePoint.position, activeGun.firePoint.rotation);
            
            activeGun.fireCounter = activeGun.fireRate;

            UIController.instance.ammoText.text = activeGun.currentAmmo + "/" + activeGun.maxAmmo;

            muzzleFlash.SetActive(true);
        }
    }

    public void SwitchGun()
    {
        //desactiva la arma activa
        activeGun.gameObject.SetActive(false);

        currentGun++;

        if(currentGun >= allGuns.Count)
        {
            currentGun = 0;
        }

        //activar arma..
        activeGun = allGuns[currentGun];
        activeGun.gameObject.SetActive(true);

        //cambia la municion
        UIController.instance.ammoText.text = activeGun.currentAmmo + "/" + activeGun.maxAmmo;
    }

    public void AddGun(string gunToAdd)
    {
        bool gunUnlocked = false;

        if(unlockableGuns.Count > 0) //lista de armas para desbloquear
        {
            for (int i = 0; i < unlockableGuns.Count; i++)
            {
                gunUnlocked = true;

                //lo agregas a la lista de armas
                allGuns.Add(unlockableGuns[i]);

                //lo eliminas de la lista de armas bloqueadas
                unlockableGuns.RemoveAt(i);

                i = unlockableGuns.Count;
            }
        }

        if(gunUnlocked)
        {
            currentGun = allGuns.Count - 2;
            SwitchGun();
        }
    }

    public void Bounce(float bounceForce)
    {
        bounceAmount = bounceForce; //
        bounce = true;
    }
}