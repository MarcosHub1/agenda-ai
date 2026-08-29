# AgendaAI — Product Roadmap

> **Última atualização:** 2026-08-29
> **Responsável:** Product Manager
> **Status:** Em planejamento

---

## 📌 Princípios do Roadmap

1. **Valor antes de escala** — Entregar um MVP funcional e completo antes de otimizar.
2. **Revenue first** — Modelo de assinatura desde o dia 1 (sem freemium).
3. **Genérico por design** — Nenhuma decisão deve limitar a um nicho específico.

---

## Priorização (WSJF)

> **WSJF = (Business Value + Time Criticality + Opportunity) / Job Size**

| Feature | BV | TC | Opp | Size | WSJF | Fase |
|---------|----|----|-----|------|------|------|
| F09 — Autenticação & Multi-tenant | 10 | 10 | 8 | 5 | **5.6** | 🟢 Now |
| F01 — Onboarding do Tenant | 9 | 10 | 9 | 5 | **5.6** | 🟢 Now |
| F02 — Profissionais & Serviços | 10 | 10 | 9 | 5 | **5.8** | 🟢 Now |
| F03 — Motor de Disponibilidade | 10 | 10 | 10 | 8 | **3.75** | 🟢 Now |
| F04 — Booking Page Pública | 10 | 9 | 10 | 5 | **5.8** | 🟢 Now |
| F05 — Painel Administrativo | 9 | 9 | 8 | 8 | **3.25** | 🟢 Now |
| F06 — Notificações E-mail | 8 | 8 | 7 | 3 | **7.67** | 🟢 Now |
| F10 — Planos & Billing | 10 | 7 | 8 | 8 | **3.13** | 🟡 Next |
| F07 — Pagamento Online | 8 | 6 | 8 | 8 | **2.75** | 🟡 Next |
| F08 — Google Calendar | 6 | 4 | 7 | 5 | **3.4** | 🟡 Next |
| F11 — WhatsApp Notifications | 7 | 5 | 8 | 5 | **4.0** | 🔵 Later |
| F12 — App Mobile (PWA) | 6 | 3 | 7 | 8 | **2.0** | 🔵 Later |

---

## 🟢 Now — MVP (Sprints 1-6 · ~12 semanas)

> **Objetivo:** Lançar um produto funcional que um negócio possa usar para receber agendamentos online, gerenciar sua agenda e ser notificado.

### Sprint 1-2: Fundação (Semanas 1-4)
- [x] Setup do projeto Rails 8 com Hotwire/Turbo
- [x] **F09** — Autenticação (Rails 8 Auth), roles (owner/admin/professional)
- [x] **F01** — Multi-tenancy (ActsAsTenant), onboarding foundation
- [x] Modelagem do banco de dados core com UUIDs

### Sprint 3-4: Core do Agendamento (Semanas 5-8)
- [x] **F02** — CRUD de profissionais e serviços, horários de trabalho
- [x] **F03** — Motor de disponibilidade (cálculo de slots, regras de negócio)
- [x] **F04** — Booking page pública (fluxo de agendamento em etapas)

### Sprint 5-6: Gestão & Comunicação (Semanas 9-12)
- [ ] **F05** — Dashboard administrativo (calendário, KPIs, gestão de agendamentos)
- [ ] **F06** — Notificações por e-mail (confirmação, lembrete, cancelamento)
- [ ] Testes end-to-end, correção de bugs, polish de UX

### 🚀 Marco: **MVP Launch** (Semana 12)
> Critérios de lançamento:
> - Um tenant consegue se cadastrar, configurar profissionais/serviços e receber agendamentos.
> - Clientes agendam pela página pública sem criar conta.
> - Notificações automáticas funcionam.
> - Zero conflitos de overbooking.

---

## 🟡 Next — Monetização & Integrações (Sprints 7-10 · ~8 semanas)

> **Objetivo:** Ativar a receita com planos de assinatura e pagamento online, e integrar com calendários externos.

### Sprint 7-8: Revenue
- [ ] **F10** — Planos de assinatura (Starter, Pro, Business) com Stripe Billing
- [ ] **F07** — Pagamento online no agendamento (Stripe Checkout)
- [ ] Pricing page pública
- [ ] Enforcement de limites por plano

### Sprint 9-10: Integração & Expansão
- [ ] **F08** — Google Calendar (OAuth2, sync bidirecional)
- [ ] Melhorias de UX baseadas em feedback dos primeiros usuários
- [ ] Otimização de performance

### 🚀 Marco: **Revenue Ready** (Semana 20)
> Critérios:
> - Tenants pagam assinatura recorrente.
> - Pagamento online funcional no agendamento.
> - Google Calendar sincronizado.

---

## 🔵 Later — Crescimento (Sprints 11+)

> **Objetivo:** Escalar funcionalidades para aumentar retenção e atrair mais segmentos.

- [ ] **F11** — Notificações via WhatsApp Business API
- [ ] **F12** — PWA / App Mobile
- [ ] **F13** — Relatórios avançados e analytics
- [ ] **F14** — Avaliações de clientes
- [ ] **F15** — Lista de espera automática
- [ ] **F16** — Agendamento recorrente
- [ ] **F17** — Multi-idioma (i18n)
- [ ] **F18** — Marketplace público
- [ ] **F19** — Integração Outlook Calendar
- [ ] **F20** — Customização avançada da booking page

---

## 📊 KPIs de Produto (Acompanhamento Mensal)

| Métrica | Meta MVP | Meta 6 meses |
|---------|----------|--------------|
| Tenants ativos | 10 | 100 |
| Agendamentos/mês (total plataforma) | 500 | 10.000 |
| Taxa de conversão booking page | > 40% | > 50% |
| No-show rate | < 20% | < 10% |
| Churn mensal | — | < 5% |
| MRR (Monthly Recurring Revenue) | R$ 0 | R$ 5.000+ |
| NPS | — | > 50 |

---

## Decisões em Aberto

> ⚠️ As seguintes decisões precisam ser tomadas antes de iniciar o desenvolvimento:

1. **Nome do produto** — "AgendaAI" é o nome definitivo ou é placeholder?
2. **Domínio e hospedagem** — Já possui domínio? Onde será hospedado (Render, Fly.io, VPS)?
3. **Gateway de pagamento** — Stripe é viável no Brasil? Considerar Mercado Pago como alternativa?
4. **E-mail transacional** — Qual provedor? (Resend, SendGrid, Mailgun, Amazon SES)
5. **Multi-tenancy approach** — Schema-based (Apartment) ou Row-based (ActsAsTenant)?
