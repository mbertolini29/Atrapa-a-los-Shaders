using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraController : MonoBehaviour
{
    public static CameraController instance;

    [Header("Player Point")]
    public Transform target;

    [Header("Zoom")]
    public Camera theCam;
    public float zoomSpeed = 1f;
    float startFOV; //field of view
    float targetFOV; //field of view

    void Awake()
    {
        instance = this;
    }

    void Start()
    {
        startFOV = theCam.fieldOfView;
        targetFOV = startFOV;
    }

    //para que el movimiento de la camara, sea desp de q el jugador se haya movido
    void LateUpdate() 
    {
        transform.position = target.position;
        transform.rotation = target.rotation;

        theCam.fieldOfView = Mathf.Lerp(theCam.fieldOfView, targetFOV, zoomSpeed * Time.deltaTime);
    }

    public void ZoomIn(float newZoom)
    {
        targetFOV = newZoom;
    }

    public void ZoomOut()
    {
        targetFOV = startFOV;
    }


}
