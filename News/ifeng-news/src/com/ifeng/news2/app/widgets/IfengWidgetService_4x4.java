package com.ifeng.news2.app.widgets;

import com.ifeng.news2.R;

/**
 * WidgetService 4X4
 * @author chenxi
 *
 */
public class IfengWidgetService_4x4 extends IfengWidgetService{

	public static final String PREFERENCE_KEY = "AppWidget4x4";
	
	@Override
	public int getWidgetView() {
		// TODO Auto-generated method stub
		return R.layout.appwidget_view_4_4;
	}

	@Override
	public String[] getWidgetActions() {
		// TODO Auto-generated method stub
		return IfengWidgetConstant.APP_WIDGET_ACTION_4X4;
	}

	@Override
	public Class getWidgetServiceClass() {
		// TODO Auto-generated method stub
		return IfengWidgetService_4x4.class;
	}

	@Override
	public int showDatasSize() {
		// TODO Auto-generated method stub
		return 4;
	}

	@Override
	public String getPreferenceKey() {
		// TODO Auto-generated method stub
		return PREFERENCE_KEY;
	}

	@Override
	public Class getWidgetProviderClass() {
		// TODO Auto-generated method stub
		return IfengWidgetProvider_4x4.class;
	}

	@Override
	public int[] getWidgetHeadViews() {
		// TODO Auto-generated method stub
		return new int[]{R.id.widget_img_1,R.id.widget_img_2,R.id.widget_img_3,R.id.widget_img_4};
	}

	@Override
	public int[] getWidgetTitleViews() {
		// TODO Auto-generated method stub
		return new int[]{R.id.widget_title_1,R.id.widget_title_2,R.id.widget_title_3,R.id.widget_title_4};
	}

	@Override
	public int[] getWidgetDateViews() {
		// TODO Auto-generated method stub
		return new int[]{R.id.widget_date_1,R.id.widget_date_2,R.id.widget_date_3,R.id.widget_date_4};
	}

	@Override
	public int[] getWiegetItemViews() {
		// TODO Auto-generated method stub
		return new int[]{R.id.widget_body_1,R.id.widget_body_2,R.id.widget_body_3,R.id.widget_body_4};
	}

	@Override
	public int getPageNumViews() {
		// TODO Auto-generated method stub
		return R.id.news_num_tag;
	}

}
