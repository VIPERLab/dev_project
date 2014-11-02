package com.ifeng.commons.push.test;

import java.io.IOException;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.TimeUnit;

import org.json.JSONException;

import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.test.ServiceTestCase;

import com.ifeng.commons.push.PushEntity;
import com.ifeng.commons.push.PushService;
import com.ifeng.commons.push.Utils;
import com.qad.app.BaseBroadcastReceiver;
import com.qad.mock.MockHttpManager;
import com.qad.net.HttpManager;

public class PushServiceTest extends ServiceTestCase<PushService>{

	public PushServiceTest() {
		super(PushService.class);
	}
	
	private static class TestApp extends BaseBroadcastReceiver
	{
		private CountDownLatch latch;
		
		public TestApp(CountDownLatch latch) {
			this.latch=latch;
		}
		
		@Override
		public IntentFilter getIntentFilter() {
			IntentFilter filter=new IntentFilter();
			filter.addAction(PushService.ACTION_BASE+"IfengNews2_android_v2");
			return filter;
		}

		@Override
		public void onReceive(Context context, Intent intent) {
			assertNotNull(intent.getSerializableExtra(PushService.EXTRA_ENTITY));
			latch.countDown();
		}
	}
	
	private class TestAlarm extends BaseBroadcastReceiver
	{
		private CountDownLatch latch;

		TestAlarm(CountDownLatch latch){
			this.latch=latch;
		}
		
		@Override
		public IntentFilter getIntentFilter() {
			IntentFilter filter=new IntentFilter();
			filter.addAction(PushService.ACTION_SET);
			return filter;
		}

		@Override
		public void onReceive(Context context, Intent intent) {
			assertEquals(15L*1000*60, intent.getLongExtra(PushService.EXTRA_TIMER, 0));
			assertEquals("IfengNews2_android_v2", intent.getStringExtra(PushService.EXTRA_PRODUCT));
			latch.countDown();
		}
	}
	
	public void testParseOnline() throws JSONException, IOException
	{
		String url="http://ct1.ifeng.com/fhzk/v2/ifengnews/getPushNews?type=IfengNews2_android_v2&timestamp=0";
		String content=HttpManager.getHttpText(url);
		System.out.println(content);
		PushEntity entity=Utils.parsePushEntity(content);
		assertNotNull(entity);
	}
	
	public void testParse() throws JSONException
	{
		PushEntity entity=Utils.parsePushEntity("{'product':'IfengNews2_android_v2','msg':'6月13日上午，原中国足协副主席，国家体育总局足球运动管理中心主任谢亚龙因犯受贿罪，一审被判10年6个月，没收财产20万','para':{'id':'37955915','timer':'15','type':'doc'},'timestamp':'1339558272308'}");
		assertEquals("6月13日上午，原中国足协副主席，国家体育总局足球运动管理中心主任谢亚龙因犯受贿罪，一审被判10年6个月，没收财产20万", entity.getMsg());
		assertEquals("IfengNews2_android_v2", entity.getProduct());
		assertEquals("37955915", entity.getId());
		assertEquals("15", entity.getTimer());
		assertEquals("doc", entity.getType());
		assertEquals("1339558272308", entity.getTimeStamp());
	}
	
	public void testPull() throws InterruptedException
	{
		final CountDownLatch latch=new CountDownLatch(2);
		HttpManager.setProxy(new MockHttpManager(){
			
			@Override
			public String getHttpText(String url) throws IOException {
				return "{'product':'IfengNews2_android_v2','msg':'6月13日上午，原中国足协副主席，国家体育总局足球运动管理中心主任谢亚龙因犯受贿罪，一审被判10年6个月，没收财产20万','para':{'id':'37955915','timer':'15','type':'doc'},'timestamp':'1339558272308'}";
			}
		});
		TestApp app=new TestApp(latch);
		TestAlarm alarm=new TestAlarm(latch);
		getSystemContext().registerReceiver(app, app.getIntentFilter());
		getSystemContext().registerReceiver(alarm, alarm.getIntentFilter());
		Intent intent=new Intent();
		intent.putExtra(PushService.EXTRA_PRODUCT, "IfengNews2_android_v2");
		intent.putExtra(PushService.EXTRA_COMPONENT_NAME, new ComponentName(getSystemContext(), TestApp.class));
		startService(intent);
		long timestamp=System.currentTimeMillis();
		latch.await(200, TimeUnit.MILLISECONDS);
		if(System.currentTimeMillis()-timestamp>180){
			fail("没有接受到通知");
		}
		getSystemContext().unregisterReceiver(app);
		getSystemContext().unregisterReceiver(alarm);
	}
	
	public void testPullFail() throws InterruptedException{
		final CountDownLatch latch=new CountDownLatch(1);
		HttpManager.setProxy(new MockHttpManager(){
			@Override
			public String getHttpText(String url) throws IOException {
				throw new IOException();
			}
		});
		TestAlarm alarm=new TestAlarm(latch);
		getSystemContext().registerReceiver(alarm, alarm.getIntentFilter());
		Intent intent=new Intent();
		intent.putExtra(PushService.EXTRA_PRODUCT, "IfengNews2_android_v2");
		startService(intent);
		long timestamp=System.currentTimeMillis();
		latch.await(200, TimeUnit.MILLISECONDS);
		if(System.currentTimeMillis()-timestamp>180){
			fail("没有接受到通知");
		}
		getSystemContext().unregisterReceiver(alarm);
	}
	
	public void testStartable() throws InterruptedException
	{
		assertFalse(PushService.ALIVE);
		startService(new Intent());
		assertTrue(PushService.ALIVE);
	}
	
	@Override
	protected void setUp() throws Exception {
		super.setUp();
		startService(new Intent());
		getService().reset();
		shutdownService();
	}
	
	public void testStartUp() throws Exception
	{
		Intent intent=new Intent();
		intent.putExtra(PushService.EXTRA_PRODUCT,"IfengNews2_android_v2");
		intent.putExtra(PushService.EXTRA_COMPONENT_NAME, new ComponentName(getContext(),TestApp.class));
		intent.setAction(PushService.ACTION_STARTUP);
		startService(intent);
		assertTrue(PushService.ALIVE);
		assertTrue(getService().getStartedProducts().contains("IfengNews2_android_v2"));
		shutdownService();
		assertFalse(PushService.ALIVE);
		startService(new Intent());
		assertTrue(getService().getStartedProducts().contains("IfengNews2_android_v2"));
	}
	
	public void testShutdown() throws Exception{
		Intent intent=new Intent();
		intent.putExtra(PushService.EXTRA_PRODUCT,"IfengNews2_android_v2");
		intent.setAction(PushService.ACTION_STOP);
		startService(intent);
		assertFalse(getService().getStartedProducts().contains("IfengNews2_android_v2"));
		assertTrue(getService().getStoppedProducts().contains("IfengNews2_android_v2"));
		shutdownService();
		startService(new Intent());
		assertFalse(getService().getStartedProducts().contains("IfengNews2_android_v2"));
		assertTrue(getService().getStoppedProducts().contains("IfengNews2_android_v2"));
	}
	
/*	想办法解决TestCase只能通过startService来启动的问题
	public void testSetAlarm() throws InterruptedException
	{
		final CountDownLatch latch=new CountDownLatch(1);
		HttpManager.setProxy(new MockHttpManager(){
			
			@Override
			public String getHttpText(String url) throws IOException {
				return "{'product':'IfengNews2_android_v2','msg':'6月13日上午，原中国足协副主席，国家体育总局足球运动管理中心主任谢亚龙因犯受贿罪，一审被判10年6个月，没收财产20万','para':{'id':'37955915','timer':'15','type':'doc'},'timestamp':'1339558272308'}";
			}
		});
		TestApp app=new TestApp(latch);
		getSystemContext().registerReceiver(app, app.getIntentFilter());
		Intent intent=new Intent(getSystemContext(),MyAlarmReceiver.class);
		intent.setAction(PushService.ACTION_SET);
		intent.putExtra(PushService.EXTRA_PRODUCT, "IfengNews2_android_v2");
		intent.putExtra(PushService.EXTRA_TIMER, 200L);
		assertFalse(PushService.ALIVE);
		getSystemContext().sendBroadcast(intent);
		long timestamp=System.currentTimeMillis();
		latch.await(600, TimeUnit.MILLISECONDS);
		if(System.currentTimeMillis()-timestamp>180){
			fail("没有接受到通知");
		}
		assertTrue(PushService.ALIVE);
		getSystemContext().unregisterReceiver(app);
	}*/

}
