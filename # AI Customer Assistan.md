# AI Customer Assistant — Chatbot Feature (O4)

Uses your existing `chat/ChatProvider.java` and `chat/MockChatProvider.java`.
Adds a rate-limited, cached chat endpoint and a floating widget on `home.jsp`.

Package: `com.yourname.yournameeats`.

---

## 1. ChatServlet — NEW FILE
Path: `src/main/java/com/yourname/yournameeats/controller/ChatServlet.java`

```java
package com.yourname.yournameeats.controller;

import com.google.gson.JsonObject;
import com.yourname.yournameeats.chat.ChatProvider;
import com.yourname.yournameeats.chat.MockChatProvider;
import com.yourname.yournameeats.util.JsonUtil;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * AI customer assistant endpoint. Scope restricted to menu/order/restaurant
 * FAQ questions via MockChatProvider (canned answers, no outbound network
 * call — safe to run with zero configuration for the capstone review).
 *
 * Guardrails per spec Section 17:
 *  - Per-session rate limit: 10 messages / 60 seconds
 *  - Input length cap: 300 characters
 *  - Repeated identical questions cached in-memory per session
 *  - Provider call wrapped in try/catch; degraded static reply on failure
 */
@WebServlet("/api/v1/chat")
public class ChatServlet extends HttpServlet {

    private static final int MAX_MESSAGES_PER_WINDOW = 10;
    private static final long WINDOW_MILLIS = 60_000L;
    private static final int MAX_INPUT_LENGTH = 300;

    // Swap this line for a real provider later (e.g. GeminiChatProvider)
    // behind the same ChatProvider interface — nothing else needs to change.
    private final ChatProvider chatProvider = new MockChatProvider();

    private void writeError(HttpServletResponse resp, int status, String code, String message) throws IOException {
        JsonObject error = new JsonObject();
        error.addProperty("code", code);
        error.addProperty("message", message);
        JsonObject envelope = new JsonObject();
        envelope.addProperty("success", false);
        envelope.add("data", null);
        envelope.add("error", error);
        resp.setStatus(status);
        resp.setContentType("application/json");
        resp.getWriter().write(JsonUtil.GSON.toJson(envelope));
    }

    @SuppressWarnings("unchecked")
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json");

        HttpSession session = req.getSession(true);
        String message = req.getParameter("message");

        if (message == null || message.isBlank()) {
            writeError(resp, HttpServletResponse.SC_BAD_REQUEST, "VALIDATION_ERROR", "message is required");
            return;
        }
        if (message.length() > MAX_INPUT_LENGTH) {
            writeError(resp, HttpServletResponse.SC_BAD_REQUEST, "VALIDATION_ERROR",
                "message must be " + MAX_INPUT_LENGTH + " characters or fewer");
            return;
        }

        // ---- Rate limiting (per session) ----
        List<Long> timestamps = (List<Long>) session.getAttribute("chatTimestamps");
        if (timestamps == null) timestamps = new ArrayList<>();

        long now = System.currentTimeMillis();
        timestamps.removeIf(t -> now - t > WINDOW_MILLIS);

        if (timestamps.size() >= MAX_MESSAGES_PER_WINDOW) {
            writeError(resp, HttpServletResponse.SC_TOO_MANY_REQUESTS, "RATE_LIMITED",
                "Too many messages — please wait a moment before trying again");
            return;
        }
        timestamps.add(now);
        session.setAttribute("chatTimestamps", timestamps);

        // ---- Per-session cache for repeated identical questions ----
        Map<String, String> cache = (Map<String, String>) session.getAttribute("chatCache");
        if (cache == null) cache = new HashMap<>();

        String cacheKey = message.trim().toLowerCase();
        String reply;

        if (cache.containsKey(cacheKey)) {
            reply = cache.get(cacheKey);
        } else {
            try {
                reply = chatProvider.getReply(message, null);
            } catch (Exception e) {
                // Degraded response instead of a 500 — never expose internals
                reply = "Sorry, I'm having trouble answering right now. " +
                        "You can browse the menu or check Order History directly.";
            }
            cache.put(cacheKey, reply);
            session.setAttribute("chatCache", cache);
        }

        JsonObject data = new JsonObject();
        data.addProperty("reply", reply);

        JsonObject envelope = new JsonObject();
        envelope.addProperty("success", true);
        envelope.add("data", data);
        envelope.add("error", null);
        resp.getWriter().write(JsonUtil.GSON.toJson(envelope));
    }
}
```

---

## 2. Add the chat widget to home.jsp

### 2a. Add this CSS block right before `</style>` in home.jsp's `<head>`

```css
/* ===== AI Assistant widget ===== */
#chatToggleBtn {
    position: fixed;
    bottom: 24px;
    right: 24px;
    width: 60px;
    height: 60px;
    border-radius: 50%;
    background: linear-gradient(135deg, #ff7043, #ff5252);
    color: #fff;
    border: none;
    font-size: 1.6rem;
    cursor: pointer;
    box-shadow: 0 8px 20px rgba(0,0,0,0.25);
    z-index: 9998;
    transition: transform 0.2s ease;
}
#chatToggleBtn:hover { transform: scale(1.08); }

#chatPanel {
    position: fixed;
    bottom: 96px;
    right: 24px;
    width: 340px;
    max-height: 460px;
    background: #fff;
    border-radius: 14px;
    box-shadow: 0 12px 32px rgba(0,0,0,0.25);
    display: none;
    flex-direction: column;
    overflow: hidden;
    z-index: 9998;
}
#chatPanel.open { display: flex; }

#chatHeader {
    background: linear-gradient(135deg, #ff7043, #ff5252);
    color: #fff;
    padding: 14px 16px;
    font-weight: 700;
    display: flex;
    justify-content: space-between;
    align-items: center;
}
#chatHeader button {
    background: none;
    border: none;
    color: #fff;
    font-size: 1.1rem;
    cursor: pointer;
}

#chatMessages {
    flex: 1;
    overflow-y: auto;
    padding: 12px;
    display: flex;
    flex-direction: column;
    gap: 8px;
    max-height: 320px;
}

.chat-msg {
    padding: 8px 12px;
    border-radius: 10px;
    font-size: 0.85rem;
    line-height: 1.35;
    max-width: 85%;
}
.chat-msg.user {
    background: #ffe0d6;
    align-self: flex-end;
    color: #7a2e12;
}
.chat-msg.bot {
    background: #f1f1f1;
    align-self: flex-start;
    color: #222;
}

#chatInputRow {
    display: flex;
    border-top: 1px solid #eee;
    padding: 8px;
    gap: 6px;
}
#chatInput {
    flex: 1;
    padding: 8px 10px;
    border: 1px solid #ddd;
    border-radius: 8px;
    font-size: 0.85rem;
}
#chatSendBtn {
    background: #ff5252;
    color: #fff;
    border: none;
    border-radius: 8px;
    padding: 8px 14px;
    cursor: pointer;
    font-weight: 600;
}
```

### 2b. Add this HTML block right before the closing `</body>` tag (after the success overlay `<div>`)

```html
<!-- ===== AI ASSISTANT WIDGET ===== -->
<button id="chatToggleBtn" onclick="toggleChat()">💬</button>

<div id="chatPanel">
    <div id="chatHeader">
        <span>🤖 BenedictJeromeMart Assistant</span>
        <button onclick="toggleChat()">✕</button>
    </div>
    <div id="chatMessages">
        <div class="chat-msg bot">Hi! Ask me about our menu, orders, hours, or payments.</div>
    </div>
    <div id="chatInputRow">
        <input type="text" id="chatInput" placeholder="Type a question..." maxlength="300"
            onkeydown="if(event.key==='Enter') sendChatMessage();">
        <button id="chatSendBtn" onclick="sendChatMessage()">Send</button>
    </div>
</div>
```

### 2c. Add these JS functions inside the existing `<script>` block, anywhere before the final `loadMenu(); loadCart();` lines

```javascript
function toggleChat() {
    document.getElementById('chatPanel').classList.toggle('open');
}

async function sendChatMessage() {
    const input = document.getElementById('chatInput');
    const message = input.value.trim();
    if (!message) return;

    const messagesDiv = document.getElementById('chatMessages');

    const userMsg = document.createElement('div');
    userMsg.className = 'chat-msg user';
    userMsg.textContent = message;
    messagesDiv.appendChild(userMsg);

    input.value = '';
    messagesDiv.scrollTop = messagesDiv.scrollHeight;

    const typingMsg = document.createElement('div');
    typingMsg.className = 'chat-msg bot';
    typingMsg.textContent = '...';
    messagesDiv.appendChild(typingMsg);
    messagesDiv.scrollTop = messagesDiv.scrollHeight;

    try {
        const formData = new URLSearchParams();
        formData.append('message', message);
        const res = await fetch(ctx + '/api/v1/chat', { method: 'POST', body: formData });
        const result = await res.json();

        typingMsg.textContent = result.success
            ? result.data.reply
            : (result.error && result.error.message) || 'Something went wrong.';
    } catch (err) {
        typingMsg.textContent = 'Connection failed. Please try again.';
    }

    messagesDiv.scrollTop = messagesDiv.scrollHeight;
}
```

---

## Terminal commands — rebuild, redeploy, run

```
cd D:\benedictmart\benedictmart\jerome_zom
mvn clean package
```
**Confirm `BUILD SUCCESS`.**

```
cd D:\benedictmart\benedictmart\jerome_zom\tomcat\bin
.\shutdown.bat
```
Wait 5 seconds.
```
Remove-Item -Recurse -Force "D:\benedictmart\benedictmart\jerome_zom\tomcat\webapps\benedictjeromemart" -ErrorAction SilentlyContinue
Copy-Item "D:\benedictmart\benedictmart\jerome_zom\target\benedictjeromemart.war" -Destination "D:\benedictmart\benedictmart\jerome_zom\tomcat\webapps\" -Force
.\startup.bat
```

Test:
```
http://localhost:8080/benedictjeromemart/home.jsp
```

You should see a round chat bubble button in the bottom-right corner. Click it, ask something like "what are your hours" or "how do I track my order" — it should reply using your existing `MockChatProvider`'s canned answers.

---

## Note on your MockChatProvider content
If you don't remember what canned answers it currently has (it was recreated
earlier after the BOM encoding fix), paste its current content and I'll expand
the FAQ coverage to hit the spec's "5–10 FAQ-style domain questions" minimum
if it's currently thinner than that.