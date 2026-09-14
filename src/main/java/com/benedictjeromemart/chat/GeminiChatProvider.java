package com.benedictjeromemart.chat;

import com.google.genai.Client;
import com.google.genai.types.GenerateContentResponse;

/**
 * Real LLM-backed implementation of ChatProvider.
 */
public class GeminiChatProvider implements ChatProvider {

    private static final String MODEL = "gemini-2.5-flash";
    private final Client client;

    public GeminiChatProvider() {
        String apiKey = System.getenv("GEMINI_API_KEY");
        if (apiKey == null || apiKey.isBlank()) {
            throw new IllegalStateException("GEMINI_API_KEY environment variable is not set");
        }
        this.client = Client.builder().apiKey(apiKey).build();
    }

    @Override
    public String getReply(String userMessage, String context) {
        String systemPrompt =
            "You are the AI Assistant for BenedictJeromeMart, a food ordering app. " +
            "Answer ONLY questions about the menu, orders, restaurants, payments, or how to use the site. " +
            "If asked about anything unrelated, politely redirect the customer back to food-ordering topics. " +
            "Keep answers short (2-3 sentences).\n\n" +
            (context != null ? "Current menu context:\n" + context + "\n\n" : "") +
            "Customer question: " + userMessage;

        try {
            // The SDK throws an IOException here if the API call fails
            GenerateContentResponse response = client.models.generateContent(MODEL, systemPrompt, null);
            String text = (response != null) ? response.text() : null;
            return (text == null || text.isBlank()) ? "I'm not sure how to answer that — could you rephrase?" : text;
        } catch (Exception e) {
            System.err.println("Gemini API Error: " + e.getMessage());
            return "Sorry, I'm having trouble connecting right now. Please try again later.";
        }
    }
}
