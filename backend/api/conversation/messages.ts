import { IncomingMessage, ServerResponse } from 'http';
import { query } from '../../lib/neon';
import { getAuthUser, setCorsHeaders, sendJson, parseBody } from '../../lib/auth';

export default async function handler(req: IncomingMessage, res: ServerResponse) {
  setCorsHeaders(res);
  if (req.method === 'OPTIONS') return sendJson(res, 200, {});

  const user = getAuthUser(req);
  if (!user) return sendJson(res, 401, { error: 'Token tidak valid' });

  const url = new URL(req.url || '/', `http://${req.headers.host}`);
  const conversationId = url.searchParams.get('conversation_id');

  try {
    if (req.method === 'GET' && conversationId) {
      // Verifikasi conversation milik user ini
      const convs = await query(
        'SELECT id FROM conversations WHERE id = $1 AND user_id = $2',
        [conversationId, user.userId]
      );
      if (!convs.length) return sendJson(res, 404, { error: 'Percakapan tidak ditemukan' });

      const messages = await query(
        'SELECT * FROM messages WHERE conversation_id = $1 ORDER BY created_at ASC',
        [conversationId]
      );
      return sendJson(res, 200, { success: true, data: messages });
    }

    return sendJson(res, 405, { error: 'Method tidak diizinkan' });
  } catch (error) {
    console.error('Messages error:', error);
    return sendJson(res, 500, { error: 'Terjadi kesalahan server' });
  }
}
