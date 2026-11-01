package cn.itcase.order_api.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import cn.itcase.order_api.service.HealthService;

// @RestController用于处理Web请求 @RequestMapping("...")定义接口路径 
@RestController @RequestMapping("/api/health") public class HealthController {
	private final HealthService healthService;
	
	public HealthController(HealthService healthService) {
        this.healthService = healthService;
    }
	
	// 通过GET请求访问
	@GetMapping public String check() {
        return healthService.check();
    }
}