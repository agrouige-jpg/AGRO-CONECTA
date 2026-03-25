-- ============================================
-- AGRO CONECTA - DATABASE SCHEMA
-- Supabase PostgreSQL Setup
-- ============================================

-- Habilitar extensões necessárias
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================
-- TABELA: products
-- Armazena todos os produtos do marketplace
-- ============================================
CREATE TABLE IF NOT EXISTS products (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  category TEXT NOT NULL CHECK (category IN (
    'Hortaliças',
    'Frutas',
    'Grãos',
    'Aves',
    'Suínos',
    'Bovinos',
    'Caprinos',
    'Ovinos',
    'Outros'
  )),
  price_min DECIMAL(10,2),
  price_max DECIMAL(10,2),
  unit TEXT, -- kg, unidade, par, dúzia, etc
  description TEXT,
  producer_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  image_url TEXT,
  stock_status TEXT DEFAULT 'available' CHECK (stock_status IN ('available', 'low', 'out')),
  views_count INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índices para performance
CREATE INDEX idx_products_category ON products(category);
CREATE INDEX idx_products_producer ON products(producer_id);
CREATE INDEX idx_products_created ON products(created_at DESC);

-- ============================================
-- TABELA: producers
-- Perfis detalhados dos produtores
-- ============================================
CREATE TABLE IF NOT EXISTS producers (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE UNIQUE,
  name TEXT NOT NULL,
  location TEXT,
  province TEXT,
  specialty TEXT,
  rating DECIMAL(2,1) DEFAULT 0 CHECK (rating >= 0 AND rating <= 5),
  reviews_count INTEGER DEFAULT 0,
  phone TEXT,
  whatsapp TEXT,
  email TEXT,
  bio TEXT,
  avatar_url TEXT,
  verified BOOLEAN DEFAULT false,
  active BOOLEAN DEFAULT true,
  joined_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índices
CREATE INDEX idx_producers_user ON producers(user_id);
CREATE INDEX idx_producers_rating ON producers(rating DESC);
CREATE INDEX idx_producers_location ON producers(location);

-- ============================================
-- TABELA: reviews
-- Avaliações dos produtores
-- ============================================
CREATE TABLE IF NOT EXISTS reviews (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  producer_id UUID REFERENCES producers(id) ON DELETE CASCADE,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
  comment TEXT,
  helpful_count INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(producer_id, user_id) -- Um usuário só pode avaliar um produtor uma vez
);

-- Índices
CREATE INDEX idx_reviews_producer ON reviews(producer_id);
CREATE INDEX idx_reviews_user ON reviews(user_id);
CREATE INDEX idx_reviews_created ON reviews(created_at DESC);

-- ============================================
-- TABELA: favorites
-- Produtos favoritos dos usuários
-- ============================================
CREATE TABLE IF NOT EXISTS favorites (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  product_id UUID REFERENCES products(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, product_id)
);

-- Índices
CREATE INDEX idx_favorites_user ON favorites(user_id);
CREATE INDEX idx_favorites_product ON favorites(product_id);

-- ============================================
-- TABELA: messages (Planejado)
-- Sistema de mensagens entre usuários
-- ============================================
CREATE TABLE IF NOT EXISTS messages (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  sender_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  recipient_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  product_id UUID REFERENCES products(id) ON DELETE SET NULL,
  message TEXT NOT NULL,
  read BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índices
CREATE INDEX idx_messages_sender ON messages(sender_id);
CREATE INDEX idx_messages_recipient ON messages(recipient_id);
CREATE INDEX idx_messages_created ON messages(created_at DESC);

-- ============================================
-- TABELA: orders (Planejado)
-- Pedidos realizados
-- ============================================
CREATE TABLE IF NOT EXISTS orders (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  buyer_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  producer_id UUID REFERENCES producers(id) ON DELETE SET NULL,
  product_id UUID REFERENCES products(id) ON DELETE SET NULL,
  quantity DECIMAL(10,2) NOT NULL,
  unit_price DECIMAL(10,2) NOT NULL,
  total_price DECIMAL(10,2) NOT NULL,
  status TEXT DEFAULT 'pending' CHECK (status IN (
    'pending',
    'confirmed',
    'in_transit',
    'delivered',
    'cancelled'
  )),
  delivery_address TEXT,
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índices
CREATE INDEX idx_orders_buyer ON orders(buyer_id);
CREATE INDEX idx_orders_producer ON orders(producer_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_created ON orders(created_at DESC);

-- ============================================
-- TABELA: payments (Planejado)
-- Registro de pagamentos
-- ============================================
CREATE TABLE IF NOT EXISTS payments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  order_id UUID REFERENCES orders(id) ON DELETE SET NULL,
  amount DECIMAL(10,2) NOT NULL,
  currency TEXT DEFAULT 'AOA',
  payment_method TEXT,
  transaction_id TEXT UNIQUE,
  status TEXT DEFAULT 'pending' CHECK (status IN (
    'pending',
    'processing',
    'completed',
    'failed',
    'refunded'
  )),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índices
CREATE INDEX idx_payments_user ON payments(user_id);
CREATE INDEX idx_payments_order ON payments(order_id);
CREATE INDEX idx_payments_status ON payments(status);
CREATE INDEX idx_payments_transaction ON payments(transaction_id);

-- ============================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================

-- Habilitar RLS em todas as tabelas
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE producers ENABLE ROW LEVEL SECURITY;
ALTER TABLE reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE favorites ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;

-- ============================================
-- POLÍTICAS: products
-- ============================================

-- Qualquer pessoa pode visualizar produtos
CREATE POLICY "Anyone can read products"
ON products FOR SELECT
USING (true);

-- Usuários autenticados que pagaram podem inserir produtos
CREATE POLICY "Paid users can insert products"
ON products FOR INSERT
WITH CHECK (
  auth.uid() = producer_id AND
  auth.jwt() ->> 'has_paid' = 'true'
);

-- Produtores podem atualizar seus próprios produtos
CREATE POLICY "Producers can update own products"
ON products FOR UPDATE
USING (auth.uid() = producer_id)
WITH CHECK (auth.uid() = producer_id);

-- Produtores podem deletar seus próprios produtos
CREATE POLICY "Producers can delete own products"
ON products FOR DELETE
USING (auth.uid() = producer_id);

-- ============================================
-- POLÍTICAS: producers
-- ============================================

-- Qualquer pessoa pode visualizar produtores
CREATE POLICY "Anyone can read producers"
ON producers FOR SELECT
USING (true);

-- Usuários autenticados podem criar perfil de produtor
CREATE POLICY "Authenticated users can insert producer profile"
ON producers FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- Produtores podem atualizar seu próprio perfil
CREATE POLICY "Producers can update own profile"
ON producers FOR UPDATE
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- ============================================
-- POLÍTICAS: reviews
-- ============================================

-- Qualquer pessoa pode ler reviews
CREATE POLICY "Anyone can read reviews"
ON reviews FOR SELECT
USING (true);

-- Usuários autenticados que pagaram podem criar reviews
CREATE POLICY "Paid users can insert reviews"
ON reviews FOR INSERT
WITH CHECK (
  auth.uid() = user_id AND
  auth.jwt() ->> 'has_paid' = 'true'
);

-- Usuários podem atualizar suas próprias reviews
CREATE POLICY "Users can update own reviews"
ON reviews FOR UPDATE
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- Usuários podem deletar suas próprias reviews
CREATE POLICY "Users can delete own reviews"
ON reviews FOR DELETE
USING (auth.uid() = user_id);

-- ============================================
-- POLÍTICAS: favorites
-- ============================================

-- Usuários podem ver apenas seus próprios favoritos
CREATE POLICY "Users can read own favorites"
ON favorites FOR SELECT
USING (auth.uid() = user_id);

-- Usuários podem adicionar favoritos
CREATE POLICY "Users can insert favorites"
ON favorites FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- Usuários podem remover favoritos
CREATE POLICY "Users can delete own favorites"
ON favorites FOR DELETE
USING (auth.uid() = user_id);

-- ============================================
-- FUNÇÕES E TRIGGERS
-- ============================================

-- Função para atualizar updated_at automaticamente
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
   NEW.updated_at = NOW();
   RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers para updated_at
CREATE TRIGGER update_products_updated_at BEFORE UPDATE ON products
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_producers_updated_at BEFORE UPDATE ON producers
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_reviews_updated_at BEFORE UPDATE ON reviews
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_orders_updated_at BEFORE UPDATE ON orders
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_payments_updated_at BEFORE UPDATE ON payments
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Função para calcular rating médio do produtor
CREATE OR REPLACE FUNCTION calculate_producer_rating(producer_uuid UUID)
RETURNS VOID AS $$
BEGIN
  UPDATE producers
  SET 
    rating = (
      SELECT COALESCE(AVG(rating), 0)
      FROM reviews
      WHERE producer_id = producer_uuid
    ),
    reviews_count = (
      SELECT COUNT(*)
      FROM reviews
      WHERE producer_id = producer_uuid
    )
  WHERE id = producer_uuid;
END;
$$ LANGUAGE plpgsql;

-- Trigger para atualizar rating após inserção de review
CREATE OR REPLACE FUNCTION update_producer_rating_after_review()
RETURNS TRIGGER AS $$
BEGIN
  PERFORM calculate_producer_rating(NEW.producer_id);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_rating_after_review_insert
AFTER INSERT ON reviews
FOR EACH ROW EXECUTE FUNCTION update_producer_rating_after_review();

CREATE TRIGGER update_rating_after_review_update
AFTER UPDATE ON reviews
FOR EACH ROW EXECUTE FUNCTION update_producer_rating_after_review();

CREATE TRIGGER update_rating_after_review_delete
AFTER DELETE ON reviews
FOR EACH ROW EXECUTE FUNCTION update_producer_rating_after_review();

-- ============================================
-- DADOS INICIAIS (SEED)
-- ============================================

-- Inserir categorias padrão e produtos exemplo
-- (Execute depois de criar um usuário de teste)

-- Nota: Substitua 'USER_UUID_HERE' pelo UUID real do usuário

/*
-- Exemplo de produtos iniciais
INSERT INTO products (name, category, price_min, price_max, unit, description) VALUES
('Tomate', 'Hortaliças', 500, 800, 'kg', 'Tomate fresco local de alta qualidade'),
('Alface', 'Hortaliças', 300, 500, 'unidade', 'Alface crespa cultivada sem agrotóxicos'),
('Banana', 'Frutas', 250, 400, 'kg', 'Banana da terra madura'),
('Milho', 'Grãos', 180, 300, 'kg', 'Milho amarelo de qualidade premium'),
('Frango Caipira', 'Aves', 1200, 1800, 'kg', 'Frango criado solto, alimentação natural'),
('Ovos Caipira', 'Aves', 50, 80, 'unidade', 'Ovos frescos de galinhas caipiras'),
('Pombos', 'Aves', 2500, 4200, 'par', 'Pombos para criação ou consumo'),
('Patos', 'Aves', 8600, 14200, 'unidade', 'Patos adultos de raça selecionada');
*/

-- ============================================
-- VIEWS ÚTEIS
-- ============================================

-- View: Produtos com informações do produtor
CREATE OR REPLACE VIEW products_with_producer AS
SELECT 
  p.*,
  pr.name as producer_name,
  pr.location as producer_location,
  pr.rating as producer_rating,
  pr.whatsapp as producer_whatsapp
FROM products p
LEFT JOIN producers pr ON p.producer_id = pr.user_id;

-- View: Estatísticas do marketplace
CREATE OR REPLACE VIEW marketplace_stats AS
SELECT
  (SELECT COUNT(*) FROM products) as total_products,
  (SELECT COUNT(*) FROM producers WHERE active = true) as active_producers,
  (SELECT COUNT(*) FROM reviews) as total_reviews,
  (SELECT AVG(rating) FROM reviews) as average_rating,
  (SELECT COUNT(*) FROM auth.users) as total_users;

-- ============================================
-- BACKUP RECOMENDADO
-- Execute periodicamente:
-- pg_dump -h seu-host -U seu-usuario -d agro-conecta > backup.sql
-- ============================================
