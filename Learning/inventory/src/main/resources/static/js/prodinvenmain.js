// Data Store (Simulating backend data for demo)
const dataStore = {
    products: [],
    inventory: [],
};

// Current Mode (Determines whether managing products or inventory)
let currentMode = 'products';

// Column Definitions
const columns = {
    products: ['ID', 'Name', 'Price', 'Description', 'Actions'],
    inventory: ['ID', 'Product ID', 'Stock Quantity', 'Location', 'Actions'],
};

// Form Fields Definitions
const formFields = {
    products: [
        { id: 'name', label: 'Product Name', type: 'text', placeholder: 'Enter product name' },
        { id: 'price', label: 'Price', type: 'number', placeholder: 'Enter price' },
        { id: 'description', label: 'Description', type: 'text', placeholder: 'Enter description' },
    ],
    inventory: [
        { id: 'productId', label: 'Product ID', type: 'number', placeholder: 'Enter product ID' },
        { id: 'stockQuantity', label: 'Stock Quantity', type: 'number', placeholder: 'Enter quantity' },
        { id: 'location', label: 'Location', type: 'text', placeholder: 'Enter location' },
    ],
};

// Initialize the Page
function initializePage(mode = 'products') {
    currentMode = mode;
    document.getElementById('page-title').innerText = currentMode === 'products' ? 'Product Management' : 'Inventory Management';
    document.getElementById('add-btn').innerText = `+ Add New ${currentMode === 'products' ? 'Product' : 'Inventory'}`;

    renderTable();
}

// Render Table
function renderTable() {
    const tableHead = document.querySelector('#data-table thead');
    const tableBody = document.getElementById('data-table-body');

    // Clear previous content
    tableHead.innerHTML = '';
    tableBody.innerHTML = '';

    // Add Headers
    const headers = columns[currentMode];
    const headerRow = headers.map((header) => `<th>${header}</th>`).join('');
    tableHead.innerHTML = `<tr>${headerRow}</tr>`;

    // Add Rows
    const items = dataStore[currentMode];
    items.forEach((item, index) => {
        const row = `
            <tr>
                ${Object.values(item)
                    .map((value) => `<td>${value}</td>`)
                    .join('')}
                <td>
                    <button onclick="editItem(${index})">Edit</button>
                    <button onclick="deleteItem(${index})">Delete</button>
                </td>
            </tr>
        `;
        tableBody.innerHTML += row;
    });
}

// Open Modal
function openModal(itemIndex = null) {
    const modal = document.getElementById('modal');
    const overlay = document.getElementById('modal-overlay');
    const formFieldsContainer = document.getElementById('form-fields');
    const fields = formFields[currentMode];

    // Reset Form
    document.getElementById('modal-form').reset();
    formFieldsContainer.innerHTML = '';

    // Populate Form Fields
    fields.forEach((field) => {
        formFieldsContainer.innerHTML += `
            <label for="${field.id}">${field.label}</label>
            <input type="${field.type}" id="${field.id}" placeholder="${field.placeholder}" required />
        `;
    });

    // Show Modal
    modal.style.display = 'block';
    overlay.style.display = 'block';
}

// Close Modal
function closeModal() {
    document.getElementById('modal').style.display = 'none';
    document.getElementById('modal-overlay').style.display = 'none';
}

// Handle Submit
function handleSubmit(event) {
    event.preventDefault();

    const fields = formFields[currentMode];
    const newItem = {};

    fields.forEach((field) => {
        newItem[field.id] = document.getElementById(field.id).value;
    });

    dataStore[currentMode].push(newItem);
    closeModal();
    renderTable();
}

// Edit Item
function editItem(index) {
    const modal = document.getElementById('modal');
    const overlay = document.getElementById('modal-overlay');
    const formFieldsContainer = document.getElementById('form-fields');
    const fields = formFields[currentMode];
    const item = dataStore[currentMode][index];

    // Populate Modal Fields
    formFieldsContainer.innerHTML = '';
    fields.forEach((field) => {
        formFieldsContainer.innerHTML += `
            <label for="${field.id}">${field.label}</label>
            <input type="${field.type}" id="${field.id}" value="${item[field.id]}" required />
        `;
    });

    // Show Modal
    modal.style.display = 'block';
    overlay.style.display = 'block';
}

// Delete Item
function deleteItem(index) {
    dataStore[currentMode].splice(index, 1);
    renderTable();
}

// Initialize Page with Products
initializePage();
