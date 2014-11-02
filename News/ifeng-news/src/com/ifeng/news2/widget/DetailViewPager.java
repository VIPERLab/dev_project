package com.ifeng.news2.widget;

import java.util.ArrayList;

import com.ifeng.news2.R;

import android.content.Context;
import android.support.v4.view.PagerAdapter;
import android.support.v4.view.ViewPager;
import android.util.AttributeSet;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;

public class DetailViewPager extends ViewPager {

	private boolean can = true;
	private View onTouchListener = null;

	public DetailViewPager(Context context) {
		super(context);
		setBackgroundColor(getResources().getColor(R.color.ivory2));
	}

	public DetailViewPager(Context context, AttributeSet attrs) {
		super(context, attrs);
		setBackgroundColor(getResources().getColor(R.color.ivory2));
	}

	public void canScolling(boolean can) {
		this.can = can;
	}

	@Override
	public boolean onInterceptTouchEvent(MotionEvent arg0) {
		if (can) {
			touchEventHook();
			return super.onInterceptTouchEvent(arg0);
		} else {
			return false;
		}
	}
	
	public void setOnTouchListener(View v) {
		onTouchListener = v;
	}
	
	private void touchEventHook() {
		if (null != onTouchListener && onTouchListener.getVisibility() == View.VISIBLE) {
			onTouchListener.clearFocus();
		}
	}

	public interface onInstantiateItemListener {
		public void beforeInstantiate(int position);

		public void afterInstantiate(DetailView detailView, int position);
	}

	public static class DetailPagerAdapter extends PagerAdapter {

		private ViewPager viewPager;
		private ArrayList<String> ids;
		private onInstantiateItemListener listener;

		public DetailPagerAdapter(ViewPager viewPager, ArrayList<String> ids,
				onInstantiateItemListener listener) {
			this.viewPager = viewPager;
			this.ids = ids;
			this.listener = listener;
		}

		@Override
		public boolean isViewFromObject(View arg0, Object arg1) {

			return arg0 == arg1;
		}

		@Override
		public int getCount() {
			return ids.size();
		}

		@Override
		public void destroyItem(ViewGroup container, int position, Object object) {
			View view = viewPager.findViewWithTag(position);
			if (view != null){
				((ViewPager) container).removeView(view);
				view = null;
			}
		}

		@Override
		public Object instantiateItem(ViewGroup container, final int position) {
			listener.beforeInstantiate(position);
			DetailView newDetailView = (DetailView) viewPager
					.findViewWithTag(position);
			if (newDetailView == null) {
				newDetailView = new DetailView(viewPager.getContext());
				newDetailView.setTag(position);
			}
			listener.afterInstantiate(newDetailView, position);
			try {
				((ViewPager) container).addView(newDetailView);
			} catch (Exception e) {
			}
			return newDetailView;
		}

	}
}
