# 📦 INSTRUÇÕES DE EXPORTAÇÃO

## Exportar Projeto para Uso Standalone

### 1. Preparar para Exportação

```bash
# 1. Clone/copie todo o projeto
git clone <seu-repo> agro-conecta-export
cd agro-conecta-export

# 2. Instale dependências
npm install
# ou
pnpm install

# 3. Configure variáveis de ambiente
cp .env.example .env
# Edite .env com suas credenciais Supabase
```

---

### 2. Build para Produção

```bash
# Fazer build
npm run build

# Testar build localmente
npm run preview
```

O build será gerado na pasta `dist/`

---

### 3. Estrutura do Build

Após o build, você terá:

```
dist/
├── index.html              # Página principal
├── assets/
│   ├── index-[hash].js     # JavaScript minificado
│   ├── index-[hash].css    # CSS minificado
│   └── [outros arquivos]   # Fonts, imagens, etc
└── vite.svg                # Favicon
```

---

### 4. Deploy Manual

#### Opção A: Servidor Web Simples

```bash
# Nginx
sudo cp -r dist/* /var/www/html/

# Apache
sudo cp -r dist/* /var/www/html/

# Python (para teste)
cd dist
python -m http.server 8000
```

#### Opção B: Vercel CLI

```bash
npm i -g vercel
vercel --prod
```

#### Opção C: Netlify CLI

```bash
npm i -g netlify-cli
netlify deploy --prod --dir=dist
```

#### Opção D: FTP/cPanel

1. Fazer build: `npm run build`
2. Fazer upload da pasta `dist/` via FTP
3. Apontar domínio para essa pasta

---

### 5. Variáveis de Ambiente no Deploy

**Importante:** As variáveis `VITE_*` são incorporadas no build!

Isso significa que você precisa:

1. Configurar `.env` ANTES do build
2. Rebuild se mudar credenciais
3. Ou usar variáveis de ambiente do hosting

**Vercel/Netlify:**
Configure no dashboard web, eles farão rebuild automaticamente.

**Servidor próprio:**
```bash
# Definir antes do build
export VITE_SUPABASE_URL="https://xxx.supabase.co"
export VITE_SUPABASE_ANON_KEY="eyJhbGci..."
npm run build
```

---

### 6. Exportar Código Fonte

Para compartilhar o código:

```bash
# Criar arquivo zip (sem node_modules)
zip -r agro-conecta-source.zip . \
  -x "node_modules/*" \
  -x "dist/*" \
  -x ".git/*" \
  -x ".env"

# Ou usar tar.gz
tar -czf agro-conecta-source.tar.gz \
  --exclude=node_modules \
  --exclude=dist \
  --exclude=.git \
  --exclude=.env \
  .
```

---

### 7. Documentação Incluída

O projeto exportado inclui:

- ✅ `README.md` - Documentação principal
- ✅ `DEPLOYMENT.md` - Guia de deployment
- ✅ `API.md` - Documentação de APIs
- ✅ `SECURITY.md` - Práticas de segurança
- ✅ `FAQ.md` - Perguntas frequentes
- ✅ `CONTRIBUTING.md` - Guia de contribuição
- ✅ `database-schema.sql` - Schema do banco
- ✅ `.env.example` - Exemplo de variáveis

---

### 8. Requisitos Mínimos

**Para Desenvolvimento:**
- Node.js 18+
- npm ou pnpm
- Conta Supabase

**Para Produção (Hosting):**
- Qualquer servidor web estático
- Suporte a SPA (rewrites para index.html)
- HTTPS (recomendado)

---

### 9. Configuração Pós-Deploy

Após o deploy, configure:

1. **DNS:** Aponte domínio para servidor
2. **SSL:** Configure certificado HTTPS (Let's Encrypt gratuito)
3. **Supabase:** Configure URL de redirect em Authentication > URL Configuration
4. **Backups:** Configure backups automáticos do Supabase

---

### 10. Manutenção

```bash
# Atualizar dependências
npm update

# Verificar vulnerabilidades
npm audit fix

# Rebuild e redeploy
npm run build
# Upload dist/ para servidor
```

---

## 📋 Checklist de Exportação

Antes de entregar o projeto:

- [ ] Código está versionado (Git)
- [ ] `.env` não está incluído (apenas `.env.example`)
- [ ] Documentação completa
- [ ] README com instruções claras
- [ ] Build funciona localmente
- [ ] Credenciais de teste fornecidas
- [ ] Schema do banco documentado
- [ ] Instruções de deploy incluídas

---

## 🎁 Conteúdo da Exportação

```
agro-conecta/
├── src/                    # Código fonte
├── public/                 # Assets públicos
├── .env.example           # Variáveis de ambiente
├── .gitignore
├── package.json
├── vite.config.ts
├── tsconfig.json
├── vercel.json            # Config Vercel
├── netlify.toml           # Config Netlify
├── database-schema.sql    # Schema SQL
├── README.md              # Documentação principal
├── DEPLOYMENT.md          # Guia de deploy
├── API.md                 # API docs
├── SECURITY.md            # Segurança
├── FAQ.md                 # FAQ
├── CONTRIBUTING.md        # Contribuição
└── EXPORT.md             # Este arquivo
```

---

## 🔐 Segurança na Exportação

**NUNCA inclua:**
- ❌ `.env` com credenciais reais
- ❌ `node_modules/`
- ❌ `.git/` (se quiser ocultar histórico)
- ❌ Backups de banco de dados
- ❌ Senhas ou API keys

**SEMPRE inclua:**
- ✅ `.env.example` (sem valores reais)
- ✅ Documentação completa
- ✅ Instruções de setup
- ✅ Schema do banco

---

## 💡 Dicas Finais

1. **Teste em ambiente limpo** antes de entregar
2. **Forneça credenciais de teste** do Supabase
3. **Documente customizações** feitas
4. **Inclua estimativa de custos** de hosting
5. **Forneça contato** para suporte

---

## 📞 Suporte

Para dúvidas sobre a exportação:
- 📧 agrouige@gmail.com
- 📖 Consulte README.md e outros docs

---

**Projeto pronto para exportação e uso standalone! ✅**

**Data:** 01/02/2026
