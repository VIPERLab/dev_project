package com.ifeng.news2.sport_live.util;

import java.util.Random;

/**
 * 随机产生邮箱，电话或者qq号
 * 
 * @author SunQuan
 * 
 */
public class RandomUserInfoUtil {
	private static final char[] eng_char = new char[] { 'a', 'b', 'c', 'd',
			'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q',
			'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z' };
	private static final String[] first_name = new String[] { "zhao", "qian",
			"sun", "li", "zhou", "wang", "wu", "zheng", "feng", "chen", "chu",
			"wei", "jiang", "shen", "yang", "zhu", "qin", "you", "xu", "he",
			"shi", "zhan", "kong", "cao", "xie", "jin", "shu", "fang", "yuan" };
	private static final String[] tel_head = new String[] { "13", "18", "15" };
	private static final String[] email_suffix = new String[] { "@gmail.com",
			"@yahoo.com", "@msn.com", "@hotmail.com", "@aol.com", "@ask.com",
			"@live.com", "@qq.com", "@0355.net", "@163.com", "@163.net",
			"@263.net", "@3721.net", "@yeah.net", "@googlemail.com",
			"@126.com", "@sina.com", "@sohu.com", "@yahoo.com.cn" };

	public static final int EMAIL = 0x0000;
	public static final int TEL = 0x0001;
	public static final int QQ = 0x0002;

	public static String generateRandomInfo(int type) {
		Random random = new Random();
		StringBuilder uName = new StringBuilder();
		switch (type) {
		case EMAIL: // email
			uName.append(
					first_name[random.nextInt(Integer.MAX_VALUE)
							% first_name.length]).append(
					eng_char[random.nextInt(Integer.MAX_VALUE)
							% eng_char.length]);
			int month = random.nextInt(Integer.MAX_VALUE) % 11 + 1;
			int day = random.nextInt(Integer.MAX_VALUE) % 29 + 1;
			if (month < 10)
				uName.append("0");
			uName.append(month);
			if (day < 10)
				uName.append("0");
			uName.append(day);
			uName.append(email_suffix[random.nextInt(Integer.MAX_VALUE)
					% email_suffix.length]);
			break;
		case TEL: // tel
			uName.append(
					tel_head[random.nextInt(Integer.MAX_VALUE)
							% tel_head.length])
					.append(random.nextInt(Integer.MAX_VALUE) % 10)
					.append(random.nextInt(Integer.MAX_VALUE) % 10)
					.append(random.nextInt(Integer.MAX_VALUE) % 10)
					.append(random.nextInt(Integer.MAX_VALUE) % 10)
					.append(random.nextInt(Integer.MAX_VALUE) % 10)
					.append(random.nextInt(Integer.MAX_VALUE) % 10)
					.append(random.nextInt(Integer.MAX_VALUE) % 10)
					.append(random.nextInt(Integer.MAX_VALUE) % 10)
					.append(random.nextInt(Integer.MAX_VALUE) % 10);
			break;
		case QQ: // qq
			uName.append(random.nextInt(Integer.MAX_VALUE) % 9 + 1)
					.append(random.nextInt(Integer.MAX_VALUE) % 10)
					.append(random.nextInt(Integer.MAX_VALUE) % 10)
					.append(random.nextInt(Integer.MAX_VALUE) % 10)
					.append(random.nextInt(Integer.MAX_VALUE) % 10);
			int lenth = 0;
			while (random.nextInt(Integer.MAX_VALUE) % 2 == 0) {
				if (lenth > 6)
					break;
				uName.append(random.nextInt(Integer.MAX_VALUE) % 10);
				lenth++;
			}
			break;
		default:
			break;
		}
		return uName.toString();
	}
}
