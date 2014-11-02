package com.ifeng.news2.activity;

import java.util.ArrayList;

import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.view.WindowManager;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.Button;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.Toast;

import com.ifeng.news2.R;
import com.ifeng.news2.R.id;
import com.ifeng.news2.adapter.CityListAdapter;
import com.ifeng.news2.util.StatisticUtil;
import com.ifeng.news2.weather.WeatherDBManager;
import com.ifeng.news2.weather.WeatherManager;
import com.ifeng.news2.widget.IfengBottom;
import com.qad.annotation.InjectView;

public class ChangeCityActivity extends AppBaseActivity implements OnClickListener{
	private ArrayList<String> searchList;
	private CityListAdapter cityAdapter;
	@InjectView(id=id.citylist)
	ListView cityList;
	@InjectView(id=id.search_button)
	Button searchBtn;
	@InjectView(id=id.search_content)
	EditText searchEdit;
	@InjectView(id=id.ifeng_bottom)
	IfengBottom ifengBottom;
	public static final int RESULT_SELECTED_CITY = 0x1;
	private WeatherDBManager weatherDBManager;
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_STATE_ALWAYS_HIDDEN);  
		super.onCreate(savedInstanceState);
		setContentView(R.layout.weather_change_city);
		searchList = WeatherManager.getSearchedCitysList(this);
		initView();
		initCityList();
		if(!WeatherManager.isCitysDBExist()){
			Log.i("news", "copy start");
			new CopyThread().start();
		}else{
			Log.i("news", "citylist.db exist");
		}
		beginStatistic();
	}
	
	private void beginStatistic() {
		// TODO Auto-generated method stub
		StatisticUtil.addRecord(this
				, StatisticUtil.StatisticRecordAction.page
				, "id=noid"+"$ref=ts"+"$type=" + StatisticUtil.StatisticPageType.set);
	}
	class CopyThread extends Thread{

		@Override
		public void run() {
			WeatherManager.copyDBDatas(ChangeCityActivity.this);
		}
		
	} 
	public void initView(){
		searchBtn.setOnClickListener(this);
		ifengBottom.onClickBack();
	}
	public void initCityList(){
		cityAdapter = new CityListAdapter(this, searchList);
		cityList.setAdapter(cityAdapter);
		cityList.setOnItemClickListener(new OnItemClickListener() {
			@Override
			public void onItemClick(AdapterView<?> arg0, View arg1, int arg2,
					long arg3) {
				Intent intent = new Intent();
				intent.putExtra("name", searchList.get(arg2));
				setResult(RESULT_SELECTED_CITY, intent);
				finish();
			}
		});
	}
	@Override
	public void onClick(View v) {
		if(v==searchBtn){
			if(!WeatherManager.isCitysDBExist()){
				new CopyThread().start();
				showMessage("请重新搜索");
				return;
			}
			String inputName = searchEdit.getText().toString();
			weatherDBManager = new WeatherDBManager(this);
			if(weatherDBManager.isFindCity(inputName)){
				ArrayList<String> tempSearch = new ArrayList<String>();
				tempSearch.add(inputName);
				cityAdapter.updateDatas(tempSearch);
				searchList = tempSearch;
				WeatherManager.resetSearchedCitys(inputName);
			}
		}
	}
	@Override
	protected void onPause() {
		super.onPause();
		if(weatherDBManager!=null){
			weatherDBManager.closeDB();
			WeatherManager.saveSearchedCitys(this);
		}
	}
	
	@Override
    public void onBackPressed() {
		StatisticUtil.isBack = true;
        finish();
        overridePendingTransition(R.anim.in_from_left, R.anim.out_to_right);;
    }
}
