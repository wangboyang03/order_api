package cn.itcase.order_api.common.exception;

public class BaseException extends RuntimeException {
    private static final long serialVersionUID = 1L;
    
	public BaseException() {}
	
    public BaseException(String message) {
        super(message);
    }
}