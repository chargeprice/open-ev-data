require 'dotenv'
require 'google/apis/sheets_v4'
require 'multi_json'
require 'pry'

Dotenv.load('.env')

FILE_NAME = '../data/ev-data.json'.freeze
PORT_NAME = %i[type1 type2 ccs chademo tesla_suc tesla_ccs].freeze
ALLOWED_TYPES = ["bev","phev"]
ALLOWED_VECHICLE_TYPES=["car","motorbike","scooter"]

ROWS = [
  :id,
  :brand,
  :vehicle_type,
  :type,
  :model,
  :release_year,
  :variant,
  :usable_battery_size,
  :average_consumption,
  :ac_phases,
  :max_ac_power,
  :max_dc_power,
  :plug_type1,
  :plug_type2,
  :plug_ccs,
  :plug_chademo,
  :plug_tesla_suc,
  :plug_tesla_ccs,
  :dc_charging_curve
]

PORT_START_COLUMN = ROWS.index(:plug_type1)

def csv_to_json_file
  response_cars = google_service.get_spreadsheet_values(sheet_id, 'Cars')
  response_brands = google_service.get_spreadsheet_values(sheet_id, 'Brands')
  indexed_brands = indexed_brands(response_brands)
  cars_hash = response_cars.values.drop(1).map { |row| parse_car(row,indexed_brands) }

  hash = {
    data: cars_hash,
    brands: indexed_brands.map { |name,id| { id: id, name: name } },
    meta: {
      updated_at: Time.now.utc.iso8601,
      overall_count: cars_hash.size
    }
  }

  File.write(FILE_NAME, MultiJson.dump(hash, pretty: true))
end

def google_service
  service = Google::Apis::SheetsV4::SheetsService.new
  auth = ::Google::Auth::ServiceAccountCredentials
         .make_creds(scope: Google::Apis::SheetsV4::AUTH_SPREADSHEETS_READONLY)
  service.authorization = auth
  service
end

def parse_car(row,brands)
  {
    id: field(row,:id),
    brand: field(row,:brand),
    vehicle_type: field(row,:vehicle_type),
    type: field(row, :type).downcase.tap { |t| ALLOWED_TYPES.include?(t) },
    brand_id: brands.fetch(field(row,:brand)) { raise "brand #{field(row,:brand)} not found" },
    model: field(row,:model),
    release_year: !field(row,:release_year).empty? ? to_i(row,:release_year) : nil,
    variant: field(row,:variant),
    usable_battery_size: to_f(row,:usable_battery_size),
    ac_charger: ac_charger(row),
    dc_charger: dc_charger(row),
    energy_consumption: {
      average_consumption: to_f(row,:average_consumption)
    }
  }
end

def indexed_brands(response_brands)
  response_brands.values.drop(1).each_with_object({}) do |(id,name),memo|
    memo[name]=id
  end
end

def ac_charger(row)
  {
    usable_phases: to_i(row,:ac_phases),
    ports: [fetch_port(row, 0), fetch_port(row, 1)].compact,
    max_power: to_f(row,:max_ac_power),
    power_per_charging_point: power_per_charging_point(row)
  }
end

def dc_charger(row)
  ports = [2, 3, 4, 5].map { |idx| fetch_port(row, idx) }.compact
  return if ports.empty?

  curve = charging_curve(row)
  max_power = to_f(row,:max_dc_power)
  {
    ports: ports,
    max_power: curve ? curve.max_by { |v| v[:power] }[:power] : max_power,
    charging_curve: curve || default_charging_curve(max_power, row),
    is_default_charging_curve: !curve
  }
end

def charging_curve(row) # rubocop:disable Metrics/MethodLength
  data = field(row,:dc_charging_curve)
  return if data.nil? || data.empty?

  last_percentage = -1
  data.split(';').map do |pair|
    percentage, power = pair.split(',')
    percentage = Integer(percentage)
    power = Integer(power)
    raise 'percentage needs to grow' if last_percentage >= percentage

    last_percentage = percentage
    { percentage: percentage, power: power }
  end
end

def default_charging_curve(max_power, row)
  max_ac_power = to_f(row,:max_ac_power)
  [
    { percentage: 0, power: (max_power * 0.95).to_i },
    { percentage: 75, power: max_power },
    { percentage: 100, power: max_ac_power }
  ]
end

def fetch_port(row, column)
  ['x','o'].include?(row[PORT_START_COLUMN + column]) ? PORT_NAME[column] : nil
end

def power_per_charging_point(row)
  max_power = to_f(row,:max_ac_power)
  max_phases = to_i(row,:ac_phases)
  {
    2.0 => [max_power, 2.0].min,
    2.3 => [max_power, 2.3].min,
    3.7 => [max_power, 3.7].min,
    7.4 => [max_power, 7.4].min,
    11 => [max_power, max_phases * 3.7].min,
    16 => [max_power, max_phases * 5.4].min,
    22 => [max_power, max_phases * 7.4].min,
    43 => max_power > 22 ? max_power : [max_power, max_phases * 7.4].min
  }
end

def field(row,name)
  row[ROWS.index(name)]
end

def to_f(row,name)
  value = field(row,name)
  Float(value.tr(',', '.')).tap { |f| raise 'float must be >=0' unless f >= 0 }
end

def to_i(row,name)
  value = field(row,name)
  Integer(value).tap { |i| raise 'int must be >=0' unless i >= 0 }
end

def sheet_id
  ENV['APPLICATION_SHEET_ID']
end

csv_to_json_file
puts "Saved to #{FILE_NAME}"
