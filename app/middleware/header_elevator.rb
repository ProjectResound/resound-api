class HeaderElevator < Apartment::Elevators::Generic
  def parse_tenant_name(request)
    tenant_name = request.get_header('HTTP_X_TENANT')

    tenant_name.present? ? tenant_name : 'public'
  end
end
