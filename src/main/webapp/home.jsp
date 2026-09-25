<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page isELIgnored="true" %>
<%
    String userName = (String) session.getAttribute("userName");
    if (userName == null || userName.isEmpty()) userName = "Guest";
    String firstName = userName.contains(" ") ? userName.split(" ")[0] : userName;
    String userRole = (String) session.getAttribute("userRole");
    boolean isOwner = "RESTAURANT_OWNER".equals(userRole);
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>BenedictJeromeMart - Home</title>
    <meta name="description" content="Order delicious food online from BenedictJeromeMart">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
</head>
<body>

<!-- =========================================================
     WELCOME TOAST
     ========================================================= -->
<div id="welcomeToast">
    <span class="toast-emoji">👋</span>
    <span>
        Welcome back, <%= firstName %>!
        Let's find something tasty.
    </span>
</div>

<!-- =========================================================
     NAVBAR
     ========================================================= -->
<header class="navbar">
    <a href="#" class="brand">
        <div class="brand-icon">🛒</div>
        BenedictJeromeMart
    </a>
    <div class="nav-right">
        <a href="orders.jsp" class="btn btn-outline-sm">My Orders</a>
        <% if (isOwner) { %>
        <a href="manage-menu.jsp" class="btn btn-outline-sm">Manage Menu</a>
        <% } %>
        <div class="welcome-badge">
            <span class="welcome-avatar"><%= firstName.charAt(0) %></span>
            Hey, <strong><%= firstName %></strong>! 👋
        </div>
        <a href="#" onclick="doLogout(); return false;" class="btn btn-outline-sm">🚪 Logout</a>
    </div>
</header>

<!-- =========================================================
     HERO BANNER
     ========================================================= -->
<section class="hero-banner">
    <div class="hero-content">
        <p class="hero-tag">🍽️ Fresh &amp; Delicious</p>
        <h1>Welcome back, <span class="hero-name"><%= firstName %></span>!</h1>
        <p class="hero-sub">What are you craving today? Pick your favourite and we'll get it to you!</p>
    </div>
    <div class="hero-art">🍕🍔🍜🥗🍛🥤</div>
</section>

<!-- =========================================================
     CATEGORY TABS
     ========================================================= -->
<div class="category-section">
    <div class="category-tabs" id="categoryTabs">
        <button class="category-tab active" onclick="filterByCategory('all')" data-cat="all" id="tab-all">
            🍽️ All
        </button>
    </div>
</div>

<!-- =========================================================
     MAIN LAYOUT
     ========================================================= -->
<main class="main-layout">

    <!-- =====================================================
         MENU SECTION
         ==================================================== -->
    <section>
        <!-- ZOMATO STYLE AI ASSISTANT -->
        <div class="ai-assistant-card">
            <div class="ai-header">
                <div class="ai-avatar">✨</div>
                <div>
                    <strong style="font-size:1.15rem;display:block;">Zomato-Style Food AI</strong>
                    <span style="font-size:0.85rem;color:var(--text-muted);">Ask for recommendations based on taste, budget, or dietary needs!</span>
                </div>
            </div>
            <div class="ai-input-wrapper">
                <input type="text" id="aiQuery" class="ai-input" placeholder="e.g. Cheesy burger under Rs. 250 or Spicy North Indian...">
                <button onclick="askAI()" class="btn btn-outline-sm">Search AI</button>
            </div>
            <div class="ai-quick-prompts">
                <span class="ai-chip" onclick="quickSearch('Cheesy & Juicy')">🧀 Cheesy &amp; Juicy</span>
                <span class="ai-chip" onclick="quickSearch('Spicy')">🌶️ Spicy Feasts</span>
                <span class="ai-chip" onclick="quickSearch('Under 250')">💰 Under Rs. 250</span>
                <span class="ai-chip" onclick="quickSearch('Desserts')">🍰 Sweet Cravings</span>
            </div>
        </div>

        <!-- MENU TITLE -->
        <h2 class="section-title">
            <span id="sectionEmoji">🔥</span>
            <span id="sectionLabel">Explore Delicious Menu</span>
        </h2>

        <!-- MENU LIST -->
        <div id="menuList" class="menu-grid">
            <div class="loading-spinner">
                <div class="spinner"></div>
                <p>Loading mouth-watering food...</p>
            </div>
        </div>
    </section>

    <!-- =====================================================
         CART PANEL
         ==================================================== -->
    <aside>
        <div class="cart-panel">
            <h2 class="section-title" style="font-size:1.2rem;">
                🛒 Your Cart
                <span class="cart-badge" id="cartBadge" style="display:none;">0</span>
            </h2>
            <div id="cartItems">
                <div class="empty-cart-msg">
                    <span style="font-size:2.5rem;">🛒</span>
                    <p>Your cart is empty</p>
                    <small>Add items from the menu</small>
                </div>
            </div>

            <!-- PRICE BREAKDOWN -->
            <div class="cart-summary" id="cartSummary" style="display:none;">
                <div class="cart-row">
                    <span>Subtotal</span>
                    <span id="cartSubtotal">Rs. 0.00</span>
                </div>
                <div class="cart-row">
                    <span>GST (5%)</span>
                    <span id="cartTax">Rs. 0.00</span>
                </div>
                <div class="cart-row delivery-row">
                    <span>Delivery</span>
                    <span class="free-tag">FREE</span>
                </div>
                <div class="cart-total">
                    <span>Total</span>
                    <span id="cartTotal">Rs. 0.00</span>
                </div>
            </div>
            <button onclick="openPayment()" class="btn btn-primary" id="payBtn" disabled>💳 Proceed to Pay</button>
            <div id="message"></div>
        </div>
    </aside>
</main>

<!-- =========================================================
     PAYMENT MODAL
     ========================================================= -->
<div class="modal-overlay" id="paymentModal">
    <div class="modal">
        <div class="modal-header">
            <h2>💳 Payment</h2>
            <button onclick="closePayment()" class="modal-close" id="modalCloseBtn">✕</button>
        </div>
        <div class="payment-total-banner">
            <span>Order Total</span>
            <strong id="modalTotal">Rs. 0.00</strong>
        </div>
        <p style="font-size:0.85rem;color:var(--text-muted);margin-bottom:1rem;">Choose your payment method:</p>

        <!-- PAYMENT OPTIONS -->
        <div class="payment-options">
            <div class="payment-option selected" onclick="selectPayment('cash')" id="opt-cash">
                <div class="pay-icon">💵</div>
                <div class="pay-info">
                    <strong>Cash on Delivery</strong>
                    <p style="font-size: 0.8rem; color: var(--text-muted)">Pay when food arrives</p>
                </div>
                <div class="pay-check" id="check-cash">✓</div>
            </div>
            <div class="payment-option" onclick="selectPayment('upi')" id="opt-upi">
                <div class="pay-icon">📱</div>
                <div class="pay-info">
                    <strong>UPI Payment</strong>
                    <p style="font-size: 0.8rem; color: var(--text-muted)">GPay, PhonePe, Paytm</p>
                </div>
                <div class="pay-check" id="check-upi" style="display:none;">✓</div>
            </div>
            <div class="payment-option" onclick="selectPayment('card')" id="opt-card">
                <div class="pay-icon">💳</div>
                <div class="pay-info">
                    <strong>Card Payment</strong>
                    <p style="font-size: 0.8rem; color: var(--text-muted)">Debit / Credit Card</p>
                </div>
                <div class="pay-check" id="check-card" style="display:none;">✓</div>
            </div>
        </div>

        <!-- CASH DETAIL -->
        <div id="detail-cash" class="payment-detail">
            <div class="pay-detail-box">
                <span style="font-size:2rem;">🏍️</span>
                <div>
                    <strong>Pay on Delivery</strong>
                    <p style="font-size: 0.8rem;">Keep <span id="cashAmt" style="color:var(--primary);font-weight:700;">Rs. 0.00</span> ready when delivery arrives</p>
                </div>
            </div>
        </div>

        <!-- UPI DETAIL -->
        <div id="detail-upi" class="payment-detail" style="display:none;">
            <div class="upi-box">
                <div class="upi-qr" style="flex: 1; text-align: center;">
                    <div class="qr-placeholder">
                        <span style="font-size:3rem;">📱</span>
                        <p style="font-size: 0.8rem;">Scan QR Code</p>
                    </div>
                </div>
                <div class="upi-info" style="flex: 2;">
                    <p>UPI ID: <strong>benedictmart@upi</strong></p>
                    <p style="color:var(--text-muted);font-size:0.85rem;">Pay <span id="upiAmt" style="color:var(--primary);font-weight:700;">Rs. 0.00</span> to complete</p>
                </div>
            </div>
            <div class="form-group" style="margin-top:1rem;">
                <label>Enter Transaction ID (optional)</label>
                <input type="text" class="form-control" placeholder="e.g. GPay Ref: 123456" id="upiTxnId">
            </div>
        </div>

        <!-- CARD DETAIL -->
        <div id="detail-card" class="payment-detail" style="display:none;">
            <div class="card-preview" id="cardPreview">
                <div class="card-chip">💳</div>
                <div class="card-num-preview" id="cardNumPreview" style="font-family: monospace; font-size: 1.1rem; margin: 0.5rem 0;">•••• •••• •••• ••••</div>
                <div class="card-bottom" style="display: flex; justify-content: space-between; font-size: 0.8rem; text-transform: uppercase;">
                    <span id="cardNamePreview"><%= firstName.toUpperCase() %></span>
                    <span id="cardExpPreview">MM/YY</span>
                </div>
            </div>
            <div class="form-group">
                <label>Card Number</label>
                <input type="text" class="form-control" placeholder="1234 5678 9012 3456" maxlength="19" id="cardNum" oninput="formatCard(this)">
            </div>
            <div style="display:grid;grid-template-columns:1fr 1fr;gap:1rem;">
                <div class="form-group">
                    <label>Expiry</label>
                    <input type="text" class="form-control" placeholder="MM/YY" maxlength="5" id="cardExp" oninput="formatExpiry(this)">
                </div>
                <div class="form-group">
                    <label>CVV</label>
                    <input type="password" class="form-control" placeholder="•••" maxlength="3" id="cardCvv">
                </div>
            </div>
            <div class="form-group">
                <label>Name on Card</label>
                <input type="text" class="form-control" placeholder="<%= userName %>" id="cardName" oninput="document.getElementById('cardNamePreview').textContent = this.value.toUpperCase() || '<%= firstName.toUpperCase() %>'">
            </div>
        </div>

        <button onclick="confirmPayment()" class="btn btn-primary" id="confirmPayBtn" style="margin-top: 1rem;">✅ Confirm &amp; Place Order</button>
    </div>
</div>

<!-- =========================================================
     SUCCESS OVERLAY
     ========================================================= -->
<div class="success-overlay" id="successOverlay">
    <div class="success-box">
        <div class="success-icon">🎉</div>
        <h2>Order Placed!</h2>
        <p id="successMsg">Your order has been placed successfully!</p>
        <button onclick="closeSuccess()" class="btn btn-primary" style="width:auto;padding:0.75rem 2rem;margin-top:1rem;">Continue Shopping</button>
    </div>
</div>

<!-- =========================================================
     JAVASCRIPT
     ========================================================= -->
<script>
const ctx = '<%= request.getContextPath() %>';
let allItems = [];
let currentCategory = 'all';
let selectedPayment = 'cash';
let cartTotal = 0;
let currentCartItems = []; // Cached cart items for checkout payload

const categoryImages = {
    'burger': 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400&q=80',
    'pizza': 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=400&q=80',
    'biryani': 'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?w=400&q=80',
    'noodles': 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=400&q=80',
    'salad': 'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=400&q=80',
    'dessert': 'https://images.unsplash.com/photo-1607920592519-bab2a80efd77?w=400&q=80',
    'drink': 'https://images.unsplash.com/photo-1544145945-f90425340c7e?w=400&q=80',
    'starter': 'https://images.unsplash.com/photo-1574484284002-952d92456975?w=400&q=80',
    'mains': 'https://images.unsplash.com/photo-1589302168068-964664d93dc0?w=400&q=80',
    'chinese': 'https://images.unsplash.com/photo-1585032226651-759b368d7246?w=400&q=80',
    'indian': 'https://images.unsplash.com/photo-1603894584373-5ac82b2ae398?w=400&q=80',
    'default': 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400&q=80'
};

const categoryIcons = {
    'burger': '🍔', 'pizza': '🍕', 'biryani': '🍛', 'noodles': '🍜', 'salad': '🥗',
    'dessert': '🍰', 'desserts': '🍰', 'drink': '🥤', 'drinks': '🥤', 'beverages': '🥤',
    'starter': '🥟', 'starters': '🥟', 'mains': '🍛', 'main': '🍛', 'burgers': '🍔',
    'pizzas': '🍕', 'chinese': '🥡', 'indian': '🍲', 'default': '🍽️'
};

function getImage(item) {
    // 1. Check database image_url or imageUrl if provided and valid
    const dbImg = item.imageUrl || item.image_url;
    if (dbImg && typeof dbImg === 'string' && dbImg.trim() !== '') {
        return dbImg;
    }
    
    // 2. Specific fallbacks for items with empty DB image fields (IDs 1, 2, 3)
    const name = (item.name || '').toLowerCase();
    if (name.includes('paneer butter masala')) return 'https://images.unsplash.com/photo-1589302168068-964664d93dc0?w=400&q=80';
    if (name.includes('veg biryani')) return 'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?w=400&q=80';
    if (name.includes('gulab jamun')) return 'https://images.unsplash.com/photo-1607920592519-bab2a80efd77?w=400&q=80';

    // 3. Fallback based on category or name matching
    const cat = (item.category || '').toLowerCase();
    for (const key of Object.keys(categoryImages)) {
        if (cat.includes(key) || name.includes(key)) return categoryImages[key];
    }
    return categoryImages['default'];
}

function getIcon(cat) {
    if (!cat) return '🍽️';
    const c = cat.toLowerCase();
    return categoryIcons[c] || categoryIcons[c.replace(/s$/, '')] || '🍽️';
}

async function loadMenu() {
    try {
        const res = await fetch(ctx + '/api/v1/menu-items', { credentials: 'include' });
        if (!res.ok) throw new Error('HTTP ' + res.status);
        const result = await res.json();
        if (!result.data) throw new Error('No data');
        allItems = result.data;
        buildCategoryTabs(allItems);
        renderMenu(allItems);
    } catch (err) {
        console.error("Failed to load menu", err);
        document.getElementById('menuList').innerHTML = '<p style="color:var(--text-muted);grid-column:1/-1;text-align:center;padding:2rem;">⚠️ Could not load menu. Please refresh.</p>';
    }
}

function askAI() {
    const q = document.getElementById('aiQuery').value.trim().toLowerCase();
    if (!q) return;
    document.getElementById('sectionEmoji').textContent = '✨';
    document.getElementById('sectionLabel').textContent = 'AI Curated Recommendations';
    
    const filtered = allItems.filter(item => {
        const nameMatch = item.name.toLowerCase().includes(q);
        const descMatch = item.description && item.description.toLowerCase().includes(q);
        const catMatch = item.category && item.category.toLowerCase().includes(q);
        let priceMatch = true;
        if (q.includes('250') || q.includes('under 250')) priceMatch = item.price <= 250;
        if (q.includes('200') || q.includes('under 200')) priceMatch = item.price <= 200;
        return (nameMatch || descMatch || catMatch) && priceMatch;
    });
    
    renderMenu(filtered.length ? filtered : allItems);
}

function quickSearch(prompt) {
    document.getElementById('aiQuery').value = prompt;
    askAI();
}

function buildCategoryTabs(items) {
    const cats = [...new Set(items.map(i => i.category).filter(Boolean))];
    const container = document.getElementById('categoryTabs');
    cats.forEach(cat => {
        const btn = document.createElement('button');
        btn.className = 'category-tab';
        btn.dataset.cat = cat;
        btn.onclick = () => filterByCategory(cat);
        btn.innerHTML = getIcon(cat) + ' ' + cat;
        container.appendChild(btn);
    });
}

function filterByCategory(cat) {
    currentCategory = cat;
    document.querySelectorAll('.category-tab').forEach(b => b.classList.toggle('active', b.dataset.cat === cat));
    const filtered = cat === 'all' ? allItems : allItems.filter(i => i.category === cat);
    document.getElementById('sectionEmoji').textContent = cat === 'all' ? '🔥' : getIcon(cat);
    document.getElementById('sectionLabel').textContent = cat === 'all' ? 'Explore Delicious Menu' : cat;
    renderMenu(filtered);
}

function renderMenu(items) {
    const container = document.getElementById('menuList');
    container.innerHTML = '';
    
    if (!items || items.length === 0) {
        container.innerHTML = '<p style="color:var(--text-muted);grid-column:1/-1;text-align:center;padding:2rem;">No items match your query.</p>';
        return;
    }
    
    items.forEach(item => {
        const img = getImage(item);
        const card = document.createElement('div');
        card.className = 'menu-card';
        
        card.innerHTML = 
            '<div class="food-image-wrap">' +
                '<img src="' + img + '" alt="' + item.name + '" class="food-image" onerror="this.src=\'' + categoryImages['default'] + '\'">' +
                (item.category ? '<span class="category-badge">' + getIcon(item.category) + ' ' + item.category + '</span>' : '') +
            '</div>' +
            '<div class="menu-card-body">' +
                '<div class="menu-card-header">' +
                    '<span class="item-name">' + item.name + '</span>' +
                    '<span class="item-price">Rs.' + parseFloat(item.price).toFixed(0) + '</span>' +
                '</div>' +
                (item.description ? '<p class="item-desc">' + item.description + '</p>' : '') +
                '<button onclick="addToCart(' + item.id + ', this)" class="btn-add">+ Add to Cart</button>' +
            '</div>';
        
        container.appendChild(card);
    });
}

async function addToCart(menuItemId, btn) {
    btn.disabled = true;
    btn.textContent = 'Adding...';
    const formData = new URLSearchParams();
    formData.append('menuItemId', menuItemId);
    formData.append('quantity', 1);
    
    try {
        await fetch(ctx + '/api/v1/cart', { method: 'POST', body: formData, credentials: 'include' });
        await loadCart();
        btn.textContent = '✓ Added!';
        btn.style.background = '#16a34a';
        btn.style.color = '#fff';
        btn.style.borderColor = '#16a34a';
        setTimeout(() => {
            btn.disabled = false;
            btn.textContent = '+ Add to Cart';
            btn.style.background = '';
            btn.style.color = '';
            btn.style.borderColor = '';
        }, 1500);
    } catch (e) {
        btn.disabled = false;
        btn.textContent = '+ Add to Cart';
    }
}

async function loadCart() {
    try {
        const res = await fetch(ctx + '/api/v1/cart', { credentials: 'include' });
        const result = await res.json();
        const cartContainer = document.getElementById('cartItems');
        const payBtn = document.getElementById('payBtn');
        const cartSummary = document.getElementById('cartSummary');
        const cartBadge = document.getElementById('cartBadge');
        
        cartContainer.innerHTML = '';
        
        if (!result.data || !result.data.items || result.data.items.length === 0) {
            currentCartItems = [];
            cartContainer.innerHTML = 
                '<div class="empty-cart-msg">' +
                    '<span style="font-size:2.5rem;">🛒</span>' +
                    '<p>Your cart is empty</p>' +
                    '<small>Add items from the menu</small>' +
                '</div>';
            cartSummary.style.display = 'none';
            payBtn.disabled = true;
            cartBadge.style.display = 'none';
            cartTotal = 0;
            return;
        }
        
        currentCartItems = result.data.items;
        let subtotal = 0;
        let itemCount = 0;
        
        result.data.items.forEach(item => {
            const lineTotal = parseFloat(item.price) * item.quantity;
            subtotal += lineTotal;
            itemCount += item.quantity;
            
            const div = document.createElement('div');
            div.className = 'cart-item';
            div.innerHTML = 
                '<div>' +
                    '<strong style="display:block;font-size:0.9rem;">' + item.name + '</strong>' +
                    '<span style="font-size:0.78rem;color:var(--text-muted);">Rs.' + parseFloat(item.price).toFixed(0) + ' &times; ' + item.quantity + '</span>' +
                '</div>' +
                '<span style="font-weight:700;color:var(--primary);">Rs.' + lineTotal.toFixed(0) + '</span>';
            cartContainer.appendChild(div);
        });
        
        const tax = subtotal * 0.05;
        cartTotal = subtotal + tax;
        
        document.getElementById('cartSubtotal').textContent = 'Rs. ' + subtotal.toFixed(2);
        document.getElementById('cartTax').textContent = 'Rs. ' + tax.toFixed(2);
        document.getElementById('cartTotal').textContent = 'Rs. ' + cartTotal.toFixed(2);
        document.getElementById('modalTotal').textContent = 'Rs. ' + cartTotal.toFixed(2);
        document.getElementById('cashAmt').textContent = 'Rs. ' + cartTotal.toFixed(2);
        document.getElementById('upiAmt').textContent = 'Rs. ' + cartTotal.toFixed(2);
        
        cartBadge.textContent = itemCount;
        cartBadge.style.display = 'inline-block';
        cartSummary.style.display = 'block';
        payBtn.disabled = false;
    } catch (err) {
        console.error("Failed to load cart", err);
    }
}

function openPayment() {
    document.getElementById('paymentModal').classList.add('active');
    document.getElementById('modalTotal').textContent = 'Rs. ' + cartTotal.toFixed(2);
    document.getElementById('cashAmt').textContent = 'Rs. ' + cartTotal.toFixed(2);
    document.getElementById('upiAmt').textContent = 'Rs. ' + cartTotal.toFixed(2);
    selectPayment('cash');
}

function closePayment() {
    document.getElementById('paymentModal').classList.remove('active');
}

function selectPayment(type) {
    selectedPayment = type;
    ['cash', 'upi', 'card'].forEach(t => {
        const opt = document.getElementById('opt-' + t);
        const chk = document.getElementById('check-' + t);
        const det = document.getElementById('detail-' + t);
        const sel = t === type;
        opt.classList.toggle('selected', sel);
        chk.style.display = sel ? 'block' : 'none';
        det.style.display = sel ? 'block' : 'none';
    });
}

async function confirmPayment() {
    const btn = document.getElementById('confirmPayBtn');
    btn.disabled = true;
    btn.textContent = 'Processing...';
    
    try {
        const res = await fetch(ctx + '/api/orders', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            credentials: 'include',
            body: JSON.stringify({
                items: currentCartItems.map(item => ({
                    id: item.menuItemId,
                    quantity: item.quantity,
                    price: item.price
                })),
                total: cartTotal
            })
        });
        const result = await res.json();
        closePayment();
        
        if (result.success) {
            const payLabel = { cash: 'Cash on Delivery', upi: 'UPI', card: 'Card Payment' }[selectedPayment];
            document.getElementById('successMsg').innerHTML = 
                'Order <strong>#' + (result.orderId || '') + '</strong> confirmed!<br>' +
                '<small style="display:block;margin-top:0.5rem;color:var(--text-muted)">Payment: ' + payLabel + ' | Total: Rs.' + cartTotal.toFixed(2) + '</small>';
            document.getElementById('successOverlay').classList.add('active');
            loadCart();
        } else {
            const msg = document.getElementById('message');
            msg.className = 'alert-message alert-error';
            msg.textContent = (result.message) || 'Could not place order';
        }
    } catch (err) {
        closePayment();
        const msg = document.getElementById('message');
        msg.className = 'alert-message alert-error';
        msg.textContent = 'Connection failed. Please try again.';
    }
    
    btn.disabled = false;
    btn.innerHTML = '✅ Confirm &amp; Place Order';
}

function closeSuccess() {
    document.getElementById('successOverlay').classList.remove('active');
}

async function doLogout() {
    try { await fetch(ctx + '/api/v1/logout', { method: 'POST', credentials: 'include' }); } catch (e) { console.error('Logout request failed', e); }
    window.location.href = ctx + '/login.jsp';
}

function formatCard(input) {
    let v = input.value.replace(/\D/g, '').substring(0, 16);
    input.value = (v.match(/.{1,4}/g) || []).join(' ') || v;
    const padded = (v + '••••••••••••••••').substring(0, 16).match(/.{1,4}/g);
    document.getElementById('cardNumPreview').textContent = padded.join(' ');
}

function formatExpiry(input) {
    let v = input.value.replace(/\D/g, '').substring(0, 4);
    if (v.length >= 2) v = v.substring(0, 2) + '/' + v.substring(2);
    input.value = v;
    document.getElementById('cardExpPreview').textContent = v || 'MM/YY';
}

document.getElementById('paymentModal').addEventListener('click', function(e) {
    if (e.target === this) closePayment();
});

setTimeout(function() {
    const toast = document.getElementById('welcomeToast');
    if (toast) {
        toast.classList.add('hide');
        setTimeout(() => toast.remove(), 450);
    }
}, 4000);

loadMenu();
loadCart();
</script>
</body>
</html>