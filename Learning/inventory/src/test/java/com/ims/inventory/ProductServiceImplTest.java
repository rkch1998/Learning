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
import com.ims.inventory.repositories.InventoryRepository;
import com.ims.inventory.repositories.ProductRepository;
import com.ims.inventory.services.ProductServiceImpl;

import utility.TestProductDataFactory;

public class ProductServiceImplTest {

    @Mock
    private ProductRepository productRepository;

    @Mock
    private InventoryRepository inventoryRepository;
    
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
        ProductDto productDto = TestProductDataFactory.createProductDto();
        Product product = TestProductDataFactory.createProduct();

        when(productMapper.toEntity(productDto)).thenReturn(product);
        when(productRepository.save(product)).thenReturn(product);
        when(inventoryRepository.existsById(product.getInventoryId())).thenReturn(true);
        when(productMapper.toDto(product)).thenReturn(productDto);

        //Act
        ProductDto result = productServiceImpl.createProduct(productDto);

        //Assert
        assertNotNull(result);
        assertEquals(productDto.getProductName(), result.getProductName());
        verify(productRepository, times(1)).save(product);
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
        ProductDto productDto = TestProductDataFactory.createProductDto();
        Product product = TestProductDataFactory.createProduct();
        when(productMapper.toEntity(productDto)).thenReturn(product);
        when(inventoryRepository.existsById(product.getInventoryId())).thenReturn(true);
        when(productRepository.save(any(Product.class))).thenReturn(product);

        // Act
        productServiceImpl.createProduct(productDto);

        // Assert
        verify(productRepository, times(1)).save(any(Product.class));
    }

    @Test
    void testGetProductById() {
        // Arrange
        ProductDto productDto = TestProductDataFactory.createProductDto();
        Product product = TestProductDataFactory.createProduct();
        when(productRepository.findById(1L)).thenReturn(Optional.of(product));
        when(inventoryRepository.existsById(product.getInventoryId())).thenReturn(true);
        when(productMapper.toDto(product)).thenReturn(productDto);

        // Act
        ProductDto result = productServiceImpl.getProductById(1L);

        // Assert
        assertNotNull(result);
        assertEquals("Product 1", result.getProductName());
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
