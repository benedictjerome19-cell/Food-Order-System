<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Menu - Benedict Jerome Mart</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
    <!-- Premium Glassmorphism Navbar -->
    <nav class="navbar">
        <a href="${pageContext.request.contextPath}/home.jsp" class="brand">
            <div class="brand-icon">B</div>
            Benedict Jerome Mart
        </a>
        <div class="nav-right">
            <% if(session.getAttribute("userId") != null) { %>
                <div class="welcome-badge">
                    <span class="welcome-avatar"><%= session.getAttribute("userName") != null ? session.getAttribute("userName").toString().substring(0,1).toUpperCase() : "U" %></span>
                    Hi, <%= session.getAttribute("userName") %>
                </div>
                <a href="${pageContext.request.contextPath}/orders.jsp" class="btn-outline-sm">My Orders</a>
                <a href="${pageContext.request.contextPath}/logout" class="btn-outline-sm">Logout</a>
            <% } else { %>
                <a href="${pageContext.request.contextPath}/login.jsp" class="btn-outline-sm">Login</a>
            <% } %>
        </div>
    </nav>

    <!-- Hero Banner -->
    <div class="hero-banner">
        <div class="hero-content">
            <div class="hero-tag">Premium Taste</div>
            <h1>Experience <span class="hero-name">Luxury Dining</span><br>At Home.</h1>
            <p class="hero-sub">Crafted with passion, delivered with elegance.</p>
        </div>
        <div class="hero-art">🍔🍣🍕</div>
    </div>

    <!-- Main Dashboard Layout -->
    <div class="main-layout">
        <!-- Left: 3D Food Menu Grid -->
        <div>
            <h2 class="section-title">Explore Delicious Menu</h2>
            <div class="menu-grid">
                <!-- Item 1: Burger -->
                <div class="menu-card food-card">
                    <div class="menu-card-header">
                        <span class="category-badge">Burger</span>
                    </div>
                    <div class="food-image-wrap">
                        <img src="https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&w=500&q=80" alt="Classic Burger" class="food-image">
                    </div>
                    <div class="menu-card-body">
                        <div class="item-name">Classic Cheese Burger</div>
                        <div class="item-price">Rs. 199</div>
                        <p class="item-desc">Freshly prepared classic cheese burger, made to order.</p>
                        <button class="btn-add" data-menu-item-id="1">Add to Cart</button>
                    </div>
                </div>

                <!-- Item 2: Pizza -->
                <div class="menu-card food-card">
                    <div class="menu-card-header">
                        <span class="category-badge">Pizza</span>
                    </div>
                    <div class="food-image-wrap">
                        <img src="https://images.unsplash.com/photo-1604381536136-22462f001bd4?auto=format&fit=crop&w=500&q=80" alt="Margherita" class="food-image">
                    </div>
                    <div class="menu-card-body">
                        <div class="item-name">Margherita Pizza</div>
                        <div class="item-price">Rs. 325</div>
                        <p class="item-desc">Freshly prepared margherita pizza, baked to perfection.</p>
                        <button class="btn-add" data-menu-item-id="2">Add to Cart</button>
                    </div>
                </div>
            </div>
        </div>

        <!-- Right: Premium Floating Cart Panel -->
        <div class="cart-panel">
            <h3 class="section-title">
                Your Cart <span class="cart-badge" id="cart-count">0</span>
            </h3>
            
            <div id="cart-items-container">
                <div class="empty-cart-msg">
                    <p>Your cart is empty</p>
                    <small>Add items from the menu</small>
                </div>
            </div>
            
            <div class="cart-total">
                <span>Total</span>
                <span id="cart-total-amount">Rs. 0</span>
            </div>
            
            <button id="proceed-to-pay-btn" class="btn btn-primary" disabled style="width: 100%;">
                Proceed to Pay
            </button>
        </div>
    </div>

    <!-- PAYMENT MODAL -->
    <div class="modal-overlay" id="paymentModal">
        <div class="modal">
            <div class="modal-header">
                <h2>Secure Checkout</h2>
                <button class="modal-close" id="closePaymentModal">&times;</button>
            </div>
            <div class="payment-total-banner">
                <span>Total Amount to Pay</span>
                <strong id="modal-total-amount">Rs. 0</strong>
            </div>
            
            <div class="form-group" style="margin-top: 1rem;">
                <label style="color: var(--text-main); font-size: 0.9rem; font-weight: 500;">Delivery Address</label>
                <input type="text" id="checkoutAddress" class="form-control" placeholder="House No, Street, City" required>
            </div>
            <div class="form-group">
                <label style="color: var(--text-main); font-size: 0.9rem; font-weight: 500;">Phone Number</label>
                <input type="tel" id="checkoutPhone" class="form-control" placeholder="10-digit mobile number" required>
            </div>
            <div class="form-group">
                <label style="color: var(--text-main); font-size: 0.9rem; font-weight: 500;">Payment Method</label>
                <select id="checkoutPaymentMethod" class="form-control" style="background: rgba(10,9,14,0.9); color: var(--text-main);">
                    <option value="UPI">UPI / Google Pay / PhonePe</option>
                    <option value="CARD">Credit / Debit Card</option>
                    <option value="NET_BANKING">Net Banking</option>
                    <option value="COD">Cash on Delivery</option>
                </select>
            </div>

            <button class="btn btn-primary" id="confirm-pay-btn" style="width: 100%; margin-top: 1rem;">
                Confirm & Pay
            </button>
        </div>
    </div>

    <!-- SUCCESS OVERLAY -->
    <div class="success-overlay" id="successOverlay">
        <div class="success-box">
            <div class="success-icon">🎉</div>
            <h2>Order Placed!</h2>
            <p id="success-message">Your payment was successful and your order is being prepared.</p>
        </div>
    </div>

    <!-- AI CHAT DRAWER -->
    <button id="chatToggleBtn">💬</button>
    <div id="chatPanel">
        <div id="chatHeader">
            <span>AI Assistant</span>
            <button id="closeChatBtn">&times;</button>
        </div>
        <div id="chatMessages">
            <div class="chat-msg bot">Hi there! How can I help you with your order today?</div>
        </div>
        <div id="chatInputRow">
            <input type="text" id="chatInput" placeholder="Type a message...">
            <button id="chatSendBtn">Send</button>
        </div>
    </div>

    <!-- JavaScript Integrations -->
    <script>
    const ctx = '${pageContext.request.contextPath}';

    document.addEventListener('DOMContentLoaded', () => {
        initialize3DEffect();
        fetchCart();

        document.querySelectorAll('.btn-add').forEach(button => {
            button.addEventListener('click', (e) => {
                const menuItemId = e.target.getAttribute('data-menu-item-id');
                if(menuItemId) addToCart(menuItemId);
            });
        });

        const proceedPayBtn = document.getElementById('proceed-to-pay-btn');
        const paymentModal = document.getElementById('paymentModal');
        const closePaymentModal = document.getElementById('closePaymentModal');
        const confirmPayBtn = document.getElementById('confirm-pay-btn');

        if (proceedPayBtn) proceedPayBtn.addEventListener('click', () => paymentModal.classList.add('active'));
        if (closePaymentModal) closePaymentModal.addEventListener('click', () => paymentModal.classList.remove('active'));
        if (confirmPayBtn) confirmPayBtn.addEventListener('click', processPayment);

        const chatToggleBtn = document.getElementById('chatToggleBtn');
        const chatPanel = document.getElementById('chatPanel');
        const closeChatBtn = document.getElementById('closeChatBtn');
        
        chatToggleBtn.addEventListener('click', () => chatPanel.classList.toggle('open'));
        closeChatBtn.addEventListener('click', () => chatPanel.classList.remove('open'));
    });

    function initialize3DEffect() {
        const cards = document.querySelectorAll('.food-card');
        cards.forEach(card => {
            card.addEventListener('mousemove', (e) => {
                const rect = card.getBoundingClientRect();
                const x = e.clientX - rect.left; 
                const y = e.clientY - rect.top;  
                const centerX = rect.width / 2;
                const centerY = rect.height / 2;
                const rotateX = ((y - centerY) / centerY) * -12;
                const rotateY = ((x - centerX) / centerX) * 12;
                card.style.transform = `rotateX(\${rotateX}deg) rotateY(\${rotateY}deg) translateY(-8px)`;
            });
            card.addEventListener('mouseleave', () => {
                card.style.transform = 'rotateX(0deg) rotateY(0deg) translateY(0px)';
            });
        });
    }

    function fetchCart() {
        fetch(ctx + '/api/v1/cart', { method: 'GET', headers: { 'Accept': 'application/json' } })
        .then(res => res.json())
        .then(res => { if (res.success && res.data) renderCartUI(res.data); })
        .catch(err => console.error('Error fetching cart:', err));
    }

    function addToCart(menuItemId) {
        const payload = new URLSearchParams();
        payload.append('menuItemId', menuItemId);
        payload.append('quantity', '1');

        fetch(ctx + '/api/v1/cart', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: payload
        })
        .then(res => res.json())
        .then(res => {
            if (res.success && res.data) {
                renderCartUI(res.data);
            } else if (res.error) {
                if (res.error.code === 'UNAUTHORIZED') {
                    window.location.href = ctx + '/login.jsp'; 
                } else {
                    alert(res.error.message || 'Failed to add item.');
                }
            }
        })
        .catch(err => console.error('Error adding to cart:', err));
    }

    function removeFromCart(menuItemId) {
        const payload = new URLSearchParams();
        payload.append('menuItemId', menuItemId);

        fetch(ctx + '/api/v1/cart', {
            method: 'DELETE',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: payload
        })
        .then(res => res.json())
        .then(res => { if (res.success && res.data) renderCartUI(res.data); })
        .catch(err => console.error('Error removing from cart:', err));
    }

    function renderCartUI(cartItems) {
        const container = document.getElementById('cart-items-container');
        const totalAmount = document.getElementById('cart-total-amount');
        const modalTotalAmount = document.getElementById('modal-total-amount');
        const payBtn = document.getElementById('proceed-to-pay-btn');
        const cartCount = document.getElementById('cart-count');

        if (!cartItems || cartItems.length === 0) {
            container.innerHTML = `
                <div class="empty-cart-msg">
                    <p>Your cart is empty</p>
                    <small>Add items from the menu</small>
                </div>`;
            totalAmount.innerText = 'Rs. 0';
            modalTotalAmount.innerText = 'Rs. 0';
            cartCount.innerText = '0';
            payBtn.disabled = true;
            return;
        }

        let html = '';
        let grandTotal = 0;
        let totalItems = 0;

        cartItems.forEach(item => {
            const itemTotal = item.price * item.quantity;
            grandTotal += itemTotal;
            totalItems += item.quantity;

            const displayName = item.name ? item.name : ('Menu Item #' + item.menuItemId);

            html += `
                <div class="cart-item">
                    <div>
                        <strong style="color: var(--text-main); font-weight: 600;">\${displayName}</strong>
                        <div class="cart-row">Rs. \${item.price} x \${item.quantity}</div>
                    </div>
                    <div style="display: flex; align-items: center;">
                        <span style="color: var(--text-main); font-weight: 600;">Rs. \${itemTotal}</span>
                        <button onclick="removeFromCart(\${item.menuItemId})" style="margin-left:12px; color:var(--primary); background:none; border:none; font-size:1.2rem; cursor:pointer;">&times;</button>
                    </div>
                </div>`;
        });

        container.innerHTML = html;
        totalAmount.innerText = `Rs. \${grandTotal}`;
        modalTotalAmount.innerText = `Rs. \${grandTotal}`;
        cartCount.innerText = totalItems;
        payBtn.disabled = false;
    }

    function processPayment() {
        const address = document.getElementById('checkoutAddress').value.trim();
        const phone = document.getElementById('checkoutPhone').value.trim();
        const paymentMethod = document.getElementById('checkoutPaymentMethod').value;

        if (!address || !phone) {
            alert('Please fill in your delivery address and phone number.');
            return;
        }

        const confirmPayBtn = document.getElementById('confirm-pay-btn');
        confirmPayBtn.innerText = "Processing Securely...";
        confirmPayBtn.disabled = true;

        const payload = new URLSearchParams();
        payload.append('deliveryAddress', address);
        payload.append('customerPhone', phone);
        payload.append('paymentMethod', paymentMethod);

        fetch(ctx + '/api/v1/orders', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: payload
        })
        .then(res => res.json())
        .then(res => {
            if (res.success && res.data) {
                document.getElementById('paymentModal').classList.remove('active');
                document.getElementById('success-message').innerText = `Order #${res.data.orderId} placed successfully! Txn ID: ${res.data.transactionId}`;
                document.getElementById('successOverlay').classList.add('active');
                
                setTimeout(() => {
                    window.location.href = ctx + '/orders.jsp'; 
                }, 3500);
            } else {
                alert(res.error ? res.error.message : 'Checkout failed.');
                confirmPayBtn.disabled = false;
                confirmPayBtn.innerText = "Confirm & Pay";
            }
        })
        .catch(err => {
            alert('An unexpected error occurred during checkout.');
            confirmPayBtn.disabled = false;
            confirmPayBtn.innerText = "Confirm & Pay";
        });
    }
    </script>
</body>
</html>