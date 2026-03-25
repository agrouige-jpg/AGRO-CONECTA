# 🌾 AGRO CONECTA - Plataforma de Agronegócio de Angola

## 📋 Sobre o Projeto

AGRO CONECTA é uma plataforma mobile-first que liga diretamente produtores, criadores e compradores do setor agrícola e pecuário de Angola. O projeto foi desenvolvido com React, Tailwind CSS e Supabase.

### ✨ Funcionalidades Principais

- 🔐 **Sistema de Autenticação Completo**
  - Login e registo de usuários
  - Verificação por código OTP via WhatsApp/SMS
  - Sistema de pagamento (taxa única de 2.500 Kz)
  
- 🛒 **Marketplace**
  - Catálogo completo de produtos agrícolas e pecuários
  - Filtros por categoria
  - Contacto direto com produtores via WhatsApp
  
- 👨‍🌾 **Perfis de Produtores**
  - Perfis detalhados com produtos e avaliações
  - Sistema de rating e reviews
  
- 📚 **Área Educativa**
  - Conteúdos práticos sobre agricultura
  - Linguagem acessível para modernização do agronegócio

---

## 🚀 Instalação e Configuração

### Pré-requisitos

- Node.js 18 ou superior
- npm ou pnpm
- Conta Supabase (para backend)

### 1. Clone o Repositório

```bash
git clone <seu-repositorio>
cd agro-conecta
```

### 2. Instale as Dependências

```bash
npm install
# ou
pnpm install
```

### 3. Configure as Variáveis de Ambiente

Crie um arquivo `.env` na raiz do projeto:

```bash
cp .env.example .env
```

Edite o arquivo `.env` com suas credenciais do Supabase:

```env
VITE_SUPABASE_URL=https://seu-projeto.supabase.co
VITE_SUPABASE_ANON_KEY=sua_chave_anonima_aqui
```

### 4. Configure o Supabase

#### Tabelas Necessárias

Execute os seguintes comandos SQL no Supabase:

```sql
-- Tabela de Produtos
CREATE TABLE products (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  category TEXT NOT NULL,
  price_min DECIMAL(10,2),
  price_max DECIMAL(10,2),
  unit TEXT,
  description TEXT,
  producer_id UUID REFERENCES auth.users(id),
  image_url TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Tabela de Produtores
CREATE TABLE producers (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id),
  name TEXT NOT NULL,
  location TEXT,
  specialty TEXT,
  rating DECIMAL(2,1) DEFAULT 0,
  reviews_count INTEGER DEFAULT 0,
  phone TEXT,
  whatsapp TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Tabela de Reviews
CREATE TABLE reviews (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  producer_id UUID REFERENCES producers(id),
  user_id UUID REFERENCES auth.users(id),
  rating INTEGER CHECK (rating >= 1 AND rating <= 5),
  comment TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Habilitar Row Level Security
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE producers ENABLE ROW LEVEL SECURITY;
ALTER TABLE reviews ENABLE ROW LEVEL SECURITY;

-- Políticas de acesso (todos podem ler, mas apenas autenticados podem escrever)
CREATE POLICY "Anyone can read products" ON products FOR SELECT USING (true);
CREATE POLICY "Authenticated users can insert products" ON products FOR INSERT WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Anyone can read producers" ON producers FOR SELECT USING (true);
CREATE POLICY "Authenticated users can insert producers" ON producers FOR INSERT WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Anyone can read reviews" ON reviews FOR SELECT USING (true);
CREATE POLICY "Authenticated users can insert reviews" ON reviews FOR INSERT WITH CHECK (auth.role() = 'authenticated');
```

### 5. Execute o Projeto Localmente

```bash
npm run build
# ou
pnpm build
```

O projeto será compilado na pasta `dist/`.

Para desenvolvimento com hot-reload, você pode adicionar ao `package.json`:

```json
"scripts": {
  "dev": "vite",
  "build": "vite build",
  "preview": "vite preview"
}
```

Depois execute:

```bash
npm run dev
```

---

## 📦 Deploy

### Deploy na Vercel

1. Instale a CLI da Vercel:
```bash
npm i -g vercel
```

2. Execute:
```bash
vercel
```

3. Configure as variáveis de ambiente no painel da Vercel:
   - `VITE_SUPABASE_URL`
   - `VITE_SUPABASE_ANON_KEY`

### Deploy na Netlify

1. Instale a CLI da Netlify:
```bash
npm i -g netlify-cli
```

2. Execute:
```bash
netlify deploy --prod
```

3. Configure as variáveis de ambiente no painel da Netlify

### Deploy Manual

1. Build o projeto:
```bash
npm run build
```

2. Faça upload da pasta `dist/` para qualquer servidor web estático

---

## 🏗️ Estrutura do Projeto

```
agro-conecta/
├── src/
│   ├── app/
│   │   ├── components/
│   │   │   ├── Auth.tsx           # Sistema de autenticação
│   │   │   ├── HomePage.tsx       # Página inicial
│   │   │   ├── Marketplace.tsx    # Marketplace de produtos
│   │   │   ├── Producers.tsx      # Lista de produtores
│   │   │   ├── Education.tsx      # Conteúdo educativo
│   │   │   ├── Header.tsx         # Cabeçalho da app
│   │   │   └── ui/                # Componentes UI reutilizáveis
│   │   └── App.tsx                # Componente principal
│   ├── lib/
│   │   └── supabase.ts            # Cliente Supabase
│   └── styles/
│       ├── index.css              # Estilos globais
│       └── theme.css              # Temas e tokens
├── .env.example                    # Exemplo de variáveis de ambiente
├── vercel.json                     # Configuração Vercel
├── netlify.toml                    # Configuração Netlify
├── package.json
└── vite.config.ts
```

---

## 🔧 Tecnologias Utilizadas

- **Frontend:**
  - React 18
  - TypeScript
  - Tailwind CSS v4
  - Vite
  - Lucide React (ícones)
  - Sonner (notificações)

- **Backend:**
  - Supabase (autenticação, database)
  - PostgreSQL

- **UI Components:**
  - Radix UI
  - Shadcn/ui

---

## 🔒 Segurança

- Autenticação via Supabase Auth
- Row Level Security (RLS) no banco de dados
- Validação de formulários no frontend
- Proteção contra SQL Injection (via Supabase)
- HTTPS obrigatório em produção

---

## 📱 Mobile-First

O projeto foi desenvolvido com abordagem mobile-first, otimizado para:
- Conexões de internet instáveis
- Telas pequenas
- Touch interactions
- Performance em dispositivos modestos

---

## 🌐 Integrações Planejadas

- [ ] WhatsApp Business API (envio real de OTP)
- [ ] Twilio SMS (backup para OTP)
- [ ] Facebook Login
- [ ] Pagamentos Multicaixa
- [ ] Sistema de notificações push

---

## 🤝 Contribuindo

1. Fork o projeto
2. Crie uma branch (`git checkout -b feature/NovaFuncionalidade`)
3. Commit suas mudanças (`git commit -m 'Adiciona nova funcionalidade'`)
4. Push para a branch (`git push origin feature/NovaFuncionalidade`)
5. Abra um Pull Request

---

## 📄 Licença

Este projeto é privado e proprietário.

---

## 👥 Contato

Para acesso de administrador:
- Email: agrouige@gmail.com
- Senha: admin074980

---

## 🐛 Problemas Conhecidos

- Sistema OTP está em modo de desenvolvimento (códigos aparecem no console)
- Pagamentos são simulados (integração real pendente)
- Imagens de produtos usam placeholders

---

## 📈 Roadmap

- [x] Sistema de autenticação
- [x] Verificação por OTP (simulada)
- [x] Marketplace básico
- [x] Perfis de produtores
- [x] Área educativa
- [ ] Integração WhatsApp Business API
- [ ] Sistema de pagamentos real
- [ ] Chat entre compradores e produtores
- [ ] Sistema de pedidos
- [ ] Dashboard analytics
- [ ] App mobile nativo

---

**Desenvolvido para o setor agrícola de Angola 🇦🇴**
