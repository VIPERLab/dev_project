package com.qad.app;

import java.util.List;

import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.view.View;
import android.widget.ArrayAdapter;

import com.qad.inject.ExtrasInjector;
import com.qad.inject.PreferenceInjector;
import com.qad.inject.ResourceInjector;
import com.qad.inject.SystemServiceInjector;
import com.qad.inject.ViewInjector;
import com.qad.util.ActivityTool;

public class BaseFragment extends Fragment {

	protected ActivityTool tool;
	public boolean isCreated = false;

	@Override
	public void onActivityCreated(Bundle savedInstanceState) {
		super.onActivityCreated(savedInstanceState);
		tool = new ActivityTool(getActivity());
		// do the injection
		SystemServiceInjector.inject(getActivity(), this);
		ExtrasInjector.inject(getActivity().getIntent().getExtras(),
				getActivity());
		ResourceInjector.inject(getActivity().getApplicationContext(), this);
		PreferenceInjector.inject(getActivity().getApplicationContext(), this);
		ViewInjector.inject(getView(), this);
	}

	public ArrayAdapter<Object> getSpinnerAdapter(Object[] objects) {
		return tool.getSpinnerAdapter(objects);
	}

	/**
	 * @param list
	 * @return
	 * @see practice.utils.ActivityTool#getSpinnerAdapter(java.util.List)
	 */
	public ArrayAdapter<Object> getSpinnerAdapter(List<? extends Object> list) {
		return tool.getSpinnerAdapter(list);
	}

	/**
	 * @param editView
	 * @see practice.utils.ActivityTool#hideInput(android.view.View)
	 */
	public void hideInput(View editView) {
		tool.hideInput(editView);
	}

	/**
	 * @param idName
	 * @return
	 * @see practice.utils.ActivityTool#findViewByIdName(java.lang.String)
	 */
	public View findViewByIdName(String idName) {
		return tool.findViewByIdName(idName);
	}

}
