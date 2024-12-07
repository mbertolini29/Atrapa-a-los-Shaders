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

        SceneManager.LoadScene(SceneManager.GetActiveScene().name);
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
            Cursor.visible = false;

            Time.timeScale = 0f;

            //si queres parar algun sonido desde pausa
            //AudioManager.instance.StopSFX((int)fxSound.); 
            PlayerController.instance.footstepSlow.Stop();
            //PlayerController.instance.footstepFast.Stop();
        }
    }
}
