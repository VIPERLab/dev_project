/*******************************************************************************
 * Copyright 2011, 2012 Chris Banes.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *******************************************************************************/
package com.handmark.pulltorefresh.library;

import android.content.Context;
import android.util.AttributeSet;
import android.util.Log;

import com.handmark.pulltorefresh.library.internal.IfengScrollView;
import com.qad.R;

public class PullToRefreshScrollView extends PullToRefreshBase<IfengScrollView> {

	
	private final OnRefreshListener defaultOnRefreshListener = new OnRefreshListener() {
		@Override
		public void onRefresh() {
			onRefreshComplete();
		}

	};
	
	public PullToRefreshScrollView(Context context) {
		super(context);
	}

	public PullToRefreshScrollView(Context context, AttributeSet attrs) {
		super(context, attrs);
	}

	public PullToRefreshScrollView(Context context, Mode mode) {
		super(context, mode);
	}


	@Override
	protected IfengScrollView createRefreshableView(Context context, AttributeSet attrs) {
		/*
		 * 点击非跟帖区域需要将跟帖功能框隐藏，因此使用IfengScrollView来拦截touch事件并做处理 
		 * */
		IfengScrollView scrollView = new IfengScrollView(context, attrs);
//		ScrollView scrollView = new ScrollView(context, attrs);

		scrollView.setId(R.id.scrollview);
		return scrollView;
	}

	@Override
	protected boolean isReadyForPullDown() {
		return mRefreshableView.getScrollY() == 0;
	}

	@Override
	protected boolean isReadyForPullUp() {
		IfengScrollView view = getRefreshableView();
		int off=view.getScrollY()+view.getHeight()-view.getChildAt(0).getHeight();
		Log.d("text", "view.getScrollY()="+view.getScrollY()+",view.getChildAt(0).getHeight()"+view.getChildAt(0).getHeight());
		if(off==0){
			return true;
		}else{
			return false;
		}
	}
}
