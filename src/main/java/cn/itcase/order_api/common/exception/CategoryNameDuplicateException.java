package cn.itcase.order_api.common.exception;

public class CategoryNameDuplicateException extends BaseException {
    private static final long serialVersionUID = 1L;

	public CategoryNameDuplicateException(String message) {
        super(message);
    }
}