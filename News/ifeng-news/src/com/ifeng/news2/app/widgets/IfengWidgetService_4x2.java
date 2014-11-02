package com.ifeng.news2.app.widgets;

import com.ifeng.news2.R;

/**
 * WidgetService 4X2
 * @author chenxi
 *
 */
public class IfengWidgetService_4x2 extends IfengWidgetService{

	public static final String PREFERENCE_KEY = "AppWidget4x2";
	
	@Override
	public int getWidgetView() {
		// TODO Auto-generated method stub
		return R.layout.appwidget_view_4_2;
	}

	@Override
	public String[] getWidgetActions() {
		// TODO Auto-generated method stub
		return IfengWidgetConstant.APP_WIDGET_ACTION_4X2;
	}

	@Override
	public Class getWidgetServiceClass() {
		// TODO Auto-generated method stub
		return IfengWidgetService_4x2.class;
	}

	@Override
	public int showDatasSize() {
		// TODO Auto-generated method stub
		return 1;
	}

	@Override
	public String getPreferenceKey() {
		// TODO Auto-generated method stub
		return PREFERENCE_KEY;
	}

	@Override
	public Class getWidgetProviderClass() {
		// TODO Auto-generated method stub
		return IfengWidgetProvider_4x2.class;
	}

	@Override
	public int[] getWidgetHeadViews() {
		// TODO Auto-generated method stub
		return new int[]{R.id.widget_img};
	}

	@Override
	public int[] getWidgetTitleViews() {
		// TODO Auto-generated method stub
		return new int[]{R.id.widget_title};
	}

	@Override
	public int[] getWidgetDateViews() {
		// TODO Auto-generated method stub
		return new int[]{R.id.widget_date};
	}

	@Override
	public int[] getWiegetItemViews() {
		// TODO Auto-generated method stub
		return new int[]{R.id.widget_body};
	}

	@Override
	public int getPageNumViews() {
		// TODO Auto-generated method stub
		return R.id.news_num_tag;
	}

}
