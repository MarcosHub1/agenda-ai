# AgendaAI — Plano de Arquitetura Técnica

> **Baseado em:** [FEATURES.md](../product/FEATURES.md) e [ROADMAP.md](../product/ROADMAP.md)
> **Arquiteto:** Rails Architect Agent
> **Data:** 2026-08-29

---

## 1. Resumo Executivo

**AgendaAI** é um SaaS de agendamento online multi-tenant genérico. Qualquer negócio (salão, clínica, consultoria) cria um tenant isolado, cadastra profissionais e serviços, e recebe agendamentos de clientes via página pública — sem que o cliente precise criar conta.

O MVP contempla **7 features core** (F01–F06, F09), seguidas por monetização (F07, F10) e integrações (F08).

---

## 2. Stack Recomendada

| Camada | Tecnologia | Versão | Justificativa |
|--------|-----------|--------|---------------|
| **Linguagem** | Ruby | 3.3+ | Última estável |
| **Framework** | Rails | 8.0+ | Definido no FEATURES.md; inclui Auth nativo |
| **Frontend** | Hotwire (Turbo + Stimulus) | Bundled com Rails 8 | Definido no FEATURES.md; ideal para SaaS server-rendered |
| **CSS** | Tailwind CSS | 4.x | Padrão moderno para Rails; produtividade alta |
| **Database** | PostgreSQL | 17+ | Suporte a JSONB, UUID, excelente para multi-tenant |
| **Cache/Queue** | Solid Queue + Solid Cache | Rails 8 native | Elimina Redis como dependência; simplifica deploy |
| **Background Jobs** | ActiveJob + Solid Queue | Rails 8 native | Emails, lembretes, webhooks |
| **Email** | Action Mailer + provedor externo | — | Resend ou SendGrid (decisão pendente) |
| **Pagamento** | Stripe (Checkout + Billing) | API latest | Definido no FEATURES.md |
| **Testes** | RSpec + FactoryBot + Capybara | Latest | Stack padrão de produção para Rails |
| **Linter** | RuboCop + ERB Lint | Latest | Qualidade de código |
| **Deploy** | Kamal 2 | Latest | Deploy nativo Rails 8, Docker-based |

---

## 3. Arquitetura Multi-Tenant

### Recomendação: **Row-based com `acts_as_tenant`**

| Critério | Schema-based (Apartment) | Row-based (ActsAsTenant) |
|----------|--------------------------|--------------------------|
| Isolamento | Total (schemas separados) | Lógico (tenant_id em cada tabela) |
| Performance de migrations | Lenta (N schemas) | Rápida (1 schema) |
| Escalabilidade para 100+ tenants | Problemática | Excelente |
| Complexidade de deploy | Alta | Baixa |
| Maturidade com Rails 8 | Baixa (Apartment pouco mantido) | Alta |
| Custo de infra | Maior | Menor |

**Decisão:** `acts_as_tenant` com scoping automático em todos os models tenant-scoped. O `current_tenant` é setado via middleware baseado no subdomain/path.

```ruby
# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  set_current_tenant_through_filter
  before_action :set_tenant

  private

  def set_tenant
    set_current_tenant(Account.find_by!(slug: request.subdomain))
  end
end
```

---

## 4. Schema do Banco de Dados

### 4.1 Diagrama ER (Core)

```mermaid
erDiagram
    Account ||--o{ User : "has many"
    Account ||--o{ Professional : "has many"
    Account ||--o{ Service : "has many"
    Account ||--o{ Client : "has many"
    Account ||--o{ Appointment : "has many"
    Account ||--o{ Subscription : "has one"

    Professional ||--o{ ProfessionalService : "has many"
    Service ||--o{ ProfessionalService : "has many"
    Professional ||--o{ WorkSchedule : "has many"
    Professional ||--o{ ScheduleException : "has many"
    Professional ||--o{ Appointment : "has many"

    Service ||--o{ Appointment : "has many"
    Client ||--o{ Appointment : "has many"

    Account {
        uuid id PK
        string name
        string slug UK
        string logo_url
        string timezone
        string currency
        jsonb settings
        integer status
        timestamps
    }

    User {
        uuid id PK
        uuid account_id FK
        string email UK
        string name
        integer role
        string password_digest
        timestamps
    }

    Professional {
        uuid id PK
        uuid account_id FK
        uuid user_id FK "nullable - se tiver login"
        string name
        string email
        string avatar_url
        boolean active
        timestamps
    }

    Service {
        uuid id PK
        uuid account_id FK
        string name
        text description
        integer duration_minutes
        integer price_cents
        string currency
        boolean active
        integer sort_order
        timestamps
    }

    ProfessionalService {
        uuid id PK
        uuid professional_id FK
        uuid service_id FK
        timestamps
    }

    WorkSchedule {
        uuid id PK
        uuid professional_id FK
        integer day_of_week "0=domingo...6=sábado"
        time start_time
        time end_time
        time break_start "nullable"
        time break_end "nullable"
        boolean enabled
        timestamps
    }

    ScheduleException {
        uuid id PK
        uuid professional_id FK
        date exception_date
        boolean is_blocked "true=folga, false=horário especial"
        time start_time "nullable - se horário especial"
        time end_time "nullable"
        string reason
        timestamps
    }

    Client {
        uuid id PK
        uuid account_id FK
        string name
        string email
        string phone
        text notes
        timestamps
    }

    Appointment {
        uuid id PK
        uuid account_id FK
        uuid professional_id FK
        uuid service_id FK
        uuid client_id FK
        datetime starts_at
        datetime ends_at
        integer status "enum: pending confirmed completed cancelled no_show"
        integer price_cents
        string cancellation_reason
        text notes
        jsonb metadata
        timestamps
    }

    Subscription {
        uuid id PK
        uuid account_id FK
        string plan "enum: starter pro business"
        string stripe_subscription_id
        string stripe_customer_id
        integer status "enum: trialing active past_due cancelled"
        datetime trial_ends_at
        datetime current_period_end
        timestamps
    }
```

### 4.2 Convenções do Schema

- **PKs:** `UUID` em todas as tabelas (escalabilidade, segurança)
- **FKs:** Sempre com `foreign_key: true` e `null: false`
- **Indexes:** Compostos para queries frequentes (`[account_id, professional_id, starts_at]`)
- **Enums:** Rails enums para `status`, `role`, `day_of_week`
- **Money:** Armazenado em centavos (`integer price_cents`) — evita floating point
- **Timestamps:** `null: false` em todas as tabelas
- **Soft delete:** Não usar no MVP; usar `status` enum + `active` boolean

---

## 5. Componentes da Aplicação

### 5.1 Models

| Model | Responsabilidade | Validações Chave |
|-------|-----------------|------------------|
| `Account` | Tenant root | `slug` unique, format `/[a-z0-9-]+/` |
| `User` | Auth + role no tenant | `email` unique scoped to account, `role` enum |
| `Professional` | Prestador de serviço | `email` unique scoped to account |
| `Service` | Serviço oferecido | `duration_minutes > 0`, `price_cents >= 0` |
| `ProfessionalService` | Join table N:N | Unique `[professional_id, service_id]` |
| `WorkSchedule` | Horário semanal | `start_time < end_time`, unique `[professional_id, day_of_week]` |
| `ScheduleException` | Folga/feriado | `exception_date` unique per professional |
| `Client` | Cliente do tenant | `email` or `phone` required |
| `Appointment` | Agendamento core | Custom validation: no overlap |

### 5.2 Service Objects (POROs)

| Service | Responsabilidade |
|---------|-----------------|
| `Availability::SlotCalculator` | Calcula slots disponíveis para um profissional+serviço+data |
| `Availability::ConflictChecker` | Verifica overlaps antes de criar appointment |
| `Appointments::Creator` | Cria appointment com validações de negócio |
| `Appointments::Canceller` | Cancela com lógica de reembolso (futuro) |
| `Appointments::Rescheduler` | Reagenda com revalidação de disponibilidade |
| `Onboarding::AccountSetup` | Cria account + user owner + defaults |
| `Notifications::AppointmentNotifier` | Orquestra envio de emails por evento |

### 5.3 Controllers

| Controller | Namespace | Responsabilidade |
|-----------|-----------|-----------------|
| `RegistrationsController` | — | Signup de novo tenant |
| `SessionsController` | — | Login/logout |
| `Dashboard::HomeController` | `dashboard` | Dashboard principal |
| `Dashboard::AppointmentsController` | `dashboard` | CRUD de agendamentos (admin) |
| `Dashboard::ProfessionalsController` | `dashboard` | CRUD de profissionais |
| `Dashboard::ServicesController` | `dashboard` | CRUD de serviços |
| `Dashboard::SettingsController` | `dashboard` | Config do tenant |
| `Booking::ServicesController` | `booking` | Página pública - lista serviços |
| `Booking::SlotsController` | `booking` | Página pública - mostra slots |
| `Booking::AppointmentsController` | `booking` | Página pública - cria agendamento |

### 5.4 Jobs (Background)

| Job | Trigger | Ação |
|-----|---------|------|
| `SendAppointmentConfirmationJob` | Appointment criado | Envia e-mail ao cliente + profissional |
| `SendAppointmentReminderJob` | Cron (24h e 2h antes) | Envia lembrete ao cliente |
| `SendCancellationNotificationJob` | Appointment cancelado | Notifica as partes |
| `ProcessAppointmentNoShowJob` | Cron (após horário) | Marca como no-show automaticamente |

---

## 6. Rotas Principais

```ruby
# config/routes.rb
Rails.application.routes.draw do
  # === Auth ===
  resource :session, only: [:new, :create, :destroy]
  resource :registration, only: [:new, :create]

  # === Dashboard (autenticado, tenant-scoped) ===
  namespace :dashboard do
    root to: "home#index"
    resources :appointments do
      member do
        patch :confirm
        patch :cancel
        patch :complete
        patch :no_show
      end
    end
    resources :professionals do
      resources :work_schedules, only: [:index, :update]
      resources :schedule_exceptions, only: [:index, :create, :destroy]
    end
    resources :services
    resources :clients, only: [:index, :show]
    resource :settings, only: [:show, :update]
  end

  # === Booking Page (pública, tenant via slug) ===
  scope "/:tenant_slug", as: :booking do
    get "/", to: "booking/services#index"
    get "/professionals", to: "booking/professionals#index"
    get "/slots", to: "booking/slots#index"
    resources :appointments, only: [:new, :create, :show],
              controller: "booking/appointments",
              as: :booking_appointments
  end
end
```

---

## 7. Motor de Disponibilidade (F03 — Detalhe Técnico)

> **⚠️ IMPORTANTE:** Este é o componente mais crítico e complexo do sistema. Performance alvo: **< 200ms** por consulta.

### Algoritmo `Availability::SlotCalculator`

```
Input: professional_id, service_id, date
Output: Array de TimeSlot { starts_at, ends_at, available: bool }

1. Carregar WorkSchedule do profissional para o day_of_week da date
2. Se dia desabilitado ou ScheduleException(is_blocked: true) → retorna []
3. Se ScheduleException com horário especial → usar horário da exceção
4. Gerar todos os slots possíveis:
   - De start_time até end_time, incrementando por duração do serviço
   - Remover slots que caem no intervalo (break_start..break_end)
   - Adicionar buffer entre slots (configurável por tenant)
5. Carregar appointments existentes do profissional na date
6. Remover slots que conflitam com appointments existentes
7. Aplicar regras de negócio:
   - Remover slots com antecedência < mínima configurada
   - Remover slots com data > máxima configurada
8. Retornar slots com flag de disponibilidade
```

### Otimizações

- **Index composto:** `appointments(professional_id, starts_at, ends_at)` para query rápida
- **Cache:** Cache de WorkSchedule por profissional (invalidado no update)
- **Eager loading:** Carregar exceptions + appointments em uma única query por data range

---

## 8. Segurança

| Aspecto | Implementação |
|---------|--------------|
| **Autenticação** | Rails 8 `has_secure_password` + session-based |
| **Autorização** | Pundit policies por role (owner/admin/professional) |
| **Tenant isolation** | `acts_as_tenant` com scoping automático; `default_scope` em todos os models |
| **CSRF** | Rails default (token por session) |
| **SQL Injection** | ActiveRecord parameterized queries (default) |
| **Rate limiting** | `Rack::Attack` na booking page e login |
| **Input sanitization** | Strong Parameters em todos os controllers |
| **Sensitive data** | `filter_parameters` para emails, phones em logs |
| **Session cookies** | HttpOnly, Secure, SameSite=Lax |
| **CSP** | Content-Security-Policy header restritivo |
| **Clickjacking** | X-Frame-Options: SAMEORIGIN |
| **Password** | bcrypt via `has_secure_password` (mínimo 8 caracteres) |

### TODO(security)
- [ ] Implementar OAuth providers (Google) para login alternativo
- [ ] Implementar MFA para contas admin
- [ ] Considerar leaked password detection (HaveIBeenPwned API)
- [ ] Malware scan em uploads de logo/avatar

---

## 9. Estrutura de Diretórios

```
app/
├── controllers/
│   ├── application_controller.rb
│   ├── registrations_controller.rb
│   ├── sessions_controller.rb
│   ├── dashboard/
│   │   ├── home_controller.rb
│   │   ├── appointments_controller.rb
│   │   ├── professionals_controller.rb
│   │   ├── services_controller.rb
│   │   ├── clients_controller.rb
│   │   └── settings_controller.rb
│   └── booking/
│       ├── services_controller.rb
│       ├── professionals_controller.rb
│       ├── slots_controller.rb
│       └── appointments_controller.rb
├── models/
│   ├── account.rb
│   ├── user.rb
│   ├── professional.rb
│   ├── service.rb
│   ├── professional_service.rb
│   ├── work_schedule.rb
│   ├── schedule_exception.rb
│   ├── client.rb
│   └── appointment.rb
├── services/
│   ├── availability/
│   │   ├── slot_calculator.rb
│   │   └── conflict_checker.rb
│   ├── appointments/
│   │   ├── creator.rb
│   │   ├── canceller.rb
│   │   └── rescheduler.rb
│   ├── onboarding/
│   │   └── account_setup.rb
│   └── notifications/
│       └── appointment_notifier.rb
├── jobs/
│   ├── send_appointment_confirmation_job.rb
│   ├── send_appointment_reminder_job.rb
│   ├── send_cancellation_notification_job.rb
│   └── process_appointment_no_show_job.rb
├── mailers/
│   ├── appointment_mailer.rb
│   └── account_mailer.rb
├── views/
│   ├── layouts/
│   │   ├── application.html.erb    # Layout do dashboard
│   │   └── booking.html.erb        # Layout da página pública
│   ├── dashboard/
│   └── booking/
├── policies/         # Pundit
│   ├── application_policy.rb
│   ├── appointment_policy.rb
│   └── professional_policy.rb
└── components/       # ViewComponent (opcional)
```

---

## 10. Decisões Técnicas Aprovadas

| # | Decisão | Escolha | Justificativa |
|---|---------|---------|---------------|
| 1 | Multi-Tenancy | `acts_as_tenant` (row-based) | Escalável, simples, mantido ativamente |
| 2 | Autenticação | Rails 8 Authentication nativa | Leve, sem dependência, suficiente para MVP |
| 3 | Autorização | Pundit | PORO-based, testável, simples |
| 4 | CSS | Tailwind CSS 4 | Produtividade alta com Hotwire |
| 5 | Testes | RSpec + FactoryBot + Capybara | Stack padrão de produção |
| 6 | Tenant routing | Path-based (MVP) | Simples; migrar para subdomain depois |

---

## 11. Decisões em Aberto

> **⚠️ As seguintes decisões precisam ser tomadas antes/durante o desenvolvimento:**

1. **Domínio e hospedagem** — Onde será hospedado? Impacta config de Kamal e multi-tenancy.
2. **Gateway de pagamento** — Stripe vs Mercado Pago para BRL nativo.
3. **Provedor de e-mail** — Resend vs SendGrid vs Amazon SES.
4. **Nome do produto** — "AgendaAI" é definitivo ou placeholder?

---

## 12. Plano de Implementação por Fase

### Fase 1: Fundação (Sprint 1-2 · Semanas 1-4)
1. Setup projeto Rails 8 com PostgreSQL + Tailwind
2. Configurar UUIDs como PK padrão
3. `acts_as_tenant` + migration `accounts`
4. `rails generate authentication` + roles + Pundit
5. Migrations + models core (todas as tabelas)
6. Seeds de desenvolvimento

### Fase 2: Core do Agendamento (Sprint 3-4 · Semanas 5-8)
1. CRUD de profissionais e serviços (Dashboard)
2. Motor de disponibilidade (`SlotCalculator`, `ConflictChecker`)
3. Booking page pública (fluxo em steps)

### Fase 3: Gestão & Comunicação (Sprint 5-6 · Semanas 9-12)
1. Dashboard administrativo (KPIs, calendário, gestão)
2. Notificações por e-mail (mailers + background jobs)
3. Testes E2E, polish de UX

---

## 13. Plano de Verificação

### Testes Automatizados
```bash
# Unit tests dos models e services
bundle exec rspec spec/models/
bundle exec rspec spec/services/

# Integration tests dos controllers
bundle exec rspec spec/requests/

# System tests (E2E)
bundle exec rspec spec/system/

# Lint
bundle exec rubocop
```

### Verificação Manual
- **Tenant isolation:** Criar 2 tenants e verificar que dados não vazam entre eles
- **Booking flow:** Testar fluxo completo de agendamento como cliente (sem login)
- **Overbooking:** Tentar agendar dois clientes no mesmo slot e verificar que é bloqueado
- **Responsividade:** Testar booking page em mobile (Chrome DevTools)
- **Emails:** Verificar envio via letter_opener em dev, Mailtrap em staging

### Verificação de Segurança
- **CSRF:** Verificar token em todos os forms (Rails default)
- **Session cookies:** Confirmar flags HttpOnly, Secure, SameSite
- **Tenant isolation:** Tentar acessar dados de outro tenant via URL manipulation
- **SQL Injection:** Confirmar uso de parameterized queries em todos os controllers
- **Rate limiting:** Testar Rack::Attack em login e booking page
- **Input validation:** Testar inputs maliciosos em todos os formulários
- **CSP headers:** Verificar Content-Security-Policy no response
