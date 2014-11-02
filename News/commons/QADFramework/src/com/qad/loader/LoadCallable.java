package com.qad.loader;

import java.util.concurrent.Callable;

import android.graphics.Bitmap;

import com.qad.loader.callable.BeanLoadCallable;
import com.qad.loader.callable.ResourceDownloadCallable;
import com.qad.loader.callable.ResourceLoadCallable;

public abstract class LoadCallable<Result> implements Callable<Result> {

	protected LoadContext<?, ?, Result> context = null;

	/**
	 * LoadCallable factory, return callable instance by the Class of Result
	 * 
	 * @param context
	 *            LoadContext of the task
	 * @return Loading callable object
	 */
	public static <Result> LoadCallable<Result> newInstance(LoadContext<?, ?, Result> context) {
		Class<?> clazz = context.getClazz();

		if (clazz.equals(Bitmap.class)) {
			return new ResourceLoadCallable<Result>(context);
		} else if (clazz.equals(String.class) && context.getParser() == null) {
			return new ResourceDownloadCallable<Result>(context);
		} else {
			return new BeanLoadCallable<Result>(context);
		}
	}

	/**
	 * Default constructor
	 * 
	 * @param context
	 *            LoadContext of the task
	 */
	public LoadCallable(LoadContext<?, ?, Result> context) {
		this.context = context;
	}

	public LoadContext<?, ?, Result> getLoadContext() {
		return context;
	}
}
