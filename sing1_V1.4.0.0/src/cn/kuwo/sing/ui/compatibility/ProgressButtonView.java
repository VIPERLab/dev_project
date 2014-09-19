package cn.kuwo.sing.ui.compatibility;

import cn.kuwo.framework.utils.SizeUtils;
import android.content.Context;
import android.content.res.Resources;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.Paint.Align;
import android.graphics.Paint.FontMetrics;
import android.graphics.drawable.Drawable;
import android.util.AttributeSet;
import android.util.TypedValue;
import android.view.View;

public class ProgressButtonView extends View {
	private Context mContext;

	public ProgressButtonView(Context context) {
		super(context);
		mContext = context;
	}

	public ProgressButtonView(Context context, AttributeSet attrs) {
		super(context, attrs);
		mContext = context;
	}

	public ProgressButtonView(Context context, AttributeSet attrs, int defStyle) {
		super(context, attrs, defStyle);
		mContext = context;
	}

	private Drawable mForeground;
	private double mPercent;
	private String mText = "";
	private int mTextColor;
	private Paint paint = new Paint(Paint.ANTI_ALIAS_FLAG);
	
	public double getPercent() {
		return mPercent;
	}

	public void setPercent(double mPercent) {
		this.mPercent = mPercent;
		invalidate();
	}

	public String getText() {
		return mText;
	}

	public void setText(String mText) {
		this.mText = mText;
		invalidate();
	}

	public int getTextColor() {
		return mTextColor;
	}

	public void setTextColor(int mTextColor) {
		this.mTextColor = mTextColor;
	}

	public Drawable getForeground() {
		return mForeground;
	}

	public void setForeground(Drawable mForeground) {
		this.mForeground = mForeground;
		invalidate();
	}
	
	@Override
	protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
//		super.onMeasure(widthMeasureSpec, heightMeasureSpec);
		setMeasuredDimension(getBackground().getIntrinsicWidth(), getBackground().getIntrinsicHeight());
	}
	
	
	@Override
	protected void onDraw(Canvas canvas) {
		super.onDraw(canvas);

		int width =  getWidth();
		int height = getHeight();
		
		// 绘制进度条
		canvas.save();
		double foreWidth = mPercent * width / 100.0;
        canvas.clipRect(0, 0, (int)foreWidth, height);
        mForeground.setBounds(0, 0, width, height);
		mForeground.draw(canvas);
		canvas.restore();
//		canvas.clipRect(0, 0, width, height);
		
		// 绘制文本
		paint.setTextAlign(Align.CENTER);
		paint.setColor(mTextColor);
		
		float size = SizeUtils.getFontSize(mContext, 14);
		paint.setTextSize(size);
		
		FontMetrics fontMetrics = paint.getFontMetrics();
		// 计算文字高度
		float fontHeight = fontMetrics.bottom - fontMetrics.top;
		// 计算文字baseline
		float y = height - (height - fontHeight) / 2 - fontMetrics.bottom; 
		canvas.drawText(mText, width/2, y, paint);
	}
}
