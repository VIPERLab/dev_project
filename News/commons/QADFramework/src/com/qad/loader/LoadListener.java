package com.qad.loader;

public interface LoadListener<Result> {
	
	public void postExecut(LoadContext<?, ?, Result> context);
	
	public void loadComplete(LoadContext<?, ?, Result> context);
	
	public void loadFail(LoadContext<?, ?, Result> context);
}
