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
    <style>
        /* ===== Welcome toast animation ===== */
        @keyframes slideInWelcome {
            0%   { transform: translateX(120%); opacity: 0; }
            100% { transform: translateX(0);     opacity: 1; }
        }
        @keyframes fadeOutWelcome {
            0%   { transform: translateX(0);     opacity: 1; }
            100% { transform: translateX(120%); opacity: 0; }
        }
        #welcomeToast {
            position: fixed;
            top: 90px;
            right: 24px;
            z-index: 9999;
            background: linear-gradient(135deg, #ff7043, #ff5252);
            color: #fff;
            padding: 14px 22px;
            border-radius: 12px;
            box-shadow: 0 8px 24px rgba(0,0,0,0.18);
            display: flex;
            align-items: center;
            gap: 10px;
            font-size: 0.95rem;
            font-weight: 600;
            animation: slideInWelcome 0.5s ease-out forwards;
        }
        #welcomeToast.hide {
            animation: fadeOutWelcome 0.4s ease-in forwards;
        }
        #welcomeToast .toast-emoji {
            font-size: 1.4rem;
            animation: wiggle 1.2s ease-in-out infinite;
        }
        @keyframes wiggle {
            0%, 100% { transform: rotate(0deg); }
            25%      { transform: rotate(-12deg); }
            75%      { transform: rotate(12deg); }
        }

        /* ===== Hero entrance animation ===== */
        @keyframes fadeSlideUp {
            0%   { opacity: 0; transform: translateY(24px); }
            100% { opacity: 1; transform: translateY(0); }
        }
        .hero-content > * {
            opacity: 0;
            animation: fadeSlideUp 0.6s ease-out forwards;
        }
        .hero-content .hero-tag  { animation-delay: 0.05s; }
        .hero-content h1         { animation-delay: 0.18s; }
        .hero-content .hero-sub  { animation-delay: 0.32s; }
        .hero-art {
            opacity: 0;
            animation: fadeSlideUp 0.7s ease-out forwards;
            animation-delay: 0.45s;
        }

        /* ===== Menu card entrance ===== */
        @keyframes cardPop {
            0%   { opacity: 0; transform: scale(0.94) translateY(10px); }
            100% { opacity: 1; transform: scale(1) translateY(0); }
        }
        .menu-card {
            animation: cardPop 0.4s ease-out forwards;
        }

        /* ===== AI Assistant widget ===== */
        #chatToggleBtn {
            position: fixed;
            bottom: 24px;
            right: 24px;
            width: 60px;
            height: 60px;
            border-radius: 50%;
            background: linear-gradient(135deg, #ff7043, #ff5252);
            color: #fff;
            border: none;
            font-size: 1.6rem;
            cursor: pointer;
            box-shadow: 0 8px 20px rgba(0,0,0,0.25);
            z-index: 9998;
            transition: transform 0.2s ease;
        }
        #chatToggleBtn:hover { transform: scale(1.08); }

        #chatPanel {
            position: fixed;
            bottom: 96px;
            right: 24px;
            width: 340px;
            max-height: 460px;
            background: #fff;
            border-radius: 14px;
            box-shadow: 0 12px 32px rgba(0,0,0,0.25);
            display: none;
            flex-direction: column;
            overflow: hidden;
            z-index: 9998;
        }
        #chatPanel.open { display: flex; }

        #chatHeader {
            background: linear-gradient(135deg, #ff7043, #ff5252);
            color: #fff;
            padding: 14px 16px;
            font-weight: 700;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        #chatHeader button {
            background: none;
            border: none;
            color: #fff;
            font-size: 1.1rem;
            cursor: pointer;
        }

        #chatMessages {
            flex: 1;
            overflow-y: auto;
            padding: 12px;
            display: flex;
            flex-direction: column;
            gap: 8px;
            max-height: 320px;
        }

        .chat-msg {
            padding: 8px 12px;
            border-radius: 10px;
            font-size: 0.85rem;
            line-height: 1.35;
            max-width: 85%;
        }
        .chat-msg.user {
            background: #ffe0d6;
            align-self: flex-end;
            color: #7a2e12;
        }
        .chat-msg.bot {
            background: #f1f1f1;
            align-self: flex-start;
            color: #222;
        }

        #chatInputRow {
            display: flex;
            border-top: 1px solid #eee;
            padding: 8px;
            gap: 6px;
        }
        #chatInput {
            flex: 1;
            padding: 8px 10px;
            border: 1px solid #ddd;
            border-radius: 8px;
            font-size: 0.85rem;
        }
        #chatSendBtn {
            background: #ff5252;
            color: #fff;
            border: none;
            border-radius: 8px;
            padding: 8px 14px;
            cursor: pointer;
            font-weight: 600;
        }
    </style>
</head>
<body>

<!-- ===== WELCOME TOAST ===== -->
<div id="welcomeToast">
    <span class="toast-emoji">👋</span>
    <span>Welcome back, <%= firstName %>! Let's find something tasty.</span>
</div>

<!-- ===== NAVBAR ===== -->
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
        <a href="#" onclick="doLogout(); return false;" class="btn btn-outline-sm">
            🚪 Logout
        </a>
    </div>
</header>

<!-- ===== HERO BANNER ===== -->
<section class="hero-banner">
    <div class="hero-content">
        <p class="hero-tag">🍽️ Fresh &amp; Delicious</p>
        <h1>Welcome back, <span class="hero-name"><%= firstName %></span>!</h1>
        <p class="hero-sub">What are you craving today? Pick your favourite and we'll get it to you!</p>
    </div>
    <div class="hero-art">🍕🍔🍜🥗🍛🥤</div>
</section>

<!-- ===== CATEGORY TABS ===== -->
<div class="category-section">
    <div class="category-tabs" id="categoryTabs">
        <button class="category-tab active" onclick="filterByCategory('all')" data-cat="all" id="tab-all">
            🍽️ All
        </button>
    </div>
</div>

<!-- ===== MAIN LAYOUT ===== -->
<main class="main-layout">

    <!-- Menu Section -->
    <section>
        <h2 class="section-title">
            <span id="sectionEmoji">🔥</span>
            <span id="sectionLabel">Explore Delicious Menu</span>
        </h2>
        <div id="menuList" class="menu-grid">
            <div class="loading-spinner">
                <div class="spinner"></div>
                <p>Loading menu...</p>
            </div>
        </div>
    </section>

    <!-- Cart Panel -->
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

            <!-- Price Breakdown -->
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

            <button onclick="openPayment()" class="btn btn-primary" id="payBtn" disabled>
                💳 Proceed to Pay
            </button>

            <div id="message"></div>
        </div>
    </aside>
</main>

<!-- ===== PAYMENT MODAL ===== -->
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

        <!-- Payment Options -->
        <div class="payment-options">
            <div class="payment-option selected" onclick="selectPayment('cash')" id="opt-cash">
                <div class="pay-icon">💵</div>
                <div class="pay-info">
                    <strong>Cash on Delivery</strong>
                    <p>Pay when food arrives</p>
                </div>
                <div class="pay-check" id="check-cash">✓</div>
            </div>
            <div class="payment-option" onclick="selectPayment('upi')" id="opt-upi">
                <div class="pay-icon">📱</div>
                <div class="pay-info">
                    <strong>UPI Payment</strong>
                    <p>GPay, PhonePe, Paytm</p>
                </div>
                <div class="pay-check" id="check-upi" style="display:none;">✓</div>
            </div>
            <div class="payment-option" onclick="selectPayment('card')" id="opt-card">
                <div class="pay-icon">💳</div>
                <div class="pay-info">
                    <strong>Card Payment</strong>
                    <p>Debit / Credit Card</p>
                </div>
                <div class="pay-check" id="check-card" style="display:none;">✓</div>
            </div>
        </div>

        <!-- Cash Detail -->
        <div id="detail-cash" class="payment-detail">
            <div class="pay-detail-box">
                <span style="font-size:2rem;">🏍️</span>
                <div>
                    <strong>Pay on Delivery</strong>
                    <p>Keep <span id="cashAmt" style="color:var(--primary);font-weight:700;">Rs. 0.00</span> ready when delivery arrives</p>
                </div>
            </div>
        </div>

        <!-- UPI Detail -->
        <div id="detail-upi" class="payment-detail" style="display:none;">
            <div class="upi-box">
                <div class="upi-qr">
                    <div class="qr-placeholder">
                        <span style="font-size:3rem;">📱</span>
                        <p>Scan QR Code</p>
                    </div>
                </div>
                <div class="upi-info">
                    <p>UPI ID: <strong>benedictmart@upi</strong></p>
                    <p style="color:var(--text-muted);font-size:0.85rem;">Pay <span id="upiAmt" style="color:var(--primary);font-weight:700;">Rs. 0.00</span> to complete</p>
                </div>
            </div>
            <div class="form-group" style="margin-top:1rem;">
                <label>Enter Transaction ID (optional)</label>
                <input type="text" class="form-control" placeholder="e.g. GPay Ref: 123456" id="upiTxnId">
            </div>
        </div>

        <!-- Card Detail -->
        <div id="detail-card" class="payment-detail" style="display:none;">
            <div class="card-preview" id="cardPreview">
                <div class="card-chip">💳</div>
                <div class="card-num-preview" id="cardNumPreview">•••• •••• •••• ••••</div>
                <div class="card-bottom">
                    <span id="cardNamePreview"><%= firstName.toUpperCase() %></span>
                    <span id="cardExpPreview">MM/YY</span>
                </div>
            </div>
            <div class="form-group">
                <label>Card Number</label>
                <input type="text" class="form-control" placeholder="1234 5678 9012 3456"
                    maxlength="19" id="cardNum" oninput="formatCard(this)">
            </div>
            <div style="display:grid;grid-template-columns:1fr 1fr;gap:1rem;">
                <div class="form-group">
                    <label>Expiry</label>
                    <input type="text" class="form-control" placeholder="MM/YY"
                        maxlength="5" id="cardExp" oninput="formatExpiry(this)">
                </div>
                <div class="form-group">
                    <label>CVV</label>
                    <input type="password" class="form-control" placeholder="•••"
                        maxlength="3" id="cardCvv">
                </div>
            </div>
            <div class="form-group">
                <label>Name on Card</label>
                <input type="text" class="form-control" placeholder="<%= userName %>"
                    id="cardName" oninput="document.getElementById('cardNamePreview').textContent = this.value.toUpperCase() || '<%= firstName.toUpperCase() %>'">
            </div>
        </div>

        <button onclick="confirmPayment()" class="btn btn-primary" id="confirmPayBtn">
            ✅ Confirm &amp; Place Order
        </button>
    </div>
</div>

<!-- ===== SUCCESS OVERLAY ===== -->
<div class="success-overlay" id="successOverlay">
    <div class="success-box">
        <div class="success-icon">🎉</div>
        <h2>Order Placed!</h2>
        <p id="successMsg">Your order has been placed successfully!</p>
        <button onclick="closeSuccess()" class="btn btn-primary" style="width:auto;padding:0.75rem 2rem;margin-top:1rem;">
            Continue Shopping
        </button>
    </div>
</div>

<!-- ===== AI ASSISTANT WIDGET ===== -->
<button id="chatToggleBtn" onclick="toggleChat()">💬</button>

<div id="chatPanel">
    <div id="chatHeader">
        <span>🤖 BenedictJeromeMart Assistant</span>
        <button onclick="toggleChat()">✕</button>
    </div>
    <div id="chatMessages">
        <div class="chat-msg bot">Hi! Ask me about our menu, orders, hours, or payments — or just name a dish and I'll tell you which shop has it.</div>
    </div>
    <div id="chatInputRow">
        <input type="text" id="chatInput" placeholder="Type a question..." maxlength="300"
            onkeydown="if(event.key==='Enter') sendChatMessage();">
        <button id="chatSendBtn" onclick="sendChatMessage()">Send</button>
    </div>
</div>

<script>
const ctx = '<%= request.getContextPath() %>';
let allItems = [];
let currentCategory = 'all';
let selectedPayment = 'cash';
let cartTotal = 0;

// High-resolution exact item match dictionary
const exactDishImages = {
    'chef special combo':    'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400&q=80',
    'kids meal combo':       'https://images.unsplash.com/photo-1565299585323-38d6b0865b47?w=400&q=80',
    'bombay sandwich':       'https://images.unsplash.com/photo-1528735602780-2552fd46c7af?w=400&q=80',
    'egg sandwich':          'https://images.unsplash.com/photo-1525351484163-7529414344d8?w=400&q=80',
    'paneer sandwich':       'https://images.unsplash.com/photo-1509722747041-616f39b57569?w=400&q=80',
    'chicken sandwich':      'https://images.unsplash.com/photo-1603064752734-4c48eff53d05?w=400&q=80',
    'grilled cheese sandwich':'https://images.unsplash.com/photo-1528736235302-52922df5c122?w=400&q=80',
    'veg sandwich':          'https://images.unsplash.com/photo-1539252554453-80ab65ce3586?w=400&q=80',
    'club sandwich':         'https://images.unsplash.com/photo-1567234669003-dce7a7a88821?w=400&q=80',
    'fish curry':            'https://images.unsplash.com/photo-1534422298391-e4f8c172dddb?w=400&q=80',
    'crab curry':            'https://images.unsplash.com/photo-1559742811-8228636d253b?w=400&q=80',
    'prawn tempura':         'https://images.unsplash.com/photo-1565680018434-b513d5e5fd47?w=400&q=80',
    'fish and chips':        'https://images.unsplash.com/photo-1579208030886-b937da0925dc?w=400&q=80',
    'fish tikka':            'https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?w=400&q=80',
    'grilled fish':          'https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?w=400&q=80',
    'prawn curry':           'https://images.unsplash.com/photo-1559847844-5315695dadae?w=400&q=80',
    'minestrone soup':       'https://images.unsplash.com/photo-1547592166-23ac45744acd?w=400&q=80',
    'bruschetta':            'https://images.unsplash.com/photo-1572695157366-5e585ab2b69f?w=400&q=80',
    'fettuccine alfredo':    'https://images.unsplash.com/photo-1645112411341-6c4fd023714a?w=400&q=80',
    'risotto':               'https://images.unsplash.com/photo-1633964913295-ceb43826e7c9?w=400&q=80',
    'penne arrabbiata':      'https://images.unsplash.com/photo-1621996346565-e3def6164286?w=400&q=80',
    'lasagna':               'https://images.unsplash.com/photo-1574894709920-11b28e7367e3?w=400&q=80',
    'spaghetti aglio olio':  'https://images.unsplash.com/photo-1551183053-bf91a1d81141?w=400&q=80',
    'kung pao chicken':      'https://images.unsplash.com/photo-1525755662778-989d0524087e?w=400&q=80',
    'honey chilli potato':   'https://images.unsplash.com/photo-1585032226651-759b368d7246?w=400&q=80',
    'sweet corn soup':       'https://images.unsplash.com/photo-1603105037880-880cd4edfb5d?w=400&q=80',
    'spring rolls':          'https://images.unsplash.com/photo-1541529086526-db283c563270?w=400&q=80',
    'fried rice':            'https://images.unsplash.com/photo-1603133872878-684f208fb84b?w=400&q=80',
    'chilli paneer':         'https://images.unsplash.com/photo-1567188040759-fb8a883dc6d8?w=400&q=80',
    'veg manchurian':        'https://images.unsplash.com/photo-1512058564366-18510be2db19?w=400&q=80',
    'aloo paratha':          'https://images.unsplash.com/photo-1763951718802-39ebd3a4f302?w=400&q=80',
    'kadai paneer':          'https://images.unsplash.com/photo-1631452180519-c014fe946bc7?w=400&q=80',
    'chole bhature':         'https://images.unsplash.com/photo-1626777552726-4a6b54c97e46?w=400&q=80',
    'rajma chawal':          'https://images.unsplash.com/photo-1546833998-877b37c2e5c4?w=400&q=80',
    'dal makhani':           'https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=400&q=80',
    'paneer butter masala':  'https://images.unsplash.com/photo-1631452180519-c014fe946bc7?w=400&q=80',
    'curd rice':             'https://images.unsplash.com/photo-1630383249896-424e482df921?w=400&q=80',
    'butter chicken':        'https://images.unsplash.com/photo-1588166524941-3bf61a9c41db?w=400&q=80',
    'pongal':                'https://images.unsplash.com/photo-1630383249896-424e482df921?w=400&q=80',
    'medu vada':             'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?w=400&q=80',
    'rava dosa':             'https://images.unsplash.com/photo-1668236543090-82eba5ee5976?w=400&q=80',
    'uttapam':               'https://images.unsplash.com/photo-1668236543090-82eba5ee5976?w=400&q=80',
    'idli sambar':           'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?w=400&q=80',
    'masala dosa':           'https://images.unsplash.com/photo-1668236543090-82eba5ee5976?w=400&q=80',
    'corn cheese balls':     'https://images.unsplash.com/photo-1541529086526-db283c563270?w=400&q=80',
    'fish fingers':          'https://images.unsplash.com/photo-1565680018434-b513d5e5fd47?w=400&q=80',
    'chilli chicken':        'https://images.unsplash.com/photo-1563245372-f21724e3856d?w=400&q=80',
    'paneer tikka':          'https://images.unsplash.com/photo-1599487488170-d11ec9c172f0?w=400&q=80',
    'chicken 65':            'https://images.unsplash.com/photo-1610057099443-fde8c4d50f91?w=400&q=80',
    'watermelon juice':      'https://images.unsplash.com/photo-1589733955941-5eeaf752f6dd?w=400&q=80',
    'masala chaas':          'https://images.unsplash.com/photo-1528740561666-dc2479dc08ab?w=400&q=80',
    'chocolate shake':       'https://images.unsplash.com/photo-1572490122747-3968b75cc699?w=400&q=80',
    'iced tea':              'https://images.unsplash.com/photo-1556679343-c7306c1976bc?w=400&q=80',
    'mango lassi':           'https://images.unsplash.com/photo-1528740561666-dc2479dc08ab?w=400&q=80',
    'fresh lime soda':       'https://images.unsplash.com/photo-1513558161293-cdaf765ed2fd?w=400&q=80',
    'cold coffee':           'https://images.unsplash.com/photo-1517701550927-30cf4ba1dba5?w=400&q=80',
    'fruit custard':         'https://images.unsplash.com/photo-1551024601-bec78aea704b?w=400&q=80',
    'tiramisu':              'https://images.unsplash.com/photo-1571877227200-a0d98ea607e9?w=400&q=80',
    'rasmalai':              'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?w=400&q=80',
    'gulab jamun':           'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=400&q=80',
    'ice cream sundae':      'https://images.unsplash.com/photo-1563805042-7684c019e1cb?w=400&q=80',
    'cheesecake':            'https://images.unsplash.com/photo-1533134242443-d4fd215305ad?w=400&q=80',
    'chocolate brownie':     'https://images.unsplash.com/photo-1606313564200-e75d5e30476c?w=400&q=80',
    'garden salad':          'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400&q=80',
    'quinoa salad':          'https://images.unsplash.com/photo-1505253716362-afaea1d3d1af?w=400&q=80',
    'chicken salad':         'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=400&q=80',
    'sprouts salad':         'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400&q=80',
    'fruit salad':           'https://images.unsplash.com/photo-1490474418585-ba9bad8fd0ea?w=400&q=80',
    'caesar salad':          'https://images.unsplash.com/photo-1550304943-4f24f54ddde9?w=400&q=80',
    'thai noodles':          'https://images.unsplash.com/photo-1552611052-33e04de081de?w=400&q=80',
    'greek salad':           'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=400&q=80',
    'singapore noodles':     'https://images.unsplash.com/photo-1617093727343-374698b1b08d?w=400&q=80',
    'egg noodles':           'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=400&q=80',
    'veg fried noodles':     'https://images.unsplash.com/photo-1585032226651-759b368d7246?w=400&q=80',
    'chicken noodles':       'https://images.unsplash.com/photo-1617093727343-374698b1b08d?w=400&q=80',
    'schezwan noodles':      'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=400&q=80',
    'hakka noodles':         'https://images.unsplash.com/photo-1585032226651-759b368d7246?w=400&q=80',
    'paneer biryani':        'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?w=400&q=80',
    'hyderabadi biryani':    'https://images.unsplash.com/photo-1589302168068-964664d93dc0?w=400&q=80',
    'prawn biryani':         'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?w=400&q=80',
    'egg biryani':           'https://images.unsplash.com/photo-1589302168068-964664d93dc0?w=400&q=80',
    'veg biryani':           'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?w=400&q=80',
    'mutton biryani':        'https://images.unsplash.com/photo-1589302168068-964664d93dc0?w=400&q=80',
    'chicken biryani':       'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?w=400&q=80',
    'four cheese pizza':     'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=400&q=80',
    'veggie supreme pizza':  'https://images.unsplash.com/photo-1574071318508-1cdbab80d002?w=400&q=80',
    'paneer tikka pizza':    'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=400&q=80',
    'bbq chicken pizza':     'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=400&q=80',
    'farmhouse pizza':       'https://images.unsplash.com/photo-1574071318508-1cdbab80d002?w=400&q=80',
    'pepperoni pizza':       'https://images.unsplash.com/photo-1628840042765-356cda07504e?w=400&q=80',
    'margherita pizza':      'https://images.unsplash.com/photo-1604382354936-07c5d9983bd3?w=400&q=80',
    'bbq bacon burger':      'https://images.unsplash.com/photo-1553979459-d2229ba7433b?w=400&q=80',
    'paneer tikka burger':   'https://images.unsplash.com/photo-1550547660-d9450f859349?w=400&q=80',
    'mushroom swiss burger': 'https://images.unsplash.com/photo-1586190848861-99aa4a171e90?w=400&q=80',
    'spicy chicken burger':  'https://images.unsplash.com/photo-1625813506062-0aeb1d7a094b?w=400&q=80',
    'veggie burger':         'https://images.unsplash.com/photo-1520072959219-c595dc870360?w=400&q=80',
    'double patty burger':   'https://images.unsplash.com/photo-1586190848861-99aa4a171e90?w=400&q=80',
    'classic cheese burger': 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400&q=80'
};

// Generic food bank keywords for matching thousands of dishes
const foodKeywordBank = {
    'biryani': 'https://images.unsplash.com/photo-1589302168068-964664d93dc0?w=400&q=80',
    'burger':  'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400&q=80',
    'pizza':   'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=400&q=80',
    'sandwich':'https://images.unsplash.com/photo-1553909489-cd47e0907980?w=400&q=80',
    'noodle':  'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=400&q=80',
    'pasta':   'https://images.unsplash.com/photo-1595295333158-4742f28fbd85?w=400&q=80',
    'salad':   'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400&q=80',
    'soup':    'https://images.unsplash.com/photo-1547592166-23ac45744acd?w=400&q=80',
    'curry':   'https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=400&q=80',
    'dosa':    'https://images.unsplash.com/photo-1668236543090-82eba5ee5976?w=400&q=80',
    'fish':    'https://images.unsplash.com/photo-1534422298391-e4f8c172dddb?w=400&q=80',
    'prawn':   'https://images.unsplash.com/photo-1565680018434-b513d5e5fd47?w=400&q=80',
    'cake':    'https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=400&q=80',
    'ice cream':'https://images.unsplash.com/photo-1570197788417-0e82375c9371?w=400&q=80',
    'juice':   'https://images.unsplash.com/photo-1613478223719-2ab802602423?w=400&q=80',
    'shake':   'https://images.unsplash.com/photo-1572490122747-3968b75cc699?w=400&q=80',
    'coffee':  'https://images.unsplash.com/photo-1541167760496-1628856ab772?w=400&q=80',
    'tea':     'https://images.unsplash.com/photo-1576092768241-dec231879fc3?w=400&q=80'
};

const categoryDefaultImages = {
    'burger':       'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400&q=80',
    'pizza':        'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=400&q=80',
    'biryani':      'https://images.unsplash.com/photo-1589302168068-964664d93dc0?w=400&q=80',
    'noodles':      'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=400&q=80',
    'salad':        'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400&q=80',
    'dessert':      'https://images.unsplash.com/photo-1551024601-bec78aea704b?w=400&q=80',
    'drink':        'https://images.unsplash.com/photo-1544145945-f90425340c7e?w=400&q=80',
    'starter':      'https://images.unsplash.com/photo-1617622141675-d3005b9d5e8a?w=400&q=80',
    'mains':        'https://images.unsplash.com/photo-1565557623262-b51c2513a641?w=400&q=80',
    'south indian': 'https://images.unsplash.com/photo-1630383249896-424e482df921?w=400&q=80',
    'north indian': 'https://images.unsplash.com/photo-1631452180519-c014fe946bc7?w=400&q=80',
    'chinese':      'https://images.unsplash.com/photo-1585032226651-759b368d7246?w=400&q=80',
    'italian':      'https://images.unsplash.com/photo-1595295333158-4742f28fbd85?w=400&q=80',
    'seafood':      'https://images.unsplash.com/photo-1615141982883-c7ad0e69fd62?w=400&q=80',
    'sandwich':     'https://images.unsplash.com/photo-1553909489-cd47e0907980?w=400&q=80',
    'default':      'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400&q=80'
};

const categoryIcons = {
    'burger': '🍔', 'pizza': '🍕', 'biryani': '🍛', 'noodles': '🍜',
    'salad': '🥗', 'dessert': '🍰', 'desserts': '🍰', 'drink': '🥤', 'drinks': '🥤',
    'starter': '🥟', 'starters': '🥟', 'mains': '🍛', 'main': '🍛',
    'burgers': '🍔', 'south indian': '🥘', 'north indian': '🍲', 'chinese': '🥡',
    'italian': '🍝', 'seafood': '🦐', 'sandwich': '🥪', 'sandwiches': '🥪',
    'default': '🍽️'
};

function hashString(str) {
    let hash = 0;
    for (let i = 0; i < str.length; i++) {
        hash = ((hash << 5) - hash) + str.charCodeAt(i);
        hash |= 0;
    }
    return Math.abs(hash);
}

function getImage(item) {
    if (item.imageUrl && item.imageUrl.startsWith('http')) return item.imageUrl;

    const name = (item.name || '').toLowerCase().trim();
    if (exactDishImages[name]) return exactDishImages[name];

    for (const [key, url] of Object.entries(foodKeywordBank)) {
        if (name.includes(key)) return url;
    }

    const cat = (item.category || '').toLowerCase();
    for (const [key, url] of Object.entries(categoryDefaultImages)) {
        if (cat.includes(key)) return url;
    }

    return categoryDefaultImages['default'];
}

function getIcon(cat) {
    if (!cat) return '🍽️';
    const c = cat.toLowerCase();
    return categoryIcons[c] || categoryIcons[c.replace(/s$/, '')] || '🍽️';
}

async function loadMenu() {
    try {
        const res = await fetch(ctx + '/api/v1/menu-items');
        if (!res.ok) throw new Error('HTTP ' + res.status);
        const result = await res.json();
        if (!result.data) throw new Error('No data');
        allItems = result.data;
        buildCategoryTabs(allItems);
        renderMenu(allItems);
    } catch (err) {
        console.error("Failed to load menu", err);
        document.getElementById('menuList').innerHTML =
            '<p style="color:var(--text-muted);grid-column:1/-1;text-align:center;padding:2rem;">⚠️ Could not load menu. Please refresh.</p>';
    }
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
    document.querySelectorAll('.category-tab').forEach(b =>
        b.classList.toggle('active', b.dataset.cat === cat));
    const filtered = cat === 'all' ? allItems : allItems.filter(i => i.category === cat);
    document.getElementById('sectionEmoji').textContent = cat === 'all' ? '🔥' : getIcon(cat);
    document.getElementById('sectionLabel').textContent = cat === 'all' ? 'Explore Delicious Menu' : cat;
    renderMenu(filtered);
}

function renderMenu(items) {
    const container = document.getElementById('menuList');
    container.innerHTML = '';
    if (!items || items.length === 0) {
        container.innerHTML = '<p style="color:var(--text-muted);grid-column:1/-1;text-align:center;padding:2rem;">No items in this category.</p>';
        return;
    }
    items.forEach((item, idx) => {
        const img = getImage(item);
        const fallback = categoryDefaultImages['default'];
        const card = document.createElement('div');
        card.className = 'menu-card';
        card.style.animationDelay = (idx * 0.05) + 's';
        card.innerHTML =
            '<div class="food-image-wrap">' +
                '<img src="' + img + '" alt="' + item.name + '" class="food-image" ' +
                    'onerror="this.onerror=null;this.src=\'' + fallback + '\';">' +
                (item.category ? '<span class="category-badge">' + getIcon(item.category) + ' ' + item.category + '</span>' : '') +
            '</div>' +
            '<div class="menu-card-body">' +
                '<div class="menu-card-header">' +
                    '<span class="item-name">' + item.name + '</span>' +
                    '<span class="item-price">Rs.' + parseFloat(item.price).toFixed(0) + '</span>' +
                '</div>' +
                (item.description ? '<p class="item-desc">' + item.description + '</p>' : '') +
                '<button onclick="addToCart(' + item.id + ', this)" class="btn btn-add">+ Add to Cart</button>' +
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
        await fetch(ctx + '/api/v1/cart', { method: 'POST', body: formData });
        await loadCart();
        btn.textContent = '✓ Added!';
        btn.style.background = 'linear-gradient(135deg,#22c55e,#16a34a)';
        setTimeout(() => {
            btn.disabled = false;
            btn.textContent = '+ Add to Cart';
            btn.style.background = '';
        }, 1500);
    } catch (e) {
        btn.disabled = false;
        btn.textContent = '+ Add to Cart';
    }
}

async function loadCart() {
    try {
        const res = await fetch(ctx + '/api/v1/cart');
        const result = await res.json();
        const cartContainer = document.getElementById('cartItems');
        const payBtn = document.getElementById('payBtn');
        const cartSummary = document.getElementById('cartSummary');
        const cartBadge = document.getElementById('cartBadge');
        cartContainer.innerHTML = '';

        if (!result.data || !result.data.items || result.data.items.length === 0) {
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
                    '<span style="font-size:0.78rem;color:var(--text-muted);">' +
                        'Rs.' + parseFloat(item.price).toFixed(0) + ' &times; ' + item.quantity +
                    '</span>' +
                '</div>' +
                '<span style="font-weight:700;color:var(--primary);">Rs.' + lineTotal.toFixed(0) + '</span>';
            cartContainer.appendChild(div);
        });

        const tax = subtotal * 0.05;
        cartTotal = subtotal + tax;

        document.getElementById('cartSubtotal').textContent = 'Rs. ' + subtotal.toFixed(2);
        document.getElementById('cartTax').textContent       = 'Rs. ' + tax.toFixed(2);
        document.getElementById('cartTotal').textContent     = 'Rs. ' + cartTotal.toFixed(2);
        document.getElementById('modalTotal').textContent    = 'Rs. ' + cartTotal.toFixed(2);
        document.getElementById('cashAmt').textContent       = 'Rs. ' + cartTotal.toFixed(2);
        document.getElementById('upiAmt').textContent        = 'Rs. ' + cartTotal.toFixed(2);

        cartBadge.textContent = itemCount;
        cartBadge.style.display = 'inline-flex';
        cartSummary.style.display = 'block';
        payBtn.disabled = false;
    } catch (err) {
        console.error("Failed to load cart", err);
    }
}

// ===== PAYMENT MODAL =====
function openPayment() {
    document.getElementById('paymentModal').classList.add('active');
    document.getElementById('modalTotal').textContent = 'Rs. ' + cartTotal.toFixed(2);
    document.getElementById('cashAmt').textContent    = 'Rs. ' + cartTotal.toFixed(2);
    document.getElementById('upiAmt').textContent     = 'Rs. ' + cartTotal.toFixed(2);
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
        chk.style.display = sel ? 'flex' : 'none';
        det.style.display = sel ? 'block' : 'none';
    });
}

async function confirmPayment() {
    const btn = document.getElementById('confirmPayBtn');
    btn.disabled = true;
    btn.innerHTML = '<span class="spinner-sm"></span> Processing...';

    try {
        const res = await fetch(ctx + '/api/v1/orders', { method: 'POST' });
        const result = await res.json();
        closePayment();

        if (result.success) {
            const payLabel = {cash:'Cash on Delivery', upi:'UPI', card:'Card Payment'}[selectedPayment];
            document.getElementById('successMsg').innerHTML =
                'Order <strong>#' + result.data.orderId + '</strong> confirmed!<br>' +
                '<small>Payment: ' + payLabel + ' | Total: Rs.' + cartTotal.toFixed(2) + '</small>';
            document.getElementById('successOverlay').classList.add('active');
            loadCart();
        } else {
            const msg = document.getElementById('message');
            msg.className = 'alert-message alert-error';
            msg.textContent = (result.error && result.error.message) || 'Could not place order';
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
    try {
        await fetch(ctx + '/api/v1/logout', { method: 'POST' });
    } catch (e) {
        console.error('Logout request failed', e);
    }
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
    if (v.length >= 2) v = v.substring(0,2) + '/' + v.substring(2);
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

function toggleChat() {
    document.getElementById('chatPanel').classList.toggle('open');
}

async function sendChatMessage() {
    const input = document.getElementById('chatInput');
    const message = input.value.trim();
    if (!message) return;

    const messagesDiv = document.getElementById('chatMessages');

    const userMsg = document.createElement('div');
    userMsg.className = 'chat-msg user';
    userMsg.textContent = message;
    messagesDiv.appendChild(userMsg);

    input.value = '';
    messagesDiv.scrollTop = messagesDiv.scrollHeight;

    const typingMsg = document.createElement('div');
    typingMsg.className = 'chat-msg bot';
    typingMsg.textContent = '...';
    messagesDiv.appendChild(typingMsg);
    messagesDiv.scrollTop = messagesDiv.scrollHeight;

    try {
        const formData = new URLSearchParams();
        formData.append('message', message);
        const res = await fetch(ctx + '/api/chat', { method: 'POST', body: formData });
        const result = await res.json();
        typingMsg.remove();
        
        const botMsg = document.createElement('div');
        botMsg.className = 'chat-msg bot';
        const replyText = result.reply || (result.data ? result.data.reply : null) || (result.error ? result.error.message : "I'm here to help with menu, orders, and restaurant questions!");
        botMsg.textContent = replyText;
        messagesDiv.appendChild(botMsg);
        messagesDiv.scrollTop = messagesDiv.scrollHeight;

        // Auto refresh menu or cart if AI executed a live DB command
        if (replyText.includes('Live DB Confirmed') || replyText.includes('price') || replyText.includes('stock')) {
            loadMenu();
        }
        if (replyText.includes('cart') || replyText.includes('Cart')) {
            loadCart();
        }
    } catch (e) {
        typingMsg.remove();
        const errMsg = document.createElement('div');
        errMsg.className = 'chat-msg bot';
        errMsg.textContent = 'Error contacting assistant.';
        messagesDiv.appendChild(errMsg);
        messagesDiv.scrollTop = messagesDiv.scrollHeight;
    }
}

window.onload = function() {
    loadMenu();
    loadCart();
};
</script>
</body>
</html>