require 'puppet/ssl'
require 'puppet/util/yaml'

# This class transforms simple key/value pairs into the equivalent ASN1
# structures. Values may be strings or arrays of strings.
#
# @api private
class Puppet::SSL::CertificateRequestAttributes

  attr_reader :path, :custom_attributes, :extension_requests

  def initialize(path)
    @path = path
    @custom_attributes = {}
    @extension_requests = {}
  end

  # Attempt to load a yaml file at the given @path.
  # @return true if we are able to load the file, false otherwise
  # @raise [Puppet::Error] if there are unexpected attribute keys
  def load
    Puppet.info(_("csr_attributes file loading from %{path}") % { path: path })
    if Puppet::FileSystem.exist?(path)
      hash = Puppet::Util::Yaml.load_file(path, {})
      if ! hash.is_a?(Hash)
        raise Puppet::Error, _("invalid CSR attributes, expected instance of Hash, received instance of %{klass}") % { klass: hash.class }
      end
      @custom_attributes = hash.delete('custom_attributes') || {}
      @extension_requests = hash.delete('extension_requests') || {}
      if not hash.keys.empty?
        raise Puppet::Error, _("unexpected attributes %{keys} in %{path}") % { keys: hash.keys.inspect, path: @path.inspect }
      end
      return true
    end
    return false
  end
end
