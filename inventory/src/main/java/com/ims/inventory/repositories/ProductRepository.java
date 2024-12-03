package com.ims.inventory.repositories;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.ims.inventory.entities.Product;

@Repository
public interface ProductRepository extends JpaRepository<Product, Long> {

}
