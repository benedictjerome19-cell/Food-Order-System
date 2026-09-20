-- BenedictJeromemart - PostgreSQL schema
-- Idempotent: safe to run on every startup (AppContextListener does exactly that).

CREATE TABLE IF NOT EXISTS users (
    id         SERIAL PRIMARY KEY,
    name       VARCHAR(100) NOT NULL,
    email      VARCHAR(150) NOT NULL UNIQUE,
    password   VARCHAR(255) NOT NULL,
    role       VARCHAR(20)  NOT NULL CHECK (role IN ('CUSTOMER','RESTAURANT_OWNER','ADMIN')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS restaurants (
    id           SERIAL PRIMARY KEY,
    owner_id     INT          NOT NULL REFERENCES users(id),
    name         VARCHAR(150) NOT NULL,
    cuisine_type VARCHAR(50),
    address      VARCHAR(255),
    created_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX IF NOT EXISTS idx_restaurants_owner ON restaurants(owner_id);

CREATE TABLE IF NOT EXISTS menu_items (
    id            SERIAL PRIMARY KEY,
    restaurant_id INT           NOT NULL REFERENCES restaurants(id),
    name          VARCHAR(150)  NOT NULL,
    description   VARCHAR(500),
    price         DECIMAL(10,2) NOT NULL,
    stock_qty     INT DEFAULT 0,
    category      VARCHAR(50),
    image_url     VARCHAR(500),
    is_available  BOOLEAN NOT NULL DEFAULT TRUE,
    created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX IF NOT EXISTS idx_menuitems_restaurant ON menu_items(restaurant_id);

CREATE TABLE IF NOT EXISTS cart_items (
    id           SERIAL PRIMARY KEY,
    user_id      INT NOT NULL REFERENCES users(id),
    menu_item_id INT NOT NULL REFERENCES menu_items(id),
    quantity     INT NOT NULL DEFAULT 1
);
CREATE INDEX IF NOT EXISTS idx_cart_user ON cart_items(user_id);
CREATE INDEX IF NOT EXISTS idx_cart_menuitem ON cart_items(menu_item_id);

CREATE TABLE IF NOT EXISTS orders (
    id               SERIAL PRIMARY KEY,
    buyer_id         INT           NOT NULL REFERENCES users(id),
    restaurant_id    INT           NOT NULL REFERENCES restaurants(id),
    status           VARCHAR(20)   NOT NULL DEFAULT 'PENDING'
        CHECK (status IN ('PENDING','CONFIRMED','SHIPPED','DELIVERED','CANCELLED')),
    total_amount     DECIMAL(10,2) NOT NULL,
    delivery_address VARCHAR(500),
    customer_phone   VARCHAR(30),
    payment_method   VARCHAR(30),
    payment_status   VARCHAR(20) DEFAULT 'PENDING',
    transaction_id   VARCHAR(100),
    created_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX IF NOT EXISTS idx_orders_buyer ON orders(buyer_id);
CREATE INDEX IF NOT EXISTS idx_orders_restaurant ON orders(restaurant_id);

CREATE TABLE IF NOT EXISTS order_items (
    id           SERIAL PRIMARY KEY,
    order_id     INT           NOT NULL REFERENCES orders(id),
    menu_item_id INT           NOT NULL REFERENCES menu_items(id),
    quantity     INT           NOT NULL,
    unit_price   DECIMAL(10,2) NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_orderitems_order ON order_items(order_id);
CREATE INDEX IF NOT EXISTS idx_orderitems_menuitem ON order_items(menu_item_id);

CREATE TABLE IF NOT EXISTS reviews (
    id            SERIAL PRIMARY KEY,
    restaurant_id INT NOT NULL REFERENCES restaurants(id),
    user_id       INT NOT NULL REFERENCES users(id),
    rating        INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment       VARCHAR(500),
    created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX IF NOT EXISTS idx_reviews_restaurant ON reviews(restaurant_id);
CREATE INDEX IF NOT EXISTS idx_reviews_user ON reviews(user_id);

-- Upgrade path: databases created from an older version of this file lack these columns.
ALTER TABLE menu_items ADD COLUMN IF NOT EXISTS is_available BOOLEAN NOT NULL DEFAULT TRUE;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS delivery_address VARCHAR(500);
ALTER TABLE orders ADD COLUMN IF NOT EXISTS customer_phone VARCHAR(30);
ALTER TABLE orders ADD COLUMN IF NOT EXISTS payment_method VARCHAR(30);
ALTER TABLE orders ADD COLUMN IF NOT EXISTS payment_status VARCHAR(20) DEFAULT 'PENDING';
ALTER TABLE orders ADD COLUMN IF NOT EXISTS transaction_id VARCHAR(100);