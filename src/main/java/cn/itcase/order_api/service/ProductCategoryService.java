package cn.itcase.order_api.service;

import java.util.List;

import cn.itcase.order_api.dto.CategoryDTO;
import cn.itcase.order_api.entity.ProductCategory;

public interface ProductCategoryService {
    List<ProductCategory> list(Long coupleId);
    Long create(CategoryDTO dto, Long coupleId, Long userId);
}