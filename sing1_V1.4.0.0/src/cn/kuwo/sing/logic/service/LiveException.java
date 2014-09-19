package cn.kuwo.sing.logic.service;

public class LiveException extends Exception {
	private static final long serialVersionUID = -2482333750302621254L;

	public String cmd;
	public String state;
	public String detail;
	
	public LiveException(String cmd, String state) {
		super(String.format("cmd:%s  state:%s", cmd, state));
	}
}
