package com.ifeng.news2.widget.zoom;

import android.annotation.TargetApi;
import android.content.Context;
import android.util.FloatMath;
import android.view.MotionEvent;
import android.view.ScaleGestureDetector;
import android.view.ScaleGestureDetector.OnScaleGestureListener;
import android.view.VelocityTracker;
import android.view.ViewConfiguration;

public abstract class VersionedGestureDetector {
	static final String LOG_TAG = "VersionedGestureDetector";
	OnGestureListener mListener;

	public static VersionedGestureDetector newInstance(Context context, OnGestureListener listener) {
		VersionedGestureDetector detector = null;
		detector = new FroyoDetector(context);

		detector.mListener = listener;

		return detector;
	}

	public abstract boolean onTouchEvent(MotionEvent ev);

	public abstract boolean isScaling();

	public static interface OnGestureListener {
		public void onDrag(float dx, float dy);

		public void onFling(float startX, float startY, float velocityX, float velocityY);

		public void onScale(float scaleFactor, float focusX, float focusY);
	}

	private static class CupcakeDetector extends VersionedGestureDetector {

		float mLastTouchX;
		float mLastTouchY;
		final float mTouchSlop;
		final float mMinimumVelocity;

		public CupcakeDetector(Context context) {
			final ViewConfiguration configuration = ViewConfiguration.get(context);
			mMinimumVelocity = configuration.getScaledMinimumFlingVelocity();
			mTouchSlop = configuration.getScaledTouchSlop();
		}

		private VelocityTracker mVelocityTracker;
		private boolean mIsDragging;

		float getActiveX(MotionEvent ev) {
			return ev.getX();
		}

		float getActiveY(MotionEvent ev) {
			return ev.getY();
		}

		public boolean isScaling() {
			return false;
		}

		@Override
		public boolean onTouchEvent(MotionEvent ev) {
			switch (ev.getAction()) {
				case MotionEvent.ACTION_DOWN: {
					mVelocityTracker = VelocityTracker.obtain();
					mVelocityTracker.addMovement(ev);

					mLastTouchX = getActiveX(ev);
					mLastTouchY = getActiveY(ev);
					mIsDragging = false;
					break;
				}

				case MotionEvent.ACTION_MOVE: {
					final float x = getActiveX(ev);
					final float y = getActiveY(ev);
					final float dx = x - mLastTouchX, dy = y - mLastTouchY;

					if (!mIsDragging) {
						// Use Pythagoras to see if drag length is larger than
						// touch slop
						mIsDragging = FloatMath.sqrt((dx * dx) + (dy * dy)) >= mTouchSlop;
					}

					if (mIsDragging) {
						mListener.onDrag(dx, dy);
						mLastTouchX = x;
						mLastTouchY = y;

						if (null != mVelocityTracker) {
							mVelocityTracker.addMovement(ev);
						}
					}
					break;
				}

				case MotionEvent.ACTION_CANCEL: {
					// Recycle Velocity Tracker
					if (null != mVelocityTracker) {
						mVelocityTracker.recycle();
						mVelocityTracker = null;
					}
					break;
				}

				case MotionEvent.ACTION_UP: {
					if (mIsDragging) {
						if (null != mVelocityTracker) {
							mLastTouchX = getActiveX(ev);
							mLastTouchY = getActiveY(ev);

							// Compute velocity within the last 1000ms
							mVelocityTracker.addMovement(ev);
							mVelocityTracker.computeCurrentVelocity(1000);

							final float vX = mVelocityTracker.getXVelocity(), vY = mVelocityTracker.getYVelocity();

							// If the velocity is greater than minVelocity, call
							// listener
							if (Math.max(Math.abs(vX), Math.abs(vY)) >= mMinimumVelocity) {
								mListener.onFling(mLastTouchX, mLastTouchY, -vX, -vY);
							}
						}
					}

					// Recycle Velocity Tracker
					if (null != mVelocityTracker) {
						mVelocityTracker.recycle();
						mVelocityTracker = null;
					}
					break;
				}
			}

			return true;
		}
	}

	@TargetApi(8)
	private static class FroyoDetector extends CupcakeDetector {

		private final ScaleGestureDetector mDetector;

		// Needs to be an inner class so that we don't hit
		// VerifyError's on API 4.
		private final OnScaleGestureListener mScaleListener = new OnScaleGestureListener() {

			@Override
			public boolean onScale(ScaleGestureDetector detector) {
				mListener.onScale(detector.getScaleFactor(), detector.getFocusX(), detector.getFocusY());
				return true;
			}

			@Override
			public boolean onScaleBegin(ScaleGestureDetector detector) {
				return true;
			}

			@Override
			public void onScaleEnd(ScaleGestureDetector detector) {
				// NO-OP
			}
		};

		public FroyoDetector(Context context) {
			super(context);
			mDetector = new ScaleGestureDetector(context, mScaleListener);
		}

		@Override
		public boolean isScaling() {
			return mDetector.isInProgress();
		}

		@Override
		public boolean onTouchEvent(MotionEvent ev) {
			mDetector.onTouchEvent(ev);
			return super.onTouchEvent(ev);
		}

	}
}