package com.ims.inventory.services;

import java.util.List;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;

import com.ims.inventory.dtos.InventoryDto;
import com.ims.inventory.entities.Inventory;
import com.ims.inventory.mappers.InventoryMapper;
import com.ims.inventory.repositories.InventoryRepository;

@Service
public class InventoryServiceImpl implements InventoryService {

    private final InventoryRepository inventoryRepository;
    private final InventoryMapper inventoryMapper;

    public InventoryServiceImpl(InventoryRepository inventoryRepository, InventoryMapper inventoryMapper){
        this.inventoryRepository = inventoryRepository;
        this.inventoryMapper = inventoryMapper;
    }

    @Override
    public InventoryDto creatInventory(InventoryDto inventoryDto) {
        Inventory inventory = inventoryMapper.toEntity(inventoryDto);
        Inventory saveInventory = inventoryRepository.save(inventory);
        return inventoryMapper.toDto(saveInventory);
    }
    
    @Override
    public List<InventoryDto> getAllInventory() {
        List<InventoryDto> inventoryList = inventoryRepository.findAll().stream()
                                .map(inventoryMapper::toDto)
                                .collect(Collectors.toList());
        return inventoryList;
    }

    @Override
    public InventoryDto getInventoryById(Long id) {
        Inventory inventory = inventoryRepository.findById(id)
                                .orElseThrow(() -> new RuntimeException("Inventory not found with ID " + id));
        return inventoryMapper.toDto(inventory);                        
    }        

    @Override
    public InventoryDto updateInventory(Long id, InventoryDto inventoryDto) {
        Inventory existingInventory = inventoryRepository.findById(id)
                        .orElseThrow(() -> new RuntimeException("Inventory does not exist by ID " + id));
        existingInventory.setProduct(inventoryMapper.toEntity(inventoryDto).getProduct());
        existingInventory.setStockQuantity(inventoryDto.getStockQuantity());
        existingInventory.setLocation(inventoryDto.getLocation());

        Inventory updatedInventory = inventoryRepository.save(existingInventory);
        return inventoryMapper.toDto(updatedInventory);
    }

    @Override
    public void deleteInventory(Long id) {
        if(!inventoryRepository.existsById(id)){
            throw new RuntimeException("Inventory not found with ID " + id);
        }
        inventoryRepository.deleteById(id);
    }

}
