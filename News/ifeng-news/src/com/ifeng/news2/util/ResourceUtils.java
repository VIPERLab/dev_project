package com.ifeng.news2.util;

import java.io.IOException;
import java.io.InputStream;

import android.content.Context;
import android.content.res.Resources.NotFoundException;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;

/**
 * 资源管理类
 * 
 * @author Neusoft.E3
 * @since 1.0
 */
public class ResourceUtils {
    private static Context mMainContext; // resource handler

    /**
     * Set the resource handler
     * 
     * @param aContext
     */
    public static void setContext( Context aContext ) {
        mMainContext = aContext.getApplicationContext();
    }

    /**
     * Get string
     * 
     * @param aResource resource id
     * @return string
     */
    public static String getString( int aResource ) {
        return mMainContext.getString( aResource );
    }
    
    /**
     * Get CharSequence
     * @param aResource resource id
     * @return CharSequence
     */
    public static CharSequence getText( int aResource ){
    	return mMainContext.getResources().getText(aResource);
    }

    /**
     * Get drawable object
     * 
     * @param aResource resource id
     * @return drawable
     */
    public static Drawable getDrawable( int aResource ) {
        Drawable ret = null;
        try {
            ret = mMainContext.getResources().getDrawable( aResource );
        }
        catch ( NotFoundException e ) {
            e.printStackTrace();
        }
        return ret;
    }

    /**
     * Get string from asset file
     * @param aFile
     * @return
     */
    public static String getStringFromFile( String aFile ) {
        String ret = null;
        try {
            InputStream inputStream = mMainContext.getAssets().open( aFile );
            int size = inputStream.available();
            byte[] buffer = new byte[size];
            inputStream.read( buffer );
            inputStream.close();
            ret = new String( buffer, "UTF-8" );
            // ret = new String( buffer );
        }
        catch ( IOException e ) {
            e.printStackTrace();
        }
        return ret;
    }

    /**
     * Get bitmap from asset file
     * @param aImageFileName
     * @return
     */
    public static Bitmap getBitmapFromAsset( String aImageFileName ) {
        Bitmap ret = null;
        try {
            InputStream inputStream = mMainContext.getAssets().open( aImageFileName );
            ret = BitmapFactory.decodeStream( inputStream );
            inputStream.close();
        }
        catch ( IOException e ) {
            e.printStackTrace();
        }
        return ret;
    }
    
    public static Bitmap getBitmapFromFile( String aImageFileName ) {
        Bitmap ret = null;
        try {
            InputStream inputStream = mMainContext.openFileInput( aImageFileName );
            ret = BitmapFactory.decodeStream( inputStream );
            inputStream.close();
        }
        catch ( IOException e ) {
//            e.printStackTrace();
        }
        return ret;
    }
    
    /**
     * @param aResourceId
     * @return
     */
    public static Bitmap getBitmapFromResource( int aResourceId ) {
    	Drawable drawable= mMainContext.getResources().getDrawable(aResourceId);
    	BitmapDrawable bitmapDrawable = (BitmapDrawable) drawable;
    	return bitmapDrawable.getBitmap();
    }
    
    /**
     * Get Color 
     * @param aResourceId
     * @return int
     */
    public static int getColor( int aResourceId ){
    	return mMainContext.getResources().getColor( aResourceId );
    }
    
    /**
     * 
     * @param aResourceId
     * @return
     */
    public static int getDimenPixelSize ( int aResourceId ){
    	return mMainContext.getResources().getDimensionPixelSize(aResourceId);
    }
    
    /**
     * 
     * @param aResourceId
     * @return
     */
    public static float getDimen ( int aResourceId ){
    	return mMainContext.getResources().getDimension(aResourceId);
    }
    /**
     * Get Int[]
     * @param aResourceId
     * @return
     */
    public static int[] getIntArray ( int aResourceId ){
    	return mMainContext.getResources().getIntArray(aResourceId);
    }
    
}
