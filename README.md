# 🚀 SECOND CHANCE — AI Emotional Conversation Simulator

> *"Berlatih. Merasakan. Berkembang."*

Aplikasi simulator percakapan emosional berbasis AI yang futuristik. Berlatih komunikasi emosional dengan AI yang realistis dan manusiawi.

---

## ⚡ TECH STACK

| Layer | Teknologi |
|-------|-----------|
| Frontend | Flutter + Riverpod + GoRouter |
| Backend | Vercel Serverless Functions (TypeScript) |
| Database | NeonDB (PostgreSQL) |
| AI | Groq API (LLaMA 3.3 70B) |
| Auth | JWT |

---

## 📁 STRUKTUR PROJECT

```
second_chance/
├── NEONDB_SQL_SCHEMA.sql     ← Paste ke SQL Editor NeonDB
├── backend/                  ← Vercel Backend
│   ├── api/
│   │   ├── auth/
│   │   │   ├── login.ts
│   │   │   ├── register.ts
│   │   │   └── profile.ts
│   │   ├── ai/
│   │   │   └── chat.ts
│   │   ├── scenario/
│   │   │   └── index.ts
│   │   ├── conversation/
│   │   │   ├── index.ts
│   │   │   └── messages.ts
│   │   └── analysis/
│   │       └── index.ts
│   ├── lib/
│   │   ├── neon.ts
│   │   └── auth.ts
│   ├── .env.example
│   ├── package.json
│   ├── tsconfig.json
│   └── vercel.json
└── flutter_app/              ← Flutter Frontend
    ├── lib/
    │   ├── main.dart
    │   ├── core/
    │   │   ├── constants/
    │   │   ├── theme/
    │   │   ├── router/
    │   │   └── providers/
    │   └── presentation/
    │       ├── screens/
    │       │   ├── splash/
    │       │   ├── auth/
    │       │   ├── dashboard/
    │       │   ├── scenario/
    │       │   ├── chat/
    │       │   ├── analysis/
    │       │   ├── history/
    │       │   └── profile/
    │       └── widgets/
    └── pubspec.yaml
```

---

## 🗄️ LANGKAH 1: Setup Database NeonDB

1. Buka [console.neon.tech](https://console.neon.tech)
2. Buat project baru
3. Buka **SQL Editor**
4. Copy-paste seluruh isi file `NEONDB_SQL_SCHEMA.sql`
5. Klik **Run**
6. Verifikasi 6 tabel terbuat: `users`, `scenarios`, `conversations`, `messages`, `ai_feedback`, `emotional_notes`

---

## 🔑 LANGKAH 2: Dapatkan API Keys

### Groq API Key
1. Buka [console.groq.com](https://console.groq.com)
2. Daftar/Login
3. Buat API Key baru
4. Simpan key-nya

### NeonDB Connection String
1. Di Neon Console → Project Settings → Connection Details
2. Copy **Connection string** (format postgresql://...)

---

## 🚀 LANGKAH 3: Deploy Backend ke Vercel

```bash
cd backend

# Install dependencies
npm install

# Copy env file
cp .env.example .env.local
# Edit .env.local dan isi semua variabel

# Install Vercel CLI
npm i -g vercel

# Deploy
vercel deploy --prod
```

Setelah deploy, Vercel akan memberikan URL seperti:
`https://second-chance-xxx.vercel.app`

---

## 📱 LANGKAH 4: Setup Flutter App

### 1. Update Backend URL

Buka file:
```
flutter_app/lib/core/constants/app_constants.dart
```

Ganti:
```dart
static const String baseUrl = 'https://second-chance-api.vercel.app';
```
Dengan URL Vercel kamu yang asli.

### 2. Buat folder assets
```bash
cd flutter_app
mkdir -p assets/images assets/animations assets/fonts
```

### 3. Install dependencies & run
```bash
flutter pub get
flutter run
```

---

## 🎯 FITUR LENGKAP

- ✅ **Authentication** — Login & Register dengan JWT
- ✅ **Splash Screen** — Animated futuristic intro
- ✅ **Dashboard** — Stats, kategori, riwayat terbaru
- ✅ **Scenario System** — 8 template + custom CRUD
- ✅ **AI Chat** — Groq LLaMA 3.3 70B, realistis & emosional
- ✅ **Emotional Tone** — Real-time deteksi emosi AI
- ✅ **Analysis Screen** — Skor empati, kejujuran, kepercayaan diri, ketegangan
- ✅ **History Screen** — Riwayat semua percakapan + hapus
- ✅ **Profile Screen** — Stats personal + logout
- ✅ **Glassmorphism UI** — Dark mode, neon glow, floating particles
- ✅ **Full CRUD** — Scenario & Conversation

---

## 🎨 KATEGORI SKENARIO

| Emoji | Skenario |
|-------|----------|
| 🙏 | Meminta Maaf |
| 💬 | Pengakuan (Confession) |
| 💼 | Interview Kerja |
| 👨‍👩‍👧 | Bicara dengan Orang Tua |
| ⚡ | Menghadapi Toxic Friend |
| 💔 | Perpisahan (Breakup) |
| 🎤 | Public Speaking |
| ❤️ | Komunikasi Emosional |

---

## 🌐 API ENDPOINTS

| Method | Endpoint | Deskripsi |
|--------|----------|-----------|
| POST | `/api/auth/register` | Daftar akun |
| POST | `/api/auth/login` | Login |
| GET | `/api/auth/profile` | Profil user |
| GET/POST/PUT/DELETE | `/api/scenario` | CRUD Skenario |
| GET/POST/DELETE | `/api/conversation` | CRUD Percakapan |
| GET | `/api/conversation/messages` | Pesan percakapan |
| POST | `/api/ai/chat` | Kirim pesan ke AI |
| POST | `/api/analysis` | Analisis emosi |

---

## 🔐 ENVIRONMENT VARIABLES

```env
GROQ_API_KEY=gsk_...
DATABASE_URL=postgresql://...
JWT_SECRET=your_super_secret_key
```

---

*© 2045 Second Chance AI — Emotional Intelligence Platform*
