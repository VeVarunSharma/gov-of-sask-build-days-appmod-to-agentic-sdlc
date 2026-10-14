# React client local guide

Agents should read the repository [root guide](../../AGENTS.md) plus this
nearest local guide; do not assume one file automatically overrides another.

## Scope map

- `src/App.tsx` and `src/App.css` hold the starter work-item experience.
- `src/App.test.tsx` and `src/test/setup.ts` hold Vitest/Testing Library setup.
- `src/main.tsx` is the Vite entry point; `package.json`, TypeScript configs,
  `.oxlintrc.json`, and `vite.config.ts` define the toolchain.
- The shared API shape is owned by
  [`../contracts/openapi.yml`](../contracts/openapi.yml), not this subtree.

## Work and validate

Use `capstone-src\web-react` as the working directory:

```powershell
npm ci --no-audit --no-fund
npm run lint
npm test
npm run build
npm run dev
```

Run lint, tests, and build for behavior changes; `dev` is only the local
server. Use accessible Testing Library queries and verify user-visible states.

## Boundaries

- Keep strict TypeScript, React function components, accessible semantic HTML,
  and server-side validation in the selected API.
- Do not hand-edit `node_modules/`, `dist/`, coverage output, or
  `package-lock.json`; update the lock through npm when dependencies change.
- Copy `.env.example` to untracked `.env.local`. `VITE_*` values are exposed to
  the browser, so never place secrets, credentials, tokens, real personal
  data, or production-only endpoints in them.

## More detail

Follow the
[React/TypeScript instructions](../../.github/instructions/react-typescript.instructions.md),
the [capstone starter guide](../README.md), and the
[React plus API pathway](../../labs/07-capstone/pathways/02-public-service-app.md).
Keep approved requirements under [specifications](../../specs/README.md).
Escalate contract, backend, deployment, or multi-root changes to the root guide
and read the selected API's local guide.
