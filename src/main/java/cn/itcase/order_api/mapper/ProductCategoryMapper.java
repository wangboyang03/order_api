package cn.itcase.order_api.mapper;

import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Options;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import cn.itcase.order_api.entity.ProductCategory;

import java.util.List;

@Mapper public interface ProductCategoryMapper {
    @Select("select id, couple_id, name, description, sort, status, created_by_user_id, create_time, update_time " +
            "from product_category " +
            "where couple_id = #{coupleId} and status = 1 " +
            "order by sort asc, id asc")
    List<ProductCategory> listByCoupleId(@Param("coupleId") Long coupleId);

    @Select("select count(*) from product_category where couple_id = #{coupleId} and name = #{name}")
    int countByName(@Param("coupleId") Long coupleId, @Param("name") String name);

    @Insert("insert into product_category (couple_id, name, description, sort, status, created_by_user_id) " +
            "values (#{coupleId}, #{name}, #{description}, #{sort}, #{status}, #{createdByUserId})")
    @Options(useGeneratedKeys = true, keyProperty = "id")
    int insert(ProductCategory category);
}