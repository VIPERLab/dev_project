package com.ifeng.news2.widget.zoom;

import android.content.Context;
import android.graphics.Matrix;
import android.graphics.Matrix.ScaleToFit;
import android.graphics.RectF;
import android.graphics.drawable.Drawable;
import android.view.GestureDetector;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewTreeObserver;
import android.widget.ImageView;
import android.widget.ImageView.ScaleType;
import java.lang.ref.SoftReference;

public class PhotoViewAttacher implements IPhotoView, View.OnTouchListener, VersionedGestureDetector.OnGestureListener,
		GestureDetector.OnDoubleTapListener, ViewTreeObserver.OnGlobalLayoutListener {

	static final int EDGE_NONE = -1;
	static final int EDGE_LEFT = 0;
	static final int EDGE_RIGHT = 1;
	static final int EDGE_BOTH = 2;

	public static final float DEFAULT_MAX_SCALE = 3.0f;
	public static final float DEFAULT_MID_SCALE = 1.75f;
	public static final float DEFAULT_MIN_SCALE = 1.0f;

	private float mMinScale = DEFAULT_MIN_SCALE;
	private float mMidScale = DEFAULT_MID_SCALE;
	private float mMaxScale = DEFAULT_MAX_SCALE;

	private static void checkZoomLevels(float minZoom, float midZoom, float maxZoom) {
		if (minZoom >= midZoom) {
			throw new IllegalArgumentException("MinZoom should be less than MidZoom");
		} else if (midZoom >= maxZoom) {
			throw new IllegalArgumentException("MidZoom should be less than MaxZoom");
		}
	}

	/**
	 * @return true if the ImageView exists, and it's Drawable existss
	 */
	private static boolean hasDrawable(ImageView imageView) {
		return null != imageView && null != imageView.getDrawable();
	}

	/**
	 * @return true if the ScaleType is supported.
	 */
	private static boolean isSupportedScaleType(final ScaleType scaleType) {
		if (null == scaleType) {
			return false;
		}
		switch (scaleType) {
			case MATRIX:
				throw new IllegalArgumentException(scaleType.name() + " is not supported in PhotoView");
			default:
				return true;
		}
	}

	/**
	 * Set's the ImageView's ScaleType to Matrix.
	 */
	private static void setImageViewScaleTypeMatrix(ImageView imageView) {
		if (null != imageView) {
			if (!(imageView instanceof PhotoView)) {
				imageView.setScaleType(ScaleType.MATRIX);
			}
		}
	}

	private SoftReference<ImageView> mImageView;
	private ViewTreeObserver mViewTreeObserver;

	// Gesture Detectors
	private GestureDetector mGestureDetector;
	private VersionedGestureDetector mScaleDragDetector;

	// These are set so we don't keep allocating them on the heap
	private final Matrix mBaseMatrix = new Matrix();
	private final Matrix mDrawMatrix = new Matrix();
	private final Matrix mSuppMatrix = new Matrix();
	private final RectF mDisplayRect = new RectF();
	private final float[] mMatrixValues = new float[9];

	// Listeners
	private OnMatrixChangedListener mMatrixChangeListener;
	private OnViewTapListener mViewTapListener;
	private int mIvTop, mIvRight, mIvBottom, mIvLeft;
	private FlingRunnable mCurrentFlingRunnable;
	private int mScrollEdge = EDGE_BOTH;
	private ScaleType mScaleType = ScaleType.FIT_CENTER;

	public PhotoViewAttacher(ImageView imageView) {
		mImageView = new SoftReference<ImageView>(imageView);
		imageView.setOnTouchListener(this);

		mViewTreeObserver = imageView.getViewTreeObserver();
		mViewTreeObserver.addOnGlobalLayoutListener(this);

		// Make sure we using MATRIX Scale Type
		setImageViewScaleTypeMatrix(imageView);

		if (!imageView.isInEditMode()) {
			// Create Gesture Detectors...
			mScaleDragDetector = VersionedGestureDetector.newInstance(imageView.getContext(), this);

			mGestureDetector = new GestureDetector(imageView.getContext(),
					new GestureDetector.SimpleOnGestureListener());

			mGestureDetector.setOnDoubleTapListener(this);
		}
	}

	@Override
	public final RectF getDisplayRect() {
		checkMatrixBounds();
		return getDisplayRect(getDisplayMatrix());
	}

	public final ImageView getImageView() {
		ImageView imageView = null;

		if (null != mImageView) {
			imageView = mImageView.get();
		}
		return imageView;
	}

	@Override
	public float getMinScale() {
		return mMinScale;
	}

	@Override
	public float getMidScale() {
		return mMidScale;
	}

	@Override
	public float getMaxScale() {
		return mMaxScale;
	}

	@Override
	public final float getScale() {
		return getValue(mSuppMatrix, Matrix.MSCALE_X);
	}

	@Override
	public final ScaleType getScaleType() {
		return mScaleType;
	}

	public final boolean onDoubleTap(MotionEvent ev) {
		return true;
	}
	
	public void zoomToOriginalScale(){
		int defaultX = 20;
		int defaultY = 20;
		ImageView imageView = getImageView();
		if (null != imageView) {
			AnimatedZoomRunnable azr = new AnimatedZoomRunnable(getScale(), mMinScale, defaultX, defaultY);
			azr.setDelayTime(0);
			imageView.post(azr);
		}		
	}

	public final boolean onDoubleTapEvent(MotionEvent e) {
		return false;
	}

	public final void onDrag(float dx, float dy) {
		ImageView imageView = getImageView();

		if (null != imageView && hasDrawable(imageView)) {
			mSuppMatrix.postTranslate(dx, dy);
			checkAndDisplayMatrix();

			if (!mScaleDragDetector.isScaling()) {
				if (mScrollEdge == EDGE_BOTH || (mScrollEdge == EDGE_LEFT && dx >= 1f)
						|| (mScrollEdge == EDGE_RIGHT && dx <= -1f)) {					
					imageView.getParent().requestDisallowInterceptTouchEvent(false);
				}
			}
		}
	}

	@Override
	public final void onFling(float startX, float startY, float velocityX, float velocityY) {
		ImageView imageView = getImageView();
		if (hasDrawable(imageView)) {
			mCurrentFlingRunnable = new FlingRunnable(imageView.getContext());
			mCurrentFlingRunnable.fling(imageView.getWidth(), imageView.getHeight(), (int) velocityX, (int) velocityY);
			imageView.post(mCurrentFlingRunnable);
		}
	}

	@Override
	public final void onGlobalLayout() {
		ImageView imageView = getImageView();

		if (null != imageView) {
			final int top = imageView.getTop();
			final int right = imageView.getRight();
			final int bottom = imageView.getBottom();
			final int left = imageView.getLeft();

			/**
			 * We need to check whether the ImageView's bounds have changed.
			 */
			if (top != mIvTop || bottom != mIvBottom || left != mIvLeft || right != mIvRight) {
				// Update our base matrix, as the bounds have changed
				updateBaseMatrix(imageView.getDrawable());

				// Update values as something has changed
				mIvTop = top;
				mIvRight = right;
				mIvBottom = bottom;
				mIvLeft = left;
			}
		}
	}

	public final void onScale(float scaleFactor, float focusX, float focusY) {
		if (hasDrawable(getImageView()) && (getScale() < mMaxScale || scaleFactor < 1f)) {
			mSuppMatrix.postScale(scaleFactor, scaleFactor, focusX, focusY);
			checkAndDisplayMatrix();
		}
	}

	public final boolean onSingleTapConfirmed(MotionEvent e) {
		ImageView imageView = getImageView();

		if (null != imageView) {
			if (null != mViewTapListener) {
				mViewTapListener.onViewTap(imageView, e.getX(), e.getY());
			}
		}
		return false;
	}

	@Override
	public final boolean onTouch(View v, MotionEvent ev) {
		boolean handled = false;
			switch (ev.getAction()&MotionEvent.ACTION_MASK) {
				case MotionEvent.ACTION_DOWN:
					// First, disable the Parent from intercepting the touch
					// event
					v.getParent().requestDisallowInterceptTouchEvent(true);

					// If we're flinging, and the user presses down, cancel
					// fling
					cancelFling();
					break;
				case MotionEvent.ACTION_POINTER_1_UP:
				case MotionEvent.ACTION_CANCEL:
				case MotionEvent.ACTION_UP:
					// If the user has zoomed less than min scale, zoom back
					// to min scale
					if (getScale() < mMinScale) {
						RectF rect = getDisplayRect();
						if (null != rect) {
							v.post(new AnimatedZoomRunnable(getScale(), mMinScale, rect.centerX(), rect.centerY()));
							handled = true;
						}
					}
					break;
			}

			// Check to see if the user double tapped
			if (null != mGestureDetector && mGestureDetector.onTouchEvent(ev)) {
				handled = true;
			}

			// Finally, try the Scale/Drag detector
			if (null != mScaleDragDetector && mScaleDragDetector.onTouchEvent(ev)) {
				handled = true;
			}
		return handled;
	}

	@Override
	public void setMinScale(float minScale) {
		checkZoomLevels(minScale, mMidScale, mMaxScale);
		mMinScale = minScale;
	}
	
	@Override
	public void setMidScale(float midScale) {
		checkZoomLevels(mMinScale, midScale, mMaxScale);
		mMidScale = midScale;
	}

	@Override
	public void setMaxScale(float maxScale) {
		checkZoomLevels(mMinScale, mMidScale, maxScale);
		mMaxScale = maxScale;
	}

	@Override
	public final void setOnMatrixChangeListener(OnMatrixChangedListener listener) {
		mMatrixChangeListener = listener;
	}

	@Override
	public final void setOnViewTapListener(OnViewTapListener listener) {
		mViewTapListener = listener;
	}

	@Override
	public final void setScaleType(ScaleType scaleType) {
		if (isSupportedScaleType(scaleType) && scaleType != mScaleType) {
			mScaleType = scaleType;

			// Finally update
			update();
		}
	}

	public final void update() {
		ImageView imageView = getImageView();
		if (null != imageView) {			
				// Make sure we using MATRIX Scale Type
				setImageViewScaleTypeMatrix(imageView);

				// Update the base matrix using the current drawable
				updateBaseMatrix(imageView.getDrawable());
		}
	}

	@Override
	public final void zoomTo(float scale, float focalX, float focalY) {
		ImageView imageView = getImageView();

		if (null != imageView) {
			imageView.post(new AnimatedZoomRunnable(getScale(), scale, focalX, focalY));
		}
	}

	protected Matrix getDisplayMatrix() {
		mDrawMatrix.set(mBaseMatrix);
		mDrawMatrix.postConcat(mSuppMatrix);
		return mDrawMatrix;
	}

	private void cancelFling() {
		if (null != mCurrentFlingRunnable) {
			mCurrentFlingRunnable.cancelFling();
			mCurrentFlingRunnable = null;
		}
	}

	/**
	 * Helper method that simply checks the Matrix, and then displays the result
	 */
	private void checkAndDisplayMatrix() {
		checkMatrixBounds();
		setImageViewMatrix(getDisplayMatrix());
	}

	private void checkImageViewScaleType() {
		ImageView imageView = getImageView();
		/**
		 * PhotoView's getScaleType() will just divert to this.getScaleType() so
		 * only call if we're not attached to a PhotoView.
		 */
		if (null != imageView && !(imageView instanceof PhotoView)) {
			if (imageView.getScaleType() != ScaleType.MATRIX) {
				throw new IllegalStateException(
						"The ImageView's ScaleType has been changed since attaching a PhotoViewAttacher");
			}
		}
	}

	private void checkMatrixBounds() {
		final ImageView imageView = getImageView();
		if (null == imageView) {
			return;
		}

		final RectF rect = getDisplayRect(getDisplayMatrix());
		if (null == rect) {
			return;
		}

		final float height = rect.height(), width = rect.width();
		float deltaX = 0, deltaY = 0;

		final int viewHeight = imageView.getHeight();
		if (height <= viewHeight) {
			deltaY = (viewHeight - height) / 2 - rect.top;
		} else if (rect.top > 0) {
			deltaY = -rect.top;
		} else if (rect.bottom < viewHeight) {
			deltaY = viewHeight - rect.bottom;
		}

		final int viewWidth = imageView.getWidth();
		if (width <= viewWidth) {			
			deltaX = (viewWidth - width) / 2 - rect.left;
			mScrollEdge = EDGE_BOTH;
		} else if (rect.left > 0) {
			mScrollEdge = EDGE_LEFT;
			deltaX = -rect.left;
		} else if (rect.right < viewWidth) {
			deltaX = viewWidth - rect.right;
			mScrollEdge = EDGE_RIGHT;
		} else {
			mScrollEdge = EDGE_NONE;
		}
		// Finally actually translate the matrix
		mSuppMatrix.postTranslate(deltaX, deltaY);
	}

	/**
	 * Helper method that maps the supplied Matrix to the current Drawable
	 * 
	 * @param matrix - Matrix to map Drawable against
	 * @return RectF - Displayed Rectangle
	 */
	private RectF getDisplayRect(Matrix matrix) {
		ImageView imageView = getImageView();

		if (null != imageView) {
			Drawable d = imageView.getDrawable();
			if (null != d) {
				mDisplayRect.set(0, 0, d.getIntrinsicWidth(), d.getIntrinsicHeight());
				matrix.mapRect(mDisplayRect);
				return mDisplayRect;
			}
		}
		return null;
	}

	/**
	 * Helper method that 'unpacks' a Matrix and returns the required value
	 * 
	 * @param matrix - Matrix to unpack
	 * @param whichValue - Which value from Matrix.M* to return
	 * @return float - returned value
	 */
	private float getValue(Matrix matrix, int whichValue) {
		matrix.getValues(mMatrixValues);
		return mMatrixValues[whichValue];
	}

	/**
	 * Resets the Matrix back to FIT_CENTER, and then displays it.s
	 */
	private void resetMatrix() {
		mSuppMatrix.reset();
		setImageViewMatrix(getDisplayMatrix());
		checkMatrixBounds();
	}

	private void setImageViewMatrix(Matrix matrix) {
		ImageView imageView = getImageView();
		if (null != imageView) {

			checkImageViewScaleType();
			imageView.setImageMatrix(matrix);

			// Call MatrixChangedListener if needed
			if (null != mMatrixChangeListener) {
				RectF displayRect = getDisplayRect(matrix);
				if (null != displayRect) {
					mMatrixChangeListener.onMatrixChanged(displayRect);
				}
			}
		}
	}

	/**
	 * Calculate Matrix for FIT_CENTER
	 * 
	 * @param d - Drawable being displayed
	 */
	private void updateBaseMatrix(Drawable d) {
		ImageView imageView = getImageView();
		if (null == imageView || null == d) {
			return;
		}

		final float viewWidth = imageView.getWidth();
		final float viewHeight = imageView.getHeight();
		final int drawableWidth = d.getIntrinsicWidth();
		final int drawableHeight = d.getIntrinsicHeight();
		mBaseMatrix.reset();
		RectF mTempSrc = new RectF(0, 0, drawableWidth, drawableHeight);
		RectF mTempDst = new RectF(0, 0, viewWidth, viewHeight);				
		mBaseMatrix.setRectToRect(mTempSrc, mTempDst, ScaleToFit.CENTER);
		resetMatrix();
	}

	/**
	 * Interface definition for a callback to be invoked when the internal
	 * Matrix has changed for this View.
	 * 
	 * @author Chris Banes
	 */
	public static interface OnMatrixChangedListener {
		/**
		 * Callback for when the Matrix displaying the Drawable has changed.
		 * This could be because the View's bounds have changed, or the user has
		 * zoomed.
		 * 
		 * @param rect - Rectangle displaying the Drawable's new bounds.
		 */
		void onMatrixChanged(RectF rect);
	}

	/**
	 * Interface definition for a callback to be invoked when the ImageView is
	 * tapped with a single tap.
	 * 
	 * @author Chris Banes
	 */
	public static interface OnViewTapListener {

		/**
		 * A callback to receive where the user taps on a ImageView. You will
		 * receive a callback if the user taps anywhere on the view, tapping on
		 * 'whitespace' will not be ignored.
		 * 
		 * @param view - View the user tapped.
		 * @param x - where the user tapped from the left of the View.
		 * @param y - where the user tapped from the top of the View.
		 */
		void onViewTap(View view, float x, float y);
	}
	
	private static final int SIXTY_FPS_INTERVAL = 1000 / 60;

	private class AnimatedZoomRunnable implements Runnable {

		// These are 'postScale' values, means they're compounded each iteration
		static final float ANIMATION_SCALE_PER_ITERATION_IN = 1.07f;
		static final float ANIMATION_SCALE_PER_ITERATION_OUT = 0.93f;

		private int delayTime = SIXTY_FPS_INTERVAL;
		
		public void setDelayTime(int delayTime) {
			this.delayTime = delayTime;
		}

		private final float mFocalX, mFocalY;
		private final float mTargetZoom;
		private final float mDeltaScale;

		public AnimatedZoomRunnable(final float currentZoom, final float targetZoom, final float focalX,
				final float focalY) {
			mTargetZoom = targetZoom;
			mFocalX = focalX;
			mFocalY = focalY;

			if (currentZoom < targetZoom) {
				mDeltaScale = ANIMATION_SCALE_PER_ITERATION_IN;
			} else {
				mDeltaScale = ANIMATION_SCALE_PER_ITERATION_OUT;
			}
		}

		public void run() {
			ImageView imageView = getImageView();
			if (null != imageView) {
				mSuppMatrix.postScale(mDeltaScale, mDeltaScale, mFocalX, mFocalY);
				checkAndDisplayMatrix();

				final float currentScale = getScale();

				if ((mDeltaScale > 1f && currentScale < mTargetZoom)
						|| (mDeltaScale < 1f && mTargetZoom < currentScale)) {
					// We haven't hit our target scale yet, so post ourselves
					// again
					imageView.postDelayed(this, delayTime);
				} else {
					// We've scaled past our target zoom, so calculate the
					// necessary scale so we're back at target zoom
					final float delta = mTargetZoom / currentScale;
					mSuppMatrix.postScale(delta, delta, mFocalX, mFocalY);
					checkAndDisplayMatrix();
				}
			}
		}
	}

	private class FlingRunnable implements Runnable {

		private final ScrollerProxy mScroller;
		private int mCurrentX, mCurrentY;

		public FlingRunnable(Context context) {
			mScroller = ScrollerProxy.getScroller(context);
		}

		public void cancelFling() {
			mScroller.forceFinished(true);
		}

		public void fling(int viewWidth, int viewHeight, int velocityX, int velocityY) {
			final RectF rect = getDisplayRect();
			if (null == rect) {
				return;
			}

			final int startX = Math.round(-rect.left);
			final int minX, maxX, minY, maxY;

			if (viewWidth < rect.width()) {
				minX = 0;
				maxX = Math.round(rect.width() - viewWidth);
			} else {
				minX = maxX = startX;
			}

			final int startY = Math.round(-rect.top);
			if (viewHeight < rect.height()) {
				minY = 0;
				maxY = Math.round(rect.height() - viewHeight);
			} else {
				minY = maxY = startY;
			}

			mCurrentX = startX;
			mCurrentY = startY;
			// If we actually can move, fling the scroller
			if (startX != maxX || startY != maxY) {
				mScroller.fling(startX, startY, velocityX, velocityY, minX, maxX, minY, maxY, 0, 0);
			}
		}

		@Override
		public void run() {
			ImageView imageView = getImageView();
			if (null != imageView && mScroller.computeScrollOffset()) {

				final int newX = mScroller.getCurrX();
				final int newY = mScroller.getCurrY();

				mSuppMatrix.postTranslate(mCurrentX - newX, mCurrentY - newY);
				setImageViewMatrix(getDisplayMatrix());

				mCurrentX = newX;
				mCurrentY = newY;

				imageView.postDelayed(this, SIXTY_FPS_INTERVAL);
			}
		}
	}
}
