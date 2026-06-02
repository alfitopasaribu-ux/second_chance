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
    const conversationId = url.searchParams.get('id');
    const scenarioId = url.searchParams.get('scenario_id');
    try {
        // GET - Riwayat percakapan
        if (req.method === 'GET') {
            if (conversationId) {
                // Ambil satu percakapan dengan semua pesan
                const convs = await (0, neon_1.query)(`SELECT c.*, s.title as scenario_title, s.category 
           FROM conversations c 
           JOIN scenarios s ON c.scenario_id = s.id
           WHERE c.id = $1 AND c.user_id = $2`, [conversationId, user.userId]);
                if (!convs.length)
                    return (0, auth_1.sendJson)(res, 404, { error: 'Percakapan tidak ditemukan' });
                const messages = await (0, neon_1.query)('SELECT * FROM messages WHERE conversation_id = $1 ORDER BY created_at ASC', [conversationId]);
                const feedback = await (0, neon_1.query)('SELECT * FROM ai_feedback WHERE conversation_id = $1 LIMIT 1', [conversationId]);
                return (0, auth_1.sendJson)(res, 200, {
                    success: true,
                    data: { ...convs[0], messages, feedback: feedback[0] || null }
                });
            }
            else {
                // Ambil semua riwayat
                const filter = scenarioId ? 'AND c.scenario_id = $2' : '';
                const params = scenarioId ? [user.userId, scenarioId] : [user.userId];
                const convs = await (0, neon_1.query)(`SELECT c.*, s.title as scenario_title, s.category,
            (SELECT COUNT(*) FROM messages m WHERE m.conversation_id = c.id) as message_count
           FROM conversations c
           JOIN scenarios s ON c.scenario_id = s.id
           WHERE c.user_id = $1 ${filter}
           ORDER BY c.created_at DESC`, params);
                return (0, auth_1.sendJson)(res, 200, { success: true, data: convs });
            }
        }
        // POST - Buat percakapan baru
        if (req.method === 'POST') {
            const { scenario_id, session_title } = await (0, auth_1.parseBody)(req);
            if (!scenario_id)
                return (0, auth_1.sendJson)(res, 400, { error: 'scenario_id wajib diisi' });
            const result = await (0, neon_1.query)(`INSERT INTO conversations (scenario_id, user_id, session_title) 
         VALUES ($1, $2, $3) RETURNING *`, [scenario_id, user.userId, session_title || 'Sesi Baru']);
            return (0, auth_1.sendJson)(res, 201, { success: true, data: result[0] });
        }
        // DELETE - Hapus percakapan
        if (req.method === 'DELETE' && conversationId) {
            await (0, neon_1.query)('DELETE FROM conversations WHERE id = $1 AND user_id = $2', [conversationId, user.userId]);
            return (0, auth_1.sendJson)(res, 200, { success: true, message: 'Percakapan berhasil dihapus' });
        }
        return (0, auth_1.sendJson)(res, 405, { error: 'Method tidak diizinkan' });
    }
    catch (error) {
        console.error('Conversation error:', error);
        return (0, auth_1.sendJson)(res, 500, { error: 'Terjadi kesalahan server' });
    }
}
//# sourceMappingURL=index.js.map