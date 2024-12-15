using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class MainMenu : MonoBehaviour
{
    public string firstLevel;

    public GameObject continueButton;

    void Start()
    {
        if(PlayerPrefs.HasKey("CurrentLevel"))
        {
            if(PlayerPrefs.GetString("CurrentLevel") == "")
            {
                continueButton.SetActive(false);
            }
        }
        else
        {
            continueButton.SetActive(false);
        }
    }

    void Update()
    {

    }

    public void Continue()
    {
        //SceneManager.LoadScene(PlayerPrefs.GetString("CurrentLevel"));
    }

    public void PlayGame()
    {
        //SceneManager.LoadScene(firstLevel);

        //PlayerPrefs.SetString("CurrentLevel", ""); //reinicia la info guardada..
        //PlayerPrefs.SetString(firstLevel + "_cp", ""); //reinicia los checkpoint

        //Time.timeScale = 1f;
        SceneManager.LoadScene(SceneManager.GetActiveScene().buildIndex + 1);
    }

    public void QuitGame()
    {
        Application.Quit();
    }
}
