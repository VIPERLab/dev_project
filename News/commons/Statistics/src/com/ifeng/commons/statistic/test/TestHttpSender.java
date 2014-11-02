package com.ifeng.commons.statistic.test;

import java.io.IOException;

import com.qad.util.HttpSender;
import com.qad.util.HttpSender.RequestMethod;

import junit.framework.TestCase;

public class TestHttpSender extends TestCase{

	public void testPost() throws IOException
	{
		String content="datatype=test&mos=android_8&publishid=myTest&softversion=1.0&softid=testApp&ua=GT-P1000_2.2&testParam=testValue&session=353942040322543201205247037%402012-05-24+18%3A31%3A34%23PAF%23start%402012-05-24+18%3A32%3A27%23PAF%23start&ip=192_168_189_151&net=WIFI&userKey=03e6da56-f60b-4f53-a6d7-a8ef4d544d75";
		String url="http://1.ifengmo.sinaapp.com/statistics/statistics.php";
		HttpSender sender=new HttpSender();
		sender.setMethod(RequestMethod.POST);
		sender.send(url, content);
	}
	
	public void testGet() throws IOException
	{
		String content="datatype=test&mos=android_8&publishid=myTest&softversion=1.0&softid=testApp&ua=GT-P1000_2.2&testParam=testValue&session=353942040322543201205247037%402012-05-24+18%3A31%3A34%23PAF%23start%402012-05-24+18%3A32%3A27%23PAF%23start&ip=192_168_189_151&net=WIFI&userKey=03e6da56-f60b-4f53-a6d7-a8ef4d544d75";
		String url="http://1.ifengmo.sinaapp.com/statistics/statistics.php";
		HttpSender sender=new HttpSender();
		sender.setMethod(RequestMethod.GET);
		sender.send(url, content);
	}
}
