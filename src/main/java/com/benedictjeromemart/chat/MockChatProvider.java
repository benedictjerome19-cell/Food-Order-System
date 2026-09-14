package com.benedictjeromemart.chat;

public class MockChatProvider implements ChatProvider {
    @Override
    public String getReply(String userMessage, String context) {
        String msg = userMessage.toLowerCase();
        if (msg.contains("hour") || msg.contains("open")) {
            return "Our restaurants are open daily from 10 AM to 10 PM.";
        } else if (msg.contains("order") || msg.contains("track")) {
            return "You can check your order status on the Order History page.";
        } else if (msg.contains("cancel")) {
            return "To cancel an order, please contact the restaurant directly.";
        } else if (msg.contains("payment")) {
            return "We currently support mock payment confirmation for checkout.";
        } else if (msg.contains("cuisine") || msg.contains("menu")) {
            return "You can browse all available cuisines and menu items on the Home page.";
        }
        return "I'm here to help with menu, orders, and restaurant questions. Could you rephrase that?";
    }
}