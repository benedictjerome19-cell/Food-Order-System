<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page isELIgnored="true" %>
<%
    String role = (String) session.getAttribute("userRole");
    if (role == null) role = "CUSTOMER";
%>
<!DOCTYPE html>
<html>
<head>
    <title>Order History - BenedictJeromeMart</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
    <style>
        .order-card { border: 1px solid var(--border); padding: 1rem; margin-bottom: 1rem; border-radius: 8px; background: var(--bg-card); }
    </style>
</head>
<body style="padding:2rem;max-width:800px;margin:0 auto;background:var(--bg-main);">
    <h2>Order History</h2>
    <p style="margin-bottom: 1.5rem;"><a href="home.jsp" style="color:var(--primary);font-weight:bold;">&larr; Back to Home</a></p>

    <div id="ordersList">Loading...</div>

    <script>
        const ctx = '<%= request.getContextPath() %>';
        const myRole = '<%= role %>';

        async function loadOrders() {
            const res = await fetch(ctx + '/api/v1/orders/history');
            const result = await res.json();
            const container = document.getElementById('ordersList');

            if (!result.success || !result.data || result.data.length === 0) {
                container.innerHTML = '<p>No orders yet.</p>';
                return;
            }

            container.innerHTML = '';
            result.data.forEach(order => {
                const div = document.createElement('div');
                div.className = 'order-card';

                const whoLine = myRole === 'RESTAURANT_OWNER'
                    ? 'Buyer: <strong>' + order.buyerName + '</strong>'
                    : 'Restaurant: <strong>' + (order.restaurantName || 'BenedictKitchen') + '</strong>';

                let itemsHtml = '';
                if (order.items && order.items.length > 0) {
                    itemsHtml = '<ul style="margin:8px 0;padding-left:18px;font-size:0.9rem;color:var(--text-muted);">' +
                        order.items.map(i => '<li>' + (i.name || i.menuItemName) + ' x' + i.quantity + '</li>').join('') +
                        '</ul>';
                }

                let inner =
                    '<div style="display:flex;justify-content:space-between;margin-bottom:0.5rem;">' +
                        '<strong>Order #' + (order.id || order.orderId) + '</strong>' +
                        '<span style="color:var(--primary);font-weight:700;">' + order.status + '</span>' +
                    '</div>' +
                    whoLine + '<br>' +
                    'Total: Rs.' + (order.totalAmount || order.total) + '<br>' +
                    '<small style="color:var(--text-muted);">Placed: ' + (order.createdAt || '') + '</small>' +
                    itemsHtml;

                if (myRole === 'RESTAURANT_OWNER') {
                    if (order.status !== 'DELIVERED' && order.status !== 'CANCELLED') {
                        inner += '<button class="btn btn-outline-sm" style="margin-top:0.5rem;" onclick="advanceStatus(' + (order.id || order.orderId) + ')">Advance Status</button>';
                    }
                }

                div.innerHTML = inner;
                container.appendChild(div);
            });
        }

        async function advanceStatus(orderId) {
            const formData = new URLSearchParams();
            formData.append('orderId', orderId);
            const res = await fetch(ctx + '/api/v1/owner/orders/status', { method: 'POST', body: formData });
            const result = await res.json();
            if (!result.success) alert(result.error ? result.error.message : 'Failed');
            loadOrders();
        }

        loadOrders();
    </script>
</body>
</html>