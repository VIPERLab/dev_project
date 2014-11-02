package com.ifeng.news2.sport_live;

import java.util.Map;
import com.ifeng.news2.sport_live.util.SoftReferenceMap;
import com.ifeng.news2.sport_live.widget.PromptBaseView;
import com.ifeng.news2.sport_live.widget.PromptSportLiveBottom;
import android.content.Context;
import android.os.Bundle;
import android.view.ViewGroup;
import android.view.ViewGroup.LayoutParams;
import android.widget.RelativeLayout;

/**
 * 底部视图的管理类，负责缓存视图，储存共享变量，切换不同形式的底部视图，获得当前视图等功能
 * 
 * @author SunQuan
 * 
 */
public class PromptViewManager {

	// 缓存视图
	private static Map<String, PromptBaseView> map;
	// 存放视图的容器
	private ViewGroup container;
	// 管理类的实例对象，由于需要共享变量，故为singleton模式
	private static PromptViewManager instance;
	// 当前视图
	private PromptBaseView currentView;

	/**
	 * 获得当前视图
	 * 
	 * @return 当前视图类
	 */
	public PromptBaseView getCurrentView() {
		return currentView;
	}

	private PromptViewManager() {
	}

	/**
	 * 初始化实例对象
	 * 
	 * @return
	 */
	public static PromptViewManager getInstance() {
		if (instance == null) {
			instance = new PromptViewManager();
		}
		return instance;
	}
	
	/**
	 * 得到视图共享的bundle对象,保证全局只有一个bundle对象，避免内存泄露
	 * 
	 * @return
	 */
	public Bundle getShareBundle() {
		Bundle bundle = null;
		if(currentView == null || currentView.getBundle()==null){
			bundle = new Bundle();
		}else{
			bundle = currentView.getBundle();
		}
		return bundle;
	}

	/**
	 * 为底部视图设置容器
	 * 
	 * @param container
	 */
	public void setContainer(RelativeLayout container) {
		this.container = container;
	}

	/**
	 * 得到视图容器
	 * 
	 * @return
	 */
	public ViewGroup getContainer() {
		return container;
	}
	
	public boolean changeView(Class<? extends PromptBaseView> targetView){
		return changeView(targetView,null);
	}

	/**
	 * 切换底部视图
	 * 
	 * @param targetViewClass
	 * @return
	 */
	public boolean changeView(Class<? extends PromptBaseView> targetViewClass,Bundle bundle) {
		if (map == null) {
			map = new SoftReferenceMap<String, PromptBaseView>();
		}
		// 如果当前视图就是需要跳转的视图，则不进行跳转
		if (currentView != null && currentView.getClass() == targetViewClass) {
			return false;
		}

		PromptBaseView targetView = null;
		// 判断需要跳转的视图是否在缓存中
		if (map.containsKey(targetViewClass.getSimpleName())) {
			targetView = map.get(targetViewClass.getSimpleName());
			if (bundle != null) {
				targetView.setBundle(bundle);
			}
		} else {
			try {
				// 根据需要跳转的视图的字节码得到视图的实例
				targetView = targetViewClass.getConstructor(Context.class,Bundle.class)
						.newInstance(getContainer().getContext(),bundle);
				// 缓存视图
				map.put(targetViewClass.getSimpleName(), targetView);
			} catch (Exception e) {
				e.printStackTrace();
				return false;
			}
		}
		if (currentView != null) {
			// 调用上一个视图的onPause方法
			currentView.onPause();
		}

		// 将新的视图放入容器中
		container.removeAllViews();
		//fix bug targetView 可能已经有其他parent
		ViewGroup group = (ViewGroup)targetView.getContainer().getParent();
		if(group != null){
			group.removeAllViews();
		}
		container.addView(targetView.getContainer());
		// 调用当前视图的onResume方法
		targetView.onResume();
		// 刷新当前视图
		currentView = targetView;

		return true;
	}

	/**
	 * 返回到底部导航栏的视图
	 * 
	 * @return 如果返回true，则返回到底部导航栏视图，反之当前视图已经是底部导航栏视图
	 */
	public boolean backToOriginal() {
		if (currentView instanceof PromptSportLiveBottom) {
			return false;
		}
		changeView(PromptSportLiveBottom.class);		
		return true;
	}
	
	/**
	 * 清空缓存的视图，并将该实例对象销毁，在当前activity退出时调用该方法
	 */
	public void destroyPrompt() {
		if (null != map) {
			map.clear();
			map = null;
		}
		if (null != instance) {
			instance = null;
		}

	}

}
