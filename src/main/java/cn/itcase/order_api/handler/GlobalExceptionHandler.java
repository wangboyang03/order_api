package cn.itcase.order_api.handler;


import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import cn.itcase.order_api.common.constant.MessageConstant;
import cn.itcase.order_api.common.exception.BaseException;
import cn.itcase.order_api.common.result.Result;

@RestControllerAdvice public class GlobalExceptionHandler {
    private static final Logger log = LoggerFactory.getLogger(GlobalExceptionHandler.class);

    @ExceptionHandler(BaseException.class) public Result<Void> handleBaseException(BaseException error) {
        log.warn("业务异常：{}", error.getMessage());
        return Result.error(error.getMessage());
    }

    @ExceptionHandler(DuplicateKeyException.class) public Result<Void> handleDuplicateKey(DuplicateKeyException error) {
        log.warn("唯一键冲突：{}", error.getMessage());
        return Result.error(MessageConstant.CATEGORY_NAME_DUPLICATE);
    }

    @ExceptionHandler(Exception.class) public Result<Void> handleException(Exception error) {
        log.error("系统异常", error);
        return Result.error(MessageConstant.UNKNOWN_ERROR);
    }
}