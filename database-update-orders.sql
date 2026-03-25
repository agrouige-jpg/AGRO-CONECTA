-- ============================================
-- ATUALIZAÇÃO: Novas Categorias e Sistema de Pedidos
-- ============================================

-- 1. ATUALIZAR CATEGORIAS DE PRODUTOS
ALTER TABLE products DROP CONSTRAINT IF EXISTS products_category_check;

ALTER TABLE products ADD CONSTRAINT products_category_check 
CHECK (category IN (
  -- Agricultura
  'vegetables', 'fruits', 'grains', 'tubers',
  -- Aves (NOVO)
  'chickens', 'pigeons', 'quails', 'parrots', 'ducks',
  -- Pecuária
  'pork', 'beef', 'goat', 'sheep',
  -- Derivados
  'eggs', 'milk', 'fish',
  -- Rações e Suplementos (NOVO)
  'animal_feed', 'supplements', 'vitamins',
  -- Outros
  'other'
));

-- 2. CRIAR TABELA DE PEDIDOS (ORDERS)
CREATE TABLE IF NOT EXISTS orders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_number TEXT UNIQUE NOT NULL, -- Ex: ORD-20260303-0001
  
  -- Cliente
  customer_name TEXT NOT NULL,
  customer_phone TEXT NOT NULL,
  customer_email TEXT,
  customer_address TEXT,
  customer_province TEXT NOT NULL,
  customer_municipality TEXT NOT NULL,
  
  -- Status do pedido
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN (
    'pending',      -- Aguardando confirmação do produtor
    'confirmed',    -- Produtor confirmou
    'preparing',    -- Em preparação
    'ready',        -- Pronto para entrega/recolha
    'completed',    -- Concluído
    'cancelled'     -- Cancelado
  )),
  
  -- Totais
  total_amount DECIMAL(12, 2) NOT NULL,
  total_items INTEGER NOT NULL,
  
  -- Notas
  customer_notes TEXT,
  producer_notes TEXT,
  
  -- Datas
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  confirmed_at TIMESTAMP WITH TIME ZONE,
  completed_at TIMESTAMP WITH TIME ZONE,
  cancelled_at TIMESTAMP WITH TIME ZONE,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. CRIAR TABELA DE ITENS DO PEDIDO (ORDER_ITEMS)
CREATE TABLE IF NOT EXISTS order_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  product_id UUID NOT NULL REFERENCES products(id),
  producer_id UUID NOT NULL REFERENCES profiles(id),
  
  -- Detalhes do produto no momento do pedido
  product_title TEXT NOT NULL,
  product_price DECIMAL(10, 2) NOT NULL,
  product_unit TEXT NOT NULL,
  
  -- Quantidade pedida
  quantity INTEGER NOT NULL,
  subtotal DECIMAL(12, 2) NOT NULL,
  
  -- Status individual do item
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN (
    'pending', 'confirmed', 'cancelled'
  )),
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. CRIAR TABELA DE NOTIFICAÇÕES DE PEDIDOS
CREATE TABLE IF NOT EXISTS order_notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  producer_id UUID NOT NULL REFERENCES profiles(id),
  
  -- Status da notificação
  is_read BOOLEAN DEFAULT FALSE,
  read_at TIMESTAMP WITH TIME ZONE,
  
  -- Resumo do pedido
  total_items INTEGER NOT NULL,
  total_amount DECIMAL(12, 2) NOT NULL,
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 5. ÍNDICES PARA PERFORMANCE
CREATE INDEX IF NOT EXISTS idx_orders_status ON orders(status);
CREATE INDEX IF NOT EXISTS idx_orders_created_at ON orders(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_orders_customer_phone ON orders(customer_phone);
CREATE INDEX IF NOT EXISTS idx_order_items_order ON order_items(order_id);
CREATE INDEX IF NOT EXISTS idx_order_items_product ON order_items(product_id);
CREATE INDEX IF NOT EXISTS idx_order_items_producer ON order_items(producer_id);
CREATE INDEX IF NOT EXISTS idx_order_notifications_producer ON order_notifications(producer_id);
CREATE INDEX IF NOT EXISTS idx_order_notifications_unread ON order_notifications(producer_id) WHERE is_read = FALSE;

-- 6. RLS (Row Level Security) PARA PEDIDOS

ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_notifications ENABLE ROW LEVEL SECURITY;

-- Qualquer um pode criar pedidos (clientes públicos)
CREATE POLICY "Qualquer um pode criar pedidos"
  ON orders FOR INSERT
  WITH CHECK (true);

-- Produtores podem ver pedidos que contêm seus produtos
CREATE POLICY "Produtores podem ver seus pedidos"
  ON orders FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM order_items
      WHERE order_items.order_id = orders.id
      AND order_items.producer_id = auth.uid()
    )
  );

-- Admins podem ver todos os pedidos
CREATE POLICY "Admins podem ver todos os pedidos"
  ON orders FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- Produtores podem atualizar status dos seus itens
CREATE POLICY "Produtores podem atualizar pedidos"
  ON orders FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM order_items
      WHERE order_items.order_id = orders.id
      AND order_items.producer_id = auth.uid()
    )
  );

-- Políticas para order_items
CREATE POLICY "Qualquer um pode criar itens de pedido"
  ON order_items FOR INSERT
  WITH CHECK (true);

CREATE POLICY "Produtores podem ver seus itens"
  ON order_items FOR SELECT
  USING (producer_id = auth.uid());

CREATE POLICY "Admins podem ver todos os itens"
  ON order_items FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

CREATE POLICY "Produtores podem atualizar seus itens"
  ON order_items FOR UPDATE
  USING (producer_id = auth.uid());

-- Políticas para notificações
CREATE POLICY "Produtores podem ver suas notificações"
  ON order_notifications FOR SELECT
  USING (producer_id = auth.uid());

CREATE POLICY "Produtores podem atualizar suas notificações"
  ON order_notifications FOR UPDATE
  USING (producer_id = auth.uid());

CREATE POLICY "Sistema pode criar notificações"
  ON order_notifications FOR INSERT
  WITH CHECK (true);

-- 7. FUNÇÃO PARA GERAR NÚMERO DE PEDIDO
CREATE OR REPLACE FUNCTION generate_order_number()
RETURNS TEXT AS $$
DECLARE
  today TEXT;
  counter INTEGER;
  order_num TEXT;
BEGIN
  today := TO_CHAR(NOW(), 'YYYYMMDD');
  
  -- Contar pedidos de hoje
  SELECT COUNT(*) + 1 INTO counter
  FROM orders
  WHERE order_number LIKE 'ORD-' || today || '-%';
  
  -- Gerar número com padding
  order_num := 'ORD-' || today || '-' || LPAD(counter::TEXT, 4, '0');
  
  RETURN order_num;
END;
$$ LANGUAGE plpgsql;

-- 8. TRIGGER PARA GERAR NÚMERO DE PEDIDO AUTOMATICAMENTE
CREATE OR REPLACE FUNCTION set_order_number()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.order_number IS NULL THEN
    NEW.order_number := generate_order_number();
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_set_order_number
  BEFORE INSERT ON orders
  FOR EACH ROW
  EXECUTE FUNCTION set_order_number();

-- 9. FUNÇÃO PARA CRIAR NOTIFICAÇÕES QUANDO PEDIDO É CRIADO
CREATE OR REPLACE FUNCTION notify_producers_on_order()
RETURNS TRIGGER AS $$
BEGIN
  -- Criar notificação para cada produtor envolvido
  INSERT INTO order_notifications (order_id, producer_id, total_items, total_amount)
  SELECT 
    NEW.id,
    oi.producer_id,
    COUNT(*),
    SUM(oi.subtotal)
  FROM order_items oi
  WHERE oi.order_id = NEW.id
  GROUP BY oi.producer_id;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_notify_producers
  AFTER INSERT ON orders
  FOR EACH ROW
  EXECUTE FUNCTION notify_producers_on_order();

-- 10. TRIGGER PARA ATUALIZAR updated_at
CREATE TRIGGER update_orders_updated_at
  BEFORE UPDATE ON orders
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- 11. VIEW PARA FACILITAR CONSULTAS DE PEDIDOS DOS PRODUTORES
CREATE OR REPLACE VIEW producer_orders AS
SELECT 
  o.id as order_id,
  o.order_number,
  o.customer_name,
  o.customer_phone,
  o.customer_email,
  o.customer_province,
  o.customer_municipality,
  o.customer_address,
  o.customer_notes,
  o.status as order_status,
  o.created_at,
  oi.producer_id,
  p.full_name as producer_name,
  p.business_name,
  p.phone as producer_phone,
  COUNT(oi.id) as total_items_from_producer,
  SUM(oi.subtotal) as total_amount_from_producer,
  json_agg(
    json_build_object(
      'product_title', oi.product_title,
      'quantity', oi.quantity,
      'price', oi.product_price,
      'unit', oi.product_unit,
      'subtotal', oi.subtotal,
      'status', oi.status
    )
  ) as items
FROM orders o
JOIN order_items oi ON o.id = oi.order_id
JOIN profiles p ON oi.producer_id = p.id
GROUP BY 
  o.id, o.order_number, o.customer_name, o.customer_phone, 
  o.customer_email, o.customer_province, o.customer_municipality,
  o.customer_address, o.customer_notes, o.status, o.created_at,
  oi.producer_id, p.full_name, p.business_name, p.phone;

-- 12. DADOS DE EXEMPLO PARA CATEGORIAS (OPCIONAL)
-- Você pode inserir produtos de exemplo das novas categorias

COMMENT ON TABLE orders IS 'Pedidos dos clientes';
COMMENT ON TABLE order_items IS 'Itens individuais de cada pedido';
COMMENT ON TABLE order_notifications IS 'Notificações de novos pedidos para produtores';
COMMENT ON VIEW producer_orders IS 'View facilitada para produtores verem seus pedidos';
