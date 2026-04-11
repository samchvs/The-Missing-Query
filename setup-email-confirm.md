# Enabling Email Confirmation (When Ready for Production)

Currently email confirmation is **OFF** so signup works immediately during development.
Follow these steps when you are ready to require users to verify their email.

---

## Step 1 — Create the Database Trigger

Go to **Supabase Dashboard → SQL Editor** and run this once:

```sql
-- Function: auto-creates a profile row when a new user signs up
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, username, email)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'username', 'user'),
    new.email
  );
  return new;
end;
$$ language plpgsql security definer;

-- Trigger: fires after every new row in auth.users
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();
```

> **Why this is needed:** When email confirmation is ON, Supabase does not create
> a live session after signup. The app can't insert into `profiles` without a session
> (RLS blocks it). This trigger runs inside Postgres with elevated permissions,
> so it bypasses RLS and creates the row automatically.

---

## Step 2 — Turn On Email Confirmation in Supabase

1. Go to **Supabase Dashboard → Authentication → Providers → Email**
2. Toggle **"Confirm email"** → **ON**
3. Click **Save**

---

## Step 3 — No Flutter Code Changes Needed

The `SupabaseAuthDataSource.signUp()` method already handles both cases:

- **Session exists** (confirm email OFF) → inserts profile row directly
- **No session** (confirm email ON) → trigger already created the row

---

## Step 4 — Optional: Customize the Confirmation Email

Go to **Supabase Dashboard → Authentication → Email Templates → Confirm signup**
and customize the subject and body to match your game's branding.

---

## Rollback

To go back to no confirmation (dev mode): just turn the toggle OFF again in Step 2.
The trigger does no harm either way — leave it in place.
