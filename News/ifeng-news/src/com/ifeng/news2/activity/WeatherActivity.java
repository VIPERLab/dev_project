package com.ifeng.news2.activity;

import android.content.Intent;
import android.graphics.Bitmap;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.Window;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.TextView;

import com.handmark.pulltorefresh.library.PullToRefreshBase.OnRefreshListener2;
import com.handmark.pulltorefresh.library.PullToRefreshListView;
import com.ifeng.news2.IfengNewsApp;
import com.ifeng.news2.Parsers;
import com.ifeng.news2.R;
import com.ifeng.news2.R.id;
import com.ifeng.news2.adapter.WeatherAdapter;
import com.ifeng.news2.bean.WeatherBean;
import com.ifeng.news2.bean.WeatherBeans;
import com.ifeng.news2.util.ConstantManager;
import com.ifeng.news2.util.StatisticUtil;
import com.ifeng.news2.util.WindowPrompt;
import com.ifeng.news2.weather.AsyncImageLoader;
import com.ifeng.news2.weather.WeatherManager;
import com.ifeng.share.util.NetworkState;
import com.qad.annotation.InjectView;
import com.qad.loader.LoadContext;
import com.qad.loader.LoadListener;

public class WeatherActivity extends AppBaseActivity implements View.OnClickListener,LoadListener<WeatherBeans>{
	@InjectView(id=id.back)
	ImageView back;
	@InjectView(id=id.change_city_button)
	View weatherChangeView;
	PullToRefreshListView pullToRefreshListView;
	ListView weatherView;
	WeatherAdapter weatherAdapter;
	WeatherBean todayWeather;
	WeatherBeans weatherBeans;
	View todayView;
	public String chooseCityName = "";
	public Boolean isRefreshWeather=true;
	public static final int RESULT_SELECTED_CITY = 0x1;
	AsyncImageLoader asyncImageLoader = new AsyncImageLoader();
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		super.onCreate(savedInstanceState);
		setContentView(R.layout.weather);
		init();
		beginStatistic();
	}
	private void beginStatistic() {
		// TODO Auto-generated method stub
		StatisticUtil.addRecord(this
				, StatisticUtil.StatisticRecordAction.page
				, "id=noid$ref=ys"+"$type=" + StatisticUtil.StatisticPageType.set);
	}
	private void init() {
		back.setOnClickListener(this);
		weatherChangeView.setOnClickListener(this);
		setRefreshListener();
		
		if(todayWeather!=null){
			initTodayWeather();
			initOtherWeathers();
		}else{
			if(isRefreshWeather){
				isRefreshWeather=false;
				refreshingWeather();
			}

		}
	}
	private void refreshingWeather() {
		pullToRefreshListView.showRefreshingView();
		loadWeather();
	}
	
	private void initTodayWeather(){
		LayoutInflater inflater= LayoutInflater.from(this);
		todayView = inflater.inflate(R.layout.weather_today_item,null);
		TextView weekly = (TextView)todayView.findViewById(R.id.weekly);
		TextView cityName = (TextView)todayView.findViewById(R.id.city);
		TextView date = (TextView)todayView.findViewById(R.id.date);
		TextView temperature = (TextView)todayView.findViewById(R.id.temperature);
		TextView state = (TextView)todayView.findViewById(R.id.state);
		TextView date_nongli = (TextView)todayView.findViewById(R.id.date_nongli);
		final ImageView icon = (ImageView)todayView.findViewById(R.id.icon);
		weekly.setText(todayWeather.getWeek());
		date.setText(todayWeather.getDate_time());
		temperature.setText(WeatherManager.getTemperatureText(todayWeather));
		cityName.setText(todayWeather.getCity_name());
		date_nongli.setText("农历 "+todayWeather.getMoon());
		state.setText(todayWeather.getDetail_day_info());
		Bitmap cacheImage = asyncImageLoader.loadDrawable(todayWeather.getIphone_small_day_image(),
				new AsyncImageLoader.ImageCallback() {
			public void imageLoaded(Bitmap bitmap) {
				icon.setImageBitmap(bitmap);
			}
		});
		if (cacheImage != null) {
			icon.setImageBitmap(cacheImage);
		}
		weatherView.addHeaderView(todayView);
	}
	private void initOtherWeathers(){
		weatherAdapter = new WeatherAdapter(this, weatherBeans);
		weatherView.setAdapter(weatherAdapter);
	}
	
	@Override
	protected void onResume() {
		// TODO Auto-generated method stub
		StatisticUtil.doc_id = "noid";
		StatisticUtil.type = StatisticUtil.StatisticPageType.set.toString() ; 
		super.onResume();
	}
	
	private void setRefreshListener(){
		pullToRefreshListView =(PullToRefreshListView)findViewById(R.id.weather_detail_list);
		pullToRefreshListView.setShowIndicator(false);
		weatherView = pullToRefreshListView.getRefreshableView();
		weatherView.setFadingEdgeLength(0);
		weatherView.setSelector(android.R.color.transparent);
		pullToRefreshListView.setVerticalFadingEdgeEnabled(false);
		pullToRefreshListView.setOnRefreshListener(new OnRefreshListener2() {
			@Override
			public void onPullDownToRefresh() {
				if(NetworkState.isActiveNetworkConnected(WeatherActivity.this)){
					loadWeather();
				}else{
					windowPrompt.showWindowStorePrompt(R.drawable.toast_slice_wrong, R.string.network_err_title, R.string.network_err_message);
					pullToRefreshListView.onRefreshComplete();
				}
			}
			@Override
			public void onPullUpToRefresh() {
				//pullToRefreshListView.onRefreshComplete();
			}
		});
	}
	
	private void loadWeather() {
		new Thread(new Runnable() {			
			@Override
			public void run() {
				IfengNewsApp
				.getBeanLoader()
				.startLoading(
						new LoadContext<String, LoadListener<WeatherBeans>, WeatherBeans>(
								WeatherManager.getWeatherDetailUrl(WeatherManager.getChooseCity(WeatherActivity.this)),
								WeatherActivity.this, WeatherBeans.class, Parsers
										.newWeatherBeansParser(),
								LoadContext.FLAG_HTTP_FIRST,true));
			}
		}).start();		
	}
	
//	class PullRefresh extends AsyncTask<Integer, Integer, Integer>{
//		@Override
//		protected Integer doInBackground(Integer... params) {
//			WeatherManager.initWeatherDatasByCity(chooseCityName);
//			return 0;
//		}
//
//		@Override
//		protected void onPostExecute(Integer result) {
//			super.onPostExecute(result);
//			resetView();
//		}
//
//	}
	private void resetView(){
		setContentView(R.layout.weather);
		init();
	}
	
	@Override
	public void onClick(View v) {
		if(v==weatherChangeView){
			Intent intent = new Intent(WeatherActivity.this,ChangeCityActivity.class);
			startActivityForResult(intent, 0);
			overridePendingTransition(R.anim.in_from_right,
                    R.anim.out_to_left);
		}else if(v==back){
			onBackPressed();
		}
	}
	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		super.onActivityResult(requestCode, resultCode, data);
		if (resultCode == WeatherActivity.RESULT_SELECTED_CITY
				&& data != null)
			initWeatherByCity(data);
	}
	
	public void initWeatherByCity(Intent data){
		if(!NetworkState.isActiveNetworkConnected(WeatherActivity.this)){
			windowPrompt.showWindowStorePrompt(R.drawable.toast_slice_wrong, R.string.network_err_title, R.string.network_err_message);
			return;
		}
		Intent intent = data;
		if (intent != null) {
			chooseCityName = intent.getStringExtra("name");
			WeatherManager.saveChooseCity(this, chooseCityName);
		}
		if(chooseCityName==null || chooseCityName.length()==0){
			chooseCityName = WeatherManager.default_city;
		}
		refreshingWeather();
	}
	
	@Override
    public void onBackPressed() {
		StatisticUtil.isBack = true ; 
		ConstantManager.isSettingsShow = true ; 
		Intent intent = new Intent();
		intent.putExtra("todayWeather", todayWeather);
		setResult(100, intent);
        finish();
        overridePendingTransition(R.anim.in_from_left, R.anim.out_to_right);;
    }
	
	@Override
	public void postExecut(LoadContext<?, ?, WeatherBeans> context) {
		if(context.getResult()==null || context.getResult().size()<7) {
			context.setResult(null);
		}
	}
	@Override
	public void loadComplete(LoadContext<?, ?, WeatherBeans> context) {
		weatherBeans = context.getResult();
		todayWeather = weatherBeans.remove(0);
		resetView();		
	}
	
	@Override
	public void loadFail(LoadContext<?, ?, WeatherBeans> context) {
		//TODO
	}

}
