#!/bin/bash
# ============================================================
# SECOND CHANCE — Setup Script
# Jalankan: bash setup.sh
# ============================================================

echo ""
echo "╔══════════════════════════════════════╗"
echo "║       SECOND CHANCE AI SETUP         ║"
echo "║   AI Emotional Conversation Sim      ║"
echo "╚══════════════════════════════════════╝"
echo ""

# Warna
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${CYAN}[1/4] Setup Backend...${NC}"
cd backend
if [ ! -f ".env.local" ]; then
  cp .env.example .env.local
  echo -e "${YELLOW}  ⚠  .env.local dibuat dari .env.example${NC}"
  echo -e "${YELLOW}  ⚠  WAJIB isi GROQ_API_KEY dan DATABASE_URL di backend/.env.local${NC}"
else
  echo -e "${GREEN}  ✓  .env.local sudah ada${NC}"
fi

echo ""
echo -e "${CYAN}[2/4] Install Backend Dependencies...${NC}"
npm install
echo -e "${GREEN}  ✓  Backend dependencies installed${NC}"

echo ""
echo -e "${CYAN}[3/4] Setup Flutter App...${NC}"
cd ../flutter_app
flutter pub get
echo -e "${GREEN}  ✓  Flutter dependencies installed${NC}"

echo ""
echo -e "${CYAN}[4/4] Cek Flutter Doctor...${NC}"
flutter doctor --android-licenses 2>/dev/null || true

echo ""
echo "╔══════════════════════════════════════════════════════╗"
echo "║              SETUP SELESAI!                          ║"
echo "╠══════════════════════════════════════════════════════╣"
echo "║  LANGKAH SELANJUTNYA:                                ║"
echo "║                                                      ║"
echo "║  1. Paste NEONDB_SQL_SCHEMA.sql ke SQL Editor Neon   ║"
echo "║  2. Isi backend/.env.local dengan API keys kamu      ║"
echo "║  3. Deploy backend: cd backend && vercel deploy      ║"
echo "║  4. Update baseUrl di flutter_app/lib/core/          ║"
echo "║     constants/app_constants.dart                     ║"
echo "║  5. Run Flutter: cd flutter_app && flutter run       ║"
echo "╚══════════════════════════════════════════════════════╝"
echo ""
