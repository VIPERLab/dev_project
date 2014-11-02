package com.ifeng.news2.util;

import java.lang.reflect.Method;

public abstract class Compatible {

	public static void removeOverScroll(Object object)
	{
		if(object==null) return;
		try {
			Method overScrollMethod=object.getClass().getMethod("setOverScrollMode", int.class);
			overScrollMethod.invoke(object, 2);
		} catch (Exception e) {
			//always ignore
		}
	}
}
