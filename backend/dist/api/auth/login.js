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
        const { email, password } = await (0, auth_1.parseBody)(req);
        if (!email || !password) {
            return (0, auth_1.sendJson)(res, 400, { error: 'Email dan password wajib diisi' });
        }
        const users = await (0, neon_1.query)('SELECT id, username, email, password_hash, avatar_url, bio FROM users WHERE email = $1 LIMIT 1', [email]);
        if (users.length === 0) {
            return (0, auth_1.sendJson)(res, 401, { error: 'Email atau password salah' });
        }
        const user = users[0];
        const isValid = await bcryptjs_1.default.compare(password, user.password_hash);
        if (!isValid) {
            return (0, auth_1.sendJson)(res, 401, { error: 'Email atau password salah' });
        }
        const token = (0, auth_1.generateToken)({ userId: user.id, email: user.email, username: user.username });
        return (0, auth_1.sendJson)(res, 200, {
            success: true,
            message: `Selamat datang kembali, ${user.username}!`,
            token,
            user: {
                id: user.id,
                username: user.username,
                email: user.email,
                avatarUrl: user.avatar_url,
                bio: user.bio
            }
        });
    }
    catch (error) {
        console.error('Login error:', error);
        return (0, auth_1.sendJson)(res, 500, { error: 'Terjadi kesalahan server' });
    }
}
//# sourceMappingURL=login.js.map