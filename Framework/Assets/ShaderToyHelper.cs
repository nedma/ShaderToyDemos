using UnityEngine;
using System.Collections;

public class ShaderToyHelper : MonoBehaviour
{
    private bool _lockInput = false;


    private Material _material = null;

    private bool _isDragging = false;

    // Use this for initialization
    void Start ()
    {
        Renderer render  = GetComponent<Renderer>();
        if (render != null)
        {
            _material = render.material;
        }

        _isDragging = false;
    }

    // Update is called once per frame
    void Update ()
    {
        Vector3 mousePosition = Vector3.zero;
        if (_isDragging)
        {
            mousePosition = new Vector3(Input.mousePosition.x, Input.mousePosition.y, 1.0f);
        }
        else
        {
            mousePosition = new Vector3(Input.mousePosition.x, Input.mousePosition.y, 0.0f);
        }

        if (Input.GetMouseButtonUp(1))
        {
            _lockInput = !_lockInput;
        }

        if (_material != null && !_lockInput)
        {
            _material.SetVector("iMouse", mousePosition);
        }
    }

    void OnMouseDown()
    {
        _isDragging = true;
    }

    void OnMouseUp()
    {
        _isDragging = false;
    }
}