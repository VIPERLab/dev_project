package com.ifeng.news2.widget;

import com.ifeng.news2.R;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.util.AttributeSet;
import android.widget.TextView;

public class BorderTextView extends TextView
{
    @Override
    protected void onDraw(Canvas canvas)
    {
        super.onDraw(canvas);
        Paint paint = new Paint();
        paint.setStyle(Paint.Style.FILL);
        paint.setStrokeWidth(5);
        paint.setColor(getResources().getColor(R.color.topic_title_border));
        paint.setFakeBoldText(true);
       // canvas.drawLine(0, 0, this.getWidth() - 1, 0, paint);
        canvas.drawLine(0, 0, 0, this.getHeight() - 1, paint);
        canvas.drawLine(this.getWidth() - 1, 0, this.getWidth() - 1, this.getHeight() - 1, paint);
        canvas.drawLine(0, this.getHeight() - 1, this.getWidth() - 1, this.getHeight() - 1, paint);
    }
    
    public BorderTextView(Context context) {
		super(context);
	}

	public BorderTextView(Context context, AttributeSet attrs)
    {
        super(context, attrs);
    }
}