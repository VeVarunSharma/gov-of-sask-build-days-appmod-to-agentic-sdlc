---
applyTo: "capstone-src/web-react/**/*.ts,capstone-src/web-react/**/*.tsx,capstone-src/web-react/package.json,capstone-src/web-react/*.json"
---

# React and TypeScript

- Keep the React application inside `capstone-src/web-react`; do not place UI
  code in either backend track.
- Use TypeScript's existing strictness and React function components. Prefer
  explicit domain types, accessible semantic HTML, and small components over
  implicit `any`, broad casts, or framework abstractions not already needed.
- Test user-visible behavior with Testing Library. Query by accessible role or
  label and avoid assertions against implementation details.
- Keep API assumptions aligned with `capstone-src/contracts/openapi.yml`. If a
  contract change is required, call it out before changing the client.
- From `capstone-src/web-react`, run `npm test`, `npm run lint`, and
  `npm run build` for behavior changes. Do not edit `node_modules/` or generated
  build output.
