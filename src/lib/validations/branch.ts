import { z } from "zod";

export const branchSchema = z.object({
  name: z.string()
    .min(1, "Branch name is required")
    .max(200, "Branch name must be less than 200 characters"),
  
  address: z.string()
    .max(500, "Address must be less than 500 characters")
    .transform(val => val || undefined)
    .optional(),
  
  city: z.string()
    .max(100, "City must be less than 100 characters")
    .transform(val => val || undefined)
    .optional(),
  
  state: z.string()
    .max(100, "State must be less than 100 characters")
    .transform(val => val || undefined)
    .optional(),
  
  postal_code: z.string()
    .max(20, "Postal code must be less than 20 characters")
    .transform(val => val || undefined)
    .optional(),
  
  country: z.string()
    .max(100, "Country must be less than 100 characters")
    .transform(val => val || undefined)
    .optional(),
  
  phone: z.string()
    .max(50, "Phone must be less than 50 characters")
    .regex(/^$|^[+]?[(]?[0-9]{1,4}[)]?[-\s.]?[(]?[0-9]{1,4}[)]?[-\s.]?[0-9]{1,9}$/, "Invalid phone number format")
    .transform(val => val || undefined)
    .optional(),
  
  email: z.string()
    .email("Invalid email address")
    .or(z.literal(""))
    .transform(val => val || undefined)
    .optional(),
  
  notes: z.string()
    .max(2000, "Notes must be less than 2000 characters")
    .transform(val => val || undefined)
    .optional(),
});

export type BranchFormData = z.infer<typeof branchSchema>;
