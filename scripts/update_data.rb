require 'dotenv'
require 'google/apis/sheets_v4'
require 'multi_json'
require 'pry'

Dotenv.load('.env')

FILE_NAME = '../data/ev-data.json'.freeze
PORT_NAME = %i[type1 type2 ccs chademo tesla_suc tesla_ccs].freeze
PORT_START_COLUMN = 9

def csv_to_json_file
  response = google_service.get_spreadsheet_values(sheet_id, 'Cars')
  cars_hash = response.values.drop(1).map { |row| parse_car(row) }

  hash = {
    data: cars_hash,
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

def parse_car(row)
  {
    id: row[0],
    brand: row[1],
    model: row[2],
    release_year: !row[3].empty? ? to_i(row[3]) : nil,
    variant: row[4],
    usable_battery_size: to_f(row[5]),
    ac_charger: ac_charger(row),
    dc_charger: dc_charger(row)
  }
end

def ac_charger(row)
  {
    usable_phases: to_i(row[6]),
    ports: [fetch_port(row, 0), fetch_port(row, 1)].compact,
    max_power: to_f(row[7]),
    power_per_charging_point: power_per_charging_point(row)
  }
end

def dc_charger(row)
  ports = [2, 3, 4].map { |idx| fetch_port(row, idx) }.compact
  return if ports.empty?

  curve = charging_curve(row)
  max_power = to_f(row[8])
  {
    ports: ports,
    max_power: curve ? curve.max_by { |v| v[:power] }[:power] : max_power,
    charging_curve: curve || default_charging_curve(max_power, row),
    is_default_charging_curve: !curve
  }
end

def charging_curve(row) # rubocop:disable Metrics/MethodLength
  data = row[15]
  return if data.nil? || data.empty?

  last_percentage = -1
  data.split(';').map do |pair|
    percentage, power = pair.split(',')
    percentage = to_i(percentage)
    power = to_i(power)
    raise 'percentage needs to grow' if last_percentage >= percentage

    last_percentage = percentage
    { percentage: percentage, power: power }
  end
end

def default_charging_curve(max_power, row)
  max_ac_power = to_f(row[6])

  [
    { percentage: 0, power: (max_power * 0.95).to_i },
    { percentage: 75, power: max_power },
    { percentage: 100, power: max_ac_power }
  ]
end

def fetch_port(row, column)
  row[PORT_START_COLUMN + column] == 'x' ? PORT_NAME[column] : nil
end

def power_per_charging_point(row)
  max_power = to_f(row[7])
  max_phases = to_i(row[6])
  {
    2.3 => [max_power, 2.3].min,
    3.7 => [max_power, 3.7].min,
    7.4 => [max_power, 7.4].min,
    11 => [max_power, max_phases * 3.7].min,
    22 => [max_power, max_phases * 7.4].min,
    43 => max_power > 22 ? max_power : [max_power, max_phases * 7.4].min
  }
end

def to_f(value)
  Float(value.tr(',', '.')).tap { |f| raise 'float must be >=0' unless f >= 0 }
end

def to_i(value)
  Integer(value).tap { |i| raise 'int must be >=0' unless i >= 0 }
end

def sheet_id
  ENV['APPLICATION_SHEET_ID']
end

csv_to_json_file
puts "Saved to #{FILE_NAME}"
