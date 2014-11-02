package com.ifeng.news2.app.widgets;

import com.ifeng.news2.R;

/**
 * WidgetService 4X3
 * @author chenxi
 *
 */
public class IfengWidgetService_4x3 extends IfengWidgetService{

	public static final String PREFERENCE_KEY = "AppWidget4x3";
	
	@Override
	public int getWidgetView() {
		// TODO Auto-generated method stub
		return R.layout.appwidget_view_4_3;
	}

	@Override
	public String[] getWidgetActions() {
		// TODO Auto-generated method stub
		return IfengWidgetConstant.APP_WIDGET_ACTION_4X3;
	}

	@Override
	public Class getWidgetServiceClass() {
		// TODO Auto-generated method stub
		return IfengWidgetService_4x3.class;
	}

	@Override
	public int showDatasSize() {
		// TODO Auto-generated method stub
		return 2;
	}

	@Override
	public String getPreferenceKey() {
		// TODO Auto-generated method stub
		return PREFERENCE_KEY;
	}

	@Override
	public Class getWidgetProviderClass() {
		// TODO Auto-generated method stub
		return IfengWidgetProvider_4x3.class;
	}

	@Override
	public int[] getWidgetHeadViews() {
		// TODO Auto-generated method stub
		return new int[]{R.id.widget_img_1,R.id.widget_img_2};
	}

	@Override
	public int[] getWidgetTitleViews() {
		// TODO Auto-generated method stub
		return new int[]{R.id.widget_title_1,R.id.widget_title_2};
	}

	@Override
	public int[] getWidgetDateViews() {
		// TODO Auto-generated method stub
		return new int[]{R.id.widget_date_1,R.id.widget_date_2};
	}

	@Override
	public int[] getWiegetItemViews() {
		// TODO Auto-generated method stub
		return new int[]{R.id.widget_body_1,R.id.widget_body_2};
	}

	@Override
	public int getPageNumViews() {
		// TODO Auto-generated method stub
		return R.id.news_num_tag;
	}

}
