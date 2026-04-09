import { corsHeaders } from "../_shared/cors.ts";

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  try {
    const { messages, model = "aisod-3a-online", stream = true } = await req.json();
    const upstream = await fetch("https://api.openai.com/v1/chat/completions", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${Deno.env.get("OPENAI_API_KEY") ?? ""}`
      },
      body: JSON.stringify({ model, messages, stream })
    });
    return new Response(upstream.body, {
      headers: { ...corsHeaders, "Content-Type": upstream.headers.get("Content-Type") ?? "text/event-stream" },
      status: upstream.status
    });
  } catch (error) {
    return new Response(JSON.stringify({ error: String(error) }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
      status: 500
    });
  }
});
