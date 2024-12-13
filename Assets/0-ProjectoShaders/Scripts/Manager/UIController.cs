using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class UIController : MonoBehaviour
{    
    public static UIController instance;

    public Slider healthSlider;
    public Text healthText;
    //public Text ammoText;
    public Text SpiritusText;

    public Image damageEffect;
    public float damageAlpha = .25f;
    public float damageFadeSpeed = 2f; //desvanecimiento
    public int numberOfFlashes = 5;
    public float flashDuration = 0.1f;

    public GameObject pauseScreen;

    //public GameObject endScreen;

    public Image blackScreen;
    public float fadeSpeed = 1.5f;

    void Awake()
    {
        instance = this;
    }

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        //if(damageEffect.color.a != 0)
        //{
        //    damageEffect.color = new Color(damageEffect.color.r, damageEffect.color.g, damageEffect.color.b, Mathf.MoveTowards(damageEffect.color.a, 0f, damageFadeSpeed * Time.deltaTime));
        //}

        if (!GameManager.instance.levelEnding)
        {
            blackScreen.color = new Color(blackScreen.color.r, blackScreen.color.g, blackScreen.color.b, Mathf.MoveTowards(blackScreen.color.a, 0f, fadeSpeed * Time.deltaTime));
        }
        else
        {
            blackScreen.color = new Color(blackScreen.color.r, blackScreen.color.g, blackScreen.color.b, Mathf.MoveTowards(blackScreen.color.a, 1f, fadeSpeed * Time.deltaTime));
        }
    }

    public void ShowDamage()
    {
        //damageEffect.color = new Color(damageEffect.color.r, damageEffect.color.g, damageEffect.color.b, damageAlpha);

        StartCoroutine(GetInvulnerable());
    }

    IEnumerator GetInvulnerable()
    {
        int temp = 0;

        while (temp < numberOfFlashes)
        {
            damageEffect.color = new Color(damageEffect.color.r, damageEffect.color.g, damageEffect.color.b, damageAlpha);
            yield return new WaitForSeconds(flashDuration);
            damageEffect.color = new Color(damageEffect.color.r, damageEffect.color.g, damageEffect.color.b, 0f);
            yield return new WaitForSeconds(flashDuration);
            temp++;
        }

        //100% transparente.
        damageEffect.color = new Color(damageEffect.color.r, damageEffect.color.g, damageEffect.color.b, 0f);
    }
}
