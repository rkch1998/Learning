package com.ims.inventory.controllers;

import java.util.List;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.ims.inventory.dtos.ProductDto;
import com.ims.inventory.services.ProductService;

@RestController
@RequestMapping("/api/products")
public class ProductController {

    private final ProductService productService;

    public ProductController(ProductService productService){
        this.productService = productService;
    }

    @PostMapping
    public ResponseEntity<String> createProduct(@RequestBody ProductDto productDto){
        // System.out.println("Received Product DTO: " + productDto);
        if (productDto.getId() != null) {
            throw new IllegalArgumentException("ID should not be provided when creating a new product.");
        }
        productService.createProduct(productDto);
        return ResponseEntity.status(HttpStatus.CREATED).body("Product created successfuly!");
    }

    @GetMapping("/{id}")
    public ResponseEntity<ProductDto> getProductById(@PathVariable Long id){
        ProductDto product = (productService.getProductById(id));
        return ResponseEntity.ok(product);
    }

    @GetMapping
    public ResponseEntity<List<ProductDto>> getAllProduct(){
        List<ProductDto> products = productService.getAllProducts();
        return ResponseEntity.ok(products);
    }

    @PutMapping("/{id}")
    public ResponseEntity<ProductDto> updateProduct(@PathVariable Long id, @RequestBody ProductDto productDto){
        return ResponseEntity.ok(productService.updateProduct(id, productDto));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteProduct(@PathVariable Long id){
        System.out.println("Id : " + id);
        productService.deleteProduct(id);
        return ResponseEntity.noContent().build();
    }

}
