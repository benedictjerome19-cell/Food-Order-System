package com.yourname.yournameeats.util;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.JsonDeserializer;
import com.google.gson.JsonPrimitive;
import com.google.gson.JsonSerializer;

/**
 * Shared Gson instance for the whole app. Registers a LocalDateTime adapter so
 * timestamps serialize as plain ISO strings instead of Gson's default nested
 * reflection dump (year/month/day/... as separate fields), which is what was
 * breaking OrderHistory. Reuse this instead of `new Gson()` anywhere a model
 * with a LocalDateTime field gets serialized.
 */
public final class JsonUtil {

    public static final Gson GSON = new GsonBuilder()
        .registerTypeAdapter(LocalDateTime.class,
            (JsonSerializer<LocalDateTime>) (src, type, ctx) ->
                src == null ? null : new JsonPrimitive(src.format(DateTimeFormatter.ISO_LOCAL_DATE_TIME)))
        .registerTypeAdapter(LocalDateTime.class,
            (JsonDeserializer<LocalDateTime>) (json, type, ctx) ->
                json.isJsonNull() ? null : LocalDateTime.parse(json.getAsString(), DateTimeFormatter.ISO_LOCAL_DATE_TIME))
        .create();

    private JsonUtil() {}
}
