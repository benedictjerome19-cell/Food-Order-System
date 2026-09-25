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
            gap: 2rem;
            max-width: 1200px;
            margin: 2rem auto;
            padding: 0 1rem;
        }
        .dashboard-card {
            background: rgba(255, 255, 255, 0.03);
            border: 1px solid var(--border-glass);
            border-radius: 16px;
            padding: 1.8rem;
            backdrop-filter: blur(16px);
            box-shadow: 0 10px 30px rgba(0,0,0,0.3);
        }
        .order-owner-card {
            background: rgba(0,0,0,0.25);
            border: 1px solid var(--border-glass);
            border-radius: 12px;
            padding: 1.25rem;
            margin-bottom: 1rem;
        }
        .status-badge {
            display: inline-block;
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 0.8rem;
            font-weight: 700;
            text-transform: uppercase;
        }
        .status-PENDING { background: rgba(245, 158, 11, 0.2); color: #f59e0b; border: 1px solid #f59e0b; }
        .status-PREPARING { background: rgba(59, 130, 246, 0.2); color: #3b82f6; border: 1px solid #3b82f6; }
        .status-OUT_FOR_DELIVERY { background: rgba(168, 85, 247, 0.2); color: #a855f7; border: 1px solid #a855f7; }
        .status-DELIVERED { background: rgba(16, 185, 129, 0.2); color: #10b981; border: 1px solid #10b981; }
        .status-CANCELLED { background: rgba(239, 68, 68, 0.2); color: #ef4444; border: 1px solid #ef4444; }
        
        .editable-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 1rem;
        }
        .editable-table th, .editable-table td {
            padding: 12px;
            text-align: left;
            border-bottom: 1px solid var(--border-glass);
        }
        .editable-table th {
            color: var(--accent-gold);
            font-weight: 700;
            font-size: 0.85rem;
            text-transform: uppercase;
        }
        .form-input-sm {
            background: rgba(10,9,14,0.8);
            border: 1px solid var(--border-glass);
            color: #fff;
            padding: 6px 10px;
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
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1.5rem;">
                <div>
                    <h2 style="font-size: 1.6rem; font-weight: 800; color: #fff;">📦 Live Incoming Orders</h2>
                    <p style="color: var(--text-muted); font-size: 0.9rem;">View customer delivery addresses, phone numbers, dish details, and advance order status.</p>
                </div>
                <button onclick="fetchOwnerOrders()" class="btn-outline-sm" style="cursor: pointer;">🔄 Refresh Orders</button>
            </div>
            <div id="owner-orders-list">
                <p style="color: var(--text-muted);">Loading live orders...</p>
            </div>
        </div>

        <!-- Editable Menu & Inventory Section -->
        <div class="dashboard-card">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1.5rem;">
                <div>
                    <h2 style="font-size: 1.6rem; font-weight: 800; color: #fff;">🍔 Editable Hotel Menu & Inventory</h2>
                    <p style="color: var(--text-muted); font-size: 0.9rem;">Edit dish prices, stock quantities, and availability status in real time.</p>
                </div>
                <button onclick="fetchOwnerMenu()" class="btn-outline-sm" style="cursor: pointer;">🔄 Reload Menu</button>
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
                        <div style="display:flex; justify-content:space-between; padding:4px 0; border-bottom:1px dashed rgba(255,255,255,0.05); font-size:0.9rem;">
                            <span>${i.menuItemName || 'Dish'} <strong>x${i.quantity}</strong></span>
                            <span style="color:var(--accent-gold);">Rs. ${(i.unitPrice * i.quantity).toFixed(2)}</span>
                        </div>
                    `).join('');
                }

                card.innerHTML = `
                    <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:10px;">
                        <div>
                            <strong style="color:var(--accent-gold); font-size:1.1rem;">ORDER #${order.id || order.orderId}</strong>
                            <small style="color:var(--text-muted); margin-left:10px;">Customer: ${order.buyerName || 'Valued Customer'}</small>
                        </div>
                        <span class="status-badge status-${order.status || 'PENDING'}">${order.status || 'PENDING'}</span>
                    </div>

                    <div style="margin: 10px 0; background: rgba(255,255,255,0.02); padding: 10px; border-radius: 8px;">
                        <strong style="font-size:0.85rem; color:var(--text-muted); text-transform:uppercase;">Ordered Dishes:</strong>
                        ${itemsHtml}
                    </div>

                    <div style="display:grid; grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)); gap:10px; font-size:0.88rem; color:var(--text-muted); margin-bottom:12px;">
                        <div>📍 <strong>Delivery Address:</strong><br>${order.deliveryAddress || 'N/A'}</div>
                        <div>📞 <strong>Phone:</strong><br>${order.customerPhone || 'N/A'}</div>
                        <div>💳 <strong>Payment:</strong><br>${order.paymentMethod || 'Online'} (${order.paymentStatus || 'SUCCESS'})</div>
                        <div>💰 <strong>Total:</strong><br><strong style="color:#fff; font-size:1.1rem;">Rs. ${parseFloat(order.totalAmount || order.total || 0).toFixed(2)}</strong></div>
                    </div>

                    <div style="display:flex; gap:8px; flex-wrap:wrap; margin-top:10px;">
                        <button onclick="updateStatus(${order.id || order.orderId}, 'PREPARING')" class="btn-outline-sm" style="background:rgba(59,130,246,0.2); color:#3b82f6; border-color:#3b82f6;">Mark Preparing</button>
                        <button onclick="updateStatus(${order.id || order.orderId}, 'OUT_FOR_DELIVERY')" class="btn-outline-sm" style="background:rgba(168,85,247,0.2); color:#a855f7; border-color:#a855f7;">Out for Delivery</button>
                        <button onclick="updateStatus(${order.id || order.orderId}, 'DELIVERED')" class="btn-outline-sm" style="background:rgba(16,185,129,0.2); color:#10b981; border-color:#10b981;">Mark Delivered</button>
                        <button onclick="updateStatus(${order.id || order.orderId}, 'CANCELLED')" class="btn-outline-sm" style="background:rgba(239,68,68,0.2); color:#ef4444; border-color:#ef4444;">Cancel Order</button>
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
                        <td><input type="number" step="0.01" id="price_${item.id}" class="form-input-sm" style="width:100px;" value="${item.price || 0}"></td>
                        <td><input type="number" id="stock_${item.id}" class="form-input-sm" style="width:80px;" value="${item.stockQty || 0}"></td>
                        <td>
                            <label style="cursor:pointer; font-size:0.85rem;">
                                <input type="checkbox" id="avail_${item.id}" ${availChecked}> In Stock
                            </label>
                        </td>
                        <td>
                            <button onclick="saveDish(${item.id})" class="btn-outline-sm" style="background:var(--primary); color:#fff; border:none; cursor:pointer;">Save</button>
                        </td>
                    </tr>
                `;
            });

            html += `</tbody></table>`;
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

        const res = await fetch(ctx + '/api/v1/manage-menu', {
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
