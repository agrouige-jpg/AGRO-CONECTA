# 🚀 GUIA RÁPIDO DE DEPLOYMENT

## Para Vercel (Recomendado)

### Opção 1: Via Dashboard Web
1. Acesse [vercel.com](https://vercel.com)
2. Clique em "Add New Project"
3. Importe seu repositório Git
4. Configure as variáveis de ambiente:
   - `VITE_SUPABASE_URL`
   - `VITE_SUPABASE_ANON_KEY`
5. Clique em "Deploy"

### Opção 2: Via CLI
```bash
# Instalar CLI
npm i -g vercel

# Deploy
vercel

# Configurar variáveis
vercel env add VITE_SUPABASE_URL
vercel env add VITE_SUPABASE_ANON_KEY

# Deploy em produção
vercel --prod
```

---

## Para Netlify

### Opção 1: Via Dashboard Web
1. Acesse [netlify.com](https://netlify.com)
2. Clique em "Add new site"
3. Conecte seu repositório Git
4. Build settings:
   - Build command: `npm run build`
   - Publish directory: `dist`
5. Configure variáveis de ambiente em Site Settings
6. Clique em "Deploy site"

### Opção 2: Via CLI
```bash
# Instalar CLI
npm i -g netlify-cli

# Login
netlify login

# Deploy
netlify deploy --prod

# Configurar variáveis
netlify env:set VITE_SUPABASE_URL "seu_valor"
netlify env:set VITE_SUPABASE_ANON_KEY "seu_valor"
```

---

## Deploy Manual (Qualquer Servidor)

```bash
# 1. Build
npm run build

# 2. Fazer upload da pasta dist/ para:
# - Apache: /var/www/html/
# - Nginx: /usr/share/nginx/html/
# - GitHub Pages: gh-pages branch
```

### Configuração Nginx
```nginx
server {
    listen 80;
    server_name seu-dominio.com;
    root /usr/share/nginx/html;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    location /assets/ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
```

### Configuração Apache (.htaccess)
```apache
<IfModule mod_rewrite.c>
  RewriteEngine On
  RewriteBase /
  RewriteRule ^index\.html$ - [L]
  RewriteCond %{REQUEST_FILENAME} !-f
  RewriteCond %{REQUEST_FILENAME} !-d
  RewriteRule . /index.html [L]
</IfModule>
```

---

## ⚙️ Variáveis de Ambiente Obrigatórias

```env
VITE_SUPABASE_URL=https://xxxxx.supabase.co
VITE_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Como obter:**
1. Acesse [supabase.com](https://supabase.com)
2. Seu projeto > Settings > API
3. Copie "Project URL" e "anon public key"

---

## 🔍 Verificar Build Local

```bash
# Build
npm run build

# Preview (opcional - requer adicionar script no package.json)
npx vite preview
```

---

## ✅ Checklist Pré-Deploy

- [ ] Variáveis de ambiente configuradas
- [ ] Database Supabase criado e tabelas configuradas
- [ ] Build local funcionando (`npm run build`)
- [ ] .env não está no Git (.gitignore configurado)
- [ ] README.md atualizado com domínio final
- [ ] Testar autenticação em produção
- [ ] Verificar políticas RLS no Supabase

---

## 🆘 Troubleshooting

### Build falha
```bash
# Limpar cache e reinstalar
rm -rf node_modules dist
npm install
npm run build
```

### Erro 404 em rotas
- Verifique se `vercel.json` ou `netlify.toml` estão configurados
- Certifique-se de que rewrites/redirects estão ativos

### Supabase não conecta
- Verifique se as variáveis de ambiente estão corretas
- Teste manualmente: `console.log(import.meta.env.VITE_SUPABASE_URL)`
- Verifique políticas RLS no Supabase

### Imagens não carregam
- Verifique se os assets estão na pasta `dist/assets/` após build
- Verifique CORS se usar imagens externas

---

## 📊 Monitoramento Pós-Deploy

- Vercel Analytics (automático)
- Netlify Analytics (opcional, pago)
- Google Analytics (adicionar script)
- Sentry para erros (opcional)

---

**Deployment típico leva 2-5 minutos ⚡**
