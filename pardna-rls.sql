-- ═══════════════════════════════════════════════════════════════════════════
-- Pardna: lock the database so only the signed-in organizer can make changes.
--
-- HOW TO RUN
--   1. Supabase Dashboard → SQL Editor → New query
--   2. Paste this whole file
--   3. Replace YOUR_EMAIL_HERE (both places it appears per table) with the
--      email of your organizer account — must match exactly
--   4. Click Run
--
-- WHAT IT DOES
--   • Everyone can still READ  → member links keep working, no accounts
--   • Anyone can still SUBMIT  → onboarding forms and messages arrive as usual
--   • Only YOUR signed-in account can CHANGE anything else
-- ═══════════════════════════════════════════════════════════════════════════

-- 1) Remove the old wide-open development policies
do $$
declare p record;
begin
  for p in
    select schemaname, tablename, policyname
    from pg_policies
    where schemaname = 'public'
      and tablename in ('groups','members','payments','submissions')
  loop
    execute format('drop policy %I on %I.%I', p.policyname, p.schemaname, p.tablename);
  end loop;
end $$;

-- 2) Make sure row-level security is switched on
alter table public.groups      enable row level security;
alter table public.members     enable row level security;
alter table public.payments    enable row level security;
alter table public.submissions enable row level security;

-- 3) Everyone may read
create policy "public read" on public.groups      for select using (true);
create policy "public read" on public.members     for select using (true);
create policy "public read" on public.payments    for select using (true);
create policy "public read" on public.submissions for select using (true);

-- 4) Anyone may drop a form in the mailbox (onboarding + messages)
create policy "public submit" on public.submissions for insert with check (true);

-- 5) Only the organizer may change anything
create policy "organizer write" on public.groups for all
  using      (auth.jwt()->>'email' = 'YOUR_EMAIL_HERE')
  with check (auth.jwt()->>'email' = 'YOUR_EMAIL_HERE');

create policy "organizer write" on public.members for all
  using      (auth.jwt()->>'email' = 'YOUR_EMAIL_HERE')
  with check (auth.jwt()->>'email' = 'YOUR_EMAIL_HERE');

create policy "organizer write" on public.payments for all
  using      (auth.jwt()->>'email' = 'YOUR_EMAIL_HERE')
  with check (auth.jwt()->>'email' = 'YOUR_EMAIL_HERE');

create policy "organizer update" on public.submissions for update
  using      (auth.jwt()->>'email' = 'YOUR_EMAIL_HERE')
  with check (auth.jwt()->>'email' = 'YOUR_EMAIL_HERE');

create policy "organizer delete" on public.submissions for delete
  using      (auth.jwt()->>'email' = 'YOUR_EMAIL_HERE');
