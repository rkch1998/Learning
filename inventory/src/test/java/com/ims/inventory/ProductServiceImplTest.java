package com.ims.inventory;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.util.Optional;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;

import com.ims.inventory.dtos.ProductDto;
import com.ims.inventory.entities.Product;
import com.ims.inventory.mappers.ProductMapper;
import com.ims.inventory.repositories.ProductRepository;
import com.ims.inventory.services.ProductServiceImpl;

public class ProductServiceImplTest {

    @Mock
    private ProductRepository productRepository;
    
    @Mock
    private ProductMapper productMapper;

    @InjectMocks
    private ProductServiceImpl productServiceImpl;

    @BeforeEach
    void setUp(){
        MockitoAnnotations.openMocks(this);
    }

    @Test
    void testCreateProduct_ValidDto(){
        //Arrange
        ProductDto productDto = new ProductDto(1L, "Product 1", 100.0, "Description 1");
        Product productEntity = new Product(1L, "Product 1", 100.0, "Description 1");

        when(productMapper.toEntity(productDto)).thenReturn(productEntity);
        when(productRepository.save(productEntity)).thenReturn(productEntity);
        when(productMapper.toDto(productEntity)).thenReturn(productDto);

        //Act
        ProductDto result = productServiceImpl.createProduct(productDto);

        //Assert
        assertNotNull(result);
        assertEquals(productDto.getName(), result.getName());
        verify(productRepository, times(1)).save(productEntity);
    }

    @Test
    void testCreateProduct_NullDto(){
        //Arrange
        ProductDto result = productServiceImpl.createProduct(null);
        //Act and Assert
        assertNull(result);
        verify(productRepository, never()).save(any());
    }

    @Test
    void testCreateProduct() {
        // Arrange
        ProductDto productDto = new ProductDto(null, "Test Product", 99.99, null);
        Product product = new Product(null, "Test Product", 99.99, null);
        when(productMapper.toEntity(productDto)).thenReturn(product);
        when(productRepository.save(any(Product.class))).thenReturn(product);

        // Act
        productServiceImpl.createProduct(productDto);

        // Assert
        verify(productRepository, times(1)).save(any(Product.class));
    }

    @Test
    void testGetProductById() {
        // Arrange
        ProductDto productDto = new ProductDto(1L, "Test Product", 99.99, null);
        Product product = new Product(1L, "Test Product", 99.99, null);
        when(productRepository.findById(1L)).thenReturn(Optional.of(product));
        when(productMapper.toDto(product)).thenReturn(productDto);

        // Act
        ProductDto result = productServiceImpl.getProductById(1L);

        // Assert
        assertNotNull(result);
        assertEquals("Test Product", result.getName());
        verify(productRepository, times(1)).findById(1L);
    }

    @Test
    void testDeleteProduct() {
        //Arrange
        when(productRepository.existsById(1L)).thenReturn(true);
        // Act
        productServiceImpl.deleteProduct(1L);

        // Assert
        verify(productRepository, times(1)).deleteById(1L);
    }
}
