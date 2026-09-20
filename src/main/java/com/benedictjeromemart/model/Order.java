package com.benedictjeromemart.model;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public class Order {
    private int id;
    private int buyerId;
    private int restaurantId;
    private String status;
    private BigDecimal totalAmount;
    private String deliveryAddress;
    private String customerPhone;
    private String paymentMethod;
    private String paymentStatus;
    private String transactionId;
    private LocalDateTime createdAt;

    public Order() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getBuyerId() { return buyerId; }
    public void setBuyerId(int buyerId) { this.buyerId = buyerId; }

    public int getRestaurantId() { return restaurantId; }
    public void setRestaurantId(int restaurantId) { this.restaurantId = restaurantId; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public BigDecimal getTotalAmount() { return totalAmount; }
    public void setTotalAmount(BigDecimal totalAmount) { this.totalAmount = totalAmount; }

    public String getDeliveryAddress() { return deliveryAddress; }
    public void setDeliveryAddress(String deliveryAddress) { this.deliveryAddress = deliveryAddress; }

    public String getCustomerPhone() { return customerPhone; }
    public void setCustomerPhone(String customerPhone) { this.customerPhone = customerPhone; }

    public String getPaymentMethod() { return paymentMethod; }
    public void setPaymentMethod(String paymentMethod) { this.paymentMethod = paymentMethod; }

    public String getPaymentStatus() { return paymentStatus; }
    public void setPaymentStatus(String paymentStatus) { this.paymentStatus = paymentStatus; }

    public String getTransactionId() { return transactionId; }
    public void setTransactionId(String transactionId) { this.transactionId = transactionId; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}