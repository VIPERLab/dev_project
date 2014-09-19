/**
 * Copyright (c) 2005, Kuwo, Inc. All rights reserved. 
 */
package cn.kuwo.sing.bean;

import android.view.View.OnClickListener;

/**
 * 
 * @Package cn.kuwo.sing.bean
 *
 * @Date 2012-10-31, 下午5:04:29, 2012
 *
 * @Author wangming
 *
 */
public class GuideItem {
	private final int mImageRes;
	private final boolean mHasButton;
	private final int mButtonTextRes;
	private final OnClickListener mOnButtonClickListener;

	public GuideItem(final int pImageRes) {
		this(pImageRes, false, -1, null);
	}

	public GuideItem(final int pImageRes, final boolean pHasButton,
			final OnClickListener pClickListener) {
		this(pImageRes, pHasButton, -1, pClickListener);
	}

	public GuideItem(final int pImageRes, final boolean pHasButton,
			final int pButtonTextRes, final OnClickListener pClickListener) {
		this.mImageRes = pImageRes;
		this.mHasButton = pHasButton;
		this.mButtonTextRes = pButtonTextRes;
		this.mOnButtonClickListener = pClickListener;
	}

	public int getImageRes() {
		return this.mImageRes;
	}

	public boolean hasButton() {
		return this.mHasButton;
	}

	public int getButtonTextRes() {
		return this.mButtonTextRes;
	}

	public OnClickListener getOnButtonClickListener() {
		return this.mOnButtonClickListener;
	}
}
