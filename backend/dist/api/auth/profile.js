"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.default = handler;
const neon_1 = require("../../lib/neon");
const auth_1 = require("../../lib/auth");
async function handler(req, res) {
    (0, auth_1.setCorsHeaders)(res);
    if (req.method === 'OPTIONS')
        return (0, auth_1.sendJson)(res, 200, {});
    const user = (0, auth_1.getAuthUser)(req);
    if (!user)
        return (0, auth_1.sendJson)(res, 401, { error: 'Token tidak valid' });
    try {
        if (req.method === 'GET') {
            const users = await (0, neon_1.query)(`SELECT id, username, email, avatar_url, bio, created_at,
          (SELECT COUNT(*) FROM scenarios WHERE user_id = $1 AND is_active = true) as scenario_count,
          (SELECT COUNT(*) FROM conversations WHERE user_id = $1) as conversation_count,
          (SELECT COUNT(*) FROM conversations WHERE user_id = $1 AND is_completed = true) as completed_count,
          (SELECT ROUND(AVG(overall_score)) FROM ai_feedback WHERE user_id = $1) as avg_score
         FROM users WHERE id = $1`, [user.userId]);
            if (!users.length)
                return (0, auth_1.sendJson)(res, 404, { error: 'User tidak ditemukan' });
            return (0, auth_1.sendJson)(res, 200, { success: true, data: users[0] });
        }
        if (req.method === 'PUT') {
            const { username, bio } = await (0, auth_1.parseBody)(req);
            const result = await (0, neon_1.query)('UPDATE users SET username = COALESCE($1, username), bio = COALESCE($2, bio) WHERE id = $3 RETURNING id, username, email, bio', [username, bio, user.userId]);
            return (0, auth_1.sendJson)(res, 200, { success: true, data: result[0], message: 'Profil berhasil diperbarui!' });
        }
        return (0, auth_1.sendJson)(res, 405, { error: 'Method tidak diizinkan' });
    }
    catch (error) {
        console.error('Profile error:', error);
        return (0, auth_1.sendJson)(res, 500, { error: 'Terjadi kesalahan server' });
    }
}
//# sourceMappingURL=profile.js.map