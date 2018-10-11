class HeaderElevator < Apartment::Elevators::Generic
  def parse_tenant_name(request)
    tenant_name = request.get_header('HTTP_X_TENANT')

    if ActiveRecord::Migration.schema_exists?(tenant_name)
      tenant_name
    else
      'public'
    end
  end
end
