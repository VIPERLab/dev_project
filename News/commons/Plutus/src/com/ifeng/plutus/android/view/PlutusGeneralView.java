package com.ifeng.plutus.android.view;

import java.util.HashMap;
import java.util.List;

import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.net.Uri;
import android.os.Handler;
import android.os.Message;
import android.util.AttributeSet;
import android.view.Gravity;
import android.view.View;
import android.view.animation.AlphaAnimation;
import android.view.animation.Animation;
import android.view.animation.TranslateAnimation;
import android.widget.ImageView;
import android.widget.ImageView.ScaleType;
import android.widget.TextView;
import android.widget.ViewSwitcher;

import com.ifeng.plutus.android.PlutusAndroidManager;
import com.ifeng.plutus.android.utils.DialogUtil;
import com.ifeng.plutus.core.model.bean.AdAction;
import com.ifeng.plutus.core.model.bean.AdMaterial;
import com.ifeng.plutus.core.model.bean.PlutusBean;

public class PlutusGeneralView extends PlutusView {
	// Message indicating the view should be updated
	private static final int MSG_UPDATE_VIEW = 0x011;
	// Data object obtained
	private PlutusBean data = null;
	// Material type of obtained data object
	private String type = null;
	//Interval to update view item
	private int interval = 0;
	// Array for AdMaterial
	private List<AdMaterial> list = null;
	// Current AdMaterial
	private AdMaterial current = null;
	// ViewSwitcher to display items
	private ViewSwitcher viewSwitcher = null;
	// Hanlder for view update
	private static MessageHandler handler = null;

	public PlutusGeneralView(Context context, AttributeSet attrs) {
		this(context, attrs, 0);
	}

	public PlutusGeneralView(Context context, AttributeSet attrs, int defStyle) {
		super(context, attrs, defStyle);
		setVisibility(View.GONE);
	}

	@Override
	protected void onAttachedToWindow() {
		super.onAttachedToWindow();
		handler = new MessageHandler();
	}

	// TODO this can not guarantee that the handler will be stopped 
	@Override
	protected void onDetachedFromWindow() {
		super.onDetachedFromWindow();
		handler.removeMessages(MSG_UPDATE_VIEW);
	}
	
	@Override
	public void onClick(View v) {
		AdAction action = current.getAdAction();
		if (action == null || action.getUrl() == null || action.getUrl().length() == 0) return;
		String url = action.getUrl() + PlutusAndroidManager.getUrlSuffix();
		if (action.getType().contains(ACTION_TYPE_WEB)) {
			DialogUtil.showWebDialog(getContext(), url);
		} else if (action.getType().equalsIgnoreCase(ACTION_TYPE_BROWSER)) {
			Intent intent = new Intent(Intent.ACTION_VIEW, Uri.parse(url));
			intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
			getContext().startActivity(intent);
		}
	}
	
	@Override
	protected void handleBean(PlutusBean bean) {
		// Init views by AdMaterialType
		data = filterByTimeStamp(bean);
		list = data.getAdMaterials();
		if (list.isEmpty()) return;
		type = data.getAdMaterialType();
		
		// Update view by data
		setupViewSwitcher();
		// Start timer if display type is "rotation"
		if (Display.getDisplay(data.getAdDescription().getStyle()) == Display.ROTATION) {
			try {
				interval = Integer.valueOf(data.getAdDescription().getInterval());
			} catch (NumberFormatException e) {
				interval = 5;
			}
			startTimer();
		}
	}

	// Called when a bitmap is loaded
	@Override
	protected void handleBitmap(Bitmap bitmap) {
		if (type.contains(PlutusBean.TYPE_TXT) || bitmap == null)
			return;
		if (getVisibility() == View.GONE)
			setVisibility(View.VISIBLE);
		((ImageView) viewSwitcher.getNextView()).setImageBitmap(bitmap);
		viewSwitcher.showNext();
	}
	
	public void handleNext() {
		moveToNext();
		if (current == null) return;
		ExposureHandler.putInQueue(current.getAdId());
		if (type.equalsIgnoreCase(PlutusBean.TYPE_IMG)) {
			HashMap<String, String> map = new HashMap<String, String>();
			map.put("select", "thumb");
			map.put("imgUrl", current.getImageURL());
			PlutusAndroidManager.qureyAsync(map, this);
		} else {
			if (current.getText().length() == 0)
				setVisibility(View.GONE);
			else {
				((TextView) viewSwitcher.getNextView()).setText(current.getText());
				viewSwitcher.showNext();	
			}
		}
	}
	
	private void setupViewSwitcher() {
		viewSwitcher = new ViewSwitcher(getContext());
		setAnimation(data.getAdDescription().getDirect());
		LayoutParams lp = new LayoutParams(LayoutParams.FILL_PARENT, LayoutParams.FILL_PARENT);
		addView(viewSwitcher, lp);
		
		if (type.equalsIgnoreCase(PlutusBean.TYPE_IMG)) {
			ImageView previous = new ImageView(getContext());
			ImageView next = new ImageView(getContext());
			previous.setScaleType(ScaleType.CENTER_INSIDE);
			next.setScaleType(ScaleType.CENTER_INSIDE);
			viewSwitcher.addView(previous, 0, lp);
			viewSwitcher.addView(next, 1, lp);			
		} else {
			TextView previous = new TextView(getContext());
			TextView next = new TextView(getContext());
			setupTextView(previous);
			setupTextView(next);
			viewSwitcher.addView(previous, 0, lp);
			viewSwitcher.addView(next, 1, lp);
			if (getVisibility() == View.GONE)
				setVisibility(View.VISIBLE);
		} 
		handleNext();
	}

	private void setupTextView(TextView textView) {
		textView.setTextAppearance(getContext(), android.R.style.TextAppearance_Medium);
		textView.setGravity(Gravity.CENTER_VERTICAL);
		textView.setPadding(10, 0, 0, 0);
	}

	private PlutusBean filterByTimeStamp(PlutusBean bean) {
		PlutusBean filtered = bean; 
		for (AdMaterial a : bean.getAdMaterials())
			if (Long.valueOf(a.getAdStartTime()) > System.currentTimeMillis() 
					|| Long.valueOf(a.getAdEndTime()) < System.currentTimeMillis()) {
//				filtered.getPosition().getAdMaterials().remove(a);
			}
		return filtered;
	}

	// set animation according to direct
	private void setAnimation(String direct) {
		Animation inAnimation = null;
		Animation outAnimation = null;

		if (ROTATION_TYPE_FADE.equalsIgnoreCase(direct)) {
			inAnimation = new AlphaAnimation(0.0f, 1.0f); 
			outAnimation = new AlphaAnimation(1.0f, 0.0f);
		} else {
			// set animation 'up' as default
			inAnimation = new TranslateAnimation(0, 0, viewSwitcher.getHeight(), 0);
			outAnimation = new TranslateAnimation(0, 0, 0, -viewSwitcher.getHeight());
		}

		inAnimation.setRepeatCount(0);
		inAnimation.setFillAfter(true);
		inAnimation.setDuration(300);
		outAnimation.setRepeatCount(0);
		outAnimation.setDuration(300);
		outAnimation.setFillAfter(true);
		viewSwitcher.setInAnimation(inAnimation);
		viewSwitcher.setOutAnimation(outAnimation);
	}

	// Get index by display type
	private void moveToNext() {
		int index = -1;
		switch (Display.getDisplay(data.getAdDescription().getStyle())) {
		case RANDOM:
			index = (int) (Math.random() * 100) % list.size();
			break;
		case FIXED: case ROTATION: default:
			index = list.indexOf(current) + 1;
			if (index == 0 || index == list.size()) index = 0;
			break;
		}
		
		current = list.get(index);
	}

	// start timer if we should 'rotate'
	private void startTimer() {
		if (Display.getDisplay(data.getAdDescription().getStyle()) != Display.ROTATION)
			return;
		Message msg = Message.obtain(handler, MSG_UPDATE_VIEW, this);
		handler.sendMessageDelayed(msg, interval * 1000);
	}
	
	public int getInterval() {
		return interval;
	}

	// handler trigged by timer
	private static class MessageHandler extends Handler {
		
		public void handleMessage(Message msg) {
			if (msg.obj == null) return;
			switch (msg.what) {
			case MSG_UPDATE_VIEW:
				((PlutusGeneralView)msg.obj).handleNext();
				Message message = Message.obtain(handler, MSG_UPDATE_VIEW, msg.obj);
				handler.sendMessageDelayed(message, ((PlutusGeneralView) msg.obj).getInterval() * 1000);
				break;
			default:
				break;
			}
		}
	};
}