package com.benedictjeromemart.util;

import org.mindrot.jbcrypt.BCrypt;

public class PasswordUtil {
    public static String hash(String password) {
        return BCrypt.hashpw(password, BCrypt.gensalt());
    }

    public static boolean check(String password, String hashed) {
        if (hashed == null || (!hashed.startsWith("$2a$") && !hashed.startsWith("$2b$") && !hashed.startsWith("$2y$"))) {
            return false;
        }
        return BCrypt.checkpw(password, hashed);
    }

    public static boolean verify(String password, String hashed) {
        return check(password, hashed);
    }

    public static void main(String[] args) {
        if (args.length == 0) {
            System.out.println("Usage: java com.benedictjeromemart.util.PasswordUtil <password>");
            return;
        }
        String password = args[0];
        String hashed = hash(password);
        System.out.println("==================================================");
        System.out.println("Plain Password:  " + password);
        System.out.println("BCrypt Hash:     " + hashed);
        System.out.println("==================================================");
    }
}