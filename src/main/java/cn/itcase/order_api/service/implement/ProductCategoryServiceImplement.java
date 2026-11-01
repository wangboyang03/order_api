package cn.itcase.order_api.service.implement;

import java.util.List;

import org.springframework.stereotype.Service;

import cn.itcase.order_api.common.constant.MessageConstant;
import cn.itcase.order_api.common.constant.StatusConstant;
import cn.itcase.order_api.common.exception.CategoryNameDuplicateException;
import cn.itcase.order_api.dto.CategoryDTO;
import cn.itcase.order_api.entity.ProductCategory;
import cn.itcase.order_api.mapper.ProductCategoryMapper;
import cn.itcase.order_api.service.ProductCategoryService;

@Service public class ProductCategoryServiceImplement implements ProductCategoryService {
    private final ProductCategoryMapper categoryMapper;

    public ProductCategoryServiceImplement(ProductCategoryMapper categoryMapper) {
        this.categoryMapper = categoryMapper;
    }

    @Override public List<ProductCategory> list(Long coupleId) {
        return categoryMapper.listByCoupleId(coupleId);
    }

    @Override public Long create(CategoryDTO dto, Long coupleId, Long userId) {
        String name = dto.getName() == null ? "" : dto.getName().trim();
        if (name.isEmpty()) {
            throw new CategoryNameDuplicateException(MessageConstant.CATEGORY_NAME_EMPTY);
        }

        if (categoryMapper.countByName(coupleId, name) > 0) {
            throw new CategoryNameDuplicateException(MessageConstant.CATEGORY_NAME_DUPLICATE);
        }

        ProductCategory category = new ProductCategory();
        category.setCoupleId(coupleId);
        category.setName(name);
        category.setDescription(dto.getDescription());
        category.setSort(dto.getSort() == null ? 0 : dto.getSort());
        category.setStatus(StatusConstant.ENABLE);
        category.setCreatedByUserId(userId);

        categoryMapper.insert(category);
        return category.getId();
    }
}
