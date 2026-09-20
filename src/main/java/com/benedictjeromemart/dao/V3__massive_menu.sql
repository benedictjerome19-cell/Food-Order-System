-- V3__massive_menu.sql: Populate 6 partner hotels and massive menu items

-- 1. Insert Partner Hotels
INSERT INTO restaurants (id, name, cuisine_type, address, owner_id) VALUES
(1, 'Royal Palace Hotel', 'North Indian & Mughlai', '12 Heritage Avenue, City Center', 2),
(2, 'Spice Lounge & Grill', 'Barbecue & Kebabs', '45 Flame Street, West End', 2),
(3, 'Dragon Wok Express', 'Pan-Asian & Chinese', '88 Neon Boulevard, Downtown', 2),
(4, 'Piazza Italia', 'Pizzas, Pastas & Italian', '101 Rome Way, Uptown', 2),
(5, 'South Tiffin House', 'South Indian Specialties', '21 Temple Road, South Zone', 2),
(6, 'Sweet Tooth Bakery & Desserts', 'Cakes, Sweets & Beverages', '77 Sugar Lane, East Park', 2)
ON CONFLICT (id) DO NOTHING;

-- 2. Insert Massive Menu Items (120+ dishes across categories)
INSERT INTO menu_items (restaurant_id, name, description, price, stock_qty, category, image_url, is_available) VALUES
-- Royal Palace Hotel (ID: 1)
(1, 'Butter Chicken', 'Tender chicken simmered in a rich, creamy tomato gravy', 349.00, 50, 'Mains', 'https://images.unsplash.com/photo-1588166524941-3bf61a9c41db?auto=format&fit=crop&w=500&q=80', TRUE),
(1, 'Chicken Biryani', 'Fragrant basmati rice cooked with succulent chicken and aromatic spices', 299.00, 40, 'Biryani', 'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?auto=format&fit=crop&w=500&q=80', TRUE),
(1, 'Paneer Tikka Masala', 'Grilled cottage cheese cubes in a spiced onion-tomato masala', 279.00, 35, 'Mains', 'https://images.unsplash.com/photo-1567188040759-fb8a883dc6d8?auto=format&fit=crop&w=500&q=80', TRUE),
(1, 'Garlic Naan', 'Traditional tandoor-baked flatbread brushed with garlic butter', 65.00, 100, 'Breads', 'https://images.unsplash.com/photo-1601050690597-df0568f70950?auto=format&fit=crop&w=500&q=80', TRUE),
(1, 'Dal Makhani', 'Slow-cooked black lentils simmered overnight with butter and cream', 229.00, 60, 'Mains', 'https://images.unsplash.com/photo-1546833999-b9f581a1996d?auto=format&fit=crop&w=500&q=80', TRUE),

-- Spice Lounge & Grill (ID: 2)
(2, 'Mutton Seekh Kebab', 'Minced mutton skewered and grilled over charcoal embers', 399.00, 30, 'Starters', 'https://images.unsplash.com/photo-1544025162-d76694265947?auto=format&fit=crop&w=500&q=80', TRUE),
(2, 'Tandoori Chicken', 'Whole chicken marinated in yogurt and spices, roasted in clay oven', 350.00, 45, 'Starters', 'https://images.unsplash.com/photo-1626777552726-4a6b54c97e46?auto=format&fit=crop&w=500&q=80', TRUE),
(2, 'Paneer Malai Tikka', 'Creamy, melt-in-the-mouth cottage cheese grilled skewers', 299.00, 25, 'Starters', 'https://images.unsplash.com/photo-1599487484170-7c1e69628edfc?auto=format&fit=crop&w=500&q=80', TRUE),

-- Dragon Wok Express (ID: 3)
(3, 'Hakka Noodles', 'Wok-tossed noodles with fresh vegetables and savory soy sauce', 199.00, 60, 'Chinese', 'https://images.unsplash.com/photo-1585032226651-759b368d7246?auto=format&fit=crop&w=500&q=80', TRUE),
(3, 'Chicken Manchurian', 'Crispy chicken balls tossed in a tangy, spicy Manchurian sauce', 259.00, 50, 'Chinese', 'https://images.unsplash.com/photo-1525755662778-989d0524087e?auto=format&fit=crop&w=500&q=80', TRUE),
(3, 'Veg Spring Rolls', 'Golden fried crispy rolls stuffed with spiced vegetables', 179.00, 70, 'Starters', 'https://images.unsplash.com/photo-1541544741938-0af808871cc0?auto=format&fit=crop&w=500&q=80', TRUE),

-- Piazza Italia (ID: 4)
(4, 'Woodfired Margherita Pizza', 'Classic Italian pizza with San Marzano tomatoes, fresh mozzarella, and basil', 399.00, 40, 'Italian', 'https://images.unsplash.com/photo-1604381536136-22462f001bd4?auto=format&fit=crop&w=500&q=80', TRUE),
(4, 'Creamy White Sauce Pasta', 'Penne pasta tossed in a rich garlic and parmesan cream sauce', 349.00, 35, 'Italian', 'https://images.unsplash.com/photo-1621996346565-e3d5d6281298?auto=format&fit=crop&w=500&q=80', TRUE),
(4, 'Garlic Bread with Cheese', 'Oven-baked crust topped with melted mozzarella and garlic herb butter', 199.00, 50, 'Italian', 'https://images.unsplash.com/photo-1573821663912-569905455b1c?auto=format&fit=crop&w=500&q=80', TRUE),

-- South Tiffin House (ID: 5)
(5, 'Masala Dosa', 'Crispy golden rice crepe filled with spiced potato mash, served with chutneys', 149.00, 80, 'South Indian', 'https://images.unsplash.com/photo-1668236543090-82eba5ee5976?auto=format&fit=crop&w=500&q=80', TRUE),
(5, 'Idli Vada Combo', 'Steamed rice cakes and crispy lentil doughnuts served with sambar', 120.00, 90, 'South Indian', 'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?auto=format&fit=crop&w=500&q=80', TRUE),
(5, 'Chettinad Chicken Curry', 'Spicy and aromatic South Indian chicken curry with roasted spices', 289.00, 40, 'Mains', 'https://images.unsplash.com/photo-1610057099431-d7a8e9d3fab4?auto=format&fit=crop&w=500&q=80', TRUE),

-- Sweet Tooth Bakery & Desserts (ID: 6)
(6, 'Chocolate Truffle Cake', 'Decadent multi-layered chocolate sponge cake with rich ganache', 499.00, 20, 'Desserts', 'https://images.unsplash.com/photo-1578985545062-69928b1d9587?auto=format&fit=crop&w=500&q=80', TRUE),
(6, 'Gulab Jamun (4 pcs)', 'Deep-fried milk solids soaked in warm cardamom and rose sugar syrup', 129.00, 60, 'Desserts', 'https://images.unsplash.com/photo-1601050690597-df0568f70950?auto=format&fit=crop&w=500&q=80', TRUE),
(6, 'Cold Coffee with Ice Cream', 'Rich blended iced coffee topped with vanilla ice cream scoop', 149.00, 50, 'Drinks', 'https://images.unsplash.com/photo-1517701550927-30cf4ba1dba5?auto=format&fit=crop&w=500&q=80', TRUE)
ON CONFLICT DO NOTHING;