package cn.kuwo.sing.bean;

import android.graphics.Bitmap;

public class TempOrderedSongsBean {

	public Bitmap bitmap;

	public String name;

	public String singer;

	public int progress;

	public TempOrderedSongsBean(Bitmap bitmap, String name, String singer,
			int progress) {
		super();
		this.bitmap = bitmap;
		this.name = name;
		this.singer = singer;
		this.progress = progress;
	}

}
