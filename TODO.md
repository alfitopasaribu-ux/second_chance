# TODO - Deploy & Fix Vercel (Second Chance)

## Plan
- [ ] Fix backend Vercel routing so `/api/*` works
- [ ] Update `backend/vercel.json` to build TypeScript and route to `dist/api/*`
- [ ] Commit changes and redeploy backend project on Vercel
- [ ] Update Flutter `baseUrl` to backend domain
- [ ] Verify endpoints: `/api/auth/login`, `/api/ai/chat`, `/api/analysis`

## Notes
- Saat ini frontend domain memunculkan 404, backend endpoints juga 404.
- RootDirectory backend sudah benar (`backend/`), tapi kemungkinan output functions belum sesuai.

