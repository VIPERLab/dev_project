/**
 * 
 */
package cn.kuwo.sing.ui.activities;

import cn.kuwo.framework.log.KuwoLog;
import cn.kuwo.sing.R;
import cn.kuwo.sing.controller.LiveRoomController;
import android.os.Bundle;

/**
 * @author wangming
 *
 */
public class LiveRoomActivity extends BaseActivity {
	private final String TAG = "LiveRoomActivity";
	private LiveRoomController mController;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		KuwoLog.i(TAG, "onCreate");
		setContentView(R.layout.live_room_layout);
		mController = new LiveRoomController(this);
	}
}
