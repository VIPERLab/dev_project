/**
 * Copyright (c) 2005, Kuwo, Inc. All rights reserved. 
 */
package cn.kuwo.sing.controller;

import java.util.ArrayList;
import java.util.List;

import android.content.Context;
import android.content.Intent;
import android.graphics.LinearGradient;
import android.util.TypedValue;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.view.ViewGroup.LayoutParams;
import android.widget.BaseAdapter;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import cn.kuwo.framework.log.KuwoLog;
import cn.kuwo.sing.R;
import cn.kuwo.sing.bean.GuideItem;
import cn.kuwo.sing.ui.activities.BaseActivity;
import cn.kuwo.sing.ui.activities.MainActivity;
import cn.kuwo.sing.widget.CircleFlowIndicator;
import cn.kuwo.sing.widget.ViewFlow;

/**
 * @Package cn.kuwo.sing.controller
 * 
 * @Date 2012-10-31, 下午4:29:44, 2012
 * 
 * @Author wangming
 * 
 */
public class GuideController extends BaseController {
	private final String TAG = "GuideController";
	private BaseActivity mActivity;
	private List<GuideItem> mItems = new ArrayList<GuideItem>();

	public GuideController(BaseActivity activity) {
		KuwoLog.v(TAG, "GuideController");
		mActivity = activity;
		initView();
	}

	private void initView() {
		mItems.add(new GuideItem(R.drawable.guide_1, false, null));
		mItems.add(new GuideItem(R.drawable.guide_2, false, null));
		mItems.add(new GuideItem(R.drawable.guide_3, false, null));
		mItems.add(new GuideItem(R.drawable.guide_4, false, null));
		mItems.add(new GuideItem(R.drawable.guide_5, true, mClickListener));

		ViewFlow viewFlow = (ViewFlow) mActivity.findViewById(R.id.vf_guide);
		viewFlow.setmSideBuffer(5); // 设置5张向导图
//		CircleFlowIndicator flowIndicator = (CircleFlowIndicator) mActivity.findViewById(R.id.cfi_guide);
//		viewFlow.setFlowIndicator(flowIndicator);
		viewFlow.setAdapter(new GuideAdapter(mActivity, mItems), 0);
	}

	private OnClickListener mClickListener = new OnClickListener() {

		@Override
		public void onClick(View v) {
			Intent intent = new Intent(mActivity, MainActivity.class);
			mActivity.startActivity(intent);
			mActivity.finish();
		}
	};

	class GuideAdapter extends BaseAdapter {
		private Context mContext;
		private List<GuideItem> mItems;

		public GuideAdapter(Context context, List<GuideItem> items) {
			mContext = context;
			mItems = items;
		}

		@Override
		public int getCount() {
			return mItems.size();
		}

		@Override
		public Object getItem(int position) {
			return mItems.get(position);
		}

		@Override
		public long getItemId(int position) {
			return position;
		}

		@Override
		public View getView(int position, View convertView, ViewGroup parent) {
			GuideItem item = mItems.get(position);
			LinearLayout ll = new LinearLayout(mContext);
			ll.setOrientation(LinearLayout.VERTICAL);
			ll.setLayoutParams(new LinearLayout.LayoutParams(LayoutParams.FILL_PARENT, LayoutParams.FILL_PARENT));
			ll.setBackgroundResource(item.getImageRes());
			if (item.hasButton()) {
				ImageView ivUp = new ImageView(mContext);
				ivUp.setBackgroundResource(R.drawable.guide_5_up);
				LinearLayout.LayoutParams ivUpParams = new LinearLayout.LayoutParams(LayoutParams.FILL_PARENT, 0, 13f);
				ImageView ivBelow = new ImageView(mContext);
				ivBelow.setBackgroundResource(R.drawable.guide_btn_selector);
				ivBelow.setOnClickListener(item.getOnButtonClickListener());
				LinearLayout.LayoutParams ivBelowParams = new LinearLayout.LayoutParams(LayoutParams.FILL_PARENT, 0, 3f);
				ll.addView(ivUp, ivUpParams);
				ll.addView(ivBelow, ivBelowParams);
			}
			return ll;
		}
	}
}
