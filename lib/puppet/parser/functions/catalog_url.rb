def os_name_in_catalog_url(os_minor_version)
  case os_minor_version
  when 5
    'leopard'
  when 6
    'snowleopard'
  when 7
    'lion'
  when 8
    'mountainlion'
  when 9
    '10.9'
  when 10
    '10.10'
  when 11
    '10.11'
  else
    '10.12'
  end
end

module Puppet::Parser::Functions
  newfunction(:catalog_url, :type => :rvalue) do |args|
    os_name = args[0]
    if os_name == '10.4'
      "/content/catalogs/index"
    else
      os_minor_version = function_os_minor_version([os_name])
      os_minor_versions = (5..os_minor_version).to_a.reverse
      url = os_minor_versions.map { |o| os_name_in_catalog_url(o) }.join('-')
      "/content/catalogs/others/index-#{url}.merged-1"
    end
  end
end
