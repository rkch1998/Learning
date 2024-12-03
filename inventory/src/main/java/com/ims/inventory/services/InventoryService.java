package com.ims.inventory.services;

import java.util.List;

import com.ims.inventory.dtos.InventoryDto;

public interface InventoryService {
    InventoryDto getInventoryById(Long id);
    List<InventoryDto> getAllInventory();
    InventoryDto creatInventory(InventoryDto inventoryDto);
    InventoryDto updateInventory(Long id, InventoryDto inventoryDto);
    void deleteInventory(Long id);
}
