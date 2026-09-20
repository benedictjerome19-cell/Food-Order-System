package com.benedictjeromemart.model;

import java.math.BigDecimal;

public class CartItem {
    private int id;
    private int userId;
    private int menuItemId;
    private int quantity;
    private String name;
    private BigDecimal price;
    private BigDecimal unitPrice;

    public CartItem() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }
    public int getMenuItemId() { return menuItemId; }
    public void setMenuItemId(int menuItemId) { this.menuItemId = menuItemId; }
    public int getQuantity() { return quantity; }
    public void setQuantity(int quantity) { this.quantity = quantity; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public BigDecimal getPrice() { return price; }
    public void setPrice(BigDecimal price) { 
        this.price = price; 
        this.unitPrice = price; 
    }
    public BigDecimal getUnitPrice() { return unitPrice != null ? unitPrice : price; }
    public void setUnitPrice(BigDecimal unitPrice) { 
        this.unitPrice = unitPrice; 
        if (this.price == null) this.price = unitPrice;
    }
}

