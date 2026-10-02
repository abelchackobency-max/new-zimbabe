-- Zimbabe Creation setup
-- Run this entire file in Supabase -> SQL Editor -> Run.

create table if not exists products (
  id text primary key,
  title text not null,
  price numeric not null default 0,
  image_url text,
  active boolean not null default true,
  created_at timestamptz not null default now()
);

insert into products (id, title, price, image_url, active)
values
  ('p1', 'Classic Crochet Teddy Bear', 2000, '', true),
  ('p2', 'Cozy Fall Beanie Hat', 1500, '', true)
on conflict (id) do nothing;

alter table products enable row level security;

drop policy if exists "Public can read products" on products;
drop policy if exists "Public can add products" on products;
drop policy if exists "Public can update products" on products;
drop policy if exists "Public can delete products" on products;

create policy "Public can read products"
on products for select to anon using (true);

create policy "Public can add products"
on products for insert to anon with check (true);

create policy "Public can update products"
on products for update to anon using (true) with check (true);

create policy "Public can delete products"
on products for delete to anon using (true);

-- Product image storage bucket
insert into storage.buckets (id, name, public)
values ('product-images', 'product-images', true)
on conflict (id) do update set public = true;

-- Storage policies for product images
 drop policy if exists "Public can upload product images" on storage.objects;
 drop policy if exists "Public can read product images" on storage.objects;
 drop policy if exists "Public can delete product images" on storage.objects;

create policy "Public can upload product images"
on storage.objects for insert to anon
with check (bucket_id = 'product-images');

create policy "Public can read product images"
on storage.objects for select to anon
using (bucket_id = 'product-images');

create policy "Public can delete product images"
on storage.objects for delete to anon
using (bucket_id = 'product-images');

-- Make sure the admin can update order status and delivery dates.
 drop policy if exists "Allow public order updates" on orders;
create policy "Allow public order updates"
on orders for update to anon
using (true) with check (true);
