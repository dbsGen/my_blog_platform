CONFIG = Hashie::Mash.new YAML.load(File.open('config/config.yml'))
ID_REGEXP = /@[\w.]+/

