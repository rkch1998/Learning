package utility;

import java.util.ArrayList;
import java.util.List;

import com.ims.inventory.dtos.ProductDto;
import com.ims.inventory.entities.Product;

public class TestProductDataFactory {
public static ProductDto createProductDto() {
        return new ProductDto(1L, 1L, "Product 1", 10, 100.0, "Description 1");
    }

    public static Product createProduct() {
        // Inventory inventory = new Inventory(1L, 1L, "Ravi's", "Warehouse A", null);
        return new Product(1L, 1L, "Product 1", 10, 100.0, "Description 1");
    }

    public static List<ProductDto> createListOfProductDto() {
        List<ProductDto> mockProductDtos = new ArrayList<>();
        mockProductDtos.add(new ProductDto(1L, 1L, "Product 1", 10, 100.0, "Description 1"));
        mockProductDtos.add(new ProductDto(2L, 1L, "Product 2", 12, 108.0, "Description 2"));
        return mockProductDtos;
    }

    public static List<Product> createListOfProduct() {
        // Inventory inventory = new Inventory(1L, 1L, "Ravi's", "Warehouse A", null);
        List<Product> mockProductList = new ArrayList<>();
        mockProductList.add(new Product(1L, 1L, "Product 1", 10, 100.0, "Description 1"));
        mockProductList.add(new Product(2L, 1L, "Product 2", 20, 110.0, "Description 2"));
        return mockProductList;
    }
}
