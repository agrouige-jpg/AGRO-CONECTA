# 🔒 Segurança e Melhores Práticas - AGRO CONECTA

## 📋 Checklist de Segurança

### ✅ Antes do Deploy

- [ ] Remover todos os console.log com informações sensíveis
- [ ] Configurar variáveis de ambiente (.env não deve ir para Git)
- [ ] Revisar políticas RLS no Supabase
- [ ] Ativar HTTPS (automático no Vercel/Netlify)
- [ ] Configurar CORS apropriadamente
- [ ] Limitar tentativas de login (rate limiting)
- [ ] Validar todos os inputs do usuário
- [ ] Sanitizar dados antes de armazenar
- [ ] Revisar dependências com `npm audit`

---

## 🔐 Autenticação e Autorização

### Senhas
```typescript
// ✅ BOM - Supabase já faz hash automaticamente
await supabase.auth.signUp({
  email: email,
  password: password // Mínimo 6 caracteres
});

// ❌ NUNCA armazenar senhas em texto plano
// ❌ NUNCA logar senhas no console
```

### Tokens e Sessões
```typescript
// ✅ Verificar autenticação antes de operações sensíveis
const { data: { user } } = await supabase.auth.getUser();
if (!user) {
  throw new Error('Não autenticado');
}

// ✅ Verificar se o usuário pagou
if (!user.user_metadata?.has_paid) {
  throw new Error('Pagamento pendente');
}
```

### Row Level Security (RLS)
```sql
-- ✅ Sempre ativar RLS
ALTER TABLE products ENABLE ROW LEVEL SECURITY;

-- ✅ Políticas restritivas por padrão
CREATE POLICY "Users can only update own data"
ON products FOR UPDATE
USING (auth.uid() = producer_id)
WITH CHECK (auth.uid() = producer_id);
```

---

## 🛡️ Proteção Contra Ataques

### SQL Injection
```typescript
// ✅ BOM - Supabase usa queries parametrizadas
const { data } = await supabase
  .from('products')
  .select()
  .eq('name', userInput); // Seguro

// ❌ EVITAR - String interpolation direta
// const query = `SELECT * FROM products WHERE name = '${userInput}'`;
```

### XSS (Cross-Site Scripting)
```typescript
// ✅ React automaticamente escapa HTML
<div>{userInput}</div> // Seguro

// ❌ NUNCA usar dangerouslySetInnerHTML com dados não confiáveis
// <div dangerouslySetInnerHTML={{ __html: userInput }} />
```

### CSRF (Cross-Site Request Forgery)
```typescript
// ✅ Supabase Auth inclui proteção CSRF automaticamente
// Headers e tokens são gerenciados pela biblioteca
```

---

## 🔑 Variáveis de Ambiente

### ✅ Seguras
```env
# Público - OK expor no frontend (prefixo VITE_)
VITE_SUPABASE_URL=https://xxx.supabase.co
VITE_SUPABASE_ANON_KEY=eyJhbGc... # Chave pública, pode expor
```

### ❌ Nunca Expor
```env
# Privadas - NUNCA incluir no frontend
SUPABASE_SERVICE_ROLE_KEY=eyJhbGc... # Acesso total ao DB
TWILIO_AUTH_TOKEN=xxxxx
DATABASE_PASSWORD=xxxxx
SECRET_KEY=xxxxx
```

### Uso Correto
```typescript
// ✅ Acessar variáveis no Vite
const supabaseUrl = import.meta.env.VITE_SUPABASE_URL;

// ✅ Verificar se existe
if (!supabaseUrl) {
  throw new Error('VITE_SUPABASE_URL não configurada');
}
```

---

## 📝 Validação de Dados

### Frontend
```typescript
// ✅ Validar antes de enviar
function validateEmail(email: string): boolean {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
}

function validatePhone(phone: string): boolean {
  return /^\+244\s?\d{3}\s?\d{3}\s?\d{3}$/.test(phone);
}

// ✅ Sanitizar inputs
function sanitizeInput(input: string): string {
  return input.trim().replace(/[<>]/g, '');
}
```

### Backend (Database Constraints)
```sql
-- ✅ Constraints no banco
CREATE TABLE products (
  price_min DECIMAL(10,2) CHECK (price_min >= 0),
  rating INTEGER CHECK (rating >= 1 AND rating <= 5),
  email TEXT CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
);
```

---

## 🚫 Rate Limiting

### Proteção contra Brute Force
```typescript
// Implementar com Supabase Edge Functions ou middleware

// Exemplo conceitual
const loginAttempts = new Map();

async function checkRateLimit(email: string) {
  const attempts = loginAttempts.get(email) || 0;
  
  if (attempts >= 5) {
    throw new Error('Muitas tentativas. Aguarde 15 minutos.');
  }
  
  loginAttempts.set(email, attempts + 1);
  
  // Limpar após 15 minutos
  setTimeout(() => {
    loginAttempts.delete(email);
  }, 15 * 60 * 1000);
}
```

---

## 📱 Segurança Mobile

### HTTPS Obrigatório
```typescript
// ✅ Verificar protocolo
if (window.location.protocol !== 'https:' && 
    window.location.hostname !== 'localhost') {
  window.location.href = 
    window.location.href.replace('http:', 'https:');
}
```

### Armazenamento Local
```typescript
// ❌ NUNCA armazenar dados sensíveis em localStorage
// localStorage.setItem('password', password); // ERRADO

// ✅ Supabase Auth gerencia tokens automaticamente
// Tokens são armazenados de forma segura
```

---

## 🔍 Logs e Monitoramento

### O que Logar
```typescript
// ✅ Eventos importantes
console.log('Usuário autenticado:', user.id);
console.log('Produto criado:', product.id);

// ❌ NUNCA logar dados sensíveis
// console.log('Senha:', password); // ERRADO
// console.log('Token:', token); // ERRADO
// console.log('Cartão:', cardNumber); // ERRADO
```

### Produção
```typescript
// ✅ Remover logs em produção
if (import.meta.env.DEV) {
  console.log('Debug info:', data);
}
```

---

## 🔧 Headers de Segurança

### Vercel/Netlify
```json
// vercel.json ou netlify.toml
{
  "headers": [
    {
      "source": "/(.*)",
      "headers": [
        {
          "key": "X-Content-Type-Options",
          "value": "nosniff"
        },
        {
          "key": "X-Frame-Options",
          "value": "DENY"
        },
        {
          "key": "X-XSS-Protection",
          "value": "1; mode=block"
        },
        {
          "key": "Referrer-Policy",
          "value": "strict-origin-when-cross-origin"
        },
        {
          "key": "Permissions-Policy",
          "value": "geolocation=(), microphone=(), camera=()"
        }
      ]
    }
  ]
}
```

---

## 👥 Controle de Acesso

### Verificações Necessárias
```typescript
// ✅ Verificar autenticação
async function checkAuth() {
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) throw new Error('Não autenticado');
  return user;
}

// ✅ Verificar pagamento
async function checkPayment(user: User) {
  if (!user.user_metadata?.has_paid) {
    throw new Error('Pagamento necessário');
  }
}

// ✅ Verificar propriedade
async function checkOwnership(userId: string, productId: string) {
  const { data } = await supabase
    .from('products')
    .select('producer_id')
    .eq('id', productId)
    .single();
  
  if (data.producer_id !== userId) {
    throw new Error('Sem permissão');
  }
}
```

---

## 🆘 Tratamento de Erros

### Mensagens de Erro
```typescript
// ✅ Mensagens genéricas para o usuário
catch (error) {
  // Log completo para debug (apenas dev)
  console.error('[DEV]', error);
  
  // Mensagem genérica para o usuário
  toast.error('Erro ao processar solicitação. Tente novamente.');
}

// ❌ EVITAR expor detalhes técnicos
// toast.error(error.message); // Pode expor informações sensíveis
```

---

## 📊 Auditoria

### Logs de Auditoria
```sql
-- Tabela de auditoria (opcional)
CREATE TABLE audit_logs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id),
  action TEXT NOT NULL,
  table_name TEXT,
  record_id UUID,
  old_data JSONB,
  new_data JSONB,
  ip_address INET,
  user_agent TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);
```

---

## ✅ Checklist Final Pré-Produção

- [ ] Todas as variáveis de ambiente configuradas
- [ ] `.env` está no `.gitignore`
- [ ] RLS ativado em todas as tabelas
- [ ] Políticas de acesso revisadas
- [ ] HTTPS ativado
- [ ] Headers de segurança configurados
- [ ] Rate limiting implementado (se necessário)
- [ ] Logs sensíveis removidos
- [ ] `npm audit` executado e vulnerabilidades corrigidas
- [ ] Backup do banco de dados configurado
- [ ] Monitoramento ativo
- [ ] Documentação de segurança atualizada

---

## 📚 Recursos

- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [Supabase Security Best Practices](https://supabase.com/docs/guides/auth/row-level-security)
- [Web Security Academy](https://portswigger.net/web-security)

---

## 🚨 Contato de Emergência

Em caso de incidente de segurança:
1. Documentar o incidente
2. Isolar sistemas afetados
3. Notificar administradores
4. Revisar logs
5. Implementar correção
6. Notificar usuários (se necessário)

---

**Segurança é um processo contínuo, não um destino! 🔒**

**Última revisão:** 01/02/2026
