package cn.itcase.order_api.service;

import org.springframework.stereotype.Service;

@Service public class HealthService {
	public String check() {
		// 待实现的业务逻辑
        return "order_api is running";
    }
}