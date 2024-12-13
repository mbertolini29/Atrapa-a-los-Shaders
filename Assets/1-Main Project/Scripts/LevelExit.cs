using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class LevelExit : MonoBehaviour
{
    //public string nextLevel;
    //public float waitToEndLevel;

    private void OnTriggerEnter(Collider other)
    {
        if(other.tag == "Player")
        {
            GameManager.instance.levelEnding = true;

            //
            GameManager.instance.PlayerWin(); 

            //StartCoroutine(EndLevelCo());

            AudioManager.instance.PlayLevelVictory();
        }
    }

    //public IEnumerator EndLevelCo()
    //{
    //    PlayerPrefs.SetString(nextLevel + "_cp", ""); //reinicia los checkpoint
    //    PlayerPrefs.SetString("CurrentLevel", nextLevel); //para que continue en el estado que dejaste el juego.

    //    yield return new WaitForSeconds(waitToEndLevel);

    //    SceneManager.LoadScene(nextLevel);
    //}

    //public void Ganaste()
    //{

    //}
}
