<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page isELIgnored="true" %>
<%
    String userName = (String) session.getAttribute("userName");
    String userRole = (String) session.getAttribute("userRole");
    if (userName == null || userName.isEmpty()) userName = "Guest";
    String firstName = userName.contains(" ") ? userName.split(" ")[0] : userName;

    // Only restaurant owners may access this page.
    if (!"RESTAURANT_OWNER".equals(userRole)) {
        response.sendRedirect(request.getContextPath() + "/home.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Menu - BenedictJeromeMart</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
    <style>
        .manage-layout {
            max-width: 1200px;
            margin: 1.5rem auto;
            padding: 0 1rem;
            display: grid;
            grid-template-columns: 360px 1fr;
            gap: 1.5rem;
        }
        @media (max-width: 900px) {
            .manage-layout { grid-template-columns: 1fr; }
        }
        .manage-panel {
            background: var(--card-bg, #fff);
            border-radius: 14px;
            padding: 1.25rem;
            box-shadow: 0 4px 16px rgba(0,0,0,0.06);
        }
        .manage-panel h2 { margin-bottom: 1rem; font-size: 1.1rem; }
        .seed-bar {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 1rem;
            margin-bottom: 1rem;
            flex-wrap: wrap;
        }
        .dish-table-wrap { overflow-x: auto; }
        table.dish-table {
            width: 100%;
            border-collapse: collapse;
            font-size: 0.88rem;
        }
        table.dish-table th, table.dish-table td {
            text-align: left;
            padding: 0.55rem 0.6rem;
            border-bottom: 1px solid rgba(0,0,0,0.08);
            vertical-align: middle;
        }
        table.dish-table img {
            width: 42px; height: 42px; object-fit: cover; border-radius: 8px;
        }
        table.dish-table .row-actions { display: flex; gap: 0.4rem; }
        .btn-tiny {
            padding: 0.3rem 0.6rem;
            font-size: 0.78rem;
            border-radius: 6px;
            border: none;
            cursor: pointer;
        }
        .btn-tiny.edit { background: #e0e7ff; color: #3730a3; }
        .btn-tiny.delete { background: #fee2e2; color: #b91c1c; }
        #seedProgress { font-size: 0.8rem; color: var(--text-muted); margin-top: 0.4rem; }
        .stock-low { color: #b91c1c; font-weight: 700; }
    </style>
</head>
<body>

<header class="navbar">
    <a href="home.jsp" class="brand">
        <div class="brand-icon">🛒</div>
        BenedictJeromeMart
    </a>
    <div class="nav-right">
        <a href="home.jsp" class="btn btn-outline-sm">Home</a>
        <div class="welcome-badge">
            <span class="welcome-avatar"><%= firstName.charAt(0) %></span>
            Hey, <strong><%= firstName %></strong>! 👋
        </div>
        <a href="#" onclick="doLogout(); return false;" class="btn btn-outline-sm">🚪 Logout</a>
    </div>
</header>

<main class="manage-layout">

    <!-- ===== ADD / EDIT FORM ===== -->
    <section class="manage-panel">
        <h2 id="formTitle">➕ Add a Dish</h2>
        <form id="dishForm" onsubmit="return submitDish(event)">
            <input type="hidden" id="dishId" value="">
            <div class="form-group">
                <label>Name</label>
                <input type="text" class="form-control" id="dishName" required>
            </div>
            <div class="form-group">
                <label>Description</label>
                <input type="text" class="form-control" id="dishDesc">
            </div>
            <div style="display:grid;grid-template-columns:1fr 1fr;gap:1rem;">
                <div class="form-group">
                    <label>Price (Rs.)</label>
                    <input type="number" step="0.01" min="0" class="form-control" id="dishPrice" required>
                </div>
                <div class="form-group">
                    <label>Stock Qty</label>
                    <input type="number" min="0" class="form-control" id="dishStock" value="20">
                </div>
            </div>
            <div class="form-group">
                <label>Category</label>
                <input type="text" class="form-control" id="dishCategory" placeholder="e.g. Biryani, Pizza, Dessert" required>
            </div>
            <div class="form-group">
                <label>Image URL (optional \u2014 use a direct image link, not a search page link)</label>
                <input type="text" class="form-control" id="dishImage" maxlength="500" placeholder="https://example.com/photo.jpg">
            </div>
            <button type="submit" class="btn btn-primary" id="dishSubmitBtn">Add Dish</button>
            <button type="button" class="btn btn-outline-sm" id="cancelEditBtn" onclick="resetForm()" style="display:none;margin-top:0.5rem;">Cancel Edit</button>
            <div id="formMessage"></div>
        </form>
    </section>

    <!-- ===== DISH LIST ===== -->
    <section class="manage-panel">
        <div class="seed-bar">
            <h2 style="margin:0;">🍽️ Your Dishes (<span id="dishCount">0</span>)</h2>
            <div>
                <button class="btn btn-outline-sm" onclick="seedDishes()" id="seedBtn">⚡ Seed 100 Sample Dishes</button>
            </div>
        </div>
        <div id="seedProgress"></div>
        <div class="dish-table-wrap">
            <table class="dish-table">
                <thead>
                    <tr>
                        <th>Image</th><th>Name</th><th>Category</th><th>Price</th><th>Stock</th><th>Actions</th>
                    </tr>
                </thead>
                <tbody id="dishTableBody">
                    <tr><td colspan="6" style="text-align:center;padding:1.5rem;">Loading...</td></tr>
                </tbody>
            </table>
        </div>
    </section>

</main>

<script>
const ctx = '<%= request.getContextPath() %>';
let restaurantId = null;
let allDishes = [];

const categoryImages = {
    'burger':  'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=300&q=80',
    'pizza':   'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=300&q=80',
    'biryani': 'https://images.unsplash.com/photo-1589302168068-964664d93dc0?w=300&q=80',
    'noodles': 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=300&q=80',
    'salad':   'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=300&q=80',
    'dessert': 'https://images.unsplash.com/photo-1551024601-bec78aea704b?w=300&q=80',
    'drink':   'https://images.unsplash.com/photo-1544145945-f90425340c7e?w=300&q=80',
    'starter': 'https://images.unsplash.com/photo-1617622141675-d3005b9d5e8a?w=300&q=80',
    'mains':   'https://images.unsplash.com/photo-1565557623262-b51c2513a641?w=300&q=80',
    'south indian': 'https://images.unsplash.com/photo-1630383249896-424e482df921?w=300&q=80',
    'north indian': 'https://images.unsplash.com/photo-1631452180519-c014fe946bc7?w=300&q=80',
    'chinese': 'https://images.unsplash.com/photo-1585032226651-759b368d7246?w=300&q=80',
    'italian': 'https://images.unsplash.com/photo-1595295333158-4742f28fbd85?w=300&q=80',
    'seafood': 'https://images.unsplash.com/photo-1615141982883-c7ad0e69fd62?w=300&q=80',
    'sandwich': 'https://images.unsplash.com/photo-1553909489-cd47e0907980?w=300&q=80',
    'default': 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=300&q=80'
};

function imageFor(category) {
    const c = (category || '').toLowerCase();
    for (const key of Object.keys(categoryImages)) {
        if (c.includes(key)) return categoryImages[key];
    }
    return categoryImages['default'];
}

async function loadDishes() {
    try {
        const res = await fetch(ctx + '/api/v1/owner/menu-items');
        const result = await res.json();
        if (!result.success) {
            document.getElementById('dishTableBody').innerHTML =
                '<tr><td colspan="6" style="text-align:center;padding:1.5rem;">' +
                (result.error ? result.error.message : 'Could not load dishes') + '</td></tr>';
            return;
        }
        restaurantId = result.data.restaurantId;
        allDishes = result.data.items || [];
        renderDishes();
    } catch (err) {
        console.error('Failed to load dishes', err);
        document.getElementById('dishTableBody').innerHTML =
            '<tr><td colspan="6" style="text-align:center;padding:1.5rem;">⚠️ Could not load dishes. Please refresh.</td></tr>';
    }
}

function renderDishes() {
    document.getElementById('dishCount').textContent = allDishes.length;
    const body = document.getElementById('dishTableBody');
    if (allDishes.length === 0) {
        body.innerHTML = '<tr><td colspan="6" style="text-align:center;padding:1.5rem;">No dishes yet. Add one, or seed 100 sample dishes.</td></tr>';
        return;
    }
    body.innerHTML = allDishes.map(d => {
        const img = (d.imageUrl && d.imageUrl.startsWith('http')) ? d.imageUrl : imageFor(d.category);
        const stockClass = d.stockQty <= 0 ? 'stock-low' : '';
        return '<tr>' +
            '<td><img src="' + img + '" alt="' + escapeHtml(d.name) + '" onerror="this.src=\'' + categoryImages['default'] + '\';"></td>' +
            '<td>' + escapeHtml(d.name) + '<br><small style="color:var(--text-muted);">' + escapeHtml(d.description || '') + '</small></td>' +
            '<td>' + escapeHtml(d.category || '') + '</td>' +
            '<td>Rs.' + Number(d.price).toFixed(0) + '</td>' +
            '<td class="' + stockClass + '">' + d.stockQty + '</td>' +
            '<td class="row-actions">' +
                '<button class="btn-tiny edit" onclick="editDish(' + d.id + ')">Edit</button>' +
                '<button class="btn-tiny delete" onclick="deleteDish(' + d.id + ')">Delete</button>' +
            '</td>' +
        '</tr>';
    }).join('');
}

function escapeHtml(s) {
    return (s || '').replace(/[&<>"']/g, c => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));
}

function editDish(id) {
    const d = allDishes.find(x => x.id === id);
    if (!d) return;
    document.getElementById('formTitle').textContent = '✏️ Edit Dish';
    document.getElementById('dishId').value = d.id;
    document.getElementById('dishName').value = d.name || '';
    document.getElementById('dishDesc').value = d.description || '';
    document.getElementById('dishPrice').value = d.price;
    document.getElementById('dishStock').value = d.stockQty;
    document.getElementById('dishCategory').value = d.category || '';
    document.getElementById('dishImage').value = d.imageUrl || '';
    document.getElementById('dishSubmitBtn').textContent = 'Save Changes';
    document.getElementById('cancelEditBtn').style.display = 'inline-block';
    window.scrollTo({top: 0, behavior: 'smooth'});
}

function resetForm() {
    document.getElementById('formTitle').textContent = '➕ Add a Dish';
    document.getElementById('dishForm').reset();
    document.getElementById('dishId').value = '';
    document.getElementById('dishStock').value = 20;
    document.getElementById('dishSubmitBtn').textContent = 'Add Dish';
    document.getElementById('cancelEditBtn').style.display = 'none';
}

async function submitDish(evt) {
    evt.preventDefault();
    const id = document.getElementById('dishId').value;
    const body = new URLSearchParams();
    if (id) body.append('id', id);
    body.append('name', document.getElementById('dishName').value);
    body.append('description', document.getElementById('dishDesc').value);
    body.append('price', document.getElementById('dishPrice').value);
    body.append('stockQty', document.getElementById('dishStock').value);
    body.append('category', document.getElementById('dishCategory').value);
    body.append('imageUrl', document.getElementById('dishImage').value);

    const msg = document.getElementById('formMessage');
    try {
        const res = await fetch(ctx + '/api/v1/owner/menu-items', { method: 'POST', body: body });
        const result = await res.json();
        if (result.success) {
            msg.className = 'alert-message alert-success';
            msg.textContent = id ? 'Dish updated!' : 'Dish added!';
            resetForm();
            await loadDishes();
        } else {
            msg.className = 'alert-message alert-error';
            msg.textContent = (result.error && result.error.message) || 'Could not save dish';
        }
    } catch (err) {
        msg.className = 'alert-message alert-error';
        msg.textContent = 'Connection failed. Please try again.';
    }
    return false;
}

async function deleteDish(id) {
    if (!confirm('Delete this dish?')) return;
    try {
        await fetch(ctx + '/api/v1/owner/menu-items?id=' + id, { method: 'DELETE' });
        await loadDishes();
    } catch (err) {
        console.error('Failed to delete dish', err);
    }
}

// ===== SEED 100 SAMPLE DISHES =====
const seedCategories = {
    'Burger':  ['Classic Cheese Burger','Double Patty Burger','Veggie Burger','Spicy Chicken Burger','Mushroom Swiss Burger','BBQ Bacon Burger','Paneer Tikka Burger'],
    'Pizza':   ['Margherita Pizza','Pepperoni Pizza','Farmhouse Pizza','BBQ Chicken Pizza','Paneer Tikka Pizza','Four Cheese Pizza','Veggie Supreme Pizza'],
    'Biryani': ['Chicken Biryani','Mutton Biryani','Veg Biryani','Egg Biryani','Prawn Biryani','Hyderabadi Biryani','Paneer Biryani'],
    'Noodles': ['Hakka Noodles','Schezwan Noodles','Chicken Noodles','Veg Fried Noodles','Singapore Noodles','Egg Noodles','Thai Noodles'],
    'Salad':   ['Caesar Salad','Greek Salad','Fruit Salad','Sprouts Salad','Chicken Salad','Quinoa Salad','Garden Salad'],
    'Dessert': ['Chocolate Brownie','Gulab Jamun','Ice Cream Sundae','Cheesecake','Rasmalai','Tiramisu','Fruit Custard'],
    'Drink':   ['Cold Coffee','Fresh Lime Soda','Mango Lassi','Iced Tea','Chocolate Shake','Masala Chaas','Watermelon Juice'],
    'Starters': ['Paneer Tikka','Chicken 65','Spring Rolls','Veg Manchurian','Chilli Chicken','Corn Cheese Balls','Fish Fingers'],
    'South Indian': ['Masala Dosa','Idli Sambar','Uttapam','Medu Vada','Rava Dosa','Pongal','Curd Rice'],
    'North Indian': ['Butter Chicken','Paneer Butter Masala','Dal Makhani','Chole Bhature','Rajma Chawal','Aloo Paratha','Kadai Paneer'],
    'Chinese': ['Veg Manchurian','Chilli Paneer','Spring Rolls','Fried Rice','Sweet Corn Soup','Honey Chilli Potato','Kung Pao Chicken'],
    'Italian': ['Spaghetti Aglio Olio','Penne Arrabbiata','Lasagna','Risotto','Fettuccine Alfredo','Bruschetta','Minestrone Soup'],
    'Seafood': ['Grilled Fish','Prawn Curry','Fish Tikka','Fish and Chips','Prawn Tempura','Crab Curry','Fish Curry'],
    'Sandwich': ['Club Sandwich','Grilled Cheese Sandwich','Veg Sandwich','Chicken Sandwich','Paneer Sandwich','Egg Sandwich','Bombay Sandwich']
};

function buildSeedList() {
    const list = [];
    for (const [cat, names] of Object.entries(seedCategories)) {
        names.forEach(name => {
            list.push({
                name: name,
                description: 'Freshly prepared ' + name.toLowerCase() + ', made to order.',
                price: (99 + Math.floor(Math.random() * 300)),
                stockQty: 15 + Math.floor(Math.random() * 30),
                category: cat,
                imageUrl: imageFor(cat)
            });
        });
    }
    // list has 14 categories * 7 = 98; top up to 100+
    list.push({ name: 'Chef Special Combo', description: 'A curated combo picked by the chef.', price: 249, stockQty: 25, category: 'Mains', imageUrl: imageFor('mains') });
    list.push({ name: 'Kids Meal Combo', description: 'A fun, kid-friendly combo meal.', price: 179, stockQty: 25, category: 'Mains', imageUrl: imageFor('mains') });
    return list;
}

async function seedDishes() {
    if (!confirm('This will add 100 sample dishes to your menu. Continue?')) return;
    const seedBtn = document.getElementById('seedBtn');
    const progress = document.getElementById('seedProgress');
    seedBtn.disabled = true;
    const items = buildSeedList();
    let done = 0;
    const batchSize = 8;

    for (let i = 0; i < items.length; i += batchSize) {
        const batch = items.slice(i, i + batchSize);
        await Promise.all(batch.map(item => {
            const body = new URLSearchParams();
            body.append('name', item.name);
            body.append('description', item.description);
            body.append('price', item.price);
            body.append('stockQty', item.stockQty);
            body.append('category', item.category);
            body.append('imageUrl', item.imageUrl);
            return fetch(ctx + '/api/v1/owner/menu-items', { method: 'POST', body: body })
                .then(() => { done++; progress.textContent = 'Adding dishes... ' + done + ' / ' + items.length; })
                .catch(() => { done++; });
        }));
    }

    progress.textContent = 'Done! Added ' + done + ' dishes.';
    seedBtn.disabled = false;
    await loadDishes();
}

// Logout (matches home.jsp behavior — LogoutServlet only accepts POST)
async function doLogout() {
    try {
        await fetch(ctx + '/api/v1/logout', { method: 'POST' });
    } catch (e) {
        console.error('Logout request failed', e);
    }
    window.location.href = ctx + '/login.jsp';
}

loadDishes();
</script>
</body>
</html>
