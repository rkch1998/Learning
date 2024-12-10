package utility;

import java.util.ArrayList;
import java.util.List;

import com.ims.inventory.dtos.InventoryDto;
import com.ims.inventory.entities.Inventory;

public class TestInventoryDataFactory {
    public static InventoryDto createInventoryDto() {
        return new InventoryDto(1L, 1L, "Ravi's", "Warehouse A");
    }

    public static Inventory createInventory() {
        return new Inventory(1L, 1L, "Ravi's", "Warehouse A");
    }

    public static List<InventoryDto> createListOfInventoryDto() {
        List<InventoryDto> mockInventoryDtos = new ArrayList<>();
        mockInventoryDtos.add( new InventoryDto(1L, 1L, "Ravi's", "Warehouse A"));
        mockInventoryDtos.add( new InventoryDto(2L, 2L, "R's", "Warehouse A"));
        return mockInventoryDtos;
    }

    public static List<Inventory> createListOfInventory() {
        List<Inventory> mockInventoryList = new ArrayList<>();
        mockInventoryList.add(new Inventory(1L, 1L, "Ravi's", "Warehouse A"));
        mockInventoryList.add(new Inventory(2L, 2L, "R's", "Warehouse A"));
        return mockInventoryList;
    }
}
