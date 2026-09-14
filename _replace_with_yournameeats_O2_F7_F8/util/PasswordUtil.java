package com.benedictjeromemart.util;

import org.mindrot.jbcrypt.BCrypt;

public class PasswordUtil {
    public static String hash(String password) {
        return BCrypt.hashpw(password, BCrypt.gensalt());
    }

    public static boolean check(String password, String hashed) {
        if (hashed == null || !hashed.startsWith("$2a$")) {
            return false;
        }
        return BCrypt.checkpw(password, hashed);
    }
}