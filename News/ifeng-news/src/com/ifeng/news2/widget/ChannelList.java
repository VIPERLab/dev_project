package com.ifeng.news2.widget;

import android.content.Context;
import android.util.AttributeSet;
import android.util.DisplayMetrics;
import android.view.Gravity;
import android.view.View;
import android.widget.LinearLayout;
import android.widget.ListAdapter;
import android.widget.TextView;
import com.ifeng.news2.R;
import com.ifeng.news2.adapter.MutilLayoutBaseAdapter;
import com.ifeng.news2.bean.Channel;
import com.ifeng.news2.bean.DocUnit;
import com.ifeng.news2.bean.Extension;
import com.ifeng.news2.util.ActivityStartManager;
import com.ifeng.news2.util.Compatible;
import com.ifeng.news2.util.ConstantManager;
import com.ifeng.news2.util.IntentUtil;
import com.ifeng.news2.util.ReadUtil;
import com.ifeng.news2.util.ReviewManager;
import com.ifeng.news2.util.StatisticUtil;
import com.qad.form.BasePageAdapter;
import com.qad.form.PageManager;
import com.qad.view.PageListView;
import java.util.ArrayList;

// @gm change PageListView to PageListViewWithHeader
public class ChannelList extends PageListViewWithHeader {

	BasePageAdapter renderAdapter;
	MutilLayoutBaseAdapter mutilLayoutAdapter;
	/* < IfengNews3.4.0_20121227, liuxiaoliang update begin */

	public static int leftPx; // 列表简介居左距离
	public static int rightPx; // 列表简介居右距离
	public static int picPx; // 缩略图宽度

	public void initFontCount(Context ct, DisplayMetrics display) {

		int leftWidth = Integer.parseInt(getResources().getString(
				R.string.description_leftWidth));
		int rightWidth = Integer.parseInt(getResources().getString(
				R.string.description_rightWidth));
		int picWidth = Integer.parseInt(getResources().getString(
				R.string.description_picWidth));

		leftPx = ReviewManager.dip2px(leftWidth, display.density);
		rightPx = ReviewManager.dip2px(rightWidth, display.density);
		picPx = ReviewManager.dip2px(picWidth, display.density);
	}

	/* IfengNews3.4.0_20121227, liuxiaoliang update end> */

	public ChannelList(Context context, AttributeSet attrs) {
		super(context, attrs);
		decorate();
	}

	public ChannelList(Context context, PageManager<?> pageManager, int flag,
			String loadButton, String loadingMsg, String loadErrorMsg) {
		super(context, pageManager, flag, loadButton, loadingMsg, loadErrorMsg);
		decorate();
	}

	public ChannelList(Context context, PageManager<?> pageManager, int flag) {
		super(context, pageManager, flag);
		decorate();
	}

	public ChannelList(Context context, PageManager<?> pageManager) {
		super(context, pageManager);
		decorate();
	}

	private void decorate() {
		setVerticalFadingEdgeEnabled(false);
		Compatible.removeOverScroll(this);
		setPadding(getPaddingLeft(), getPaddingTop() - 2, getPaddingRight(),
				getPaddingBottom());
	}

	@Override
	public void setAdapter(ListAdapter adapter) {
	  if (adapter instanceof BasePageAdapter) {
	    renderAdapter = (BasePageAdapter) adapter;
      } else {
        mutilLayoutAdapter = (MutilLayoutBaseAdapter) adapter;
      }
		super.setAdapter(adapter);
	}

	public void refresh() {
		if (renderAdapter != null) renderAdapter.notifyDataSetChanged();
		if (mutilLayoutAdapter != null) mutilLayoutAdapter.notifyDataSetChanged();
        
	}

	@SuppressWarnings("rawtypes")
	@Override
	public void bindPageManager(PageManager pageManager) {
		super.bindPageManager(pageManager);
		// add listioner for change trigger mode
		// ensure trigger mode
		setTriggerMode(AUTO_MODE);
		/*
		 * pageManager.addOnPageLoadListioner(new PageLoadAdapter(){
		 * 
		 * @Override public void onPageLoadComplete(int loadPageNo, int pageSum,
		 * Object content) { if(loadPageNo==3){
		 * setTriggerMode(PageListView.MANUAL_MODE); } }
		 * 
		 * @Override public void onPageLoadFail(int loadPageNo, int pageSum) {
		 * if(loadPageNo==1){ //show retry } } });
		 */
	}

	public View getFooter() {
		return loadSwitcher;
	}

	@Override
	public View initLoadingView() {
		LinearLayout loadingLayout = new LinearLayout(getContext());
		loadingLayout.setGravity(Gravity.CENTER);
		loadingLayout.setOrientation(LinearLayout.HORIZONTAL);
		GifView gifView = new GifView(getContext());
		gifView.setLayoutParams(new android.view.ViewGroup.LayoutParams(
				android.view.ViewGroup.LayoutParams.WRAP_CONTENT,
				android.view.ViewGroup.LayoutParams.WRAP_CONTENT));
		gifView.setBackgroundResource(R.drawable.loading);
		loadingLayout.addView(gifView);
		TextView textView = new TextView(getContext());
		textView.setGravity(Gravity.CENTER);
		textView.setSingleLine(true);
		textView.setTextSize(17);
		textView.setPadding(12, 0, 0, 0);
		textView.setText(loadingMsg);
		loadingLayout.addView(textView);
		return loadingLayout;
	}

	public void resetListFooter(int pageNum) {
		if (pageNum > 1) {
			removeFooterView(getFooter());
			addFooterView(getFooter());
			setTriggerMode(PageListView.AUTO_MODE);
		}
	}

	// @lxl, for list topic ,and so on begin
	// dispatch message
	public static void goToReadPage(Context context, int position,
			ArrayList<String> ids, ArrayList<DocUnit> docUnits,
			Channel channel, String actionType, ArrayList<Extension> links) {
		boolean successful = false;

		if (null != links) {
			for (Extension link : links) {
				if (null != link && !"doc".equals(link.getType())) {
					ReadUtil.markReaded(link.getDocumentId());
					if (IntentUtil.startActivityByExtension(context, link)) {
						if (ConstantManager.ACTION_PUSH_LIST.equals(actionType)) {
							String docId = link.getDocumentId();
							if (docId.contains("imcp_")) {
								docId = docId.split("_")[1];
							}
							StatisticUtil.addRecord(context
									, StatisticUtil.StatisticRecordAction.openpush
									, "aid="+docId+"$type=l");
						}
						successful = true;
						break;
					}
				}
			}
		}

		if (null == docUnits || docUnits.size() < position) {
			docUnits = null;
			if (null == ids || ids.size() < position)
				return;
		}

		if (!successful)
			ActivityStartManager.startDetail(context, position, ids, docUnits,
					channel, actionType);
		if (position == 0 && ("doc".equals(links.get(0).getType())||"originalDoc".equals(links.get(0).getType()))) {
			ReadUtil.markReaded(ids.get(position));
		}
	}

	public static void goToReadPage(Context context, String id,
			Channel channel, String actionType, ArrayList<Extension> links) {
		boolean successful = false;
		//获取列表缩略图URL，缩略图URL数据在ListItem & topicContent bean 中插入到links中
		String thumbnail = null;
		String introduction = null;
		if (links.size() > 0 && null != links.get(0)){ 
			thumbnail = links.get(0).getThumbnail();
			introduction = links.get(0).getIntroduction();
		}
		
		if (null != links) {
			for (Extension link : links) {
				if (null != link && !"doc".equals(link.getType()) && !"originalDoc".equals(link.getType())) {
					ReadUtil.markReaded(link.getDocumentId());
					if (IntentUtil.startActivityByExtension(context, link,channel)) {
						if (ConstantManager.ACTION_PUSH_LIST.equals(actionType)) {
							String docId = link.getDocumentId();
							if (docId.contains("imcp_")) {
								docId = docId.split("_")[1];
							}
							StatisticUtil.addRecord(context
									, StatisticUtil.StatisticRecordAction.openpush
									, "aid="+docId+"$type=l");
						}
						successful = true;
						break;
					}
				} else if (null != link &&  ("doc".equals(link.getType())||"originalDoc".equals(link.getType()))) {
					ActivityStartManager.startDetail(context, id, thumbnail,introduction, channel, actionType);
					successful = true;
					break;
				}
			}
		}

		if (!successful){
			ActivityStartManager.startDetail(context, id, thumbnail, introduction,
					channel, actionType);
		}
		if (links.size() > 0 && ("doc".equals(links.get(0).getType())||"originalDoc".equals(links.get(0).getType()))) {
			ReadUtil.markReaded(id);
		}
	}
	
	/**
	 * 供独家频道子栏目（比如Fun来了）中启动文章使用，加入统计需要的子栏目documentId
	 * @param context
	 * @param aid
	 */
	public static void goToReadPage(Context context, String id,
			Channel channel, String actionType, ArrayList<Extension> links, String exclusiveDocumentId) {
		boolean successful = false;
		//获取列表缩略图URL，缩略图URL数据在ListItem & topicContent bean 中插入到links中
		String thumbnail = null;
		//获取列表的描述信息，用于分享
		String introduction = null ; 
		if (links.size() > 0 && null != links.get(0)){
			thumbnail = links.get(0).getThumbnail();
			introduction = links.get(0).getIntroduction();
		}
		
		if (null != links) {
			for (Extension link : links) {
				if (null != link && !"doc".equals(link.getType())) {
					ReadUtil.markReaded(link.getDocumentId());
					if (IntentUtil.startActivityByExtension(context, link,channel)) {
						if (ConstantManager.ACTION_PUSH_LIST.equals(actionType)) {
							String docId = link.getDocumentId();
							if (docId.contains("imcp_")) {
								docId = docId.split("_")[1];
							}
							StatisticUtil.addRecord(context
									, StatisticUtil.StatisticRecordAction.openpush
									, "aid="+docId+"$type=l");
						}
						successful = true;
						break;
					}
				}
			}
		}

		if (links.size() > 0 && ("doc".equals(links.get(0).getType())||"originalDoc".equals(links.get(0).getType()))) {
			ReadUtil.markReaded(id);
		}
	}
	/**
	 * 视频添加
	 * @param context
	 * @param id
	 * @param channel
	 * @param actionType
	 * @param link
	 */
	public static void goToReadPage(Context context, String id,String title,
			Channel channel, String actionType) {
		if (!id.equals("")){
			ActivityStartManager.startDetail(context, id, title, channel, actionType);
			ReadUtil.markReaded(id);
		}
	}
	// get default extension
	public static Extension getDefaultExtension(ArrayList<Extension> extensions) {
		if (extensions == null)
			return null;
		for (Extension extension : extensions) {
			if ("1".equals(extension.getIsDefault())) {
				return extension;
			}
		}
		return null;
	}
}
