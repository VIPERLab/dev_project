package com.ifeng.news2.widget;

import android.content.Context;
import android.util.AttributeSet;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.animation.Animation;
import android.view.animation.RotateAnimation;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.ifeng.news2.R;

public class HeaderView extends LinearLayout {
	private LinearLayout mContainer;
	private ImageView mArrowImageView;
	private TextView mHintTextView;
	private int mState = STATE_NORMAL;
	private GifView refreshLoadingView;
	private View refreshDownView;
	private Animation mRotateUpAnim;
	private Animation mRotateDownAnim;

	private final int ROTATE_ANIM_DURATION = 180;
	private int mDefaultHeaderViewHeight = 0;
	public final static int STATE_NORMAL = 0;
	public final static int STATE_READY = 1;
	public final static int STATE_REFRESHING = 2;
	private View shadow;
	private View mHeaderViewContent;

	public HeaderView(Context context) {
		super(context);
		initView(context);
	}

	/**
	 * @param context
	 * @param attrs
	 */
	public HeaderView(Context context, AttributeSet attrs) {
		super(context, attrs);
		initView(context);
	}

	public void initView(Context context) {
		// 初始情况，设置下拉刷新view高度为0
		LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(
				LayoutParams.FILL_PARENT, 0);
		mContainer = (LinearLayout) LayoutInflater.from(context).inflate(
				R.layout.header, null);
		addView(mContainer, lp);
		setGravity(Gravity.BOTTOM);
		refreshLoadingView = (GifView) findViewById(R.id.attach);
		refreshDownView = (View) findViewById(R.id.header_arrow);
		mArrowImageView = (ImageView) findViewById(R.id.header_arrow);
		mHintTextView = (TextView) findViewById(R.id.header_hint_textview);
		shadow = findViewById(R.id.shadow);
		mHeaderViewContent = findViewById(R.id.header_content);
		mRotateUpAnim = new RotateAnimation(0.0f, -180.0f,
				Animation.RELATIVE_TO_SELF, 0.5f, Animation.RELATIVE_TO_SELF,
				0.5f);
		mRotateUpAnim.setDuration(ROTATE_ANIM_DURATION);
		mRotateUpAnim.setFillAfter(true);
		mRotateDownAnim = new RotateAnimation(-180.0f, 0.0f,
				Animation.RELATIVE_TO_SELF, 0.5f, Animation.RELATIVE_TO_SELF,
				0.5f);
		mRotateDownAnim.setDuration(ROTATE_ANIM_DURATION);
		mRotateDownAnim.setFillAfter(true);
	}

	public void setState(int state) {
		if (state == mState)
			return;
		if (state == STATE_REFRESHING) {
			// 显示进度
			mArrowImageView.clearAnimation();

			/*
			 * mArrowImageView.setVisibility(View.INVISIBLE);
			 * mProgressBar.setVisibility(View.VISIBLE);
			 */
		} else {
			// 显示箭头图片
			/*
			 * mArrowImageView.setVisibility(View.VISIBLE);
			 * mProgressBar.setVisibility(View.INVISIBLE);
			 */
		}

		switch (state) {
		case STATE_NORMAL:
			if (mState == STATE_READY) {
				mArrowImageView.startAnimation(mRotateDownAnim);
			}
			if (mState == STATE_REFRESHING) {
				mArrowImageView.clearAnimation();
			}
			mHintTextView.setText(R.string.header_hint_normal);
			break;
		case STATE_READY:
			if (mState != STATE_READY) {
				mArrowImageView.clearAnimation();
				mArrowImageView.startAnimation(mRotateUpAnim);
				mHintTextView.setText(R.string.header_hint_ready);
			}
			break;
		case STATE_REFRESHING:
			mHintTextView.setText(R.string.header_hint_loading);
			break;
		default:
		}

		mState = state;
	}

	public final int getState() {
		return mState;
	}

	public void setVisibleHeight(int height) {
		height += mDefaultHeaderViewHeight;
		if (height < 0)
			height = 0;
		LinearLayout.LayoutParams lp = (LinearLayout.LayoutParams) mContainer
				.getLayoutParams();
		lp.height = height;
		mContainer.setLayoutParams(lp);
	}

	public int getVisiableHeight() {
		return mContainer.getHeight() - mDefaultHeaderViewHeight;
	}

	public void restartLoading() {
		refreshLoadingView.reset();
	}

	public void isShowRefreshLoading(Boolean isShow) {
		if (isShow) {
			refreshLoadingView.setVisibility(View.VISIBLE);
		} else {
			refreshLoadingView.setVisibility(View.GONE);
		}
	}

	public void isShowRefreshDown(Boolean isShow) {
		if (isShow) {
			refreshDownView.setVisibility(View.VISIBLE);
		} else {
			refreshDownView.setVisibility(View.GONE);
		}
	}

	public int getContentHight() {
		return mHeaderViewContent.getHeight() + shadow.getHeight();
	}

	public void setDefaultHeaderViewHeight(int headerViewHeight) {
		this.mDefaultHeaderViewHeight = headerViewHeight;
	}
	
}