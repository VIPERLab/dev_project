package com.ifeng.news2.commons.upgrade;

import java.lang.annotation.Documented;
import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

@Documented
@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.TYPE)
public @interface UpgradeNotify {
	int layout_update();

	int drawable_default_icon() default 0;

	int drawable_start_icon() default 0;

	int drawable_update_icon() default 0;

	int drawable_success_icon() default 0;

	int drawable_fail_icon() default 0;

	int id_percent() default 0;

	int id_icon() default 0;

	int id_title() default 0;

	int id_progressbar();

	String startTicker() default "";

	String successTicker() default "";

	String successMessage() default "";

	String failTicker() default "";

	String failMessage() default "";

	String updateTitle() default "";
}
