using UnityEditor;
using UnityEngine;
using System;
using System.IO;




[CustomEditor(typeof(HDRIBaker))]
public class HDRIBakerEditor : Editor
{
    public override void OnInspectorGUI()
    {
        HDRIBaker baker = target as HDRIBaker;


        base.DrawDefaultInspector();


        if (GUILayout.Button("Bake"))
        {
            baker.Bake();
        }
    }



}