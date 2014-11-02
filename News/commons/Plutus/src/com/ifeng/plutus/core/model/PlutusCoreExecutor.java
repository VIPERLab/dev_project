package com.ifeng.plutus.core.model;

import java.util.concurrent.Callable;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.FutureTask;

import com.ifeng.plutus.core.Constants.ERROR;
import com.ifeng.plutus.core.PlutusCoreListener;
import com.ifeng.plutus.core.model.callable.PlutusCoreCallable;

/**
 * Executor class for Plutus
 * @author gao_miao
 *
 */
class PlutusCoreExecutor {

	private static PlutusCoreExecutor mExecutor = null;
	private static ExecutorService sExecutorService = null;
	
	private class InnerFutureTask<Result> extends FutureTask<Result> {

		private PlutusCoreListener<Result> listener = null;
		
		public InnerFutureTask(Callable<Result> callable, PlutusCoreListener<Result> listener) {
			super(callable);
			this.listener = listener;
		}
		
		@Override
		protected void done() {
			super.done();
			try {
				Result r = get();
				if (listener != null) listener.onPostComplete(r);
			} catch (InterruptedException e) {
				if (listener != null) listener.onPostFailed(ERROR.ERROR_EXECUTION);
			} catch (ExecutionException e) {
				if (listener != null) listener.onPostFailed(ERROR.ERROR_EXECUTION);
			}
		}
	}
	
	private PlutusCoreExecutor() {
		sExecutorService = Executors.newCachedThreadPool();
	}
	
	/**
	 * Retrive a PlutusCoreExecutor object
	 * @return the instance of PlutusCoreExecutor 
	 */
	public static final PlutusCoreExecutor getInstance() {
		if (mExecutor == null)
			mExecutor = new PlutusCoreExecutor();
		return mExecutor;
	}
	
	/**
	 * Accept a PlutusCoreCallable and executes the task sometime in the future.
	 * @param callable
	 * &emsp;Callable which handles a specified request
	 * @param listener
	 * &emsp;The listener to notify on finish or exception
	 */
	public <Result> void execute(PlutusCoreCallable<Result> callable, PlutusCoreListener<Result> listener) {
		if (listener != null) listener.onPostStart();
		InnerFutureTask<Result> future = new InnerFutureTask<Result>(callable, listener);
		sExecutorService.execute(future);
	}
	
	/**
	 * shutdown the excutor and recycle corresponding resources
	 */
	public void shutDown() {
		sExecutorService.shutdown();
	}
	
}
