# frozen_string_literal: true

require 'shortuuid'
require 'contentful'
require 'multi_json'
require 'pry'
require 'dotenv'

Dotenv.load('.env')

FILE_NAME = '../data/ev-data.json'
PAGE_SIZE = 100

def load_from_contentful
  entries = fetch_entries
  brands = entries.map do |v|
    { id: ShortUUID.expand(v.model.brand.id), name: v.model.brand.name }
  end.uniq.sort_by { |c| c[:name] }
  vehicles = entries.map { |entry| to_model(entry) }.sort_by { |b| b[:brand] }

  hash = {
    data: vehicles,
    brands: brands,
    meta: {
      updated_at: Time.now.utc.iso8601,
      overall_count: vehicles.size
    }
  }

  File.write(FILE_NAME, MultiJson.dump(hash, pretty: true))
end

def fetch_entries
  current_skip = 0
  entries_per_page = []
  loop do
    current_page = client.entries(content_type: 'vehicleModelVariant', include: 2, skip: current_skip)
    entries_per_page << current_page.to_a
    current_page.length.zero? ? break : current_skip += PAGE_SIZE
  end

  entries_per_page.flatten
end

def client
  @client ||= ::Contentful::Client.new(
    space: ENV['CONTENTFUL_SPACE_ID'],
    access_token: ENV['CONTENTFUL_ACCESS_TOKEN']
  )
end

def to_model(entry)
  {
    id: ShortUUID.expand(entry.id),
    brand: entry.model.brand.name,
    vehicle_type: entry.model.vehicle_type,
    type: entry.model.ev_type,
    brand_id: ShortUUID.expand(entry.model.brand.id),
    model: entry.model.name,
    release_year: entry.release_year,
    variant: entry.variant.to_s,
    usable_battery_size: entry.battery_size.to_f,
    ac_charger: ac_charger(entry),
    dc_charger: dc_charger(entry),
    energy_consumption: {
      average_consumption: entry.average_consumption.to_f
    }
  }
end

def ac_charger(entry)
  {
    usable_phases: entry.ac_phases,
    ports: list_value(entry, :ac_ports, []),
    max_power: entry.max_ac_power.to_f,
    power_per_charging_point: power_per_charging_point(entry)
  }
end

def dc_charger(entry)
  ports = list_value(entry, :dc_ports, [])
  return if ports.empty?

  curve = dc_charging_curve(entry)
  max_power = entry.max_dc_power
  {
    ports: ports,
    max_power: (curve ? curve.max_by { |v| v[:power] }[:power] : max_power).to_f,
    charging_curve: dc_charging_curve(entry),
    is_default_charging_curve: !entry.respond_to?(:dc_charging_curve)
  }
end

def dc_charging_curve(entry)
  unless entry.respond_to?(:dc_charging_curve)
    return nil unless entry.max_dc_power

    max_dc_power = entry.max_dc_power.to_f
    max_ac_power = entry.max_ac_power.to_f
    return default_charging_curve(max_dc_power, max_ac_power)
  end

  list_value(entry, :dc_charging_curve).map do |item|
    vals = item.split(',')
    { percentage: Integer(vals[0]), power: Float(vals[1]) }
  end
end

def default_charging_curve(max_dc_power, max_ac_power)
  [
    { percentage: 0, power: (max_dc_power * 0.95).round(1) },
    { percentage: 75, power: max_dc_power },
    { percentage: 100, power: max_ac_power }
  ]
end

def power_per_charging_point(entry)
  max_power = entry.max_ac_power.to_f
  max_phases = entry.ac_phases
  {
    2.0 => [max_power, 2.0].min.round(1),
    2.3 => [max_power, 2.3].min.round(1),
    3.7 => [max_power, 3.7].min.round(1),
    7.4 => [max_power, 7.4].min.round(1),
    11 => [max_power, max_phases * 3.7].min.round(1),
    16 => [max_power, max_phases * 5.4].min.round(1),
    22 => [max_power, max_phases * 7.4].min.round(1),
    43 => max_power > 22 ? max_power : [max_power, max_phases * 7.4].min.round(1)
  }
end

def list_value(entry, name, default = nil)
  return default unless entry.respond_to?(name)

  entry.public_send(name)
end

load_from_contentful
puts "Saved to #{FILE_NAME}"
