-- Update existing items with real food images
UPDATE menu_items SET image_url = 'https://images.unsplash.com/photo-1565557623262-b51c2513a641?w=400&q=80', category = 'Mains' WHERE name = 'Paneer Butter Masala';
UPDATE menu_items SET image_url = 'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?w=400&q=80', category = 'Mains' WHERE name = 'Veg Biryani';
UPDATE menu_items SET image_url = 'https://images.unsplash.com/photo-1533993192821-2cce3a8267d?w=400&q=80', category = 'Desserts' WHERE name = 'Gulab Jamun';

-- Add more menu items across categories
INSERT INTO menu_items (restaurant_id, name, description, price, stock_qty, category, image_url) VALUES
(1, 'Classic Burger', 'Juicy patty with lettuce, tomato & cheese sauce', 150.00, 30, 'Burgers', 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400&q=80'),
(1, 'Spicy Chicken Burger', 'Crispy chicken fillet with sriracha mayo', 180.00, 25, 'Burgers', 'https://images.unsplash.com/photo-1561758033-d89a9ad46330?w=400&q=80'),
(1, 'Cheese Burst Pizza', 'Wood-fired pizza loaded with mozzarella cheese', 280.00, 25, 'Pizza', 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=400&q=80'),
(1, 'Chicken Tikka Pizza', 'Spicy chicken tikka with peppers on pizza base', 320.00, 20, 'Pizza', 'https://images.unsplash.com/photo-1528137871618-79d2761e3fd5?w=400&q=80'),
(1, 'Veg Hakka Noodles', 'Stir-fried noodles with crunchy vegetables', 130.00, 35, 'Noodles', 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=400&q=80'),
(1, 'Chicken Biryani', 'Fragrant basmati rice with spiced chicken', 260.00, 30, 'Mains', 'https://images.unsplash.com/photo-1589302168068-964664d93dc0?w=400&q=80'),
(1, 'Dal Makhani', 'Slow-cooked black lentils in rich butter gravy', 200.00, 40, 'Mains', 'https://images.unsplash.com/photo-1546833998-877b37c2e5c6?w=400&q=80'),
(1, 'Crispy Spring Rolls', 'Golden fried veggie spring rolls with dip', 100.00, 45, 'Starters', 'https://images.unsplash.com/photo-1617622141675-d3005b9d5e8a?w=400&q=80'),
(1, 'Chicken Tikka', 'Tandoor-grilled chicken with mint chutney', 240.00, 30, 'Starters', 'https://images.unsplash.com/photo-1565557623262-b51c2513a641?w=400&q=80'),
(1, 'Chocolate Brownie', 'Warm gooey chocolate brownie with ice cream', 120.00, 40, 'Desserts', 'https://images.unsplash.com/photo-1551024601-bec78aea704b?w=400&q=80'),
(1, 'Mango Lassi', 'Chilled mango blended with creamy yogurt', 80.00, 60, 'Drinks', 'https://images.unsplash.com/photo-1590301157890-4810ed352733?w=400&q=80'),
(1, 'Fresh Lemonade', 'Mint lemon cooler with rock salt', 60.00, 70, 'Drinks', 'https://images.unsplash.com/photo-1621263764928-df1444c5e859?w=400&q=80'),
(1, 'Cold Coffee', 'Blended iced coffee with cream', 90.00, 50, 'Drinks', 'https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=400&q=80');
