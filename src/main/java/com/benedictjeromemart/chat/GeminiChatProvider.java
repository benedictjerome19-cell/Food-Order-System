package com.benedictjeromemart.chat;

import com.google.genai.Client;
import com.google.genai.types.GenerateContentResponse;

/**
 * Real LLM-backed implementation of ChatProvider.
 */
public class GeminiChatProvider implements ChatProvider {

    private static final String MODEL = "gemini-2.5-flash";
    private final Client client;
    private final MockChatProvider fallback = new MockChatProvider();

    public GeminiChatProvider() {
        String apiKey = resolveApiKey();
        if (apiKey == null || apiKey.isBlank()) {
            this.client = null;
        } else {
            this.client = Client.builder().apiKey(apiKey).build();
        }
    }

    public GeminiChatProvider(String apiKey) {
        if (apiKey != null && !apiKey.isBlank()) {
            this.client = Client.builder().apiKey(apiKey).build();
        } else {
            this.client = null;
        }
    }

    private String resolveApiKey() {
        String key = System.getenv("GEMINI_API_KEY");
        if (key != null && !key.isBlank()) return key.trim();

        key = System.getProperty("GEMINI_API_KEY");
        if (key != null && !key.isBlank()) return key.trim();

        key = System.getProperty("gemini.api.key");
        if (key != null && !key.isBlank()) return key.trim();

        try (java.io.InputStream in = GeminiChatProvider.class.getClassLoader().getResourceAsStream("config.properties")) {
            if (in != null) {
                java.util.Properties props = new java.util.Properties();
                props.load(in);
                key = props.getProperty("gemini.api.key");
                if (key != null && !key.isBlank()) return key.trim();
            }
        } catch (Exception ignored) {}

        return null;
    }

    @Override
    public String getReply(String userMessage, String context) {
        if (client == null) {
            return fallback.getReply(userMessage, context);
        }

        String systemPrompt =
            "You are the AI Assistant for BenedictJeromeMart, a food ordering app. " +
            "Answer ONLY questions about the menu, orders, restaurants, payments, or how to use the site. " +
            "If asked about anything unrelated, politely redirect the customer back to food-ordering topics. " +
            "Keep answers short (2-3 sentences).\n\n" +
            (context != null ? "Current menu context:\n" + context + "\n\n" : "") +
            "Customer question: " + userMessage;

        try {
            GenerateContentResponse response = client.models.generateContent(MODEL, systemPrompt, null);
            String text = (response != null) ? response.text() : null;
            return (text == null || text.isBlank()) ? fallback.getReply(userMessage, context) : text;
        } catch (Exception e) {
            System.err.println("Gemini API Error: " + e.getMessage());
            return fallback.getReply(userMessage, context);
        }
    }
}
