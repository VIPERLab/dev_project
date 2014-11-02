package com.ifeng.news2.widget;

import com.qad.util.OnFlingListener;

import com.qad.util.IfengGestureDetector;

import android.view.MotionEvent;
import android.view.View;

import android.util.AttributeSet;

import android.content.Context;

import android.widget.ExpandableListView;

/**
 * @author liu_xiaoliang
 *
 */
public class IfengExpandableListView extends ExpandableListView {

  private View onTouchListener;
  private IfengGestureDetector detector = null;
  private boolean isIntercept;
  public IfengExpandableListView(Context context) {
    super(context);
  }

  public IfengExpandableListView(Context context, AttributeSet attrs) {
    super(context, attrs);
  }


  @Override
  public boolean onInterceptTouchEvent(MotionEvent ev) {
    if (null != onTouchListener && onTouchListener.getVisibility() == View.VISIBLE) {
      onTouchListener.clearFocus();
      return true;
    }
    if (null != detector) {
      detector.onTouchEvent(ev);
    }
    if(isIntercept){
      return true;
    }
    return super.onInterceptTouchEvent(ev);
  }
  
  @Override
  public boolean onTouchEvent(MotionEvent ev) {
    if (null != detector) {
      detector.onTouchEvent(ev);
    }
    return super.onTouchEvent(ev);
  }

  public void setOnTouchListener(View v) {
    onTouchListener = v;
  }

  public void setOnFlingListener(OnFlingListener listener) {
    detector = IfengGestureDetector.getInsensitiveIfengGestureDetector(listener);
  }

  public void setIntercept(boolean isIntercept) {
    this.isIntercept = isIntercept;
  }

}
