import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

Deno.serve(async (req) => {
  // Handle CORS preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  if (req.method !== "POST") {
    return new Response(JSON.stringify({ error: "Method not allowed" }), {
      status: 405,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }

  try {
    const payload = await req.json();

    // Validate required fields
    if (!payload.sensor_id || !payload.coach_number) {
      return new Response(
        JSON.stringify({ error: "Missing required fields: sensor_id, coach_number" }),
        {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    // Build the row to upsert — only include fields the Arduino sends
    const row: Record<string, unknown> = {
      sensor_id: payload.sensor_id,
      device_id: payload.device_id ?? null,
      coach_number: payload.coach_number,
      toilet_position: payload.toilet_position ?? null,
      status: payload.status ?? null,
      voc: payload.voc ?? null,
      nh3: payload.nh3 ?? null,
      h2s: payload.h2s ?? null,
      smoke: payload.smoke ?? null,
      temperature: payload.temperature ?? null,
      humidity: payload.humidity ?? null,
      latitude: payload.latitude ?? null,
      longitude: payload.longitude ?? null,
      door_status: payload.door_status ?? null,
      door_open_events_today: payload.door_open_events_today ?? null,
      timestamp: new Date().toISOString(),
    };

    // Use service role to bypass RLS
    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

    // Upsert using sensor_id as the conflict key
    const { data, error } = await supabase
      .from("odour_management_live")
      .upsert(row, { onConflict: "sensor_id" })
      .select("pending_action")
      .single();

    if (error) {
      console.error("Supabase upsert error:", error);
      return new Response(
        JSON.stringify({ error: error.message }),
        {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    // Build response — include pending_action so Arduino can trigger RESOLVE SMS
    const response: Record<string, unknown> = { success: true };
    if (data?.pending_action) {
      response.pending_action = data.pending_action;
    }

    return new Response(JSON.stringify(response), {
      status: 200,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (err) {
    console.error("Ingestion error:", err);
    return new Response(
      JSON.stringify({ error: "Invalid JSON payload" }),
      {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  }
});
