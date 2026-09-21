package com.benedictjeromemart.listener;

import com.benedictjeromemart.listener.AppContextListener;

public class TestDB {
    public static void main(String[] args) {
        System.out.println("Testing DB Connection...");
        AppContextListener listener = new AppContextListener();
        try {
            listener.contextInitialized(null);
            System.out.println("Success!");
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
