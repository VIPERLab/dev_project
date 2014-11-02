package com.ifeng.news2.plot_module;

import android.content.Context;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.LinearLayout;
import com.ifeng.news2.IfengNewsApp;
import com.ifeng.news2.plot_module.bean.PlotTopicBodyItem;
import com.qad.loader.ImageLoader;

/**
 * @author liu_xiaoliang
 * 提供策划专题公共方法
 */
public class PlotBaseModule extends LinearLayout implements OnClickListener{

  public Context context;
  public LayoutInflater inflater;
  private ImageLoader imageLoader;
  public PlotTopicBodyItem plotTopicBody = null;
  
  public PlotBaseModule(Context context) {
    super(context);
    init(context);
  }

  public PlotBaseModule(Context context, AttributeSet attrs) {
    super(context, attrs);
    init(context);
  }

  /**
   * 初始化
   * @param context
   */
  public void init(Context context){
    this.context = context;
    inflater = LayoutInflater.from(context);
    setOrientation(LinearLayout.VERTICAL);
  }

  /**
   * @return ImageLoader
   */
  public ImageLoader getDefaultLoader(){
    if(imageLoader==null){
      imageLoader = IfengNewsApp.getImageLoader();
    }
    return imageLoader;
  }
  
  /**
   * 创建View
   */
  public void create(){
      if(isBuildModule())buildModule();
  }

  /**
   * 子类实现
   */
  public void buildModule(){}
  
  /**
   * 是否构造Module
   * @return
   */
  private boolean isBuildModule(){
    //TODO  
    if (null == plotTopicBody) {
      return false;
    }
    return true;
  }
  /**
   * 获取当前模块类型
   * @return  
   */
  public String getModuleType(){
    if (null != plotTopicBody) {
      return  plotTopicBody.getType();
    }  
    return null;
  }
  
  /**
   * 设置每种样式的数据
   */
  public void setData(PlotTopicBodyItem plotTopicBody){
    this.plotTopicBody = plotTopicBody;
  }
  
  @Override
  public void onClick(View arg0) {

  }

}
