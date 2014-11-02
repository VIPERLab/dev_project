package com.ifeng.news2.sport_live.util;

import java.lang.ref.ReferenceQueue;
import java.lang.ref.SoftReference;
import java.util.HashMap;

/**
 * 将PromptBaseView的子类对象封装成软引用的对象，放置在SoftReferenceMap里面
 * 
 * @param <K>
 * @param <V>
 */
public class SoftReferenceMap<K, V> extends HashMap<K, V> {

	private static final long serialVersionUID = 1L;
	private HashMap<K, SoftValue<K, V>> temp;
	private ReferenceQueue<V> queue;

	public SoftReferenceMap() {
		super();
		this.temp = new HashMap<K, SoftValue<K, V>>();
		queue = new ReferenceQueue<V>();
	}

	/**
	 * 首先，获取temp是否能够拿到PromptBaseView的子类对象
	 */
	@Override
	public boolean containsKey(Object key) {

		clearMap();

		return temp.containsKey(key);
	}

	@Override
	public V get(Object key) {
		clearMap();
		SoftValue<K, V> softValue = temp.get(key);
		if (softValue != null) {
			return softValue.get();
		}

		return null;
	}

	@Override
	public V put(K key, V value) {
		SoftValue<K, V> softReference = new SoftValue<K, V>(key, value, queue);
		temp.put(key, softReference);
		return null;
	}
	
	@Override
	public void clear() {
		temp.clear();
		super.clear();
	}

	/**
	 * 需要判断当前的temp对应那个软引用对象包装对象（手机）是否存在 在每一个操作执行的时候都去判读一下
	 * 当前的这个temp到底有多少（手机）被回收，用ReferenceQueue来存储被系统回收了（手机）的软引用对象
	 */
	@SuppressWarnings("unchecked")
	private void clearMap() {
		SoftValue<K, V> softReference = (SoftValue<K, V>) queue.poll();

		while (softReference != null) {
			temp.remove(softReference.key);
			softReference = (SoftValue<K, V>) queue.poll();
		}
	}

	@SuppressWarnings("hiding")
	private class SoftValue<K, V> extends SoftReference<V> {
		private K key;

		public SoftValue(K k, V r, ReferenceQueue<? super V> q) {
			super(r, q);
			this.key = k;
		}
	}

}
