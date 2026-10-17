<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page isELIgnored="true" %>
<%
    String userName = (String) session.getAttribute("userName");
    if (userName == null) userName = "Hotel Owner";
    String userRole = (String) session.getAttribute("userRole");
    if (!"RESTAURANT_OWNER".equals(userRole) && !"ADMIN".equals(userRole)) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Hotel Owner Dashboard - Benedict Jerome Mart</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
    <style>
        .dashboard-grid {
            display: grid;
            grid-template-columns: 1fr;
            gap: 1.5rem;
            max-width: 1200px;
            margin: 1.5rem auto;
            padding: 0 1rem;
        }
        .dashboard-card {
            background: var(--bg-card);
            border: 1px solid var(--border);
            border-radius: 12px;
            padding: 1.25rem;
        }
        .order-owner-card {
            background: #f8fafc;
            border: 1px solid var(--border);
            border-radius: 8px;
            padding: 1rem;
            margin-bottom: 1rem;
        }
        .status-badge {
            display: inline-block;
            padding: 3px 10px;
            border-radius: 20px;
            font-size: 0.75rem;
            font-weight: 700;
            text-transform: uppercase;
        }
        .status-PENDING { background: #fef3c7; color: #d97706; border: 1px solid #fde68a; }
        .status-PREPARING { background: #dbeafe; color: #2563eb; border: 1px solid #bfdbfe; }
        .status-OUT_FOR_DELIVERY { background: #f3e8ff; color: #9333ea; border: 1px solid #e9d5ff; }
        .status-DELIVERED { background: #dcfce7; color: #166534; border: 1px solid #bbf7d0; }
        .status-CANCELLED { background: #fee2e2; color: #991b1b; border: 1px solid #fecaca; }
        
        .table-responsive {
            width: 100%;
            overflow-x: auto;
        }
        .editable-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 1rem;
            min-width: 500px;
        }
        .editable-table th, .editable-table td {
            padding: 10px;
            text-align: left;
            border-bottom: 1px solid var(--border);
            font-size: 0.9rem;
        }
        .editable-table th {
            color: var(--text-muted);
            font-weight: 700;
            font-size: 0.8rem;
            text-transform: uppercase;
        }
        .form-input-sm {
            background: #fff;
            border: 1px solid var(--border);
            color: var(--text-main);
            padding: 6px 8px;
            border-radius: 6px;
            font-size: 0.9rem;
            width: 100%;
        }
    </style>
</head>
<body>
    <nav class="navbar">
        <a href="<%= request.getContextPath() %>/home.jsp" class="brand">
            <div class="brand-icon">🏨</div>
            Hotel Owner Portal
        </a>
        <div class="nav-right">
            <div class="welcome-badge">
                <span class="welcome-avatar">H</span>
                Hi, <%= userName %>
            </div>
            <a href="<%= request.getContextPath() %>/home.jsp" class="btn-outline-sm">Customer View</a>
            <a href="<%= request.getContextPath() %>/logout" class="btn-outline-sm">Logout</a>
        </div>
    </nav>

    <div class="dashboard-grid">
        <!-- Live Incoming Orders Section -->
        <div class="dashboard-card">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1.25rem; flex-wrap: wrap; gap: 0.75rem;">
                <div>
                    <h2 style="font-size: 1.3rem; font-weight: 800;">📦 Live Incoming Orders</h2>
                    <p style="color: var(--text-muted); font-size: 0.85rem;">View delivery details, dishes, and advance order status.</p>
                </div>
                <button onclick="fetchOwnerOrders()" class="btn-outline-sm">🔄 Refresh</button>
            </div>
            <div id="owner-orders-list">
                <p style="color: var(--text-muted);">Loading live orders...</p>
            </div>
        </div>

        <!-- Editable Menu & Inventory Section -->
        <div class="dashboard-card">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1.25rem; flex-wrap: wrap; gap: 0.75rem;">
                <div>
                    <h2 style="font-size: 1.3rem; font-weight: 800;">🍔 Editable Menu & Inventory</h2>
                    <p style="color: var(--text-muted); font-size: 0.85rem;">Edit dish prices, stock quantities, and availability.</p>
                </div>
                <button onclick="fetchOwnerMenu()" class="btn-outline-sm">🔄 Reload</button>
            </div>

            <div id="owner-menu-list">
                <p style="color: var(--text-muted);">Loading menu items...</p>
            </div>
        </div>
    </div>

    <script>
    const ctx = '<%= request.getContextPath() %>';

    document.addEventListener('DOMContentLoaded', () => {
        fetchOwnerOrders();
        fetchOwnerMenu();
    });

    async function fetchOwnerOrders() {
        const container = document.getElementById('owner-orders-list');
        try {
            const res = await fetch(ctx + '/api/v1/orders/history');
            const result = await res.json();

            if (!result.success || !result.data || result.data.length === 0) {
                container.innerHTML = `<p style="color: var(--text-muted); padding: 1rem 0;">No incoming orders found for your hotel.</p>`;
                return;
            }

            container.innerHTML = '';
            result.data.forEach(order => {
                const card = document.createElement('div');
                card.className = 'order-owner-card';

                let itemsHtml = '';
                if (order.items && order.items.length > 0) {
                    itemsHtml = order.items.map(i => `
                        <div style="display:flex; justify-content:space-between; padding:4px 0; border-bottom:1px dashed var(--border); font-size:0.88rem;">
                            <span>${i.menuItemName || 'Dish'} <strong>x${i.quantity}</strong></span>
                            <span style="color:var(--primary); font-weight:600;">Rs. ${(i.unitPrice * i.quantity).toFixed(2)}</span>
                        </div>
                    `).join('');
                }

                card.innerHTML = `
                    <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:8px; flex-wrap:wrap; gap:5px;">
                        <div>
                            <strong style="color:var(--primary); font-size:1.05rem;">ORDER #${order.id || order.orderId}</strong>
                            <small style="color:var(--text-muted); display:block;">Customer: ${order.buyerName || 'Valued Customer'}</small>
                        </div>
                        <span class="status-badge status-${order.status || 'PENDING'}">${order.status || 'PENDING'}</span>
                    </div>

                    <div style="margin: 8px 0; background: #fff; padding: 8px; border-radius: 6px; border:1px solid var(--border);">
                        <strong style="font-size:0.8rem; color:var(--text-muted); text-transform:uppercase;">Ordered Dishes:</strong>
                        ${itemsHtml}
                    </div>

                    <div style="display:grid; grid-template-columns: repeat(auto-fit, minmax(140px, 1fr)); gap:8px; font-size:0.85rem; color:var(--text-muted); margin-bottom:10px;">
                        <div>📍 <strong>Address:</strong><br>${order.deliveryAddress || 'N/A'}</div>
                        <div>📞 <strong>Phone:</strong><br>${order.customerPhone || 'N/A'}</div>
                        <div>💳 <strong>Payment:</strong><br>${order.paymentMethod || 'Online'}</div>
                        <div>💰 <strong>Total:</strong><br><strong style="color:var(--text-main); font-size:1rem;">Rs. ${parseFloat(order.totalAmount || order.total || 0).toFixed(2)}</strong></div>
                    </div>

                    <div style="display:flex; gap:6px; flex-wrap:wrap; margin-top:8px;">
                        <button onclick="updateStatus(${order.id || order.orderId}, 'PREPARING')" class="btn-outline-sm" style="color:#2563eb; border-color:#bfdbfe;">Preparing</button>
                        <button onclick="updateStatus(${order.id || order.orderId}, 'OUT_FOR_DELIVERY')" class="btn-outline-sm" style="color:#9333ea; border-color:#e9d5ff;">Out for Delivery</button>
                        <button onclick="updateStatus(${order.id || order.orderId}, 'DELIVERED')" class="btn-outline-sm" style="color:#166534; border-color:#bbf7d0;">Delivered</button>
                        <button onclick="updateStatus(${order.id || order.orderId}, 'CANCELLED')" class="btn-outline-sm" style="color:#991b1b; border-color:#fecaca;">Cancel</button>
                    </div>
                `;
                container.appendChild(card);
            });
        } catch (err) {
            console.error('Error fetching orders:', err);
            container.innerHTML = `<p style="color: #ef4444;">Failed to load incoming orders.</p>`;
        }
    }

    async function updateStatus(orderId, status) {
        const formData = new URLSearchParams();
        formData.append('orderId', orderId);
        formData.append('status', status);

        const res = await fetch(ctx + '/api/v1/owner/orders/status', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: formData
        });
        const result = await res.json();
        if (result.success) {
            fetchOwnerOrders();
        } else {
            alert(result.error ? result.error.message : 'Failed to update order status.');
        }
    }

    async function fetchOwnerMenu() {
        const container = document.getElementById('owner-menu-list');
        try {
            const res = await fetch(ctx + '/api/v1/menu-items');
            const result = await res.json();

            if (!result.success || !result.data || result.data.length === 0) {
                container.innerHTML = `<p style="color: var(--text-muted);">No menu items found.</p>`;
                return;
            }

            let html = `
                <div class="table-responsive">
                    <table class="editable-table">
                        <thead>
                            <tr>
                                <th>Dish Name</th>
                                <th>Category</th>
                                <th>Price (Rs.)</th>
                                <th>Stock Qty</th>
                                <th>Status</th>
                                <th>Action</th>
                            </tr>
                        </thead>
                        <tbody>
            `;

            result.data.forEach(item => {
                const availChecked = item.isAvailable !== false ? 'checked' : '';
                html += `
                    <tr>
                        <td><input type="text" id="name_${item.id}" class="form-input-sm" value="${item.name || ''}"></td>
                        <td style="color: var(--text-muted); font-size: 0.85rem;">${item.category || 'Mains'}</td>
                        <td><input type="number" step="0.01" id="price_${item.id}" class="form-input-sm" style="width:80px;" value="${item.price || 0}"></td>
                        <td><input type="number" id="stock_${item.id}" class="form-input-sm" style="width:60px;" value="${item.stockQty || 0}"></td>
                        <td>
                            <label style="cursor:pointer; font-size:0.85rem; white-space:nowrap;">
                                <input type="checkbox" id="avail_${item.id}" ${availChecked}> In Stock
                            </label>
                        </td>
                        <td>
                            <button onclick="saveDish(${item.id})" class="btn-outline-sm" style="background:var(--primary); color:#fff; border:none; cursor:pointer;">Save</button>
                        </td>
                    </tr>
                `;
            });

            html += `</tbody></table></div>`;
            container.innerHTML = html;
        } catch (err) {
            console.error('Error fetching menu items:', err);
            container.innerHTML = `<p style="color: #ef4444;">Failed to load menu items.</p>`;
        }
    }

    async function saveDish(itemId) {
        const price = document.getElementById('price_' + itemId).value;
        const stock = document.getElementById('stock_' + itemId).value;
        const available = document.getElementById('avail_' + itemId).checked;

        const formData = new URLSearchParams();
        formData.append('id', itemId);
        formData.append('price', price);
        formData.append('stockQty', stock);
        formData.append('isAvailable', available);

        const res = await fetch(ctx + '/api/v1/owner/menu-items', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: formData
        });
        const result = await res.json();
        if (result.success) {
            alert('Dish details saved successfully!');
            fetchOwnerMenu();
        } else {
            alert(result.error ? result.error.message : 'Failed to save dish changes.');
        }
    }
    </script>
</body>
</html>
