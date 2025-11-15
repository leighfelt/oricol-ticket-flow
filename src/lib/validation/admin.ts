import { z } from 'zod';

export const adminRecoverSchema = z.object({
  email: z.string().email(),
  recoveryCode: z.string().min(8).max(256),
});
