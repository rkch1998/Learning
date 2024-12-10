async function loadInventory() {
    try {
        const response = await fetch('/api/inventory');
        if (!response.ok) throw new Error('Failed to fetch inventory items.');
        const inventory = await response.json();

        const tableBody = document.getElementById('inventory-table-body');
        tableBody.innerHTML = '';

        inventory.forEach(item => {
            const row = `<tr>
                <td>${item.id}</td>
                <td>${item.userId}</td>
                <td>${item.inventoryName}</td>
                <td>${item.location}</td>
                <td>
                    <button onclick="openEditModal(${item.id}, ${item.userId}, '${item.inventoryName}', '${item.location}')">Edit</button>
                    <button class="delete-btn" onclick="deleteInventory(${item.id})">Delete</button>
                </td>
            </tr>`;
            tableBody.innerHTML += row;
        });
    } catch (error) {
        console.error('Error loading inventory:', error);
        alert('Failed to load inventory items. Please try again later.');
    }
}

async function deleteInventory(id) {
    const confirmDelete = confirm("Are you sure you want to delete this inventory?");
    if (confirmDelete) {
        try {
            const response = await fetch(`/api/inventory/${id}`, { method: 'DELETE' });
            if (response.ok) {
                alert('Inventory item deleted successfully');
                loadInventory();
            } else {
                alert('Failed to delete inventory item.');
            }
        } catch (error) {
            console.error('Error deleting inventory item:', error);
            alert('Failed to delete inventory item. Please try again later.');
        }
    }
}

function openEditModal(id = null, userid = '', inventoryname = '', location = '') {
    document.getElementById('inventoryId').value = id || '';
    document.getElementById('userId').value = userid || '';
    document.getElementById('inventoryName').value = inventoryname || '';
    document.getElementById('location').value = location || '';
    document.getElementById('modal-title').innerText = id ? 'Edit Inventory' : 'Create Inventory';
    document.getElementById('inventory-modal').style.display = 'flex';
}

async function saveInventory(event) {
    event.preventDefault();
    const id = document.getElementById('inventoryId').value;
    const userid = document.getElementById('userId').value;
    const inventoryname = document.getElementById('inventoryName').value;
    const location = document.getElementById('location').value;

    const inventory = { userid, inventoryname, location };

    try {
        if (id) {
            // Update existing inventory item
            await fetch(`/api/inventory/${id}`, {
                method: 'PUT',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(inventory),
            });
            alert('Inventory item updated successfully');
        } else {
            // Create new inventory item
            await fetch('/api/inventory', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(inventory),
            });
            alert('Inventory item created successfully');
        }
        closeModal();
        loadInventory();
    } catch (error) {
        console.error('Error saving inventory item:', error);
        alert('Failed to save inventory item. Please try again later.');
    }
}

function closeModal() {
    document.getElementById('inventory-modal').style.display = 'none';
}

window.onload = loadInventory;
