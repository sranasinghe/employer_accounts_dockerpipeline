module FixtureLoader
  def self.root
    @root ||= Pathname(File.expand_path('../../', __FILE__)).join 'fixtures'
  end

  def self.load_fixture(*args)
    output = read_fixture(*args)
    return nil unless output
    output.gsub!(/\s*\n\s*/, '')
    output
  end

  def self.read_fixture(fixture, format, binding)
    path = FixtureLoader.root.join "#{fixture}.#{format}"
    return path.read if path.exist?
    template = path.sub_ext "#{path.extname}.erb"
    return nil unless template.exist?
    ERB.new(template.read).result binding
  end

  def method_or_default(method:, default:)
    method(method).call
  rescue NameError
    default
  end

  def method_missing(meth, *args, &block)
    if /^(?<fixture>.*)_(?<format>json|xml)$/ =~ meth.to_s
      binding = instance_eval { binding }
      FixtureLoader.load_fixture(fixture, format, binding) || super
    else
      super
    end
  end
end
