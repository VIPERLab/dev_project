package com.ifeng.news2.widget;



import com.ifeng.news2.R;
import com.ifeng.news2.bean.PhotoAndTextLiveContent;
import com.ifeng.news2.bean.PhotoAndTextLiveTitleBean;
import com.ifeng.news2.util.DateUtil;
import com.qad.util.IfengGestureDetector;
import com.qad.util.OnFlingListener;

import android.app.Activity;
import android.content.Context;
import android.graphics.drawable.AnimationDrawable;
import android.os.Handler;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.view.GestureDetector;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

/**
 * 图文直播头部信息
 * 
 * @author SunQuan:
 * @version 创建时间：2013-8-21 上午9:57:13 类说明
 */

public class PhotoAndTextLiveTitleView extends LinearLayout {

	private static final int MARGIN_480 = 7;
	private static final int MARGIN_720 = 15;
	public static final int IS_LOADING = 0x0000;
	public static final int HAS_LOADED = 0x0001;
	public static final int LOAD_FAIL = 0x0002;

	// 加载视图状态 成功/失败/正在加载
	private int loadState = IS_LOADING;

	private Handler handler;

	// 更新直播状态为直播中
	private UpdateRunable updateToLivingRunnable;
	// 更新直播状态为直播结束
	private UpdateRunable updateToEndRunnable;
	// 屏幕宽
	private int screenWidth;

	private View container;
//	private TextView category;
//	private TextView name;
	private TextView content;
	private TextView state;
	private View state_wrapper;
	private ImageView bottomLine;
	private GifView gifView;
	private GestureDetector detector;
	
	public PhotoAndTextLiveTitleView setHandler(Handler handler) {
		this.handler = handler;
		return this;
	}
	
	public PhotoAndTextLiveTitleView setOnFlingListener(OnFlingListener listener) {
		detector = IfengGestureDetector.getInsensitiveIfengGestureDetector(listener);
		return this;
	}

	public int getLoadState() {
		return loadState;
	}

	public void setLoadState(int loadState) {
		this.loadState = loadState;
	}
	
	public PhotoAndTextLiveTitleView(Context context){
		super(context);
		screenWidth = ((Activity) context).getWindowManager()
				.getDefaultDisplay().getWidth();
		updateToLivingRunnable = new UpdateRunable(
				R.string.direct_seeding_in_living);
		updateToEndRunnable = new UpdateRunable(
				R.string.direct_seeding_after_living);
		initView(context);
	}

	public PhotoAndTextLiveTitleView(Context context, AttributeSet attrs) {
		super(context, attrs);
		screenWidth = ((Activity) context).getWindowManager()
				.getDefaultDisplay().getWidth();
		updateToLivingRunnable = new UpdateRunable(
				R.string.direct_seeding_in_living);
		updateToEndRunnable = new UpdateRunable(
				R.string.direct_seeding_after_living);
		initView(context);
	}

	private void initView(Context context) {
		container = LayoutInflater.from(context).inflate(
				R.layout.direct_seeding_bottom_title, this);
//		category = (TextView) container
//				.findViewById(R.id.direct_seeding_title_TV);
//		name = (TextView) container.findViewById(R.id.direct_seeding_name_TV);
		content = (TextView) container
				.findViewById(R.id.direct_seeding_content_TV);
		state = (TextView) container
				.findViewById(R.id.direct_seeding_status_TV);
		state_wrapper = container.findViewById(R.id.state_wrapper);
		gifView = (GifView) container.findViewById(R.id.direct_seeding_GV);
		bottomLine = (ImageView) container.findViewById(R.id.bottom_line);
//		category.setVisibility(View.INVISIBLE);
//		name.setVisibility(View.INVISIBLE);
		content.setVisibility(View.GONE);
		bottomLine.setVisibility(View.GONE);
		state_wrapper.setVisibility(View.GONE);
		this.setLongClickable(true);
	}

	/**
	 * 渲染视图
	 * 
	 * @param data
	 * @param updateState
	 *            是否更新直播状态
	 */
	public void renderView(PhotoAndTextLiveTitleBean data, boolean updateState) {
		PhotoAndTextLiveContent result = data.getContent();
		visibleView(/*category, name, */content, bottomLine, state_wrapper);
		// 如果内容为空，显示的布局
		if (TextUtils.isEmpty(result.getDescription())) {
			showNoneView();
		} else {
			content.setText(result.getDescription());
		}
		// result.setServer_time("2013-09-04 15:55:30");
		// result.setStart_date("2013-09-04 15:55:35");
		// result.setEnd_date("2013-09-04 15:55:40");
		long currentTime = DateUtil.getTimeMillisFromServerTime(result
				.getServer_time());
		long beginTime = DateUtil.getTimeMillisFromServerTime(result
				.getStart_date());
		long endTime = DateUtil.getTimeMillisFromServerTime(result
				.getEnd_date());

		renderState(currentTime, beginTime, endTime, updateState);
	}

	/**
	 * 渲染直播状态
	 * 
	 * @param currentTime
	 * @param beginTime
	 * @param endTime
	 */
	private void renderState(long currentTime, long beginTime, long endTime,
			boolean updateState) {
		// 即将直播
		if (currentTime < beginTime) {
			state.setText(R.string.direct_seeding_before_living);
			hideGifView();
			if (updateState) {
				// 在直播开始的时候更新直播状态
				handler.postDelayed(updateToLivingRunnable, beginTime
						- currentTime);
				// 在直播结束的时候更新直播状态
				handler.postDelayed(updateToEndRunnable, endTime - currentTime);
			}
		}
		// 直播中
		else if (currentTime >= beginTime && currentTime <= endTime) {
			state.setText(R.string.direct_seeding_in_living);
			if (updateState) {
				// 在直播结束的时候更新直播状态
				handler.postDelayed(updateToEndRunnable, endTime - currentTime);
			}
		}
		// 直播结束
		else if (currentTime > endTime) {
			state.setText(R.string.direct_seeding_after_living);
			hideGifView();
		}
	}

	/**
	 * 导读内容为空时候的视图显示
	 */
	private void showNoneView() {
		content.setVisibility(View.GONE);
		bottomLine.setVisibility(View.GONE);
		LayoutParams lp = new LayoutParams(state_wrapper.getLayoutParams());
		int marginTop = 0;
		if (screenWidth >= 720) {
			marginTop = MARGIN_720;
		} else {
			marginTop = MARGIN_480;
		}
		lp.setMargins(lp.leftMargin, marginTop, lp.rightMargin, lp.bottomMargin);
	}

	/**
	 * 将动态点图隐藏，并调整相关布局
	 */
	private void hideGifView() {
		gifView.setVisibility(View.GONE);
	}

	/**
	 * 将动态点图显示，并调整相关布局
	 */
	private void visibleGifView() {
		gifView.setVisibility(View.VISIBLE);
	}

	/**
	 * 将控件可见
	 * 
	 * @param views
	 */
	private void visibleView(View... views) {
		for (View view : views) {
			if (view.getVisibility() != View.VISIBLE) {
				view.setVisibility(View.VISIBLE);
			}
		}
	}

	@Override
	protected void onDetachedFromWindow() {
		clearQueue();
		super.onDetachedFromWindow();
	}
	
	/**
	 * 将runnable从消息队列中移除
	 */
	public void clearQueue() {
		handler.removeCallbacks(updateToLivingRunnable);
		handler.removeCallbacks(updateToEndRunnable);
	}
	
	@Override
	public boolean onTouchEvent(MotionEvent ev) {
		 if (null != detector&&detector.onTouchEvent(ev)) {
		        return true;
		 }
		 return super.onTouchEvent(ev);
	}


	/**
	 * 更新直播状态，在UI线程中运行
	 * 
	 * @author SunQuan
	 * 
	 */
	private class UpdateRunable implements Runnable {

		private int text;

		public UpdateRunable(int text) {
			this.text = text;
		}

		@Override
		public void run() {
			switch (text) {
			case R.string.direct_seeding_in_living:
				state.setText(text);
				visibleGifView();
				break;
			case R.string.direct_seeding_after_living:
				state.setText(text);
				hideGifView();
				break;
			default:
				break;
			}
		}
	}
}
