package com.ims.inventory.services;

import java.util.List;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.ims.inventory.dtos.InventoryDto;
import com.ims.inventory.entities.Inventory;
import com.ims.inventory.mappers.InventoryMapper;
import com.ims.inventory.repositories.InventoryRepository;

@Service
public class InventoryServiceImpl implements InventoryService {

    @Autowired
    public InventoryRepository inventoryRepository;
    @Autowired
    public InventoryMapper inventoryMapper;

    // public InventoryServiceImpl(InventoryRepository inventoryRepository, InventoryMapper inventoryMapper){
    //     this.inventoryRepository = inventoryRepository;
    //     this.inventoryMapper = inventoryMapper;
    // }

    @Override
    public InventoryDto creatInventory(InventoryDto inventoryDto) {
        if(inventoryDto == null){
            return null;
        }
        if (inventoryDto.getId() != null && inventoryRepository.existsById(inventoryDto.getId())) {
            throw new IllegalArgumentException("Cannot manually insert an ID that already exists.");
        }

        if (!inventoryRepository.existsById(inventoryDto.getUserId())) {
            throw new RuntimeException("Inventory not found with ID " + inventoryDto.getUserId());
        }

        Inventory inventory = inventoryMapper.toEntity(inventoryDto);
        Inventory saveInventory = inventoryRepository.save(inventory);
        return inventoryMapper.toDto(saveInventory);
    }
    
    // @Override
    // public List<InventoryDto> getAllInventoryForUser(Long userId) {
    //     List<InventoryDto> inventoryList = inventoryRepository.findByUserId(userId).stream()
    //                             .map(inventoryMapper::toDto)
    //                             .collect(Collectors.toList());
    //     return inventoryList;
    // }

    @Override
    public List<InventoryDto> getAllInventory() {
        List<InventoryDto> inventoryList = inventoryRepository.findAll().stream()
                                .map(inventoryMapper::toDto)
                                .collect(Collectors.toList());
        return inventoryList;
    }

    // @Override
    // public InventoryDto getInventoryById(Long id) {
    //     Long loggedInUserId = SecurityUtils.getLoggedInUserId(userService);
    //     Inventory inventory = inventoryRepository.findByIdAndUserId(id, loggedInUserId)
    //                             .orElseThrow(() -> new RuntimeException("Inventory not found with ID " + id + " for the logged-in user"));
    //     return inventoryMapper.toDto(inventory);                        
    // }      
    
    @Override
    public InventoryDto getInventoryById(Long id) {
        System.out.println( " Inventory : ");

        Inventory inventory = inventoryRepository.findById(id)
                                .orElseThrow(() -> new RuntimeException("Inventory not found with ID " + id + " for the logged-in user"));
        System.out.println( " Inventory : " + inventory.toString());
        System.out.println( " Inventory : " + inventoryMapper.toDto(inventory).toString());

        return inventoryMapper.toDto(inventory);                        
    } 

    // @Override
    // public InventoryDto updateInventory(Long id, InventoryDto inventoryDto) {
    //     Long loggedInUserId = SecurityUtils.getLoggedInUserId(userService);
    //     Inventory existingInventory = inventoryRepository.findByIdAndUserId(id, loggedInUserId)
    //                         .orElseThrow(() -> new RuntimeException("Inventory does not exist for the logged-in user by ID " + id));

    //     existingInventory.setInventoryName(inventoryDto.getInventoryName());
    //     existingInventory.setLocation(inventoryDto.getLocation());

    //     Inventory updatedInventory = inventoryRepository.save(existingInventory);
    //     return inventoryMapper.toDto(updatedInventory);
    // }

    // @Override
    // public void deleteInventory(Long id) {
    //     Long loggedInUserId = SecurityUtils.getLoggedInUserId(userService);
    //     Inventory inventory = inventoryRepository.findByIdAndUserId(id, loggedInUserId)
    //         .orElseThrow(() -> new RuntimeException("Inventory not found for the logged-in user with ID " + id));

    //     productRepository.deleteByInventoryId(id);
    //     inventoryRepository.delete(inventory);
    // }

    @Override
    public InventoryDto updateInventory(Long id, InventoryDto inventoryDto) {
        Inventory existingInventory = inventoryRepository.findById(id)
                            .orElseThrow(() -> new RuntimeException("Inventory does not exist for the logged-in user by ID " + id));

        existingInventory.setInventoryName(inventoryDto.getInventoryName());
        existingInventory.setLocation(inventoryDto.getLocation());

        Inventory updatedInventory = inventoryRepository.save(existingInventory);
        return inventoryMapper.toDto(updatedInventory);
    }

    @Override
    public void deleteInventory(Long id) {
        Inventory inventory = inventoryRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Inventory not found for the logged-in user with ID " + id));

        inventoryRepository.delete(inventory);
    }

}
