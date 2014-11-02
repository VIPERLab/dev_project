package com.ifeng.news2.util;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;
import java.lang.reflect.Field;
import android.content.Context;
import android.content.SharedPreferences;
import android.content.SharedPreferences.Editor;
import android.text.TextUtils;

/**
 * 保存对象信息到本地
 * 
 * @author SunQuan:
 * @version 创建时间：2013-9-19 下午1:40:25 类说明
 */

public final class InfoPreserver {

	private static final String DEFAULT_VALUE = "";

	private InfoPreserver() {
	}

	private static <T> SharedPreferences getSharedPreferences(Context context,
			Class<T> clazz) {
		SharedPreferences sp = null;
		PreferenceName name = clazz.getAnnotation(PreferenceName.class);
		if (name != null) {
			sp = context.getSharedPreferences(name.value(),
					Context.MODE_PRIVATE);
		}
		return sp;
	}

	/**
	 * 将信息保存到本地
	 * 
	 * @param context
	 * @param user
	 */
	@SuppressWarnings("unchecked")
	public static <T> boolean saveInfo(Context context, T t) {

		SharedPreferences sp = getSharedPreferences(context, t.getClass());
		if (sp == null || t == null) {
			return false;
		}
		Editor editor = sp.edit();
		Class<T> clazz = (Class<T>) t.getClass();
		Field[] fields = clazz.getDeclaredFields();
		for (Field field : fields) {
			field.setAccessible(true);
			if (field.getType() == String.class) {
				PreferenceItem item = field.getAnnotation(PreferenceItem.class);
				if (item != null) {
					try {
						editor.putString(item.value(), (String) field.get(t));
					} catch (Exception e) {
						return false;
					}
				}
			}
		}
		return editor.commit();
	}

	/**
	 * 从本地读取信息
	 * 
	 * @param <T>
	 * @param <T>
	 * 
	 * @param context
	 * @return
	 */
	public static <T> T getSavedInfo(Context context, Class<T> clazz) {
		SharedPreferences sp = getSharedPreferences(context, clazz);
		if (sp == null) {
			return null;
		}
		T t = null;
		boolean hasSaved = true;
		try {
			t = clazz.newInstance();
		} catch (Exception e) {
			return null;
		}

		Field[] fields = clazz.getDeclaredFields();
		for (Field field : fields) {
			field.setAccessible(true);
			if (field.getType() == String.class) {
				PreferenceItem item = field.getAnnotation(PreferenceItem.class);
				if (item != null) {
					if (TextUtils.isEmpty(sp.getString(item.value(),
							DEFAULT_VALUE))) {
						hasSaved = false;
						break;
					} else {
						try {
							field.set(t,
									sp.getString(item.value(), DEFAULT_VALUE));
						} catch (Exception e) {
							hasSaved = false;
							break;
						}
					}
				}
			}
		}
		if (!hasSaved) {
			t = null;
		}
		return t;
	}

	/**
	 * 清空保存的信息
	 * 
	 * @param <T>
	 * 
	 * @param context
	 */
	public static <T> boolean clearInfo(Context context, Class<T> clazz) {
		SharedPreferences sp = getSharedPreferences(context, clazz);
		if (sp == null) {
			return false;
		}
		Editor editor = sp.edit();
		editor.clear();
		return editor.commit();
	}

	/**
	 * 检查是否保存了信息
	 * 
	 * @param <T>
	 * 
	 * @param context
	 * @return
	 */
	public static <T> boolean hasSavedInfo(Context context, Class<T> clazz) {
		return getSavedInfo(context, clazz) == null ? false : true;
	}

	/**
	 * 保存的对象指定的xml文件名
	 * 
	 * @author SunQuan
	 * 
	 */
	@Retention(RetentionPolicy.RUNTIME)
	@Target(ElementType.FIELD)
	public static @interface PreferenceItem {

		String value();
	}

	/**
	 * 保存的每一项对应的key
	 * 
	 * @author SunQuan
	 * 
	 */
	@Retention(RetentionPolicy.RUNTIME)
	@Target(ElementType.TYPE)
	public static @interface PreferenceName {

		String value();
	}
}
