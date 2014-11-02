package com.ifeng.news2.widget;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.net.Uri;
import android.text.SpannableString;
import android.text.Spanned;
import android.text.TextUtils;
import android.text.style.StyleSpan;
import android.util.AttributeSet;
import android.util.DisplayMetrics;
import android.view.GestureDetector;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewConfiguration;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.ImageView.ScaleType;
import android.widget.RelativeLayout;
import android.widget.TextView;
import com.ifeng.news2.Config;
import com.ifeng.news2.IfengNewsApp;
import com.ifeng.news2.R;
import com.ifeng.news2.R.drawable;
import com.ifeng.news2.R.id;
import com.ifeng.news2.R.layout;
import com.ifeng.news2.advertise.AdDetailActivity;
import com.ifeng.news2.bean.Channel;
import com.ifeng.news2.bean.Extension;
import com.ifeng.news2.bean.ListItem;
import com.ifeng.news2.bean.ListUnit;
import com.ifeng.news2.bean.StringUtil;
import com.ifeng.news2.bean.TopicContent;
import com.ifeng.news2.bean.TopicSubject;
import com.ifeng.news2.bean.VideoListItem;
import com.ifeng.news2.plutus.android.view.ExposureHandler;
import com.ifeng.news2.util.ActivityStartManager;
import com.ifeng.news2.util.ConstantManager;
import com.ifeng.news2.util.IntentUtil;
import com.qad.loader.ImageLoader;
import com.qad.loader.LoadContext;
import com.qad.render.RenderAdapter;
import com.qad.view.RecyclingImageView;
import java.util.ArrayList;
import org.taptwo.android.widget.CircleFlowIndicator;
import org.taptwo.android.widget.ViewFlow;
import org.taptwo.android.widget.ViewFlow.ViewSwitchListener;
import org.taptwo.android.widget.ViewFlow.ViewSwitchToListener;

public class HeadImage extends RelativeLayout implements ViewSwitchListener, ViewSwitchToListener {

    private final static float RATIO_NORMAL = 270.0f / 480;
    private final static float RATIO_TOPIC = 530.0f / 720;
    public static final int MODE_NORMAL = 0X01;
    public static final int MODE_TOPIC = 0X02;
    public int MODE = MODE_NORMAL;

    public static boolean isUpAndDown = false;
	private static ListUnit headImageUnit = null;
	private static ArrayList<VideoListItem> headImageVideoUnit = null;
	
	//private static ListUnits units = null;
//	@SuppressWarnings("unused")
//	private GestureDetector mInterruptDetector;

	private int mTouchSlop;
	private float mLastMotionX;
	private float mLastMotionY;

	ArrayList<?> data = null;
	private Channel channel = null;
	private FlowAdapter adapter = null;
	private VideoFlowAdapter videoAdapter = null;

	TextView title;
	TextView imageTag;
	TextView topicTitle;
	ViewFlow viewFlow;
	View leftModule;
	TextView leftModuleTitle;
	ChannelList list;
	RenderAdapter mAdapter;
	CircleFlowIndicator circleFlowIndicator;
	
	//视频修改
	//ArrayList<ListItem> data = null;//new ArrayList<ListItem>();
	public HeadImage(Context context, AttributeSet attrs, int defStyle) {
		super(context, attrs, defStyle);
		init();
	}

	public HeadImage(Context context, AttributeSet attrs) {
		super(context, attrs);
		init();
	}

	public HeadImage(Context context, int mode) {
	  super(context);
	  MODE = mode;
      init();
	}
	
	public HeadImage(Context context) {
		super(context);
		MODE = MODE_NORMAL;
		init();
	}

	private void init() {
		LayoutInflater inflater = LayoutInflater.from(getContext());
		inflater.inflate(layout.widget_head_image, this);
//		mInterruptDetector = new GestureDetector(
//				new InterruptGestureDetectorListener());
		title = (TextView) findViewById(id.head_title);
		topicTitle = (TextView) findViewById(id.topic_title);
		imageTag = (TextView) findViewById(id.image_tag);
		viewFlow = (ViewFlow) findViewById(id.view_flow);
		leftModule = findViewById(id.topic_slider_left_module);
		DividerLine line = (DividerLine)leftModule.findViewById(id.channelDivider);
		leftModuleTitle = (TextView) leftModule.findViewById(id.title);
		circleFlowIndicator = (CircleFlowIndicator)findViewById(R.id.circleFlowIndicator);
		leftModule.setVisibility(View.GONE);
		if (MODE == MODE_NORMAL) {
		  line.setNormalDivider(false);
		  title.setVisibility(View.VISIBLE);
		  imageTag.setVisibility(View.VISIBLE);
		  topicTitle.setVisibility(View.GONE);
		  leftModule.setVisibility(View.GONE);
		  circleFlowIndicator.setVisibility(View.GONE);
		  leftModuleTitle.setTextColor(getContext().getResources().getColor(R.color.title_color));
        } else {
          line.setNormalDivider(true);
          title.setVisibility(View.GONE);
          imageTag.setVisibility(View.GONE);
          topicTitle.setVisibility(View.VISIBLE);
          leftModule.setVisibility(View.VISIBLE);
          circleFlowIndicator.setVisibility(View.VISIBLE);
          circleFlowIndicator.setFadeAble(false);
          viewFlow.setFlowIndicator(circleFlowIndicator);
          leftModuleTitle.setTextColor(getContext().getResources().getColor(R.color.topic_slider_inactive_color));
        }
		
		DisplayMetrics metrics = getResources().getDisplayMetrics();
		LayoutParams params = new LayoutParams(metrics.widthPixels, (int) (metrics.widthPixels * (MODE == MODE_NORMAL? RATIO_NORMAL :RATIO_TOPIC)));
		final ViewConfiguration configuration = ViewConfiguration.get(getContext());
		mTouchSlop = configuration.getScaledTouchSlop();
		
		viewFlow.setLayoutParams(params);
		viewFlow.setOnViewSwitchListener(this);
		viewFlow.setOnViewSwitchToListener(this);
		
		if (Config.ENABLE_ADVER)
			ExposureHandler.init();
	}

	/**
	 * headUnit 焦点图数据
	 * channel 焦点图所属频道，用于统计
	 * @param unit
	 * @param channel
	 */
	public synchronized void render(final Object unit, Channel channel) {
//		ListUnit headUnit = units.get(0);
		this.channel = channel;
		if (unit == null) {
			return;
		}
		boolean isNormal;
		ListUnit headUnit = null; 
		TopicSubject subject = null;
		if (unit instanceof ListUnit) {
		  isNormal = true;
		  headUnit = (ListUnit)unit;
		  setUnit(headUnit);
        } else {
          subject = (TopicSubject)unit;
          isNormal = false;
          //TODO 标志位 设置不同颜色
          if (TextUtils.isEmpty(subject.getTitle())) {
//            leftModule.setVisibility(View.GONE);
            leftModuleTitle.setVisibility(View.GONE);
          } else {
            leftModuleTitle.setText(subject.getTitle());
//            leftModule.setVisibility(View.VISIBLE);
            leftModuleTitle.setVisibility(View.VISIBLE);
          }
        }
		data = (isNormal ? headUnit.getUnitListItems() : subject.getPodItems());
		if(viewFlow.getAdapter()==null){
			adapter = new FlowAdapter(unit);
		} else {
			if (isNormal) {
			  adapter.listUnit = headUnit;
            } else {
              adapter.subject = subject;
            }
			adapter.notifyDataSetChanged();
		}
		 if (isNormal) {
		   viewFlow.setAdapter(adapter);
         } else {
           if (subject.getPodItems().size() > 0 && subject.getPodItems().size()-1 >= subject.getLastSelectionPosition()) {
             viewFlow.setAdapter(adapter, subject.getLastSelectionPosition());
           } else {
             viewFlow.setAdapter(adapter);
           }
         }
		if (data.size() > 0) {
			onSwitched(null, 0);
		}
	}
	/**
	 * 视频频道添加
	 * @param headUnit
	 * @param channel
	 */
	public synchronized void render(final ArrayList<VideoListItem> headUnit, Channel channel) {
		this.channel = channel;
		if (headUnit == null) {
			return;
		}
		setVideoUnit(headUnit);
		data = headUnit;
		if(viewFlow.getAdapter()==null){
			videoAdapter = new VideoFlowAdapter(headUnit);
		} else {
			videoAdapter.unit = headUnit;
			videoAdapter.notifyDataSetChanged();
		}
		viewFlow.setAdapter(videoAdapter);
		if (data.size() > 0) {
			onSwitched(null, 0);
		}
	}

	private class InterruptGestureDetectorListener extends
			GestureDetector.SimpleOnGestureListener {

		@Override
		public boolean onDown(MotionEvent e) {
			list.isStopScroll = false;
			return false;
		}

		@Override
		public boolean onScroll(MotionEvent e1, MotionEvent e2,
				float distanceX, float distanceY) {
			if (Math.abs(e1.getX() - e2.getX()) >= 25 && list != null) {
				list.isStopScroll = true;
			} else {
				list.isStopScroll = false;
			}
			return false;
		}

		@Override
		public boolean onSingleTapUp(MotionEvent e) {
			// TODO Auto-generated method stub
			return false;
		}

	}

	private class FlowAdapter extends BaseAdapter {

		private ListUnit listUnit;
		private TopicSubject subject;
		private boolean isNormal;

		public FlowAdapter(Object unit) {
		    if (unit instanceof ListUnit) {
		      this.listUnit = (ListUnit)unit;
		      isNormal = true;
            } else {
              //专题
              this.subject = (TopicSubject)unit;
              isNormal = false;
            }
		}
		
		@Override
		public int getCount() {
			return data.size();
		}

		@Override
		public Object getItem(int position) {
			return data.get(position);
		}

		@Override
		public long getItemId(int position) {
			return position;
		}

		@Override
		public View getView(final int position, View convertView,
				ViewGroup parent) {
//			Log.d("Sdebug", "HeadImage: getview for #" + position);
			if (convertView == null) {				
				ImageView imageView = new RecyclingImageView(getContext());
				imageView.setId(id.thumbnail);
				imageView.setScaleType(ScaleType.CENTER_CROP);			
				convertView = imageView;
			}						
				IfengNewsApp.getImageLoader().startLoading(
						new LoadContext<String, ImageView, Bitmap>(isNormal ? listUnit.getUnitListItems().get(position).getThumbnail() : subject.getPodItems().get(position).getThumbnail(),
								(ImageView)convertView, Bitmap.class,
								LoadContext.FLAG_CACHE_FIRST, HeadImage.this.getContext()),
						new ImageLoader.DefaultImageDisplayer(getResources()
								.getDrawable(drawable.default_focus_image)));
				convertView.setOnClickListener(new View.OnClickListener() {
					@Override
					public void onClick(View v) {
					  if (isNormal) {
					    directToReadPage(v, listUnit, position);
                      } else {
                        subject.setLastSelectionPosition(position);
                        directToNormalPage(v.getContext(), subject.getPodItems().get(position).getLinks(), null, IntentUtil.FLAG_FROM_JSON_TOPIC);
                      }
					}
				});
			return convertView;
			
		}

	}
	//视频添加
	private class VideoFlowAdapter extends BaseAdapter {
	
		private ArrayList<VideoListItem> unit;

		public VideoFlowAdapter(ArrayList<VideoListItem> unit) {
			this.unit = unit;
		}
		
		@Override
		public int getCount() {
			return data.size();
		}

		@Override
		public Object getItem(int position) {
			return data.get(position);
		}

		@Override
		public long getItemId(int position) {
			return position;
		}

		@Override
		public View getView(final int position, View convertView,
				ViewGroup parent) {
//			Log.d("Sdebug", "HeadImage: getview for #" + position);
			if (convertView == null) {
				//View mView = LayoutInflater.from(getContext()).inflate(R.layout.viewflow, null);
				RelativeLayout.LayoutParams mParams = new RelativeLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT);
				RelativeLayout mLayout = new RelativeLayout(getContext());
				mLayout.setLayoutParams(mParams);
				
				ImageView imageView = new RecyclingImageView(getContext());
				imageView.setId(id.thumbnail);
				imageView.setScaleType(ScaleType.CENTER_CROP);				
				mLayout.addView(imageView,0, mParams);
				
				RelativeLayout.LayoutParams mParams_2 = new RelativeLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT);
				mParams_2.addRule(RelativeLayout.CENTER_IN_PARENT);
				ImageView imageViewIcon = new ImageView(getContext());
				imageViewIcon.setImageResource(R.drawable.video_head_icon);
				mLayout.addView(imageViewIcon,1,mParams_2);				
				convertView = mLayout;			
			}
//			ImageView mImageView = (ImageView) ((RelativeLayout)convertView).findViewById(R.id.viewflow_image);
//			mImageView.setId(id.thumbnail);
			IfengNewsApp.getImageLoader().startLoading(
					new LoadContext<String, ImageView, Bitmap>(unit.get(position).getImage(),
							(ImageView)((RelativeLayout)convertView).getChildAt(0), Bitmap.class,LoadContext.FLAG_CACHE_FIRST, HeadImage.this.getContext()),
					new ImageLoader.DefaultImageDisplayer(getResources()
							.getDrawable(drawable.default_focus_image)));
			convertView.setOnClickListener(new View.OnClickListener() {
				@Override
				public void onClick(View v) {
					directToReadPage(v, unit, position);
					
				}
			});
			return convertView;
			
		}

	}
	
	public static Extension getDefaultExtension(ArrayList<Extension> extensions) {
		if (extensions == null)
			return null;
		for (Extension extension : extensions) {
			// 取得默认调转的Extension
			if ("1".equals(extension.getIsDefault())) {
				return extension;
			}
		}
		return null;
	}

	@Override
	public void onSwitched(View view, int position) {
		// 仅改变焦点图title显示信息
		onSwitchTo(position);
	}
	
	/**
	 * 切换焦点图时，伴随改变焦点图title
	 */
	@Override
	public void onSwitchTo(int position) {
		if (position >= data.size()) {
			return;
		}
		String titleStr = "";
		if(data.get(position) instanceof ListItem){
			titleStr = ((ListItem) data.get(position)).getTitle();
		}else if(data.get(position) instanceof VideoListItem){
			titleStr = ((VideoListItem) data.get(position)).getTitle();
		}else if(data.get(position) instanceof TopicContent){
          titleStr = ((TopicContent) data.get(position)).getTitle();
		}
//		if (titleStr.length() > 18)
//			titleStr = titleStr.substring(0, 17);
		titleStr = StringUtil.getStr(titleStr, 18);
		if (TextUtils.isEmpty(titleStr)) {
			title.setVisibility(View.INVISIBLE);
		} else {
		  if (MODE == MODE_NORMAL){
		    title.setVisibility(View.VISIBLE);
		    title.setText(titleStr);
		  } else {
		    topicTitle.setText(titleStr);
		  }
		}
		
		SpannableString msp = new SpannableString((1 + position) + "/"
				+ data.size());
		msp.setSpan(new StyleSpan(android.graphics.Typeface.BOLD), 0, 1,
				Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
		if (TextUtils.isEmpty(msp) || 1 == data.size()) { // 按要求：娱乐、体育等频道焦点图，如果只有一张，就去掉1/1
			imageTag.setVisibility(View.INVISIBLE);
		} else {
		    if (MODE == MODE_NORMAL) {
		      imageTag.setVisibility(View.VISIBLE);
		      imageTag.setText(msp);
            } 
		}
		//视频修改
		if(data.get(position) instanceof ListItem)
			if ("ad".equals(((ListItem) data.get(position)).getType()))
				ExposureHandler.putInQueue(((ListItem) data.get(position)).getExtra());
	}

	public void destroy() {
		if (data != null)
			data.clear();
	}

	public void setList(ChannelList list) {
		this.list = list;
	}

	@Override
	public boolean onInterceptTouchEvent(MotionEvent ev) {
		int action = ev.getAction();
		final float x = ev.getX();
		final float y = ev.getY();
		switch (action) {
		case MotionEvent.ACTION_DOWN:
			getParent().requestDisallowInterceptTouchEvent(true);
			mLastMotionX = x;
			mLastMotionY = y;
			break;
		case MotionEvent.ACTION_MOVE:
			final float xDiff = Math.abs(x - mLastMotionX);
			final float yDiff = Math.abs(y - mLastMotionY);
			if (xDiff < yDiff && yDiff > mTouchSlop) {
				getParent().requestDisallowInterceptTouchEvent(false);
			}
		}
		return super.onInterceptTouchEvent(ev);
	}

	@Override
	public boolean onTouchEvent(MotionEvent event) {
		return true;
	}

	/**
	 * According to the current location of pictures and the specified JSON
	 * object to decided which read page should be jumped to
	 * 
	 * @param v
	 * @param unit
	 * @param mCurrentScreen
	 */
	public void directToReadPage(View v, ListUnit unit,
			int mCurrentScreen) {
		if ("ad".equals(unit.getUnitListItems().get(mCurrentScreen).getType()
				.trim())) {
			Intent intent = new Intent();
			intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
			// @gm, TODO, replace substring(2) (this is to remove
			// the '\\' part of the uri path)
			String url = Uri
					.parse(unit.getUnitListItems().get(mCurrentScreen).getId())
					.getEncodedSchemeSpecificPart().substring(2);
			if ("browser".equals(Uri.parse(
					unit.getUnitListItems().get(mCurrentScreen).getId())
					.getScheme())) {
				intent.setAction(Intent.ACTION_VIEW);
				intent.setData(Uri.parse(url));
			} else {
				intent.setClass(v.getContext(), AdDetailActivity.class);
				intent.putExtra("URL", url);
			}
			v.getContext().startActivity(intent);
			((Activity) v.getContext()).overridePendingTransition(R.anim.in_from_right,
					R.anim.out_to_left);
		} else {
//			int pst = mCurrentScreen;
//			for (int i = 0; i < mCurrentScreen; i++) {
//				if ("ad".equals(unit.getBody().get(i).getType().trim())) {
//					pst--;
//				}
//			}

//			boolean successful = false;
			ArrayList<Extension> links = unit.getUnitListItems().get(mCurrentScreen).getLinks();
			directToNormalPage(v.getContext(), links, channel, IntentUtil.FLAG_FROM_HEADIMAGE);
			//TODO
//			if (!successful)
//				ActivityStartManager.startDetail(v.getContext(), pst,
//						unit.getIds(), unit.getDocUnits(),
//						Config.CHANNELS[0], ConstantManager.ACTION_FROM_APP);
		}
	}
	
	public void directToNormalPage(Context context, ArrayList<Extension> links, Channel channel, int flag){
	  if (null != links) {
	    for (Extension link : links) {
	      if (null != link && !"doc".equals(link.getType())){
	        if (IntentUtil.startActivityByExtension(context, link, flag, 0, channel)) {                     
	          //                      successful = true;
	          break;
	        }
	      } else if ("doc".equals(link.getType())) {
	        ActivityStartManager.startDetail(context, link.getUrl(), link.getThumbnail(),link.getIntroduction(), channel, IntentUtil.FLAG_FROM_HEADIMAGE == flag ? ConstantManager.ACTION_FROM_HEAD_IMAGE : ConstantManager.ACTION_FROM_TOPIC2);
	        break;
	      }
	    }
	  }
	}
	
	//视频添加
	public void directToReadPage(View v, ArrayList<VideoListItem> unit,
			int mCurrentScreen) {
		String id = unit.get(mCurrentScreen).getMemberItem().getGuid();
		String title = unit.get(mCurrentScreen).getFullTitle();
		ActivityStartManager.startDetail(v.getContext(),id,title,channel, ConstantManager.ACTION_FROM_HEAD_IMAGE);
	}
	
	public static ListUnit getUnit() {
	  return headImageUnit;
	}

	public static void setUnit(ListUnit unit) {
	  headImageUnit = unit;
	}
	//视频添加
	public static ArrayList<VideoListItem> getVideoUnit() {
	  return headImageVideoUnit;
	}

	public static void setVideoUnit(ArrayList<VideoListItem> unit) {
	  headImageVideoUnit = unit;
	}

}
