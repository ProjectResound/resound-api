namespace :db do
  task create_tenants: :environment do
    Apartment.tenant_names.each do |tenant_name|
      next if ActiveRecord::Migration.schema_exists?(tenant_name)

      Apartment::Tenant.create(tenant_name)
      puts "Created #{tenant_name} tenant"
    end
  end
end
