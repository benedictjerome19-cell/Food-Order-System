package com.benedictjeromemart.util;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.JsonDeserializer;
import com.google.gson.JsonPrimitive;
import com.google.gson.JsonSerializer;

/**
 * Central place to build Gson instances used across all servlets.
 *
 * Plain `new Gson()` uses reflection to read every field on a class,
 * including private JDK internals like java.time.LocalDateTime#date.
 * On Java 9+ that reflective access is blocked by the module system
 * (java.base does not open java.time to arbitrary code), which crashes
 * with InaccessibleObjectException the moment any model with a
 * LocalDateTime/LocalDate field gets serialized.
 *
 * Registering explicit adapters below serializes those types as plain
 * ISO date strings instead of touching their private fields, avoiding
 * the problem entirely (and producing cleaner JSON for the frontend).
 */
public final class GsonUtil {

    private GsonUtil() {}

    private static final DateTimeFormatter DATE_TIME_FORMAT = DateTimeFormatter.ISO_LOCAL_DATE_TIME;
    private static final DateTimeFormatter DATE_FORMAT = DateTimeFormatter.ISO_LOCAL_DATE;

    private static final Gson INSTANCE = new GsonBuilder()
        .registerTypeAdapter(LocalDateTime.class, (JsonSerializer<LocalDateTime>) (src, type, ctx) ->
            src == null ? null : new JsonPrimitive(DATE_TIME_FORMAT.format(src)))
        .registerTypeAdapter(LocalDateTime.class, (JsonDeserializer<LocalDateTime>) (json, type, ctx) ->
            json == null || json.isJsonNull() ? null : LocalDateTime.parse(json.getAsString(), DATE_TIME_FORMAT))
        .registerTypeAdapter(LocalDate.class, (JsonSerializer<LocalDate>) (src, type, ctx) ->
            src == null ? null : new JsonPrimitive(DATE_FORMAT.format(src)))
        .registerTypeAdapter(LocalDate.class, (JsonDeserializer<LocalDate>) (json, type, ctx) ->
            json == null || json.isJsonNull() ? null : LocalDate.parse(json.getAsString(), DATE_FORMAT))
        .create();

    /** Shared, safely-configured Gson instance. Use this instead of `new Gson()`. */
    public static Gson create() {
        return INSTANCE;
    }
}