ENV['RACK_ENV'] ||= 'test'

require_relative '../config/environment.rb'

require 'edu_apps'

require 'rack/test'
require 'json'

RSpec.configure do |config|
  config.before(:each) do
    DataMapper.auto_migrate!
  end
end

def populate_apps
  apps = JSON.parse(File.read('./public/data/lti_examples.json'))
  ap = AdminPermission.create(:username => "me", :apps => "any")
  apps.each_with_index do |app, idx|
    obj = App.build_or_update(app['id'], app, ap)
  end
end
  
def app_review
  app = App.last
  @token = ExternalAccessToken.create(:token => 'abc', :active => true)
  @review = AppReview.create(
    :tool_id => app.tool_id,
    :external_access_token_id => @token.id,
    :tool_name => app.name,
    :user_id => 12345,
    :user_name => "Some User",
    :user_url => "http://www.example.com/some_user",
    :rating => 4,
    :comments => "This is good",
    :created_at => Time.now
  )
end

def admin_permission
  AdminPermission.create
end

def lti_xml
  <<-EOF
<?xml version="1.0" encoding="UTF-8"?>
<cartridge_basiclti_link xmlns="http://www.imsglobal.org/xsd/imslticc_v1p0"
    xmlns:blti = "http://www.imsglobal.org/xsd/imsbasiclti_v1p0"
    xmlns:lticm ="http://www.imsglobal.org/xsd/imslticm_v1p0"
    xmlns:lticp ="http://www.imsglobal.org/xsd/imslticp_v1p0"
    xmlns:xsi = "http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation = "http://www.imsglobal.org/xsd/imslticc_v1p0 http://www.imsglobal.org/xsd/lti/ltiv1p0/imslticc_v1p0.xsd
    http://www.imsglobal.org/xsd/imsbasiclti_v1p0 http://www.imsglobal.org/xsd/lti/ltiv1p0/imsbasiclti_v1p0.xsd
    http://www.imsglobal.org/xsd/imslticm_v1p0 http://www.imsglobal.org/xsd/lti/ltiv1p0/imslticm_v1p0.xsd
    http://www.imsglobal.org/xsd/imslticp_v1p0 http://www.imsglobal.org/xsd/lti/ltiv1p0/imslticp_v1p0.xsd">
    <blti:launch_url>https://example.com/wiki</blti:launch_url>
    <blti:title>Global Wiki</blti:title>
    <blti:description>Institution-wide wiki tool with all the trimmings</blti:description>
    <blti:extensions platform="canvas.instructure.com">
      <lticm:property name="privacy_level">public</lticm:property>
      <lticm:property name="domain">example.com</lticm:property>
      <lticm:property name="icon_url">https://example.com/wiki.png</lticm:property>
      <lticm:property name="text">Build/Link to Wiki Page</lticm:property>
      <lticm:options name="labels">
          <lticm:property name="en-US">Build/Link to Wiki Page</lticm:property>
          <lticm:property name="en-GB">Build/Link to Wiki Page</lticm:property>
        </lticm:options>
      <lticm:options name="editor_button">
        <lticm:property name="enabled">true</lticm:property>
        <lticm:property name="selection_width">500</lticm:property>
        <lticm:property name="selection_height">300</lticm:property>
      </lticm:options>
      <lticm:options name="resource_selection">
        <lticm:property name="enabled">true</lticm:property>
        <lticm:property name="selection_width">500</lticm:property>
        <lticm:property name="selection_height">300</lticm:property>
      </lticm:options>
    </blti:extensions>
</cartridge_basiclti_link>
  EOF
end