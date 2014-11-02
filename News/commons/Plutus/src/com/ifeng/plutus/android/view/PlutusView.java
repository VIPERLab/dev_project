package com.ifeng.plutus.android.view;

import java.util.HashMap;
import java.util.Map;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.util.AttributeSet;
import android.view.View;
import android.widget.FrameLayout;

import com.ifeng.plutus.android.PlutusAndroidManager;
import com.ifeng.plutus.android.PlutusAndroidManager.PlutusAndroidListener;
import com.ifeng.plutus.core.Constants;
import com.ifeng.plutus.core.Constants.ERROR;
import com.ifeng.plutus.core.PlutusCoreListener;
import com.ifeng.plutus.core.PlutusCoreManager;
import com.ifeng.plutus.core.model.bean.PlutusBean;

/**
 * Base view for Plutus SDK, containing enums class and callbacks of loading
 * @author gao_miao
 *
 */
public abstract class PlutusView extends FrameLayout implements PlutusAndroidListener<Object>, View.OnClickListener {
	
	/**
	 * Display enum for animation
	 * @author gao_miao
	 *
	 */
	protected enum Display {
		ROTATION ,
		FIXED,
		RANDOM;	
		private static final String DISPLAY_STYLE_ROTATION = "rotation";
		private static final String DISPLAY_STYLE_RANDOM = "random";
		private static final String DISPLAY_STYLE_FIXED = "fixed";
		public static Display getDisplay(String s) {
			if (s.equalsIgnoreCase(DISPLAY_STYLE_ROTATION))
				return Display.ROTATION;
			if (s.equalsIgnoreCase(DISPLAY_STYLE_RANDOM))
				return Display.RANDOM;
			if (s.equalsIgnoreCase(DISPLAY_STYLE_FIXED))
				return Display.FIXED;
			return Display.FIXED;
		}
	}
	
	/**
	 * Rotation type: 'up'
	 */
	protected static final String ROTATION_TYPE_UP = "up";
	
	/**
	 * Rotation type: 'fade'
	 */
	protected static final String ROTATION_TYPE_FADE = "fade";
	
	/**
	 * Action type: 'web'
	 */
	protected static final String ACTION_TYPE_WEB = "web";
	
	/**
	 * Action type: 'browser'
	 */
	protected static final String ACTION_TYPE_BROWSER = "browser";

	/**
	 * Advertisement position
	 */
	protected String position = null;

	/**
	 * Constructor, please refer to {@link PlutusView#PlutusView(Context, AttributeSet, int)}
	 * @param context the context holds the view
	 * @param attrs attrs of the view
	 */
	public PlutusView(Context context, AttributeSet attrs) {
		this(context, attrs, 0);
	}
	
	/**
	 * Constructor for the view, note that {@link PlutusCoreManager#qureyAsync(com.ifeng.plutus.core.model.callable.PlutusCoreCallable, PlutusCoreListener) qureyAsync}
	 * and {@link ExposureHandler#init(Context)} will be tirggered on constructing, the selections will be given by {@link PlutusView#getSelectionArg() getSelectionArg}
	 * 
	 * @param context
	 * @param attrs
	 * @param defStyle
	 */
	public PlutusView(Context context, AttributeSet attrs, int defStyle) {
		super(context, attrs, defStyle);
		setOnClickListener(this);
		
		for (int i = 0; i < attrs.getAttributeCount(); i++)
			if (Constants.KEY_POSITION.equals(attrs.getAttributeName(i)))
				position = attrs.getAttributeValue(i);
		PlutusAndroidManager.qureyAsync(getSelectionArg(), this);
		
		ExposureHandler.init();
	}

	/**
	 * Set your own selection arg in this method, which is automatically called in constructor,
	 * override this to set your own query args
	 * @return Args should be used to query
	 */
	protected Map<String, String> getSelectionArg() {
		HashMap<String, String> map = new HashMap<String, String>();
		map.put(Constants.SELECT, Constants.SELE_ADPOSITION);
		map.put(Constants.KEY_POSITION, position);
		return map;
	}
	
	/**
	 * Handle data object loaded
	 * @param bean Data object loaded
	 */
	protected abstract void handleBean(PlutusBean bean);
	
	/**
	 * Handle bitmap object loaded
	 * @param bitmap Bitmap object loaded
	 */
	protected abstract void handleBitmap(Bitmap bitmap);

	@Override
	public void onPostStart() {
	}

	@Override
	public void onPostComplete(Object result) {
		if (result == null) return;
		
		if (result instanceof PlutusBean) {
			handleBean((PlutusBean) result);
		} else if (result instanceof byte[]) {
			Bitmap bitmap = BitmapFactory.decodeByteArray((byte[]) result, 0, ((byte[]) result).length);
			handleBitmap(bitmap);
		} 
	}

	@Override
	public void onPostFailed(ERROR error) {
		System.out.println(error);
	}
}
