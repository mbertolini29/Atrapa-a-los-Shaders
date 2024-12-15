using UnityEngine;

public class EnemyInstance : MonoBehaviour
{

    public GameObject spiritPrefab;

    private void Update()
    {

    }

    public void InstanciarAlma()
    {
        //instanciar espiritu
        if (spiritPrefab != null)
        {
            Instantiate(spiritPrefab, spiritPrefab.transform.position, spiritPrefab.transform.rotation);
        }
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.tag == "Player")
        {
            InstanciarAlma();
        }
    }
}
