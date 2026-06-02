"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.default = handler;
const bcryptjs_1 = __importDefault(require("bcryptjs"));
const neon_1 = require("../../lib/neon");
const auth_1 = require("../../lib/auth");
async function handler(req, res) {
    (0, auth_1.setCorsHeaders)(res);
    if (req.method === 'OPTIONS')
        return (0, auth_1.sendJson)(res, 200, {});
    if (req.method !== 'POST') {
        return (0, auth_1.sendJson)(res, 405, { error: 'Method tidak diizinkan' });
    }
    try {
        const { username, email, password } = await (0, auth_1.parseBody)(req);
        if (!username || !email || !password) {
            return (0, auth_1.sendJson)(res, 400, { error: 'Username, email, dan password wajib diisi' });
        }
        if (password.length < 6) {
            return (0, auth_1.sendJson)(res, 400, { error: 'Password minimal 6 karakter' });
        }
        // Cek apakah email/username sudah ada
        const existing = await (0, neon_1.query)('SELECT id FROM users WHERE email = $1 OR username = $2 LIMIT 1', [email, username]);
        if (existing.length > 0) {
            return (0, auth_1.sendJson)(res, 409, { error: 'Email atau username sudah terdaftar' });
        }
        // Hash password
        const passwordHash = await bcryptjs_1.default.hash(password, 10);
        // Insert user
        const users = await (0, neon_1.query)('INSERT INTO users (username, email, password_hash) VALUES ($1, $2, $3) RETURNING id, username, email, created_at', [username, email, passwordHash]);
        const user = users[0];
        const token = (0, auth_1.generateToken)({ userId: user.id, email: user.email, username: user.username });
        return (0, auth_1.sendJson)(res, 201, {
            success: true,
            message: 'Akun berhasil dibuat! Selamat datang di Second Chance.',
            token,
            user: { id: user.id, username: user.username, email: user.email }
        });
    }
    catch (error) {
        console.error('Register error:', error);
        return (0, auth_1.sendJson)(res, 500, { error: 'Terjadi kesalahan server' });
    }
}
//# sourceMappingURL=register.js.map