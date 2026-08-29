# AgendaAI — Features & Requirements (JTBD)

> **Produto:** SaaS de agendamento genérico para qualquer tipo de negócio.
> **Modelo:** Assinatura mensal/anual (sem plano gratuito).
> **Stack:** Ruby on Rails 8+ (full-stack com Hotwire/Turbo).
> **Arquitetura:** Multi-tenant (cada empresa/negócio é um tenant isolado).

---

## 🎯 Visão do Produto

**Uma plataforma de agendamento online completa e genérica**, onde qualquer negócio — de salões de beleza a clínicas médicas, de personal trainers a consultores financeiros — possa criar sua agenda digital, receber agendamentos de clientes e gerenciar seus horários de forma simples e profissional.

---

## Personas

### Persona 1: Dono do Negócio / Administrador (Tenant Owner)
- **Quem:** Empreendedor ou gestor que precisa organizar a agenda de profissionais.
- **Dor:** Perde tempo com agendamento manual (WhatsApp, telefone, caderno). Sofre com faltas e não tem controle financeiro dos agendamentos.
- **Expectativa:** Um painel onde cadastra serviços, profissionais, horários e vê tudo funcionando automaticamente.

### Persona 2: Profissional / Prestador de Serviço
- **Quem:** Funcionário ou autônomo que executa o serviço agendado.
- **Dor:** Não tem visibilidade clara da própria agenda. Recebe avisos de última hora.
- **Expectativa:** Ver sua agenda do dia/semana de forma clara e receber lembretes.

### Persona 3: Cliente Final (Consumidor)
- **Quem:** Pessoa que quer agendar um serviço.
- **Dor:** Precisa ligar, mandar mensagem e esperar resposta para conseguir um horário.
- **Expectativa:** Agendar online em poucos cliques, a qualquer hora, sem precisar criar conta.

---

## Features do MVP

---

### F01 — Multi-Tenancy & Onboarding

**JTBD:** _"Quando eu quero oferecer agendamento online para meu negócio, eu preciso criar minha conta e configurar minha empresa, para que eu tenha um espaço exclusivo e personalizado."_

**Escopo:**
- Cadastro de conta do tenant (nome da empresa, segmento, slug para URL pública).
- Configuração inicial: nome, logo, horário de funcionamento, timezone, moeda.
- Cada tenant tem dados completamente isolados (clientes, profissionais, agendamentos).
- Subdomínio ou path único (ex: `app.agendaai.com/minha-barbearia`).

**Métricas de Sucesso:**
- Tempo de onboarding < 3 minutos.
- Taxa de conclusão do setup > 80%.

---

### F02 — Gestão de Profissionais e Serviços

**JTBD:** _"Quando eu preciso organizar meu negócio, eu quero cadastrar meus profissionais e os serviços que cada um oferece, para que os clientes possam escolher o que precisam."_

**Escopo:**
- CRUD de profissionais (nome, e-mail, avatar, especialidades).
- CRUD de serviços (nome, descrição, duração, preço).
- Associação profissional ↔ serviço (um profissional pode oferecer N serviços).
- Definição de horários de trabalho por profissional (dias da semana, horário de início/fim, intervalos).
- Configuração de exceções (férias, folgas, feriados).

**Métricas de Sucesso:**
- Cada tenant cadastra pelo menos 1 profissional e 1 serviço na primeira sessão.

---

### F03 — Motor de Disponibilidade e Agendamento

**JTBD:** _"Quando um cliente quer agendar comigo, eu preciso que o sistema mostre apenas os horários realmente disponíveis, para evitar conflitos e overbooking."_

**Escopo:**
- Motor de cálculo de slots disponíveis baseado em:
  - Horário de trabalho do profissional.
  - Duração do serviço.
  - Agendamentos já existentes (sem conflito).
  - Exceções e bloqueios.
- Regras de negócio configuráveis:
  - Antecedência mínima para agendar (ex: 2h antes).
  - Antecedência máxima (ex: agendar até 30 dias no futuro).
  - Buffer entre agendamentos (ex: 15min de intervalo).
- Status do agendamento: `pendente`, `confirmado`, `concluído`, `cancelado`, `no-show`.

**Métricas de Sucesso:**
- Zero conflitos de horário (overbooking = 0).
- Tempo de resposta do cálculo de disponibilidade < 200ms.

---

### F04 — Página Pública de Agendamento (Booking Page)

**JTBD:** _"Quando eu sou cliente e quero agendar um serviço, eu preciso de uma página simples e rápida para escolher serviço, profissional, data e horário, sem precisar criar uma conta."_

**Escopo:**
- Página pública acessível via URL única do tenant.
- Fluxo em etapas:
  1. Selecionar serviço.
  2. Selecionar profissional (ou "qualquer disponível").
  3. Selecionar data e horário.
  4. Informar dados de contato (nome, e-mail, telefone).
  5. Confirmar agendamento.
- Página responsiva (mobile-first).
- Personalização visual básica (logo, cores do tenant).
- Sem necessidade de login/cadastro para o cliente.

**Métricas de Sucesso:**
- Taxa de conversão (visitante → agendamento) > 40%.
- Tempo do fluxo completo < 60 segundos.

---

### F05 — Painel Administrativo (Dashboard)

**JTBD:** _"Quando eu abro meu painel, eu quero ver minha agenda de hoje e da semana num relance, para me organizar e não perder nenhum compromisso."_

**Escopo:**
- Dashboard com visão geral:
  - Agendamentos de hoje e da semana (calendário visual).
  - Próximos agendamentos (lista).
  - KPIs: total de agendamentos (dia/semana/mês), receita estimada, taxa de cancelamento.
- Visualização de calendário (dia, semana, mês) por profissional.
- Gestão de agendamentos: confirmar, cancelar, reagendar, marcar como no-show.
- Agendamento manual (admin cria agendamento para um cliente walk-in).
- Filtros por profissional, serviço, status, período.

**Métricas de Sucesso:**
- Admin acessa painel diariamente (DAU/MAU > 60%).
- Tempo para encontrar um agendamento específico < 10 segundos.

---

### F06 — Notificações por E-mail

**JTBD:** _"Quando um agendamento é criado, confirmado ou cancelado, eu (e meu cliente) precisamos ser notificados automaticamente, para que ninguém esqueça e para reduzir faltas."_

**Escopo:**
- E-mails transacionais automatizados:
  - **Para o cliente:** confirmação de agendamento, lembrete (24h e 2h antes), cancelamento.
  - **Para o profissional/admin:** novo agendamento, cancelamento pelo cliente.
- Templates de e-mail personalizáveis (nome da empresa, logo).
- Lembrete automático configurável (admin define antecedência).
- Background jobs para envio (ActiveJob + Sidekiq/Solid Queue).

**Métricas de Sucesso:**
- Taxa de entrega de e-mails > 98%.
- Redução de no-show em 30% após implementação de lembretes.

---

### F07 — Pagamento Online no Ato do Agendamento

**JTBD:** _"Quando um cliente agenda comigo, eu quero que ele possa pagar antecipadamente, para reduzir cancelamentos de última hora e garantir minha receita."_

**Escopo:**
- Integração com gateway de pagamento (Stripe como padrão).
- Configuração por tenant:
  - Pagamento obrigatório ou opcional no agendamento.
  - Pagamento total ou sinal/depósito (ex: 50% antecipado).
- Fluxo de checkout integrado à página de agendamento.
- Política de reembolso configurável (reembolso total, parcial ou sem reembolso por cancelamento).
- Dashboard financeiro básico: receita por período, pagamentos pendentes, reembolsos.
- Webhooks do Stripe para atualização automática de status.

**Métricas de Sucesso:**
- Redução de cancelamentos em 40% quando pagamento antecipado é ativo.
- Tempo de processamento do pagamento < 5 segundos.

---

### F08 — Integração com Google Calendar

**JTBD:** _"Quando um agendamento é confirmado, eu quero que ele apareça automaticamente no meu Google Calendar, para que eu tenha tudo centralizado no meu calendário pessoal."_

**Escopo:**
- OAuth2 com Google para conectar a conta do profissional.
- Sincronização bidirecional:
  - Novo agendamento no sistema → cria evento no Google Calendar.
  - Evento bloqueado no Google Calendar → bloqueia horário no sistema (evita conflito).
- Cancelamento sincronizado nos dois sentidos.
- Dados do evento: nome do cliente, serviço, horário, link para detalhes.

**Métricas de Sucesso:**
- 50%+ dos profissionais conectam Google Calendar no primeiro mês.
- Conflitos por agenda externa = 0 após integração.

---

### F09 — Autenticação e Autorização

**JTBD:** _"Quando eu acesso o sistema, eu preciso me autenticar de forma segura e ter acesso apenas ao que me compete (admin vê tudo, profissional vê sua agenda)."_

**Escopo:**
- Autenticação com Devise ou Rails 8 Authentication nativa.
- Roles: `owner` (dono do tenant), `admin`, `professional`.
- Permissões:
  - Owner/Admin: acesso total ao painel do tenant.
  - Professional: vê e gerencia apenas sua própria agenda.
- Convite de membros por e-mail.
- Login/registro para usuários do painel (não para clientes finais).

**Métricas de Sucesso:**
- Zero acessos não autorizados entre tenants.
- Tempo de login < 3 segundos.

---

### F10 — Planos e Billing (Assinatura)

**JTBD:** _"Quando eu quero usar a plataforma, eu preciso escolher um plano e pagar minha assinatura, para ter acesso contínuo ao sistema."_

**Escopo:**
- Planos com diferentes limites:
  - **Starter:** 1 profissional, 50 agendamentos/mês.
  - **Pro:** 5 profissionais, agendamentos ilimitados, pagamento online.
  - **Business:** profissionais ilimitados, Google Calendar, suporte prioritário.
- Integração com Stripe Billing para assinaturas recorrentes.
- Página de pricing pública.
- Gestão de assinatura (upgrade, downgrade, cancelamento).
- Período trial de 14 dias.
- Enforcement de limites (bloqueia funcionalidade se excede o plano).

**Métricas de Sucesso:**
- Conversão trial → pago > 10%.
- Churn mensal < 5%.

---

## Features Pós-MVP (Futuro)

| ID | Feature | Prioridade |
|----|---------|------------|
| F11 | Notificações por WhatsApp (API Business) | Alta |
| F12 | App Mobile (PWA ou nativo) | Alta |
| F13 | Relatórios avançados e analytics | Média |
| F14 | Avaliações e reviews de clientes | Média |
| F15 | Lista de espera automática | Média |
| F16 | Agendamento recorrente (ex: toda terça às 14h) | Média |
| F17 | Multi-idioma (i18n) | Baixa |
| F18 | Marketplace público de profissionais | Baixa |
| F19 | Integração com Outlook Calendar | Baixa |
| F20 | Customização avançada da booking page (CSS/temas) | Baixa |
