package com.qad.loader;

import java.io.File;
import java.io.IOException;
import java.lang.Thread.UncaughtExceptionHandler;
import java.text.ParseException;
import java.util.HashMap;
import java.util.Set;
import java.util.WeakHashMap;
import java.util.concurrent.BlockingQueue;
import java.util.concurrent.Callable;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.Executor;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.FutureTask;
import java.util.concurrent.LinkedBlockingQueue;
import java.util.concurrent.RejectedExecutionHandler;
import java.util.concurrent.ThreadFactory;
import java.util.concurrent.ThreadPoolExecutor;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicInteger;

import android.graphics.Bitmap;
import android.graphics.drawable.BitmapDrawable;
import android.os.Handler;
import android.os.Looper;
import android.os.Message;
import android.support.v4.app.Fragment;
import android.text.TextUtils;
import android.util.Log;
import android.widget.ImageView;

import com.qad.loader.ImageLoader.Pack;
import com.qad.util.LogHandler;
import com.qad.util.QadArrayDeque;
import com.qad.view.RecyclingImageView;

/**
 * Class handles loading task in {@link ExecutorService}, note that you should
 * call {@link #getSettings()} to setup parameters of the loader.<br><br>
 * 
 * @gm, this class is <B>NOT</B> singleton, for that different {@link Loader} could have their own<br>
 * {@link ExecutorService} to execute tasks, and as they do not share the same task queue, their tasks <br>
 * cannot be blocked by the others
 */
public class LoaderExecutor {

	/**
	 * Core thread number of {@link #THREAD_POOL_EXECUTOR}
	 */
	private static final int CORE_POOL_SIZE = 1 ;
	
	/**
	 * Max pool size number of {@link #THREAD_POOL_EXECUTOR}
	 */
	private static final int MAXIMUM_POOL_SIZE = 32;
	
	/**
	 * Keep alive of thread after excuting, in seconds, of {@link #THREAD_POOL_EXECUTOR}
	 */
	private static final int KEEP_ALIVE = 1;
	
	/**
	 * Callback id for success computation of handler
	 */
	private static final int MESSAGE_COMPLETE = 0x303;
	
	/**
	 * Callback id for failed computation of handler
	 */
	private static final int MESSAGE_FAILED = 0x304;
	
	
  /**
	 *Order enums 
	 */
	public static enum EXECUTE_ORDER {
		/**
		 * Indicates the task should be excuted in order of 'first in first out'
		 */
		FIFO_ORDER,
		
		/**
		 * Indicates the task should be excuted in order of 'first in last out'
		 */
		FILO_ORDER;
	}
	
	private HashMap<String, WeakHashMap<ImageView, LoadContext<?, ImageView, ?>>> queueMap ;	
	
	/**
	 * Thread factory for {@link #THREAD_POOL_EXECUTOR}, new thread will be given the name
	 * like 'LoaderExecutor #($No)'
	 */
	private final ThreadFactory sThreadFactory = new ThreadFactory() {
		private final AtomicInteger mCount = new AtomicInteger(1);

		public Thread newThread(final Runnable r) {
		    Thread t = new Thread(r, loaderName + " LoaderExecutor #" + mCount.getAndIncrement());
		    t.setUncaughtExceptionHandler(new UncaughtExceptionHandler() {
                
                @Override
                public void uncaughtException(Thread thread, Throwable ex) {
                    Log.e("Sdebug", thread.getName() + " uncaughtException called!!!");
                    // 在下载线程出现异常错误时，直接丢弃并清除任务列表中的记录
                    String url = ((LoadCallable<?>)((MyFutureTask<?>)((MyRunnable)r).r).getCallable()).context.getParam().toString();
                    queueMap.remove(url);
//                    LogHandler.addLogRecord("LoaderExecutor"
//                            , "UncaughtException occurs in working thread"
//                            , "The url is " + LogHandler.processURL(url) + ", size of task is " + queueMap.size() + ", Exception Info: " + LogHandler.stackTraceToString(ex));
                }
            });
			return t; 
		}
	};

	/**
	 * Blocking queue for runnables, holds by {@link #THREAD_POOL_EXECUTOR}
	 */
	private final BlockingQueue<Runnable> poolWorkQueue = new LinkedBlockingQueue<Runnable>(6);

	/**
	 * An {@link Executor} that can be used to execute tasks in parallel.
	 */
//	public final Executor THREAD_POOL_EXECUTOR = new ThreadPoolExecutor(
//			CORE_POOL_SIZE, MAXIMUM_POOL_SIZE, KEEP_ALIVE, TimeUnit.SECONDS,
//			poolWorkQueue, sThreadFactory, new ThreadPoolExecutor.CallerRunsPolicy());

	public final Executor THREAD_POOL_EXECUTOR = new ThreadPoolExecutor(
	          CORE_POOL_SIZE, MAXIMUM_POOL_SIZE, KEEP_ALIVE, TimeUnit.SECONDS,
            poolWorkQueue, sThreadFactory, new RejectedExecutionHandler() {
                
                @Override
                public void rejectedExecution(Runnable r, ThreadPoolExecutor executor) {
                    Log.e("Sdebug", "rejectedExecution called");
                    
                    // 在下载任务被Reject时，不在主线程执行，直接丢弃并清除任务列表中的记录
                    String url = ((LoadCallable<?>)((MyFutureTask<?>)((MyRunnable)r).r).getCallable()).context.getParam().toString();
                    queueMap.remove(url);
//                    LogHandler.addLogRecord("LoaderExecutor"
//                            , "Task is rejected by ThreadPoolExecutor"
//                            , "The url is " + LogHandler.processURL(url) + ", size of task is " + queueMap.size());
//                    if (!executor.isShutdown()) {
//                        r.run();
//                    }
                }
            });

	
	/**
	 * An {@link Executor} that executes tasks one at a time in serial order (first in last out).
	 * This serialization is global to a particular process.
	 */
	public final Executor SERIAL_EXECUTOR = new SerialExecutor();
	
	/**
	 * An {@link Executor} that executes tasks one at a time in serial order (first in first out).
	 * This serialization is global to a particular process.
	 */
	public final Executor FIFO_SERIAL_EXECUTOR = new FifoSerialExecutor();

	/**
	 * @gm, The difference of {@link SerialExecutor} and {@link FifoSerialExecutor} is that how the poll task<br>
	 * from task queue ({@link QadArrayDeque#poll()} or {@link QadArrayDeque#pollLast()}) 
	 */
    private class SerialExecutor implements Executor {
        final QadArrayDeque<Runnable> mTasks = new QadArrayDeque<Runnable>();
        Runnable mActive;

        public synchronized void execute(final Runnable r) {
            mTasks.offer(new MyRunnable(r) {
                public void run() {
                    try {
                        r.run();
                    } finally {
                        scheduleNext();
                    }
                }
            });
            
           	scheduleNext();
        }

        protected synchronized void scheduleNext() {
            if ((mActive = mTasks.pollLast()) != null) {
                THREAD_POOL_EXECUTOR.execute(mActive);
            }
        }
    }
    
    /**
     * Please refer to {@link SerialExecutor}
     */
    private class FifoSerialExecutor implements Executor {
        final QadArrayDeque<Runnable> mTasks = new QadArrayDeque<Runnable>();
        Runnable mActive;

        public synchronized void execute(final Runnable r) {
            mTasks.offer(new MyRunnable(r) {
                public void run() {
                    try {
                        r.run();
                    } finally {
                        scheduleNext();
                    }
                }
            });
            
            scheduleNext();
        }

        protected synchronized void scheduleNext() {
            if ((mActive = mTasks.poll()) != null) {
                THREAD_POOL_EXECUTOR.execute(mActive);
            }
        }
    }
    
    private abstract class MyRunnable implements Runnable {

        public Runnable r;
        public MyRunnable(Runnable r) {
            this.r = r;
        }        
    }
    
    private class MyFutureTask<V> extends FutureTask<V> {

        private Callable<V> callable = null;
        
        public MyFutureTask(Callable<V> callable) {
            super(callable);
            this.callable = callable;
        }
        
        public MyFutureTask(Runnable runnable, V result) {
            super(runnable, result);
        }
        
        public Callable<V> getCallable() {
            return callable;
        }
    }
    
    /**
     * name of loader which hires this loader executor to work
     */
    private String loaderName = "default loader";
    
	/**
	 * Hanlder to make callbacks on the main thread
	 */
    private final Handler sHandler = new Handler(Looper.getMainLooper()) {
    	
    	@SuppressWarnings({ "unchecked", "rawtypes" })
		public void handleMessage(Message msg) {
			LoadContext context = (LoadContext) msg.obj;
			Object target = null;
			if (null == context) {
				return;
			} else {
				target = context.getTarget();
			}
    		if (isInvalidTarget(target)) {
    			Log.e("Sdebug", "LoaderExecutor: target is invalid !!!");
    			return;
    		} 
    		
    		if (null == target) {
    			// 现在context中target的引用使用了WeakReference，导致列表多次刷新时可能导致target为空，此时
    			// 不能直接返回，否者会导致显示底图
    			WeakHashMap<ImageView, LoadContext<?, ImageView, ?>> callbackMap = queueMap.get(context.getParam().toString());
    			if (null != callbackMap) {
    				for (ImageView view : callbackMap.keySet()) {
    					if (null != view) {
    						target = view;
    						break;
    					}
    				}
    			}
    			if (null == target) {
    				// 如果不存在对应的target直接返回
    				return;
    			}
    		}
    		
    		switch (msg.what) {
    		case MESSAGE_COMPLETE:
    			// 可以删除为空的判断，因为如果result为null不会来到这个分支，而是MESSAGE_FAILED
    			if (target instanceof ImageView) {
    				WeakHashMap<ImageView, LoadContext<?, ImageView, ?>> callbackMap = queueMap.remove(context.getParam().toString());	
    				
    				if(callbackMap == null || !callbackMap.containsKey(target)){
    					callback(context, (BitmapDrawable)context.getResult(), MESSAGE_COMPLETE);
    				} 
    				if(callbackMap != null){
    					Set<ImageView> set = callbackMap.keySet();
    					for(ImageView view: set){
    						LoadContext<?, ImageView, ?> imageContext = callbackMap.get(view);
    						callback(imageContext, (BitmapDrawable)context.getResult(), MESSAGE_COMPLETE);
    					}
    				}
    				
    				// 统计图片下载成功
//    				LogHandler.increaseSuccessCount();
    			} else if (target instanceof LoadListener) {
    				((LoadListener) target).loadComplete(context);
    			} 
    			break;
    		case MESSAGE_FAILED:
    			
    			if (context.getTryTimes() == 0) {
    				//重试一次
//    				Log.w("Sdebug", "LoaderExecutor: try task again: " + context.getParam().toString());
    				context.increaseTryTimes();
    				LoaderExecutor.this.execute(context, EXECUTE_ORDER.FIFO_ORDER);
    			} else {
    			    Log.w("Sdebug", "LoaderExecutor: Loading task failed after once retry, url is: " + context.getParam().toString());
    				if (target instanceof LoadListener) {
        				((LoadListener) target).loadFail(context);
        			} else if (target instanceof ImageView) {
        				WeakHashMap<ImageView, LoadContext<?, ImageView, ?>> callbackMap = queueMap.remove(context.getParam().toString());	
    					if(callbackMap == null || !callbackMap.containsKey(target)){
    						callback(context, (BitmapDrawable)context.getResult(), MESSAGE_FAILED);
    					}
    					if(callbackMap != null){
    						Set<ImageView> set = callbackMap.keySet();
    						for(ImageView view: set){
    							LoadContext<?, ImageView, ?> imageContext = callbackMap.get(view);
    							callback(imageContext,(BitmapDrawable)context.getResult(), MESSAGE_FAILED);
    						}
    					}
        				// 统计图片下载失败
//        				LogHandler.increaseFailedCount();
        			}
    			}
    			break;
    		default:
    			break;
    		}
    	}

		private boolean isInvalidTarget(Object target) {
//			if (target == null) return true;
			return target instanceof Fragment ? (((Fragment) target).getActivity()) == null : false;
		}
    };
    
	/**
	 * Constructor
	 */
	public LoaderExecutor() {
		queueMap = new HashMap<String, WeakHashMap<ImageView, LoadContext<?, ImageView, ?>>>();
	}
	
	public LoaderExecutor(String loaderName ) {
	    this();
	    this.loaderName = loaderName;
	}
    
	/**
	 * Execute a task assigned by {@link LoadContext} asynchronously some time in the future 
	 * @param context Context to identify a load task
	 * @param order Execute order, please refer to {@link EXECUTE_ORDER}
	 */
	@SuppressWarnings("unchecked")
	public <Param, Target, Result> void execute(final LoadContext<Param, Target, Result> context, EXECUTE_ORDER order) {
		if (TextUtils.isEmpty(context.getParam().toString())) {
//			Log.e("Sdebug", "In LoaderExecutor, target url is empty.");
//			LogHandler.addLogRecord("LoaderExecutor"
//			        , "context.getParam() is empty"
//			        , "In LoaderExecutor, target url is empty.");
			return;
		}
		
		// here we are in the ui thread
		if(context.getTarget() instanceof ImageView){
			addQueue(context.getParam().toString(), (LoadContext<?, ImageView, ?>) context);
			if(queueMap.get(context.getParam().toString())!=null&&context.getTryTimes()==0){
				return;
			}
		}
		
//			Log.w("Sdebug", "In LoaderExecutor, duplicate task for :" + context.getParam());
//			LogHandler.addLogRecord("Warning", 
//			        LoaderExecutor.class.getSimpleName(), 
//			        "In LoaderExecutor, duplicate task occurs", "URL is " + LogHandler.processURL(context.getParam().toString()));
            
		FutureTask<Result> futureTask = new MyFutureTask<Result>(LoadCallable.newInstance(context)) {
			@Override
			protected void done() {
				super.done();
				Message message = Message.obtain();
				message.obj = context;
				try {
					// 如果xxCallable.call()中抛出异常，则get()会得到并抛出这些异常
					Result result = get(); 
					context.setResult(result);
					if (result != null) {
						message.what = MESSAGE_COMPLETE;
					} else {
						message.what = MESSAGE_FAILED;
//						LogHandler.addLogRecord("LoaderExecutor"
//						        , "Result is null, url: " + LogHandler.processURL(context.getParam().toString()));
					}
				} catch (InterruptedException e) {
					// 下载线程被打断
					// 如果异常说明loading失败，设置相应结果，
					message.what = MESSAGE_FAILED;
					context.setResult(null);
					String exceptionStr = e.getLocalizedMessage();
					Log.e(getClass().getName(), null == exceptionStr?"LoaderExecutor -- InterruptedException":exceptionStr);
//					LogHandler.addLogRecord("LoaderExecutor"
//					        , "InterruptedException occurs, url: " + LogHandler.processURL(context.getParam().toString())
//                            , "" + e.getMessage());
						
				} catch (ExecutionException e) {
					// 如果异常说明loading失败，设置相应结果，
					message.what = MESSAGE_FAILED;
					context.setResult(null);
					// 可能是IOException 或 ParseException
					String exceptionMsg = null;
					if (e.getCause() instanceof IOException) {
						File file = ImageLoader.getResourceCacheManager().getCacheFile(context.getParam().toString(), true);
						if(file!=null){
							file.delete();
						}
						// 网络I/O错误，需要记录log
						exceptionMsg = "LoaderExecutor IOException occurs, url:" + context.getParam().toString();
//						LogHandler.addLogRecord("LoaderExecutor"
//						        , "IOException occurs, url: " + LogHandler.processURL(context.getParam().toString())
//						        , "" + e.getCause().getMessage());
						Log.w("Sdebug", exceptionMsg, e);
					} else if (e.getCause() instanceof ParseException) {
						// JSON 解析错误，需要记录log
						exceptionMsg = "LoaderExecutor ParseException occurs, url:" + context.getParam();
//						LogHandler.addLogRecord("LoaderExecutor"
//						        , "ParseException occurs, url: " + LogHandler.processURL(context.getParam().toString())
//                                , "" + e.getCause().getMessage());
						Log.w("Sdebug", exceptionMsg, e);
					} else {
						exceptionMsg = "LoaderExecutor ExecutionException occurs, url:" + context.getParam();
						Log.w("Sdebug", exceptionMsg, e);
//					    LogHandler.addLogRecord("LoaderExecutor"
//					            , "Exception occurs, url: " + LogHandler.processURL(context.getParam().toString())
//                                , "" + e.getCause().getMessage());
					}
				} finally {
					sHandler.sendMessage(message);
					
				}
			}
		};
		
		switch (order) {
		case FIFO_ORDER:
			FIFO_SERIAL_EXECUTOR.execute(futureTask);
			break;
		case FILO_ORDER:
		default:
			SERIAL_EXECUTOR.execute(futureTask);
			break;
		}
	}
	
	private void addQueue(String url, LoadContext<?, ImageView, ?> context){
		
		WeakHashMap<ImageView, LoadContext<?, ImageView, ?>> callbackMap = queueMap.get(url);
		
		if(callbackMap == null){
			if(queueMap.containsKey(url)){
				callbackMap = new WeakHashMap<ImageView, LoadContext<?, ImageView, ?>>();
				callbackMap.put((ImageView)context.getTarget(), context);
				queueMap.put(url, callbackMap);
			}else{
				queueMap.put(url, null);
			}
		}else{
			callbackMap.put((ImageView)context.getTarget(), context);
			
		}
		
	}
	
	private void callback(LoadContext<?, ImageView, ?> context, BitmapDrawable drawable, int state){
		ImageView target = (ImageView) context.getTarget();
		if (null == target 
				|| (target instanceof RecyclingImageView && ((RecyclingImageView)target).attached == false)) {
			return;
		}
		
		Pack pack = (Pack) target.getTag();
		// 在ImageLoader中都会为ImageView设置Pack，所以pack不会为空
		if (context.getParam().toString().equals(pack.getParam())) {
			// 只有当ImageView tag中的url与context中一样时才设置图片，避免
			// 因ImageView在ListView中的复用而造成的图片闪
			switch (state) {
			case MESSAGE_COMPLETE:
				if (LoadContext.TYPE_HTTP == context.getType()) {
					pack.getDisplayer().display(target, drawable, context.getAppContext());
				} else {
					pack.getDisplayer().display(target, drawable);
				}
				break;
			case MESSAGE_FAILED:
				pack.getDisplayer().fail(target);
				break;
			}
		}
	}
}