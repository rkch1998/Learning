package com.ims.inventory;

// import static org.junit.jupiter.api.Assertions.assertEquals;
// import static org.junit.jupiter.api.Assertions.assertNotNull;
// import static org.mockito.ArgumentMatchers.any;
// import static org.mockito.Mockito.mockStatic;
// import static org.mockito.Mockito.times;
// import static org.mockito.Mockito.verify;
// import static org.mockito.Mockito.when;

// // import java.util.ArrayList;
// // import java.util.List;
// import java.util.Optional;

// import org.junit.jupiter.api.BeforeEach;
// import org.junit.jupiter.api.Test;
// // import org.junit.jupiter.api.extension.ExtendWith;
// import org.mockito.InjectMocks;
// import org.mockito.Mock;
// import org.mockito.MockitoAnnotations;
// // import org.powermock.core.classloader.annotations.PrepareForTest;
// // import org.powermock.modules.junit5.PowerMockExtension;

// import com.ims.inventory.dtos.InventoryDto;
// import com.ims.inventory.entities.Inventory;
// import com.ims.inventory.mappers.InventoryMapper;
// import com.ims.inventory.repositories.InventoryRepository;
// import com.ims.inventory.repositories.ProductRepository;
// import com.ims.inventory.services.InventoryServiceImpl;
// import com.ims.inventory.services.UserServiceImpl;
// import com.ims.inventory.utils.SecurityUtils;

// import utility.TestInventoryDataFactory;

// @ExtendWith(PowerMockExtension.class)
// @PrepareForTest(SecurityUtils.class)
public class InventoryServiceImplTest {
    // @Mock
    // public InventoryRepository inventoryRepository;

    // @Mock
    // public ProductRepository productRepository;

    // @Mock
    // public InventoryMapper inventoryMapper;
    
    // @InjectMocks
    // public InventoryServiceImpl inventoryService;

    // @InjectMocks
    // public UserServiceImpl userService;

    // @BeforeEach
    // public void setUp(){
    //     MockitoAnnotations.openMocks(this);
    // }

    // @Test
    // void testCreateInventory(){
    //     //Arrange
    //     // Product product = new Product(1L, "Product 1", 100.0, "Description 1");
    //     InventoryDto inventoryDto = TestInventoryDataFactory.createInventoryDto();
    //     Inventory inventory = TestInventoryDataFactory.createInventory();

    //     when(inventoryMapper.toEntity(inventoryDto)).thenReturn(inventory);
    //     when(inventoryRepository.save(any(Inventory.class))).thenReturn(inventory);
    //     when(inventoryMapper.toDto(inventory)).thenReturn(inventoryDto);

    //     //Act
    //     InventoryDto result = inventoryService.creatInventory(inventoryDto);
    //     //Assert
    //     assertNotNull(result);
    //     assertEquals("Warehouse A", result.getLocation());
    //     verify(inventoryRepository, times(1)).save(any(Inventory.class));
    // }

    // // @Test
    // // void testAllGetInventory(){
    // //     //Arrange
    // //     List<Inventory> mockInventoryList = new ArrayList<>(TestInventoryDataFactory.createListOfInventory());
    // //     // List<InventoryDto> mockInventoryDtos = new ArrayList<>(TestInventoryDataFactory.createListOfInventoryDto());

    // //     when(inventoryRepository.findAll()).thenReturn(mockInventoryList);
    // //     when(inventoryMapper.toDto(any(Inventory.class))).thenAnswer(inv -> {
    // //         Inventory inventory = inv.getArgument(0);
    // //         return new InventoryDto(
    // //             inventory.getId(),
    // //             inventory.getUser().getId(),
    // //             inventory.getInventoryname(),
    // //             inventory.getLocation()
    // //         );
    // //     });
        
    // //     //Act
    // //     List<InventoryDto> result = inventoryService.getAllInventoryForUser();

    // //     //Assert
    // //     assertNotNull(result);
    // //     assertEquals(2, result.size());
    // //     assertEquals("Warehouse A", result.get(0).getLocation());
    // //     assertEquals("Warehouse B", result.get(1).getLocation());

    // //     verify(inventoryRepository, times(1)).findAll();
    // //     verify(inventoryMapper, times(2)).toDto(any(Inventory.class));
    // // }

    // @Test
    // void testGetInventoryById(){
    //     //Arrange
    //     // Product product = new Product(1L, "Product 1", 100.0, "Description 1");
    //     InventoryDto inventoryDto = TestInventoryDataFactory.createInventoryDto();
    //     Inventory inventory = TestInventoryDataFactory.createInventory();
    //     when(inventoryRepository.findById(1L)).thenReturn(Optional.of(inventory));
    //     when(inventoryMapper.toDto(inventory)).thenReturn(inventoryDto);

    //     //Act
    //     InventoryDto inventoryDto2 = inventoryService.getInventoryById(1L);

    //     //Assert
    //     assertNotNull(inventoryDto2);
    //     assertEquals("Warehouse A", inventoryDto2.getLocation());
    // }    

    // @Test
    // void testDeleteInventory(){
    //     // Arrange
    //     Long userId = 1L;
    //     Long inventoryId = 1L;
    //     Inventory inventory = new Inventory();
    //     inventory.setId(inventoryId); 

    //     mockStatic(SecurityUtils.class);
    //     when(SecurityUtils.getLoggedInUserId(any(UserServiceImpl.class))).thenReturn(userId);
        
    //     when(inventoryRepository.findByIdAndUserid(inventoryId, userId)).thenReturn(Optional.of(inventory));
        
    //     // when(productRepository.deleteByInventoryid(inventoryId)).thenReturn();

    //     // Act

    //     inventoryService.deleteInventory(inventoryId);

    //     // Assert
    //     verify(productRepository, times(1)).deleteByInventoryid(inventoryId); // Verify that deleteByInventoryid is called once
    //     verify(inventoryRepository, times(1)).delete(inventory);
    // }

}
