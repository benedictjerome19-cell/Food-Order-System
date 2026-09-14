/*package com.yourname.yournameeats.chat;

public interface ChatProvider {
    String respond(String userMessage, int userId);
}*/

package com.yourname.yournameeats.chat;

public interface ChatProvider {
    String getReply(String userMessage, String context);
}