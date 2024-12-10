package com.ims.inventory.mappers;

import com.ims.inventory.dtos.ProductDto;
import com.ims.inventory.entities.Product;

public interface ProductMapper {
    ProductDto toDto(Product product);
    Product toEntity(ProductDto productDto);
}
