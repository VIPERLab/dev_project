package com.ifeng.news2.share;


import java.util.ArrayList;

import android.app.Dialog;
import android.content.Context;
import android.content.DialogInterface.OnCancelListener;
import android.view.Gravity;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.view.WindowManager;
import android.widget.TextView;

import com.ifeng.news2.R;
import com.ifeng.news2.util.StatisticUtil;

public class ShareAlertBig  extends ShareAlert  {
	
	public ShareAlertBig(Context context, WXHandler wxHandler, String url,String title,String content,ArrayList<String> imageList
			, String documentId, StatisticUtil.StatisticPageType type) {
		super(context, wxHandler, url, title, content, imageList, documentId, type);
	}

	public ShareAlertBig(Context context, WXHandler wxHandler, String url,String title,String content,ArrayList<String> imageList
			, String documentId, StatisticUtil.StatisticPageType type,int state) {
		super(context, wxHandler, url, title, content, imageList, documentId, type, state);
	}

	/**
	 * @param context
	 *            Context.
	 * @param title
	 *            The title of this AlertDialog can be null .
	 * @param items
	 *            button name list.
	 * @param alertDo
	 *            methods call Id:Button + cancel_Button.
	 * @param exit
	 *            Name can be null.It will be Red Color
	 * @return A AlertDialog
	 */
	@Override
	public  Dialog getCustomDialog(final Context context, OnCancelListener cancelListener, final OnAlertSelectId alertDo) {
		final Dialog dlg = new Dialog(context, R.style.shareDialogTheme);
		
		dlg.show();
		dlg.setCanceledOnTouchOutside(true);
		if (cancelListener != null) {
			dlg.setOnCancelListener(cancelListener);
		}
		Window window = dlg.getWindow();
		window.setGravity(Gravity.BOTTOM);
		window.setLayout(WindowManager.LayoutParams.MATCH_PARENT, WindowManager.LayoutParams.WRAP_CONTENT);
		window.setContentView(R.layout.detail_share);
		
		TextView weibo_share = (TextView) window.findViewById(R.id.weibo_share);
		TextView tenqt_share = (TextView) window.findViewById(R.id.tenqt_share);
		TextView tenqq_share = (TextView) window.findViewById(R.id.tenqq_share);
		TextView tenqz_share = (TextView) window.findViewById(R.id.tenqz_share);
		TextView weixin_share = (TextView) window.findViewById(R.id.weixin_share);
		TextView pengyou_share = (TextView) window.findViewById(R.id.pengyou_share);
		TextView yxpengyou_share = (TextView) window.findViewById(R.id.yxpengyou_share);
		TextView yixin_share = (TextView) window.findViewById(R.id.yixin_share);
		TextView sms_share = (TextView) window.findViewById(R.id.sms_share);
		TextView dlg_cancel = (TextView) window.findViewById(R.id.dlg_cancel);
		
		weibo_share.setOnClickListener(new OnClickListener(){
			@Override
			public void onClick(View arg0) {
				alertDo.onClick(WEIBO_BUT);
				dlg.dismiss();
			}
			
		});
		
		tenqt_share.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				alertDo.onClick(TENQT_BUT);
				dlg.dismiss();
			}
		});
		tenqz_share.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				alertDo.onClick(TENQZ_BUT);
				dlg.dismiss();
			}
		});
		tenqq_share.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				alertDo.onClick(TENQQ_BUT);
				dlg.dismiss();
			}
		});
		
		weixin_share.setOnClickListener(new OnClickListener(){
			@Override
			public void onClick(View arg0) {
				alertDo.onClick(WEIXIN_BUT);
				dlg.dismiss();
			}
			
		});
		
		pengyou_share.setOnClickListener(new OnClickListener(){
			@Override
			public void onClick(View arg0) {
				alertDo.onClick(PENGYOU_BUT);
				dlg.dismiss();
				
			}
			
		});
		
		yixin_share.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				alertDo.onClick(YIXIN_BUT);
				dlg.dismiss();
			}
		});
		
		yxpengyou_share.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				alertDo.onClick(YXPENGYOU_BUT);
				dlg.dismiss();
			}
		});
		
		sms_share.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				// TODO Auto-generated method stub
				alertDo.onClick(SMS_BUT);
				dlg.dismiss();
			}
		});
		
		dlg_cancel.setOnClickListener(new OnClickListener(){
			@Override
			public void onClick(View arg0) {
				// TODO Auto-generated method stub
				dlg.dismiss();
			}
			
		});
		
		return dlg;
	}

}
