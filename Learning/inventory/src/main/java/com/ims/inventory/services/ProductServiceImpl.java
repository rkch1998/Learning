package com.ims.inventory.services;

import java.util.List;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;

import com.ims.inventory.dtos.ProductDto;
import com.ims.inventory.entities.Product;
import com.ims.inventory.mappers.ProductMapper;
import com.ims.inventory.repositories.InventoryRepository;
import com.ims.inventory.repositories.ProductRepository;

@Service
public class ProductServiceImpl implements ProductService{

    private final ProductRepository productRepository;
    private final InventoryRepository inventoryRepository;
    private final ProductMapper productMapper;

    public ProductServiceImpl(ProductRepository productRepository, InventoryRepository inventoryRepository, ProductMapper productMapper){
        this.productRepository = productRepository;
        this.inventoryRepository = inventoryRepository;
        this.productMapper = productMapper;
    }

    @Override
    public ProductDto createProduct(ProductDto productDto) {
        if(productDto == null){
            return null;
        }
        if (productDto.getId() != null && productRepository.existsById(productDto.getId())) {
            throw new IllegalArgumentException("Cannot manually insert an ID that already exists.");
        }
        // System.out.println("InventoryId : " + productDto.getInventoryId());
        // System.out.println("ProductId : " + productDto.getId());
        if (!inventoryRepository.existsById(productDto.getInventoryId())) {
            throw new RuntimeException("Inventory not found with ID " + productDto.getInventoryId());
        }

        Product product = productMapper.toEntity(productDto);
        System.out.println(product.toString());
        Product savedProduct = productRepository.save(product);
        System.out.println(savedProduct.toString());
        return productMapper.toDto(savedProduct);
    }

    @Override
    public ProductDto getProductById(Long id) {
        Product product = productRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Product not found by ID " + id));

        // Validate the existence of the inventory
        if (!inventoryRepository.existsById(product.getInventoryId())) {
            throw new RuntimeException("Inventory not found for the associated product ID " + id);
        }

        return productMapper.toDto(product);
    }

    // @Override
    // public List<ProductDto> getAllProducts() {
    //     Long loggedInUserId = SecurityUtils.getLoggedInUserId(userService);
    //     List<Long> userInventoryIds = inventoryRepository.findByUserId(loggedInUserId)
    //             .stream()
    //             .map(Inventory::getId)
    //             .collect(Collectors.toList());

    //     // Fetch products for the user's inventories
    //     List<ProductDto> productList = productRepository.findAllByInventoryIdIn(userInventoryIds)
    //             .stream()
    //             .map(productMapper::toDto)
    //             .collect(Collectors.toList());

    //     return productList;
    // }

    @Override
    public List<ProductDto> getAllProducts() {
        
        // Fetch products for the user's inventories
        List<ProductDto> productList = productRepository.findAll()
                .stream()
                .map(productMapper::toDto)
                .collect(Collectors.toList());

        return productList;
    }

    @Override
    public ProductDto updateProduct(Long id, ProductDto productDto) {
        Product existingProduct = productRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Product not found with ID " + id));

        // Validate if the inventory exists
        if (!inventoryRepository.existsById(productDto.getInventoryId())) {
            throw new RuntimeException("Inventory not found with ID " + productDto.getInventoryId());
        }

        existingProduct.setProductName(productDto.getProductName());
        existingProduct.setDescription(productDto.getDescription());
        existingProduct.setPrice(productDto.getPrice());
        existingProduct.setQuantity(productDto.getQuantity());
        existingProduct.setInventoryId(productDto.getInventoryId());

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
