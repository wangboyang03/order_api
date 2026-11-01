package cn.itcase.order_api.common.result;

import java.io.Serializable;

public class Result<T> implements Serializable {
	private static final long serialVersionUID = 1L;
	
	// 业务状态
	public static final Integer SUCCESS = 1;
	public static final Integer ERROR = 0;
	
	private Integer code;
	private String message;
	private T data;
	
	public Result() {}
	
	public Result(Integer code, String message, T data) {
        this.code = code;
        this.message = message;
        this.data = data;
    }
	
	public static <T> Result<T> success() {
        return new Result<>(SUCCESS, null, null);
    }

    public static <T> Result<T> success(T data) {
        return new Result<>(SUCCESS, null, data);
    }

    public static <T> Result<T> error(String message) {
        return new Result<>(ERROR, message, null);
    }

    public Integer getCode() { 
        return code; 
    }

    public void setCode(Integer code) { 
        this.code = code; 
    }

    public String getMessage() { 
        return message; 
    }

    public void setMessage(String message) { 
        this.message = message; 
    }

    public T getData() { 
        return data; 
    }

    public void setData(T data) { 
        this.data = data; 
    }
}