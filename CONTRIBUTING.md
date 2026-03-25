# 🤝 Guia de Contribuição

Obrigado pelo interesse em contribuir com AGRO CONECTA! Este guia irá ajudá-lo a começar.

---

## 📋 Código de Conduta

Ao participar deste projeto, você concorda em:

- Ser respeitoso com outros colaboradores
- Aceitar feedback construtivo
- Focar no que é melhor para a comunidade
- Mostrar empatia com outros membros

---

## 🚀 Como Contribuir

### 1. Reportar Bugs

Encontrou um bug? Ajude-nos a corrigir:

1. Verifique se já não foi reportado nas [Issues](../../issues)
2. Crie uma nova Issue incluindo:
   - Título claro e descritivo
   - Descrição detalhada do problema
   - Passos para reproduzir
   - Comportamento esperado vs atual
   - Screenshots (se aplicável)
   - Ambiente (navegador, OS, versão)

**Template de Bug Report:**
```markdown
## Descrição
[Descrição clara do bug]

## Passos para Reproduzir
1. Vá para '...'
2. Clique em '...'
3. Veja o erro

## Comportamento Esperado
[O que deveria acontecer]

## Comportamento Atual
[O que está acontecendo]

## Screenshots
[Se aplicável]

## Ambiente
- Navegador: [Chrome 120]
- OS: [Windows 11]
- Versão: [1.0.0]
```

---

### 2. Sugerir Funcionalidades

Tem uma ideia? Compartilhe!

1. Abra uma Issue com prefixo `[FEATURE]`
2. Descreva o problema que resolve
3. Proponha uma solução
4. Adicione mockups/exemplos se possível

**Template de Feature Request:**
```markdown
## Problema
[Qual problema esta funcionalidade resolve?]

## Solução Proposta
[Como você imagina que funcione?]

## Alternativas Consideradas
[Outras formas de resolver]

## Informações Adicionais
[Mockups, exemplos, etc]
```

---

### 3. Contribuir com Código

#### Setup Inicial

```bash
# 1. Fork o repositório no GitHub

# 2. Clone seu fork
git clone https://github.com/SEU_USUARIO/agro-conecta.git
cd agro-conecta

# 3. Adicione upstream
git remote add upstream https://github.com/ORIGINAL/agro-conecta.git

# 4. Instale dependências
npm install

# 5. Configure .env
cp .env.example .env
# Edite .env com suas credenciais
```

#### Workflow de Desenvolvimento

```bash
# 1. Crie uma branch
git checkout -b feature/minha-funcionalidade

# 2. Faça suas alterações
# ... código ...

# 3. Teste localmente
npm run dev

# 4. Commit suas mudanças
git add .
git commit -m "feat: adiciona nova funcionalidade"

# 5. Push para seu fork
git push origin feature/minha-funcionalidade

# 6. Abra um Pull Request no GitHub
```

---

## 📝 Padrões de Código

### Commits

Use [Conventional Commits](https://www.conventionalcommits.org/):

```bash
# Funcionalidade nova
git commit -m "feat: adiciona filtro por província"

# Correção de bug
git commit -m "fix: corrige erro no login"

# Documentação
git commit -m "docs: atualiza README com novas instruções"

# Estilo/formatação
git commit -m "style: formata componente Auth"

# Refatoração
git commit -m "refactor: simplifica lógica de OTP"

# Performance
git commit -m "perf: otimiza carregamento de imagens"

# Testes
git commit -m "test: adiciona testes para Auth"

# Build/CI
git commit -m "build: atualiza dependências"
```

---

### TypeScript

```typescript
// ✅ BOM - Sempre tipar
interface Product {
  id: string;
  name: string;
  price: number;
}

function getProduct(id: string): Promise<Product> {
  // ...
}

// ❌ EVITAR - Usar 'any'
function getProduct(id: any): any {
  // ...
}
```

---

### React Components

```typescript
// ✅ BOM - Componentes funcionais + TypeScript
interface ButtonProps {
  label: string;
  onClick: () => void;
  disabled?: boolean;
}

export function Button({ label, onClick, disabled = false }: ButtonProps) {
  return (
    <button onClick={onClick} disabled={disabled}>
      {label}
    </button>
  );
}

// ✅ BOM - Usar hooks
const [loading, setLoading] = useState(false);

// ❌ EVITAR - Class components
class Button extends React.Component {
  // ...
}
```

---

### Estrutura de Arquivos

```
src/
├── app/
│   ├── components/        # Componentes React
│   │   ├── Auth.tsx      # Um componente por arquivo
│   │   ├── Header.tsx
│   │   └── ui/           # Componentes reutilizáveis
│   └── App.tsx           # Componente principal
├── lib/                   # Utilitários e configurações
│   └── supabase.ts
└── styles/               # Estilos globais
    ├── index.css
    └── theme.css
```

---

### CSS/Tailwind

```typescript
// ✅ BOM - Classes do Tailwind
<div className="flex items-center gap-4 p-4 bg-white rounded-lg">

// ✅ BOM - Conditional classes
<div className={`btn ${loading ? 'opacity-50' : ''}`}>

// ✅ MELHOR - clsx para condicionais complexas
import { clsx } from 'clsx';
<div className={clsx(
  'btn',
  loading && 'opacity-50',
  error && 'border-red-500'
)}>

// ❌ EVITAR - Inline styles (exceto dinâmicos)
<div style={{ padding: '16px' }}>
```

---

## 🧪 Testes

### Adicionar Testes (Futuro)

Quando implementarmos testes:

```typescript
// tests/Auth.test.tsx
import { render, screen, fireEvent } from '@testing-library/react';
import { Auth } from '../src/app/components/Auth';

describe('Auth Component', () => {
  it('should render login form', () => {
    render(<Auth onAuthSuccess={() => {}} />);
    expect(screen.getByText('Entrar')).toBeInTheDocument();
  });

  it('should switch to register form', () => {
    render(<Auth onAuthSuccess={() => {}} />);
    fireEvent.click(screen.getByText('Não tem conta? Inscreva-se aqui'));
    expect(screen.getByText('Criar Conta')).toBeInTheDocument();
  });
});
```

---

## 📚 Documentação

### Comentários no Código

```typescript
// ✅ BOM - Explicar o "porquê"
// Simulamos delay para parecer mais realista ao usuário
await new Promise(resolve => setTimeout(resolve, 1000));

// ✅ BOM - Documentar funções complexas
/**
 * Calcula o rating médio de um produtor baseado em todas reviews
 * @param producerId - UUID do produtor
 * @returns Promise com o rating atualizado (0-5)
 */
async function calculateRating(producerId: string): Promise<number> {
  // ...
}

// ❌ EVITAR - Comentar o óbvio
// Incrementa contador
counter++;
```

---

### README e Docs

- Atualize README.md se mudar funcionalidades principais
- Adicione exemplos de uso
- Mantenha screenshots atualizados
- Documente breaking changes

---

## 🔍 Code Review

### O que procuramos

- ✅ Código limpo e legível
- ✅ Segue padrões do projeto
- ✅ Funciona conforme esperado
- ✅ Sem bugs óbvios
- ✅ Performance adequada
- ✅ Segurança considerada
- ✅ Documentação atualizada

### Recebendo Feedback

- Seja aberto a sugestões
- Faça perguntas se não entender
- Não leve críticas para o pessoal
- Aprenda e melhore

---

## ✅ Checklist do Pull Request

Antes de abrir o PR, verifique:

- [ ] Código segue os padrões do projeto
- [ ] Commits seguem Conventional Commits
- [ ] Testado localmente e funciona
- [ ] Sem erros no console
- [ ] Sem warnings de linter
- [ ] Documentação atualizada (se necessário)
- [ ] Screenshots incluídos (se mudança visual)
- [ ] Branch está atualizada com main

---

## 🎯 Áreas que Precisam de Ajuda

### Alta Prioridade

- [ ] Testes automatizados
- [ ] Sistema de chat em tempo real
- [ ] Integração WhatsApp Business (Twilio)
- [ ] Sistema de pagamentos Multicaixa
- [ ] PWA com modo offline

### Média Prioridade

- [ ] Dashboard analytics
- [ ] Sistema de notificações
- [ ] Multi-idioma (i18n)
- [ ] Otimização de imagens
- [ ] Acessibilidade (a11y)

### Baixa Prioridade

- [ ] Dark mode
- [ ] Animações aprimoradas
- [ ] Easter eggs
- [ ] Mais templates de produtos

---

## 🎨 Design

### Figma

Se tiver acesso ao Figma, consulte o design original antes de fazer mudanças visuais significativas.

### Design System

Mantenha consistência:
- Cores: Verde primário (#10B981)
- Espaçamento: Múltiplos de 4px
- Border radius: 8px (padrão), 12px (cards), 16px (modais)
- Sombras: Usar classes Tailwind shadow-*

---

## 📞 Dúvidas?

- 📧 Email: agrouige@gmail.com
- 💬 Abra uma Issue com tag `[QUESTION]`
- 📖 Leia a documentação completa

---

## 🙏 Agradecimentos

Todo tipo de contribuição é bem-vinda:

- 💻 Código
- 🐛 Reportar bugs
- 💡 Sugestões
- 📖 Documentação
- 🎨 Design
- 🌍 Traduções
- ⭐ Dar star no projeto

**Obrigado por ajudar a construir AGRO CONECTA! 🌾**

---

**Última atualização:** 01/02/2026
