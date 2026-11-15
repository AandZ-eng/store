-- Run in Supabase SQL Editor to prevent browser clients from reading admin credentials
-- or changing products directly. The admin-api Edge Function uses the server-only
-- service role key; public clients have read-only access to active products and images.

alter table public.admins enable row level security;
alter table public.products enable row level security;
alter table public.product_images enable row level security;

revoke all on table public.admins from anon, authenticated;
revoke all on table public.products from anon, authenticated;
revoke all on table public.product_images from anon, authenticated;

grant select on table public.products, public.product_images to anon, authenticated;

drop policy if exists "az_public_read_active_products" on public.products;
create policy "az_public_read_active_products"
on public.products
for select
to anon, authenticated
using (active = true);

drop policy if exists "az_public_read_active_product_images" on public.product_images;
create policy "az_public_read_active_product_images"
on public.product_images
for select
to anon, authenticated
using (
  exists (
    select 1
    from public.products
    where products.id = product_images.product_id
      and products.active = true
  )
);
