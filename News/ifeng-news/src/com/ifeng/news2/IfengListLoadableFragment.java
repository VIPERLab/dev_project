package com.ifeng.news2;

import java.util.ArrayList;
import java.util.List;

import android.text.TextUtils;

import com.ifeng.news2.bean.ListItem;
import com.ifeng.news2.util.StatisticUtil;
import com.ifeng.news2.util.WindowPrompt;
import com.qad.form.PageEntity;
import com.qad.loader.BeanLoader;
import com.qad.loader.ListLoadableFragment;
import com.qad.loader.LoadContext;
import com.qad.loader.StateAble;
import com.qad.util.WToast;
import com.umeng.analytics.MobclickAgent;

@SuppressWarnings("unchecked")
public abstract class IfengListLoadableFragment<T extends PageEntity> extends
		ListLoadableFragment<T> {
	
	protected boolean canRender = false;
	
	@Override
	public void loadFail(LoadContext<?, ?, T> context) {
		super.loadFail(context);		
		WindowPrompt.getInstance(getActivity()).showWindowStorePrompt(R.drawable.toast_slice_wrong, R.string.network_err_title, R.string.network_err_message);
	}
	
	@Override
	public void onResume() {
		super.onResume();
		if (Config.ADD_UMENG_STAT)
			MobclickAgent.onResume(getActivity());
		if(StatisticUtil.isBack){
			StatisticUtil.addRecord(this.getActivity()
					, StatisticUtil.StatisticRecordAction.page
					, "id="+StatisticUtil.doc_id+"$ref=back"+"$type=" + StatisticUtil.type);
			StatisticUtil.isBack = false;
		}
	}

	@Override
	public void onPause() {
		super.onPause();
		if (Config.ADD_UMENG_STAT)
			MobclickAgent.onPause(getActivity());
	}

	@Override
	public StateAble getStateAble() {
		return null;
	}

	@Override
	public BeanLoader getLoader() {
		return IfengNewsApp.getBeanLoader();
	}
	
	public void pullDownRefresh(boolean ignoreExpired) {
	}
	
	protected void filterDuplicates(ArrayList<ListItem> resultItems, ArrayList<ListItem> totalItems) {
		List<String> documentIds = new ArrayList<String>();
		for (ListItem item : totalItems)
			documentIds.add(item.getDocumentId());

		int i = 0;
		while (true) {
			if (i >= resultItems.size())
				break;
			if (TextUtils.isEmpty(resultItems.get(i).getDocumentId())||documentIds.contains(resultItems.get(i).getDocumentId()))
				resultItems.remove(i);
			else
				i++;
		}
	}
	
	public boolean needRefresh(boolean ignoreExpired){
		return false;
	}
		
}
