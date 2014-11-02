package com.ifeng.news2.widget;

import android.content.Context;
import android.graphics.Bitmap;
import android.view.Gravity;
import android.view.View;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.ifeng.news2.IfengNewsApp;
import com.ifeng.news2.R;
import com.ifeng.news2.R.drawable;
import com.ifeng.news2.bean.Extension;
import com.ifeng.news2.bean.ListItem;
import com.ifeng.news2.fragment.NewsMasterFragmentActivity;
import com.ifeng.news2.fragment.TopicFragment;
import com.ifeng.news2.util.IntentUtil;
import com.ifeng.news2.util.ModuleLinksManager;
import com.qad.loader.LoadContext;

/**
 * The header view class, contains 3 parts, a image view, a title view and three
 * titles of the article of the focus topic
 * 
 * @author gao_miao
 * 
 */
public class TopicFocusView extends LinearLayout {

	private ImageView imageView;
	private ListItem item;
	private Context context;
	public TopicFocusView(Context context) {
		super(context);
		this.context = context;
		setOrientation(LinearLayout.VERTICAL);
	}

	public void initFocusView(final Context context, ListItem item) {
		removeAllViews();
		this.item = item;
		LinearLayout layout = (LinearLayout) inflate(context,
				R.layout.topic_focus_view, this);
		imageView = (ImageView) layout.findViewById(R.id.focus_image);
		imageView.setOnClickListener(titleOnClickListener);
		IfengNewsApp.getImageLoader().startLoading(new LoadContext<String, ImageView, Bitmap>(
				item.getThumbnail(), imageView, Bitmap.class, LoadContext.FLAG_CACHE_FIRST));
		TextView title = (TextView) layout.findViewById(R.id.focus_title);
		title.setText(item.getTitle());
		title.setOnClickListener(titleOnClickListener);
	}

	public void initRetryView(final Context context, boolean isRetry) {
		removeAllViews();
		final TextView textView = new TextView(context);
		textView.setLayoutParams(new LayoutParams(LayoutParams.MATCH_PARENT, 60));
		textView.setGravity(Gravity.CENTER);
		textView.setBackgroundResource(drawable.channellist_selector);

		if (isRetry)
			textView.setText("获取焦点专题失败，请确认连接网络后点击重试");
		else
			textView.setText("正在载入焦点专题，请稍候");

		textView.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View v) {
				textView.setText("正在载入焦点专题，请稍候");
				// 不能再使用getCurrentNavigateFragment(), 如果要重新使用TopicFocusView，请参考
				// NewsMasterFragmentActivity考虑如何得到Fragment的引用
//				TopicFragment fragment = (TopicFragment)((NewsMasterFragmentActivity)context).getCurrentNavigateFragment();
//				fragment.loadTopicFocus();
			}
		});
		addView(textView);
	}
	
	/**
	 * Click listeners of the header view
	 */
	private OnClickListener titleOnClickListener = new OnClickListener() {

		@Override
		public void onClick(View v) {
			Extension defaultExtension = ModuleLinksManager.getTopicLink(item.getLinks());
			if(defaultExtension!=null){
				IntentUtil.startActivityWithPos(context, defaultExtension,0);
			}
			
		}
	};

}