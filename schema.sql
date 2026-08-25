create extension if not exists pgcrypto;

create table if not exists public.orders (
 id uuid primary key default gen_random_uuid(),
 order_code text unique not null,
 roblox_username text not null,
 robux integer not null check (robux > 0),
 amount_vnd bigint not null check (amount_vnd > 0),
 status text not null default 'pending_payment' check (status in ('pending_payment','paid','delivering','completed','cancelled')),
 payment_reference text,
 created_at timestamptz not null default now(),
 paid_at timestamptz
);

create index if not exists orders_status_idx on public.orders(status);
create index if not exists orders_created_idx on public.orders(created_at desc);

create table if not exists public.admin_users (
 user_id uuid primary key references auth.users(id) on delete cascade,
 role text not null default 'admin' check (role in ('admin')),
 created_at timestamptz not null default now()
);

alter table public.orders enable row level security;
alter table public.admin_users enable row level security;

-- Khách chỉ được tạo đơn mới ở trạng thái chờ thanh toán.
drop policy if exists "public can create orders" on public.orders;
create policy "public can create orders"
on public.orders for insert
to anon, authenticated
with check (status = 'pending_payment');

-- Chỉ admin được xem danh sách đơn hàng.
drop policy if exists "admins can read orders" on public.orders;
create policy "admins can read orders"
on public.orders for select
to authenticated
using (exists (select 1 from public.admin_users a where a.user_id = auth.uid()));

-- Chỉ admin được đổi trạng thái/thông tin đơn.
drop policy if exists "admins can update orders" on public.orders;
create policy "admins can update orders"
on public.orders for update
to authenticated
using (exists (select 1 from public.admin_users a where a.user_id = auth.uid()))
with check (exists (select 1 from public.admin_users a where a.user_id = auth.uid()));

-- Admin chỉ đọc được chính quyền admin của tài khoản đang đăng nhập.
drop policy if exists "users can read own admin record" on public.admin_users;
create policy "users can read own admin record"
on public.admin_users for select
to authenticated
using (user_id = auth.uid());

-- Không cho client tự cấp quyền admin.
revoke insert, update, delete on public.admin_users from anon, authenticated;

grant select on public.admin_users to authenticated;
grant select, insert on public.orders to anon, authenticated;
grant update on public.orders to authenticated;

-- RPC công khai để khách tra cứu đúng một đơn bằng mã. Không mở toàn bộ bảng orders.
create or replace function public.get_order_status(p_order_code text)
returns table (
 order_code text,
 roblox_username text,
 robux integer,
 amount_vnd bigint,
 status text,
 payment_reference text,
 created_at timestamptz,
 paid_at timestamptz
)
language sql
stable
security definer
set search_path = public
as $$
  select o.order_code,o.roblox_username,o.robux,o.amount_vnd,o.status,
         o.payment_reference,o.created_at,o.paid_at
  from public.orders o
  where upper(o.order_code)=upper(trim(p_order_code))
  limit 1;
$$;

grant execute on function public.get_order_status(text) to anon, authenticated;

-- SAU KHI TẠO USER ADMIN TRONG Supabase Authentication > Users,
-- chạy lệnh này và thay UUID bằng UID của user admin:
-- insert into public.admin_users(user_id) values ('YOUR-AUTH-USER-UUID');
