RSpec.describe Invoice, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      invoice = build(:invoice)
      expect(invoice).to be_valid
    end
  end
end
