package com.qad.util;

public interface OnFlingListener {

    public static final int FLING_LEFT = 1;
    public static final int FLING_RIGHT = 2;
    
    public void onFling(int flingState);
}
