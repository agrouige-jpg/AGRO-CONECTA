# 🎯 INÍCIO RÁPIDO - AGRO CONECTA

## ⚡ 5 Minutos para Começar!

### 📝 CHECKLIST RÁPIDO

```
□ Passo 1: Supabase configurado (5 min)
□ Passo 2: Admin criado (2 min)
□ Passo 3: Teste realizado (3 min)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Total: 10 minutos ⏱️
```

---

## 🚀 PASSO 1: SUPABASE (5 minutos)

### A. Acesse seu Supabase
```
URL: https://gybsyclbdhfbxoqnrkwn.supabase.co
Dashboard: https://app.supabase.com
```

### B. Execute o SQL
```
1. Menu lateral → "SQL Editor"
2. "New query"
3. Cole TODO o conteúdo de: /database-schema-products.sql
4. Clique "Run" (Ctrl/Cmd + Enter)
```

### C. Verifique
```
Menu lateral → "Table Editor"

Deve ver:
✅ profiles
✅ products
✅ payments
✅ product_history
```

---

## 👤 PASSO 2: CRIAR ADMIN (2 minutos)

### A. Criar usuário no Auth
```
1. Menu lateral → "Authentication" → "Users"
2. "Add user" → "Create new user"
3. Preencha:
   Email: agrouige@gmail.com
   Password: admin074980
4. ✅ Marque "Auto Confirm User"
5. "Create user"
6. ⭐ COPIE o UUID do usuário
```

### B. Criar perfil admin
```
1. Menu lateral → "SQL Editor"
2. "New query"
3. Cole e AJUSTE o UUID:

INSERT INTO profiles (id, email, full_name, role)
VALUES (
  'COLE_SEU_UUID_AQUI',
  'agrouige@gmail.com', 
  'Administrador AGRO', 
  'admin'
);

4. "Run"
```

### C. Verifique
```
"Table Editor" → "profiles"
Deve ver 1 registro com role = 'admin'
```

---

## ✅ PASSO 3: TESTAR (3 minutos)

### Teste 1: Login Admin ✅
```
1. Abra sua aplicação
2. Clique "Login"
3. Email: agrouige@gmail.com
   Senha: admin074980
4. Deve ver: Dashboard de Administração
```

### Teste 2: Criar Produtor ✅
```
1. Abra aba anônima (Ctrl+Shift+N)
2. Clique "Login" → "Criar Conta"
3. Selecione "Produtor"
4. Preencha dados de teste
5. "Criar Conta"
6. Faça login
7. Deve ver: Dashboard do Produtor
```

### Teste 3: Fluxo Completo ✅
```
1. Como PRODUTOR: Adicione um produto
2. Como ADMIN: Aprove o produto
3. Como ADMIN: Confirme pagamento
4. SEM LOGIN: Veja no marketplace
```

---

## 🎉 PRONTO!

Se chegou até aqui, seu sistema está **100% funcional**!

---

## 📱 ÁREAS DO SISTEMA

### 🌾 ÁREA DO PRODUTOR
```
Acesso: Login com conta de produtor

Pode fazer:
✅ Adicionar produtos
✅ Editar produtos pendentes/rejeitados
✅ Eliminar produtos
✅ Renovar produtos expirados
✅ Ver estatísticas
   - Total de produtos
   - Pendentes/Aprovados/Rejeitados
   - Visualizações
   - Contactos recebidos
```

### ⚙️ ÁREA DO ADMIN
```
Acesso: Login como admin

Pode fazer:
✅ Ver TODOS os produtos
✅ Aprovar produtos
✅ Rejeitar produtos (com motivo)
✅ Confirmar pagamentos
✅ Ver informações dos produtores
✅ Filtrar e pesquisar
✅ Ver estatísticas gerais
```

### 🛒 MARKETPLACE PÚBLICO
```
Acesso: Sem login necessário

Mostra:
✅ Produtos aprovados e pagos
✅ Filtros por categoria/província
✅ Pesquisa em tempo real
✅ Contacto direto (WhatsApp/Tel)
✅ Informações do produtor
```

---

## 💡 CENÁRIOS DE USO

### Cenário 1: Novo Produtor 🌾
```
1. Produtor acessa o site
2. Cria conta (Produtor)
3. Adiciona produto
   - Nome: Tomate Fresco
   - Preço: 800 Kz/kg
   - Quantidade: 500 kg
   - Local: Luanda, Viana
4. Status: Pendente
5. Aguarda aprovação
```

### Cenário 2: Admin Aprova ✅
```
1. Admin faz login
2. Vê produto pendente
3. Clica "Aprovar"
4. Adiciona nota: "Produto de qualidade"
5. Confirma aprovação
6. Status: Aprovado (aguardando pagamento)
```

### Cenário 3: Confirmação de Pagamento 💰
```
1. Produtor faz pagamento offline (2.500 Kz)
2. Produtor informa admin
3. Admin confirma no sistema
4. Status: Pago
5. Produto aparece no marketplace
6. Visível por 30 dias
```

### Cenário 4: Comprador Interessado 📱
```
1. Visitante acessa marketplace
2. Filtra: Agricultura, Luanda
3. Vê produto "Tomate Fresco"
4. Clica "WhatsApp"
5. Envia mensagem ao produtor
6. Negocia diretamente
7. ✅ Contador de contactos +1
```

### Cenário 5: Renovação 🔄
```
1. Após 30 dias, produto expira
2. Status: Expirado
3. Produtor vê no dashboard
4. Clica "Renovar"
5. Nova taxa de 2.500 Kz
6. Admin confirma pagamento
7. Produto ativo por mais 30 dias
```

---

## 📊 EXEMPLO DE DADOS

### Produto de Exemplo:
```json
{
  "title": "Tomate Orgânico",
  "description": "Tomate fresco, cultivado sem agrotóxicos",
  "category": "vegetables",
  "price": 850,
  "unit": "kg",
  "quantity": 200,
  "province": "Luanda",
  "municipality": "Viana",
  "status": "approved",
  "payment_status": "paid",
  "views": 47,
  "contacts": 12
}
```

### Produtor de Exemplo:
```json
{
  "name": "João Silva",
  "email": "joao@fazenda.ao",
  "phone": "+244 923 456 789",
  "business": "Fazenda São José",
  "type": "Agricultura",
  "province": "Luanda",
  "municipality": "Viana"
}
```

---

## 🔥 FUNCIONALIDADES DESTAQUE

### 1. Contadores Automáticos 📈
```
✅ Visualizações - Incrementa quando produto é visto
✅ Contactos - Incrementa ao clicar WhatsApp/Tel
✅ Visível para produtor e admin
✅ Métrica de sucesso do produto
```

### 2. Sistema de Aprovação ⚡
```
✅ Workflow completo
✅ Notas do admin
✅ Feedback ao produtor
✅ Reenvio após rejeição
```

### 3. Expiração Automática ⏰
```
✅ 30 dias de visibilidade
✅ Alerta antes de expirar
✅ Renovação simples
✅ Nova cobrança na renovação
```

### 4. Filtros Inteligentes 🔍
```
✅ Por categoria
✅ Por província
✅ Pesquisa livre
✅ Resultados em tempo real
```

### 5. Segurança RLS 🔒
```
✅ Produtor vê só seus produtos
✅ Admin vê tudo
✅ Público vê só aprovados
✅ Impossível burlar pelo frontend
```

---

## 💰 MODELO DE NEGÓCIO

### Receita Principal:
```
Taxa de Publicação: 2.500 Kz por produto
Duração: 30 dias
Renovação: 2.500 Kz (mais 30 dias)
```

### Exemplo de Receita:
```
10 produtos/mês × 2.500 Kz = 25.000 Kz/mês
50 produtos/mês × 2.500 Kz = 125.000 Kz/mês
100 produtos/mês × 2.500 Kz = 250.000 Kz/mês
```

### Crescimento:
```
Mês 1: 10 produtos = 25.000 Kz
Mês 2: 25 produtos = 62.500 Kz
Mês 3: 50 produtos = 125.000 Kz
Mês 6: 100+ produtos = 250.000+ Kz
```

---

## 🎯 KPIs IMPORTANTES

### Para Monitorar:
```
1. Total de Produtores Cadastrados
2. Taxa de Aprovação de Produtos
3. Produtos Ativos no Marketplace
4. Visualizações Totais
5. Contactos Totais
6. Taxa de Conversão (Contactos/Visualizações)
7. Receita Mensal
8. Taxa de Renovação
```

### SQL para KPIs:
```sql
-- Ver no arquivo: SQL_COMANDOS_UTEIS.sql
-- Seção: RELATÓRIOS E ANALYTICS
```

---

## 🆘 PROBLEMAS COMUNS

### "Não consigo fazer login"
```
Solução:
1. Verifique email/senha
2. Confira se usuário tem perfil na tabela profiles
3. Tente resetar senha no Supabase
```

### "Produto não aparece no marketplace"
```
Solução:
Verifique se:
✅ status = 'approved'
✅ payment_status = 'paid'
✅ expires_at > NOW()
```

### "Erro ao adicionar produto"
```
Solução:
1. Abra Console (F12)
2. Veja erros na aba Console
3. Verifique permissões RLS
```

### "RLS policy violation"
```
Solução:
1. Execute novamente o schema SQL completo
2. Verifique se políticas existem:
   SELECT * FROM pg_policies;
```

---

## 📚 DOCUMENTAÇÃO

### Arquivos Disponíveis:
```
📄 GUIA_PASSO_A_PASSO.md
   → Tutorial detalhado com screenshots

📄 SETUP_INSTRUCTIONS.md
   → Instruções de configuração do Supabase

📄 SISTEMA_COMPLETO.md
   → Documentação técnica completa

📄 SISTEMA_PRONTO.md
   → Overview executivo

📄 SQL_COMANDOS_UTEIS.sql
   → 20 seções de comandos SQL úteis

📄 database-schema-products.sql
   → Schema completo do banco
```

---

## 🎓 PRÓXIMOS PASSOS

### Fase 1: Configuração ✅
```
✅ Supabase configurado
✅ Admin criado
✅ Sistema testado
```

### Fase 2: Conteúdo
```
□ Adicionar 5-10 produtos de teste
□ Criar 3-5 produtores de teste
□ Popular marketplace
```

### Fase 3: Lançamento
```
□ Divulgar para produtores reais
□ Coletar feedback
□ Ajustar conforme necessário
```

### Fase 4: Crescimento
```
□ Adicionar mais categorias
□ Implementar upload de imagens
□ Sistema de avaliações
□ Notificações por email
```

---

## 🌟 VOCÊ CONSEGUIU!

Sistema **100% funcional** e pronto para **transformar o agronegócio angolano**! 🇦🇴

```
┌────────────────────────────────────────┐
│                                        │
│   🌾 AGRO CONECTA                      │
│                                        │
│   ✅ Autenticação segura               │
│   ✅ 2 tipos de usuário                │
│   ✅ CRUD completo de produtos         │
│   ✅ Sistema de aprovação              │
│   ✅ Gestão de pagamentos              │
│   ✅ Marketplace funcional             │
│   ✅ Contadores em tempo real          │
│   ✅ 100% Mobile-first                 │
│                                        │
│   🚀 PRONTO PARA PRODUÇÃO!             │
│                                        │
└────────────────────────────────────────┘
```

**Bora revolucionar a agricultura! 🌾💚**
