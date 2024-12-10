package com.ims.inventory.mappers;

import org.springframework.stereotype.Component;

import com.ims.inventory.dtos.ProductDto;
import com.ims.inventory.entities.Product;

@Component
public class ProductMapperImpl implements ProductMapper{

    @Override
    public ProductDto toDto(Product product) {
        System.out.println("Mapping Product to ProductDto: " + product);
        if(product == null){
            return null;
        }

        ProductDto productDto = new ProductDto();
        productDto.setId(product.getId());
        productDto.setInventoryId(product.getInventoryId());
        productDto.setProductName(product.getProductName());
        productDto.setQuantity(product.getQuantity());
        productDto.setPrice(product.getPrice());
        productDto.setDescription(product.getDescription());
        return productDto;
    }

    @Override
    public Product toEntity(ProductDto productDto) {
        System.out.println("Mapping Product to Product: " + productDto);
        if(productDto == null){
            return null;
        }

        Product product = new Product();
        product.setId(productDto.getId());
        product.setInventoryId(productDto.getInventoryId());
        product.setProductName(productDto.getProductName());
        product.setQuantity(productDto.getQuantity());
        product.setPrice(productDto.getPrice());
        product.setDescription(productDto.getDescription());
        return product;
    }

}
