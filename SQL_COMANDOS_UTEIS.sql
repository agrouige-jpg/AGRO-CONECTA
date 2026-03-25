-- ============================================
-- COMANDOS SQL ÚTEIS - AGRO CONECTA
-- ============================================

-- 🔧 ADMINISTRAÇÃO E MANUTENÇÃO

-- ============================================
-- 1. CRIAR PRIMEIRO ADMIN
-- ============================================

-- Após criar usuário no Supabase Auth, execute:
INSERT INTO profiles (id, email, full_name, role)
VALUES (
  'COLE_UUID_AQUI',  -- UUID do usuário criado no Auth
  'agrouige@gmail.com', 
  'Administrador AGRO', 
  'admin'
);

-- ============================================
-- 2. CRIAR ADMIN ADICIONAL
-- ============================================

INSERT INTO profiles (id, email, full_name, role)
VALUES (
  'UUID_DO_NOVO_ADMIN',
  'novoadmin@agroconecta.ao',
  'Nome do Novo Admin',
  'admin'
);

-- ============================================
-- 3. VERIFICAR TODOS OS USUÁRIOS
-- ============================================

-- Ver todos os perfis
SELECT 
  id,
  email,
  full_name,
  role,
  business_name,
  province,
  created_at
FROM profiles
ORDER BY created_at DESC;

-- Ver apenas admins
SELECT * FROM profiles WHERE role = 'admin';

-- Ver apenas produtores
SELECT * FROM profiles WHERE role = 'producer';

-- ============================================
-- 4. ESTATÍSTICAS GERAIS
-- ============================================

-- Total de usuários por tipo
SELECT role, COUNT(*) as total
FROM profiles
GROUP BY role;

-- Total de produtos por status
SELECT status, COUNT(*) as total
FROM products
GROUP BY status;

-- Total de produtos por província
SELECT location_province, COUNT(*) as total
FROM products
WHERE status = 'approved' AND payment_status = 'paid'
GROUP BY location_province
ORDER BY total DESC;

-- Produtores mais ativos
SELECT 
  p.full_name,
  p.business_name,
  COUNT(pr.id) as total_produtos
FROM profiles p
LEFT JOIN products pr ON p.id = pr.producer_id
WHERE p.role = 'producer'
GROUP BY p.id, p.full_name, p.business_name
ORDER BY total_produtos DESC
LIMIT 10;

-- ============================================
-- 5. GESTÃO DE PRODUTOS
-- ============================================

-- Ver produtos pendentes de aprovação
SELECT 
  pr.id,
  pr.title,
  pr.price,
  pr.location_province,
  p.full_name as produtor,
  p.phone,
  pr.submitted_at
FROM products pr
JOIN profiles p ON pr.producer_id = p.id
WHERE pr.status = 'pending'
ORDER BY pr.submitted_at ASC;

-- Ver produtos com pagamento pendente
SELECT 
  pr.id,
  pr.title,
  pr.payment_amount,
  p.full_name as produtor,
  p.phone,
  pr.approved_at
FROM products pr
JOIN profiles p ON pr.producer_id = p.id
WHERE pr.status = 'approved' AND pr.payment_status = 'pending'
ORDER BY pr.approved_at ASC;

-- Ver produtos ativos no marketplace
SELECT 
  pr.id,
  pr.title,
  pr.price,
  pr.unit,
  pr.views,
  pr.contacts,
  p.full_name as produtor,
  pr.expires_at
FROM products pr
JOIN profiles p ON pr.producer_id = p.id
WHERE pr.status = 'approved' 
  AND pr.payment_status = 'paid'
  AND pr.expires_at > NOW()
ORDER BY pr.views DESC;

-- Ver produtos que vão expirar em 7 dias
SELECT 
  pr.id,
  pr.title,
  p.full_name as produtor,
  p.phone,
  pr.expires_at
FROM products pr
JOIN profiles p ON pr.producer_id = p.id
WHERE pr.status = 'approved' 
  AND pr.payment_status = 'paid'
  AND pr.expires_at BETWEEN NOW() AND NOW() + INTERVAL '7 days'
ORDER BY pr.expires_at ASC;

-- ============================================
-- 6. APROVAR PRODUTO MANUALMENTE
-- ============================================

UPDATE products 
SET 
  status = 'approved',
  approved_at = NOW(),
  expires_at = NOW() + INTERVAL '30 days',
  admin_notes = 'Aprovado manualmente via SQL'
WHERE id = 'COLE_ID_DO_PRODUTO_AQUI';

-- ============================================
-- 7. REJEITAR PRODUTO MANUALMENTE
-- ============================================

UPDATE products 
SET 
  status = 'rejected',
  admin_notes = 'Descrição insuficiente. Por favor, adicione mais detalhes.'
WHERE id = 'COLE_ID_DO_PRODUTO_AQUI';

-- ============================================
-- 8. CONFIRMAR PAGAMENTO MANUALMENTE
-- ============================================

UPDATE products 
SET 
  payment_status = 'paid',
  paid_at = NOW()
WHERE id = 'COLE_ID_DO_PRODUTO_AQUI';

-- ============================================
-- 9. RENOVAR PRODUTO MANUALMENTE
-- ============================================

UPDATE products 
SET 
  expires_at = expires_at + INTERVAL '30 days',
  payment_status = 'pending'
WHERE id = 'COLE_ID_DO_PRODUTO_AQUI';

-- ============================================
-- 10. EXPIRAR PRODUTOS ANTIGOS
-- ============================================

-- Ver produtos que deveriam estar expirados
SELECT 
  id,
  title,
  expires_at,
  status
FROM products
WHERE expires_at < NOW() AND status = 'approved';

-- Marcar como expirados
UPDATE products 
SET status = 'expired'
WHERE expires_at < NOW() AND status = 'approved';

-- ============================================
-- 11. RELATÓRIOS E ANALYTICS
-- ============================================

-- Produtos mais visualizados
SELECT 
  pr.title,
  pr.price,
  pr.views,
  pr.contacts,
  p.full_name as produtor,
  pr.location_province
FROM products pr
JOIN profiles p ON pr.producer_id = p.id
WHERE pr.status = 'approved'
ORDER BY pr.views DESC
LIMIT 10;

-- Produtos mais contactados
SELECT 
  pr.title,
  pr.contacts,
  pr.views,
  ROUND((pr.contacts::NUMERIC / NULLIF(pr.views, 0) * 100), 2) as taxa_conversao,
  p.full_name as produtor
FROM products pr
JOIN profiles p ON pr.producer_id = p.id
WHERE pr.status = 'approved' AND pr.views > 0
ORDER BY pr.contacts DESC
LIMIT 10;

-- Receita total gerada
SELECT 
  COUNT(*) as total_produtos_pagos,
  SUM(payment_amount) as receita_total
FROM products
WHERE payment_status = 'paid';

-- Receita por mês
SELECT 
  DATE_TRUNC('month', paid_at) as mes,
  COUNT(*) as produtos_pagos,
  SUM(payment_amount) as receita
FROM products
WHERE payment_status = 'paid' AND paid_at IS NOT NULL
GROUP BY DATE_TRUNC('month', paid_at)
ORDER BY mes DESC;

-- ============================================
-- 12. LIMPEZA E MANUTENÇÃO
-- ============================================

-- Eliminar produtos rejeitados antigos (mais de 90 dias)
DELETE FROM products
WHERE status = 'rejected' 
  AND created_at < NOW() - INTERVAL '90 days';

-- Eliminar produtos expirados antigos (mais de 60 dias)
DELETE FROM products
WHERE status = 'expired' 
  AND expires_at < NOW() - INTERVAL '60 days';

-- ============================================
-- 13. BACKUP E EXPORTAÇÃO
-- ============================================

-- Exportar todos os produtos ativos
COPY (
  SELECT 
    pr.title,
    pr.description,
    pr.category,
    pr.price,
    pr.unit,
    pr.location_province,
    p.full_name as produtor,
    p.phone,
    pr.views,
    pr.contacts
  FROM products pr
  JOIN profiles p ON pr.producer_id = p.id
  WHERE pr.status = 'approved' AND pr.payment_status = 'paid'
) TO '/tmp/produtos_ativos.csv' WITH CSV HEADER;

-- Exportar todos os produtores
COPY (
  SELECT 
    full_name,
    email,
    phone,
    business_name,
    business_type,
    province,
    municipality,
    created_at
  FROM profiles
  WHERE role = 'producer'
) TO '/tmp/produtores.csv' WITH CSV HEADER;

-- ============================================
-- 14. TESTES E DESENVOLVIMENTO
-- ============================================

-- Criar produto de teste (use seu UUID de produtor)
INSERT INTO products (
  producer_id,
  title,
  description,
  category,
  business_type,
  price,
  unit,
  quantity_available,
  location_province,
  location_municipality,
  status,
  payment_status,
  expires_at
) VALUES (
  'SEU_UUID_PRODUTOR',
  'Tomate Orgânico de Teste',
  'Tomate fresco cultivado sem agrotóxicos, colhido diariamente',
  'vegetables',
  'farm',
  850.00,
  'kg',
  200,
  'Luanda',
  'Viana',
  'approved',
  'paid',
  NOW() + INTERVAL '30 days'
);

-- Simular visualizações e contactos
UPDATE products 
SET 
  views = FLOOR(RANDOM() * 100),
  contacts = FLOOR(RANDOM() * 20)
WHERE status = 'approved';

-- ============================================
-- 15. TROUBLESHOOTING
-- ============================================

-- Verificar políticas RLS
SELECT * FROM pg_policies 
WHERE schemaname = 'public' 
  AND tablename IN ('profiles', 'products', 'payments', 'product_history');

-- Verificar se usuário tem perfil
SELECT 
  au.id,
  au.email,
  p.full_name,
  p.role
FROM auth.users au
LEFT JOIN profiles p ON au.id = p.id
WHERE p.id IS NULL; -- Usuários sem perfil

-- Verificar produtos órfãos (sem produtor)
SELECT * FROM products
WHERE producer_id NOT IN (SELECT id FROM profiles);

-- ============================================
-- 16. RESETAR DADOS DE TESTE
-- ============================================

-- ⚠️ CUIDADO: Isso apaga TODOS os produtos
-- DELETE FROM products;

-- ⚠️ CUIDADO: Isso apaga todos os produtores (mantém admins)
-- DELETE FROM profiles WHERE role = 'producer';

-- Resetar contadores de um produto
UPDATE products 
SET views = 0, contacts = 0
WHERE id = 'COLE_ID_DO_PRODUTO';

-- ============================================
-- 17. MIGRAÇÃO E ATUALIZAÇÃO
-- ============================================

-- Adicionar nova coluna (exemplo)
-- ALTER TABLE products ADD COLUMN IF NOT EXISTS featured BOOLEAN DEFAULT FALSE;

-- Atualizar estrutura de tabela
-- ALTER TABLE products ALTER COLUMN price TYPE NUMERIC(12,2);

-- Criar índice adicional
-- CREATE INDEX IF NOT EXISTS idx_products_featured ON products(featured) WHERE featured = TRUE;

-- ============================================
-- 18. MONITORAMENTO
-- ============================================

-- Ver tamanho das tabelas
SELECT 
  schemaname,
  tablename,
  pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;

-- Ver número de registros em cada tabela
SELECT 
  'profiles' as tabela, COUNT(*) as registros FROM profiles
UNION ALL
SELECT 'products', COUNT(*) FROM products
UNION ALL
SELECT 'payments', COUNT(*) FROM payments
UNION ALL
SELECT 'product_history', COUNT(*) FROM product_history;

-- Ver últimas alterações (histórico)
SELECT 
  ph.action,
  ph.created_at,
  p_changed.full_name as quem_mudou,
  pr.title as produto
FROM product_history ph
LEFT JOIN profiles p_changed ON ph.changed_by = p_changed.id
LEFT JOIN products pr ON ph.product_id = pr.id
ORDER BY ph.created_at DESC
LIMIT 20;

-- ============================================
-- 19. NOTIFICAÇÕES E ALERTAS
-- ============================================

-- Produtos pendentes há mais de 3 dias
SELECT 
  pr.id,
  pr.title,
  p.full_name as produtor,
  p.email,
  p.phone,
  pr.submitted_at,
  NOW() - pr.submitted_at as tempo_espera
FROM products pr
JOIN profiles p ON pr.producer_id = p.id
WHERE pr.status = 'pending' 
  AND pr.submitted_at < NOW() - INTERVAL '3 days'
ORDER BY pr.submitted_at ASC;

-- ============================================
-- 20. PERFORMANCE
-- ============================================

-- Analisar performance de queries
EXPLAIN ANALYZE
SELECT * FROM products
WHERE status = 'approved' 
  AND payment_status = 'paid'
  AND expires_at > NOW();

-- Reindexar tabelas
REINDEX TABLE products;
REINDEX TABLE profiles;

-- Atualizar estatísticas
ANALYZE products;
ANALYZE profiles;

-- ============================================
-- FIM DOS COMANDOS ÚTEIS
-- ============================================

-- 💡 DICAS:
-- 1. Sempre faça backup antes de comandos DELETE/UPDATE em massa
-- 2. Teste comandos em ambiente de desenvolvimento primeiro
-- 3. Use transações para operações críticas
-- 4. Monitore o tamanho do banco regularmente
-- 5. Crie índices para queries frequentes
