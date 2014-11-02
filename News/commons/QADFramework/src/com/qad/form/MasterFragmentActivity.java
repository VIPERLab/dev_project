package com.qad.form;

import java.util.ArrayList;

import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentTransaction;
import android.util.Log;
import android.view.View;

import com.qad.app.BaseFragmentActivity;

public abstract class MasterFragmentActivity extends BaseFragmentActivity {

	/**
	 * 内容ViewGroup要求的id名称
	 */
	public static final String CONTENT_ID_NAME = "content";

	private static final String STATE_CURRENT_NAVIGATEID = "currentNavigateID";

	private FragmentManager mFragmentManager;

	private View currentNavigatorView;// 获取当前指示焦点的目标

	private String currentNavigateId;

	private Fragment currentNavigateFragment;

	private onNavigateListener mNavigateListener = null;

	private onUnNavigateListener mUnNavigateListener = null;

	private ArrayList<View> navViews = new ArrayList<View>();

	private static int contentId;

	/**
	 * 发生导航时的监听器
	 * 
	 * @author 13leaf
	 * 
	 */
	public interface onNavigateListener {

		/**
		 * 当导航发生时被调用
		 * 
		 * @param tag
		 * @param intent
		 * @return 是否继续处理导航。若返回true，将不处理导航
		 */
		boolean onNavigation(String tag, Fragment fragment);
	}

	public interface onUnNavigateListener {
		/**
		 * 当导航丢失焦点时被调用
		 */

		boolean onUnNavigation(String tag, Fragment fragment);
	}

	public abstract int getContentViewGroupId();

	protected static class NavigateEntry {

		public NavigateEntry(String contentId, Fragment fragment) {
			this.contentId = contentId;
			this.fragment = fragment;
		}

		public final String contentId;
		public final Fragment fragment;
	}

	@Override
	protected void onSaveInstanceState(Bundle outState) {
		// save current navigate
		super.onSaveInstanceState(outState);
		outState.putString("tag", currentNavigateId);
	}

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		contentId = getContentViewGroupId();
		if (contentId < 1)
			throw new RuntimeException("getContentViewGroup传入资源ID不正确!");
		mFragmentManager = getSupportFragmentManager();
		currentNavigateId = null;
		currentNavigateFragment = null;
	}

	@Override
	protected void onResume() {
		super.onResume();
	}

	@Override
	protected void onDestroy() {
		super.onDestroy();
		navViews.clear();
	}

	/**
	 * 将导航的视图绑定到某个Activity中。点击导航视图会切换content。若希望设置绑定时立即呈现，请调用重载函数<br>
	 * 必须在setContentView之后调用此方法。<br>
	 * <strong>建议不要将按钮重新绑定某个活动，否则绑定前启动的活动将持续占用资源。</strong>
	 * 
	 * @param navView
	 *            引起链接行为的导航View
	 * @param intent
	 *            导航Activity目标的Intent
	 * @param tag
	 *            标识符
	 * @param current
	 *            是否当前立即显示
	 */

	public void bindNavigate(View navView, final Fragment fragment,
			final String tag, boolean current) {
		if (current) {
			currentNavigatorView = navView;
			navView.setSelected(true);
			navigate(tag, fragment, true);
		}
		navViews.add(navView);
		navView.setOnClickListener(new View.OnClickListener() {
			@Override
			public void onClick(View v) {
				// ensure selected
				if (currentNavigatorView != null) {
					currentNavigatorView.setSelected(false);
				}
				v.setSelected(true);
				currentNavigatorView = v;
				navigate(tag, fragment);
			}
		});
	}

	public void bindNavigate(int id, Fragment contentFragment, String tag,
			boolean current) {
		bindNavigate(findViewById(id), contentFragment, tag, current);
	}

	public void bindNavigate(int id, Fragment contentFragment, String tag) {
		bindNavigate(findViewById(id), contentFragment, tag, false);
	}

	public void bindNavigate(View navView, Fragment fragment, String tag) {
		bindNavigate(navView, fragment, tag, false);
	}

	/**
	 * 
	 * @param navView
	 */
	public void unBindNavigate(View navView) {
		navView.setOnClickListener(null);
		navViews.remove(navView);
	}

	/**
	 * 设置Navigate监听器。以此可以在导航发生之前捕获
	 * 
	 * @param listener
	 */
	public void setOnNavigateListener(onNavigateListener listener) {
		mNavigateListener = listener;
	}

	public void setOnUnNavigateListener(onUnNavigateListener listener) {
		mUnNavigateListener = listener;
	}

	public void navigate(String tag) {
		Fragment fragment = mFragmentManager.findFragmentByTag(tag);
		if (fragment == null)
			throw new NullPointerException("Have you ever bindNavigator?");
		navigate(tag, fragment, true);
	}

	public void navigate(String tag, Fragment fragment) {
		navigate(tag, fragment, true);
	}

	public void navigate(String tag, Fragment fragment, boolean forceStart) {
		if (fragment == null || tag == null || tag.length() == 0)
			throw new NullPointerException();
		if (!forceStart && currentNavigateId != null
				&& currentNavigateId.equals(tag))
			return;
		if (mUnNavigateListener != null && tag != null) {
			mUnNavigateListener.onUnNavigation(currentNavigateId,
					currentNavigateFragment);
		}
		FragmentTransaction contentTransaction = mFragmentManager
				.beginTransaction();
		if (currentNavigateFragment != null) {
			contentTransaction.hide(currentNavigateFragment);
			Log.d("MasterFragmentActivity", "hide" + tag);
		}
		if (mFragmentManager.findFragmentByTag(tag) == null) {
			fragment.setRetainInstance(true);
			contentTransaction.add(contentId, fragment, tag);
			Log.d("MasterFragmentActivity", "add" + tag);
			contentTransaction.attach(fragment);
			Log.d("MasterFragmentActivity", "attach" + tag);
		} else {
			if(fragment.isDetached()){
				contentTransaction.attach(fragment);
			}
			contentTransaction.show(fragment);
			Log.d("MasterFragmentActivity", "show" + tag);
		}
		contentTransaction.commit();
		if (fragment != null) {
			Log.d("MasterFragmentActivity", "" + fragment + "-----" + tag);
		}
		currentNavigateId = tag;
		currentNavigateFragment = fragment;
		if (mNavigateListener != null) {
			Log.d("tag", "111111111111111");
			mNavigateListener.onNavigation(tag, fragment);
		}
	}

	/**
	 * 获得当前被选中的navigatorFragment(假如调用bindNavigator绑定后)
	 * 
	 * @return the currentNavigatorFragment
	 */
	public Fragment getCurrentNavigateFragment() {
		return currentNavigateFragment;
	}

	public void setCurrentNavigateTag(String tag) {
		this.currentNavigateId = tag;
	}

}
