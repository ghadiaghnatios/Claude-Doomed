# Security (always loaded)

- Never read, print, log, or commit secrets. Config comes from env vars; keep `.env.example` in sync with every var the app reads.
- Validate and type-check all external input at the boundary (HTTP, CLI args, files, webhooks, LLM output).
- Parameterized queries only. No string-built SQL, shell commands, or HTML.
- Every endpoint/action checks authz, not just authn. Deny by default.
- Encode output for its context (HTML, URL, shell). Set security headers and strict CORS on web servers.
- Pin dependencies via the lockfile.
- Errors shown to users never include stack traces, SQL, or internal paths.
