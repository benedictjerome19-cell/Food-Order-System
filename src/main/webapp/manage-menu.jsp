<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page isELIgnored="true" %>
<%
    String userName = (String) session.getAttribute("userName");
    String userRole = (String) session.getAttribute("userRole");
    if (!"RESTAURANT_OWNER".equals(userRole) && !"ADMIN".equals(userRole) && !"DEVELOPER".equals(userRole)) {
        response.sendRedirect(request.getContextPath() + "/home.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Manage Menu - BenedictJeromeMart</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
    <style>
        .manage-layout { max-width: 1200px; margin: 1.5rem auto; padding: 0 1rem; display: grid; grid-template-columns: 360px 1fr; gap: 1.5rem; }
        .manage-panel { background: var(--bg-card); border-radius: 8px; border: 1px solid var(--border); padding: 1.5rem; }
        table.dish-table { width: 100%; border-collapse: collapse; font-size: 0.9rem; color: #fff; }
        table.dish-table th, table.dish-table td { padding: 0.75rem; border-bottom: 1px solid var(--border); }
    </style>
</head>
<body>
<header class="navbar">
    <a href="home.jsp" class="brand"><div class="brand-icon">🛒</div>BenedictJeromeMart</a>
    <div class="nav-right">
        <a href="home.jsp" class="btn btn-outline-sm">Home</a>
        <a href="logout" class="btn btn-outline-sm">Logout</a>
    </div>
</header>
<main class="manage-layout">
    <section class="manage-panel">
        <h2 id="formTitle">➕ Add Dish</h2>
        <form id="dishForm" onsubmit="return submitDish(event)">
            <input type="hidden" id="dishId">
            <div class="form-group"><label>Name</label><input type="text" class="form-control" id="dishName" required></div>
            <div class="form-group"><label>Price (Rs.)</label><input type="number" step="0.01" class="form-control" id="dishPrice" required></div>
            <div class="form-group"><label>Stock</label><input type="number" class="form-control" id="dishStock" value="20"></div>
            <div class="form-group"><label>Category</label><input type="text" class="form-control" id="dishCategory" required></div>
            <div class="form-group"><label>Image URL</label><input type="text" class="form-control" id="dishImage"></div>
            <button type="submit" class="btn btn-primary" id="dishSubmitBtn">Save Dish</button>
            <div id="formMessage"></div>
        </form>
    </section>
    <section class="manage-panel">
        <h2>🍽️ Your Dishes</h2>
        <table class="dish-table">
            <thead><tr><th>Name</th><th>Category</th><th>Price</th><th>Stock</th><th>Action</th></tr></thead>
            <tbody id="dishTableBody"><tr><td colspan="5">Loading...</td></tr></tbody>
        </table>
    </section>
</main>
<script>
const ctx = '<%= request.getContextPath() %>';
async function loadDishes() {
    const res = await fetch(ctx + '/api/v1/owner/menu-items');
    const result = await res.json();
    if (!result.success) return;
    const body = document.getElementById('dishTableBody');
    body.innerHTML = (result.data.items || []).map(d => `
        <tr>
            <td><strong>${d.name}</strong></td>
            <td>${d.category}</td>
            <td>Rs.${d.price}</td>
            <td>${d.stockQty}</td>
            <td><button class="btn btn-outline-sm" onclick="deleteDish(${d.id})">Delete</button></td>
        </tr>
    `).join('');
}
async function submitDish(e) {
    e.preventDefault();
    const body = new URLSearchParams();
    if (document.getElementById('dishId').value) body.append('id', document.getElementById('dishId').value);
    body.append('name', document.getElementById('dishName').value);
    body.append('price', document.getElementById('dishPrice').value);
    body.append('stockQty', document.getElementById('dishStock').value);
    body.append('category', document.getElementById('dishCategory').value);
    body.append('imageUrl', document.getElementById('dishImage').value);
    await fetch(ctx + '/api/v1/owner/menu-items', { method: 'POST', body });
    document.getElementById('dishForm').reset();
    loadDishes();
    return false;
}
async function deleteDish(id) {
    await fetch(ctx + '/api/v1/owner/menu-items?id=' + id, { method: 'DELETE' });
    loadDishes();
}
loadDishes();
</script>
</body>
</html>