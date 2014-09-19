package cn.kuwo.sing.ui.compatibility;

import cn.kuwo.framework.log.KuwoLog;
import cn.kuwo.framework.utils.SizeUtils;
import cn.kuwo.sing.logic.LyricLogic;
import cn.kuwo.sing.util.lyric.Lyric;
import cn.kuwo.sing.util.lyric.Sentence;
import cn.kuwo.sing.util.lyric.Word;
import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.util.AttributeSet;
import android.view.View;


public class LrcView extends View{

	private final String TAG = "LrcView";
	private Lyric lyric;
	private final float mFontSize = SizeUtils.getFontSize(getContext(), 19);
	private final float mMinFontSize = SizeUtils.getFontSize(getContext(), 15);
	private int mNormalColor = Color.WHITE;
	private int nHighlightColor = Color.parseColor("#ffe400");
	
	private long position;
	private int sentenceIndex = 0;
	private Word word;
	float margin = 2;
	
	private Paint paint = new Paint();

	public LrcView(Context context, AttributeSet attrs, int defStyle) {
		super(context, attrs, defStyle);
	}
	
	public LrcView(Context context, AttributeSet attrs) {
		this(context, attrs, 0);
	}
	
	public LrcView(Context context) {
		this(context, null);
	}
	
	public void setLyric(Lyric lyric) {
		this.lyric = lyric;
	}
	
	public void setPosition(long position) {
		this.position = position;
		
		if (lyric == null) {
			sentenceIndex = 0;
			return;
		}
		
		LyricLogic lLyric = new LyricLogic();
		sentenceIndex = lLyric.findSentenceIndex(position, lyric);
		if (sentenceIndex < 0)
			word = null;
		else {
			word = lLyric.findWord(position, lyric.getSentences().get(sentenceIndex));
		}
		
		invalidate();
	}
	
	public Sentence getSentence(int index) {
		if (lyric == null || lyric.getSentences() == null)
			return null;
		
		if (index < 0)
			index = 0;
		
		if (index >= lyric.getSentences().size())
			return null;
		
		return lyric.getSentences().get(index);
	}
	
	@Override
	protected void onDraw(Canvas canvas) {
		if(lyric == null)
			return;
		
	    super.onDraw(canvas);

	    //=========================画前面的四个圆点=========================
		float dian = SizeUtils.getFontSize(getContext(), 6);
		long flagtime = lyric.getSentences().get(0).getTimestamp();//取第一句话的开始时间作为标准
		int number = (int)(flagtime - position) / 1000 -1 ;
		if (number > 4)
			number = 4;
		
		for(int i = 1; i <= number ; i++){
			float x = (margin + dian*2) * i - dian;
			float y = margin + dian;
			//画外面的大圆
			paint.setColor(Color.LTGRAY);
			paint.setStrokeWidth(dian);
			canvas.drawCircle(x, y, dian, paint);
			//画里面的小圆
			paint.setColor(Color.BLUE);
			paint.setStrokeWidth(dian - 1);
			canvas.drawCircle(x, y, dian - 1, paint);
		}
		
		// 设置抗锯齿   
        paint.setAntiAlias(true);  
	    int index;
	    
	    float left, top, right;	// 句子的左边距
	    Sentence sentence;
	    String content; // 句子内容
	    float contentWidth; // 句子宽度
	    
	    if (sentenceIndex < 0)
	    	sentenceIndex = 0;

	    // 画上面一句
	    index = sentenceIndex%2==0 ? sentenceIndex : sentenceIndex+1;
	    sentence = getSentence(index);
	    if (sentence != null) {
		    content = sentence.getContent();
		    if (content != null) {
		    	contentWidth = adjustMinFontSize(content);
		    	left = margin;
		    	top = mFontSize + margin*2 + dian*2;
		    	paint.setColor(mNormalColor);
		    	canvas.drawText(content, left, top, paint);
		    	
		    	// 着色
		    	canvas.save();
		    	right = computeHighlightWidth(sentence) + left;
		    	canvas.clipRect(left, 0, right, top+mFontSize);
		    	paint.setColor(nHighlightColor);
		    	canvas.drawText(content, left, top, paint);
		    	canvas.restore();
		    }
	    }
	    
	    // 画下面一句
	    index = sentenceIndex%2==0 ? sentenceIndex+1 : sentenceIndex;
	    sentence = getSentence(index);
	    if (sentence != null) {
		    content = sentence.getContent();
		    if (content != null) {
		    	contentWidth = adjustMinFontSize(content);
		    	left = getWidth() - contentWidth - margin;
		    	top = mFontSize*2 + margin*4 + dian*2;
		    	paint.setColor(mNormalColor);
		    	canvas.drawText(content, left, top, paint);
		    	
		    	// 着色
		    	canvas.save();
		    	right = computeHighlightWidth(sentence) + left;
		    	canvas.clipRect(left, 0, right, top+mFontSize);
		    	paint.setColor(nHighlightColor);
		    	canvas.drawText(content, left, top, paint);
		    	canvas.restore();
			}	 
	    }

	}

	private float computeHighlightWidth(Sentence sentence) {
		if (sentence == null)
			return 0;
		
		if (sentenceIndex != sentence.getIndex())
			return 0;
		
		if (word == null) {
			KuwoLog.d(TAG, "WORD==NULL  POS:"+position);
			return 0;
		}
		// 之前文字宽度
		float w = paint.measureText(sentence.getContent(), 0, word.getIndex());
		KuwoLog.d(TAG, "word: " + word.getContent() + "     word.getIndex()"+word.getIndex()+ "        w:" + w);
		if (w < 0)
			w=0;
		
		// 当前文字%
		float percent = (position - word.getTimestamp())*1.0F / word.getTimespan();
		if (percent > 1)
			percent = 1;
		w += paint.measureText(word.getContent())*percent;
		
		
		return w;
	}
	
	// 返回调整后的内容宽度
	private float adjustMinFontSize(String content) {
		
		float size = mFontSize;
		float contentWidth;
		float maxWidth = getWidth()-margin*2;;
		float step = 0.5F;
		
		size += step;
		do {
			size -= step;
			paint.setTextSize(size);
			contentWidth = paint.measureText(content);
		} while (contentWidth > maxWidth && size > mMinFontSize);
		
		return contentWidth;
	}	
	
}
