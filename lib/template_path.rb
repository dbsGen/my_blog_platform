require 'httpclient'
require 'template_manager'

module TemplatePath
  class << self
    FILE_PATH = "/home/gen/www/dynamic_template"
    ZIP_ADDRESS = 'http://127.0.0.1:4500/'
    TEMPLATE_MANAGER = TemplateManager::TempManager.new "#{FILE_PATH}/tmp/templates"

    def exist?(template)
      name = template.name
      version = template.version
      path = "#{FILE_PATH}/#{name}-#{version}"

      File.exist?(path) and File.exist?("#{path}/template.yml")
    end

    def get(template)
      name = template.name
      version = template.version
      file_name = "#{name}-#{version}.zip"
      address = "#{ZIP_ADDRESS}#{file_name}"
      client = HTTPClient.new
      response = client.get address
      TEMPLATE_MANAGER.new_folder do |path|
        tmp = "#{path}/#{file_name}"
        File.open tmp, 'wb' do |file|
          file.write response.body
        end
        TemplateManager::Decompression.actives tmp, "#{FILE_PATH}/#{name}-#{version}"
      end
    end

    def path(template)
      name = template.name
      version = template.version
      "#{FILE_PATH}/#{name}-#{version}/"
    end

    def edit_layout(template)
      name = template.name
      version = template.version
      "#{FILE_PATH}/#{name}-#{version}/edit/view/layout"
    end

    def edit_content(template)
      name = template.name
      version = template.version
      "#{FILE_PATH}/#{name}-#{version}/edit/view/content"
    end

    def skim_layout(template)
      name = template.name
      version = template.version
      "#{FILE_PATH}/#{name}-#{version}/skim/view/layout"
    end

    def skim_content(template)
      name = template.name
      version = template.version
      "#{FILE_PATH}/#{name}-#{version}/skim/view/content"
    end
  end
end