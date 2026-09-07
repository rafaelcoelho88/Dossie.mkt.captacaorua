/* ------------------------------------------------------------------
   Configuração do dossiê — preencha os dois valores abaixo.
   Onde encontrar: painel do Supabase → Project Settings → API
     supabaseUrl     = "Project URL"
     supabaseAnonKey = "Project API keys" → anon / public
   A chave anon é pública por natureza: quem protege os dados é o RLS
   definido em supabase/schema.sql, que só libera quem está na tabela
   de membros. Nunca coloque aqui a chave "service_role".
------------------------------------------------------------------- */
window.DOSSIE_CONFIG = {
  supabaseUrl:     "COLE_AQUI_A_PROJECT_URL",
  supabaseAnonKey: "COLE_AQUI_A_CHAVE_ANON"
};
