json.extract! api_v1_transactions, :id, :price, :status, :created_at, :updated_at
 
json.property do
    json.extract! api_v1_transactions.reservation.property, :id, :name
end
