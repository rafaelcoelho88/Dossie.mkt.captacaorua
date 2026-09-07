# Dossiê Vivo — V3 Prev · Captação Presencial

Painel executivo do projeto de captação presencial de clientes de auxílio-acidente.
Uma página só, sem framework e sem etapa de build: o navegador carrega o `index.html`
e conversa direto com o banco.

- **Hospedagem:** Vercel (site estático)
- **Banco e login:** Supabase (Postgres + autenticação por link no e-mail)
- **Quem entra:** apenas os e-mails cadastrados na tabela `membros`

---

## O que você vai precisar

Três contas gratuitas, nesta ordem: **Supabase**, **GitHub** e **Vercel**.
O caminho inteiro leva cerca de 30 minutos e não exige terminal.

---

## Passo 1 — Criar o banco no Supabase

1. Entre em <https://supabase.com> e crie uma conta.
2. **New project**. Dê o nome `dossie-v3prev`, escolha a região **South America (São Paulo)**
   e guarde a senha do banco que ele pedir (você não vai precisar dela no dia a dia,
   mas não dá para recuperar depois).
3. Espere o projeto terminar de subir (uns 2 minutos).
4. No menu lateral, abra **SQL Editor → New query**.
5. Abra o arquivo `supabase/schema.sql` deste repositório, **troque os e-mails do item 8
   pelos reais da equipe**, cole tudo no editor e clique em **Run**.
   Deve aparecer *Success. No rows returned*.
6. Vá em **Project Settings → API** e copie dois valores:
   - **Project URL** (algo como `https://abcdefgh.supabase.co`)
   - **Project API keys → anon / public** (uma chave longa)

> A chave `anon` é pública de propósito — ela vai dentro da página. Quem protege os dados
> são as regras de acesso criadas pelo `schema.sql`, que só liberam quem está na tabela
> `membros`. **Nunca** use aqui a chave `service_role`.

---

## Passo 2 — Preencher o `config.js`

Abra o arquivo `config.js` e substitua os dois marcadores pelos valores que você copiou:

```js
window.DOSSIE_CONFIG = {
  supabaseUrl:     "https://abcdefgh.supabase.co",
  supabaseAnonKey: "eyJhbGciOi..."
};
```

---

## Passo 3 — Subir para o GitHub

1. Entre em <https://github.com> e crie um repositório **privado** chamado `dossie-v3prev`.
2. Na tela do repositório vazio, clique em **uploading an existing file**.
3. Arraste os arquivos desta pasta (inclusive a subpasta `supabase`) e confirme com **Commit changes**.

---

## Passo 4 — Publicar na Vercel

1. Entre em <https://vercel.com> com a conta do GitHub.
2. **Add New → Project → Import** e escolha o repositório `dossie-v3prev`.
3. Não mexa em nada: framework **Other**, sem comando de build, diretório raiz.
4. **Deploy**. Em menos de um minuto sai a URL, algo como
   `https://dossie-v3prev.vercel.app`.

### Domínio da V3 (opcional)

Em **Settings → Domains**, adicione por exemplo `dossie.v3prev.com.br` e crie no seu
provedor de DNS o registro `CNAME` que a Vercel indicar. Leva alguns minutos para propagar.

---

## Passo 5 — Autorizar o endereço no Supabase

Sem isto o link de acesso enviado por e-mail não volta para o site.

1. No Supabase, vá em **Authentication → URL Configuration**.
2. **Site URL:** a URL da Vercel (ou o domínio da V3, se já configurou).
3. **Redirect URLs:** adicione as duas, uma por linha:
   ```
   https://dossie-v3prev.vercel.app/**
   https://dossie.v3prev.com.br/**
   ```
4. Salve.

---

## Passo 6 — Primeiro acesso

Abra a URL, digite seu e-mail corporativo e clique em **Receber link de acesso**.
Chega um e-mail do Supabase com um link; ao clicar, o dossiê abre já autenticado.
A sessão fica salva no navegador — no dia a dia ninguém precisa refazer isso.

---

## Uso no dia a dia

- Quem tem papel `admin` ou `editor` altera qualquer campo; a gravação é automática
  e aparece **salvo** no topo da tela.
- Quem tem papel `leitor` enxerga tudo, mas os campos ficam travados.
- Quem estiver com o dossiê aberto recebe as alterações dos outros na hora.
- O bloco **Últimas alterações**, no fim da Visão Executiva, mostra quem mexeu em quê.
- O botão **Carregar DEMO** preenche o dossiê com o cenário de teste; **Limpar DEMO**
  desfaz sem deixar resíduo. Use antes de começar para conferir os cálculos.

### Incluir ou remover pessoas

No Supabase, **Table Editor → membros**: insira uma linha com o e-mail, o nome e o papel
(`admin`, `editor` ou `leitor`), ou apague a linha de quem sai. Vale no acesso seguinte.

---

## Atualizar o dossiê depois

Qualquer alteração no `index.html` enviada ao GitHub publica sozinha na Vercel — não há
nada para reconstruir. Pelo site do GitHub: abra o arquivo, clique no lápis, edite,
**Commit changes**. Em torno de um minuto a mudança está no ar.

---

## Se algo não funcionar

| Sintoma | Causa mais provável |
|---|---|
| "Falta configurar o acesso ao banco" | O `config.js` ainda está com os marcadores `COLE_AQUI` |
| O link do e-mail abre e volta para a tela de login | Falta o passo 5 (Redirect URLs no Supabase) |
| "Este e-mail ainda não tem acesso" | O endereço não está na tabela `membros` |
| Salva mas some ao recarregar | O `schema.sql` não rodou por inteiro — rode de novo |
| Página em branco | JavaScript desativado, ou navegador muito antigo |
| Não recebeu o e-mail | Verifique o spam. O envio gratuito do Supabase tem limite por hora; para volume maior, configure um SMTP próprio em **Authentication → Emails** |

---

## Estrutura

```
index.html          o dossiê inteiro (interface, cálculos e motor de recomendação)
config.js           endereço e chave pública do Supabase
vercel.json         cabeçalhos e configuração da hospedagem
supabase/schema.sql tabelas, permissões, histórico e tempo real
```

## Custo

Os planos gratuitos de Vercel e Supabase dão conta de sobra para um dossiê usado por
alguns diretores. O ponto de atenção no Supabase é a pausa automática de projetos sem
acesso por muitos dias no plano gratuito — basta reativar pelo painel, sem perda de dados.
