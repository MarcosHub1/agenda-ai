# frozen_string_literal: true

module ApplicationHelper
  def format_cents(cents, currency = "BRL")
    return "Grátis" if cents.blank? || cents.zero?

    reais = cents.to_f / 100.0
    symbol = currency == "BRL" ? "R$" : "$"
    format("%s %.2f", symbol, reais).tr(".", ",")
  end

  def appointment_status_badge(status)
    classes = case status.to_s
    when "pending"
      "bg-amber-50 text-amber-700 border-amber-200"
    when "confirmed"
      "bg-emerald-50 text-emerald-700 border-emerald-200"
    when "completed"
      "bg-blue-50 text-blue-700 border-blue-200"
    when "cancelled"
      "bg-rose-50 text-rose-700 border-rose-200"
    when "no_show"
      "bg-slate-100 text-slate-700 border-slate-200"
    else
      "bg-gray-50 text-gray-700 border-gray-200"
    end

    labels = {
      "pending" => "Pendente",
      "confirmed" => "Confirmado",
      "completed" => "Concluído",
      "cancelled" => "Cancelado",
      "no_show" => "Não compareceu"
    }

    tag.span(labels[status.to_s] || status.to_s.humanize, class: "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium border #{classes}")
  end

  def day_name_pt(day)
    names = {
      "sunday" => "Domingo",
      "monday" => "Segunda-feira",
      "tuesday" => "Terça-feira",
      "wednesday" => "Quarta-feira",
      "thursday" => "Quinta-feira",
      "friday" => "Sexta-feira",
      "saturday" => "Sábado",
      0 => "Domingo",
      1 => "Segunda-feira",
      2 => "Terça-feira",
      3 => "Quarta-feira",
      4 => "Quinta-feira",
      5 => "Sexta-feira",
      6 => "Sábado"
    }
    names[day] || names[day.to_s] || day.to_s.humanize
  end
end
