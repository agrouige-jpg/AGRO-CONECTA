# 🚀 Instruções de Configuração - AGRO CONECTA

## 📋 Pré-requisitos

1. Conta no Supabase (https://supabase.com)
2. Projeto criado no Supabase

## 🗄️ Configuração do Banco de Dados

### Passo 1: Executar o Schema SQL

1. Acesse o seu projeto no Supabase
2. Vá para **SQL Editor**
3. Crie uma nova query
4. Copie todo o conteúdo do arquivo `/database-schema-products.sql`
5. Execute a query (clique em "Run")

### Passo 2: Criar Primeiro Usuário Admin

Após executar o schema, você precisa criar o primeiro administrador:

1. Vá para **Authentication** > **Users**
2. Clique em "Add user" > "Create new user"
3. Preencha:
   - Email: `agrouige@gmail.com`
   - Password: `admin074980`
   - Confirme o email automaticamente

4. Copie o **User UID** que foi gerado

5. Volte ao **SQL Editor** e execute:

```sql
-- Substitua 'UUID_DO_USUARIO' pelo UID copiado
INSERT INTO profiles (id, email, full_name, role)
VALUES (
  'UUID_DO_USUARIO', 
  'agrouige@gmail.com', 
  'Administrador AGRO', 
  'admin'
);
```

### Passo 3: Configurar Email Auth (Opcional mas Recomendado)

1. Vá para **Authentication** > **Providers**
2. Habilite "Email"
3. Configure as configurações de email:
   - Você pode usar o email padrão do Supabase para testes
   - Para produção, configure um provedor SMTP customizado

## 🔑 Credenciais Configuradas

### Administrador Principal:
- **Email:** agrouige@gmail.com
- **Senha:** admin074980
- **Acesso:** Dashboard completo de administração

### Produtores:
- Podem se cadastrar pela plataforma
- Precisam preencher formulário completo
- Acesso: Dashboard de produtor

## 📊 Estrutura do Sistema

### Tabelas Criadas:

1. **profiles** - Perfis de usuários (admin e produtores)
2. **products** - Produtos cadastrados
3. **payments** - Histórico de pagamentos
4. **product_history** - Histórico de alterações

### Fluxo de Trabalho:

1. **Produtor se cadastra** → Perfil criado
2. **Produtor adiciona produto** → Status: "Pendente"
3. **Admin revisa produto** → Aprova ou Rejeita
4. **Se aprovado** → Produtor recebe notificação
5. **Produtor paga taxa** (2.500 Kz)
6. **Admin confirma pagamento** → Produto fica visível
7. **Produto expira em 30 dias** → Produtor pode renovar

## 🔒 Segurança (RLS - Row Level Security)

O sistema já vem com políticas de segurança configuradas:

- ✅ Produtores só veem seus próprios produtos
- ✅ Admins veem todos os produtos
- ✅ Público vê apenas produtos aprovados e ativos
- ✅ Histórico é protegido por permissões

## 🎨 Funcionalidades Implementadas

### Dashboard do Produtor:
- ✅ Adicionar produtos
- ✅ Editar produtos (pendentes/rejeitados)
- ✅ Eliminar produtos
- ✅ Renovar produtos expirados
- ✅ Ver estatísticas (visualizações, contactos)
- ✅ Receber feedback do admin

### Dashboard do Admin:
- ✅ Ver todos os produtos
- ✅ Filtrar por status (pendente/aprovado/rejeitado)
- ✅ Aprovar produtos com notas
- ✅ Rejeitar produtos com justificativa
- ✅ Confirmar pagamentos
- ✅ Ver informações do produtor
- ✅ Estatísticas completas

### Marketplace Público:
- ✅ Ver produtos aprovados e pagos
- ✅ Filtrar por categoria
- ✅ Filtrar por localização
- ✅ Contactar produtor (WhatsApp)
- ✅ Ver detalhes completos

## 📱 Categorias de Produtos

### Agricultura (Fazenda):
- Vegetais
- Frutas
- Grãos
- Tubérculos

### Pecuária (Criatório):
- Frango
- Porco
- Gado
- Cabra
- Ovelha
- Ovos
- Leite
- Peixe

## 💰 Sistema de Pagamento

- **Taxa de Publicação:** 2.500 Kz
- **Duração:** 30 dias
- **Renovação:** Possível após expiração
- **Métodos:** Multicaixa, Transferência, Express, Cash

## 🔧 Troubleshooting

### Erro: "RLS policy violation"
- Verifique se executou todo o schema SQL
- Verifique se o usuário tem perfil criado na tabela `profiles`

### Não consigo fazer login como admin
- Verifique se criou o perfil admin no passo 2
- Verifique se o UUID está correto

### Produtos não aparecem no marketplace
- Produtos precisam estar com status "approved"
- Produtos precisam ter payment_status "paid"
- Produtos não podem estar expirados (expires_at > NOW())

## 📞 Suporte

Para problemas técnicos, verifique:
1. Console do navegador (F12)
2. Logs do Supabase (Dashboard > Logs)
3. Verificar políticas RLS no Supabase

---

✅ **Sistema Pronto para Uso!**

Após seguir todos os passos, você terá:
- Sistema de autenticação funcionando
- Área de admin completa
- Área de produtor completa
- Marketplace público
- Sistema de aprovação de produtos
- Sistema de pagamentos
