package com.ifeng.news2.widget;

import android.content.Context;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.ifeng.news2.R;
import com.ifeng.news2.R.layout;

public class IfengTop extends RelativeLayout {

	private static final String TEXT_CONTENT_ATTRS = "text_content";
	private static final String IMAGE_CONTENT_ATTRS = "image_content";
	private ImageView image;
	private TextView text;

	public IfengTop(Context context, AttributeSet attrs, int defStyle) {
		super(context, attrs, defStyle);
		initialize(context, attrs);
	}

	public IfengTop(Context context, AttributeSet attrs) {
		super(context, attrs);
		initialize(context, attrs);
	}

	public IfengTop(Context context) {
		super(context);
		initialize(context);
	}

	private void initialize(Context context, AttributeSet attrs) {

		initView(context);
		int resourceText = attrs.getAttributeResourceValue(null,
				TEXT_CONTENT_ATTRS, 0);
		int resourceDrawable = attrs.getAttributeResourceValue(null,
				IMAGE_CONTENT_ATTRS, 0);
		if (resourceText > 0) {
			String content = context.getResources().getText(resourceText)
					.toString();
			text.setText(content);
		}
		if (resourceDrawable > 0) {
			image.setBackgroundResource(resourceDrawable);
		}
	}

	private void initialize(Context context) {
		initView(context);
	}

	private void initView(Context context) {
		LayoutInflater inflater = LayoutInflater.from(context);
		View view = inflater.inflate(layout.ifeng_top, this);
		image = (ImageView) view.findViewById(R.id.icon);
		text = (TextView) view.findViewById(R.id.text);
	}

	public void setImageContent(int resId) {
		image.setBackgroundResource(resId);
	}

	public void setTextContent(String textCont) {
		text.setText(textCont);
	}

}
