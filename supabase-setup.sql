-- Run this in the Supabase SQL Editor (dashboard.supabase.com → SQL Editor)
-- If re-running, drop old policies first:
--
-- drop policy if exists "Public can read gallery images" on gallery_images;
-- drop policy if exists "Authenticated users can insert gallery images" on gallery_images;
-- drop policy if exists "Authenticated users can delete gallery images" on gallery_images;
-- drop policy if exists "Public can read jobs" on jobs;
-- drop policy if exists "Authenticated users can insert jobs" on jobs;
-- drop policy if exists "Authenticated users can delete jobs" on jobs;
-- drop policy if exists "Authenticated users can upload to gallery" on storage.objects;
-- drop policy if exists "Public can read gallery" on storage.objects;
-- drop policy if exists "Authenticated users can delete from gallery" on storage.objects;

-- 1. Create jobs table
create table if not exists jobs (
  id uuid default gen_random_uuid() primary key,
  name text not null,
  location text,
  created_at timestamptz default now()
);

alter table jobs enable row level security;

create policy "Public can read jobs"
  on jobs for select to anon using (true);

create policy "Authenticated users can insert jobs"
  on jobs for insert to authenticated with check (true);

create policy "Authenticated users can delete jobs"
  on jobs for delete to authenticated using (true);

-- 2. Create gallery_images table (with job_id)
create table if not exists gallery_images (
  id uuid default gen_random_uuid() primary key,
  url text not null,
  caption text,
  job_id uuid references jobs(id) on delete cascade,
  created_at timestamptz default now()
);

alter table gallery_images enable row level security;

create policy "Public can read gallery images"
  on gallery_images for select to anon using (true);

create policy "Authenticated users can insert gallery images"
  on gallery_images for insert to authenticated with check (true);

create policy "Authenticated users can delete gallery images"
  on gallery_images for delete to authenticated using (true);

-- 3. Storage bucket
insert into storage.buckets (id, name, public)
values ('gallery', 'gallery', true)
on conflict (id) do nothing;

-- 4. Storage policies
create policy "Authenticated users can upload to gallery"
  on storage.objects for insert to authenticated
  with check (bucket_id = 'gallery');

create policy "Public can read gallery"
  on storage.objects for select to anon
  using (bucket_id = 'gallery');

create policy "Authenticated users can delete from gallery"
  on storage.objects for delete to authenticated
  using (bucket_id = 'gallery');
