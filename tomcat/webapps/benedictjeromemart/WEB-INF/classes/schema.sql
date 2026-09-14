-- BenedictJeromeMart — Full Schema (idempotent, H2-compatible)

CREATE TABLE IF NOT EXISTS users (
    id            INT AUTO_INCREMENT PRIMARY KEY,
    name          VARCHAR(120) NOT NULL,
    email         VARCHAR(200) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    role          VARCHAR(30)  NOT NULL DEFAULT 'CUSTOMER',
    created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS restaurants (
    id           INT AUTO_INCREMENT PRIMARY KEY,
    owner_id     INT          NOT NULL,
    name         VARCHAR(200) NOT NULL,
    cuisine_type VARCHAR(100),
    address      VARCHAR(300),
    created_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_rest_owner FOREIGN KEY (owner_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS menu_items (
    id            INT AUTO_INCREMENT PRIMARY KEY,
    restaurant_id INT            NOT NULL,
    name          VARCHAR(200)   NOT NULL,
    description   VARCHAR(500),
    price         DECIMAL(10, 2) NOT NULL,
    stock_qty     INT            NOT NULL DEFAULT 0,
    category      VARCHAR(100),
    image_url     VARCHAR(500),
    available     BOOLEAN        NOT NULL DEFAULT TRUE,
    created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_item_rest FOREIGN KEY (restaurant_id) REFERENCES restaurants(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS cart_items (
    id           INT AUTO_INCREMENT PRIMARY KEY,
    user_id      INT NOT NULL,
    menu_item_id INT NOT NULL,
    quantity     INT NOT NULL DEFAULT 1,
    CONSTRAINT fk_cart_user FOREIGN KEY (user_id)      REFERENCES users(id)      ON DELETE CASCADE,
    CONSTRAINT fk_cart_item FOREIGN KEY (menu_item_id) REFERENCES menu_items(id) ON DELETE CASCADE,
    CONSTRAINT uq_cart      UNIQUE (user_id, menu_item_id)
);

CREATE TABLE IF NOT EXISTS orders (
    id            INT AUTO_INCREMENT PRIMARY KEY,
    buyer_id      INT            NOT NULL,
    restaurant_id INT            NOT NULL,
    status        VARCHAR(30)    NOT NULL DEFAULT 'PENDING',
    total_amount  DECIMAL(10, 2) NOT NULL,
    created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_order_buyer FOREIGN KEY (buyer_id)      REFERENCES users(id)       ON DELETE CASCADE,
    CONSTRAINT fk_order_rest  FOREIGN KEY (restaurant_id) REFERENCES restaurants(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS order_items (
    id           INT AUTO_INCREMENT PRIMARY KEY,
    order_id     INT            NOT NULL,
    menu_item_id INT            NOT NULL,
    quantity     INT            NOT NULL,
    unit_price   DECIMAL(10, 2) NOT NULL,
    CONSTRAINT fk_oi_order FOREIGN KEY (order_id)     REFERENCES orders(id)     ON DELETE CASCADE,
    CONSTRAINT fk_oi_item  FOREIGN KEY (menu_item_id) REFERENCES menu_items(id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS reviews (
    id           INT AUTO_INCREMENT PRIMARY KEY,
    order_id     INT          NOT NULL,
    buyer_id     INT          NOT NULL,
    menu_item_id INT          NOT NULL,
    rating       INT          NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment      VARCHAR(1000),
    created_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_rev_order  FOREIGN KEY (order_id)     REFERENCES orders(id)     ON DELETE CASCADE,
    CONSTRAINT fk_rev_buyer  FOREIGN KEY (buyer_id)     REFERENCES users(id)      ON DELETE CASCADE,
    CONSTRAINT fk_rev_item   FOREIGN KEY (menu_item_id) REFERENCES menu_items(id) ON DELETE CASCADE,
    CONSTRAINT uq_review     UNIQUE (buyer_id, menu_item_id, order_id)
);

-- Seed admin (password = admin123)
MERGE INTO users (id, name, email, password_hash, role) KEY(email)
VALUES (1, 'Admin User', 'admin@benedictmart.com',
        '$2a$12$pFEFuGJPxOBHoGVMtyAT/eP2OkCyHH0x7lC6R9R.FD0wFbGGJjS0a', 'ADMIN');

-- Seed owner (password = owner123)
MERGE INTO users (id, name, email, password_hash, role) KEY(email)
VALUES (2, 'Jerome Owner', 'owner@benedictmart.com',
        '$2a$12$Z7HXsb0MxDKKWuV3FOeSw.w1oJ/XO/a8f1R.eS.XCzEgVv8Vs1v5K', 'RESTAURANT_OWNER');

MERGE INTO restaurants (id, owner_id, name, cuisine_type, address) KEY(id)
VALUES (1, 2, 'Jerome Kitchen', 'Multi-cuisine', '12 Main Street, Chennai');

MERGE INTO menu_items (id, restaurant_id, name, description, price, stock_qty, category) KEY(id)
VALUES
(1, 1, 'Masala Burger',   'Spicy Indian-style burger with chutney',   120.00, 50, 'Burger'),
(2, 1, 'Paneer Pizza',    'Wood-fired pizza with paneer tikka',        220.00, 30, 'Pizza'),
(3, 1, 'Chicken Biryani', 'Aromatic basmati rice with tender chicken', 180.00, 40, 'Biryani'),
(4, 1, 'Veg Noodles',     'Stir-fried veggies with hakka noodles',     110.00, 60, 'Noodles'),
(5, 1, 'Mango Lassi',     'Chilled mango yogurt drink',                 60.00, 80, 'Drink'),
(6, 1, 'Gulab Jamun',     'Soft milk-solid dumplings in sugar syrup',   80.00, 70, 'Dessert'),
(7, 1, 'Spring Rolls',    'Crispy vegetable spring rolls',              90.00, 55, 'Starter'),
(8, 1, 'Greek Salad',     'Fresh veggies with feta and olives',        130.00, 45, 'Salad');

ALTER TABLE users ALTER COLUMN id RESTART WITH 10;
ALTER TABLE restaurants ALTER COLUMN id RESTART WITH 10;
ALTER TABLE menu_items ALTER COLUMN id RESTART WITH 10;
