async function loadProducts() {
    try {
        const response = await fetch('/api/products');
        if (!response.ok) throw new Error('Failed to fetch products.');
        console.log(response);
        const products = await response.json();
        
        const tableBody = document.getElementById('products-table-body');
        if (!tableBody) {
            console.error('Table body element not found!');
            return;
        }

        // Clear existing table rows
        tableBody.innerHTML = '';

        // Create rows dynamically
        let tableRows = '';
        products.forEach(product => {
            tableRows += `<tr>
                <td>${product.id}</td>
                <td>${product.inventoryId}</td>
                <td>${product.productName}</td>
                <td>${product.quantity}</td>
                <td>${product.price}</td>
                <td>${product.description}</td>
                <td class="action-buttons">
                    <button class="icon-btn" onclick="openEditModal(${product.id}, ${product.inventoryId}, '${product.productName}', ${product.quantity}, ${product.price}, '${product.description}')">
                        <i class="fas fa-edit"></i>
                    </button>
                    <button class="icon-btn delete-btn" onclick="deleteProduct(${product.id})">
                        <i class="fas fa-trash-alt"></i>
                    </button>
                </td>
            </tr>`;
        });

        tableBody.innerHTML = tableRows; // Add all rows at once
    } catch (error) {
        console.error('Error loading products:', error);
        alert('Failed to load products. Please try again later.');
    }
}

window.onload = function() {
    loadProducts();
    document.getElementById('model-overlay').onclick = closeModel;
};

async function deleteProduct(id) {
    const confirmDelete = confirm("Are you sure you want to delete this product?");
    if (confirmDelete) {
        try {
            const response = await fetch(`/api/products/${id}`, { method: 'DELETE' });
            if (response.ok) {
                alert('Product deleted successfully');
                loadProducts(); // Reload the product list after successful deletion
            } else {
                alert('Failed to delete product.');
            }
        } catch (error) {
            console.error('Error deleting product:', error);
            alert('Failed to delete product. Please try again later.');
        }
    }
}

function openEditModal(id = null, inventoryid = '', name = '', quantity = '', price = '', description = '') {
    document.getElementById('productId').value = id || '';
    document.getElementById('inventoryId').value = inventoryid || '';
    document.getElementById('productName').value = name || '';
    document.getElementById('quantity').value = quantity || '';
    document.getElementById('productPrice').value = price || '';
    document.getElementById('description').value = description || '';
    document.getElementById('modal-title').innerText = id ? 'Edit Product' : 'Create Product';
    document.getElementById('product-modal').style.display = 'flex';
}

async function saveProduct(event) {
    event.preventDefault(); // Prevent form submission

    const id = document.getElementById('productId').value;
    const inventoryid = document.getElementById('inventoryId').value;
    const name = document.getElementById('productName').value;
    const quantity = document.getElementById('quantity').value;
    const price = document.getElementById('productPrice').value;
    const description = document.getElementById('description').value;

    const product = {
        inventoryId: inventoryid,
        productName: name,
        quantity: parseInt(quantity, 10),
        price: parseFloat(price),
        description: description,
    };

    try {
        let response;
        if (id) {
            // Update existing product
            response = await fetch(`/api/products/${id}`, {
                method: 'PUT',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(product),
            });
            if (!response.ok) throw new Error('Failed to update product');
            alert('Product updated successfully');
        } else {
            // Create new product
            response = await fetch('/api/products', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(product),
            });
            if (!response.ok) throw new Error('Failed to create product');
            alert('Product created successfully');
        }

        closeModal();
        loadProducts(); // Reload the product list
    } catch (error) {
        console.error('Error saving product:', error);
        alert('Failed to save product. Please try again later.');
    }
}

function closeModal() {
    document.getElementById('product-modal').style.display = 'none';
}
