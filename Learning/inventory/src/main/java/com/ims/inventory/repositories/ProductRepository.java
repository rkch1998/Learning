package com.ims.inventory.repositories;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.ims.inventory.entities.Product;

@Repository
public interface ProductRepository extends JpaRepository<Product, Long> {
    Optional<Product> findAllByInventoryIdIn(List<Long> id);
    Optional<Product> findByInventoryId(Long id);
    void deleteByInventoryId(Long id);
}
