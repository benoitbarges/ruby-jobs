require 'json'
require 'date'

# votre code
class CompteRendu
  def self.results
    results = { 'totals' => [] }
    group_by_date.each do |date, coms|
      results['totals'] << { 'sent_on' => date, 'total' => calculate_price(coms) }
    end
    results
  end

  def self.calculate_price(coms)
    sum = coms.length * 0.1 + color_price(coms) + pages_price(coms)
    coms.each { |com| sum += 0.6 if express_delivery?(com['practitioner_id']) }
    sum.round(2)
  end

  def self.parse_json
    file = File.read('./data.json')
    JSON.parse(file)
  end

  def self.group_by_date
    parse_json['communications'].group_by { |com| Date.parse(com['sent_at']).strftime('%m/%d/%Y') }
  end

  def self.express_delivery?(practitioner_id)
    parse_json['practitioners'].find { |prac| prac['id'] == practitioner_id }['express_delivery']
  end

  def self.color?(com)
    com['color'] == true
  end

  def self.color_price(coms)
    sum = 0
    coms.each { |com| sum += 0.18 if color?(com) }
    sum
  end

  def self.pages_price(coms)
    sum = 0
    coms.each { |com| sum += 0.07 * (com['pages_number'] - 1) }
    sum
  end
end

p CompteRendu.results
