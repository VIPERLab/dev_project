package com.ifeng.news2.plot_module;

import android.content.Context;
import android.graphics.Bitmap;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;
import com.ifeng.news2.R;
import com.qad.loader.LoadContext;

/**
 * @author liu_xiaoliang
 * 图说模块
 */
public class PlotDiagramModule extends PlotBaseModule {
  private ImageView imageView;
  
  public PlotDiagramModule(Context context) {
    super(context);
  }

  public PlotDiagramModule(Context context, AttributeSet attrs) {
    super(context, attrs);
  }

  @Override
  public void buildModule() {
    super.buildModule();
    String text = plotTopicBody.getIntro();
    String imageUrl = plotTopicBody.getThumbnail();

    if (TextUtils.isEmpty(text) && TextUtils.isEmpty(imageUrl)) {
      return;
    }

    View diagramView = inflater.inflate(R.layout.plot_diagram_layout, null);
    imageView = (ImageView)diagramView.findViewById(R.id.plot_diagram_icon);
    TextView textView = (TextView)diagramView.findViewById(R.id.plot_diagram_text);

    textView.setText(text);

    if (TextUtils.isEmpty(imageUrl)) {
      imageView.setVisibility(View.GONE);
    } else {
      imageView.setVisibility(View.VISIBLE);
      getDefaultLoader().startLoading(new LoadContext<String, ImageView, Bitmap>(imageUrl, 
          imageView, Bitmap.class, LoadContext.FLAG_CACHE_FIRST, context));
    }
    
    addView(diagramView);
  }
}
