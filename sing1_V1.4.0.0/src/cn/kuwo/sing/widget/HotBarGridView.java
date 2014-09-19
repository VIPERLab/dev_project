package cn.kuwo.sing.widget;

import android.content.Context;
import android.util.AttributeSet;
import android.widget.GridView;

public class HotBarGridView extends GridView {

	public HotBarGridView(Context context, AttributeSet attrs) {   
        super(context, attrs);   
    }   
  
	HotBarGridView(Context context) {   
        super(context);   
    }   
  
    public HotBarGridView(Context context, AttributeSet attrs, int defStyle) {   
        super(context, attrs, defStyle);   
    }  

	@Override
	protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {

		int expandSpec = MeasureSpec.makeMeasureSpec(Integer.MAX_VALUE >> 2,
				MeasureSpec.AT_MOST);
		super.onMeasure(widthMeasureSpec, expandSpec);

	}
}
