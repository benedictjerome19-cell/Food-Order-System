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
</head>
<body style="padding:2rem;max-width:800px;margin:0 auto;">
    <h2>Order History</h2>
    <p><a href="home.jsp">&larr; Back to Home</a></p>

    <div id="ordersList">Loading...</div>

    <script>
        const ctx = '<%= request.getContextPath() %>';
        const myRole = '<%= role %>';

        async function loadOrders() {
            const res = await fetch(ctx + '/api/v1/orders/history');
            const result = await res.json();
            const container = document.getElementById('ordersList');

            if (!result.success || result.data.length === 0) {
                container.innerHTML = '<p>No orders yet.</p>';
                return;
            }

            container.innerHTML = '';
            result.data.forEach(order => {
                const div = document.createElement('div');
                div.style.cssText = 'border:1px solid #ddd;padding:12px;margin-bottom:10px;border-radius:6px;';

                const whoLine = myRole === 'RESTAURANT_OWNER'
                    ? 'Buyer: ' + order.buyerName
                    : 'Restaurant: ' + order.restaurantName;

                let itemsHtml = '';
                if (order.items && order.items.length > 0) {
                    itemsHtml = '<ul style="margin:6px 0;padding-left:18px;font-size:0.85rem;">' +
                        order.items.map(i => '<li>' + i.name + ' x' + i.quantity + '</li>').join('') +
                        '</ul>';
                }

                let inner =
                    '<strong>Order #' + order.id + '</strong> &mdash; ' +
                    '<span style="color:#ff5252;font-weight:600;">' + order.status + '</span><br>' +
                    whoLine + '<br>' +
                    'Total: Rs.' + order.totalAmount + '<br>' +
                    '<small>Placed: ' + (order.createdAt || '') + '</small>' +
                    itemsHtml;

                if (myRole === 'RESTAURANT_OWNER') {
                    if (order.status !== 'DELIVERED' && order.status !== 'CANCELLED') {
                        inner += '<button onclick="advanceStatus(' + order.id + ')">Advance to Next Status</button>';
                    }
                } else if (order.status === 'DELIVERED') {
                    inner += '<button onclick="leaveReview(' + order.restaurantId + ')">Leave a Review</button>';
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
            if (!result.success) alert(result.error.message);
            loadOrders();
        }

        async function leaveReview(restaurantId) {
            const rating = prompt('Rate this restaurant 1-5:');
            if (!rating || rating < 1 || rating > 5) return;
            const comment = prompt('Leave a comment (optional):') || '';

            const formData = new URLSearchParams();
            formData.append('restaurantId', restaurantId);
            formData.append('rating', rating);
            formData.append('comment', comment);

            const res = await fetch(ctx + '/api/v1/reviews', { method: 'POST', body: formData });
            const result = await res.json();
            alert(result.success ? 'Thanks for your review!' : result.error.message);
        }

        loadOrders();
    </script>
</body>
</html>