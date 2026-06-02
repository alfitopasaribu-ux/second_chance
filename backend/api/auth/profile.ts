import { IncomingMessage, ServerResponse } from 'http';
import { query } from '../../lib/neon';
import { getAuthUser, setCorsHeaders, sendJson, parseBody } from '../../lib/auth';

export default async function handler(req: IncomingMessage, res: ServerResponse) {
  setCorsHeaders(res);
  if (req.method === 'OPTIONS') return sendJson(res, 200, {});

  const user = getAuthUser(req);
  if (!user) return sendJson(res, 401, { error: 'Token tidak valid' });

  try {
    if (req.method === 'GET') {
      const users = await query(
        `SELECT id, username, email, avatar_url, bio, created_at,
          (SELECT COUNT(*) FROM scenarios WHERE user_id = $1 AND is_active = true) as scenario_count,
          (SELECT COUNT(*) FROM conversations WHERE user_id = $1) as conversation_count,
          (SELECT COUNT(*) FROM conversations WHERE user_id = $1 AND is_completed = true) as completed_count,
          (SELECT ROUND(AVG(overall_score)) FROM ai_feedback WHERE user_id = $1) as avg_score
         FROM users WHERE id = $1`,
        [user.userId]
      );
      if (!users.length) return sendJson(res, 404, { error: 'User tidak ditemukan' });
      return sendJson(res, 200, { success: true, data: users[0] });
    }

    if (req.method === 'PUT') {
      const { username, bio } = await parseBody(req);
      const result = await query(
        'UPDATE users SET username = COALESCE($1, username), bio = COALESCE($2, bio) WHERE id = $3 RETURNING id, username, email, bio',
        [username, bio, user.userId]
      );
      return sendJson(res, 200, { success: true, data: result[0], message: 'Profil berhasil diperbarui!' });
    }

    return sendJson(res, 405, { error: 'Method tidak diizinkan' });
  } catch (error) {
    console.error('Profile error:', error);
    return sendJson(res, 500, { error: 'Terjadi kesalahan server' });
  }
}
