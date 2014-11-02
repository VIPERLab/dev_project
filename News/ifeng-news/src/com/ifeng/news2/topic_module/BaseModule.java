package com.ifeng.news2.topic_module;

import com.ifeng.news2.widget.DividerLine;

import com.ifeng.news2.activity.TopicDetailModuleActivity;

import android.content.Context;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.LinearLayout;
import android.widget.TextView;
import com.ifeng.news2.Config;
import com.ifeng.news2.IfengNewsApp;
import com.ifeng.news2.R;
import com.ifeng.news2.R.drawable;
import com.ifeng.news2.R.id;
import com.ifeng.news2.bean.Extension;
import com.ifeng.news2.bean.TopicContent;
import com.ifeng.news2.bean.TopicSubject;
import com.ifeng.news2.util.IntentUtil;
import com.ifeng.news2.util.ModuleLinksManager;
import com.ifeng.news2.util.ReadUtil;
import com.ifeng.news2.util.TopicDetailUtil;
import com.qad.loader.ImageLoader;
import java.util.ArrayList;
/**
 * 基础模块
 * @author pjw
 *
 */
public class BaseModule extends LinearLayout implements OnClickListener{
	public Context context;
	public TopicSubject subject;
	public TopicContent content;
	private ImageLoader imageLoader;
	public LayoutInflater inflate = null;
	public ArrayList<TopicContent> contents;
	public BaseModule(Context context) {
		super(context);
		init(context);
	}
	public BaseModule(Context context, AttributeSet attrs) {
		super(context, attrs);
		init(context);
	}
	/**
	 * 初始化Module
	 * @param context
	 */
	private void init(Context context){
		this.context = context;
		inflate = LayoutInflater.from(context);
		initView(context);
		setViewListener();
	}
	/**
	 * 获取默认ImageLoader
	 * @return
	 */
	public ImageLoader getDefaultLoader(){
		if(imageLoader==null){
			imageLoader = IfengNewsApp.getImageLoader();
		}
		return imageLoader;
	}
	/**
	 * 初始化 View
	 * @param context
	 */
	public void initView(Context context){
		setOrientation(VERTICAL);
	}
	/**
	 * 设置监听事件
	 */
	public void setViewListener(){}
	/**
	 * 启动构造Module
	 */
	public void create(){
		if(subject!=null && isBuildModule())buildModule();
	}
	/**
	 * 开始构建 View
	 */
	public void buildModule(){
		
	}
	/**
	 * 是否构造Module
	 * @return
	 */
	private boolean isBuildModule(){
		if((TopicDetailUtil.SOLOIMAGE_MODULE_TYPE.equals(getModuleType())
				|| TopicDetailUtil.TEXT_MODULE_TYPE.equals(getModuleType())) 
				&& content ==null ){
			return false;
		}else if((TopicDetailUtil.LINKS_MODULE_TYPE.equals(getModuleType()) 
				|| TopicDetailUtil.LIST_MODULE_TYPE.equals(getModuleType())
				|| TopicDetailUtil.ALBUM_MODULE_TYPE.equals(getModuleType())) 
				&& (contents ==null || contents.size()==0)){
			return false;
		}
		return true;
	}
	/**
	 * 获取当前模块类型
	 * @return title|soloImage|text|links|list|slides|album
	 */
	public String getModuleType(){
		return subject.getView();
	}
	/**
	 * 点击事件处理
	 */
	@Override
	public void onClick(View v) {
		
	}
	/**
	 * 设置模块数据
	 * @param subject
	 */
	public void setDatas(TopicSubject subject){
		this.subject = subject;
		this.contents = subject.getPodItems();
		//将专题Id保存到每一项的content中，用于跳转后统计
		for (TopicContent topicContent : contents) {
			topicContent.setTopicId(subject.getTopicId());
		}
		this.content = subject.getContent();		
	}
	/**
	 * 获取分隔符View
	 * @return
	 */
	public View getDividerView(){
		return LayoutInflater.from(context).inflate(R.layout.list_item_diver_module, null);
	}
	/**
	 * 添加标题view
	 */
	public View getLeftTitleView(String title){
		View view=LayoutInflater.from(context).inflate(R.layout.title_left_module, null);
		view.setBackgroundResource(R.drawable.channellist_selector);
		TextView titleView = (TextView)view.findViewById(id.title);
		titleView.setText(title);
		 DividerLine line = (DividerLine)view.findViewById(id.channelDivider);
		if (TopicDetailModuleActivity.STYLE.equals("normal")) {
          line.setNormalDivider(false);
          titleView.setTextColor(getContext().getResources().getColor(R.color.title_color));
        } else {
          line.setNormalDivider(true);
          titleView.setTextColor(getContext().getResources().getColor(R.color.topic_slider_inactive_color));
        }
		return view;
	}
	
	/**
	 * 添加阴影效果
	 */
	public View getShadowView(boolean isTop){
		View view=LayoutInflater.from(context).inflate(R.layout.topic_bottom_shadow, null);
		if (isTop) 
			view.setBackgroundResource(drawable.topic_sub_title_top_shadow);
		else 
			view.setBackgroundResource(drawable.topic_sub_title_shadow);
		return view;
	}
	
	class ModuleClickListener implements OnClickListener{
		private TopicContent content;
		private int position = 0;
		public ModuleClickListener(TopicContent content){
			this.content = content;
		}
		public ModuleClickListener(TopicContent content,int position){
			this.content = content;
			this.position = position;
		}
		@Override
		public void onClick(View v) {
			Extension defaultExtension = ModuleLinksManager.getTopicLink(content.getLinks());
			if(defaultExtension!=null){
				defaultExtension.setCategory(content.getTopicId());
				ReadUtil.markReaded(defaultExtension.getUrl());
				IntentUtil.startActivityWithPos(context, defaultExtension,position);
				// 将标题变灰，表示文章已阅读
				final View finalV = v;
				if (null == v) {
                  return;
                }
				  v.postDelayed(new Runnable() {
				    @Override
				    public void run() {
				      /*
				       * 解决崩溃日志中bug, 
				       * 原因分析：这里改变颜色是延时操作，如果用户点击文章后，在一秒钟之内退出专题，
				       * activity 执行onDestroy  remove掉添加的view,这是执行字变颜色view为null 程序报NullPointException
				       * 解决方案：
				       * 1.try  catch 住
				       * 2.判读finalV 、finalV.findViewById(id.title) 是否为空
				       * 最终选第一个，原因可能刚判断完finalV 、finalV.findViewById(id.title)不为null 执行改变颜色时被回收掉了，这是也会挂掉
				       * */
				      try {
				      ((TextView)finalV.findViewById(id.title)).setTextColor(getResources().getColor(R.color.list_readed_text_color));
				      } catch (Exception e) {
				      }
				    }
				  }, Config.AUTO_PULL_TIME);
				
			}
		}
		
	}
}
