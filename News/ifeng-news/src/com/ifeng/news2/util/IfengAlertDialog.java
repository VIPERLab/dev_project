package com.ifeng.news2.util;

import android.text.TextUtils;

import android.app.Activity;

import android.content.DialogInterface;
import android.util.DisplayMetrics;
import android.view.View;
import android.view.Window;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.LinearLayout.LayoutParams;
import com.ifeng.news2.R;

import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface.OnClickListener;

/**
 * @author liu_xiaoliang
 *
 */
public class IfengAlertDialog {

  public static AlertDialog CreateDialog(Context context, String title, String introduction, String ok, String cancel, final OnClickListener yes, final OnClickListener no){

    AlertDialog.Builder builder = new AlertDialog.Builder(context, R.style.upgrade_dialog);
    final AlertDialog dialog = builder.create();
    dialog.show();
    Window window = dialog.getWindow();
    window.setContentView(R.layout.upgrade_layout);

    DisplayMetrics display = new DisplayMetrics();
    ((Activity)context).getWindowManager().getDefaultDisplay().getMetrics(display);

    LayoutParams params = new LayoutParams(display.widthPixels*4/5, LayoutParams.WRAP_CONTENT);
    LinearLayout buttonLayout = (LinearLayout)window.findViewById(R.id.button_layout);
    buttonLayout.setLayoutParams(params);

    TextView dialogTitle = (TextView)window.findViewById(R.id.title);
    TextView dialogIntrod = (TextView)window.findViewById(R.id.introduction);

    TextView okBut = (TextView)window.findViewById(R.id.ok);
    TextView cancelBut = (TextView)window.findViewById(R.id.cancel);

    if (!TextUtils.isEmpty(ok)) okBut.setText(ok);
    if (!TextUtils.isEmpty(cancel)) cancelBut.setText(cancel);

    if (!TextUtils.isEmpty(title)) dialogTitle.setText(title);
    if (TextUtils.isEmpty(introduction)) {
      dialogIntrod.setVisibility(View.GONE);
    } else {
      dialogIntrod.setVisibility(View.VISIBLE);
      dialogIntrod.setText(introduction);
    }
    okBut.setOnClickListener(new View.OnClickListener() {

      @Override
      public void onClick(View v) {
        if (yes != null)
          yes.onClick(dialog, DialogInterface.BUTTON_POSITIVE);
        dialog.dismiss();
      }
    });
    cancelBut.setOnClickListener(new View.OnClickListener() {

      @Override
      public void onClick(View v) {
        if (no != null)
          no.onClick(dialog, DialogInterface.BUTTON_NEGATIVE);
        dialog.dismiss();
      }
    });
    return dialog;
  }

}
