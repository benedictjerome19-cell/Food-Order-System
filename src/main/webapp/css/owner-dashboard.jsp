<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Owner Dashboard - Benedict Jerome Mart</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
    <nav class="navbar">
        <a href="${pageContext.request.contextPath}/home.jsp" class="brand">
            <div class="brand-icon">B</div>
            Hotel Owner Portal
        </a>
        <div class="nav-right">
            <a href="${pageContext.request.contextPath}/logout" class="btn-outline-sm">Logout</a>
        </div>
    </nav>

    <div class="main-layout" style="grid-template-columns: 1fr; max-width: 1200px; margin: 2rem auto; padding: 0 1rem;">
        
        <!-- Section 1: Live Incoming Orders -->
        <div class="auth-card" style="max-width: 100%; margin-bottom: 2rem;">
            <h2 class="section-title">📦 Live Incoming Orders</h2>
            <div id="orders-container">
                <p style="color: var(--text-muted);">Loading live orders...</p>
            </div>
        </div>

        <!-- Section 2: Editable Menu Inventory Management -->
        <div class="auth-card" style="max-width: 100%;">
            <h2 class="section-title">🍔 Manage Menu & Stock</h2>
            <div id="menu-management-container">
                <p style="color: var(--text-muted);">Loading menu items...</p>
            </div>
        </div>
    </div>

    <script>
    const ctx = '${pageContext.request.contextPath}';

    document.addEventListener('DOMContentLoaded', () => {
        fetchOwnerOrders();
        fetchOwnerMenu();
    });

    function fetchOwnerOrders() {
        fetch(ctx + '/api/v1/orders/history', { method: 'GET', headers: { 'Accept': 'application/json' } })
        .then(res => res.json())
        .then(res => {
            if (res.success && res.data) {
                renderOwnerOrders(res.data);
            }
        })
        .catch(err => console.error('Error fetching orders:', err));
    }

    function renderOwnerOrders(orders) {
        const container = document.getElementById('orders-container');
        if (!orders || orders.length === 0) {
            container.innerHTML = `<p style="color: var(--text-muted);">No incoming orders found.</p>`;
            return;
        }

        let html = '<div style="display: flex; flex-direction: column; gap: 1rem;">';
        orders.forEach(order => {
            html.append ? null : ''; // placeholder
            html += `
                <div style="background: rgba(255,255,255,0.03); border: 1px solid var(--border-glass); padding: 1.5rem; border-radius: 12px;">
                    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 0.8rem;">
                        <strong>Order #${order.orderId}</strong>
                        <span class="category-badge" style="position:static;">Status: \${order.status}</span>
                    </div>
                    <p style="margin: 4px 0;"><strong>Customer Phone:</strong> \${order.customerPhone || 'N/A'}</p>
                    <p style="margin: 4px 0;"><strong>Delivery Address:</strong> \${order.deliveryAddress || 'N/A'}</p>
                    <p style="margin: 4px 0;"><strong>Payment:</strong> \${order.paymentMethod || 'Online'} (\${order.paymentStatus || 'PAID'})</p>
                    <p style="margin: 4px 0;"><strong>Total Amount:</strong> Rs. \${order.totalAmount || order.total}</p>
                    
                    <div style="margin-top: 1rem; display: flex; gap: 0.5rem;">
                        <button onclick="advanceOrderStatus(\${order.orderId})" class="btn-outline-sm" style="background:var(--primary); color:white; border:none;">Advance Status</button>
                    </div>
                </div>`;
        });
        html += '</div>';
        container.innerHTML = html;
    }

    function advanceOrderStatus(orderId) {
        const payload = new URLSearchParams();
        payload.append('orderId', orderId);

        fetch(ctx + '/api/v1/owner/orders/status', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: payload
        })
        .then(res => res.json())
        .then(res => {
            if (res.success) {
                fetchOwnerOrders();
            } else {
                alert(res.error ? res.error.message : 'Failed to update status.');
            }
        })
        .catch(err => console.error('Error updating status:', err));
    }

    function fetchOwnerMenu() {
        fetch(ctx + '/api/v1/owner/menu-items', { method: 'GET', headers: { 'Accept': 'application/json' } })
        .then(res => res.json())
        .then(res => {
            if (res.success && res.data && res.data.items) {
                renderOwnerMenu(res.data.items);
            }
        })
        .catch(err => console.error('Error fetching menu:', err));
    }

    function renderOwnerMenu(items) {
        const container = document.getElementById('menu-management-container');
        if (!items || items.length === 0) {
            container.innerHTML = `<p style="color: var(--text-muted);">No menu items found.</p>`;
            return;
        }

        let html = '<div style="display: grid; grid-template-columns: repeat(auto-fill, minmax(280px, 1fr)); gap: 1rem;">';
        items.forEach(item => {
            html += `
                <div style="background: rgba(255,255,255,0.03); border: 1px solid var(--border-glass); padding: 1rem; border-radius: 12px;">
                    <strong>\${item.name}</strong>
                    <p style="margin: 4px 0; color: var(--accent-gold);">Price: Rs. \${item.price}</p>
                    <p style="margin: 4px 0; font-size: 0.85rem;">Stock Qty: \${item.stockQty}</p>
                    <span style="font-size: 0.8rem; color: #4cd137;">● \${item.isAvailable !== false ? 'In Stock' : 'Out of Stock'}</span>
                </div>`;
        });
        html += '</div>';
        container.innerHTML = html;
    }
    </script>
</body>
</html>