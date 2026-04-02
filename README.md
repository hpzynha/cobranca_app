<p align="center">
  <img src="https://mensalify.com.br/icon.png" alt="Mensalify Logo" width="100"/>
</p>

<h1 align="center">mensalify</h1>

<p align="center">
  <strong>Seu trabalho vale. Cobre por ele.</strong><br/>
  Automatize cobranças via WhatsApp e nunca mais perca dinheiro por vergonha de cobrar.
</p>

<p align="center">
  <img alt="Flutter" src="https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter&logoColor=white"/>
  <img alt="Supabase" src="https://img.shields.io/badge/Supabase-Backend-3ECF8E?logo=supabase&logoColor=white"/>
  <img alt="Dart" src="https://img.shields.io/badge/Dart-3.x-0553B1?logo=dart&logoColor=white"/>
  <img alt="Status" src="https://img.shields.io/badge/status-em%20lançamento-purple"/>
</p>

---

## 📲 Sobre o Mensalify

Professores particulares e personal trainers perdem dinheiro todo mês — não porque seus clientes não pagam, mas porque **cobrar é constrangedor**. Mensalify resolve isso.

O app automatiza lembretes de pagamento via WhatsApp, exibe o status de cada aluno em tempo real e elimina completamente a necessidade de cobrar manualmente. O usuário cadastra, o app cuida do resto.

> *"Automatize suas cobranças e nunca mais perca dinheiro."*

---

## ✨ Funcionalidades

### Já disponíveis

- **Gestão de alunos** — Cadastro completo com foto, WhatsApp (com seletor de país) e dados de mensalidade
- **Status de pagamento em tempo real** — Pago ✅ · Vence hoje ⚠️ · Atrasado ❌ — calculado automaticamente por data
- **Dashboard financeiro** — Receita mensal consolidada e total de alunos em um único painel
- **Relatórios** — Visão clara da saúde financeira do negócio
- **Autenticação completa** — Login por e-mail/senha e Google Sign-In, verificação de e-mail, recuperação de senha
- **Perfil de usuário** — Edição de dados pessoais, visualização de métricas-chave
- **Notificações** — Alertas configuráveis por aluno
- **Modo escuro** — Interface adaptável à preferência do usuário
- **Planos Free e Pro** — Free até 3 alunos; Pro em R$ 39,90/mês via PIX (AbacatePay)
- **Sistema de cupons** — Desconto aplicável no checkout do plano Pro

### Em desenvolvimento

- [ ] Automação de cobranças via WhatsApp (Meta Business API)
- [ ] Relatórios avançados com gráficos e histórico
- [ ] Exportação de dados
- [ ] Recorrência automática de PIX

---

## 🛠️ Stack

| Camada | Tecnologia |
|---|---|
| Mobile | Flutter · Dart |
| Estado | Riverpod |
| Backend | Supabase (Auth · PostgreSQL · RLS · Edge Functions) |
| Pagamentos | AbacatePay (PIX) |
| Notificações push | Firebase (Spark) |
| WhatsApp | Meta WhatsApp Business API |

---

## 🏗️ Arquitetura

Clean Architecture com separação por features:

```
lib/
├── core/
│   ├── theme/
│   ├── responsive/
│   └── di/
└── features/
    ├── auth/
    │   ├── data/
    │   ├── domain/
    │   └── presentation/
    ├── students/
    ├── dashboard/
    ├── payments/
    └── subscription/
```

Cada feature segue o padrão **Data → Domain → Presentation**, com repositórios, use cases e providers Riverpod desacoplados. Nenhum `fontSize` é hardcoded — tudo passa por `AppResponsive.fontSize(context, base)` para garantir responsividade real em qualquer tela.

---

## 🔒 Segurança e Regras de Negócio

- Row Level Security (RLS) ativa em todas as tabelas — cada usuário acessa apenas seus próprios dados
- Cada aluno pertence a um único usuário autenticado
- Status de pagamento calculado automaticamente via `pg_cron` no Supabase
- Plano Free limitado a 3 alunos; acesso Pro verificado via Edge Function a cada sessão
- Pagamentos Pro processados externamente via PIX, evitando a comissão de 30% da Apple

---

## 📸 Telas

| Splash | Onboarding | Login |
|:---:|:---:|:---:|
| ![Splash](./screenshots/splash.png) | ![Onboarding](./screenshots/onboarding.png) | ![Login](./screenshots/login.png) |

| Alunos | Novo Aluno | Perfil |
|:---:|:---:|:---:|
| ![Alunos](./screenshots/alunos.png) | ![Novo Aluno](./screenshots/novo_aluno.png) | ![Perfil](./screenshots/perfil.png) |

---

## 🚀 Como rodar localmente

### Pré-requisitos

- Flutter 3.x
- Dart 3.x
- Conta no Supabase
- Variáveis de ambiente configuradas

### Setup

```bash
# Clone o repositório
git clone https://github.com/hpzynha/mensalify.git
cd mensalify

# Instale as dependências
flutter pub get

# Configure as variáveis de ambiente
cp .env.example .env
# Preencha SUPABASE_URL e SUPABASE_ANON_KEY

# Rode o app
flutter run
```

---

## 🗺️ Roadmap

- [x] Cadastro de alunos com WhatsApp
- [x] Status de pagamento automático
- [x] Dashboard financeiro
- [x] Autenticação com Google
- [x] Plano Pro com pagamento PIX
- [x] Sistema de cupons
- [ ] Automação de cobranças via WhatsApp
- [ ] Relatórios com gráficos
- [ ] Exportação em PDF/CSV
- [ ] PIX recorrente automático

---

## 👩‍💻 Desenvolvido por

**Larissa Nogueira** — Software & Mobile Developer

Desenvolvido com 💜 para resolver uma dor real de quem trabalha por conta própria.

[![LinkedIn](https://img.shields.io/badge/LinkedIn-Larissa%20Nogueira-blue?logo=linkedin)](https://linkedin.com/in/larissanogueira)
[![Site](https://img.shields.io/badge/Site-mensalify.com.br-purple)](https://mensalify.com.br)
