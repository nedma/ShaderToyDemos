using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEngine;

public class HDRIBaker : MonoBehaviour
{
    public enum EMethod
    {
        LogLuv = 0,
        RGBE,
    }
    public EMethod Method = EMethod.RGBE;


    public Texture HDR_Image;

    Material m_BakeMat;
    public Texture2D m_BakeResult;
    public RenderTexture m_RT;

    public void Bake(string saveDir)
    {
        if (HDR_Image == null)
            return;

        if (m_BakeMat == null)
        {
            Shader sh = Shader.Find("Hidden/HDRIBaker");
            m_BakeMat = new Material(sh);
        }

        RenderTexture tempRT = RenderTexture.GetTemporary(HDR_Image.width, HDR_Image.height, 0, RenderTextureFormat.ARGB32, RenderTextureReadWrite.Linear);
        Graphics.Blit(HDR_Image, tempRT, m_BakeMat, (int)Method);






        SaveRenderTextureToPNG(tempRT, saveDir, HDR_Image.name + "_Encoded");
        m_RT = tempRT;
        //RenderTexture.ReleaseTemporary(tempRT);
    }

    //将RenderTexture保存成一张png图片
    public bool SaveRenderTextureToPNG(RenderTexture rt, string contents, string pngName)
    {
        RenderTexture prev = RenderTexture.active;
        RenderTexture.active = rt;

        Texture2D png = new Texture2D(rt.width, rt.height, TextureFormat.ARGB32, false);
        png.ReadPixels(new Rect(0, 0, rt.width, rt.height), 0, 0, false);
        png.Apply();

        byte[] bytes = png.EncodeToPNG();

        if (!Directory.Exists(contents))
            Directory.CreateDirectory(contents);
        FileStream file = File.Open(contents + "/" + pngName + ".png", FileMode.Create);

        BinaryWriter writer = new BinaryWriter(file);
        writer.Write(bytes);
        file.Close();

        m_BakeResult = png;

        //Texture2D.DestroyImmediate(png);
        //png = null;

        RenderTexture.active = prev;

        return true;

    }
}
