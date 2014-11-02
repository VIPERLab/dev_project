
package com.ifeng.news2.widget.zoom;

import android.graphics.RectF;

import android.widget.ImageView;


public interface IPhotoView {
  
    /**
     * Gets the Display Rectangle of the currently displayed Drawable. The
     * Rectangle is relative to this View and includes all scaling and
     * translations.
     *
     * @return - RectF of Displayed Drawable
     */
    RectF getDisplayRect();

    /**
     * @return The current minimum scale level. What this value represents depends on the current {@link android.widget.ImageView.ScaleType}.
     */
    float getMinScale();

    /**
     * @return The current middle scale level. What this value represents depends on the current {@link android.widget.ImageView.ScaleType}.
     */
    float getMidScale();

    /**
     * @return The current maximum scale level. What this value represents depends on the current {@link android.widget.ImageView.ScaleType}.
     */
    float getMaxScale();

    /**
     * Returns the current scale value
     *
     * @return float - current scale value
     */
    float getScale();

    /**
     * Return the current scale type in use by the ImageView.
     */
    ImageView.ScaleType getScaleType();

    /**
     * Sets the minimum scale level. What this value represents depends on the current {@link android.widget.ImageView.ScaleType}.
     */
    void setMinScale(float minScale);

    /**
     * Sets the middle scale level. What this value represents depends on the current {@link android.widget.ImageView.ScaleType}.
     */
    void setMidScale(float midScale);

    /**
     * Sets the maximum scale level. What this value represents depends on the current {@link android.widget.ImageView.ScaleType}.
     */
    void setMaxScale(float maxScale);

    /**
     * Register a callback to be invoked when the Matrix has changed for this
     * View. An example would be the user panning or scaling the Photo.
     *
     * @param listener - Listener to be registered.
     */
    void setOnMatrixChangeListener(PhotoViewAttacher.OnMatrixChangedListener listener);

    /**
     * Register a callback to be invoked when the View is tapped with a single
     * tap.
     *
     * @param listener - Listener to be registered.
     */
    void setOnViewTapListener(PhotoViewAttacher.OnViewTapListener listener);

    /**
     * Controls how the image should be resized or moved to match the size of
     * the ImageView. Any scaling or panning will happen within the confines of
     * this {@link android.widget.ImageView.ScaleType}.
     *
     * @param scaleType - The desired scaling mode.
     */
    void setScaleType(ImageView.ScaleType scaleType);

    /**
     * Zooms to the specified scale, around the focal point given.
     *
     * @param scale  - Scale to zoom to
     * @param focalX - X Focus Point
     * @param focalY - Y Focus Point
     */
    void zoomTo(float scale, float focalX, float focalY);
}
