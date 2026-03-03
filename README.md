# 📲 Venzza — Gestão Inteligente de Cobranças

Venzza é um aplicativo mobile desenvolvido para simplificar a gestão de cobranças recorrentes, controle de inadimplência e organização financeira de pequenos negócios.

O objetivo é resolver uma dor real: acompanhar pagamentos de forma simples, visual e eficiente.

---

## 🚀 Sobre o Projeto

Venzza foi construído com foco em:

* Simplicidade
* Performance
* Arquitetura escalável
* Boa experiência do usuário (UX)

O app permite cadastrar alunos/clientes, acompanhar status de pagamento e visualizar indicadores de forma clara.

---

## 🛠️ Stack Tecnológica

### 📱 Mobile

* Flutter
* Dart

### 🔐 Backend

* Supabase

  * Authentication
  * PostgreSQL
  * Row Level Security (RLS)

### 🧪 Qualidade

* Testes unitários
* Testes de widget
* Estrutura modular organizada por features

---

## 🧱 Arquitetura

O projeto segue princípios de arquitetura limpa e organização por feature:

```
lib/
 ├── core/
 ├── features/
 │    ├── auth/
 │    ├── students/
 │    ├── dashboard/
 │    └── payments/
```

Separação clara entre:

* Presentation
* Domain
* Data

Isso facilita manutenção e escalabilidade futura.

---

## ✨ Funcionalidades Atuais

* Cadastro de alunos
* Campo de WhatsApp com código internacional
* Controle de status:

  * Pago
  * Vence hoje
  * Atrasado
* Dashboard com indicadores
* Autenticação por email
* Verificação de email no cadastro
* Responsividade para diferentes tamanhos de tela

---

## 🔒 Regras de Negócio

* Um aluno pertence a um usuário autenticado
* Cada cobrança possui status calculado automaticamente com base na data
* Apenas o usuário dono pode visualizar e editar seus registros (RLS ativa)

---

## 📈 Roadmap

* [ ] Notificações automáticas
* [ ] Integração com WhatsApp
* [ ] Relatórios financeiros
* [ ] Exportação de dados
* [ ] Dashboard avançado com métricas

---

## 🎯 Objetivo do Produto

Venzza não é apenas um app de cobrança.
É uma ferramenta para organização financeira de pequenos negócios que precisam de controle simples e eficiente.

---

## 👩‍💻 Desenvolvido por

Larissa Nogueira
Software & Mobile Developer

Desenvolvido com 💜 e foco em resolver problemas reais.
