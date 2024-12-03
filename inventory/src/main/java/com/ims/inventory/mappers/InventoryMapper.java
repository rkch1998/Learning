package com.ims.inventory.mappers;

import com.ims.inventory.dtos.InventoryDto;
import com.ims.inventory.entities.Inventory;

public interface InventoryMapper {
    InventoryDto toDto(Inventory inventory);
    Inventory toEntity(InventoryDto inventoryDto);
}
