puts "Cleaning up existing data..."
Appointment.destroy_all
ScheduleException.destroy_all
WorkSchedule.destroy_all
ProfessionalService.destroy_all
Service.destroy_all
Professional.destroy_all
Client.destroy_all
User.destroy_all
Account.destroy_all

puts "Creating Tenant 1: Barbearia Navalha de Ouro..."
account1 = Account.create!(
  name: "Barbearia Navalha de Ouro",
  slug: "navalha-ouro",
  logo_url: "https://images.unsplash.com/photo-1503951914875-452162b0f3f1",
  timezone: "America/Sao_Paulo",
  currency: "BRL",
  status: :active,
  settings: {
    min_advance_hours: 2,
    max_advance_days: 30,
    slot_buffer_minutes: 10
  }
)

ActsAsTenant.with_tenant(account1) do
  owner1 = User.create!(
    account: account1,
    name: "Carlos Navalha",
    email_address: "carlos@navalha.com",
    password: "password123",
    role: :owner
  )

  pro1 = Professional.create!(
    account: account1,
    user: owner1,
    name: "Carlos Navalha",
    email: "carlos@navalha.com",
    avatar_url: "https://images.unsplash.com/photo-1534528741775-53994a69daeb",
    active: true
  )

  pro2 = Professional.create!(
    account: account1,
    name: "Lucas Tesoura",
    email: "lucas@navalha.com",
    avatar_url: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d",
    active: true
  )

  # Services
  srv_corte = Service.create!(
    account: account1,
    name: "Corte Tradicional",
    description: "Corte de cabelo masculino com tesoura e máquina, finalizado com lavagem.",
    duration_minutes: 40,
    price_cents: 5000,
    currency: "BRL",
    active: true,
    sort_order: 1
  )

  srv_barba = Service.create!(
    account: account1,
    name: "Barba Terapia",
    description: "Modelagem de barba com toalha quente, navalhete e óleos essenciais.",
    duration_minutes: 30,
    price_cents: 4000,
    currency: "BRL",
    active: true,
    sort_order: 2
  )

  srv_combo = Service.create!(
    account: account1,
    name: "Combo Cabelo + Barba",
    description: "Experiência completa de corte e barba com desconto.",
    duration_minutes: 60,
    price_cents: 8000,
    currency: "BRL",
    active: true,
    sort_order: 3
  )

  # Professional Services
  ProfessionalService.create!(professional: pro1, service: srv_corte)
  ProfessionalService.create!(professional: pro1, service: srv_barba)
  ProfessionalService.create!(professional: pro1, service: srv_combo)
  ProfessionalService.create!(professional: pro2, service: srv_corte)

  # Work Schedules (Monday to Friday, 9am to 6pm)
  [ pro1, pro2 ].each do |pro|
    (1..5).each do |day|
      WorkSchedule.create!(
        professional: pro,
        day_of_week: day,
        start_time: "09:00",
        end_time: "18:00",
        break_start: "12:00",
        break_end: "13:00",
        enabled: true
      )
    end
  end

  # Clients
  client1 = Client.create!(
    account: account1,
    name: "João Silva",
    email: "joao.silva@example.com",
    phone: "(11) 98765-4321",
    notes: "Prefere máquina 2 nas laterais."
  )

  client2 = Client.create!(
    account: account1,
    name: "Pedro Alves",
    email: "pedro.alves@example.com",
    phone: "(11) 99887-7665"
  )

  # Appointments
  tomorrow = Date.tomorrow
  Appointment.create!(
    account: account1,
    professional: pro1,
    service: srv_corte,
    client: client1,
    starts_at: tomorrow.in_time_zone("America/Sao_Paulo").change(hour: 10, min: 0),
    ends_at: tomorrow.in_time_zone("America/Sao_Paulo").change(hour: 10, min: 40),
    status: :confirmed,
    price_cents: 5000
  )

  Appointment.create!(
    account: account1,
    professional: pro1,
    service: srv_barba,
    client: client2,
    starts_at: tomorrow.in_time_zone("America/Sao_Paulo").change(hour: 14, min: 0),
    ends_at: tomorrow.in_time_zone("America/Sao_Paulo").change(hour: 14, min: 30),
    status: :pending,
    price_cents: 4000
  )
end

puts "Creating Tenant 2: Clínica Bem Estar..."
account2 = Account.create!(
  name: "Clínica Bem Estar",
  slug: "bem-estar",
  logo_url: "https://images.unsplash.com/photo-1519494026892-80bbd2d6fd0d",
  timezone: "America/Sao_Paulo",
  currency: "BRL",
  status: :active,
  settings: {
    min_advance_hours: 24,
    max_advance_days: 60
  }
)

ActsAsTenant.with_tenant(account2) do
  owner2 = User.create!(
    account: account2,
    name: "Dra. Renata Lima",
    email_address: "renata@bemestar.com",
    password: "password123",
    role: :owner
  )

  pro_dr = Professional.create!(
    account: account2,
    user: owner2,
    name: "Dra. Renata Lima",
    email: "renata@bemestar.com",
    avatar_url: "https://images.unsplash.com/photo-1559839734-2b71ea197ec2",
    active: true
  )

  srv_consulta = Service.create!(
    account: account2,
    name: "Consulta Dermatológica",
    description: "Avaliação clínica completa da pele, cabelos e unhas.",
    duration_minutes: 50,
    price_cents: 25000,
    currency: "BRL",
    active: true,
    sort_order: 1
  )

  ProfessionalService.create!(professional: pro_dr, service: srv_consulta)

  (1..4).each do |day|
    WorkSchedule.create!(
      professional: pro_dr,
      day_of_week: day,
      start_time: "10:00",
      end_time: "17:00",
      break_start: "13:00",
      break_end: "14:00",
      enabled: true
    )
  end

  client_dr = Client.create!(
    account: account2,
    name: "Mariana Souza",
    email: "mariana.souza@example.com",
    phone: "(11) 91234-5678"
  )

  Appointment.create!(
    account: account2,
    professional: pro_dr,
    service: srv_consulta,
    client: client_dr,
    starts_at: 2.days.from_now.in_time_zone("America/Sao_Paulo").change(hour: 11, min: 0),
    ends_at: 2.days.from_now.in_time_zone("America/Sao_Paulo").change(hour: 11, min: 50),
    status: :confirmed,
    price_cents: 25000
  )
end

puts "Creating Tenant 3 (Sem Assinatura): Espaço Glow Estética..."
account3 = Account.create!(
  name: "Espaço Glow Estética",
  slug: "espaco-glow",
  logo_url: "https://images.unsplash.com/photo-1560066984-138dadb4c035",
  timezone: "America/Sao_Paulo",
  currency: "BRL",
  status: :active,
  settings: {
    min_advance_hours: 2,
    max_advance_days: 30,
    slot_buffer_minutes: 15
  }
)

ActsAsTenant.with_tenant(account3) do
  owner3 = User.create!(
    account: account3,
    name: "Camila Rocha",
    email_address: "camila@glowestetica.com",
    password: "password123",
    role: :owner
  )

  Professional.create!(
    account: account3,
    user: owner3,
    name: "Camila Rocha",
    email: "camila@glowestetica.com",
    avatar_url: "https://images.unsplash.com/photo-1573496359142-b8d87734a5a2",
    active: true
  )
  # Sem assinatura ativa
end

puts "Creating Tenant 4 (Sem Assinatura): Studio Pilates Vida..."
account4 = Account.create!(
  name: "Studio Pilates Vida",
  slug: "pilates-vida",
  logo_url: "https://images.unsplash.com/photo-1518611012118-696072aa579a",
  timezone: "America/Sao_Paulo",
  currency: "BRL",
  status: :active,
  settings: {
    min_advance_hours: 1,
    max_advance_days: 15,
    slot_buffer_minutes: 0
  }
)

ActsAsTenant.with_tenant(account4) do
  owner4 = User.create!(
    account: account4,
    name: "Marcos Souza",
    email_address: "marcos@pilatesvida.com",
    password: "password123",
    role: :owner
  )

  Professional.create!(
    account: account4,
    user: owner4,
    name: "Marcos Souza",
    email: "marcos@pilatesvida.com",
    avatar_url: "https://images.unsplash.com/photo-1500648767791-00dcc994a43e",
    active: true
  )
  # Sem assinatura ativa
end

puts "Seeds created successfully! (4 tenants: 2 com assinatura ativa e 2 sem assinatura)"
