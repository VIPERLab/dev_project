package com.ifeng.news2.app.widgets;

import java.util.ArrayList;
import java.util.List;

import android.app.PendingIntent;
import android.app.Service;
import android.appwidget.AppWidgetManager;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.graphics.Bitmap;
import android.graphics.drawable.BitmapDrawable;
import android.net.NetworkInfo;
import android.os.IBinder;
import android.preference.PreferenceManager;
import android.text.TextUtils;
import android.util.Log;
import android.view.View;
import android.view.animation.Animation;
import android.view.animation.AnimationUtils;
import android.widget.ImageView;
import android.widget.RemoteViews;

import com.ifeng.news2.IfengNewsApp;
import com.ifeng.news2.R;
import com.ifeng.news2.activity.DetailActivity;
import com.ifeng.news2.bean.Channel;
import com.ifeng.news2.bean.Extension;
import com.ifeng.news2.bean.ListItem;
import com.ifeng.news2.bean.ListUnits;
import com.ifeng.news2.util.ConstantManager;
import com.ifeng.news2.util.IntentUtil;
import com.ifeng.news2.util.ReadUtil;
import com.ifeng.share.util.NetworkState;
import com.qad.loader.ImageLoader.ImageDisplayer;
import com.qad.loader.LoadContext;
import com.qad.loader.LoadListener;
import com.qad.system.PhoneManager;
import com.qad.system.listener.NetworkListener;
import com.qad.util.WToast;

/**
 * Widget Service
 * @author chenxi
 *
 */
public abstract class IfengWidgetService extends Service implements LoadListener<ListUnits> , NetworkListener{

	private int dataAccount = 0;
	private int currentIndex = 0;
	private RemoteViews remoteViews;
	private ArrayList<ListItem> widgetDatas = new ArrayList<ListItem>();

	
	/**
	 * 为WidgetView设置数据
	 * @param context
	 * @param paramList
	 */
	private void setWidgetViewDatas(Context context, List<ListItem> paramList) {
		int dataSize = paramList.size(); 
		if(dataSize <= 0 ){
			return ; 
		}
		if (this.remoteViews == null)
			this.remoteViews = new RemoteViews(getPackageName(), getWidgetView());
		
		int[] titleViewIds = getWidgetTitleViews();
		int[] dateViewIds  = getWidgetDateViews();
		int[] imageViewIds = getWidgetHeadViews();
		int[] itemViewIds  = getWiegetItemViews();
		
		
		
		for(int i = 0 ; i < dataSize ; i ++){
			if(imageViewIds == null && dateViewIds == null){
				widgetViewBindDatas(context,this.remoteViews,paramList.get(i), titleViewIds[i],0,itemViewIds[i]);
			}else{
				widgetViewBindDatas(context,this.remoteViews,paramList.get(i), titleViewIds[i],dateViewIds[i],itemViewIds[i],imageViewIds[i]);
			}
		}
		
		getDataAccount(widgetDatas);
		if(getPageNumViews() != -1){
			this.remoteViews.setTextViewText(getPageNumViews(),(this.currentIndex + 1) +"/"+this.dataAccount);
		}
		
		
	}
	
	/**
	 * 为Widget绑定数据
	 * @param context
	 * @param item
	 * @param titleId
	 * @param dateId
	 * @param itemId
	 */
	private void widgetViewBindDatas(Context context, RemoteViews remoteViews,ListItem item, int titleId,
			int dateId, int itemId ){
		widgetViewBindDatas(context, this.remoteViews,item, titleId, dateId, itemId,0);
	}
	
	/**
	 * 为Widget绑定数据
	 * @param context
	 * @param item
	 * @param titleId
	 * @param dateId
	 * @param itemId
	 * @param headId
	 */
	private void widgetViewBindDatas(Context context, final RemoteViews remoteViews,ListItem item, int titleId,
			int dateId, int itemId , final int headId) {
		// TODO Auto-generated method stub
		String title = item.getTitle();
		String updateTime = item.getUpdateTime(); 
		String thumbnail = item.getThumbnail();
		String introduction = item.getIntroduction();
		String documentId = item.getDocumentId(); 
		ArrayList<Extension> links = item.getLinks();
		
		if(!TextUtils.isEmpty(title) && titleId != 0)
			remoteViews.setTextViewText(titleId, title);
		if(!TextUtils.isEmpty(updateTime) && dateId != 0)
			remoteViews.setTextViewText(dateId, updateTime);
		if(!TextUtils.isEmpty(thumbnail) && headId != 0 ){
			IfengNewsApp.getImageLoader().startLoading(
					new LoadContext<String, ImageView, Bitmap>(thumbnail, new ImageView(context), Bitmap.class,
							LoadContext.FLAG_CACHE_FIRST, context), new ImageDisplayer() {
								@Override
								public void prepare(ImageView img) {
									
								}
								@Override
								public void display(ImageView img, BitmapDrawable bmp) {
			                            if (bmp != null && null != bmp.getBitmap()){// && !bmp.isRecycled()) {
			                            	remoteViews.setViewVisibility(headId, View.VISIBLE);
			                            	remoteViews.setImageViewBitmap(headId, bmp.getBitmap());
			                            	updateViews(remoteViews);
			                            }
								}
		                        @Override
		                        public void display(ImageView img, BitmapDrawable bmp,
		                                Context ctx) {
		                            	if (bmp != null && null != bmp.getBitmap()){// && !bmp.isRecycled()) {
		                            		remoteViews.setViewVisibility(headId, View.VISIBLE);
			                            	remoteViews.setImageViewBitmap(headId, bmp.getBitmap());
			                                if (null != ctx) {
			                                    // fade in
			                                    Animation fadeInAnimation = AnimationUtils.loadAnimation(ctx, R.anim.fade_in);
			                                    img.startAnimation(fadeInAnimation);
			                                }
			                                updateViews(remoteViews);
		                            	}
		                            }

								@Override
								public void fail(ImageView img) {
									// TODO Auto-generated method stub
									
		                        }

							});
		}else if(TextUtils.isEmpty(thumbnail) && headId != 0){
			remoteViews.setViewVisibility(headId, View.GONE);
		}
		
		setItemClick(context,itemId,documentId , thumbnail,introduction,links);
		updateViews(remoteViews);
	}

	/**
	 * 设置item项点击事件
	 * @param context
	 * @param paramInt
	 * @param documentId
	 * @param thumbnail
	 * @param introduction
	 * @param links
	 */
	private void setItemClick(Context context,int paramInt , String documentId , String thumbnail , String introduction , ArrayList<Extension> links) {
		if (this.remoteViews == null)
			this.remoteViews = new RemoteViews(getPackageName(), getWidgetView());
		
		Intent queryIntent = null ; 
		
		if (null != links) {
			for (Extension link : links) {
				if (null != link && !"doc".equals(link.getType())) {
					ReadUtil.markReaded(link.getDocumentId());
					queryIntent =  IntentUtil.queryIntent(context, link, IntentUtil.FLAG_REDIRECT_BACK, 
							0, null);
					queryIntent.setAction(ConstantManager.ACTION_WIDGET);
					queryIntent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP
							| Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_EXCLUDE_FROM_RECENTS);
					break;
				} else if ("doc".equals(link.getType())) {
					queryIntent = getDetailIntent(context,documentId , thumbnail , introduction ,
							null,ConstantManager.ACTION_WIDGET );
					break;
				}
			}
		}else{
			queryIntent = getDetailIntent(context,documentId , thumbnail , introduction ,
					null,ConstantManager.ACTION_WIDGET );
		}
		
		if(queryIntent == null)
			return ; 
		
		PendingIntent localPendingIntent = PendingIntent.getActivity(
				context, (int)(Math.random() * 100000), queryIntent, PendingIntent.FLAG_UPDATE_CURRENT );
		this.remoteViews.setOnClickPendingIntent(paramInt, localPendingIntent);
	}
	
	/**
	 * 获取item的intent
	 * @param context
	 * @param id
	 * @param thumbnail
	 * @param introduction
	 * @param channel
	 * @param actionType
	 * @return
	 */
	private Intent getDetailIntent(Context context, String id, String thumbnail,String introduction,
			Channel channel, String actionType){
		Intent intent = new Intent(context, DetailActivity.class);
		intent.setAction(actionType);
		intent.putExtra(ConstantManager.EXTRA_DETAIL_ID, id);
		intent.putExtra(ConstantManager.EXTRA_CHANNEL, channel);
		//将列表缩略图URL传到详情页，用于收藏保存缩略图URL
		intent.putExtra(ConstantManager.THUMBNAIL_URL, thumbnail);
		//将列表描述信息系传导详情页，用于分享
		intent.putExtra(ConstantManager.EXTRA_INTRODUCTION, introduction);
		intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP
				| Intent.FLAG_ACTIVITY_EXCLUDE_FROM_RECENTS
				| Intent.FLAG_ACTIVITY_NEW_TASK);
		
		return intent ; 
	}
	
	/**
	 * 初始化数据
	 */
	private void initDatas() {
		// TODO Auto-generated method stub
		if (NetworkState.isActiveNetworkConnected(this)) {
			IfengWidgetUtils.getWidgetDatas(this.getApplicationContext(), this , 
					IfengWidgetConstant.APP_WIDGET_DATA_URL);
		}
	}
	
	/**
	 * 获取数据大小
	 * @param datas
	 */
	private void getDataAccount(ArrayList<ListItem> datas) {
		if ((datas == null) || datas.isEmpty() || (showDatasSize() == 0)){
			this.dataAccount = 0;
			return ; 
		}
		int dataSize = datas.size();
		if(dataSize % showDatasSize() >= 0){
			this.dataAccount = dataSize / showDatasSize();
			return ; 
		}
		this.dataAccount = (dataAccount + 1);
	}
	
	/**
	 * 上一页按钮点击事件
	 */
	private void onPreBtnClick() {
		this.currentIndex = (this.currentIndex - 1);
		if (this.currentIndex < 0)
			this.currentIndex = (this.dataAccount - 1);
		setWidgetViewByIndex(this.currentIndex);
	}
	
	/**
	 * 下一页按钮点击事件
	 */
	private void onNextBtnClick() {
		this.currentIndex = (this.currentIndex + 1);
		if (this.currentIndex > this.dataAccount -1 )
			this.currentIndex = 0;
		setWidgetViewByIndex(this.currentIndex);
	}
	
	/**
	 * 刷新按钮点击事件
	 */
	private void onRefreshClick(){
		this.currentIndex = 0;
		if (!NetworkState.isActiveNetworkConnected(this)) {
			new WToast(getApplicationContext()).showMessage(R.string.not_network_message);
			return ; 
		}
		showRefreshView(this.remoteViews);
		initDatas();
	}
	
	/**
	 * 获取当前数据
	 * @param paramList
	 * @param paramInt
	 * @return
	 */
	private ArrayList<ListItem> getLocalDatas(ArrayList<ListItem> paramList, int paramInt) {
		ArrayList<ListItem> localArrayList = new ArrayList<ListItem>();
		if (paramList != null) {
			int i = paramInt * showDatasSize();
			for (int j = 0; j < showDatasSize(); j++)
				if ((paramList.size() > i + j) && (i + j >= 0))
					localArrayList.add(paramList.get(i + j));
		}
		return localArrayList;
	}
	
	/**
	 * 显示错误提示页面
	 * @param paramRemoteViews
	 */
	private void showErrorView(RemoteViews paramRemoteViews) {
		if (paramRemoteViews == null)
			paramRemoteViews = new RemoteViews(getPackageName(), getWidgetView());
		
		paramRemoteViews.setViewVisibility(R.id.widget_body_layout, View.INVISIBLE);
		paramRemoteViews.setViewVisibility(R.id.widget_loadding, View.VISIBLE);
		paramRemoteViews.setTextViewText(R.id.widget_error_or_loadding, getResources()
				.getString(R.string.appwidget_error_loading));
		paramRemoteViews.setViewVisibility(R.id.widget_bottom, View.INVISIBLE);
		updateViews(paramRemoteViews);
	}
	
	/**
	 * 显示刷新页面
	 * @param paramRemoteViews
	 */
	private void showRefreshView(RemoteViews paramRemoteViews) {
		if (paramRemoteViews == null)
			paramRemoteViews = new RemoteViews(getPackageName(), getWidgetView());
		
		paramRemoteViews.setViewVisibility(R.id.widget_body_layout, View.INVISIBLE);
		paramRemoteViews.setViewVisibility(R.id.widget_loadding, View.VISIBLE);
		paramRemoteViews.setTextViewText(R.id.widget_error_or_loadding, getResources()
				.getString(R.string.appwidget_loading));
		paramRemoteViews.setViewVisibility(R.id.widget_bottom, View.VISIBLE);
		updateViews(paramRemoteViews);
	}
	
	/**
	 * 刷新Widget
	 * @param paramRemoteViews
	 */
	private void updateViews(RemoteViews paramRemoteViews) {
		ComponentName localComponentName = new ComponentName(this.getApplicationContext(), getWidgetProviderClass());
		IfengWidgetUtils.setWidgetView(this.getApplicationContext(), 
				paramRemoteViews, getWidgetActions(), getWidgetServiceClass());
		AppWidgetManager localAppWidgetManager = AppWidgetManager
				.getInstance(this);
		if ((localComponentName != null) && (localAppWidgetManager != null)
				&& (paramRemoteViews != null))
			localAppWidgetManager.updateAppWidget(localComponentName,
					paramRemoteViews);
	}
	
	/**
	 * 根据index为widget设置数据
	 * @param paramInt
	 */
	private void setWidgetViewByIndex(int paramInt) {
		if (paramInt >= 0) {
			ArrayList<ListItem> localList2 = null;
				if ((paramInt >= this.dataAccount) && (this.dataAccount != 0))
					return;
				if (this.remoteViews == null)
					this.remoteViews = new RemoteViews(getPackageName(), getWidgetView());
				
				ArrayList<ListItem> localList1 = this.widgetDatas;
				if (localList1 != null) {
					int i = this.widgetDatas.size();
					if (i > 0 && paramInt < i) {
						localList2 = getLocalDatas(this.widgetDatas, paramInt);
					}
				}
			if ((localList2 == null) || (localList2.size() == 0)) {
				showErrorView(this.remoteViews);
				return;
			}
			this.remoteViews.setViewVisibility(R.id.widget_loadding, View.INVISIBLE);
			this.remoteViews.setViewVisibility(R.id.widget_body_layout, View.VISIBLE);
			this.remoteViews.setViewVisibility(R.id.widget_bottom, View.VISIBLE);
			
			setWidgetViewDatas(getApplicationContext(), localList2);
			ComponentName localComponentName = new ComponentName(this, getWidgetProviderClass());
			AppWidgetManager localAppWidgetManager = AppWidgetManager
					.getInstance(this);
			if ((localComponentName != null) && (localAppWidgetManager != null)
					&& (this.remoteViews != null)) {
				localAppWidgetManager.updateAppWidget(localComponentName,
						this.remoteViews);
				SharedPreferences sharedPreferences = PreferenceManager
						.getDefaultSharedPreferences(this);
				if (paramInt != sharedPreferences.getInt(getPreferenceKey(), 0))
					sharedPreferences.edit().putInt(getPreferenceKey(), paramInt)
							.commit();
			}
		}
	}
	
	@Override
	public IBinder onBind(Intent intent) {
		// TODO Auto-generated method stub
		return null;
	}

	
	@Override
	public void onCreate() {
		// TODO Auto-generated method stub
		super.onCreate();
		initDatas();
		initRegister();
	}
	

	private void initRegister() {
		// TODO Auto-generated method stub
		PhoneManager.getInstance(getApplicationContext()).addOnNetWorkChangeListener(this);
	}

	@Override
	public void onStart(Intent intent, int startId) {
		// TODO Auto-generated method stub
		if (intent == null)
			return ; 
		String action = intent.getAction();
		if(TextUtils.isEmpty(action))
			return ; 
		this.remoteViews = new RemoteViews(getPackageName(), getWidgetView());
		
		IfengWidgetUtils.setWidgetView(this.getApplicationContext(), 
				this.remoteViews, getWidgetActions(), getWidgetServiceClass());
//		getDataAccount(this.widgetDatas);
		this.currentIndex = PreferenceManager.getDefaultSharedPreferences(this).getInt(
				getPreferenceKey(), 0);
		
		String[] actionArrays = getWidgetActions();
		
		if (action.equals(actionArrays[0])) {
			onPreBtnClick();
			return;
		}
		if (action.equals(actionArrays[1])) {
			onNextBtnClick();
			return;
		}
		if (action.equals(actionArrays[2])) {
			onRefreshClick();
			return;
		}
		if ((this.widgetDatas != null) && (this.widgetDatas.size() > 0)) {
			this.currentIndex = 0;
			setWidgetViewByIndex(this.currentIndex);
			return;
		}
		if (!NetworkState.isActiveNetworkConnected(this)) {
			showErrorView(this.remoteViews);
			new WToast(getApplicationContext()).showMessage(R.string.not_network_message);
			return ; 
		}
		
		showRefreshView(this.remoteViews);
			
	}
	
	@Override
	public void onDestroy() {
		// TODO Auto-generated method stub
		super.onDestroy();
		this.remoteViews = null ; 
		if(this.widgetDatas != null){
			this.widgetDatas.clear();
			this.widgetDatas = null ; 
		}
		PhoneManager.getInstance(getApplicationContext()).
				removeNetworkChangeListioner(this);
	}

	@Override
	public void postExecut(LoadContext<?, ?, ListUnits> context) {
		// TODO Auto-generated method stub
		
		ArrayList<ListItem> loadDatas = context.getResult().getWidgetItems();
		
		if(loadDatas ==null){
			return;
		}
		//过滤不正确的数据，如title为空，则不显示该条数据
		IfengWidgetUtils.filerInvalidItems(loadDatas);
		
		//check the integrity of data
		// 如果加载得到结果少于2条，则显示加载失败
		if (loadDatas.size() == 0 || loadDatas.size() < 2 ) {
			context.setResult(null);
			return;
		}
		
	}

	@Override
	public void loadComplete(final LoadContext<?, ?, ListUnits> context) {
		// TODO Auto-generated method stub
		ArrayList<ListItem> loadDatas = (ArrayList<ListItem>) context.getResult().getWidgetItems();
		if(loadDatas != null && !loadDatas.isEmpty() ){
			if(this.widgetDatas == null)
				this.widgetDatas =new ArrayList<ListItem>();
			this.widgetDatas.clear();
			this.widgetDatas.addAll(loadDatas);
			setWidgetViewByIndex(currentIndex); 
		}
	}

	@Override
	public void loadFail(LoadContext<?, ?, ListUnits> context) {
		// TODO Auto-generated method stub
		showErrorView(remoteViews);
	}
	
	
	
	@Override
	public void onWifiConnected(NetworkInfo networkInfo) {
		// TODO Auto-generated method stub
		if(this.widgetDatas == null || this.widgetDatas.size() <= 0){
			IfengWidgetUtils.getWidgetDatas(this.getApplicationContext(), this , 
					IfengWidgetConstant.APP_WIDGET_DATA_URL);
		}
	}

	@Override
	public void onMobileConnected(NetworkInfo networkInfo) {
		// TODO Auto-generated method stub
		if(this.widgetDatas == null || this.widgetDatas.size() <= 0){
			IfengWidgetUtils.getWidgetDatas(this.getApplicationContext(), this , 
					IfengWidgetConstant.APP_WIDGET_DATA_URL);
		}
	}

	@Override
	public void onDisconnected(NetworkInfo networkInfo) {
		// TODO Auto-generated method stub
	}

	//获取widget的layout
	public abstract int getWidgetView();
	//获取widget的事件action
	public abstract String[] getWidgetActions();
	//获取绑定的service
	public abstract Class getWidgetServiceClass();
	//获取需要显示的item项数
	public abstract int showDatasSize();
	//获取preference的保存的key名称
	public abstract String getPreferenceKey();
	//获取绑定的provider
	public abstract Class getWidgetProviderClass();
	//获取所有的img的id数组
	public abstract int[] getWidgetHeadViews();
	//获取所有的标题的id数组
	public abstract int[] getWidgetTitleViews();
	//获取所有的日期的id数组
	public abstract int[] getWidgetDateViews();
	//获取所有的item项的id数组
	public abstract int[] getWiegetItemViews();
	//获取页数的id
	public abstract int getPageNumViews();
	
}
