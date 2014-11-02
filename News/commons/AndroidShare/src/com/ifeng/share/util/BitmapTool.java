package com.ifeng.share.util;

import android.content.res.Resources;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Shader.TileMode;
import android.graphics.drawable.BitmapDrawable;

/**
 * 
 * @author 13leaf
 *
 */
public class BitmapTool {

	public static BitmapDrawable fillHorizontalAndRepeatX(Resources res,int originalId,int scaledHeight)
	{
		Bitmap original=BitmapFactory.decodeResource(res, originalId);
		if(scaledHeight==0 || original.getHeight()==scaledHeight) {
			BitmapDrawable drawable= new BitmapDrawable(original);
			drawable.setTileModeX(TileMode.REPEAT);return drawable;
		}
		Bitmap scaled=Bitmap.createScaledBitmap(original, original.getWidth(),scaledHeight,true);
		//release original
		original.recycle();
		original=null;
		BitmapDrawable drawable=new BitmapDrawable(scaled);
		drawable.setTileModeX(TileMode.REPEAT);
		return drawable;
	}
}
