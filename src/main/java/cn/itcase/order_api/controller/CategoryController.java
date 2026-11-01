package cn.itcase.order_api.controller;

import java.util.List;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import cn.itcase.order_api.common.result.Result;
import cn.itcase.order_api.dto.CategoryDTO;
import cn.itcase.order_api.entity.ProductCategory;
import cn.itcase.order_api.service.ProductCategoryService;

@RestController @RequestMapping("/api/categories") public class CategoryController {
    private final ProductCategoryService categoryService;
    public CategoryController(ProductCategoryService categoryService) {
        this.categoryService = categoryService;
    }

    @GetMapping public Result<List<ProductCategory>> list(@RequestHeader("X-Couple-Id") Long coupleId) {
        return Result.success(categoryService.list(coupleId));
    }

    @PostMapping public Result<Long> create(@RequestHeader("X-Couple-Id") Long coupleId, @RequestHeader("X-User-Id") Long userId, @RequestBody CategoryDTO dto) {
        return Result.success(categoryService.create(dto, coupleId, userId));
    }
}