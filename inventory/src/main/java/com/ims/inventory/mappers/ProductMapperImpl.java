package com.ims.inventory.mappers;

import org.springframework.stereotype.Component;

import com.ims.inventory.dtos.ProductDto;
import com.ims.inventory.entities.Product;

@Component
public class ProductMapperImpl implements ProductMapper{

    @Override
    public ProductDto toDto(Product product) {
        if(product == null){
            return null;
        }

        ProductDto productDto = new ProductDto();
        productDto.setId(product.getId());
        productDto.setName(product.getProductName());
        productDto.setPrice(product.getPrice());
        productDto.setDescription(product.getDescription());
        return productDto;
    }

    @Override
    public Product toEntity(ProductDto productDto) {
        if(productDto == null){
            return null;
        }

        Product product = new Product();
        product.setId(productDto.getId());
        product.setProductName(productDto.getName());
        product.setPrice(productDto.getPrice());
        product.setDescription(productDto.getDescription());
        return product;
    }

}
