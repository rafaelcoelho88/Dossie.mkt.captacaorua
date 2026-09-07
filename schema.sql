-- =====================================================================
--  DOSSIÊ VIVO — V3 PREV · CAPTAÇÃO PRESENCIAL
--  Estrutura do banco no Supabase.
--  Como usar: painel do Supabase → SQL Editor → New query →
--  cole este arquivo inteiro → Run. Pode rodar de novo sem quebrar nada.
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. Quem tem acesso ao dossiê
--    papel: 'admin' e 'editor' podem alterar; 'leitor' só enxerga.
-- ---------------------------------------------------------------------
create table if not exists public.membros (
  email     text primary key,
  nome      text,
  papel     text not null default 'editor' check (papel in ('admin','editor','leitor')),
  criado_em timestamptz not null default now()
);

-- ---------------------------------------------------------------------
-- 2. O dossiê em si: um registro por área do projeto
-- ---------------------------------------------------------------------
create table if not exists public.dossie_docs (
  chave          text primary key,
  conteudo       jsonb not null default '{}'::jsonb,
  atualizado_por text,
  atualizado_em  timestamptz not null default now()
);

-- ---------------------------------------------------------------------
-- 3. Quem alterou o quê
-- ---------------------------------------------------------------------
create table if not exists public.dossie_historico (
  id    bigserial primary key,
  chave text not null,
  email text,
  em    timestamptz not null default now()
);
create index if not exists dossie_historico_em_idx on public.dossie_historico (em desc);

-- ---------------------------------------------------------------------
-- 4. Funções de permissão
-- ---------------------------------------------------------------------
create or replace function public.e_membro() returns boolean
language sql stable security definer set search_path = public as $$
  select exists (select 1 from public.membros m where m.email = (auth.jwt() ->> 'email'));
$$;

create or replace function public.pode_editar() returns boolean
language sql stable security definer set search_path = public as $$
  select exists (
    select 1 from public.membros m
    where m.email = (auth.jwt() ->> 'email') and m.papel in ('admin','editor')
  );
$$;

-- ---------------------------------------------------------------------
-- 5. Regras de acesso (RLS) — sem isso o banco fica aberto
-- ---------------------------------------------------------------------
alter table public.membros          enable row level security;
alter table public.dossie_docs      enable row level security;
alter table public.dossie_historico enable row level security;

drop policy if exists "membros: ler"        on public.membros;
drop policy if exists "membros: administrar" on public.membros;
drop policy if exists "docs: ler"           on public.dossie_docs;
drop policy if exists "docs: inserir"       on public.dossie_docs;
drop policy if exists "docs: atualizar"     on public.dossie_docs;
drop policy if exists "historico: ler"      on public.dossie_historico;

create policy "membros: ler" on public.membros
  for select to authenticated using (public.e_membro());

create policy "membros: administrar" on public.membros
  for all to authenticated
  using (exists (select 1 from public.membros m where m.email = (auth.jwt() ->> 'email') and m.papel = 'admin'))
  with check (exists (select 1 from public.membros m where m.email = (auth.jwt() ->> 'email') and m.papel = 'admin'));

create policy "docs: ler" on public.dossie_docs
  for select to authenticated using (public.e_membro());

create policy "docs: inserir" on public.dossie_docs
  for insert to authenticated
  with check (public.pode_editar() and atualizado_por = (auth.jwt() ->> 'email'));

create policy "docs: atualizar" on public.dossie_docs
  for update to authenticated
  using (public.pode_editar())
  with check (public.pode_editar() and atualizado_por = (auth.jwt() ->> 'email'));

create policy "historico: ler" on public.dossie_historico
  for select to authenticated using (public.e_membro());

-- ---------------------------------------------------------------------
-- 6. Registro automático de quem alterou
-- ---------------------------------------------------------------------
create or replace function public.registrar_historico() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  insert into public.dossie_historico (chave, email) values (new.chave, new.atualizado_por);
  delete from public.dossie_historico
   where id < (select max(id) - 500 from public.dossie_historico);
  return new;
end $$;

drop trigger if exists trg_dossie_historico on public.dossie_docs;
create trigger trg_dossie_historico
  after insert or update on public.dossie_docs
  for each row execute function public.registrar_historico();

-- ---------------------------------------------------------------------
-- 7. Atualização em tempo real entre quem estiver com o dossiê aberto
-- ---------------------------------------------------------------------
do $$
begin
  begin
    alter publication supabase_realtime add table public.dossie_docs;
  exception when duplicate_object then null;
  end;
end $$;

-- ---------------------------------------------------------------------
-- 8. AJUSTE AQUI: quem entra no dossiê
--    Troque os e-mails pelos reais antes de rodar.
-- ---------------------------------------------------------------------
insert into public.membros (email, nome, papel) values
  ('rafael.coelho@v3prev.com.br', 'Rafael Coelho',       'admin'),
  ('marketing@v3prev.com.br',     'Diretor de Marketing','editor'),
  ('comercial@v3prev.com.br',     'Diretor Comercial',   'editor'),
  ('financeiro@v3prev.com.br',    'Diretor Financeiro',  'editor')
on conflict (email) do nothing;
