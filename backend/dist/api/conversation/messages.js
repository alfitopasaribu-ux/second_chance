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
    const url = new URL(req.url || '/', `http://${req.headers.host}`);
    const conversationId = url.searchParams.get('conversation_id');
    try {
        if (req.method === 'GET' && conversationId) {
            // Verifikasi conversation milik user ini
            const convs = await (0, neon_1.query)('SELECT id FROM conversations WHERE id = $1 AND user_id = $2', [conversationId, user.userId]);
            if (!convs.length)
                return (0, auth_1.sendJson)(res, 404, { error: 'Percakapan tidak ditemukan' });
            const messages = await (0, neon_1.query)('SELECT * FROM messages WHERE conversation_id = $1 ORDER BY created_at ASC', [conversationId]);
            return (0, auth_1.sendJson)(res, 200, { success: true, data: messages });
        }
        return (0, auth_1.sendJson)(res, 405, { error: 'Method tidak diizinkan' });
    }
    catch (error) {
        console.error('Messages error:', error);
        return (0, auth_1.sendJson)(res, 500, { error: 'Terjadi kesalahan server' });
    }
}
//# sourceMappingURL=messages.js.map