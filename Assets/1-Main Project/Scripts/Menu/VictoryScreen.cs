using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;

public class VictoryScreen : MonoBehaviour
{
    public string mainMenuScene;
    public float timeBetweenShowing = 0.75f;
    public GameObject textBox;
    public GameObject returnButton;

    public Image blackScreen;
    public float blackScreenFade = 1f;

    void Start()
    {
        StartCoroutine(ShowObjectCo());

        Cursor.lockState = CursorLockMode.None;
        Cursor.visible = true;
    }

    private void Update()
    {
        blackScreen.color = new Color(blackScreen.color.r, blackScreen.color.g, blackScreen.color.b, Mathf.MoveTowards(blackScreen.color.a, 0f, blackScreenFade * Time.deltaTime));
    }

    public void MainMenu()
    {
        SceneManager.LoadScene(mainMenuScene);
    }

    public IEnumerator ShowObjectCo()
    {
        yield return new WaitForSeconds(timeBetweenShowing);
        textBox.SetActive(true);
        yield return new WaitForSeconds(timeBetweenShowing);
        returnButton.SetActive(true);
    }
}