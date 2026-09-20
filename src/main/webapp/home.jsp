<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page isELIgnored="true" %>
<%
    String userName = (String) session.getAttribute("userName");
    if (userName == null || userName.isEmpty()) userName = "Guest";
    String userRole = (String) session.getAttribute("userRole");
    boolean isOwner = "RESTAURANT_OWNER".equals(userRole);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Benedict Jerome Mart - Premium Online Food Order</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <style>
        /* ===== Hotel Filter Selector Bar ===== */
        .hotel-bar-container {
            display: flex;
            gap: 12px;
            overflow-x: auto;
            padding: 1rem 0;
            margin-bottom: 1.5rem;
            scrollbar-width: thin;
        }
        .hotel-chip {
            background: rgba(255, 255, 255, 0.04);
            border: 1px solid var(--border-glass);
            border-radius: 24px;
            padding: 10px 20px;
            color: var(--text-main);
            white-space: nowrap;
            cursor: pointer;
            font-size: 0.9rem;
            font-weight: 600;
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        .hotel-chip:hover, .hotel-chip.active {
            background: linear-gradient(135deg, #f59e0b, #ef4444);
            color: #fff;
            border-color: transparent;
            box-shadow: 0 4px 15px rgba(245, 158, 11, 0.4);
        }

        /* ===== Category Filter Pills ===== */
        .category-bar {
            display: flex;
            gap: 8px;
            flex-wrap: wrap;
            margin-bottom: 1.5rem;
        }
        .cat-pill {
            background: rgba(255, 255, 255, 0.03);
            border: 1px solid var(--border-glass);
            color: var(--text-muted);
            padding: 8px 16px;
            border-radius: 18px;
            font-size: 0.85rem;
            font-weight: 500;
            cursor: pointer;
            transition: all 0.2s ease;
        }
        .cat-pill:hover, .cat-pill.active {
            background: rgba(255, 255, 255, 0.12);
            color: var(--accent-gold);
            border-color: var(--accent-gold);
        }

        /* ===== Dynamic Menu Grid & Card Tilt ===== */
        .menu-grid-dynamic {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(260px, 1fr));
            gap: 1.5rem;
        }
        .food-card-dynamic {
            background: rgba(255, 255, 255, 0.03);
            border: 1px solid var(--border-glass);
            border-radius: 16px;
            overflow: hidden;
            backdrop-filter: blur(16px);
            transition: transform 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275), box-shadow 0.3s ease;
            will-change: transform;
            perspective: 1000px;
        }
        .food-card-dynamic:hover {
            transform: translateY(-8px) scale(1.02);
            box-shadow: 0 16px 35px rgba(0,0,0,0.4);
            border-color: rgba(245, 158, 11, 0.5);
        }
        .food-img-frame {
            width: 100%;
            height: 160px;
            object-fit: cover;
            background: #1a1921;
        }
        .food-card-content {
            padding: 1.2rem;
        }

        /* ===== Pagination Control ===== */
        .pagination-container {
            display: flex;
            justify-content: center;
            align-items: center;
            gap: 12px;
            margin-top: 2rem;
        }

        /* ===== Order Receipt Confirmation Overlay ===== */
        .receipt-box {
            background: #0e0d14;
            border: 1px solid var(--accent-gold);
            border-radius: 20px;
            padding: 2rem;
            max-width: 500px;
            width: 90%;
            text-align: center;
            box-shadow: 0 20px 50px rgba(0,0,0,0.8);
            position: relative;
        }
    </style>
</head>
<body>
    <!-- Navbar -->
    <nav class="navbar">
        <a href="${pageContext.request.contextPath}/home.jsp" class="brand">
            <div class="brand-icon">B</div>
            Benedict Jerome Mart
        </a>
        <div class="nav-right">
            <% if(session.getAttribute("userId") != null) { %>
                <div class="welcome-badge">
                    <span class="welcome-avatar"><%= session.getAttribute("userName").toString().substring(0,1).toUpperCase() %></span>
                    Hi, <%= session.getAttribute("userName") %>
                </div>
                <a href="${pageContext.request.contextPath}/orders.jsp" class="btn-outline-sm">My Orders History</a>
                <% if(isOwner) { %>
                    <a href="${pageContext.request.contextPath}/owner-dashboard.jsp" class="btn-outline-sm" style="border-color:var(--accent-gold); color:var(--accent-gold);">Hotel Owner Dashboard</a>
                <% } %>
                <a href="${pageContext.request.contextPath}/logout" class="btn-outline-sm">Logout</a>
            <% } else { %>
                <a href="${pageContext.request.contextPath}/login.jsp" class="btn-outline-sm">Login</a>
                <a href="${pageContext.request.contextPath}/register.jsp" class="btn-primary" style="padding: 8px 16px; border-radius: 8px; text-decoration: none;">Register</a>
            <% } %>
        </div>
    </nav>

    <!-- Hero Banner -->
    <div class="hero-banner">
        <div class="hero-content">
            <div class="hero-tag">🌟 100+ Authentic Dishes & Partner Hotels</div>
            <h1>Craving Delicious Food?<br><span class="hero-name">Fast & Smooth Delivery</span></h1>
            <p class="hero-sub">Choose your favorite nearby partner hotel & get fresh food delivered to your doorstep.</p>
        </div>
        <div class="hero-art">🍕🍔Biryani 🍛🍹</div>
    </div>

    <!-- Main Container -->
    <div class="main-layout">
        <div>
            <!-- Hotel Selection Bar -->
            <div style="margin-bottom: 0.5rem;">
                <h3 style="color: var(--text-main); font-weight: 700; margin-bottom: 8px;">🏨 Select Partner Hotel / Restaurant</h3>
                <div class="hotel-bar-container" id="hotel-selector">
                    <button class="hotel-chip active" onclick="selectHotel(0, this)">
                        <span>🏬</span> All Hotels (100+ Dishes)
                    </button>
                    <!-- Partner hotels populated dynamically via JS -->
                </div>
            </div>

            <!-- Search & Category Filters -->
            <div style="display: flex; justify-content: space-between; align-items: center; gap: 1rem; flex-wrap: wrap; margin-bottom: 1rem;">
                <div class="category-bar" id="category-selector">
                    <button class="cat-pill active" onclick="selectCategory('all', this)">All Categories</button>
                    <button class="cat-pill" onclick="selectCategory('Mains', this)">Main Course</button>
                    <button class="cat-pill" onclick="selectCategory('Starters', this)">Starters</button>
                    <button class="cat-pill" onclick="selectCategory('Biryani', this)">Biryani & Rice</button>
                    <button class="cat-pill" onclick="selectCategory('Pizza', this)">Pizzas & Burgers</button>
                    <button class="cat-pill" onclick="selectCategory('Noodles', this)">Chinese & Noodles</button>
                    <button class="cat-pill" onclick="selectCategory('South Indian', this)">South Indian</button>
                    <button class="cat-pill" onclick="selectCategory('Desserts', this)">Desserts</button>
                    <button class="cat-pill" onclick="selectCategory('Drinks', this)">Beverages</button>
                </div>

                <div style="position: relative; min-width: 220px;">
                    <input type="text" id="searchInput" onkeyup="handleSearch()" placeholder="🔍 Search 100+ dishes..." class="form-control" style="border-radius: 20px; padding: 8px 16px;">
                </div>
            </div>

            <!-- Dynamic Menu Grid -->
            <div class="menu-grid-dynamic" id="menu-grid">
                <p style="color: var(--text-muted); text-align: center; grid-column: 1/-1; padding: 3rem;">Loading 100+ dishes...</p>
            </div>

            <!-- Pagination Controls -->
            <div class="pagination-container" id="pagination-controls"></div>
        </div>

        <!-- Floating Cart Panel -->
        <div class="cart-panel">
            <h3 class="section-title" style="display: flex; justify-content: space-between; align-items: center;">
                <span>🛒 Your Cart</span>
                <span class="cart-badge" id="cart-count">0</span>
            </h3>
            
            <div id="cart-items-container">
                <div class="empty-cart-msg">
                    <p>Your cart is empty</p>
                    <small>Select dishes from your favorite hotel</small>
                </div>
            </div>
            
            <div class="cart-total" style="border-top: 1px dashed var(--border-glass); padding-top: 1rem; margin-top: 1rem;">
                <span style="font-weight: 600;">Subtotal</span>
                <span id="cart-total-amount" style="font-weight: 800; color: var(--accent-gold); font-size: 1.2rem;">Rs. 0</span>
            </div>
            
            <button id="proceed-to-pay-btn" class="btn btn-primary" disabled style="width: 100%; margin-top: 1rem;">
                Proceed to Checkout
            </button>
        </div>
    </div>

    <!-- MULTI-STEP CHECKOUT & PAYMENT MODAL -->
    <div class="modal-overlay" id="paymentModal">
        <div class="modal" style="max-width: 480px;">
            <div class="modal-header">
                <h2>💳 Checkout & Secure Payment</h2>
                <button class="modal-close" id="closePaymentModal">&times;</button>
            </div>
            
            <div class="payment-total-banner">
                <span>Total Amount to Pay</span>
                <strong id="modal-total-amount">Rs. 0</strong>
            </div>
            
            <div class="form-group" style="margin-top: 1.2rem;">
                <label style="color: var(--text-main); font-size: 0.9rem; font-weight: 600;">📍 Delivery Address</label>
                <input type="text" id="checkoutAddress" class="form-control" placeholder="Door No, Street Name, City, Pincode" required>
            </div>
            <div class="form-group">
                <label style="color: var(--text-main); font-size: 0.9rem; font-weight: 600;">📞 Contact Phone Number</label>
                <input type="tel" id="checkoutPhone" class="form-control" placeholder="10-digit mobile number" required>
            </div>
            <div class="form-group">
                <label style="color: var(--text-main); font-size: 0.9rem; font-weight: 600;">💳 Select Payment Method</label>
                <select id="checkoutPaymentMethod" class="form-control" style="background: #0a090e; color: #fff;">
                    <option value="UPI">⚡ Instant UPI (Google Pay, PhonePe, Paytm)</option>
                    <option value="CARD">💳 Credit / Debit Card</option>
                    <option value="NET_BANKING">🏛️ Net Banking</option>
                    <option value="COD">💵 Cash on Delivery (COD)</option>
                </select>
            </div>

            <button class="btn btn-primary" id="confirm-pay-btn" onclick="processPayment()" style="width: 100%; margin-top: 1.2rem;">
                Confirm Order & Pay
            </button>
        </div>
    </div>

    <!-- RECEIPT CONFIRMATION OVERLAY -->
    <div class="success-overlay" id="successOverlay">
        <div class="receipt-box">
            <div style="font-size: 3.5rem; margin-bottom: 0.5rem;">🎉</div>
            <h2 style="color: #fff; font-size: 1.8rem; font-weight: 800; margin-bottom: 0.5rem;">Order Confirmed!</h2>
            <p style="color: var(--text-muted); font-size: 0.95rem; margin-bottom: 1.5rem;">Your payment was verified and order sent to hotel kitchen.</p>

            <div style="background: rgba(255,255,255,0.04); border-radius: 12px; padding: 1rem; text-align: left; font-size: 0.9rem; margin-bottom: 1.5rem;">
                <div style="display:flex; justify-content:space-between; margin-bottom:6px;">
                    <span style="color:var(--text-muted);">Order ID:</span>
                    <strong style="color:var(--accent-gold);" id="rcpt-order-id">#000</strong>
                </div>
                <div style="display:flex; justify-content:space-between; margin-bottom:6px;">
                    <span style="color:var(--text-muted);">Txn ID:</span>
                    <code style="color:#fff;" id="rcpt-txn-id">TXN-0000</code>
                </div>
                <div style="display:flex; justify-content:space-between; margin-bottom:6px;">
                    <span style="color:var(--text-muted);">Estimated Delivery:</span>
                    <strong style="color:#10b981;">30 - 45 Mins</strong>
                </div>
            </div>

            <a href="${pageContext.request.contextPath}/orders.jsp" class="btn btn-primary" style="width: 100%; text-decoration: none; display: block; text-align: center;">
                Track Live Order Status &rarr;
            </a>
        </div>
    </div>

    <!-- AI Chat Assistant -->
    <button id="chatToggleBtn">💬</button>
    <div id="chatPanel">
        <div id="chatHeader">
            <span>AI Assistant</span>
            <button id="closeChatBtn">&times;</button>
        </div>
        <div id="chatMessages">
            <div class="chat-msg bot">Hi! I can update prices, mark items in stock, or add dishes to your cart. Ask me anything!</div>
        </div>
        <div id="chatInputRow">
            <input type="text" id="chatInput" placeholder="e.g. Set Butter Chicken price to 18.99...">
            <button id="chatSendBtn">Send</button>
        </div>
    </div>

    <script>
    const ctx = '${pageContext.request.contextPath}';
    let allMenuItems = [];
    let filteredItems = [];
    let selectedHotelId = 0;
    let selectedCategory = 'all';
    let currentPage = 1;
    const pageSize = 12;

    document.addEventListener('DOMContentLoaded', () => {
        fetchRestaurants();
        fetchMenuItems();
        fetchCart();

        document.getElementById('proceed-to-pay-btn').addEventListener('click', () => {
            document.getElementById('paymentModal').classList.add('active');
        });
        document.getElementById('closePaymentModal').addEventListener('click', () => {
            document.getElementById('paymentModal').classList.remove('active');
        });

        const chatToggleBtn = document.getElementById('chatToggleBtn');
        const chatPanel = document.getElementById('chatPanel');
        const closeChatBtn = document.getElementById('closeChatBtn');
        
        chatToggleBtn.addEventListener('click', () => chatPanel.classList.toggle('open'));
        closeChatBtn.addEventListener('click', () => chatPanel.classList.remove('open'));

        document.getElementById('chatSendBtn').addEventListener('click', sendChatMessage);
        document.getElementById('chatInput').addEventListener('keypress', (e) => {
            if(e.key === 'Enter') sendChatMessage();
        });
    });

    async function fetchRestaurants() {
        try {
            const res = await fetch(ctx + '/api/v1/restaurants');
            const result = await res.json();
            if (result.success && result.data) {
                const selector = document.getElementById('hotel-selector');
                let html = `
                    <button class="hotel-chip \${selectedHotelId === 0 ? 'active' : ''}" onclick="selectHotel(0, this)">
                        <span>🏬</span> All Hotels (100+ Dishes)
                    </button>`;
                result.data.forEach(r => {
                    html += `
                        <button class="hotel-chip \${selectedHotelId === r.id ? 'active' : ''}" onclick="selectHotel(\${r.id}, this)">
                            <span>🍽️</span> \${r.name} (\${r.cuisineType || 'Specialties'})
                        </button>`;
                });
                selector.innerHTML = html;
            }
        } catch(e) { console.error('Error fetching restaurants:', e); }
    }

    async function fetchMenuItems() {
        try {
            let url = ctx + '/api/v1/menu-items';
            if (selectedHotelId > 0) url += '?restaurantId=' + selectedHotelId;

            const res = await fetch(url);
            const result = await res.json();

            if (result.success && result.data) {
                allMenuItems = result.data;
                applyFilters();
            }
        } catch(e) { console.error('Error fetching menu items:', e); }
    }

    function selectHotel(hotelId, btn) {
        selectedHotelId = hotelId;
        document.querySelectorAll('.hotel-chip').forEach(b => b.classList.remove('active'));
        btn.classList.add('active');
        currentPage = 1;
        fetchMenuItems();
    }

    function selectCategory(cat, btn) {
        selectedCategory = cat;
        document.querySelectorAll('.cat-pill').forEach(b => b.classList.remove('active'));
        btn.classList.add('active');
        currentPage = 1;
        applyFilters();
    }

    function handleSearch() {
        currentPage = 1;
        applyFilters();
    }

    function applyFilters() {
        const query = document.getElementById('searchInput').value.toLowerCase().trim();
        filteredItems = allMenuItems.filter(item => {
            const matchCat = (selectedCategory === 'all') || 
                             (item.category && item.category.equalsIgnoreCase ? item.category.equalsIgnoreCase(selectedCategory) : item.category == selectedCategory);
            const matchQuery = !query || 
                               (item.name && item.name.toLowerCase().includes(query)) || 
                               (item.description && item.description.toLowerCase().includes(query));
            return matchCat && matchQuery;
        });

        renderGrid();
    }

    function renderGrid() {
        const grid = document.getElementById('menu-grid');
        const pagination = document.getElementById('pagination-controls');

        if (!filteredItems || filteredItems.length === 0) {
            grid.innerHTML = `<p style="color: var(--text-muted); text-align: center; grid-column: 1/-1; padding: 3rem;">No dishes found matching your selection.</p>`;
            pagination.innerHTML = '';
            return;
        }

        const totalPages = Math.ceil(filteredItems.length / pageSize);
        if (currentPage > totalPages) currentPage = 1;

        const start = (currentPage - 1) * pageSize;
        const pageItems = filteredItems.slice(start, start + pageSize);

        let html = '';
        pageItems.forEach(item => {
            const img = item.imageUrl || 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=500&q=80';
            const priceFormatted = parseFloat(item.price).toFixed(2);

            html += `
                <div class="food-card-dynamic">
                    <img src="\${img}" alt="\${item.name}" class="food-img-frame" onerror="this.src='https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=500&q=80'">
                    <div class="food-card-content">
                        <div style="display:flex; justify-content:space-between; align-items:flex-start; margin-bottom:6px;">
                            <span class="category-badge" style="position:static;">\${item.category || 'Specialty'}</span>
                            <span style="color: var(--accent-gold); font-weight: 800; font-size: 1.1rem;">Rs. \${priceFormatted}</span>
                        </div>
                        <h4 style="color: #fff; font-size: 1.1rem; font-weight: 700; margin-bottom: 4px;">\${item.name}</h4>
                        <p style="color: var(--text-muted); font-size: 0.82rem; margin-bottom: 12px; height: 36px; overflow: hidden; text-overflow: ellipsis;">\${item.description || 'Delicious gourmet creation cooked fresh to order.'}</p>
                        <button class="btn-add" onclick="addToCart(\${item.id})" style="width: 100%;">Add to Cart</button>
                    </div>
                </div>
            `;
        });
        grid.innerHTML = html;

        // Render Pagination Buttons
        if (totalPages > 1) {
            let pagHtml = `<button onclick="changePage(-1)" class="btn-outline-sm" \${currentPage === 1 ? 'disabled' : ''}>&laquo; Prev</button>`;
            pagHtml += `<span style="color: var(--text-muted); font-size: 0.9rem;">Page <strong>\${currentPage}</strong> of <strong>\${totalPages}</strong> (\${filteredItems.length} items)</span>`;
            pagHtml += `<button onclick="changePage(1)" class="btn-outline-sm" \${currentPage === totalPages ? 'disabled' : ''}>Next &raquo;</button>`;
            pagination.innerHTML = pagHtml;
        } else {
            pagination.innerHTML = '';
        }
    }

    function changePage(delta) {
        currentPage += delta;
        renderGrid();
        window.scrollTo({ top: document.getElementById('menu-grid').offsetTop - 100, behavior: 'smooth' });
    }

    function fetchCart() {
        fetch(ctx + '/api/v1/cart')
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
            } else if (res.error && res.error.code === 'UNAUTHORIZED') {
                window.location.href = ctx + '/login.jsp';
            } else {
                alert(res.error ? res.error.message : 'Error adding item');
            }
        });
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
        .then(res => { if (res.success && res.data) renderCartUI(res.data); });
    }

    function renderCartUI(cartItems) {
        const container = document.getElementById('cart-items-container');
        const totalAmount = document.getElementById('cart-total-amount');
        const modalTotalAmount = document.getElementById('modal-total-amount');
        const payBtn = document.getElementById('proceed-to-pay-btn');
        const cartCount = document.getElementById('cart-count');

        if (!cartItems || cartItems.length === 0) {
            container.innerHTML = `<div class="empty-cart-msg"><p>Your cart is empty</p><small>Select dishes from menu</small></div>`;
            totalAmount.innerText = 'Rs. 0';
            modalTotalAmount.innerText = 'Rs. 0';
            cartCount.innerText = '0';
            payBtn.disabled = true;
            return;
        }

        let html = '';
        let grandTotal = 0;
        let totalQty = 0;

        cartItems.forEach(item => {
            const itemTotal = (item.price || item.unitPrice || 0) * item.quantity;
            grandTotal += itemTotal;
            totalQty += item.quantity;

            html += `
                <div class="cart-item" style="display:flex; justify-content:space-between; align-items:center; padding: 10px 0; border-bottom:1px solid var(--border-glass);">
                    <div>
                        <strong style="color: #fff; font-size: 0.95rem;">\${item.name || ('Dish #' + item.menuItemId)}</strong>
                        <div style="font-size: 0.82rem; color: var(--text-muted);">Rs. \${item.price || item.unitPrice} x \${item.quantity}</div>
                    </div>
                    <div style="display:flex; align-items:center; gap:8px;">
                        <span style="color: var(--accent-gold); font-weight: 700;">Rs. \${itemTotal.toFixed(2)}</span>
                        <button onclick="removeFromCart(\${item.menuItemId})" style="color:#ef4444; background:none; border:none; font-size:1.2rem; cursor:pointer;">&times;</button>
                    </div>
                </div>`;
        });

        container.innerHTML = html;
        totalAmount.innerText = `Rs. \${grandTotal.toFixed(2)}`;
        modalTotalAmount.innerText = `Rs. \${grandTotal.toFixed(2)}`;
        cartCount.innerText = totalQty;
        payBtn.disabled = false;
    }

    async function processPayment() {
        const address = document.getElementById('checkoutAddress').value.trim();
        const phone = document.getElementById('checkoutPhone').value.trim();
        const paymentMethod = document.getElementById('checkoutPaymentMethod').value;

        if (!address || !phone) {
            alert('Please enter your delivery address and phone number.');
            return;
        }

        const confirmBtn = document.getElementById('confirm-pay-btn');
        confirmBtn.innerText = 'Verifying & Processing Payment...';
        confirmBtn.disabled = true;

        const payload = new URLSearchParams();
        payload.append('deliveryAddress', address);
        payload.append('customerPhone', phone);
        payload.append('paymentMethod', paymentMethod);

        try {
            const res = await fetch(ctx + '/api/v1/orders', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: payload
            });
            const result = await res.json();

            if (result.success && result.data) {
                document.getElementById('paymentModal').classList.remove('active');
                document.getElementById('rcpt-order-id').innerText = '#' + result.data.orderId;
                document.getElementById('rcpt-txn-id').innerText = result.data.transactionId;
                document.getElementById('successOverlay').classList.add('active');
            } else {
                alert(result.error ? result.error.message : 'Checkout failed.');
                confirmBtn.disabled = false;
                confirmBtn.innerText = 'Confirm Order & Pay';
            }
        } catch(err) {
            alert('An error occurred during checkout.');
            confirmBtn.disabled = false;
            confirmBtn.innerText = 'Confirm Order & Pay';
        }
    }

    async function sendChatMessage() {
        const input = document.getElementById('chatInput');
        const msg = input.value.trim();
        if (!msg) return;

        const messagesContainer = document.getElementById('chatMessages');
        messagesContainer.innerHTML += `<div class="chat-msg user">\${msg}</div>`;
        input.value = '';
        messagesContainer.scrollTop = messagesContainer.scrollHeight;

        try {
            const payload = new URLSearchParams();
            payload.append('message', msg);

            const res = await fetch(ctx + '/api/chat', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: payload
            });
            const result = await res.json();

            const replyText = result.reply || (result.data ? result.data.reply : 'Response received.');
            messagesContainer.innerHTML += `<div class="chat-msg bot">\${replyText}</div>`;
            messagesContainer.scrollTop = messagesContainer.scrollHeight;

            if (replyText.includes('Live DB Confirmed') || replyText.includes('Added')) {
                fetchMenuItems();
                fetchCart();
            }
        } catch(e) {
            messagesContainer.innerHTML += `<div class="chat-msg bot">Sorry, having trouble answering right now.</div>`;
        }
    }
    </script>
</body>
</html>