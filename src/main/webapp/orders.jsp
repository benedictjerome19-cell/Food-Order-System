<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page isELIgnored="true" %>
<%
    String userName = (String) session.getAttribute("userName");
    if (userName == null) userName = "Guest";
    String userRole = (String) session.getAttribute("userRole");
    if (userRole == null) userRole = "CUSTOMER";
    boolean isOwner = "RESTAURANT_OWNER".equals(userRole);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Order History - Benedict Jerome Mart</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
    <style>
        .order-card {
            background: rgba(255, 255, 255, 0.03);
            border: 1px solid var(--border-glass);
            border-radius: 16px;
            padding: 1.5rem;
            margin-bottom: 1.5rem;
            backdrop-filter: blur(16px);
            transition: transform 0.3s ease, box-shadow 0.3s ease;
        }
        .order-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 12px 30px rgba(0,0,0,0.3);
            border-color: rgba(245, 158, 11, 0.4);
        }
        .status-pill {
            display: inline-block;
            padding: 6px 14px;
            border-radius: 20px;
            font-size: 0.82rem;
            font-weight: 700;
            letter-spacing: 0.5px;
            text-transform: uppercase;
        }
        .status-PENDING { background: rgba(245, 158, 11, 0.2); color: #f59e0b; border: 1px solid #f59e0b; }
        .status-PREPARING { background: rgba(59, 130, 246, 0.2); color: #3b82f6; border: 1px solid #3b82f6; }
        .status-OUT_FOR_DELIVERY { background: rgba(168, 85, 247, 0.2); color: #a855f7; border: 1px solid #a855f7; }
        .status-DELIVERED { background: rgba(16, 185, 129, 0.2); color: #10b981; border: 1px solid #10b981; }
        .status-CANCELLED { background: rgba(239, 68, 68, 0.2); color: #ef4444; border: 1px solid #ef4444; }
        .item-row {
            display: flex;
            justify-content: space-between;
            padding: 6px 0;
            border-bottom: 1px dashed rgba(255,255,255,0.06);
            font-size: 0.92rem;
        }
        .item-row:last-child { border-bottom: none; }
    </style>
</head>
<body>
    <nav class="navbar">
        <a href="<%= request.getContextPath() %>/home.jsp" class="brand">
            <div class="brand-icon">B</div>
            Benedict Jerome Mart
        </a>
        <div class="nav-right">
            <a href="<%= request.getContextPath() %>/home.jsp" class="btn-outline-sm">&larr; Back to Menu</a>
            <% if (isOwner) { %>
                <a href="<%= request.getContextPath() %>/owner-dashboard.jsp" class="btn-outline-sm">Owner Dashboard</a>
            <% } %>
            <a href="<%= request.getContextPath() %>/logout" class="btn-outline-sm">Logout</a>
        </div>
    </nav>

    <div style="max-width: 900px; margin: 2rem auto; padding: 0 1rem;">
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 2rem;">
            <div>
                <h1 style="font-size: 2rem; font-weight: 800; background: linear-gradient(135deg, #fff, #f59e0b); -webkit-background-clip: text; -webkit-text-fill-color: transparent;">Your Order History</h1>
                <p style="color: var(--text-muted); margin-top: 4px;">Track live delivery status, receipts, and order items.</p>
            </div>
            <button onclick="loadOrders()" class="btn-outline-sm" style="cursor: pointer;">🔄 Refresh</button>
        </div>

        <div id="ordersContainer">
            <p style="color: var(--text-muted); text-align: center; padding: 3rem;">Loading your orders...</p>
        </div>
    </div>

    <script>
        const ctx = '<%= request.getContextPath() %>';
        const userRole = '<%= userRole %>';

        async function loadOrders() {
            const container = document.getElementById('ordersContainer');
            try {
                const res = await fetch(ctx + '/api/v1/orders/history');
                const result = await res.json();

                if (!result.success || !result.data || result.data.length === 0) {
                    container.innerHTML = `
                        <div style="text-align: center; padding: 4rem 1rem; background: rgba(255,255,255,0.02); border-radius: 16px; border: 1px solid var(--border-glass);">
                            <div style="font-size: 3rem; margin-bottom: 1rem;">🛍️</div>
                            <h3 style="color: var(--text-main); margin-bottom: 0.5rem;">No Orders Yet</h3>
                            <p style="color: var(--text-muted); margin-bottom: 1.5rem;">Looks like you haven't placed any orders yet.</p>
                            <a href="${ctx}/home.jsp" class="btn btn-primary">Browse Menu & Order Now</a>
                        </div>`;
                    return;
                }

                container.innerHTML = '';
                result.data.forEach(order => {
                    const card = document.createElement('div');
                    card.className = 'order-card';

                    const statusClass = 'status-' + (order.status || 'PENDING');
                    const formattedDate = order.createdAt ? new Date(order.createdAt).toLocaleString() : 'Recent';

                    let itemsListHtml = '';
                    if (order.items && order.items.length > 0) {
                        itemsListHtml = order.items.map(item => `
                            <div class="item-row">
                                <span style="color: var(--text-main); font-weight: 500;">\${item.menuItemName || 'Dish Item'} <small style="color: var(--text-muted);">x\${item.quantity}</small></span>
                                <span style="color: var(--accent-gold); font-weight: 600;">Rs. \${(item.unitPrice * item.quantity).toFixed(2)}</span>
                            </div>
                        `).join('');
                    } else {
                        itemsListHtml = '<p style="color: var(--text-muted); font-size: 0.85rem;">Itemized breakdown available</p>';
                    }

                    card.innerHTML = `
                        <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 1rem; padding-bottom: 1rem; border-bottom: 1px solid var(--border-glass);">
                            <div>
                                <span style="color: var(--accent-gold); font-weight: 700; font-size: 0.9rem;">ORDER #\${order.id || order.orderId}</span>
                                <h3 style="color: var(--text-main); font-size: 1.25rem; font-weight: 700; margin: 4px 0;">\${order.restaurantName || 'Partner Hotel'}</h3>
                                <small style="color: var(--text-muted);">Placed on \${formattedDate}</small>
                            </div>
                            <div style="text-align: right;">
                                <span class="status-pill \${statusClass}">\${order.status || 'PENDING'}</span>
                                <div style="font-size: 1.3rem; font-weight: 800; color: #fff; margin-top: 6px;">Rs. \${parseFloat(order.totalAmount || order.total || 0).toFixed(2)}</div>
                            </div>
                        </div>

                        <div style="margin-bottom: 1rem; background: rgba(0,0,0,0.2); padding: 12px; border-radius: 10px;">
                            <div style="font-size: 0.85rem; color: var(--text-muted); margin-bottom: 6px; font-weight: 600; text-transform: uppercase; letter-spacing: 0.5px;">Ordered Items</div>
                            \${itemsListHtml}
                        </div>

                        <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 12px; font-size: 0.88rem; color: var(--text-muted); background: rgba(255,255,255,0.02); padding: 12px; border-radius: 10px;">
                            <div>📍 <strong>Delivery Address:</strong><br>\${order.deliveryAddress || 'Standard Delivery'}</div>
                            <div>📞 <strong>Contact Phone:</strong><br>\${order.customerPhone || 'N/A'}</div>
                            <div>💳 <strong>Payment Method:</strong><br>\${order.paymentMethod || 'Online Payment'} (\${order.paymentStatus || 'SUCCESS'})</div>
                            <div>🧾 <strong>Txn ID:</strong><br><code style="background: rgba(255,255,255,0.1); padding: 2px 6px; border-radius: 4px; color: var(--accent-gold);">\${order.transactionId || 'TXN-ONLINE'}</code></div>
                        </div>

                        \${order.status === 'DELIVERED' ? `
                            <div style="margin-top: 1rem; text-align: right;">
                                <button onclick="leaveReview(\${order.restaurantId})" class="btn-outline-sm" style="cursor: pointer; border-color: var(--accent-gold); color: var(--accent-gold);">⭐ Leave Restaurant Review</button>
                            </div>
                        ` : ''}
                    `;

                    container.appendChild(card);
                });
            } catch (err) {
                console.error('Error loading orders:', err);
                container.innerHTML = `<p style="color: #ef4444; text-align: center;">Failed to load order history. Please log in.</p>`;
            }
        }

        async function leaveReview(restaurantId) {
            const rating = prompt('Rate this hotel 1 to 5 stars:');
            if (!rating || rating < 1 || rating > 5) return;
            const comment = prompt('Leave a comment (optional):') || '';

            const formData = new URLSearchParams();
            formData.append('restaurantId', restaurantId);
            formData.append('rating', rating);
            formData.append('comment', comment);

            const res = await fetch(ctx + '/api/v1/reviews', { method: 'POST', body: formData });
            const result = await res.json();
            alert(result.success ? 'Thank you for rating your hotel experience!' : (result.error ? result.error.message : 'Error submitting review.'));
        }

        document.addEventListener('DOMContentLoaded', loadOrders);
    </script>
</body>
</html>