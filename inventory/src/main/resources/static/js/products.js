async function loadProducts() {
    try {
        const response = await fetch('/api/products');
        if (!response.ok) throw new Error('Failed to fetch products.');

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
                <td>${product.name}</td>
                <td>${product.price}</td>
                <td>
                    <button onclick="openEditModal(${product.id}, '${product.name}', ${product.price})">Edit</button>
                    <button class="delete-btn" onclick="deleteProduct(${product.id})">Delete</button>
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

function openEditModal(id = null, name = '', price = '') {
    document.getElementById('productId').value = id || '';
    document.getElementById('productName').value = name || '';
    document.getElementById('productPrice').value = price || '';
    document.getElementById('modal-title').innerText = id ? 'Edit Product' : 'Create Product';
    document.getElementById('product-modal').style.display = 'flex';
}

async function saveProduct(event) {
    event.preventDefault(); // Prevent form submission

    const id = document.getElementById('productId').value;
    const name = document.getElementById('productName').value;
    const price = document.getElementById('productPrice').value;

    const product = { name, price };

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
