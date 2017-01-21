require 'rails_helper'

RSpec.describe Address, type: :model do
  describe 'Geolocation - latitude and longitude' do

    context 'with valid address' do
      it 'returns the right latitude and longitude' do
        @address = create(:address, country: 'Brazil', state: 'Sao Paulo', city: 'Sao Paulo', neighborhood: 'Bela Vista', street: 'Av Paulista', number: '1000')
        expect(@address.latitude.to_f).to eql(-23.5650071)
        expect(@address.longitude.to_f).to eql(-46.6520933)
      end
    end

    context 'with blank address' do
      it 'returns cordinates for an unknown place' do
        @address = create(:address, country: 'na', state: 'na', city: 'na', neighborhood: 'na', street: 'na', number: 'na')
        expect(@address.latitude.to_f).to eql(-22.95764)
        expect(@address.longitude.to_f).to eql(18.49041)
      end
    end
  end
end
