// Soft halo around text for Windows Terminal. Letters themselves are left untouched,
// so strokes stay crisp, and the background stays transparent.
// Tweak GLOW_STRENGTH (brightness) and GLOW_RADIUS (spread, in pixels at 100% scale).

Texture2D shaderTexture;
SamplerState samplerState;

cbuffer PixelShaderSettings
{
    float Time;
    float Scale;
    float2 Resolution;
    float4 Background;
};

static const float GLOW_STRENGTH = 0.5;
static const float GLOW_RADIUS = 6.0;
static const int RINGS = 4;
static const int SPOKES = 12;
static const float TAU = 6.2831853;

float luminance(float3 c)
{
    return dot(c, float3(0.2126, 0.7152, 0.0722));
}

float4 main(float4 pos : SV_POSITION, float2 tex : TEXCOORD) : SV_TARGET
{
    float4 color = shaderTexture.Sample(samplerState, tex);
    float2 texel = GLOW_RADIUS * max(Scale, 1.0) / Resolution;

    float3 glow = float3(0.0, 0.0, 0.0);
    float total = 0.0;

    for (int ring = 1; ring <= RINGS; ring++)
    {
        float r = (float)ring / RINGS;
        float weight = exp(-2.0 * r * r);
        for (int spoke = 0; spoke < SPOKES; spoke++)
        {
            // Offset alternate rings so the samples don't line up into visible spokes.
            float angle = TAU * (spoke + 0.5 * (ring % 2)) / SPOKES;
            float2 offset = float2(cos(angle), sin(angle)) * r * texel;
            float4 s = shaderTexture.Sample(samplerState, tex + offset);

            // Only text is bright enough to bloom; the dark background stays clear.
            float mask = smoothstep(0.22, 0.6, luminance(s.rgb));
            glow += s.rgb * mask * weight;
            total += weight;
        }
    }

    glow = glow / total * GLOW_STRENGTH;

    // Fade the glow out wherever there is already text, so glyphs aren't thickened.
    glow *= 1.0 - smoothstep(0.05, 0.4, luminance(color.rgb));

    // Output is premultiplied, so the glow needs matching alpha to show on glass.
    return float4(saturate(color.rgb + glow), saturate(color.a + luminance(glow)));
}
