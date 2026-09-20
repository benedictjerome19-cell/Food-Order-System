package com.benedictjeromemart.model;

public class OrderItemDetail extends OrderItem {
    private String menuItemName;

    public OrderItemDetail() {}

    public String getMenuItemName() {
        return menuItemName;
    }

    public void setMenuItemName(String menuItemName) {
        this.menuItemName = menuItemName;
    }
}