using UnityEditor;
using UnityEngine;
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
            string srcDir = CalcSaveDirectory(baker.HDR_Image);
            baker.Bake(srcDir);

            AssetDatabase.Refresh();
        }
    }




    static string CalcSaveDirectory(Object src)
    {
        string srcPath = AssetDatabase.GetAssetPath(src);
        

        string dir = Path.Combine(Application.dataPath.Replace("/Assets", "/"), Path.GetDirectoryName(srcPath));

        return dir;

    }
}