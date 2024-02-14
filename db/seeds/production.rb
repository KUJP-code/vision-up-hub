Organisation.create!(name: 'KidsUP', email: 'kidsup@gmail.com', phone: '1234567890')

Admin.create!(
  name: 'Brett',
  email: 'admin@gmail.com',
  password: ENV['ADMIN_PASS'],
  organisation_id: Organisation.first.id
)
