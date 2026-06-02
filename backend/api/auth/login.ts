import { IncomingMessage, ServerResponse } from 'http';
import bcrypt from 'bcryptjs';
import { query } from '../../lib/neon';
import { generateToken, setCorsHeaders, sendJson, parseBody } from '../../lib/auth';

export default async function handler(req: IncomingMessage, res: ServerResponse) {
  setCorsHeaders(res);
  if (req.method === 'OPTIONS') return sendJson(res, 200, {});

  if (req.method !== 'POST') {
    return sendJson(res, 405, { error: 'Method tidak diizinkan' });
  }

  try {
    const { email, password } = await parseBody(req);

    if (!email || !password) {
      return sendJson(res, 400, { error: 'Email dan password wajib diisi' });
    }

    const users = await query(
      'SELECT id, username, email, password_hash, avatar_url, bio FROM users WHERE email = $1 LIMIT 1',
      [email]
    );

    if (users.length === 0) {
      return sendJson(res, 401, { error: 'Email atau password salah' });
    }

    const user = users[0];
    const isValid = await bcrypt.compare(password, user.password_hash);

    if (!isValid) {
      return sendJson(res, 401, { error: 'Email atau password salah' });
    }

    const token = generateToken({ userId: user.id, email: user.email, username: user.username });

    return sendJson(res, 200, {
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
  } catch (error: any) {
    console.error('Login error:', error);
    return sendJson(res, 500, { error: 'Terjadi kesalahan server' });
  }
}
