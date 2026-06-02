import { IncomingMessage, ServerResponse } from 'http';
import { query } from '../../lib/neon';
import { getAuthUser, setCorsHeaders, sendJson, parseBody } from '../../lib/auth';

export default async function handler(req: IncomingMessage, res: ServerResponse) {
  setCorsHeaders(res);
  if (req.method === 'OPTIONS') return sendJson(res, 200, {});

  const user = getAuthUser(req);
  if (!user) return sendJson(res, 401, { error: 'Token tidak valid' });

  const url = new URL(req.url || '/', `http://${req.headers.host}`);
  const conversationId = url.searchParams.get('id');
  const scenarioId = url.searchParams.get('scenario_id');

  try {
    // GET - Riwayat percakapan
    if (req.method === 'GET') {
      if (conversationId) {
        // Ambil satu percakapan dengan semua pesan
        const convs = await query(
          `SELECT c.*, s.title as scenario_title, s.category 
           FROM conversations c 
           JOIN scenarios s ON c.scenario_id = s.id
           WHERE c.id = $1 AND c.user_id = $2`,
          [conversationId, user.userId]
        );
        if (!convs.length) return sendJson(res, 404, { error: 'Percakapan tidak ditemukan' });

        const messages = await query(
          'SELECT * FROM messages WHERE conversation_id = $1 ORDER BY created_at ASC',
          [conversationId]
        );

        const feedback = await query(
          'SELECT * FROM ai_feedback WHERE conversation_id = $1 LIMIT 1',
          [conversationId]
        );

        return sendJson(res, 200, {
          success: true,
          data: { ...convs[0], messages, feedback: feedback[0] || null }
        });
      } else {
        // Ambil semua riwayat
        const filter = scenarioId ? 'AND c.scenario_id = $2' : '';
        const params = scenarioId ? [user.userId, scenarioId] : [user.userId];
        const convs = await query(
          `SELECT c.*, s.title as scenario_title, s.category,
            (SELECT COUNT(*) FROM messages m WHERE m.conversation_id = c.id) as message_count
           FROM conversations c
           JOIN scenarios s ON c.scenario_id = s.id
           WHERE c.user_id = $1 ${filter}
           ORDER BY c.created_at DESC`,
          params
        );
        return sendJson(res, 200, { success: true, data: convs });
      }
    }

    // POST - Buat percakapan baru
    if (req.method === 'POST') {
      const { scenario_id, session_title } = await parseBody(req);
      if (!scenario_id) return sendJson(res, 400, { error: 'scenario_id wajib diisi' });

      const result = await query(
        `INSERT INTO conversations (scenario_id, user_id, session_title) 
         VALUES ($1, $2, $3) RETURNING *`,
        [scenario_id, user.userId, session_title || 'Sesi Baru']
      );
      return sendJson(res, 201, { success: true, data: result[0] });
    }

    // DELETE - Hapus percakapan
    if (req.method === 'DELETE' && conversationId) {
      await query(
        'DELETE FROM conversations WHERE id = $1 AND user_id = $2',
        [conversationId, user.userId]
      );
      return sendJson(res, 200, { success: true, message: 'Percakapan berhasil dihapus' });
    }

    return sendJson(res, 405, { error: 'Method tidak diizinkan' });
  } catch (error) {
    console.error('Conversation error:', error);
    return sendJson(res, 500, { error: 'Terjadi kesalahan server' });
  }
}
