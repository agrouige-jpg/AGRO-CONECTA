# ❓ FAQ - Perguntas Frequentes

## 🚀 Deployment

### Como faço o deploy da aplicação?

**Vercel (Recomendado):**
1. Criar conta em [vercel.com](https://vercel.com)
2. Conectar repositório Git
3. Configurar variáveis de ambiente
4. Deploy automático a cada push

Veja detalhes completos em [DEPLOYMENT.md](./DEPLOYMENT.md)

---

### Quanto custa hospedar?

- **Vercel:** Gratuito até 100GB de banda/mês
- **Netlify:** Gratuito até 100GB de banda/mês
- **Supabase:** Gratuito até 500MB database + 2GB storage

Para tráfego maior, planos pagos começam em ~$20/mês

---

### Posso usar um domínio próprio?

Sim! Tanto Vercel quanto Netlify permitem domínios customizados:
- Gratuito: `seu-projeto.vercel.app`
- Custom: `www.agro-conecta.ao` (configuração DNS necessária)

---

## 🗄️ Banco de Dados

### Como faço backup do banco?

**Opção 1 - Supabase Dashboard:**
1. Project > Settings > Database
2. Clicar em "Create Backup"

**Opção 2 - CLI:**
```bash
supabase db dump -f backup.sql
```

**Opção 3 - Automatizado:**
Configure backups automáticos no Supabase (plano pago)

---

### Como restaurar um backup?

```bash
# Via psql
psql -h seu-host.supabase.co -U postgres -d postgres < backup.sql

# Via Supabase CLI
supabase db push --db-url "postgresql://..."
```

---

### Posso mudar de Supabase para outro banco?

Sim! O código usa queries SQL padrão. Principais alternativas:
- PostgreSQL self-hosted
- AWS RDS
- Google Cloud SQL
- Neon
- PlanetScale (requer adaptar para MySQL)

---

## 🔐 Autenticação

### Como adiciono admin manualmente?

1. Criar conta normalmente na aplicação
2. No Supabase Dashboard:
   - Authentication > Users
   - Encontrar o usuário
   - Edit User Metadata
   - Adicionar: `{ "has_paid": true, "is_admin": true }`

---

### Como resetar senha de usuário?

```typescript
// Enviar email de reset
await supabase.auth.resetPasswordForEmail(
  'usuario@exemplo.com',
  {
    redirectTo: 'https://seu-site.com/reset-password'
  }
);
```

---

### OTP não está chegando no WhatsApp

O sistema atual está em **modo de desenvolvimento**. O código OTP aparece:
- No console do navegador (F12)
- Na notificação toast

Para produção, precisa integrar:
- Twilio WhatsApp API
- MessageBird
- Ou outro provedor de SMS

---

## 💰 Pagamentos

### Como integrar pagamentos reais?

Atualmente usa **simulação**. Para integrar Multicaixa:

1. Criar conta no [Multicaixa Express](https://developer.multicaixa.ao)
2. Obter credenciais API
3. Implementar webhook de callback
4. Substituir função `handleSimulatePayment` por chamada real

Exemplo em [API.md](./API.md)

---

### Posso mudar o valor da taxa?

Sim! Edite em `/src/app/components/Auth.tsx`:

```typescript
// Linha ~120
<p className="text-gray-600 mt-2">
  Para garantir a segurança e qualidade do marketplace, 
  cobramos uma taxa única de acesso de 5.000 Kz. {/* Altere aqui */}
</p>
```

---

## 📱 WhatsApp

### Como integro com WhatsApp Business?

1. Criar conta [Twilio](https://www.twilio.com)
2. Ativar WhatsApp Business API
3. Configurar webhook
4. Atualizar código de envio OTP

Ver implementação completa em [API.md](./API.md)

---

### Botão de contato não abre WhatsApp

Verifique:
1. Número está no formato correto: `+244912345678`
2. WhatsApp instalado no dispositivo
3. Navegador permite abrir links externos

---

## 🖼️ Imagens

### Como adicionar imagens de produtos?

**Opção 1 - URL externa:**
```typescript
image_url: 'https://exemplo.com/imagem.jpg'
```

**Opção 2 - Supabase Storage:**
```typescript
// Upload
const { data } = await supabase.storage
  .from('products')
  .upload(`${productId}.jpg`, file);

// URL pública
const url = supabase.storage
  .from('products')
  .getPublicUrl(data.path).data.publicUrl;
```

**Opção 3 - Cloudinary (Recomendado):**
- Upload mais rápido
- Otimização automática
- CDN global

---

### Imagens não carregam

Verifique:
1. URL está acessível publicamente
2. CORS configurado no servidor de imagens
3. HTTPS (não HTTP misto)
4. Formato suportado (jpg, png, webp)

---

## 🐛 Problemas Comuns

### "Failed to fetch" ao fazer login

**Causas:**
1. Variáveis de ambiente não configuradas
2. URL do Supabase incorreta
3. CORS bloqueado

**Solução:**
```bash
# Verificar .env
cat .env

# Deve conter:
VITE_SUPABASE_URL=https://xxx.supabase.co
VITE_SUPABASE_ANON_KEY=eyJhbGc...
```

---

### Build falha com erro de memória

```bash
# Aumentar memória do Node
NODE_OPTIONS=--max_old_space_size=4096 npm run build
```

Ou adicionar ao `package.json`:
```json
"scripts": {
  "build": "NODE_OPTIONS=--max_old_space_size=4096 vite build"
}
```

---

### Páginas retornam 404 após deploy

Configurar rewrites no hosting:

**Vercel:** Já configurado em `vercel.json`  
**Netlify:** Já configurado em `netlify.toml`

Se problema persistir, verificar se os arquivos existem.

---

### Erro "RLS policy violated"

RLS (Row Level Security) está bloqueando. Verifique:

1. Usuário está autenticado
2. Políticas de acesso estão corretas
3. `has_paid` está true no user metadata

Desabilitar temporariamente (apenas dev):
```sql
ALTER TABLE products DISABLE ROW LEVEL SECURITY;
```

---

## 📊 Performance

### Como otimizar carregamento?

1. **Lazy loading de componentes:**
```typescript
const Marketplace = lazy(() => import('./components/Marketplace'));
```

2. **Imagens otimizadas:**
- Use WebP quando possível
- Lazy load imagens off-screen
- CDN para imagens

3. **Code splitting:**
Vite já faz automaticamente

4. **Cache de queries:**
```typescript
const { data } = await supabase
  .from('products')
  .select()
  .cache(300); // 5 minutos
```

---

### Site está lento em Angola

**Causas comuns:**
1. Internet instável
2. Servidor longe geograficamente
3. Imagens muito grandes

**Soluções:**
- Usar CDN global (Vercel/Netlify incluem)
- Otimizar imagens
- Implementar PWA com cache offline
- Reduzir bundle size

---

## 🔄 Atualizações

### Como atualizar dependências?

```bash
# Verificar updates
npm outdated

# Atualizar todas
npm update

# Atualizar específica
npm install lucide-react@latest

# Verificar vulnerabilidades
npm audit fix
```

---

### Como migrar banco de dados?

Criar migration no Supabase:

```sql
-- Em Supabase SQL Editor
ALTER TABLE products ADD COLUMN new_field TEXT;

-- Ou via CLI
supabase migration new add_new_field
```

---

## 🤝 Contribuição

### Como contribuir com o projeto?

1. Fork o repositório
2. Criar branch: `git checkout -b feature/nova-funcionalidade`
3. Commit: `git commit -m 'Adiciona nova funcionalidade'`
4. Push: `git push origin feature/nova-funcionalidade`
5. Abrir Pull Request

---

### Encontrei um bug, como reportar?

1. Verificar se já foi reportado (Issues no GitHub)
2. Criar novo Issue com:
   - Descrição clara do bug
   - Passos para reproduzir
   - Comportamento esperado vs atual
   - Screenshots se aplicável
   - Ambiente (navegador, OS, etc)

---

## 📞 Suporte

### Onde consigo ajuda?

1. **Documentação:**
   - [README.md](./README.md)
   - [DEPLOYMENT.md](./DEPLOYMENT.md)
   - [API.md](./API.md)
   - [SECURITY.md](./SECURITY.md)

2. **Comunidades:**
   - [Supabase Discord](https://discord.supabase.com)
   - [Vercel Community](https://github.com/vercel/vercel/discussions)
   - Stack Overflow (tag: supabase, react, tailwindcss)

3. **Contato Direto:**
   - Email: agrouige@gmail.com

---

## 📝 Licença e Uso

### Posso usar este código comercialmente?

Sim, mas verifique os termos de licença de cada dependência:
- React: MIT (comercial OK)
- Tailwind: MIT (comercial OK)
- Supabase: Apache 2.0 (comercial OK)

---

### Preciso dar crédito?

Não é obrigatório, mas é apreciado! 😊

---

## 🎯 Roadmap

### Quais funcionalidades estão planejadas?

- [ ] Sistema de chat em tempo real
- [ ] Notificações push
- [ ] App mobile nativo (React Native)
- [ ] Sistema de pedidos completo
- [ ] Dashboard analytics
- [ ] Multi-idioma (PT/EN)
- [ ] Modo offline (PWA)
- [ ] Integração com redes sociais

---

**Não encontrou sua resposta?**

Abra uma Issue no GitHub ou entre em contato pelo email: agrouige@gmail.com

---

**Última atualização:** 01/02/2026
