using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class GameManager : MonoBehaviour
{
    public static GameManager instance;

    public float waitAfterDying = 2f;

    [HideInInspector]
    public bool levelEnding;

    [Header("Panel ganaste/perdiste")]
    public GameObject PanelWin;
    public GameObject PanelLose;

    private void Awake()
    {
        instance = this;
    }

    void Start()
    {
        Cursor.lockState = CursorLockMode.Locked; //para q no se vea
        Cursor.visible = false;
    }

    void Update()
    {
        if (Input.GetButtonDown("Pause"))
        {
            PauseUnpause();
        }
    }

    public void PlayerDied()
    {
        StartCoroutine(PlayerDiedCo()); 
    }

    public IEnumerator PlayerDiedCo()
    {
        yield return new WaitForSeconds(waitAfterDying);

        Cursor.visible = true;

        Cursor.lockState = CursorLockMode.None;
        PanelLose.SetActive(true);
        //SceneManager.LoadScene(SceneManager.GetActiveScene().name);
    }

    public void PlayerWin()
    {
        StartCoroutine(PlayerWinCo());
    }      

    public IEnumerator PlayerWinCo()
    {
        yield return new WaitForSeconds(waitAfterDying);


        Cursor.lockState = CursorLockMode.None;
        Cursor.visible = true;

        PanelWin.SetActive(true);
        //SceneManager.LoadScene(SceneManager.GetActiveScene().name);
    }

    public void PauseUnpause()
    {
        //si esta activado en la jerarquia
        if (UIController.instance.pauseScreen.activeInHierarchy)
        {
            UIController.instance.pauseScreen.SetActive(false);

            Cursor.lockState = CursorLockMode.Locked;
            Cursor.visible = false;

            Time.timeScale = 1f;

            PlayerController.instance.footstepSlow.Play();
        }
        else
        {
            UIController.instance.pauseScreen.SetActive(true);

            Cursor.lockState = CursorLockMode.None;
            Cursor.visible = true;

            Time.timeScale = 0f;

            //si queres parar algun sonido desde pausa
            //AudioManager.instance.StopSFX((int)fxSound.); 
            PlayerController.instance.footstepSlow.Stop();
            //PlayerController.instance.footstepFast.Stop();
        }
    }
}
