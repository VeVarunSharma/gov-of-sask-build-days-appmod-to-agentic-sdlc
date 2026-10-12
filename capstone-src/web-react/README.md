# Work items web

React + TypeScript + Vite client for the capstone starter. See the parent
[`README.md`](../README.md) for setup, API selection, safety rules, tests, and
container commands.

## Commands

Run from `capstone-src\web-react`:

```powershell
npm ci --no-audit --no-fund
npm run dev
npm run lint
npm test
npm run build
```

Copy `.env.example` to `.env.local` for local configuration. The default API is
Java at `http://localhost:8080`; use
`VITE_API_BASE_URL=http://localhost:8081` for .NET. Never commit `.env.local`.

The client must not be the only validation boundary. Keep validation in the
selected API and update client, contract, API, and tests together when changing
the resource shape.
