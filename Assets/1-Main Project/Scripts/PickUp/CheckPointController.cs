using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class CheckPointController : MonoBehaviour
{
    public string cpName;

    void Start()
    {
        if(PlayerPrefs.HasKey(SceneManager.GetActiveScene().name + "_cp"))
        {
            if(PlayerPrefs.GetString(SceneManager.GetActiveScene().name + "_cp") == cpName)
            {
                PlayerController.instance.transform.position = transform.position;
                Debug.Log("player starting at " + cpName);
            }
        }
    }
        
    void Update()
    {
        if (Input.GetKeyDown(KeyCode.L))
        {

        }
    }

    private void OnTriggerEnter(Collider other)
    {
        if(other.gameObject.tag == "Player")
        {
            PlayerPrefs.SetString(SceneManager.GetActiveScene().name + "_cp", cpName);
            Debug.Log("player hit " + cpName);

            AudioManager.instance.PlaySFX((int)fxSound.checkpoint);
        }
    }
}
