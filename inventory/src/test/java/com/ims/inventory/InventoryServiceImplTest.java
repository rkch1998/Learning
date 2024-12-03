package com.ims.inventory;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;

import com.ims.inventory.dtos.InventoryDto;
import com.ims.inventory.entities.Inventory;
import com.ims.inventory.entities.Product;
import com.ims.inventory.mappers.InventoryMapper;
import com.ims.inventory.repositories.InventoryRepository;
import com.ims.inventory.services.InventoryServiceImpl;

public class InventoryServiceImplTest {
    @Mock
    public InventoryRepository inventoryRepository;

    @Mock
    public InventoryMapper inventoryMapper;
    
    @InjectMocks
    public InventoryServiceImpl inventoryService;

    @BeforeEach
    public void setUp(){
        MockitoAnnotations.openMocks(this);
    }

    @Test
    void testCreateInventory(){
        //Arrange
        Product product = new Product(1L, "Product 1", 100.0, "Description 1");
        InventoryDto inventoryDto = new InventoryDto(1L, product.getId(), 21, "Warehouse 1");
        Inventory inventory = new Inventory(1L, product, 21, "Warehouse 1");

        when(inventoryMapper.toEntity(inventoryDto)).thenReturn(inventory);
        when(inventoryRepository.save(any(Inventory.class))).thenReturn(inventory);
        when(inventoryMapper.toDto(inventory)).thenReturn(inventoryDto);

        //Act
        InventoryDto result = inventoryService.creatInventory(inventoryDto);
        //Assert
        assertNotNull(result);
        assertEquals("Warehouse 1", result.getLocation());
        assertEquals(21, result.getStockQuantity());
        verify(inventoryRepository, times(1)).save(any(Inventory.class));
    }

    @Test
    void testAllGetInventory(){
        //Arrange
        List<Inventory> mockInventoryList = new ArrayList<>();
        mockInventoryList.add(new Inventory(1L, new Product(1L, "Product 1", 100.0, "Description 1"), 10, "Warehouse A"));
        mockInventoryList.add(new Inventory(2L, new Product(2L, "Product 2", 200.0, "Description 2"), 20, "Warehouse B"));

        List<InventoryDto> mockInventoryDtos = new ArrayList<>();
        mockInventoryDtos.add(new InventoryDto(1L, 1L, 10, "Warehouse A"));
        mockInventoryDtos.add(new InventoryDto(2L, 2L, 20, "Warehouse B"));

        when(inventoryRepository.findAll()).thenReturn(mockInventoryList);
        when(inventoryMapper.toDto(any(Inventory.class))).thenAnswer(inv -> {
            Inventory inventory = inv.getArgument(0);
            return new InventoryDto(
                inventory.getId(),
                inventory.getProduct().getId(),
                inventory.getStockQuantity(),
                inventory.getLocation()
            );
        });
        
        //Act
        List<InventoryDto> result = inventoryService.getAllInventory();

        //Assert
        assertNotNull(result);
        assertEquals(2, result.size());
        assertEquals("Warehouse A", result.get(0).getLocation());
        assertEquals("Warehouse B", result.get(1).getLocation());

        verify(inventoryRepository, times(1)).findAll();
        verify(inventoryMapper, times(2)).toDto(any(Inventory.class));
    }

    @Test
    void testGetInventoryById(){
        //Arrange
        Product product = new Product(1L, "Product 1", 100.0, "Description 1");
        InventoryDto inventoryDto = new InventoryDto(1L, product.getId(), 21, "Warehouse 1");
        Inventory inventory = new Inventory(1L, product, 21, "Warehouse 1");
        when(inventoryRepository.findById(1L)).thenReturn(Optional.of(inventory));
        when(inventoryMapper.toDto(inventory)).thenReturn(inventoryDto);

        //Act
        InventoryDto inventoryDto2 = inventoryService.getInventoryById(1L);

        //Assert
        assertNotNull(inventoryDto2);
        assertEquals("Warehouse 1", inventoryDto2.getLocation());
        assertEquals(21, inventoryDto2.getStockQuantity());
    }    

    @Test
    void testDeleteInventory(){
        //Arrange
        when(inventoryRepository.existsById(1L)).thenReturn(true);
        //Act
        inventoryService.deleteInventory(1L);
        //Assert
        verify(inventoryRepository, times(1)).deleteById(1L);

    }

}
