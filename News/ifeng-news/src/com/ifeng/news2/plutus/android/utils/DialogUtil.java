package com.ifeng.news2.plutus.android.utils;

import android.app.Dialog;
import android.content.Context;
import android.util.DisplayMetrics;
import android.view.Window;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;

public class DialogUtil {

	/**
	 * Show a dialog with a webview as content view, which is full screen
	 * @param context The context to show the dialog
	 * @param url The url will be loaded by the webview
	 */
	public static void showWebDialog(Context context, String url) {
		Dialog	detailDialog = new Dialog(context, android.R.style.Theme_Translucent_NoTitleBar);
		detailDialog.requestWindowFeature(Window.FEATURE_NO_TITLE );
		WebView web = new WebView(context);
		initWebView(web);
		
		DisplayMetrics metrics = new DisplayMetrics();
		detailDialog.getWindow().getWindowManager().getDefaultDisplay().getMetrics(metrics);
		
		detailDialog.addContentView(web, new android.view.ViewGroup.LayoutParams(
				metrics.widthPixels, metrics.heightPixels));
		detailDialog.show();
		web.loadUrl(url);
	}
	
	private static void initWebView(WebView webView) {
		initSettings(webView.getSettings());
		webView.setScrollbarFadingEnabled(false);
		webView.setHorizontalScrollBarEnabled(false);
		webView.setVerticalScrollBarEnabled(false);
		webView.setWebViewClient(new WebViewClient() {
			@Override
			public boolean shouldOverrideUrlLoading(WebView view, String url) {
				return false;
			}
		});
	}

	private static void initSettings(WebSettings settings) {
		settings.setAppCacheEnabled(true);
		settings.setAllowFileAccess(true);
		settings.setSupportZoom(false);
		settings.setBuiltInZoomControls(false);
		settings.setLoadWithOverviewMode(true);
		settings.setUseWideViewPort(true);
	}
}
