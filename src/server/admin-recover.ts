// Minimal server endpoint to replace client-side hardcoded admin recovery.
import express from 'express';
import { z } from 'zod';
import { pool } from '../db'; // adjust to your DB connection helper
import bcrypt from 'bcryptjs';

const router = express.Router();

const bodySchema = z.object({ email: z.string().email(), recoveryCode: z.string().min(8) });

router.post('/api/admin/recover', async (req, res) => {
  const parsed = bodySchema.safeParse(req.body);
  if (!parsed.success) return res.status(400).json({ error: parsed.error });
  const { email, recoveryCode } = parsed.data;

  try {
    const row = await pool.query('SELECT recovery_code_hash FROM admins WHERE email = $1', [email]);
    if (!row || row.rowCount === 0) return res.status(404).json({ error: 'Not found' });
    const hash = row.rows[0].recovery_code_hash;
    const ok = await bcrypt.compare(recoveryCode, hash);
    if (!ok) return res.status(401).json({ error: 'Unauthorized' });

    // Issue a short-lived token or mark session as admin - implementation-specific
    return res.json({ ok: true });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: 'Internal Server Error' });
  }
});

export default router;
