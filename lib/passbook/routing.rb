module Passbook
  module Routing
    def passbook_routes
      scope module: "passbook/controllers", controller: :passbook, path: :passbook, constraints: { pass_type_id: /([\w\d\-\.])+/ } do
    
        root as: :passbook_root, to: redirect("/")
        scope path: :v1 do
      
          scope "passes/:pass_type_id" do
            get ":serial_number", action: :show_pass
          end
      
          scope "devices/:device_id/registrations/:pass_type_id" do
            scope ":serial_number" do
              post action: :register_device
              delete action: :unregister_device
            end
            get "/", action: :modified_passes
          end
      
          post "log", action: :log
      
        end
      end
    end
  end
end