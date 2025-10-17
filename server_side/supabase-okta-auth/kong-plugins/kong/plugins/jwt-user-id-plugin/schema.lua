local PLUGIN_NAME = "jwt-user-id-plugin"

local schema = {
  name = PLUGIN_NAME,
  fields = {
    { config = {
        type = "record",
        fields = {
          {
            user_id_field = {
              type = "string",
              required = true,
              default = "sub"
            }
          },
          {
            header_name = {
              type = "string",
              required = true,
              default = "Okta-User-ID"
            }
          }
        },
      },
    },
  },
}

return schema
