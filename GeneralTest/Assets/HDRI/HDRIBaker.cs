using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEngine;

[ExecuteInEditMode]
public class HDRIBaker : MonoBehaviour
{
    public enum EMethod
    {
        LogLuv = 0,
        RGBM = 2,
        RGBE =4,
    }
    public EMethod Method = EMethod.RGBE;
    public bool SeperateColorAndAlpha = false;

    [Range(0.01f, 32.0f)]
    public float RGBM_MaxValue = 2.0f;

    public Texture HDR_Image;

    Material m_BakeMat;
    public Texture2D m_BakeResult;
    public RenderTexture m_RT;
    public RenderTexture m_RT2;


    void Awake()
    {
        Shader.SetGlobalFloat("_RgbmMaxValue", RGBM_MaxValue);
    }

    public void Bake(string saveDir)
    {
        if (HDR_Image == null)
            return;

        if (m_BakeMat == null)
        {
            Shader sh = Shader.Find("Hidden/HDRIBaker");
            m_BakeMat = new Material(sh);
        }


        //m_BakeMat.SetFloat("_RgbmMaxValue", RGBM_MaxValue);
        Shader.SetGlobalFloat("_RgbmMaxValue", RGBM_MaxValue);


        RenderTexture tempRT = RenderTexture.GetTemporary(HDR_Image.width, HDR_Image.height, 0, RenderTextureFormat.ARGB32, RenderTextureReadWrite.Linear);
        Graphics.Blit(HDR_Image, tempRT, m_BakeMat, (int)Method);

        SaveRenderTextureToPNG(tempRT, saveDir, HDR_Image.name + "_Encoded");
        m_RT = tempRT;
        //RenderTexture.ReleaseTemporary(tempRT);


        if (SeperateColorAndAlpha)
        {
            RenderTexture tempRT2 = RenderTexture.GetTemporary(HDR_Image.width, HDR_Image.height, 0, RenderTextureFormat.ARGB32, RenderTextureReadWrite.Linear);
            Graphics.Blit(HDR_Image, tempRT2, m_BakeMat, (int)(Method + 1));
            SaveRenderTextureToPNG(tempRT, saveDir, HDR_Image.name + "_Encoded_Alpha");

            m_RT2 = tempRT2;
        }

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
