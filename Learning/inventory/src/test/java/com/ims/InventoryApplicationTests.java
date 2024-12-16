package com.ims;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.TestPropertySource;

import com.ims.inventory.InventoryApplication;

@SpringBootTest(classes = InventoryApplication.class)
@TestPropertySource(locations = "classpath:application-test.properties")
class InventoryApplicationTests {

	@Test
	void contextLoads() {
	}

}