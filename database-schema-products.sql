-- =============================================
-- AGRO CONECTA - Sistema de Gestão de Produtos
-- =============================================

-- Tabela de perfis de usuários (estende auth.users do Supabase)
CREATE TABLE IF NOT EXISTS profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT UNIQUE NOT NULL,
  full_name TEXT NOT NULL,
  role TEXT NOT NULL CHECK (role IN ('producer', 'admin')),
  phone TEXT,
  province TEXT,
  municipality TEXT,
  address TEXT,
  business_name TEXT,
  business_type TEXT CHECK (business_type IN ('farm', 'livestock', 'both')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabela de produtos
CREATE TABLE IF NOT EXISTS products (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  producer_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  category TEXT NOT NULL CHECK (category IN (
    'vegetables', 'fruits', 'grains', 'tubers',
    'chicken', 'pork', 'beef', 'goat', 'sheep',
    'eggs', 'milk', 'fish', 'other'
  )),
  business_type TEXT NOT NULL CHECK (business_type IN ('farm', 'livestock')),
  price DECIMAL(10, 2) NOT NULL,
  unit TEXT NOT NULL CHECK (unit IN ('kg', 'unidade', 'saco', 'caixa', 'litro', 'dúzia')),
  quantity_available INTEGER NOT NULL DEFAULT 0,
  location_province TEXT NOT NULL,
  location_municipality TEXT NOT NULL,
  
  -- Imagens (URLs das imagens do produto)
  image_url TEXT,
  images TEXT[], -- Array de URLs de imagens
  
  -- Status de aprovação
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected', 'expired')),
  admin_notes TEXT, -- Notas do admin sobre aprovação/rejeição
  
  -- Datas de publicação
  submitted_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  approved_at TIMESTAMP WITH TIME ZONE,
  expires_at TIMESTAMP WITH TIME ZONE, -- Data de expiração da publicação
  
  -- Pagamento
  payment_status TEXT NOT NULL DEFAULT 'pending' CHECK (payment_status IN ('pending', 'paid', 'expired')),
  payment_amount DECIMAL(10, 2) DEFAULT 2500.00, -- Taxa de publicação
  paid_at TIMESTAMP WITH TIME ZONE,
  
  -- Controle
  views INTEGER DEFAULT 0,
  contacts INTEGER DEFAULT 0, -- Quantas vezes foi contactado
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabela de pagamentos
CREATE TABLE IF NOT EXISTS payments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  producer_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  amount DECIMAL(10, 2) NOT NULL,
  payment_method TEXT CHECK (payment_method IN ('multicaixa', 'transfer', 'express', 'cash')),
  payment_reference TEXT, -- Referência do pagamento
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'confirmed', 'rejected')),
  confirmed_by UUID REFERENCES profiles(id), -- Admin que confirmou
  confirmed_at TIMESTAMP WITH TIME ZONE,
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabela de histórico de alterações
CREATE TABLE IF NOT EXISTS product_history (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  action TEXT NOT NULL CHECK (action IN ('created', 'updated', 'approved', 'rejected', 'renewed', 'expired', 'deleted')),
  changed_by UUID NOT NULL REFERENCES profiles(id),
  changes JSONB, -- Detalhes das mudanças
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índices para melhor performance
CREATE INDEX IF NOT EXISTS idx_products_producer ON products(producer_id);
CREATE INDEX IF NOT EXISTS idx_products_status ON products(status);
CREATE INDEX IF NOT EXISTS idx_products_category ON products(category);
CREATE INDEX IF NOT EXISTS idx_products_expires_at ON products(expires_at);
CREATE INDEX IF NOT EXISTS idx_payments_product ON payments(product_id);
CREATE INDEX IF NOT EXISTS idx_payments_producer ON payments(producer_id);
CREATE INDEX IF NOT EXISTS idx_product_history_product ON product_history(product_id);

-- RLS (Row Level Security) Policies

-- Habilitar RLS
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE product_history ENABLE ROW LEVEL SECURITY;

-- Policies para profiles
CREATE POLICY "Usuários podem ver seu próprio perfil"
  ON profiles FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Usuários podem atualizar seu próprio perfil"
  ON profiles FOR UPDATE
  USING (auth.uid() = id);

CREATE POLICY "Admins podem ver todos os perfis"
  ON profiles FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- Policies para products
CREATE POLICY "Todos podem ver produtos aprovados"
  ON products FOR SELECT
  USING (status = 'approved' AND expires_at > NOW());

CREATE POLICY "Produtores podem ver seus próprios produtos"
  ON products FOR SELECT
  USING (producer_id = auth.uid());

CREATE POLICY "Produtores podem criar produtos"
  ON products FOR INSERT
  WITH CHECK (
    producer_id = auth.uid() AND
    EXISTS (
      SELECT 1 FROM profiles
      WHERE id = auth.uid() AND role = 'producer'
    )
  );

CREATE POLICY "Produtores podem atualizar seus produtos pendentes"
  ON products FOR UPDATE
  USING (
    producer_id = auth.uid() AND
    status IN ('pending', 'rejected')
  );

CREATE POLICY "Produtores podem deletar seus produtos"
  ON products FOR DELETE
  USING (producer_id = auth.uid());

CREATE POLICY "Admins podem ver todos os produtos"
  ON products FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

CREATE POLICY "Admins podem atualizar qualquer produto"
  ON products FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- Policies para payments
CREATE POLICY "Produtores podem ver seus pagamentos"
  ON payments FOR SELECT
  USING (producer_id = auth.uid());

CREATE POLICY "Produtores podem criar pagamentos"
  ON payments FOR INSERT
  WITH CHECK (producer_id = auth.uid());

CREATE POLICY "Admins podem ver todos os pagamentos"
  ON payments FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

CREATE POLICY "Admins podem atualizar pagamentos"
  ON payments FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- Policies para product_history
CREATE POLICY "Admins e produtores podem ver histórico relevante"
  ON product_history FOR SELECT
  USING (
    changed_by = auth.uid() OR
    EXISTS (
      SELECT 1 FROM products
      WHERE products.id = product_history.product_id
      AND products.producer_id = auth.uid()
    ) OR
    EXISTS (
      SELECT 1 FROM profiles
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- Função para atualizar updated_at automaticamente
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers para atualizar updated_at
CREATE TRIGGER update_profiles_updated_at
  BEFORE UPDATE ON profiles
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_products_updated_at
  BEFORE UPDATE ON products
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Função para registrar histórico automaticamente
CREATE OR REPLACE FUNCTION log_product_history()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO product_history (product_id, action, changed_by, changes)
    VALUES (NEW.id, 'created', NEW.producer_id, row_to_json(NEW));
  ELSIF TG_OP = 'UPDATE' THEN
    INSERT INTO product_history (product_id, action, changed_by, changes)
    VALUES (
      NEW.id,
      CASE
        WHEN OLD.status != NEW.status AND NEW.status = 'approved' THEN 'approved'
        WHEN OLD.status != NEW.status AND NEW.status = 'rejected' THEN 'rejected'
        WHEN OLD.expires_at != NEW.expires_at THEN 'renewed'
        ELSE 'updated'
      END,
      auth.uid(),
      jsonb_build_object('old', row_to_json(OLD), 'new', row_to_json(NEW))
    );
  ELSIF TG_OP = 'DELETE' THEN
    INSERT INTO product_history (product_id, action, changed_by, changes)
    VALUES (OLD.id, 'deleted', auth.uid(), row_to_json(OLD));
  END IF;
  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

-- Trigger para histórico de produtos
CREATE TRIGGER product_history_trigger
  AFTER INSERT OR UPDATE OR DELETE ON products
  FOR EACH ROW
  EXECUTE FUNCTION log_product_history();

-- Criar primeiro usuário admin (execute após criar o usuário no Supabase Auth)
-- INSERT INTO profiles (id, email, full_name, role)
-- VALUES (
--   'UUID_DO_USUARIO_CRIADO', 
--   'agrouige@gmail.com', 
--   'Administrador AGRO', 
--   'admin'
-- );
