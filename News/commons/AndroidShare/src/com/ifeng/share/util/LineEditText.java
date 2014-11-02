package com.ifeng.share.util;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Paint.Style;
import android.graphics.RectF;
import android.util.AttributeSet;
import android.widget.EditText;

public class LineEditText extends EditText {  

	public LineEditText(Context context, AttributeSet attrs) {
		super(context, attrs);
	}

	@Override
	protected void onDraw(Canvas canvas) {

		Paint paint = new Paint();
		paint.setStyle(Style.STROKE);
		paint.setStrokeWidth(2);
		paint.setColor(Color.parseColor("#B3B3B3"));
		canvas.drawRoundRect(new RectF(this.getScrollX(), 2+this.getScrollY(), this.getWidth() + this.getScrollX(), this.getHeight()+ this.getScrollY()-1), 3,3, paint);
		super.onDraw(canvas);
	}

}

