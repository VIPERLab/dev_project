package com.weibo.net;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.InetSocketAddress;
import java.net.Proxy;
import java.net.SocketAddress;
import java.net.URL;

import android.app.Dialog;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.res.Resources;
import android.graphics.Bitmap;
import android.graphics.Color;
import android.net.http.SslError;
import android.os.Bundle;
import android.os.Handler;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewGroup.LayoutParams;
import android.view.Window;
import android.webkit.SslErrorHandler;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.RelativeLayout;

import com.ifeng.share.R;
import com.ifeng.share.action.ShareManager;
import com.ifeng.share.config.TokenTools;
import com.ifeng.share.sina.SinaManager;

public class WeiboDialog extends Dialog {

    static final FrameLayout.LayoutParams FILL = new FrameLayout.LayoutParams(
            ViewGroup.LayoutParams.FILL_PARENT, ViewGroup.LayoutParams.FILL_PARENT);
    static final int MARGIN = 4;
    static final int PADDING = 2;

    private final Weibo mWeibo;
    private String mUrl;
    private WeiboDialogListener mListener;
    private ProgressDialog mSpinner;
    private ImageView mBtnClose;
    private WebView mWebView;
    private RelativeLayout webViewContainer;
    private RelativeLayout mContent;
    Handler handler = new Handler();

    private final static String TAG = "Weibo-WebView";

    public WeiboDialog(final Weibo weibo, Context context, String url, WeiboDialogListener listener) {
        super(context, R.style.ContentOverlay);
        mWeibo = weibo;
        mUrl = url;
        mListener = listener;
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        mSpinner = new ProgressDialog(getContext());
        mSpinner.requestWindowFeature(Window.FEATURE_NO_TITLE);
        mSpinner.setMessage("Loading...");

        requestWindowFeature(Window.FEATURE_NO_TITLE);
        mContent = new RelativeLayout(getContext());

        setUpWebView();

        // setUpCloseBtn();

        addContentView(mContent, new LayoutParams(LayoutParams.FILL_PARENT,
                LayoutParams.FILL_PARENT));
    }

    private void setUpWebView() {
        webViewContainer = new RelativeLayout(getContext());
        // webViewContainer.setOrientation(LinearLayout.VERTICAL);

        // webViewContainer.addView(title, new
        // LinearLayout.LayoutParams(LayoutParams.FILL_PARENT,
        // getContext().getResources().getDimensionPixelSize(R.dimen.dialog_title_height)));

        mWebView = new WebView(getContext());
        mWebView.setVerticalScrollBarEnabled(false);
        mWebView.setHorizontalScrollBarEnabled(false);
        mWebView.getSettings().setJavaScriptEnabled(true);
        mWebView.setWebViewClient(new WeiboDialog.WeiboWebViewClient());
        mWebView.loadUrl(mUrl);
        mWebView.setLayoutParams(FILL);
        mWebView.setVisibility(View.INVISIBLE);

        webViewContainer.addView(mWebView);

        RelativeLayout.LayoutParams lp = new RelativeLayout.LayoutParams(LayoutParams.FILL_PARENT,
                LayoutParams.FILL_PARENT);
        Resources resources = getContext().getResources();
        lp.leftMargin = resources.getDimensionPixelSize(R.dimen.dialog_left_margin);
        lp.topMargin = resources.getDimensionPixelSize(R.dimen.dialog_top_margin);
        lp.rightMargin = resources.getDimensionPixelSize(R.dimen.dialog_right_margin);
        lp.bottomMargin = resources.getDimensionPixelSize(R.dimen.dialog_bottom_margin);
        mContent.addView(webViewContainer);
    }

    private void setUpCloseBtn() {
        mBtnClose = new ImageView(getContext());
        mBtnClose.setClickable(true);
        mBtnClose.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mListener.onCancel();
                WeiboDialog.this.dismiss();
            }
        });

        mBtnClose.setImageResource(R.drawable.close_selector);
        mBtnClose.setVisibility(View.INVISIBLE);

        RelativeLayout.LayoutParams closeBtnRL = new RelativeLayout.LayoutParams(
                LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT);
        closeBtnRL.addRule(RelativeLayout.ALIGN_PARENT_RIGHT);
        closeBtnRL.addRule(RelativeLayout.ALIGN_PARENT_TOP);
        closeBtnRL.topMargin = getContext().getResources().getDimensionPixelSize(
                R.dimen.dialog_btn_close_right_margin);
        closeBtnRL.rightMargin = getContext().getResources().getDimensionPixelSize(
                R.dimen.dialog_btn_close_top_margin);

        webViewContainer.addView(mBtnClose, closeBtnRL);
    }

    private class WeiboWebViewClient extends WebViewClient {

        @Override
        public boolean shouldOverrideUrlLoading(WebView view, String url) {
            Log.d(TAG, "Redirect URL: " + url);
            // 待后台增加对默认重定向地址的支持后修改下面的逻辑
            if (url.startsWith(mWeibo.getRedirectUrl())) {
                if (mSpinner.isShowing()) {
                    mSpinner.dismiss();
                }
                handleRedirectUrl(view, url);
//                WeiboDialog.this.dismiss();
                return true;
            }
            view.loadUrl(url);
            // launch non-dialog URLs in a full browser
//            getContext().startActivity(new Intent(Intent.ACTION_VIEW, Uri.parse(url)));
            return true;
        }

        @Override
        public void onReceivedError(WebView view, int errorCode, String description,
                String failingUrl) {
            super.onReceivedError(view, errorCode, description, failingUrl);
            if (mSpinner.isShowing()) {
                mSpinner.dismiss();
            }
            mListener.onError(new DialogError(description, errorCode, failingUrl));
            WeiboDialog.this.dismiss();
        }

        @Override
        public void onPageStarted(WebView view, String url, Bitmap favicon) {
            Log.d(TAG, "onPageStarted URL: " + url);
            // google issue. shouldOverrideUrlLoading not executed
            if (url.startsWith(mWeibo.getRedirectUrl())) {
                if (mSpinner.isShowing()) {
                    mSpinner.dismiss();
                }
                handleRedirectUrl(view, url);
                view.stopLoading();
                WeiboDialog.this.dismiss();
                return;
            }
            super.onPageStarted(view, url, favicon);
            mSpinner.show();
        }

        @Override
        public void onPageFinished(WebView view, String url) {
            Log.d(TAG, "onPageFinished URL: " + url);
            super.onPageFinished(view, url);
            if (mSpinner.isShowing()) {
                mSpinner.dismiss();
            }

            mContent.setBackgroundColor(Color.TRANSPARENT);
            webViewContainer.setBackgroundResource(R.drawable.dialog_bg);
            // mBtnClose.setVisibility(View.VISIBLE);
            mWebView.setVisibility(View.VISIBLE);
        }

        public void onReceivedSslError(WebView view, SslErrorHandler handler, SslError error) {
            handler.proceed();
        }

    }

    private void handleRedirectUrl(WebView view, String url) {
        final Bundle values = Utility.parseUrl(url);

        String error = values.getString("error");
        String error_code = values.getString("error_code");

        if (error == null && error_code == null) {
			new Thread(new Runnable() {
				@Override
				public void run() {
					getUserName(values);
				}
			}).start();
        } else if (error.equals("access_denied")) {
            // 用户或授权服务器拒绝授予数据访问权限
            mListener.onCancel();
        } else {
            mListener.onWeiboException(new WeiboException(error, Integer.parseInt(error_code)));
        }
    }

    private static String getHtml(String urlString) {

        try {

            StringBuffer html = new StringBuffer();

            SocketAddress sa = new InetSocketAddress("10.75.0.103", 8093);
            Proxy proxy = new Proxy(java.net.Proxy.Type.HTTP, sa);

            URL url = new URL(urlString);

            HttpURLConnection conn = (HttpURLConnection) url.openConnection(proxy);

            InputStreamReader isr = new InputStreamReader(conn.getInputStream());

            BufferedReader br = new BufferedReader(isr);

            String temp;

            while ((temp = br.readLine()) != null) {

                html.append(temp);

            }

            br.close();

            isr.close();
            return html.toString();

        } catch (Exception e) {

            e.printStackTrace();

            return null;

        }
        
    }
    
    @Override
    public void dismiss() {
        
        // bug #13319 为了避免报下面的错误，在destroy WebView前需要先
        // 将其从view系统中remove
        //Error: WebView.destroy() called while still attached
    	//bug #14802 从新浪微博界面返回的时候会有一个小阴影划过。 注释掉下面webview removeView代码
//        webViewContainer.removeView(mWebView);
//        mWebView.removeAllViews();
//    	mWebView.destroy();
    	
    	super.dismiss();
    }
    
    @Override
    public void onBackPressed() {
        if (mSpinner.isShowing()) {
            mSpinner.dismiss();
        }
//    	dismiss(); 
    	super.onBackPressed(); // 这里会cancel这个dialog，所以不需要dismiss
    }
    
    /**
     * 获取用户名与授权是两个操作，需要同时执行完才能让dialog消失，请求不能在主线程执行，在高版本sdk下会报NetWorkOnMainThreadException
     * @param values
     */
    private void getUserName(final Bundle values) {
		String token = values.getString("access_token");
		String expires_in = values.getString("expires_in");
		String uid = values.getString("uid");
		if(token!=null && token.length()>0&& uid!=null&& uid.length()>0){
			AccessToken accessToken = new AccessToken(token, Weibo.getAppSecret());
			accessToken.setExpiresIn(expires_in);
			Weibo.getInstance().setAccessToken(accessToken);
			if(expires_in!=null && expires_in.length()>0){
				//保存过期时间
				SinaManager.saveExpiresTime(getContext(),Long.valueOf(expires_in));
			}
			String username =SinaManager.getUsername(getContext(),uid, accessToken);
			if(username==null || username.length()==0) {
				username = "无法显示账号信息";
			}
			TokenTools.saveToken(getContext(),ShareManager.SINA,token,Weibo.getAppSecret(), username);
		}
		handler.post(new Runnable() {
			
			@Override
			public void run() {
				mListener.onComplete(values);
				WeiboDialog.this.dismiss();
			}
		});
	}
}
