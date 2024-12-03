package com.ims.inventory.services;

import java.util.List;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;

import com.ims.inventory.dtos.ProductDto;
import com.ims.inventory.entities.Product;
import com.ims.inventory.mappers.ProductMapper;
import com.ims.inventory.repositories.ProductRepository;

@Service
public class ProductServiceImpl implements ProductService{

    private final ProductRepository productRepository;
    private final ProductMapper productMapper;

    public ProductServiceImpl(ProductRepository productRepository, ProductMapper productMapper){
        this.productRepository = productRepository;
        this.productMapper = productMapper;
    }

    @Override
    public ProductDto createProduct(ProductDto productDto) {
        if(productDto == null){
            return null;
        }

        Product product = productMapper.toEntity(productDto);
        Product savedProduct = productRepository.save(product);
        return productMapper.toDto(savedProduct);
    }

    @Override
    public ProductDto getProductById(Long id) {
        Product product = productRepository.findById(id)
                                .orElseThrow(() -> new RuntimeException("Product not found by ID " + id));
        System.out.println(product.toString());
        return productMapper.toDto(product);
    }

    @Override
    public List<ProductDto> getAllProducts() {
        List<ProductDto> prodcuList = productRepository.findAll().stream()
                                        .map(productMapper::toDto)
                                        .collect(Collectors.toList());
        return prodcuList;
    }

    @Override
    public ProductDto updateProduct(Long id, ProductDto productDto) {
        Product existingProduct = productRepository.findById(id)
                            .orElseThrow(() -> new RuntimeException("Product not found with ID " + id));
        existingProduct.setProductName(productDto.getName());
        existingProduct.setDescription(productDto.getDescription());
        existingProduct.setPrice(productDto.getPrice()); 

        Product updatedProduct = productRepository.save(existingProduct);
        return productMapper.toDto(updatedProduct);
    }

    @Override
    public void deleteProduct(Long id) {
        if(!productRepository.existsById(id)){
            throw new RuntimeException("Product not found by ID " + id);
        }
        productRepository.deleteById(id);
    }

}
