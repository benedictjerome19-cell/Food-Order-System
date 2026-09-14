INSERT INTO users (name, email, password_hash, role) VALUES
('Admin', 'admin@yournameeats.com', '$2a$10$MQJkELMJPjs6y9DJ1mVTweB/7jwnBd4Tel8JSS9AbtzDsug1UAxpG', 'ADMIN');

INSERT INTO users (name, email, password_hash, role) VALUES
('Test Owner', 'owner@test.com', '$2a$10$KKrvdMt9a58vnldV55FOQ.WBZvfOLzVcS7ZGkc2BVPQi.i.hQntti', 'RESTAURANT_OWNER'),
('Test Customer', 'customer@test.com', '$2a$10$Lnt/cyR2MpYMdXhfExt.9e/42nPgeMX90sYCXuuzVW.dDiuf03TFO', 'CUSTOMER');

INSERT INTO restaurants (owner_id, name, cuisine_type, address) VALUES
(2, 'Tasty Bites', 'Indian', '123 Main Street');

INSERT INTO menu_items (restaurant_id, name, description, price, stock_qty, category, image_url) VALUES
(1, 'Paneer Butter Masala', 'Creamy tomato-based curry', 220.00, 50, 'Mains', ''),
(1, 'Veg Biryani', 'Fragrant rice with vegetables', 180.00, 40, 'Mains', ''),
(1, 'Gulab Jamun', 'Sweet milk-based dessert', 90.00, 60, 'Desserts', '');