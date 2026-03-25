# 📡 API e Integrações - AGRO CONECTA

## Visão Geral

Este documento descreve as APIs e integrações utilizadas e planejadas para a plataforma AGRO CONECTA.

---

## 🗄️ Supabase Backend

### Autenticação

#### Criar Conta
```typescript
const { data, error } = await supabase.auth.signUp({
  email: 'usuario@exemplo.com',
  password: 'senha_segura',
  options: {
    data: {
      full_name: 'João Silva',
      phone: '+244 912 345 678',
      has_paid: false,
      phone_verified: true
    }
  }
});
```

#### Login
```typescript
const { data, error } = await supabase.auth.signInWithPassword({
  email: 'usuario@exemplo.com',
  password: 'senha_segura'
});
```

#### Logout
```typescript
const { error } = await supabase.auth.signOut();
```

#### Obter Usuário Atual
```typescript
const { data: { user } } = await supabase.auth.getUser();
```

#### Atualizar Metadata do Usuário
```typescript
const { error } = await supabase.auth.updateUser({
  data: { has_paid: true }
});
```

---

### Database - Produtos

#### Listar Todos os Produtos
```typescript
const { data, error } = await supabase
  .from('products')
  .select('*')
  .order('created_at', { ascending: false });
```

#### Filtrar por Categoria
```typescript
const { data, error } = await supabase
  .from('products')
  .select('*')
  .eq('category', 'Hortaliças')
  .order('name');
```

#### Buscar por Nome
```typescript
const { data, error } = await supabase
  .from('products')
  .select('*')
  .ilike('name', `%${searchTerm}%`);
```

#### Criar Novo Produto
```typescript
const { data, error } = await supabase
  .from('products')
  .insert({
    name: 'Tomate',
    category: 'Hortaliças',
    price_min: 500,
    price_max: 800,
    unit: 'kg',
    description: 'Tomate fresco local',
    producer_id: user.id,
    image_url: 'https://...'
  })
  .select();
```

#### Atualizar Produto
```typescript
const { data, error } = await supabase
  .from('products')
  .update({ price_min: 600, price_max: 900 })
  .eq('id', productId)
  .select();
```

#### Deletar Produto
```typescript
const { error } = await supabase
  .from('products')
  .delete()
  .eq('id', productId);
```

---

### Database - Produtores

#### Listar Produtores
```typescript
const { data, error } = await supabase
  .from('producers')
  .select('*')
  .order('rating', { ascending: false });
```

#### Obter Produtor com Produtos
```typescript
const { data, error } = await supabase
  .from('producers')
  .select(`
    *,
    products (*)
  `)
  .eq('id', producerId)
  .single();
```

#### Criar Perfil de Produtor
```typescript
const { data, error } = await supabase
  .from('producers')
  .insert({
    user_id: user.id,
    name: 'Fazenda Boa Vista',
    location: 'Huambo',
    specialty: 'Hortaliças Orgânicas',
    phone: '+244 912 345 678',
    whatsapp: '+244 912 345 678'
  })
  .select();
```

---

### Database - Reviews

#### Listar Reviews de um Produtor
```typescript
const { data, error } = await supabase
  .from('reviews')
  .select(`
    *,
    users (full_name)
  `)
  .eq('producer_id', producerId)
  .order('created_at', { ascending: false });
```

#### Criar Review
```typescript
const { data, error } = await supabase
  .from('reviews')
  .insert({
    producer_id: producerId,
    user_id: user.id,
    rating: 5,
    comment: 'Excelente produtor, produtos de qualidade!'
  })
  .select();
```

#### Calcular Rating Médio
```typescript
const { data, error } = await supabase
  .rpc('calculate_producer_rating', { 
    producer_id: producerId 
  });
```

---

## 📱 Integrações Externas

### WhatsApp Business API (Planejado)

#### Enviar OTP
```typescript
// Exemplo com Twilio
async function sendWhatsAppOTP(phone: string, code: string) {
  const response = await fetch('https://api.twilio.com/2010-04-01/Accounts/YOUR_ACCOUNT_SID/Messages.json', {
    method: 'POST',
    headers: {
      'Authorization': 'Basic ' + btoa('YOUR_ACCOUNT_SID:YOUR_AUTH_TOKEN'),
      'Content-Type': 'application/x-www-form-urlencoded'
    },
    body: new URLSearchParams({
      'From': 'whatsapp:+14155238886',
      'To': `whatsapp:${phone}`,
      'Body': `Seu código de verificação AGRO CONECTA: ${code}`
    })
  });
  return response.json();
}
```

#### Contato com Produtor
```typescript
function contactProducer(phone: string, productName: string) {
  const message = encodeURIComponent(
    `Olá! Vi seu produto "${productName}" na AGRO CONECTA e gostaria de saber mais informações.`
  );
  window.open(`https://wa.me/${phone}?text=${message}`, '_blank');
}
```

---

### SMS via Twilio (Alternativa OTP)

```typescript
async function sendSMSOTP(phone: string, code: string) {
  const response = await fetch('https://api.twilio.com/2010-04-01/Accounts/YOUR_ACCOUNT_SID/Messages.json', {
    method: 'POST',
    headers: {
      'Authorization': 'Basic ' + btoa('YOUR_ACCOUNT_SID:YOUR_AUTH_TOKEN'),
      'Content-Type': 'application/x-www-form-urlencoded'
    },
    body: new URLSearchParams({
      'From': '+1234567890',
      'To': phone,
      'Body': `AGRO CONECTA - Código: ${code}`
    })
  });
  return response.json();
}
```

---

### Multicaixa Express API (Pagamentos - Planejado)

```typescript
interface PaymentRequest {
  amount: number;
  reference: string;
  email: string;
  phone: string;
}

async function createPayment(payment: PaymentRequest) {
  const response = await fetch('https://api.multicaixa.ao/v1/payments', {
    method: 'POST',
    headers: {
      'Authorization': 'Bearer YOUR_API_KEY',
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      amount: payment.amount,
      currency: 'AOA',
      reference: payment.reference,
      customer: {
        email: payment.email,
        phone: payment.phone
      },
      callback_url: 'https://agro-conecta.ao/payment/callback'
    })
  });
  return response.json();
}
```

---

## 🔐 Variáveis de Ambiente Necessárias

### Produção
```env
# Supabase
VITE_SUPABASE_URL=https://xxxxx.supabase.co
VITE_SUPABASE_ANON_KEY=eyJhbGci...

# Twilio (Opcional)
VITE_TWILIO_ACCOUNT_SID=ACxxxxx
VITE_TWILIO_AUTH_TOKEN=xxxxx
VITE_TWILIO_PHONE_NUMBER=+1234567890

# Multicaixa (Opcional)
VITE_MULTICAIXA_API_KEY=xxxxx
VITE_MULTICAIXA_MERCHANT_ID=xxxxx
```

---

## 🧪 Endpoints para Testes

### Health Check
```typescript
// GET /api/health
{
  "status": "ok",
  "timestamp": "2026-02-01T12:00:00Z"
}
```

### Verificar Supabase Connection
```typescript
const { data, error } = await supabase
  .from('products')
  .select('count')
  .limit(1);

if (!error) {
  console.log('Conexão OK');
}
```

---

## 🚀 Próximas Integrações

- [ ] WhatsApp Business API (Twilio/MessageBird)
- [ ] Sistema de pagamentos Multicaixa Express
- [ ] Google Maps API (localização de produtores)
- [ ] Firebase Cloud Messaging (notificações push)
- [ ] Analytics (Google Analytics / Mixpanel)
- [ ] Cloudinary (upload e otimização de imagens)

---

## 📚 Recursos

- [Supabase Docs](https://supabase.com/docs)
- [Twilio WhatsApp API](https://www.twilio.com/whatsapp)
- [Multicaixa Express Docs](https://developer.multicaixa.ao)

---

**Última atualização:** 01/02/2026
