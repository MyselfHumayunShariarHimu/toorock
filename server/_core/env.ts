/**
 * Runtime environment bridge.
 *
 * The original source archive references this module, but the deployment
 * bundle is intentionally self-contained. Expose process.env through a
 * string-indexed object so existing server modules can read their expected
 * environment keys without requiring a platform-specific generated file.
 */
export const ENV = process.env as Record<string, string | undefined>;
