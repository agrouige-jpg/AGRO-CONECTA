# 🚀 GUIA PASSO A PASSO - Configuração Completa

## 📋 PASSO 1: Configurar Supabase

### 1.1 Executar o Schema SQL

1. **Acesse seu projeto Supabase:**
   - URL: https://gybsyclbdhfbxoqnrkwn.supabase.co
   - Faça login no painel: https://app.supabase.com

2. **Abra o SQL Editor:**
   - No menu lateral, clique em "SQL Editor"
   - Clique em "New query"

3. **Cole o SQL completo:**
   - Abra o arquivo `/database-schema-products.sql`
   - Copie TODO o conteúdo
   - Cole no editor SQL
   - Clique em "Run" (ou pressione Ctrl/Cmd + Enter)

4. **Verifique se deu certo:**
   - Vá em "Table Editor"
   - Você deve ver as tabelas:
     - ✅ profiles
     - ✅ products
     - ✅ payments
     - ✅ product_history

---

## 📋 PASSO 2: Criar Primeiro Administrador

### 2.1 Criar usuário no Auth

1. **No painel Supabase, vá para "Authentication"**
   - Menu lateral → "Authentication" → "Users"

2. **Adicione novo usuário:**
   - Clique em "Add user" → "Create new user"
   - Preencha:
     ```
     Email: agrouige@gmail.com
     Password: admin074980
     ```
   - ✅ Marque "Auto Confirm User" (importante!)
   - Clique em "Create user"

3. **Copie o User ID:**
   - Após criar, você verá uma lista de usuários
   - Clique no usuário recém-criado
   - **COPIE o UUID** (algo como: `8f7e6d5c-4b3a-2c1d-0e9f-8a7b6c5d4e3f`)

### 2.2 Criar perfil admin

1. **Volte ao SQL Editor**
   - Menu lateral → "SQL Editor"
   - Nova query

2. **Execute este comando (substitua o UUID):**

```sql
-- IMPORTANTE: Substitua 'SEU_UUID_AQUI' pelo UUID que você copiou
INSERT INTO profiles (id, email, full_name, role)
VALUES (
  'SEU_UUID_AQUI',  -- ← Cole aqui o UUID do passo anterior
  'agrouige@gmail.com', 
  'Administrador AGRO', 
  'admin'
);
```

3. **Verifique:**
   - Vá em "Table Editor" → "profiles"
   - Você deve ver o registro do admin

---

## 📋 PASSO 3: Testar o Sistema

### 3.1 Login como Administrador

1. **Acesse a aplicação:**
   - Abra seu app no navegador
   - Clique em "Login" ou "Área do Produtor"

2. **Faça login:**
   ```
   Email: agrouige@gmail.com
   Senha: admin074980
   ```

3. **Você deve ver:**
   - ✅ Dashboard de Administração
   - ✅ Estatísticas (tudo zerado ainda)
   - ✅ Botão "Sair" no canto superior direito

### 3.2 Criar Conta de Produtor (Teste)

1. **Abra uma aba anônima/privada** (Ctrl+Shift+N)
   - Isso permite testar sem fazer logout do admin

2. **Na nova aba:**
   - Acesse a aplicação
   - Clique em "Login"

3. **Crie conta de produtor:**
   - Clique em "Criar Conta"
   - Selecione "Produtor" (ícone do trator)
   - Preencha:
     ```
     Nome Completo: João Silva
     Email: produtor@teste.com
     Telefone: +244 923 456 789
     Senha: teste123
     Confirmar Senha: teste123
     Nome do Negócio: Fazenda São José
     Tipo de Negócio: Fazenda (Agricultura)
     Província: Luanda
     Município: Viana
     ```
   - Clique em "Criar Conta"

4. **Faça login com a nova conta:**
   ```
   Email: produtor@teste.com
   Senha: teste123
   ```

5. **Você deve ver:**
   - ✅ Dashboard do Produtor
   - ✅ Estatísticas zeradas
   - ✅ Botão "Adicionar Novo Produto"

### 3.3 Adicionar Produto

1. **No dashboard do produtor:**
   - Clique em "Adicionar Novo Produto"

2. **Preencha o formulário:**
   ```
   Nome do Produto: Tomate Fresco
   Descrição: Tomate orgânico, recém-colhido, da melhor qualidade
   Tipo de Negócio: Fazenda (Agricultura)
   Categoria: Vegetais
   Preço: 800
   Unidade: kg
   Quantidade Disponível: 500
   Província: Luanda
   Município: Viana
   ```

3. **Clique em "Enviar para Aprovação"**

4. **Você deve ver:**
   - ✅ Mensagem: "Produto adicionado! Aguardando aprovação do admin."
   - ✅ Produto aparece na lista com badge "Pendente"
   - ✅ Estatísticas atualizadas (1 pendente)

### 3.4 Aprovar Produto (como Admin)

1. **Volte para a aba do admin**
   - Dashboard de Administração

2. **Recarregue a página** (F5)

3. **Você deve ver:**
   - ✅ Estatísticas: "1 Pendente"
   - ✅ Produto "Tomate Fresco" listado
   - ✅ Badge "Aguardando Revisão"
   - ✅ Informações do produtor (João Silva)

4. **Aprovar o produto:**
   - Clique no botão verde "Aprovar"
   - No modal, deixe "Aprovar" selecionado
   - (Opcional) Adicione uma nota: "Produto aprovado, ótima qualidade!"
   - Clique em "Confirmar Aprovação"

5. **Você deve ver:**
   - ✅ Mensagem: "Produto aprovado com sucesso!"
   - ✅ Badge muda para "Aprovado"
   - ✅ Badge adicional: "Pagamento Pendente"

### 3.5 Confirmar Pagamento

1. **Ainda como admin:**
   - Localize o produto aprovado
   - Você verá o badge "Pagamento Pendente"

2. **Confirmar pagamento:**
   - Clique no botão verde "Confirmar Pagamento"
   - Confirme a ação

3. **Você deve ver:**
   - ✅ Mensagem: "Pagamento confirmado!"
   - ✅ Badge muda para "Pago - 2,500 Kz"
   - ✅ Produto agora está ativo

### 3.6 Ver no Marketplace

1. **Abra uma nova aba (normal, sem login)**
   - Acesse a aplicação

2. **Clique em "Marketplace"**

3. **Você deve ver:**
   - ✅ Produto "Tomate Fresco" visível
   - ✅ Preço: 800 Kz/kg
   - ✅ Localização: Luanda
   - ✅ Produtor: João Silva
   - ✅ Botões: WhatsApp e Telefone

4. **Teste o contacto:**
   - Clique em "WhatsApp"
   - Deve abrir WhatsApp com mensagem pré-preenchida

---

## 📋 PASSO 4: Testar Fluxo de Rejeição

### 4.1 Adicionar outro produto (como Produtor)

1. **Na aba do produtor:**
   - Adicione novo produto:
     ```
     Nome: Produto de Teste (Será Rejeitado)
     Descrição: Apenas para testar rejeição
     Categoria: Frutas
     Preço: 1000
     Unidade: kg
     Quantidade: 100
     ```

### 4.2 Rejeitar produto (como Admin)

1. **Na aba do admin:**
   - Recarregue a página
   - Localize o novo produto
   - Clique em "Rejeitar"

2. **No modal:**
   - Selecione "Rejeitar"
   - Adicione motivo: "Descrição insuficiente. Por favor, adicione mais detalhes sobre o produto."
   - Clique em "Confirmar Rejeição"

### 4.3 Verificar como produtor

1. **Volte para a aba do produtor:**
   - Recarregue a página
   - Você deve ver:
     - ✅ Produto com badge "Rejeitado"
     - ✅ Nota do admin visível em vermelho
     - ✅ Botão "Editar" disponível

2. **Editar e reenviar:**
   - Clique em "Editar"
   - Melhore a descrição
   - Clique em "Atualizar"
   - Produto volta para "Pendente"

---

## 📋 PASSO 5: Testar Renovação

### 5.1 Simular expiração (como Admin)

1. **No Supabase, SQL Editor:**

```sql
-- Fazer o produto expirar (para teste)
UPDATE products 
SET expires_at = NOW() - INTERVAL '1 day',
    status = 'expired'
WHERE title = 'Tomate Fresco';
```

### 5.2 Renovar (como Produtor)

1. **Dashboard do produtor:**
   - Recarregue a página
   - Produto agora aparece como "Expirado"
   - Botão "Renovar" visível

2. **Clique em "Renovar":**
   - Produto recebe +30 dias
   - Pagamento volta para "Pendente"
   - Admin precisa confirmar novo pagamento

---

## ✅ CHECKLIST FINAL

### Banco de Dados
- [ ] Schema SQL executado com sucesso
- [ ] Tabelas criadas (profiles, products, payments, product_history)
- [ ] Políticas RLS funcionando

### Autenticação
- [ ] Admin criado e consegue fazer login
- [ ] Produtor criado e consegue fazer login
- [ ] Sessões persistem após reload

### Dashboard Produtor
- [ ] Adicionar produto funciona
- [ ] Editar produto funciona
- [ ] Eliminar produto funciona
- [ ] Estatísticas atualizando
- [ ] Badges de status corretos

### Dashboard Admin
- [ ] Ver todos os produtos
- [ ] Aprovar produto funciona
- [ ] Rejeitar produto funciona
- [ ] Confirmar pagamento funciona
- [ ] Filtros funcionando
- [ ] Pesquisa funcionando

### Marketplace
- [ ] Produtos aprovados e pagos aparecem
- [ ] Filtros funcionam
- [ ] Botões de contacto funcionam
- [ ] Produtos expirados não aparecem

---

## 🐛 TROUBLESHOOTING

### "Não consigo fazer login"
**Solução:**
1. Verifique se o email está confirmado no Supabase Auth
2. Verifique se o perfil existe na tabela `profiles`
3. Tente resetar a senha

### "Produto não aparece no marketplace"
**Solução:**
1. Verifique no Table Editor → products:
   - status = 'approved'
   - payment_status = 'paid'
   - expires_at > NOW()

### "Erro ao adicionar produto"
**Solução:**
1. Abra o Console do navegador (F12)
2. Veja a aba "Console" para erros
3. Verifique políticas RLS no Supabase

### "RLS policy violation"
**Solução:**
```sql
-- Verificar se as políticas existem
SELECT * FROM pg_policies WHERE schemaname = 'public';

-- Se não existirem, execute novamente o schema SQL completo
```

---

## 🎉 PARABÉNS!

Se chegou até aqui, seu sistema está 100% funcional! 🌾🇦🇴

**Sistema Completo:**
- ✅ Autenticação multi-role
- ✅ Dashboard de Produtor
- ✅ Dashboard de Admin
- ✅ Marketplace Público
- ✅ Sistema de Aprovação
- ✅ Gestão de Pagamentos
- ✅ Renovação Automática

**Pronto para produção!** 🚀
