package com.ifeng.news2.app.widgets;

import com.ifeng.news2.R;

/**
 *  WidgetProvider 4X3
 * @author chenxi
 *
 */
public class IfengWidgetProvider_4x3 extends IfengWidgetProvider {

	@Override
	public String[] getWidgetActions() {
		// TODO Auto-generated method stub
		return IfengWidgetConstant.APP_WIDGET_ACTION_4X3;
	}

	@Override
	public int getWidgetLayout() {
		// TODO Auto-generated method stub
		return R.layout.appwidget_view_4_3;
	}

	@Override
	public Class getWidgetProviderClass() {
		// TODO Auto-generated method stub
		return IfengWidgetProvider_4x3.class;
	}

	@Override
	public String getWidgetServiceAction() {
		// TODO Auto-generated method stub
		return IfengWidgetConstant.APP_WIDGET_SERVICE_4X3;
	}
	

	
}
