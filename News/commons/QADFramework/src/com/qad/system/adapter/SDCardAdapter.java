package com.qad.system.adapter;

import android.os.Environment;

import com.qad.system.listener.SDCardListener;

public class SDCardAdapter implements SDCardListener {

	private boolean isSDCardAvailiable=Environment.getExternalStorageState().equals(Environment.MEDIA_MOUNTED);
	
	@Override
	public void onSDCardRemoved() {
		isSDCardAvailiable=false;
	}

	@Override
	public void onSDCardMounted() {
		isSDCardAvailiable=true;
	}

	/**
	 * @return the isSDCardAvailiable
	 */
	public boolean isSDCardAvailiable() {
		return isSDCardAvailiable;
	}

}
