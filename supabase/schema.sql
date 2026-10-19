-- COMBAT TRUCK CAPACIDADE
-- Aplicar no SQL Editor do projeto Supabase dedicado a este sistema.
-- Todos os vendedores autenticados compartilham os mesmos registros.
create table if not exists public.combat_cargas (
  id uuid primary key default gen_random_uuid(),
  data_operacao date not null,
  cliente text not null,
  responsavel text not null,
  destino text not null,
  peso_kg numeric(12,2) not null check (peso_kg > 0),
  volumes integer not null default 1 check (volumes > 0),
  tipo text not null default 'Entrega'
    check (tipo in ('Entrega', 'Escritório Ribeirão Preto', 'Transferência')),
  nota_referencia text,
  status text not null default 'Programada'
    check (status in ('Programada', 'Carregada', 'Entregue', 'Pendente')),
  observacoes text,
  criado_por uuid references auth.users(id) on delete set null,
  criado_em timestamptz not null default now(),
  atualizado_em timestamptz not null default now()
);

create index if not exists combat_cargas_data_idx
  on public.combat_cargas (data_operacao);
create index if not exists combat_cargas_cliente_idx
  on public.combat_cargas (cliente);

alter table public.combat_cargas enable row level security;

drop policy if exists "Vendedores autenticados podem ver cargas compartilhadas" on public.combat_cargas;
create policy "Vendedores autenticados podem ver cargas compartilhadas"
  on public.combat_cargas for select to authenticated using (true);

drop policy if exists "Vendedores autenticados podem cadastrar cargas" on public.combat_cargas;
create policy "Vendedores autenticados podem cadastrar cargas"
  on public.combat_cargas for insert to authenticated with check (true);

drop policy if exists "Vendedores autenticados podem atualizar cargas" on public.combat_cargas;
create policy "Vendedores autenticados podem atualizar cargas"
  on public.combat_cargas for update to authenticated using (true) with check (true);

drop policy if exists "Vendedores autenticados podem excluir cargas" on public.combat_cargas;
create policy "Vendedores autenticados podem excluir cargas"
  on public.combat_cargas for delete to authenticated using (true);

-- Ativar Realtime para que a programação possa atualizar nas telas da equipe.
do $$
begin
  alter publication supabase_realtime add table public.combat_cargas;
exception when duplicate_object then null;
when undefined_object then null;
end $$;
