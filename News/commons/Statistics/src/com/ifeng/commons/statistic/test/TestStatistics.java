package com.ifeng.commons.statistic.test;

import java.io.IOException;

import org.apache.http.HttpResponse;
import org.apache.http.HttpStatus;
import org.apache.http.ProtocolVersion;
import org.apache.http.StatusLine;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.message.BasicHttpResponse;
import org.apache.http.message.BasicStatusLine;

import android.test.AndroidTestCase;

import com.ifeng.commons.statistic.Statistics;
import com.qad.mock.MockHttpManager;
import com.qad.net.HttpManager;
import com.qad.util.HttpSender.RequestMethod;

public class TestStatistics extends AndroidTestCase {

	// 测试Statistics在start阶段进行的配置检查
	public void testCheck() {
		try {
			Statistics.ready(null).start();//
		} catch (NullPointerException e) {
			e.printStackTrace();
			// ok Statistics wish not be null context;
		}

		try {
			Statistics.ready(getContext()).start();
		} catch (NullPointerException e) {
			e.printStackTrace();
			// ok Statistics force have request url
		}

		try {
			Statistics.ready(getContext()).setRequestUrl("http://www.test.com")
					.appendMobileOS().appendMobileOS().start();
		} catch (IllegalArgumentException e) {
			e.printStackTrace();
			// ok Statistics unable to append duplicate param
		}
	}

	// 测试发送成功后，StaCache会移除发送记录
	public void testSendSuccess() {
		// mock all send will be ok
		HttpManager.setProxy(new MockHttpManager() {
			@Override
			public HttpResponse executeHttpGet(String url) throws IOException {
				StatusLine line = new BasicStatusLine(new ProtocolVersion(
						"HTTP", 1, 1), HttpStatus.SC_OK, null);
				HttpResponse response = new BasicHttpResponse(line);
				return response;
			}

			@Override
			public HttpResponse executeHttpPost(HttpPost post)
					throws IOException {
				StatusLine line = new BasicStatusLine(new ProtocolVersion(
						"HTTP", 1, 1), HttpStatus.SC_OK, null);
				HttpResponse response = new BasicHttpResponse(line);
				return response;
			}
		});

		Statistics statistics = Statistics.ready(getContext()).setRequestUrl(
				"http://www.neverget.com");
		statistics.clearCache();

		Statistics.addRecord(Statistics.RECORD_PAGE_FOCUS, "view Page");
		assertEquals(1, statistics.getReadOnlyStatistics().size());
		statistics.send();
		assertEquals(0, statistics.getReadOnlyStatistics().size());

		Statistics.addRecord(Statistics.RECORD_PAGE_FOCUS, "view Page2");
		assertEquals(1, statistics.getReadOnlyStatistics().size());
		statistics.send();
		assertEquals(0, statistics.getReadOnlyStatistics().size());
		statistics.stop(false);

	}

	// 测试发送失败后,StaCache会持续保持
	public void testSendFail() {
		// mock all send will be failed
		HttpManager.setProxy(new MockHttpManager() {
			@Override
			public HttpResponse executeHttpGet(String url) throws IOException {
				throw new IOException();
			}

			@Override
			public HttpResponse executeHttpPost(HttpPost post)
					throws IOException {
				throw new IOException();
			}
		});

		Statistics statistics = Statistics.ready(getContext()).setRequestUrl(
				"http://www.neverget.com");
		statistics.clearCache();
		Statistics.addRecord(Statistics.RECORD_PAGE_FOCUS, "view Detail");

		assertEquals(1, statistics.getReadOnlyStatistics().size());

		statistics.send();
		statistics.setRequestMethod(RequestMethod.POST);
		assertEquals(1, statistics.getReadOnlyStatistics().size());

		Statistics.addRecord(Statistics.RECORD_PAGE_FOCUS, "view Detail2");
		statistics.send();
		assertEquals(2, statistics.getReadOnlyStatistics().size());
		statistics.stop(false);
	}

	/**
	 * 测试当突发杀死情况后
	 */
	public void testAppKill() {
		// mock all send will be failed
		HttpManager.setProxy(new MockHttpManager() {
			@Override
			public HttpResponse executeHttpGet(String url) throws IOException {
				throw new IOException();
			}

			@Override
			public HttpResponse executeHttpPost(HttpPost post)
					throws IOException {
				throw new IOException();
			}
		});

		Statistics statistics = Statistics.ready(getContext()).setRequestUrl(
				"http://www.neverget.com");
		statistics.clearCache();
		Statistics.addRecord(Statistics.RECORD_PAGE_FOCUS, "view Detail");
		Statistics.addRecord(Statistics.RECORD_PAGE_FOCUS, "view Detail");
		Statistics.addRecord(Statistics.RECORD_PAGE_FOCUS, "view Detail");

		statistics.send();// send and will be persistance

		statistics.stop(false);// stop sending and clear instance cache
		statistics = null;

		Statistics newStatistics = Statistics.ready(getContext());
		assertEquals(3, newStatistics.getReadOnlyStatistics().size());
		newStatistics.stop(false);

	}

	/**
	 * 测试当超出GET最大长度时，是否会采取切割发送的策略
	 */
	public void testSplitGet() {
		// mock all send will be failed
		HttpManager.setProxy(new MockHttpManager() {
			@Override
			public HttpResponse executeHttpGet(String url) throws IOException {
				StatusLine line = new BasicStatusLine(new ProtocolVersion(
						"HTTP", 1, 1), HttpStatus.SC_OK, null);
				HttpResponse response = new BasicHttpResponse(line);
				return response;
			}

			@Override
			public HttpResponse executeHttpPost(HttpPost post)
					throws IOException {
				StatusLine line = new BasicStatusLine(new ProtocolVersion(
						"HTTP", 1, 1), HttpStatus.SC_OK, null);
				HttpResponse response = new BasicHttpResponse(line);
				return response;
			}
		});
		Statistics statistics = Statistics.ready(getContext()).setRequestUrl(
				"http://www.neverget.com");
		statistics.clearCache();
		//more than 1024
		for (int i = 0; i < 50; i++) {
			Statistics.addRecord(Statistics.RECORD_PAGE_FOCUS,
					"1234567890");
		}
		statistics.send();
		System.out.println(statistics.getReadOnlyStatistics().size());
		assertFalse(statistics.getReadOnlyStatistics().size()==0);
		statistics.send();
		assertEquals(0, statistics.getReadOnlyStatistics().size());
		statistics.stop(false);
	}

}
