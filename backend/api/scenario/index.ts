import { IncomingMessage, ServerResponse } from 'http';
import { query } from '../../lib/neon';
import { getAuthUser, setCorsHeaders, sendJson, parseBody } from '../../lib/auth';

export default async function handler(req: IncomingMessage, res: ServerResponse) {
  setCorsHeaders(res);
  if (req.method === 'OPTIONS') return sendJson(res, 200, {});

  const user = getAuthUser(req);
  if (!user) return sendJson(res, 401, { error: 'Token tidak valid atau sudah kadaluarsa' });

  const url = new URL(req.url || '/', `http://${req.headers.host}`);
  const scenarioId = url.searchParams.get('id');

  try {
    // GET - Ambil semua scenario milik user
    if (req.method === 'GET' && !scenarioId) {
      const scenarios = await query(
        `SELECT s.*, 
          (SELECT COUNT(*) FROM conversations c WHERE c.scenario_id = s.id) as conversation_count
         FROM scenarios s 
         WHERE s.user_id = $1 AND s.is_active = true
         ORDER BY s.created_at DESC`,
        [user.userId]
      );
      return sendJson(res, 200, { success: true, data: scenarios });
    }

    // GET - Ambil satu scenario
    if (req.method === 'GET' && scenarioId) {
      const scenarios = await query(
        'SELECT * FROM scenarios WHERE id = $1 AND user_id = $2',
        [scenarioId, user.userId]
      );
      if (!scenarios.length) return sendJson(res, 404, { error: 'Skenario tidak ditemukan' });
      return sendJson(res, 200, { success: true, data: scenarios[0] });
    }

    // POST - Buat scenario baru
    if (req.method === 'POST') {
      const { title, category, emotional_goal, description, difficulty_level } = await parseBody(req);
      if (!title || !category || !emotional_goal) {
        return sendJson(res, 400, { error: 'Judul, kategori, dan tujuan emosional wajib diisi' });
      }
      const result = await query(
        `INSERT INTO scenarios (user_id, title, category, emotional_goal, description, difficulty_level) 
         VALUES ($1, $2, $3, $4, $5, $6) 
         RETURNING *`,
        [user.userId, title, category, emotional_goal, description || '', difficulty_level || 1]
      );
      return sendJson(res, 201, { success: true, data: result[0], message: 'Skenario berhasil dibuat!' });
    }

    // PUT - Update scenario
    if (req.method === 'PUT' && scenarioId) {
      const { title, category, emotional_goal, description, difficulty_level } = await parseBody(req);
      const result = await query(
        `UPDATE scenarios 
         SET title = COALESCE($1, title), 
             category = COALESCE($2, category),
             emotional_goal = COALESCE($3, emotional_goal),
             description = COALESCE($4, description),
             difficulty_level = COALESCE($5, difficulty_level)
         WHERE id = $6 AND user_id = $7
         RETURNING *`,
        [title, category, emotional_goal, description, difficulty_level, scenarioId, user.userId]
      );
      if (!result.length) return sendJson(res, 404, { error: 'Skenario tidak ditemukan' });
      return sendJson(res, 200, { success: true, data: result[0], message: 'Skenario berhasil diperbarui!' });
    }

    // DELETE - Hapus scenario (soft delete)
    if (req.method === 'DELETE' && scenarioId) {
      const result = await query(
        'UPDATE scenarios SET is_active = false WHERE id = $1 AND user_id = $2 RETURNING id',
        [scenarioId, user.userId]
      );
      if (!result.length) return sendJson(res, 404, { error: 'Skenario tidak ditemukan' });
      return sendJson(res, 200, { success: true, message: 'Skenario berhasil dihapus' });
    }

    return sendJson(res, 405, { error: 'Method tidak diizinkan' });
  } catch (error) {
    console.error('Scenario error:', error);
    return sendJson(res, 500, { error: 'Terjadi kesalahan server' });
  }
}
